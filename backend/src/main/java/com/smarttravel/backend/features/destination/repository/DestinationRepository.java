package com.smarttravel.backend.features.destination.repository;

import com.smarttravel.backend.features.destination.domain.Destination;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DestinationRepository extends JpaRepository<Destination, Long> {
    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_READ)
    @Query("select d from Destination d join fetch d.category where d.id = :id")
    Optional<Destination> lockForPublicSelection(Long id);

    @Query("""
            select d from Destination d join fetch d.category c
            where d.status = 'ACTIVE' and c.status = 'ACTIVE' and c.code in :codes
              and (:search = '' or locate(:search, lower(d.name)) > 0 or locate(:search, lower(d.nameEn)) > 0)
              and (:min is null or coalesce(d.priceMaxVnd, d.priceMinVnd) >= :min)
              and (:max is null or coalesce(d.priceMinVnd, d.priceMaxVnd) <= :max)
            order by d.id
            """)
    org.springframework.data.domain.Slice<Destination> discover(String search, java.util.Set<String> codes,
            Long min, Long max, org.springframework.data.domain.Pageable pageable);

    @Override
    @EntityGraph(attributePaths = {"category"})
    List<Destination> findAll();

    @Override
    @EntityGraph(attributePaths = {"category"})
    Optional<Destination> findById(Long id);

    @EntityGraph(attributePaths = {"category"})
    List<Destination> findByStatus(String status);

    @Query("SELECT d FROM Destination d JOIN FETCH d.category c WHERE c.id = :categoryId")
    List<Destination> findByCategoryId(@Param("categoryId") Long categoryId);

    @Query("SELECT d FROM Destination d JOIN FETCH d.category c WHERE c.id = :categoryId AND d.status = :status")
    List<Destination> findByCategoryIdAndStatus(@Param("categoryId") Long categoryId, @Param("status") String status);

    @Query("SELECT COUNT(d) FROM Destination d WHERE d.category.id = :categoryId")
    long countByCategoryId(@Param("categoryId") Long categoryId);

    @Query("SELECT d FROM Destination d JOIN FETCH d.category c WHERE (LOWER(c.code) = LOWER(:category) OR LOWER(c.name) = LOWER(:category) OR LOWER(c.slug) = LOWER(:category)) AND d.status = :status")
    List<Destination> findByCategoryAndStatus(@Param("category") String category, @Param("status") String status);

    @Query("SELECT d FROM Destination d JOIN FETCH d.category c WHERE LOWER(c.code) = LOWER(:category) OR LOWER(c.name) = LOWER(:category) OR LOWER(c.slug) = LOWER(:category)")
    List<Destination> findByCategory(@Param("category") String category);
}
