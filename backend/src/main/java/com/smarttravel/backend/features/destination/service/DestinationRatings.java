package com.smarttravel.backend.features.destination.service;

import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.destination.repository.DestinationReviewRepository;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class DestinationRatings {
    private final DestinationReviewRepository reviews;
    public DestinationRatings(DestinationReviewRepository reviews) { this.reviews = reviews; }

    public List<DestinationDto> enrich(List<DestinationDto> destinations) {
        if (destinations.isEmpty()) return destinations;
        Map<Long, DestinationReviewRepository.Summary> summaries = new HashMap<>();
        reviews.summarize(destinations.stream().map(DestinationDto::getId).toList())
                .forEach(value -> summaries.put(value.getDestinationId(), value));
        for (DestinationDto destination : destinations) {
            var summary = summaries.get(destination.getId());
            destination.setAppRating(summary == null ? null : (double) summary.getRatingTotal() / summary.getReviewCount());
            destination.setAppReviewCount(summary == null ? 0L : summary.getReviewCount());
        }
        return destinations;
    }
}
