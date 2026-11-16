package com.smarttravel.backend.features.destination.repository;

import com.smarttravel.backend.features.destination.domain.DestinationReview;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import java.util.*;

public interface DestinationReviewRepository extends JpaRepository<DestinationReview, Long> {
    Optional<DestinationReview> findByDestinationIdAndUserId(Long destinationId, Long userId);

    Slice<DestinationReview> findByDestinationIdAndStatusOrderByCreatedAtDescIdDesc(Long destinationId, String status, Pageable page);

    @Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @Query("select r from DestinationReview r where r.id = :id")
    Optional<DestinationReview> lockById(Long id);

    @Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @Query("select r from DestinationReview r where r.destinationId = :destinationId and r.userId = :userId")
    Optional<DestinationReview> lockOwned(Long destinationId, Long userId);

    interface ModerationRow {
        DestinationReview getReview();
        String getDestinationName();
    }

    @Query("""
            select r as review, d.name as destinationName from DestinationReview r join Destination d on d.id = r.destinationId
            where (:status = 'ALL' or r.status = :status)
              and (:destinationId is null or r.destinationId = :destinationId)
              and (:reportedOnly = false or exists (
                 select 1 from AuditLog a where a.entityType = 'REVIEW' and a.action = 'REPORT' and a.entityId = r.id))
            order by r.createdAt desc, r.id desc
            """)
    Slice<ModerationRow> moderationPage(String status, Long destinationId, boolean reportedOnly, Pageable page);
    interface Summary {
        Long getDestinationId();
        Long getRatingTotal();
        Long getReviewCount();
    }
    @Query("select r.destinationId as destinationId, sum(r.rating) as ratingTotal, count(r) as reviewCount "
            + "from DestinationReview r where r.status = 'PUBLISHED' and r.destinationId in :ids group by r.destinationId")
    List<Summary> summarize(@Param("ids") Collection<Long> ids);
}
