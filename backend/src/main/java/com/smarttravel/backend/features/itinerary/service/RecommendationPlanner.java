package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.features.category.service.CatalogPolicy;
import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

import static com.smarttravel.backend.features.itinerary.service.RecommendationSchedule.*;

@Component
final class RecommendationPlanner {
    private final OsrmRouting routing;

    RecommendationPlanner(OsrmRouting routing) {
        this.routing = routing;
    }

    void plan(Itinerary trip, List<Destination> catalog, List<Destination> required,
              List<Destination> favorites, Set<Long> excluded, List<String> preferred) {
        var requiredIds = ids(required);
        var favoriteIds = ids(favorites);
        var destinations = new LinkedHashMap<Long, Destination>();
        for (var group : List.of(catalog, favorites, required)) {
            for (var destination : group) destinations.put(destination.getId(), destination);
        }
        var candidates = destinations.values().stream()
                .filter(d -> "ACTIVE".equals(d.getStatus()) && CatalogPolicy.available(d.getCategory()))
                .filter(d -> !excluded.contains(d.getId()))
                .map(d -> stop(d, requiredIds.contains(d.getId()), favoriteIds.contains(d.getId()), preferred))
                .filter(s -> s.required() || s.favorite() || s.preferred() || s.meal() || preferred.isEmpty())
                .sorted(Comparator.comparingInt(Stop::rank).reversed().thenComparingLong(Stop::id))
                .toList();
        int minimum = switch (trip.getPace()) {
            case "relaxed" -> 2;
            case "packed" -> 4;
            default -> 3;
        };
        var schedule = new RecommendationSchedule(coordinate(trip.getOriginLatitude(), trip.getOriginLongitude()),
                new RecommendationRoutes(routing, trip.getTransport()), minimum + 1);
        var search = new Search(trip, schedule, candidates);
        var result = search.solve();
        for (int pass = 0; pass < 2 && schedule.enrich(result.days); pass++) {
            result = search.solve();
        }
        RecommendationOutput.publish(trip, candidates, result, minimum, schedule);
    }

    private static Stop stop(Destination d, boolean required, boolean favorite, List<String> preferred) {
        var code = d.getCategory().getCode();
        boolean liked = preferred.contains(code);
        int popularity = d.getReviewCount() == null ? 0 : Math.min(35, (int) (4 * Math.log1p(d.getReviewCount())));
        int quality = d.getRating() == null ? 0 : (int) Math.round(d.getRating().doubleValue() * 3);
        var unit = d.getPriceMaxVnd() == null ? d.getPriceMinVnd() : d.getPriceMaxVnd();
        int cost = unit == null ? 40 : (int) Math.min(25, unit / 20_000);
        if (unit != null && d.getPriceMaxVnd() == null) cost += 15;
        int rank = 100 + (liked ? 55 : 0) + (favorite ? 85 : 0) + popularity + quality - cost;
        return new Stop(d, code, ItineraryCalculation.duration(d), unit, readHours(d), required, favorite, liked, rank);
    }

    private static Set<Long> ids(List<Destination> destinations) {
        return destinations.stream().map(Destination::getId).collect(Collectors.toSet());
    }

    private record Placement(int day, Day schedule, long gain, Stop stop) {}

    private static final class Search {
        private final Itinerary trip;
        private final RecommendationSchedule schedule;
        private final List<Stop> candidates;

        Search(Itinerary trip, RecommendationSchedule schedule, List<Stop> candidates) {
            this.trip = trip;
            this.schedule = schedule;
            this.candidates = candidates;
        }

        Plan solve() {
            var plan = new Plan(trip.getTotalDays());
            var mandatory = candidates.stream().filter(Stop::required)
                    .sorted(Comparator.comparingInt(this::availableDays).thenComparingLong(Stop::id)).toList();
            for (var stop : mandatory) add(plan, best(plan, List.of(stop)));
            if (trip.getTotalDays() == 1) {
                plan.featured = plan.days.getFirst().visits().stream().map(Visit::stop).filter(this::featured)
                        .map(Stop::id).findFirst().orElse(null);
                if (plan.featured == null) {
                    var choice = best(plan, candidates.stream().filter(this::featured).toList());
                    if (choice != null) {
                        add(plan, choice);
                        plan.featured = choice.stop().id();
                    }
                }
            }
            Placement choice;
            var optional = candidates.stream().filter(stop -> !stop.required()).toList();
            while ((choice = best(plan, optional)) != null) add(plan, choice);
            improve(plan);
            rebalance(plan);
            replaceExpensiveStops(plan, optional);
            for (var stop : mandatory) add(plan, best(plan, List.of(stop)));
            while ((choice = best(plan, optional)) != null) add(plan, choice);
            return plan;
        }

        private int availableDays(Stop stop) {
            int count = 0;
            for (int i = 0; i < trip.getTotalDays(); i++) if (fit(i, List.of(stop)) != null) count++;
            return count;
        }

        private boolean featured(Stop stop) {
            return stop.featured() && (stop.preferred() || trip.getPreferredCategoriesSnapshot().isEmpty());
        }

        private Placement best(Plan plan, List<Stop> stops) {
            Placement best = null;
            for (var stop : stops) {
                if (plan.used.contains(stop.id()) || !affordable(plan, stop)) continue;
                for (int day = 0; day < plan.days.size(); day++) {
                    var old = plan.days.get(day);
                    var sequence = old.stops();
                    for (int position = sequence.size(); position >= 0; position--) {
                        var next = new ArrayList<>(sequence);
                        next.add(position, stop);
                        var candidate = fit(day, next);
                        if (candidate == null) continue;
                        long gain = stop.rank() - 2L * (candidate.travelMinutes() - old.travelMinutes())
                                - 16L * (stop.meal() ? sequence.size() - old.sightseeing() : old.sightseeing());
                        if (best == null || gain > best.gain()) best = new Placement(day, candidate, gain, stop);
                    }
                }
            }
            return best;
        }

        private Day fit(int day, List<Stop> sequence) {
            return schedule.fit(trip.getStartDate().plusDays(day), sequence);
        }

        private boolean affordable(Plan plan, Stop stop) {
            return stop.unitPrice() == null || stop.unitPrice() <=
                    (trip.getMaxBudgetVnd() - plan.cost) / trip.getTravelersCount();
        }

        private void add(Plan plan, Placement placement) {
            if (placement == null) return;
            var stop = placement.stop();
            plan.days.set(placement.day(), placement.schedule());
            plan.used.add(stop.id());
            if (stop.unitPrice() != null) plan.cost += stop.unitPrice() * trip.getTravelersCount();
        }

        private void improve(Plan plan) {
            for (int day = 0; day < plan.days.size(); day++) {
                var bestDay = plan.days.get(day);
                var base = bestDay.stops();
                for (int i = 0; i < base.size(); i++) {
                    for (int j = i + 1; j < base.size(); j++) {
                        var reordered = new ArrayList<>(base);
                        Collections.swap(reordered, i, j);
                        var candidate = fit(day, reordered);
                        if (candidate != null && candidate.travelMinutes() < bestDay.travelMinutes()) bestDay = candidate;
                    }
                }
                plan.days.set(day, bestDay);
            }
        }

        private void rebalance(Plan plan) {
            if (plan.days.size() < 2) return;
            for (int first = 0; first < plan.days.size() - 1; first++) {
                for (int second = first + 1; second < plan.days.size(); second++) {
                    var a = plan.days.get(first);
                    var b = plan.days.get(second);
                    var aStops = a.stops();
                    var bStops = b.stops();
                    for (int i = 0; i < aStops.size(); i++) {
                        for (int j = 0; j < bStops.size(); j++) {
                            if (aStops.get(i).meal() != bStops.get(j).meal()) continue;
                            var left = new ArrayList<>(aStops);
                            var right = new ArrayList<>(bStops);
                            left.set(i, bStops.get(j));
                            right.set(j, aStops.get(i));
                            var leftDay = fit(first, left);
                            var rightDay = fit(second, right);
                            if (leftDay == null || rightDay == null) continue;
                            if (leftDay.travelMinutes() + rightDay.travelMinutes() < a.travelMinutes() + b.travelMinutes()) {
                                a = leftDay;
                                b = rightDay;
                            }
                        }
                    }
                    plan.days.set(first, a);
                    plan.days.set(second, b);
                }
            }
        }

        private void replaceExpensiveStops(Plan plan, List<Stop> optional) {
            for (int day = 0; day < plan.days.size(); day++) {
                for (int index = 0; index < plan.days.get(day).visits().size(); index++) {
                    var before = plan.days.get(day);
                    var old = before.visits().get(index).stop();
                    if (old.required() || old.favorite() || Objects.equals(plan.featured, old.id())
                            || old.unitPrice() == null || old.unitPrice() == 0) continue;
                    var replacement = old;
                    var selected = before;
                    long bestGain = 0;
                    for (var candidate : optional) {
                        if (plan.used.contains(candidate.id()) || candidate.meal() != old.meal()
                                || candidate.unitPrice() == null || candidate.unitPrice() >= old.unitPrice()
                                || candidate.destination().getPriceMaxVnd() == null) continue;
                        var sequence = new ArrayList<>(before.stops());
                        sequence.set(index, candidate);
                        var after = fit(day, sequence);
                        if (after == null) continue;
                        long gain = candidate.rank() - old.rank() + 2L * (before.travelMinutes() - after.travelMinutes())
                                + Math.min(20, (old.unitPrice() - candidate.unitPrice()) / 10_000);
                        if (gain > bestGain) {
                            bestGain = gain;
                            replacement = candidate;
                            selected = after;
                        }
                    }
                    if (replacement == old) continue;
                    plan.days.set(day, selected);
                    plan.used.remove(old.id());
                    plan.used.add(replacement.id());
                    plan.cost -= (old.unitPrice() - replacement.unitPrice()) * trip.getTravelersCount();
                }
            }
        }
    }

    static final class Plan {
        private final List<Day> days;
        private final Set<Long> used = new HashSet<>();
        private Long featured;
        private long cost;

        List<Day> days() { return days; }
        Set<Long> used() { return used; }
        Long featured() { return featured; }
        long cost() { return cost; }

        Plan(int size) {
            days = new ArrayList<>(Collections.nCopies(size, new Day(List.of(), 0)));
        }
    }
}
