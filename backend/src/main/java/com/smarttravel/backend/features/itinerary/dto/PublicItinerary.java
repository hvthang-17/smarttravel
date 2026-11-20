package com.smarttravel.backend.features.itinerary.dto;

import java.time.LocalDate;
import java.util.List;

public record PublicItinerary(String title, LocalDate startDate, LocalDate endDate, List<Day> days) {
    public record Day(int dayNumber, LocalDate date, List<Stop> items) {}

    public record Stop(int sequenceOrder, String startTime, Integer durationMinutes, Place destination,
                       String routeSource, String routePolyline, Double travelDistanceKm, Integer travelMinutes) {}

    public record Place(String name, String category, Double latitude, Double longitude) {}
}
