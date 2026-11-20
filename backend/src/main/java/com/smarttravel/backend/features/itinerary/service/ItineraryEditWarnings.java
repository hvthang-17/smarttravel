package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.domain.ItineraryItem;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

final class ItineraryEditWarnings {
    private ItineraryEditWarnings() {}

    static void refresh(Itinerary trip, List<ItineraryResponseDto.ConstraintDto> constraints) {
        var warnings = new LinkedHashSet<String>();
        var present = TripConstraints.activityIds(trip);
        boolean partial = false;
        for (var rule : constraints) {
            if (!"REQUIRED".equals(rule.type()) || present.contains(rule.destinationId())) continue;
            var name = rule.snapshot() == null ? "địa điểm " + rule.destinationId() : rule.snapshot().name();
            warnings.add("Chưa xếp điểm bắt buộc: " + name + ". Hãy chọn giờ phù hợp hoặc đổi ngày.");
            partial = true;
        }
        if (trip.getTotalEstimatedCost() > trip.getMaxBudgetVnd()) warnings.add("Chi phí đã biết vượt ngân sách nhóm.");
        LocalDateTime latestEnd = null;
        for (var day : trip.getDays()) {
            if (day.getItems().isEmpty()) {
                warnings.add("Ngày " + day.getDayNumber() + " chưa có hoạt động.");
                partial = true;
            }
            LocalDateTime previousEnd = null;
            for (var item : day.getItems().stream().sorted(Comparator.comparing(ItineraryItem::getSequenceOrder)).toList()) {
                var label = "Ngày " + day.getDayNumber() + " · " + item.getDestinationName();
                checkData(item, label, warnings);
                if (item.getStartTime() == null || item.getDurationMinutes() == null) {
                    warnings.add(label + " chưa đủ giờ bắt đầu hoặc thời lượng để kiểm tra lịch.");
                    previousEnd = null;
                    continue;
                }
                var start = day.getDate().atTime(item.getStartTime());
                if (latestEnd != null && start.isBefore(latestEnd)) {
                    warnings.add(label + " chồng giờ hoặc đứng sai thứ tự thời gian với hoạt động trước.");
                } else if (previousEnd != null && item.getTravelDurationSeconds() != null
                        && start.isBefore(previousEnd.plusMinutes(RecommendationSchedule.BUFFER
                            + ItineraryCalculation.travelMinutes(item.getTravelDurationSeconds())))) {
                    warnings.add(label + " không đủ thời gian di chuyển và đệm từ hoạt động trước.");
                }
                previousEnd = start.plusMinutes(item.getDurationMinutes());
                if (latestEnd == null || previousEnd.isAfter(latestEnd)) latestEnd = previousEnd;
                checkOpening(item, day.getDate(), label, warnings);
            }
        }
        trip.setWarnings(List.copyOf(warnings));
        trip.setGenerationStatus(partial ? "PARTIAL" : "COMPLETE");
    }

    private static void checkData(ItineraryItem item, String label, Set<String> warnings) {
        if (item.getUnitPriceVnd() == null) warnings.add(label + " chưa có giá tham khảo.");
        else if (!item.isUpperPriceKnown()) warnings.add(label + " chỉ tính giá tối thiểu.");
        if ("UNKNOWN".equals(item.getRouteSource())) warnings.add("Một số chặng chưa rõ thời gian đi.");
        if ("HAVERSINE".equals(item.getRouteSource())) warnings.add("Một số chặng dùng thời gian đi ước tính.");
    }

    private static void checkOpening(ItineraryItem item, LocalDate date, String label, Set<String> warnings) {
        var destination = item.getDestination();
        var hours = destination == null ? null : RecommendationSchedule.readHours(destination);
        var periods = RecommendationSchedule.hours(hours, date);
        if (periods == null) {
            warnings.add(label + " chưa rõ giờ mở cửa. Hãy xác nhận trước khi ghé.");
            return;
        }
        int start = item.getStartTime().toSecondOfDay();
        long end = start + item.getDurationMinutes() * 60L;
        if (periods.stream().noneMatch(period -> period.encloses(start, end))) {
            warnings.add(label + " nằm ngoài ca mở cửa.");
        }
    }
}
