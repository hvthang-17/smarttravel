package com.smarttravel.backend.features.itinerary.domain;

import com.smarttravel.backend.features.destination.domain.Destination;
import jakarta.persistence.*;
import java.time.LocalTime;

@Entity
@Table(name = "itinerary_items")
public class ItineraryItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "day_id", nullable = false)
    private ItineraryDay day;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "destination_id")
    private Destination destination;

    @Column(name = "sequence_order", nullable = false)
    private Integer sequenceOrder;

    @Column(name = "start_time")
    private LocalTime startTime;

    @Column(name = "duration_minutes")
    private Integer durationMinutes = 90;

    @Column(name = "estimated_cost_vnd")
    private Long estimatedCostVnd = 0L;

    @Column(columnDefinition = "TEXT")
    private String notes;

    public ItineraryItem() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public ItineraryDay getDay() { return day; }
    public void setDay(ItineraryDay day) { this.day = day; }
    public Destination getDestination() { return destination; }
    public void setDestination(Destination destination) { this.destination = destination; }
    public Integer getSequenceOrder() { return sequenceOrder; }
    public void setSequenceOrder(Integer sequenceOrder) { this.sequenceOrder = sequenceOrder; }
    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }
    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }
    public Long getEstimatedCostVnd() { return estimatedCostVnd; }
    public void setEstimatedCostVnd(Long estimatedCostVnd) { this.estimatedCostVnd = estimatedCostVnd; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
