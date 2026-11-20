package com.smarttravel.backend.features.itinerary.service;

import java.time.Duration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

final class RecommendationRoutes {
    private record Pair(OsrmRouting.Point from, OsrmRouting.Point to) {}

    private final OsrmRouting routing;
    private final String transport;
    private final Map<Pair, OsrmRouting.Leg> legs = new HashMap<>();
    private final Set<Pair> attempted = new HashSet<>();
    private final long deadline = System.nanoTime() + Duration.ofSeconds(3).toNanos();

    RecommendationRoutes(OsrmRouting routing, String transport) {
        this.routing = routing;
        this.transport = transport;
    }

    OsrmRouting.Leg leg(OsrmRouting.Point from, OsrmRouting.Point to) {
        if (from == null || to == null) return null;
        return legs.computeIfAbsent(new Pair(from, to), key -> ItineraryCalculation.estimate(from, to, transport));
    }

    boolean enrich(OsrmRouting.Point from, OsrmRouting.Point to) {
        if (from == null || to == null || !attempted.add(new Pair(from, to))) return false;
        var real = ItineraryCalculation.resolveLeg(routing, from, to, transport, System.nanoTime() < deadline);
        if ("HAVERSINE".equals(real.source())) return false;
        legs.put(new Pair(from, to), real);
        return true;
    }
}
