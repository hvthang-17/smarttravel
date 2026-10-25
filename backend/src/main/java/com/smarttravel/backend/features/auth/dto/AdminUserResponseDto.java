package com.smarttravel.backend.features.auth.dto;

import java.time.Instant;

public class AdminUserResponseDto {
    private Long id;
    private String email;
    private String fullName;
    private String role;
    private String status;
    private Instant createdAt;
    private Instant updatedAt;
    private Integer tripsCount;

    public AdminUserResponseDto() {}

    public AdminUserResponseDto(Long id, String email, String fullName, String role, String status, Instant createdAt, Instant updatedAt, Integer tripsCount) {
        this.id = id;
        this.email = email;
        this.fullName = fullName;
        this.role = role;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.tripsCount = tripsCount;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    public Integer getTripsCount() { return tripsCount; }
    public void setTripsCount(Integer tripsCount) { this.tripsCount = tripsCount; }
}
