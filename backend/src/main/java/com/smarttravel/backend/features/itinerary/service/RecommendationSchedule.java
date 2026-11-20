package com.smarttravel.backend.features.itinerary.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.destination.service.OpeningHours;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

final class RecommendationSchedule {
    static final int BUFFER = 30;
    private static final int UNKNOWN_TRAVEL_ALLOWANCE = 30;

    record Window(int start, int end) {
        Window intersect(Window other) {
            return new Window(Math.max(start, other.start), Math.min(end, other.end));
        }

        boolean encloses(long startSecond, long endSecond) {
            return startSecond >= start * 60L && endSecond <= end * 60L;
        }
    }

    record Stop(Destination destination, String code, int duration, Long unitPrice, JsonNode hours,
                boolean required, boolean favorite, boolean preferred, int rank) {
        long id() { return destination.getId(); }
        String name() { return destination.getName(); }
        boolean meal() { return "FOOD".equals(code); }
        boolean featured() { return destination.getFeaturedReason() != null; }
        OsrmRouting.Point point() { return coordinate(destination.getLatitude(), destination.getLongitude()); }
    }
    record Visit(Stop stop, int start, boolean hoursUnknown, OsrmRouting.Leg leg) {}
    record Day(List<Visit> visits, int travelMinutes) {
        List<Stop> stops() { return visits.stream().map(Visit::stop).toList(); }
        long sightseeing() { return visits.stream().filter(visit -> !visit.stop().meal()).count(); }
    }

    static OsrmRouting.Point coordinate(BigDecimal latitude, BigDecimal longitude) {
        return latitude == null || longitude == null ? null : new OsrmRouting.Point(latitude, longitude);
    }

    private final OsrmRouting.Point origin;
    private final RecommendationRoutes routes;
    private final int maxVisits;

    RecommendationSchedule(OsrmRouting.Point origin, RecommendationRoutes routes, int maxVisits) {
        this.origin = origin;
        this.routes = routes;
        this.maxVisits = maxVisits;
    }

    Day fit(LocalDate date, List<Stop> sequence) {
        var visits = new ArrayList<Visit>();
        var previous = origin;
        int current = 510;
        int travel = 0;
        int sightseeing = 0;
        int nextMeal = 0;
        for (var stop : sequence) {
            if (!stop.meal() && ++sightseeing > maxVisits) return null;
            var leg = routes.leg(previous, stop.point());
            int minutes = leg == null ? UNKNOWN_TRAVEL_ALLOWANCE : ItineraryCalculation.travelMinutes(leg.seconds());
            var periods = hours(stop.hours(), date);
            boolean unknown = periods == null;
            if (unknown) periods = List.of(new Window(0, 1440));
            int arrival = current + minutes + (visits.isEmpty() ? 0 : BUFFER);
            int start = -1;
            if (stop.meal()) {
                for (int meal = nextMeal; meal < 2; meal++) {
                    var slot = meal == 0 ? new Window(690, 840) : new Window(1050, 1260);
                    start = start(periods, slot, arrival, stop.duration());
                    if (start >= 0) {
                        nextMeal = meal + 1;
                        break;
                    }
                }
            } else {
                var slot = "NIGHTLIFE".equals(stop.code()) ? new Window(1020, 1560) : new Window(510, 1320);
                start = start(periods, slot, arrival, stop.duration());
            }
            if (start < 0) return null;
            visits.add(new Visit(stop, start, unknown, leg));
            current = start + stop.duration();
            travel += minutes;
            previous = stop.point();
        }
        return new Day(List.copyOf(visits), travel);
    }

    boolean enrich(List<Day> days) {
        boolean changed = false;
        for (var day : days) {
            var previous = origin;
            for (var visit : day.visits()) {
                var next = visit.stop().point();
                changed |= routes.enrich(previous, next);
                previous = next;
            }
        }
        return changed;
    }

    private static int start(List<Window> periods, Window allowed, int arrival, int duration) {
        for (var period : periods) {
            var window = allowed.intersect(period);
            int start = Math.max(arrival, window.start());
            if (start < 1440 && window.encloses(start * 60L, (start + (long) duration) * 60)) return start;
        }
        return -1;
    }

    static List<Window> hours(JsonNode schedule, LocalDate date) {
        if (schedule == null) return null;
        var week = schedule.path("week");
        var today = week.path(Integer.toString(date.getDayOfWeek().getValue()));
        if (!today.isArray()) return null;
        var tomorrow = week.path(Integer.toString(date.plusDays(1).getDayOfWeek().getValue()));
        var periods = new ArrayList<Window>();
        for (var period : today) {
            int end = period.get(1).asInt();
            if (end == 1440 && tomorrow.isArray() && !tomorrow.isEmpty() && tomorrow.get(0).get(0).asInt() == 0) {
                end += tomorrow.get(0).get(1).asInt();
            }
            periods.add(new Window(period.get(0).asInt(), end));
        }
        return periods;
    }

    static JsonNode readHours(Destination destination) {
        return OpeningHours.tree(destination.getOpeningHours());
    }
}
