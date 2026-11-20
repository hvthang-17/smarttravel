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

    @Column(name = "destination_name")
    private String destinationName;

    @Column(name = "latitude")
    private java.math.BigDecimal latitude;

    @Column(name = "longitude")
    private java.math.BigDecimal longitude;

    @Column(name = "category_code")
    private String categoryCode;

    @Column(name = "unit_price_vnd")
    private Long unitPriceVnd;

    @Column(name = "recommendation_reason")
    private String recommendationReason;

    @Column(name = "featured_recommendation", nullable = false)
    private boolean featuredRecommendation;

    @Column(name = "upper_price_known", nullable = false)
    private boolean upperPriceKnown = true;

    public boolean isFeaturedRecommendation() { return featuredRecommendation; }
    public void setFeaturedRecommendation(boolean value) { featuredRecommendation = value; }
    public boolean isUpperPriceKnown() { return upperPriceKnown; }
    public void setUpperPriceKnown(boolean value) { upperPriceKnown = value; }

    @Column(name = "travel_distance_m")
    private Integer travelDistanceM;

    @Column(name = "travel_duration_seconds")
    private Integer travelDurationSeconds;

    @Column(name = "route_source")
    private String routeSource = "UNKNOWN";

    @Column(name = "route_polyline", columnDefinition = "MEDIUMTEXT")
    private String routePolyline;

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

    public String getDestinationName() { return destinationName; }
    public void setDestinationName(String destinationName) { this.destinationName = destinationName; }
    public java.math.BigDecimal getLatitude() { return latitude; }
    public void setLatitude(java.math.BigDecimal latitude) { this.latitude = latitude; }
    public java.math.BigDecimal getLongitude() { return longitude; }
    public void setLongitude(java.math.BigDecimal longitude) { this.longitude = longitude; }
    public String getCategoryCode() { return categoryCode; }
    public void setCategoryCode(String categoryCode) { this.categoryCode = categoryCode; }
    public Long getUnitPriceVnd() { return unitPriceVnd; }
    public void setUnitPriceVnd(Long unitPriceVnd) { this.unitPriceVnd = unitPriceVnd; }
    public String getRecommendationReason() { return recommendationReason; }
    public void setRecommendationReason(String recommendationReason) { this.recommendationReason = recommendationReason; }
    public Integer getTravelDistanceM() { return travelDistanceM; }
    public void setTravelDistanceM(Integer travelDistanceM) { this.travelDistanceM = travelDistanceM; }
    public Integer getTravelDurationSeconds() { return travelDurationSeconds; }
    public void setTravelDurationSeconds(Integer travelDurationSeconds) { this.travelDurationSeconds = travelDurationSeconds; }
    public String getRouteSource() { return routeSource; }
    public void setRouteSource(String routeSource) { this.routeSource = routeSource; }
    public String getRoutePolyline() { return routePolyline; }
    public void setRoutePolyline(String routePolyline) { this.routePolyline = routePolyline; }
}
