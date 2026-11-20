package com.smarttravel.backend.features.itinerary.domain;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "itinerary_days")
public class ItineraryDay {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "itinerary_id", nullable = false)
    private Itinerary itinerary;

    @Column(name = "day_number", nullable = false)
    private Integer dayNumber;

    @Column(name = "date")
    private LocalDate date;

    @OneToMany(mappedBy = "day", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ItineraryItem> items = new ArrayList<>();

    @Column(name = "origin_name")
    private String originName;

    @Column(name = "origin_latitude")
    private java.math.BigDecimal originLatitude;

    @Column(name = "origin_longitude")
    private java.math.BigDecimal originLongitude;

    public ItineraryDay() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Itinerary getItinerary() { return itinerary; }
    public void setItinerary(Itinerary itinerary) { this.itinerary = itinerary; }
    public Integer getDayNumber() { return dayNumber; }
    public void setDayNumber(Integer dayNumber) { this.dayNumber = dayNumber; }
    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
    public List<ItineraryItem> getItems() { return items; }
    public void setItems(List<ItineraryItem> items) { this.items = items; }

    public String getOriginName() { return originName; }
    public void setOriginName(String originName) { this.originName = originName; }
    public java.math.BigDecimal getOriginLatitude() { return originLatitude; }
    public void setOriginLatitude(java.math.BigDecimal originLatitude) { this.originLatitude = originLatitude; }
    public java.math.BigDecimal getOriginLongitude() { return originLongitude; }
    public void setOriginLongitude(java.math.BigDecimal originLongitude) { this.originLongitude = originLongitude; }
}
