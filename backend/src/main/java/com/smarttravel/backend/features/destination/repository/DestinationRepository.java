package com.smarttravel.backend.features.destination.repository;

import com.smarttravel.backend.features.destination.domain.Destination;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DestinationRepository extends JpaRepository<Destination, Long> {
    List<Destination> findByCategoryAndStatus(String category, String status);
    List<Destination> findByStatus(String status);
}
