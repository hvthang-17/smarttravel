package com.smarttravel.backend.features.itinerary.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;
import java.util.List;

public class ItineraryResponseDto {
    private Long id;
    private String title;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer totalDays;
    private Integer travelersCount;
    private Long maxBudgetVnd;
    private String pace;
    private Long totalEstimatedCost;
    private String status;
    private List<ItineraryDayDto> days;

    public static class ItineraryDayDto {
        private Long id;
        private Integer dayNumber;
        private LocalDate date;
        private List<ItineraryItemDto> items;

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public Integer getDayNumber() { return dayNumber; }
        public void setDayNumber(Integer dayNumber) { this.dayNumber = dayNumber; }
        public LocalDate getDate() { return date; }
        public void setDate(LocalDate date) { this.date = date; }
        public List<ItineraryItemDto> getItems() { return items; }
        public void setItems(List<ItineraryItemDto> items) { this.items = items; }
    }

    public static class ItineraryItemDto {
        private Long id;
        private Integer sequenceOrder;
        private String startTime;
        private Integer durationMinutes;
        private Long estimatedCostVnd;
        private String notes;
        private DestinationSummaryDto destination;

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public Integer getSequenceOrder() { return sequenceOrder; }
        public void setSequenceOrder(Integer sequenceOrder) { this.sequenceOrder = sequenceOrder; }
        public String getStartTime() { return startTime; }
        public void setStartTime(String startTime) { this.startTime = startTime; }
        public Integer getDurationMinutes() { return durationMinutes; }
        public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }
        public Long getEstimatedCostVnd() { return estimatedCostVnd; }
        public void setEstimatedCostVnd(Long estimatedCostVnd) { this.estimatedCostVnd = estimatedCostVnd; }
        public String getNotes() { return notes; }
        public void setNotes(String notes) { this.notes = notes; }
        public DestinationSummaryDto getDestination() { return destination; }
        public void setDestination(DestinationSummaryDto destination) { this.destination = destination; }
    }

    public static class DestinationSummaryDto {
        private Long id;
        private String name;
        private String category;
        private Double latitude;
        private Double longitude;
        private Long priceMinVnd;
        private Long priceMaxVnd;

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        public Double getLatitude() { return latitude; }
        public void setLatitude(Double latitude) { this.latitude = latitude; }
        public Double getLongitude() { return longitude; }
        public void setLongitude(Double longitude) { this.longitude = longitude; }
        public Long getPriceMinVnd() { return priceMinVnd; }
        public void setPriceMinVnd(Long priceMinVnd) { this.priceMinVnd = priceMinVnd; }
        public Long getPriceMaxVnd() { return priceMaxVnd; }
        public void setPriceMaxVnd(Long priceMaxVnd) { this.priceMaxVnd = priceMaxVnd; }
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public Integer getTotalDays() { return totalDays; }
    public void setTotalDays(Integer totalDays) { this.totalDays = totalDays; }
    public Integer getTravelersCount() { return travelersCount; }
    public void setTravelersCount(Integer travelersCount) { this.travelersCount = travelersCount; }
    public Long getMaxBudgetVnd() { return maxBudgetVnd; }
    public void setMaxBudgetVnd(Long maxBudgetVnd) { this.maxBudgetVnd = maxBudgetVnd; }
    public String getPace() { return pace; }
    public void setPace(String pace) { this.pace = pace; }
    public Long getTotalEstimatedCost() { return totalEstimatedCost; }
    public void setTotalEstimatedCost(Long totalEstimatedCost) { this.totalEstimatedCost = totalEstimatedCost; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public List<ItineraryDayDto> getDays() { return days; }
    public void setDays(List<ItineraryDayDto> days) { this.days = days; }
}
