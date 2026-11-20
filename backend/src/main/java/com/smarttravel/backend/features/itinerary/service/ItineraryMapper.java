package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.domain.ItineraryDay;
import com.smarttravel.backend.features.itinerary.domain.ItineraryItem;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;

import java.util.*;
import java.util.stream.Collectors;

public class ItineraryMapper {

    public static ItineraryResponseDto toDto(Itinerary entity) {
        if (entity == null) return null;

        ItineraryResponseDto dto = new ItineraryResponseDto();
        dto.setId(entity.getId());
        dto.setTitle(entity.getTitle());
        dto.setStartDate(entity.getStartDate());
        dto.setEndDate(entity.getEndDate());
        dto.setTotalDays(entity.getTotalDays());
        dto.setTravelersCount(entity.getTravelersCount());
        dto.setMaxBudgetVnd(entity.getMaxBudgetVnd());
        dto.setPace(entity.getPace());
        dto.setTransport(entity.getTransport());
        dto.setCostComplete(entity.getCostComplete());
        dto.setGenerationStatus(entity.getGenerationStatus());
        dto.setWarnings(entity.getWarnings());
        dto.setTotalEstimatedCost(entity.getTotalEstimatedCost());
        dto.setStatus(entity.getStatus());
        dto.setVersion(entity.getVersion());

        Map<String, Long> categoryBreakdown = new LinkedHashMap<>();

        if (entity.getDays() != null) {
            List<ItineraryResponseDto.ItineraryDayDto> dayDtos = new ArrayList<>();
            for (ItineraryDay day : entity.getDays()) {
                ItineraryResponseDto.ItineraryDayDto dayDto = toDayDto(day, categoryBreakdown);
                dayDtos.add(dayDto);
            }
            dto.setDays(dayDtos);
        }

        dto.setCategoryBreakdown(categoryBreakdown);

        if (entity.getMaxBudgetVnd() != null && entity.getMaxBudgetVnd() > 0) {
            long totalCost = entity.getTotalEstimatedCost() != null ? entity.getTotalEstimatedCost() : 0L;
            double percent = (totalCost * 100.0) / entity.getMaxBudgetVnd();
            dto.setBudgetUtilizationPercent(Math.round(percent * 10.0) / 10.0);
            if (!Boolean.TRUE.equals(entity.getCostComplete())) {
                dto.setBudgetHealth("UNKNOWN");
            } else if (percent > 100.0) {
                dto.setBudgetHealth("OVERBUDGET");
            } else if (percent >= 85.0) {
                dto.setBudgetHealth("WARNING");
            } else {
                dto.setBudgetHealth("HEALTHY");
            }
        } else {
            dto.setBudgetUtilizationPercent(0.0);
            dto.setBudgetHealth("UNKNOWN");
        }

        return dto;
    }

    public static ItineraryResponseDto.ItineraryDayDto toDayDto(ItineraryDay day, Map<String, Long> globalCategoryBreakdown) {
        if (day == null) return null;
        ItineraryResponseDto.ItineraryDayDto dto = new ItineraryResponseDto.ItineraryDayDto();
        dto.setId(day.getId());
        dto.setDayNumber(day.getDayNumber());
        dto.setDate(day.getDate());

        long dayCost = 0L;
        double totalDistance = 0.0;
        int totalMinutes = 0;
        boolean distanceComplete = true, durationComplete = true;

        List<ItineraryResponseDto.ItineraryItemDto> itemDtos = new ArrayList<>();
        if (day.getItems() != null) {
            List<ItineraryItem> sortedItems = day.getItems().stream()
                    .sorted(Comparator.comparing(ItineraryItem::getSequenceOrder, Comparator.nullsLast(Comparator.naturalOrder())))
                    .collect(Collectors.toList());

            for (ItineraryItem item : sortedItems) {
                ItineraryResponseDto.ItineraryItemDto itemDto = toItemDto(item);

                Double distance = item.getTravelDistanceM() == null ? null : item.getTravelDistanceM() / 1000.0;
                Integer minutes = item.getTravelDurationSeconds() == null ? null : (int) Math.ceil(item.getTravelDurationSeconds() / 60.0);
                itemDto.setTravelDistanceKm(distance);
                itemDto.setTravelMinutes(minutes);
                if (distance != null) totalDistance += distance; else distanceComplete = false;
                if (minutes != null) totalMinutes += minutes; else durationComplete = false;

                if (item.getDurationMinutes() != null) {
                    totalMinutes += item.getDurationMinutes();
                } else durationComplete = false;

                if (item.getEstimatedCostVnd() != null) {
                    dayCost += item.getEstimatedCostVnd();
                    if (item.getCategoryCode() != null) {
                        String cat = item.getCategoryCode();
                        globalCategoryBreakdown.put(cat, globalCategoryBreakdown.getOrDefault(cat, 0L) + item.getEstimatedCostVnd());
                    }
                }

                itemDtos.add(itemDto);
            }
        }

        dto.setItems(itemDtos);
        dto.setDayCostVnd(dayCost);
        dto.setTotalDistanceKm(distanceComplete ? Math.round(totalDistance * 10.0) / 10.0 : null);
        dto.setTotalDurationMinutes(durationComplete ? totalMinutes : null);
        return dto;
    }

    public static ItineraryResponseDto.ItineraryItemDto toItemDto(ItineraryItem item) {
        if (item == null) return null;
        ItineraryResponseDto.ItineraryItemDto dto = new ItineraryResponseDto.ItineraryItemDto();
        dto.setId(item.getId());
        dto.setSequenceOrder(item.getSequenceOrder());
        dto.setStartTime(item.getStartTime() != null ? item.getStartTime().toString() : null);
        dto.setDurationMinutes(item.getDurationMinutes());
        dto.setEstimatedCostVnd(item.getEstimatedCostVnd());
        dto.setNotes(item.getNotes());
        ItineraryResponseDto.DestinationSummaryDto snapshot = new ItineraryResponseDto.DestinationSummaryDto();
        snapshot.setId(item.getDestination() == null ? null : item.getDestination().getId());
        snapshot.setName(item.getDestinationName());
        snapshot.setCategory(item.getCategoryCode());
        snapshot.setLatitude(item.getLatitude() == null ? null : item.getLatitude().doubleValue());
        snapshot.setLongitude(item.getLongitude() == null ? null : item.getLongitude().doubleValue());
        snapshot.setPriceMinVnd(item.getUnitPriceVnd());
        snapshot.setPriceMaxVnd(item.getUnitPriceVnd());
        dto.setDestination(snapshot);
        dto.setCategoryCode(item.getCategoryCode());
        dto.setUnitPriceVnd(item.getUnitPriceVnd());
        dto.setRouteSource(item.getRouteSource());
        dto.setRecommendationReason(item.getRecommendationReason());
        dto.setFeaturedRecommendation(item.isFeaturedRecommendation());
        dto.setUpperPriceKnown(item.isUpperPriceKnown());
        dto.setRoutePolyline(item.getRoutePolyline());
        return dto;
    }

    public static ItineraryResponseDto.DestinationSummaryDto toDestinationSummary(Destination dest) {
        if (dest == null) return null;
        ItineraryResponseDto.DestinationSummaryDto dto = new ItineraryResponseDto.DestinationSummaryDto();
        dto.setId(dest.getId());
        dto.setName(dest.getName());
        dto.setCategory(dest.getCategory() != null ? dest.getCategory().getName() : null);
        dto.setLatitude(dest.getLatitude() != null ? dest.getLatitude().doubleValue() : null);
        dto.setLongitude(dest.getLongitude() != null ? dest.getLongitude().doubleValue() : null);
        dto.setPriceMinVnd(dest.getPriceMinVnd());
        dto.setPriceMaxVnd(dest.getPriceMaxVnd());
        return dto;
    }

}
