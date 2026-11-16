package com.smarttravel.backend.features.destination.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "destination_reviews")
public class DestinationReview {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @Column(name = "destination_id", nullable = false)
    private Long destinationId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "rating", nullable = false)
    private Integer rating;
    public Integer getRating() { return rating; }
    public void setRating(Integer value) { rating = value; }

    @Column(name = "comment", columnDefinition = "TEXT")
    private String comment;

    @Column(name = "status", length = 20, nullable = false)
    private String status = "PUBLISHED";

    @Column(name = "created_at", nullable = false)
    private java.time.Instant createdAt = java.time.Instant.now();

    @Column(name = "updated_at", nullable = false)
    private java.time.Instant updatedAt = java.time.Instant.now();

    public Long getId() { return id; }
    public void setId(Long value) { id = value; }
    public Long getDestinationId() { return destinationId; }
    public void setDestinationId(Long value) { destinationId = value; }
    public Long getUserId() { return userId; }
    public void setUserId(Long value) { userId = value; }
    public String getComment() { return comment; }
    public void setComment(String value) { comment = value; }
    public String getStatus() { return status; }
    public void setStatus(String value) { status = value; }
    public java.time.Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.time.Instant value) { createdAt = value; }
    public java.time.Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(java.time.Instant value) { updatedAt = value; }
}
