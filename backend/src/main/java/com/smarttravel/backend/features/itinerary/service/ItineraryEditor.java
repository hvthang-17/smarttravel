package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.features.category.service.CatalogPolicy;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.domain.ItineraryDay;
import com.smarttravel.backend.features.itinerary.domain.ItineraryItem;
import com.smarttravel.backend.features.itinerary.dto.UpdateActivitiesRequest;
import org.springframework.orm.ObjectOptimisticLockingFailureException;

import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.*;

final class ItineraryEditor {
    private ItineraryEditor() {}

    private record Stop(Long id, String latitude, String longitude) {}
    private record Edit(ItineraryItem item, int sequence) {}

    static Set<Long> apply(Itinerary itinerary, UpdateActivitiesRequest request,
                           DestinationRepository destinations, Runnable flush) {
        if (request.getVersion() == null) throw new IllegalArgumentException("Thiếu version lịch trình");
        if (!request.getVersion().equals(itinerary.getVersion())) {
            throw new ObjectOptimisticLockingFailureException(Itinerary.class, itinerary.getId());
        }
        var editedDays = new HashSet<Long>();
        var routeDays = new HashSet<Long>();
        for (var update : request.getDays()) {
            var day = itinerary.getDays().stream().filter(d -> update.getDayId() != null
                            ? update.getDayId().equals(d.getId()) : Objects.equals(update.getDayNumber(), d.getDayNumber()))
                    .findFirst().orElseThrow(() -> new IllegalArgumentException("Ngày không thuộc lịch trình"));
            if (!editedDays.add(day.getId())) throw new IllegalArgumentException("Ngày bị gửi trùng");
            if (update.getDayNumber() != null && !update.getDayNumber().equals(day.getDayNumber())) {
                throw new IllegalArgumentException("ID và số ngày không khớp");
            }
            var before = path(day);
            applyDay(day, update, destinations, flush);
            if (update.isRecalculateRoute() || !before.equals(path(day))) routeDays.add(day.getId());
        }
        return routeDays;
    }

    private static void applyDay(ItineraryDay day, UpdateActivitiesRequest.DayUpdateDto update,
                                 DestinationRepository destinations, Runnable flush) {
        var old = new HashMap<Long, ItineraryItem>();
        var occupied = new HashSet<Integer>();
        for (var item : day.getItems()) {
            old.put(item.getId(), item);
            occupied.add(item.getSequenceOrder());
        }
        var desired = new HashSet<Integer>();
        var edits = new ArrayList<Edit>();
        for (var input : update.getItems()) {
            if (!desired.add(input.getSequenceOrder())) throw new IllegalArgumentException("Thứ tự hoạt động bị trùng");
            ItineraryItem item;
            if (input.getId() == null) {
                item = new ItineraryItem();
                item.setDay(day);
            } else {
                item = old.remove(input.getId());
                if (item == null) throw new IllegalArgumentException("Hoạt động không thuộc ngày hoặc bị gửi trùng");
            }
            applyItem(item, input, destinations);
            edits.add(new Edit(item, input.getSequenceOrder()));
        }
        if (!old.isEmpty()) day.getItems().removeAll(old.values());
        int temporary = 101;
        boolean needsFlush = !old.isEmpty();
        for (var edit : edits) {
            var item = edit.item();
            if (item.getId() == null || item.getSequenceOrder() == edit.sequence()) continue;
            while (occupied.contains(temporary)) temporary++;
            item.setSequenceOrder(temporary++);
            needsFlush = true;
        }
        if (needsFlush) flush.run();
        for (var edit : edits) {
            var item = edit.item();
            item.setSequenceOrder(edit.sequence());
            if (item.getId() == null) day.getItems().add(item);
        }
    }

    private static void applyItem(ItineraryItem item, UpdateActivitiesRequest.ItemUpdateDto input,
                                  DestinationRepository destinations) {
        var previous = item.getDestination() == null ? null : item.getDestination().getId();
        boolean replace = item.getId() == null || (input.hasDestination() && !Objects.equals(previous, input.getDestinationId()));
        if (replace) {
            if (input.getDestinationId() == null) throw new IllegalArgumentException("Hoạt động mới hoặc thay thế cần địa điểm");
            var destination = destinations.lockForPublicSelection(input.getDestinationId())
                    .filter(d -> "ACTIVE".equals(d.getStatus()) && CatalogPolicy.available(d.getCategory()))
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy địa điểm khả dụng"));
            ItineraryCalculation.snapshot(item, destination);
            item.setDurationMinutes(ItineraryCalculation.duration(destination));
            item.setFeaturedRecommendation(false);
            item.setRecommendationReason(null);
        }
        if (input.getDurationMinutes() != null || (!replace && input.hasDuration())) {
            item.setDurationMinutes(input.getDurationMinutes());
        }
        if (input.hasNotes()) item.setNotes(input.getNotes());
        if (input.hasStartTime()) {
            try {
                item.setStartTime(input.getStartTime() == null ? null : LocalTime.parse(input.getStartTime()));
            } catch (DateTimeParseException ex) {
                throw new IllegalArgumentException("Giờ bắt đầu không hợp lệ");
            }
        }
    }

    private static List<Stop> path(ItineraryDay day) {
        return day.getItems().stream().sorted(Comparator.comparing(ItineraryItem::getSequenceOrder))
                .map(item -> new Stop(item.getId(), normalized(item.getLatitude()), normalized(item.getLongitude())))
                .toList();
    }

    private static String normalized(java.math.BigDecimal coordinate) {
        return coordinate == null ? null : coordinate.stripTrailingZeros().toPlainString();
    }
}
