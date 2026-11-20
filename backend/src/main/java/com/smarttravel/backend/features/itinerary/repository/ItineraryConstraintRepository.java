package com.smarttravel.backend.features.itinerary.repository;

import com.smarttravel.backend.features.itinerary.domain.ItineraryConstraint;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ItineraryConstraintRepository extends JpaRepository<ItineraryConstraint, ItineraryConstraint.Key> {
    List<ItineraryConstraint> findByItineraryIdOrderByConstraintTypeAscDestinationIdAsc(Long itineraryId);
}
