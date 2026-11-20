package com.smarttravel.backend.features.itinerary.repository;

import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

import java.util.Optional;

@Repository
public interface ItineraryRepository extends JpaRepository<Itinerary, Long> {
    List<Itinerary> findByUserId(Long userId);
    long countByUserId(Long userId);

    interface OwnerCount {
        Long getOwnerId();
        Long getTripCount();
    }

    @org.springframework.data.jpa.repository.Query("""
            select i.user.id as ownerId, count(i) as tripCount from Itinerary i
            where i.user.id in :ids group by i.user.id
            """)
    List<OwnerCount> countByOwners(List<Long> ids);
    Optional<Itinerary> findByShareToken(String shareToken);
    Optional<Itinerary> findByUserIdAndGenerationKey(Long userId, String generationKey);
    List<Itinerary> findByUserIdAndStatusOrderByUpdatedAtDescIdDesc(Long userId, String status);
    List<Itinerary> findByStatusNot(String status);

    @org.springframework.data.jpa.repository.Query("""
            select i from Itinerary i where i.user.id = :userId and i.status = 'SAVED'
            and (:pattern = '' or lower(i.title) like :pattern escape '!')
            and (:period = 'ALL' or (:period = 'UPCOMING' and i.endDate >= :today)
                 or (:period = 'HISTORY' and i.endDate < :today))
            order by i.updatedAt desc, i.id desc
            """)
    org.springframework.data.domain.Page<Itinerary> findSavedPage(Long userId, String pattern, String period,
            java.time.LocalDate today, org.springframework.data.domain.Pageable pageable);

    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select i from Itinerary i where i.id = :id")
    Optional<Itinerary> lockById(Long id);

    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query("delete from Itinerary i where i.status = 'DRAFT' and i.updatedAt < :cutoff")
    int deleteExpiredDrafts(java.time.Instant cutoff);
}
