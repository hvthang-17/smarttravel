package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.common.ResourceConflictException;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.domain.ItineraryDay;
import com.smarttravel.backend.features.itinerary.domain.ItineraryItem;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;

import static com.smarttravel.backend.features.itinerary.service.RecommendationSchedule.Stop;

final class RecommendationOutput {
    private RecommendationOutput() {}

    static void publish(Itinerary trip, List<Stop> candidates, RecommendationPlanner.Plan result, int minimum,
                                RecommendationSchedule fitter) {
        var missingRequired = candidates.stream().filter(Stop::required)
                .filter(stop -> !result.used().contains(stop.id()))
                .map(stop -> missingReason(trip, result, stop, fitter)).toList();
        if (result.used().isEmpty()) {
            var missing = missingRequired.isEmpty() ? "" : " Điểm bắt buộc chưa xếp được: " + String.join(", ", missingRequired) + ".";
            throw new ResourceConflictException("Không xếp được hoạt động nào." + missing
                    + " Hãy thử đổi ngày, tăng ngân sách hoặc điều chỉnh điểm bắt buộc.");
        }
        var warnings = new LinkedHashSet<String>();
        if (!missingRequired.isEmpty()) warnings.add("Chưa xếp được điểm bắt buộc: " + String.join(", ", missingRequired)
                + ". Hãy kiểm tra giờ mở cửa, ngân sách và thời gian đi hoặc đổi ngày.");
        var days = new ArrayList<ItineraryDay>();
        boolean pricesComplete = true;
        boolean partial = !missingRequired.isEmpty();
        for (int i = 0; i < result.days().size(); i++) {
            var schedule = result.days().get(i);
            var day = new ItineraryDay();
            day.setItinerary(trip);
            day.setDayNumber(i + 1);
            day.setDate(trip.getStartDate().plusDays(i));
            if (schedule.sightseeing() < minimum) {
                partial = true;
                warnings.add("Ngày " + (i + 1) + " chưa đủ lượt tham quan theo nhịp độ. Thử mở rộng sở thích, đổi ngày hoặc tăng ngân sách.");
            }
            for (var visit : schedule.visits()) {
                var stop = visit.stop();
                var item = new ItineraryItem();
                item.setDay(day);
                item.setSequenceOrder(day.getItems().size() + 1);
                ItineraryCalculation.snapshot(item, stop.destination());
                item.setStartTime(LocalTime.ofSecondOfDay(visit.start() * 60L));
                item.setDurationMinutes(stop.duration());
                boolean featured = Objects.equals(result.featured(), stop.id());
                item.setFeaturedRecommendation(featured);
                item.setRecommendationReason(reason(stop, featured));
                item.setEstimatedCostVnd(ItineraryCalculation.groupCost(stop.unitPrice(), trip.getTravelersCount()));
                if (!item.isUpperPriceKnown()) {
                    pricesComplete = false;
                    warnings.add(stop.name() + (stop.unitPrice() == null
                            ? " chưa có giá tham khảo." : " chỉ có giá tối thiểu, dự toán có thể tăng."));
                }
                if (visit.hoursUnknown()) warnings.add(stop.name() + " chưa rõ giờ mở cửa, cần xác nhận trước khi ghé.");
                var leg = visit.leg();
                if (leg == null) warnings.add("Một số chặng chưa rõ thời gian đi. Lịch tạm chừa 30 phút cho mỗi chặng này.");
                else {
                    if ("HAVERSINE".equals(leg.source())) warnings.add("Một số chặng dùng thời gian di chuyển ước tính.");
                }
                ItineraryCalculation.applyLeg(item, leg);
                day.getItems().add(item);
            }
            days.add(day);
        }
        trip.setDays(days);
        trip.setTotalEstimatedCost(result.cost());
        trip.setCostComplete(pricesComplete);
        trip.setGenerationStatus(partial ? "PARTIAL" : "COMPLETE");
        trip.setWarnings(List.copyOf(warnings));
    }

    private static String missingReason(Itinerary trip, RecommendationPlanner.Plan plan, Stop stop, RecommendationSchedule fitter) {
        if (stop.unitPrice() != null && stop.unitPrice() > trip.getMaxBudgetVnd() / trip.getTravelersCount()) {
            return stop.name() + " (vượt ngân sách của nhóm)";
        }
        for (int day = 0; day < trip.getTotalDays(); day++) {
            if (fitter.fit(trip.getStartDate().plusDays(day), List.of(stop)) == null) continue;
            if (stop.unitPrice() != null && stop.unitPrice() >
                    (trip.getMaxBudgetVnd() - plan.cost()) / trip.getTravelersCount()) {
                return stop.name() + " (ngân sách còn lại không đủ)";
            }
            return stop.name() + " (xung đột với các khung đã xếp)";
        }
        return stop.name() + " (không có ca phù hợp với giờ đi và thời lượng)";
    }

    private static String reason(Stop stop, boolean featured) {
        if (featured) return stop.destination().getFeaturedReason();
        if (stop.required()) return "Điểm bạn chọn bắt buộc ghé";
        if (stop.favorite()) return "Địa điểm yêu thích bạn đã chọn";
        if (stop.preferred()) return "Phù hợp sở thích " + stop.destination().getCategory().getName();
        if (stop.meal()) return "Phù hợp khung giờ ăn và lịch trong ngày";
        return "Phù hợp với thời gian và lịch di chuyển trong ngày";
    }
}
