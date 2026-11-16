package com.smarttravel.backend.features.destination.service;

import com.smarttravel.backend.common.CurrentUser;
import com.smarttravel.backend.common.ResourceConflictException;
import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.features.audit.repository.AuditLogRepository;
import com.smarttravel.backend.features.audit.service.AuditService;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.category.service.CatalogPolicy;
import com.smarttravel.backend.features.destination.domain.DestinationReview;
import com.smarttravel.backend.features.destination.dto.ReviewDtos.*;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import com.smarttravel.backend.features.destination.repository.DestinationReviewRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Map;

@Service
public class DestinationReviews {
    private final DestinationReviewRepository reviews;
    private final DestinationRepository destinations;
    private final UserRepository users;
    private final AuditLogRepository logs;
    private final AuditService audit;

    public DestinationReviews(DestinationReviewRepository reviews, DestinationRepository destinations,
                              UserRepository users, AuditLogRepository logs, AuditService audit) {
        this.reviews = reviews;
        this.destinations = destinations;
        this.users = users;
        this.logs = logs;
        this.audit = audit;
    }

    @Transactional(readOnly = true)
    public Page<PublicReview> list(long destinationId, int page, int size) {
        requireAvailable(destinationId, false);
        var result = reviews.findByDestinationIdAndStatusOrderByCreatedAtDescIdDesc(
                destinationId, "PUBLISHED", pageRequest(page, size));
        return new Page<>(result.getContent().stream().map(r -> new PublicReview(
                r.getId(), r.getRating(), r.getComment(), r.getCreatedAt(), r.getUpdatedAt())).toList(), result.hasNext());
    }

    @Transactional(readOnly = true)
    public OwnedReview mine(long destinationId) {
        return reviews.findByDestinationIdAndUserId(destinationId, account(false))
                .map(DestinationReviews::ownDto).orElse(null);
    }

    @Transactional
    public OwnedReview create(long destinationId, Write write) {
        var actor = account(true);
        requireAvailable(destinationId, true);
        if (reviews.findByDestinationIdAndUserId(destinationId, actor).isPresent()) {
            throw new ResourceConflictException("Bạn đã đánh giá địa điểm này. Hãy sửa bài đánh giá hiện có.");
        }
        var review = new DestinationReview();
        review.setDestinationId(destinationId);
        review.setUserId(actor);
        apply(review, write);
        return ownDto(reviews.saveAndFlush(review));
    }

    @Transactional
    public OwnedReview update(long destinationId, Write write) {
        var review = lockedMine(destinationId);
        apply(review, write);
        return ownDto(reviews.saveAndFlush(review));
    }

    @Transactional
    public void delete(long destinationId) {
        reviews.delete(lockedMine(destinationId));
    }

    @Transactional
    public void report(long destinationId, long reviewId, Reason reason) {
        var actor = account(true);
        requireAvailable(destinationId, true);
        var review = reviews.lockById(reviewId)
                .filter(r -> r.getDestinationId() == destinationId && "PUBLISHED".equals(r.getStatus()))
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy bài đánh giá"));
        if (review.getUserId().equals(actor)) throw new IllegalArgumentException("Bạn không thể báo cáo bài của mình");
        if (!logs.existsByEntityTypeAndEntityIdAndActionAndUserId("REVIEW", reviewId, "REPORT", actor)) {
            audit.record("REVIEW", reviewId, "REPORT", Map.of("reason", reason.name()));
        }
    }

    private DestinationReview lockedMine(long destinationId) {
        return reviews.lockOwned(destinationId, account(true))
                .orElseThrow(() -> new ResourceNotFoundException("Bạn chưa có đánh giá tại địa điểm này"));
    }

    private Long account(boolean lock) {
        var email = CurrentUser.email();
        var user = (lock ? users.lockByEmail(email) : users.findByEmail(email))
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản"));
        CurrentUser.requireCurrentAccount(user);
        return user.getId();
    }

    private void requireAvailable(long id, boolean lock) {
        (lock ? destinations.lockForPublicSelection(id) : destinations.findById(id))
                .filter(d -> "ACTIVE".equals(d.getStatus()) && CatalogPolicy.available(d.getCategory()))
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy địa điểm"));
    }

    static PageRequest pageRequest(int page, int size) {
        if (page < 0 || page > 100_000 || size < 1 || size > 50) {
            throw new IllegalArgumentException("Tham số phân trang không hợp lệ");
        }
        return PageRequest.of(page, size);
    }

    private static void apply(DestinationReview review, Write write) {
        review.setRating(write.rating().intValueExact());
        var comment = write.comment();
        review.setComment(comment == null || comment.isBlank() ? null : comment.strip());
        review.setUpdatedAt(Instant.now());
    }

    private static OwnedReview ownDto(DestinationReview r) {
        return new OwnedReview(r.getId(), r.getRating(), r.getComment(), r.getStatus(), r.getCreatedAt(), r.getUpdatedAt());
    }
}
