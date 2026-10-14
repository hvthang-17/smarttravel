package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.domain.ItineraryDay;
import com.smarttravel.backend.features.itinerary.domain.ItineraryItem;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;

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

        if (entity.getDays() != null) {
            dto.setDays(entity.getDays().stream().map(ItineraryMapper::toDayDto).collect(Collectors.toList()));
        }

        return dto;
    }

    public static ItineraryResponseDto.ItineraryDayDto toDayDto(ItineraryDay day) {
        if (day == null) return null;
        ItineraryResponseDto.ItineraryDayDto dto = new ItineraryResponseDto.ItineraryDayDto();
        dto.setId(day.getId());
        dto.setDayNumber(day.getDayNumber());
        dto.setDate(day.getDate());
        if (day.getItems() != null) {
            dto.setItems(day.getItems().stream().map(ItineraryMapper::toItemDto).collect(Collectors.toList()));
        }
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
}
