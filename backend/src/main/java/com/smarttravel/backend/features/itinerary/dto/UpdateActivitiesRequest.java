package com.smarttravel.backend.features.itinerary.dto;

import jakarta.validation.constraints.NotNull;
import java.util.List;

public class UpdateActivitiesRequest {
    @NotNull(message = "Cần version hiện tại để cập nhật lịch trình")
    @jakarta.validation.constraints.Min(1)
    private Integer version;
    private boolean recalculateAll;
    public boolean isRecalculateAll() { return recalculateAll; }
    public void setRecalculateAll(boolean value) { recalculateAll = value; }
    public Integer getVersion() { return version; }
    public void setVersion(Integer value) { version = value; }


    @NotNull(message = "Danh sách ngày không được để trống")
    @jakarta.validation.constraints.Size(max = 7)
    @jakarta.validation.Valid
    private List<@NotNull DayUpdateDto> days;

    public static class DayUpdateDto {
        private boolean recalculateRoute;
        public boolean isRecalculateRoute() { return recalculateRoute; }
        public void setRecalculateRoute(boolean value) { recalculateRoute = value; }
        @jakarta.validation.constraints.Positive
        private Long dayId;
        @jakarta.validation.constraints.Min(1)
        @jakarta.validation.constraints.Max(7)
        private Integer dayNumber;
        @jakarta.validation.Valid
        @NotNull
        @jakarta.validation.constraints.Size(max = 100)
        private List<@NotNull ItemUpdateDto> items;

        public Long getDayId() { return dayId; }
        public void setDayId(Long dayId) { this.dayId = dayId; }
        public Integer getDayNumber() { return dayNumber; }
        public void setDayNumber(Integer dayNumber) { this.dayNumber = dayNumber; }
        public List<ItemUpdateDto> getItems() { return items; }
        public void setItems(List<@NotNull ItemUpdateDto> items) { this.items = items; }
    }

    public static class ItemUpdateDto {
        @jakarta.validation.constraints.Positive
        private Long id;
        @jakarta.validation.constraints.Positive
        private Long destinationId;
        @NotNull
        @jakarta.validation.constraints.Positive
        @jakarta.validation.constraints.Max(100)
        private Integer sequenceOrder;
        private String startTime;
        @jakarta.validation.constraints.Positive
        @jakarta.validation.constraints.Max(1440)
        private Integer durationMinutes;
        private Long estimatedCostVnd;
        @jakarta.validation.constraints.Size(max = 4000)
        private String notes;
        private boolean destinationSupplied;
        private boolean timeSupplied;
        private boolean durationSupplied;
        private boolean notesSupplied;

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public Long getDestinationId() { return destinationId; }
        public void setDestinationId(Long destinationId) { this.destinationId = destinationId; destinationSupplied = true; }
        public Integer getSequenceOrder() { return sequenceOrder; }
        public void setSequenceOrder(Integer sequenceOrder) { this.sequenceOrder = sequenceOrder; }
        public String getStartTime() { return startTime; }
        public void setStartTime(String startTime) { this.startTime = startTime; timeSupplied = true; }
        public Integer getDurationMinutes() { return durationMinutes; }
        public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; durationSupplied = true; }
        public Long getEstimatedCostVnd() { return estimatedCostVnd; }
        public void setEstimatedCostVnd(Long estimatedCostVnd) { this.estimatedCostVnd = estimatedCostVnd; }
        public String getNotes() { return notes; }
        public void setNotes(String notes) { this.notes = notes; notesSupplied = true; }
        public boolean hasDestination() { return destinationSupplied; }
        public boolean hasStartTime() { return timeSupplied; }
        public boolean hasDuration() { return durationSupplied; }
        public boolean hasNotes() { return notesSupplied; }
    }

    public List<DayUpdateDto> getDays() { return days; }
    public void setDays(List<@NotNull DayUpdateDto> days) { this.days = days; }
}
