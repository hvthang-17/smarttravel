package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.common.CurrentUser;
import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.domain.ItineraryConstraint;
import com.smarttravel.backend.features.itinerary.domain.ItineraryDay;
import com.smarttravel.backend.features.itinerary.domain.ItineraryItem;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;
import com.smarttravel.backend.features.itinerary.repository.ItineraryConstraintRepository;
import com.smarttravel.backend.features.itinerary.repository.ItineraryRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
public class TripManagement {
    public record TripPage(List<ItineraryResponseDto> items, int page, boolean hasNext, long total) {}
    public enum Period { ALL, UPCOMING, HISTORY }
    private final ItineraryRepository trips;
    private final ItineraryConstraintRepository constraints;
    private final UserRepository users;
    private final ItineraryService itineraries;

    public TripManagement(ItineraryRepository trips, ItineraryConstraintRepository constraints,
                          UserRepository users, ItineraryService itineraries) {
        this.trips = trips;
        this.constraints = constraints;
        this.users = users;
        this.itineraries = itineraries;
    }

    @Transactional(readOnly = true)
    public TripPage page(String search, Period period, int page, int size) {
        if (page < 0 || page > 100_000 || size < 1 || size > 50 || search.length() > 255) {
            throw new IllegalArgumentException("Tham số tìm kiếm hoặc phân trang không hợp lệ");
        }
        var user = users.findByEmail(CurrentUser.email())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản"));
        CurrentUser.requireCurrentAccount(user);
        var normalized = search.strip().toLowerCase(Locale.ROOT);
        var pattern = normalized.isEmpty() ? "" : "%" + normalized.replace("!", "!!").replace("%", "!%")
                .replace("_", "!_") + "%";
        var today = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        var result = trips.findSavedPage(user.getId(), pattern, period.name(), today, PageRequest.of(page, size));
        return new TripPage(result.stream().map(trip -> {
            var dto = itineraries.toPrivateDto(trip);
            dto.setPeriod(trip.getEndDate().isBefore(today) ? "HISTORY" : "UPCOMING");
            return dto;
        }).toList(), page, result.hasNext(), result.getTotalElements());
    }

    @Transactional
    public ItineraryResponseDto rename(long id, String title) {
        var trip = lockOwned(trips, id);
        trip.setTitle(title.strip());
        trip.setUpdatedAt(Instant.now());
        return itineraries.toPrivateDto(trips.saveAndFlush(trip));
    }

    @Transactional
    public void delete(long id) {
        trips.delete(lockOwned(trips, id));
    }

    @Transactional
    public ItineraryResponseDto duplicate(long id) {
        var original = lockOwned(trips, id);
        var copy = trips.saveAndFlush(copyTrip(original));
        var copiedRules = constraints.findByItineraryIdOrderByConstraintTypeAscDestinationIdAsc(id).stream().map(rule -> {
            var copied = new ItineraryConstraint();
            copied.setItineraryId(copy.getId());
            copied.setDestinationId(rule.getDestinationId());
            copied.setConstraintType(rule.getConstraintType());
            copied.setDestinationSnapshot(rule.getDestinationSnapshot());
            return copied;
        }).toList();
        constraints.saveAllAndFlush(copiedRules);
        return itineraries.toPrivateDto(copy);
    }

    static Itinerary lockOwned(ItineraryRepository trips, long id) {
        var trip = trips.lockById(id).orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lịch trình"));
        ItineraryService.requireOwner(trip, CurrentUser.email());
        return trip;
    }

    private static Itinerary copyTrip(Itinerary source) {
        var copy = new Itinerary();
        copy.setUser(source.getUser());
        var title = source.getTitle();
        int length = Math.min(title.codePointCount(0, title.length()), 230);
        copy.setTitle(title.substring(0, title.offsetByCodePoints(0, length)) + " (bản sao)");
        copy.setStartDate(source.getStartDate());
        copy.setEndDate(source.getEndDate());
        copy.setTotalDays(source.getTotalDays());
        copy.setTravelersCount(source.getTravelersCount());
        copy.setMaxBudgetVnd(source.getMaxBudgetVnd());
        copy.setPace(source.getPace());
        copy.setTransport(source.getTransport());
        copy.setOriginName(source.getOriginName());
        copy.setOriginLatitude(source.getOriginLatitude());
        copy.setOriginLongitude(source.getOriginLongitude());
        if (source.getPreferredCategoriesSnapshot() != null) {
            copy.setPreferredCategoriesSnapshot(new ArrayList<>(source.getPreferredCategoriesSnapshot()));
        }
        copy.setGenerationStatus(source.getGenerationStatus());
        if (source.getWarnings() != null) copy.setWarnings(new ArrayList<>(source.getWarnings()));
        copy.setTotalEstimatedCost(source.getTotalEstimatedCost());
        copy.setCostComplete(source.getCostComplete());
        for (var original : source.getDays()) {
            var day = new ItineraryDay();
            day.setItinerary(copy);
            day.setDayNumber(original.getDayNumber());
            day.setDate(original.getDate());
            day.setOriginName(original.getOriginName());
            day.setOriginLatitude(original.getOriginLatitude());
            day.setOriginLongitude(original.getOriginLongitude());
            for (var item : original.getItems()) day.getItems().add(copyActivity(item, day));
            copy.getDays().add(day);
        }
        return copy;
    }

    private static ItineraryItem copyActivity(ItineraryItem original, ItineraryDay day) {
        var item = new ItineraryItem();
        item.setDay(day);
        item.setDestination(original.getDestination());
        item.setDestinationName(original.getDestinationName());
        item.setLatitude(original.getLatitude());
        item.setLongitude(original.getLongitude());
        item.setCategoryCode(original.getCategoryCode());
        item.setSequenceOrder(original.getSequenceOrder());
        item.setStartTime(original.getStartTime());
        item.setDurationMinutes(original.getDurationMinutes());
        item.setUnitPriceVnd(original.getUnitPriceVnd());
        item.setUpperPriceKnown(original.isUpperPriceKnown());
        item.setEstimatedCostVnd(original.getEstimatedCostVnd());
        item.setNotes(original.getNotes());
        item.setRecommendationReason(original.getRecommendationReason());
        item.setFeaturedRecommendation(original.isFeaturedRecommendation());
        item.setTravelDistanceM(original.getTravelDistanceM());
        item.setTravelDurationSeconds(original.getTravelDurationSeconds());
        item.setRouteSource(original.getRouteSource());
        item.setRoutePolyline(original.getRoutePolyline());
        return item;
    }
}
