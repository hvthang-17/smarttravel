package com.smarttravel.backend.features.itinerary.dto;

import jakarta.validation.constraints.NotNull;
import java.util.List;

public class UpdateActivitiesRequest {

    @NotNull(message = "Danh sách ngày không được để trống")
    private List<DayUpdateDto> days;

    public static class DayUpdateDto {
        private Long dayId;
        private Integer dayNumber;
        private List<ItemUpdateDto> items;

        public Long getDayId() { return dayId; }
        public void setDayId(Long dayId) { this.dayId = dayId; }
        public Integer getDayNumber() { return dayNumber; }
        public void setDayNumber(Integer dayNumber) { this.dayNumber = dayNumber; }
        public List<ItemUpdateDto> getItems() { return items; }
        public void setItems(List<ItemUpdateDto> items) { this.items = items; }
    }

    public static class ItemUpdateDto {
        private Long id;
        private Long destinationId;
        private Integer sequenceOrder;
        private String startTime;
        private Integer durationMinutes;
        private Long estimatedCostVnd;
        private String notes;

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public Long getDestinationId() { return destinationId; }
        public void setDestinationId(Long destinationId) { this.destinationId = destinationId; }
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
    }

    public List<DayUpdateDto> getDays() { return days; }
    public void setDays(List<DayUpdateDto> days) { this.days = days; }
}
