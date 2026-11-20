package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.itinerary.domain.*;
import java.math.BigDecimal;
import java.util.*;
import org.springframework.stereotype.Component;

@Component
public final class ItineraryCalculation {
    private final OsrmRouting routing;

    ItineraryCalculation(OsrmRouting routing) {
        this.routing = routing;
    }

    public static int duration(Destination destination) {
        return destination.suggestedVisitDurationMinutes();
    }

    public static void snapshot(ItineraryItem item, Destination destination) {
        item.setDestination(destination);
        item.setDestinationName(destination.getName());
        item.setLatitude(destination.getLatitude());
        item.setLongitude(destination.getLongitude());
        item.setCategoryCode(destination.getCategory().getCode());
        item.setUnitPriceVnd(destination.getPriceMaxVnd() != null ? destination.getPriceMaxVnd() : destination.getPriceMinVnd());
        item.setUpperPriceKnown(destination.getPriceMaxVnd() != null);
    }

    public void recalculate(Itinerary itinerary) {
        recalculate(itinerary, null);
    }

    void recalculate(Itinerary itinerary, Set<Long> routeDays) {
        long total = 0;
        boolean complete = true;
        long deadline = System.nanoTime() + java.time.Duration.ofSeconds(3).toNanos();
        for (ItineraryDay day : itinerary.getDays()) {
            boolean hasDayOrigin = day.getOriginLatitude() != null && day.getOriginLongitude() != null;
            BigDecimal previousLat = hasDayOrigin ? day.getOriginLatitude() : itinerary.getOriginLatitude();
            BigDecimal previousLon = hasDayOrigin ? day.getOriginLongitude() : itinerary.getOriginLongitude();
            List<ItineraryItem> items = day.getItems().stream().sorted(Comparator.comparing(ItineraryItem::getSequenceOrder)).toList();
            for (ItineraryItem item : items) {
                Long cost = groupCost(item.getUnitPriceVnd(), itinerary.getTravelersCount());
                item.setEstimatedCostVnd(cost);
                if (cost == null || !item.isUpperPriceKnown()) complete = false;
                if (cost != null) {
                    if (Long.MAX_VALUE - total < cost) throw new IllegalArgumentException("Tổng chi phí vượt giới hạn");
                    total += cost;
                }
                if (routeDays == null || routeDays.contains(day.getId())) {
                    var from = RecommendationSchedule.coordinate(previousLat, previousLon);
                    var to = RecommendationSchedule.coordinate(item.getLatitude(), item.getLongitude());
                    applyLeg(item, resolveLeg(routing, from, to, itinerary.getTransport(), System.nanoTime() < deadline));
                }
                previousLat = item.getLatitude();
                previousLon = item.getLongitude();
            }
        }
        itinerary.setTotalEstimatedCost(total);
        itinerary.setCostComplete(complete);
    }

    static Long groupCost(Long unitPrice, int travelers) {
        if (unitPrice == null) return null;
        if (unitPrice > Long.MAX_VALUE / travelers) throw new IllegalArgumentException("Chi phí nhóm vượt giới hạn");
        return unitPrice * travelers;
    }

    static void applyLeg(ItineraryItem item, OsrmRouting.Leg leg) {
        item.setRouteSource(leg == null ? "UNKNOWN" : leg.source());
        item.setRoutePolyline(leg == null ? null : leg.geometry());
        item.setTravelDistanceM(leg == null ? null : leg.meters());
        item.setTravelDurationSeconds(leg == null ? null : leg.seconds());
    }

    static OsrmRouting.Leg resolveLeg(OsrmRouting routing, OsrmRouting.Point from, OsrmRouting.Point to,
                                      String transport, boolean allowNetwork) {
        if (from == null || to == null) return null;
        var result = routing.directions(from, to, transport, allowNetwork);
        return result == null ? estimate(from, to, transport) : result;
    }

    static int travelMinutes(int seconds) {
        return (int) ((seconds + 59L) / 60);
    }

    static OsrmRouting.Leg estimate(OsrmRouting.Point from, OsrmRouting.Point to, String transport) {
        double km = distance(from.lat(), from.lon(), to.lat(), to.lon());
        double minutesPerKm = switch (transport) {
            case "walking" -> 12.0;
            case "motorbike" -> 2.5;
            default -> 2.2;
        };
        return new OsrmRouting.Leg((int) Math.round(km * 1000),
                (int) Math.round(km * minutesPerKm * 60), null, "HAVERSINE");
    }

    private static double distance(BigDecimal a, BigDecimal b, BigDecimal c, BigDecimal d) {
        double lat = Math.toRadians(c.doubleValue() - a.doubleValue());
        double lon = Math.toRadians(d.doubleValue() - b.doubleValue());
        double value = Math.sin(lat / 2) * Math.sin(lat / 2)
                + Math.cos(Math.toRadians(a.doubleValue())) * Math.cos(Math.toRadians(c.doubleValue()))
                * Math.sin(lon / 2) * Math.sin(lon / 2);
        return 6371 * 2 * Math.atan2(Math.sqrt(value), Math.sqrt(Math.max(0, 1 - value)));
    }
}
