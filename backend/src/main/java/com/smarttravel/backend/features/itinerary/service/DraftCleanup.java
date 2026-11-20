package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.features.itinerary.repository.ItineraryRepository;
import org.springframework.scheduling.annotation.*;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Component
@EnableScheduling
public class DraftCleanup {
    private final ItineraryRepository trips;
    public DraftCleanup(ItineraryRepository trips) { this.trips = trips; }

    @Scheduled(initialDelay = 3600000, fixedDelay = 86400000)
    @Transactional
    public void clean() {
        trips.deleteExpiredDrafts(Instant.now().minus(7, ChronoUnit.DAYS));
    }
}
