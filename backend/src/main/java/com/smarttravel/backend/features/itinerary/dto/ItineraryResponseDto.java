package com.smarttravel.backend.features.itinerary.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;
import java.util.List;

public class ItineraryResponseDto {
    private String period;
    public String getPeriod() { return period; }
    public void setPeriod(String period) { this.period = period; }
    public record ConstraintDto(Long destinationId, String type,
            com.smarttravel.backend.features.itinerary.domain.ItineraryConstraint.Snapshot snapshot) {}
    private List<ConstraintDto> constraints;
    private String originName;
    private java.math.BigDecimal originLatitude;
    private java.math.BigDecimal originLongitude;
    private List<String> preferredCategories;

    public List<ConstraintDto> getConstraints() { return constraints; }
    public void setConstraints(List<ConstraintDto> value) { constraints = value; }
    public String getOriginName() { return originName; }
    public void setOriginName(String value) { originName = value; }
    public java.math.BigDecimal getOriginLatitude() { return originLatitude; }
    public void setOriginLatitude(java.math.BigDecimal value) { originLatitude = value; }
    public java.math.BigDecimal getOriginLongitude() { return originLongitude; }
    public void setOriginLongitude(java.math.BigDecimal value) { originLongitude = value; }
    public List<String> getPreferredCategories() { return preferredCategories; }
    public void setPreferredCategories(List<String> value) { preferredCategories = value; }
    private Long id;
    private String title;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer totalDays;
    private Integer travelersCount;
    private Long maxBudgetVnd;
    private String pace;
    private String transport;
    private Boolean costComplete;
    private String generationStatus;
    private List<String> warnings;
    public String getTransport() { return transport; }
    public void setTransport(String value) { transport = value; }
    public Boolean getCostComplete() { return costComplete; }
    public void setCostComplete(Boolean value) { costComplete = value; }
    public String getGenerationStatus() { return generationStatus; }
    public void setGenerationStatus(String value) { generationStatus = value; }
    public List<String> getWarnings() { return warnings; }
    public void setWarnings(List<String> value) { warnings = value; }

    private Long totalEstimatedCost;
    private String status;
    private String shareToken;
    private Integer version = 1;
    private java.util.Map<String, Long> categoryBreakdown;
    private Double budgetUtilizationPercent;
    private String budgetHealth;
    private List<ItineraryDayDto> days;

    public static class ItineraryDayDto {
        private Long id;
        private Integer dayNumber;
        private LocalDate date;
        private Long dayCostVnd;
        private Double totalDistanceKm;
        private Integer totalDurationMinutes;
        private List<ItineraryItemDto> items;

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public Integer getDayNumber() { return dayNumber; }
        public void setDayNumber(Integer dayNumber) { this.dayNumber = dayNumber; }
        public LocalDate getDate() { return date; }
        public void setDate(LocalDate date) { this.date = date; }
        public Long getDayCostVnd() { return dayCostVnd; }
        public void setDayCostVnd(Long dayCostVnd) { this.dayCostVnd = dayCostVnd; }
        public Double getTotalDistanceKm() { return totalDistanceKm; }
        public void setTotalDistanceKm(Double totalDistanceKm) { this.totalDistanceKm = totalDistanceKm; }
        public Integer getTotalDurationMinutes() { return totalDurationMinutes; }
        public void setTotalDurationMinutes(Integer totalDurationMinutes) { this.totalDurationMinutes = totalDurationMinutes; }
        public List<ItineraryItemDto> getItems() { return items; }
        public void setItems(List<ItineraryItemDto> items) { this.items = items; }
    }

    public static class ItineraryItemDto {
        private Long id;
        private Integer sequenceOrder;
        private String startTime;
        private Integer durationMinutes;
        private String categoryCode;
        private Long unitPriceVnd;
        private String routeSource;
        private String recommendationReason;
        private boolean featuredRecommendation;
        private boolean upperPriceKnown;

        public String getRecommendationReason() { return recommendationReason; }
        public void setRecommendationReason(String value) { recommendationReason = value; }
        public boolean isFeaturedRecommendation() { return featuredRecommendation; }
        public void setFeaturedRecommendation(boolean value) { featuredRecommendation = value; }
        public boolean isUpperPriceKnown() { return upperPriceKnown; }
        public void setUpperPriceKnown(boolean value) { upperPriceKnown = value; }
        private String routePolyline;
        public String getCategoryCode() { return categoryCode; }
        public void setCategoryCode(String value) { categoryCode = value; }
        public Long getUnitPriceVnd() { return unitPriceVnd; }
        public void setUnitPriceVnd(Long value) { unitPriceVnd = value; }
        public String getRouteSource() { return routeSource; }
        public void setRouteSource(String value) { routeSource = value; }
        public String getRoutePolyline() { return routePolyline; }
        public void setRoutePolyline(String value) { routePolyline = value; }
        private Long estimatedCostVnd;
        private String notes;
        private Double travelDistanceKm;
        private Integer travelMinutes;
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
        public Double getTravelDistanceKm() { return travelDistanceKm; }
        public void setTravelDistanceKm(Double travelDistanceKm) { this.travelDistanceKm = travelDistanceKm; }
        public Integer getTravelMinutes() { return travelMinutes; }
        public void setTravelMinutes(Integer travelMinutes) { this.travelMinutes = travelMinutes; }
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
    public String getShareToken() { return shareToken; }
    public void setShareToken(String shareToken) { this.shareToken = shareToken; }
    public Integer getVersion() { return version; }
    public void setVersion(Integer version) { this.version = version; }
    public java.util.Map<String, Long> getCategoryBreakdown() { return categoryBreakdown; }
    public void setCategoryBreakdown(java.util.Map<String, Long> categoryBreakdown) { this.categoryBreakdown = categoryBreakdown; }
    public Double getBudgetUtilizationPercent() { return budgetUtilizationPercent; }
    public void setBudgetUtilizationPercent(Double budgetUtilizationPercent) { this.budgetUtilizationPercent = budgetUtilizationPercent; }
    public String getBudgetHealth() { return budgetHealth; }
    public void setBudgetHealth(String budgetHealth) { this.budgetHealth = budgetHealth; }
    public List<ItineraryDayDto> getDays() { return days; }
    public void setDays(List<ItineraryDayDto> days) { this.days = days; }
}
