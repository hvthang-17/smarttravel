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
        dto.setTotalEstimatedCost(entity.getTotalEstimatedCost());
        dto.setStatus(entity.getStatus());
        dto.setShareToken(entity.getShareToken());
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
            if (percent > 100.0) {
                dto.setBudgetHealth("OVERBUDGET");
            } else if (percent >= 85.0) {
                dto.setBudgetHealth("WARNING");
            } else {
                dto.setBudgetHealth("HEALTHY");
            }
        } else {
            dto.setBudgetUtilizationPercent(0.0);
            dto.setBudgetHealth("HEALTHY");
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

        List<ItineraryResponseDto.ItineraryItemDto> itemDtos = new ArrayList<>();
        if (day.getItems() != null) {
            List<ItineraryItem> sortedItems = day.getItems().stream()
                    .sorted(Comparator.comparing(ItineraryItem::getSequenceOrder, Comparator.nullsLast(Comparator.naturalOrder())))
                    .collect(Collectors.toList());

            Destination prevDest = null;
            for (ItineraryItem item : sortedItems) {
                ItineraryResponseDto.ItineraryItemDto itemDto = toItemDto(item);

                Destination currDest = item.getDestination();
                if (prevDest != null && prevDest.getLatitude() != null && prevDest.getLongitude() != null
                        && currDest != null && currDest.getLatitude() != null && currDest.getLongitude() != null) {
                    double distKm = haversineKm(
                            prevDest.getLatitude().doubleValue(),
                            prevDest.getLongitude().doubleValue(),
                            currDest.getLatitude().doubleValue(),
                            currDest.getLongitude().doubleValue()
                    );
                    int travelMin = (int) Math.max(5, Math.round(distKm * 2.2));
                    itemDto.setTravelDistanceKm(distKm);
                    itemDto.setTravelMinutes(travelMin);
                    totalDistance += distKm;
                    totalMinutes += travelMin;
                } else {
                    itemDto.setTravelDistanceKm(0.0);
                    itemDto.setTravelMinutes(0);
                }

                if (item.getDurationMinutes() != null) {
                    totalMinutes += item.getDurationMinutes();
                }

                if (item.getEstimatedCostVnd() != null) {
                    dayCost += item.getEstimatedCostVnd();
                    if (currDest != null && currDest.getCategory() != null) {
                        String cat = currDest.getCategory();
                        globalCategoryBreakdown.put(cat, globalCategoryBreakdown.getOrDefault(cat, 0L) + item.getEstimatedCostVnd());
                    }
                }

                itemDtos.add(itemDto);
                prevDest = currDest;
            }
        }

        dto.setItems(itemDtos);
        dto.setDayCostVnd(dayCost);
        dto.setTotalDistanceKm(Math.round(totalDistance * 10.0) / 10.0);
        dto.setTotalDurationMinutes(totalMinutes);
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
        dto.setDestination(toDestinationSummary(item.getDestination()));
        return dto;
    }

    public static ItineraryResponseDto.DestinationSummaryDto toDestinationSummary(Destination dest) {
        if (dest == null) return null;
        ItineraryResponseDto.DestinationSummaryDto dto = new ItineraryResponseDto.DestinationSummaryDto();
        dto.setId(dest.getId());
        dto.setName(dest.getName());
        dto.setCategory(dest.getCategory());
        dto.setLatitude(dest.getLatitude() != null ? dest.getLatitude().doubleValue() : null);
        dto.setLongitude(dest.getLongitude() != null ? dest.getLongitude().doubleValue() : null);
        dto.setPriceMinVnd(dest.getPriceMinVnd());
        dto.setPriceMaxVnd(dest.getPriceMaxVnd());
        return dto;
    }

    private static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371;
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c;
        return Math.round(distance * 10.0) / 10.0;
    }
}
