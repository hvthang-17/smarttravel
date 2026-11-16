package com.smarttravel.backend.features.destination.service;

import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.features.audit.service.AuditService;
import com.smarttravel.backend.features.audit.repository.AuditLogRepository;
import com.smarttravel.backend.features.destination.dto.ReviewDtos.*;
import com.smarttravel.backend.features.destination.repository.DestinationReviewRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.Instant;
import java.util.*;

@Service
public class ReviewModerationService {
    private final DestinationReviewRepository reviews;
    private final AuditService audit;
    private final AuditLogRepository logs;
    public ReviewModerationService(DestinationReviewRepository reviews, AuditService audit, AuditLogRepository logs) {
        this.reviews = reviews;
        this.audit = audit;
        this.logs = logs;
    }

    @Transactional(readOnly = true)
    public Page<ModerationReview> list(String status, Long destinationId, boolean reportedOnly, int page, int size) {
        requireAdmin();
        if (!Set.of("ALL", "PUBLISHED", "HIDDEN").contains(status) || (destinationId != null && destinationId <= 0)) {
            throw new IllegalArgumentException("Bộ lọc đánh giá không hợp lệ");
        }
        var result = reviews.moderationPage(status, destinationId, reportedOnly, DestinationReviews.pageRequest(page, size));
        var ids = result.getContent().stream().map(row -> row.getReview().getId()).toList();
        Map<Long, Map<String, Long>> reports = new HashMap<>();
        if (!ids.isEmpty()) {
            for (var report : logs.summarizeReviewReports(ids)) {
                reports.computeIfAbsent(report.getReviewId(), id -> new TreeMap<>())
                        .put(report.getReason(), report.getCount());
            }
        }
        return new Page<>(result.getContent().stream().map(row -> {
            var r = row.getReview();
            return new ModerationReview(r.getId(), r.getDestinationId(), row.getDestinationName(),
                    r.getRating(), r.getComment(), r.getStatus(), r.getCreatedAt(), reports.getOrDefault(r.getId(), Map.of()));
        }).toList(), result.hasNext());
    }

    @Transactional
    public void changeStatus(Long id, String status) {
        requireAdmin();
        if (!Set.of("PUBLISHED", "HIDDEN").contains(status)) throw new IllegalArgumentException("Trạng thái review không hợp lệ");
        var review = reviews.lockById(id).orElseThrow(() -> new ResourceNotFoundException("Review", "id", id));
        review.setStatus(status); review.setUpdatedAt(Instant.now());
        reviews.save(review);
        audit.record("REVIEW", id, "MODERATE", Map.of("status", status));
    }

    private static void requireAdmin() {
        if (!com.smarttravel.backend.common.CurrentUser.isAdmin()) {
            throw new org.springframework.security.access.AccessDeniedException("Cần quyền quản trị viên");
        }
    }
}
