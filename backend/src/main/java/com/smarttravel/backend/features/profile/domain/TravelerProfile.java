package com.smarttravel.backend.features.profile.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "traveler_profiles")
public class TravelerProfile {
    @Id
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "language", length = 5, nullable = false)
    private String language = "vi";

    @Column(name = "default_budget_vnd")
    private Long defaultBudgetVnd;

    @Column(name = "default_pace", length = 30, nullable = false)
    private String defaultPace = "balanced";

    @Column(name = "default_transport", length = 20, nullable = false)
    private String defaultTransport = "unspecified";

    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    @Column(name = "preferred_categories", columnDefinition = "json", nullable = false)
    private java.util.List<String> preferredCategories = new java.util.ArrayList<>();

    @Column(name = "created_at", nullable = false)
    private java.time.Instant createdAt = java.time.Instant.now();

    @Column(name = "updated_at", nullable = false)
    private java.time.Instant updatedAt = java.time.Instant.now();

    public Long getUserId() { return userId; }
    public void setUserId(Long value) { userId = value; }
    public String getLanguage() { return language; }
    public void setLanguage(String value) { language = value; }
    public Long getDefaultBudgetVnd() { return defaultBudgetVnd; }
    public void setDefaultBudgetVnd(Long value) { defaultBudgetVnd = value; }
    public String getDefaultPace() { return defaultPace; }
    public void setDefaultPace(String value) { defaultPace = value; }
    public String getDefaultTransport() { return defaultTransport; }
    public void setDefaultTransport(String value) { defaultTransport = value; }
    public java.util.List<String> getPreferredCategories() { return preferredCategories; }
    public void setPreferredCategories(java.util.List<String> value) { preferredCategories = value; }
    public java.time.Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.time.Instant value) { createdAt = value; }
    public java.time.Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(java.time.Instant value) { updatedAt = value; }
}
