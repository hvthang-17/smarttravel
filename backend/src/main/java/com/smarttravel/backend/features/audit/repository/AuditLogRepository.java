package com.smarttravel.backend.features.audit.repository;

import com.smarttravel.backend.features.audit.domain.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
    boolean existsByEntityTypeAndEntityIdAndActionAndUserId(String entityType, Long entityId, String action, Long userId);

    interface ReviewReportSummary {
        Long getReviewId();
        String getReason();
        Long getCount();
    }

    @org.springframework.data.jpa.repository.Query(value = """
            select entity_id as reviewId, json_unquote(json_extract(details, '$.reason')) as reason, count(*) as count
            from audit_logs where entity_type = 'REVIEW' and action = 'REPORT' and entity_id in (:ids)
            group by entity_id, json_unquote(json_extract(details, '$.reason'))
            """, nativeQuery = true)
    java.util.List<ReviewReportSummary> summarizeReviewReports(java.util.Collection<Long> ids);
    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query("update AuditLog a set a.userId = null, a.actorName = null where a.userId = :id")
    void anonymizeActor(Long id);
}
