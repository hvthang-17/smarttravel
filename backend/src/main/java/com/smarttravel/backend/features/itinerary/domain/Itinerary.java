package com.smarttravel.backend.features.itinerary.domain;

import com.smarttravel.backend.features.auth.domain.User;
import jakarta.persistence.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "itineraries")
public class Itinerary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String title;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @Column(name = "total_days", nullable = false)
    private Integer totalDays;

    @Column(name = "travelers_count", nullable = false)
    private Integer travelersCount;

    @Column(name = "max_budget_vnd", nullable = false)
    private Long maxBudgetVnd;

    @Column(nullable = false, length = 30)
    private String pace = "balanced";

    @Column(name = "total_estimated_cost")
    private Long totalEstimatedCost = 0L;

    @Column(nullable = false, length = 30)
    private String status = "DRAFT";

    @Column(name = "share_token", unique = true, length = 100)
    private String shareToken;

    @Version
    @Column(nullable = false)
    private Integer version = 1;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    @OneToMany(mappedBy = "itinerary", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("dayNumber ASC")
    private List<ItineraryDay> days = new ArrayList<>();

    @Column(name = "transport")
    private String transport = "unspecified";

    @Column(name = "origin_name")
    private String originName;

    @Column(name = "origin_latitude")
    private java.math.BigDecimal originLatitude;

    @Column(name = "origin_longitude")
    private java.math.BigDecimal originLongitude;

    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    @Column(name = "preferred_categories_snapshot", columnDefinition = "json")
    private java.util.List<String> preferredCategoriesSnapshot;

    @Column(name = "generation_key")
    private String generationKey;

    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    @Column(name = "generation_input", columnDefinition = "json")
    private String generationInput;

    @Column(name = "generation_status")
    private String generationStatus = "COMPLETE";

    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    @Column(name = "warnings", columnDefinition = "json")
    private java.util.List<String> warnings = new java.util.ArrayList<>();

    @Column(name = "cost_complete")
    private Boolean costComplete = false;

    @Column(name = "share_expires_at")
    private java.time.LocalDateTime shareExpiresAt;

    public Itinerary() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
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
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
    public List<ItineraryDay> getDays() { return days; }
    public void setDays(List<ItineraryDay> days) { this.days = days; }

    public String getTransport() { return transport; }
    public void setTransport(String transport) { this.transport = transport; }
    public String getOriginName() { return originName; }
    public void setOriginName(String originName) { this.originName = originName; }
    public java.math.BigDecimal getOriginLatitude() { return originLatitude; }
    public void setOriginLatitude(java.math.BigDecimal originLatitude) { this.originLatitude = originLatitude; }
    public java.math.BigDecimal getOriginLongitude() { return originLongitude; }
    public void setOriginLongitude(java.math.BigDecimal originLongitude) { this.originLongitude = originLongitude; }
    public java.util.List<String> getPreferredCategoriesSnapshot() { return preferredCategoriesSnapshot; }
    public void setPreferredCategoriesSnapshot(java.util.List<String> preferredCategoriesSnapshot) { this.preferredCategoriesSnapshot = preferredCategoriesSnapshot; }
    public String getGenerationKey() { return generationKey; }
    public void setGenerationKey(String generationKey) { this.generationKey = generationKey; }
    public String getGenerationInput() { return generationInput; }
    public void setGenerationInput(String value) { generationInput = value; }
    public String getGenerationStatus() { return generationStatus; }
    public void setGenerationStatus(String generationStatus) { this.generationStatus = generationStatus; }
    public java.util.List<String> getWarnings() { return warnings; }
    public void setWarnings(java.util.List<String> warnings) { this.warnings = warnings; }
    public Boolean getCostComplete() { return costComplete; }
    public void setCostComplete(Boolean costComplete) { this.costComplete = costComplete; }
    public java.time.LocalDateTime getShareExpiresAt() { return shareExpiresAt; }
    public void setShareExpiresAt(java.time.LocalDateTime shareExpiresAt) { this.shareExpiresAt = shareExpiresAt; }
}
