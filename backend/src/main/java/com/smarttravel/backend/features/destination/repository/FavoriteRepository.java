package com.smarttravel.backend.features.destination.repository;

import com.smarttravel.backend.features.destination.domain.*;
import org.springframework.data.jpa.repository.*;
import java.util.List;

public interface FavoriteRepository extends JpaRepository<Favorite, Favorite.Key> {
    @Query("""
            select d from Favorite f join Destination d on d.id = f.destinationId join fetch d.category c
            where f.userId = :userId and d.status = 'ACTIVE' and c.status = 'ACTIVE' and c.code in :codes
            order by f.createdAt desc, d.id desc
            """)
    List<Destination> visible(Long userId, java.util.Set<String> codes);

    boolean existsByUserIdAndDestinationId(Long userId, Long destinationId);
    List<Favorite> findByUserIdAndDestinationIdIn(Long userId, List<Long> destinationIds);
    void deleteByUserIdAndDestinationId(Long userId, Long destinationId);
}
