package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.common.ResourceConflictException;
import com.smarttravel.backend.features.category.domain.Category;
import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.domain.ItineraryItem;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class RecommendationPlannerTest {
    private static final String OPEN = "[[0,1440]]";
    private final OsrmRouting routing = mock(OsrmRouting.class);
    private final RecommendationPlanner planner = new RecommendationPlanner(routing);

    @ParameterizedTest
    @CsvSource({"1,relaxed,3", "1,balanced,4", "1,packed,5",
            "2,relaxed,3", "2,balanced,4", "2,packed,5",
            "3,relaxed,3", "3,balanced,4", "3,packed,5",
            "7,relaxed,3", "7,balanced,4", "7,packed,5"})
    void paceAllocatesEachDayAndMealsDoNotCountAgainstSightseeing(int days, String pace, int cap) {
        var trip = trip(days, pace, 1_000_000L, "BEACH");
        var points = new ArrayList<>(IntStream.rangeClosed(1, days * cap)
                .mapToObj(id -> point(id, "BEACH", OPEN, 1000L, null)).toList());
        for (int i = 0; i < days * 2; i++) points.add(point(100 + i, "FOOD", OPEN, 1000L, null));
        plan(trip, points, List.of(), Set.of());
        assertThat(trip.getDays()).hasSize(days);
        assertThat(items(trip).stream().map(item -> item.getDestination().getId())).doesNotHaveDuplicates();
        for (var day : trip.getDays()) {
            assertThat(day.getItems().stream().filter(item -> item.getCategoryCode().equals("BEACH")).count()).isEqualTo(cap);
            assertThat(day.getItems().stream().filter(item -> item.getCategoryCode().equals("FOOD")).count()).isLessThanOrEqualTo(2);
            assertThat(day.getItems()).isSortedAccordingTo(Comparator.comparing(ItineraryItem::getStartTime));
        }
        assertThat(trip.getGenerationStatus()).isEqualTo("COMPLETE");
    }

    @ParameterizedTest
    @CsvSource({"BEACH,CAFE", "CAFE,BEACH", "CULTURE,CHECKIN", "CHECKIN,CULTURE"})
    void preferenceChangesSuggestionsOnSameCatalog(String preferred, String other) {
        var trip = trip(1, "relaxed", 100_000L, preferred);
        plan(trip, List.of(point(1, other, OPEN, 0L, null), point(2, preferred, OPEN, 0L, null)), List.of(), Set.of());
        assertThat(items(trip)).extracting(ItineraryItem::getCategoryCode).containsExactly(preferred);
    }

    @ParameterizedTest
    @CsvSource({"closed", "expensive", "excluded", "hidden"})
    void infeasibleTopFeaturedFallsBackToNextFeatured(String problem) {
        var trip = trip(1, "relaxed", 30_000L, "BEACH");
        var top = point(1, "BEACH", problem.equals("closed") ? "[]" : OPEN,
                problem.equals("expensive") ? 100_000L : 0L, "Điểm đầu");
        if (problem.equals("hidden")) top.setStatus("INACTIVE");
        top.setReviewCount(100_000);
        var next = point(2, "BEACH", OPEN, 0L, "Điểm thay thế tiêu biểu");
        plan(trip, List.of(top, next, point(3, "BEACH", OPEN, 0L, null)),
                List.of(), problem.equals("excluded") ? Set.of(1L) : Set.of());
        assertThat(items(trip).stream().filter(ItineraryItem::isFeaturedRecommendation))
                .extracting(ItineraryItem::getRecommendationReason).containsExactly("Điểm thay thế tiêu biểu");
    }

    @Test
    void picksAfternoonAndCanSpanMidnightOnlyWithContinuousHours() {
        var trip = trip(1, "relaxed", 100_000L, "CULTURE", "NIGHTLIFE");
        var museum = point(1, "CULTURE", "[[510,560],[810,1020]]", 0L, null);
        museum.setVisitDurationMinutes(90);
        var night = point(2, "NIGHTLIFE", "[[1410,1440]]", 0L, null);
        night.setOpeningHours(week("[[1410,1440]]").replace("\"2\":[[1410,1440]]", "\"2\":[[0,120]]"));
        plan(trip, List.of(museum, night), List.of(night), Set.of());
        assertThat(items(trip)).extracting(ItineraryItem::getStartTime).containsExactly(LocalTime.of(13, 30), LocalTime.of(23, 30));
    }

    @Test
    void onlyMinimumAndUnknownPriceKeepCostsIncompleteAndProtectBudget() {
        var trip = trip(1, "packed", 30_000L, "BEACH");
        var minimum = point(1, "BEACH", "null", null, null);
        minimum.setPriceMinVnd(15_000L);
        var unknown = point(2, "BEACH", OPEN, null, null);
        var tooExpensive = point(3, "BEACH", OPEN, 20_000L, null);
        plan(trip, List.of(minimum, unknown, tooExpensive), List.of(), Set.of());
        assertThat(items(trip)).extracting(ItineraryItem::getDestination).containsExactlyInAnyOrder(minimum, unknown);
        assertThat(trip.getTotalEstimatedCost()).isEqualTo(30_000L);
        assertThat(trip.getCostComplete()).isFalse();
        assertThat(trip.getWarnings()).anyMatch(warning -> warning.contains("giá tối thiểu"))
                .anyMatch(warning -> warning.contains("chưa rõ giờ"));
    }

    @Test
    void marksMissingRequiredAndNeverSavesEmptyPlanAsComplete() {
        var closed = point(1, "CULTURE", "[]", 0L, null);
        var open = point(2, "BEACH", OPEN, 0L, null);
        var trip = trip(1, "relaxed", 1L, "BEACH");
        plan(trip, List.of(open), List.of(closed), Set.of());
        assertThat(trip.getGenerationStatus()).isEqualTo("PARTIAL");
        assertThat(trip.getWarnings()).anyMatch(warning -> warning.contains("Điểm 1"));
        assertThatThrownBy(() -> plan(trip, List.of(), List.of(closed), Set.of()))
                .isInstanceOf(ResourceConflictException.class).hasMessageContaining("Điểm 1");
    }

    @Test
    void providerTimeCanRejectInitialEstimateAndUnavailableRouteWarns() {
        var trip = trip(1, "relaxed", 100_000L, "BEACH");
        trip.setOriginLatitude(new BigDecimal("16.05"));
        trip.setOriginLongitude(new BigDecimal("108.20"));
        var narrow = point(1, "BEACH", "[[510,560]]", 0L, "Điểm đầu");
        narrow.setLongitude(new BigDecimal("108.201"));
        var flexible = point(2, "BEACH", OPEN, 0L, null);
        when(routing.directions(any(), argThat(point -> point.lon().compareTo(narrow.getLongitude()) == 0),
                eq("taxi"), anyBoolean())).thenReturn(new OsrmRouting.Leg(9000, 3600, "[[108.20,16.05],[108.201,16.05]]", "PROVIDER"));
        plan(trip, List.of(narrow, flexible), List.of(), Set.of());
        assertThat(items(trip)).extracting(ItineraryItem::getDestination).containsExactly(flexible);
        assertThat(items(trip).getFirst().getRouteSource()).isEqualTo("HAVERSINE");
        assertThat(trip.getWarnings()).anyMatch(warning -> warning.contains("ước tính"));
    }

    private void plan(Itinerary trip, List<Destination> candidates, List<Destination> required, Set<Long> excluded) {
        planner.plan(trip, candidates, required, List.of(), excluded, trip.getPreferredCategoriesSnapshot());
    }

    private static List<ItineraryItem> items(Itinerary trip) {
        return trip.getDays().stream().flatMap(day -> day.getItems().stream()).toList();
    }

    private static Itinerary trip(int days, String pace, long budget, String... categories) {
        var trip = new Itinerary();
        trip.setStartDate(LocalDate.of(2026, 11, 16));
        trip.setTotalDays(days);
        trip.setTravelersCount(2);
        trip.setMaxBudgetVnd(budget);
        trip.setTransport("taxi");
        trip.setPace(pace);
        trip.setPreferredCategoriesSnapshot(List.of(categories));
        return trip;
    }

    private static Destination point(long id, String code, String hours, Long price, String featured) {
        var category = new Category();
        category.setCode(code);
        category.setName(code);
        category.setStatus("ACTIVE");
        var destination = new Destination();
        destination.setId(id);
        destination.setName("Điểm " + id);
        destination.setStatus("ACTIVE");
        destination.setCategory(category);
        destination.setLatitude(new BigDecimal("16.05"));
        destination.setLongitude(new BigDecimal("108.20"));
        destination.setVisitDurationMinutes(45);
        destination.setOpeningHours(week(hours));
        destination.setPriceMaxVnd(price);
        destination.setFeaturedReason(featured);
        return destination;
    }

    private static String week(String hours) {
        return "{\"week\":{" + String.join(",", IntStream.rangeClosed(1, 7)
                .mapToObj(day -> "\"" + day + "\":" + hours).toList()) + "}}";
    }
}
