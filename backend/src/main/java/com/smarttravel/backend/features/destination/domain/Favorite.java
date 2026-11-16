package com.smarttravel.backend.features.destination.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "favorites")
@IdClass(Favorite.Key.class)
public class Favorite {
    @Id
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Id
    @Column(name = "destination_id", nullable = false)
    private Long destinationId;

    @Column(name = "created_at", nullable = false)
    private java.time.Instant createdAt = java.time.Instant.now();

    public Long getUserId() { return userId; }
    public void setUserId(Long value) { userId = value; }
    public Long getDestinationId() { return destinationId; }
    public void setDestinationId(Long value) { destinationId = value; }
    public java.time.Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.time.Instant value) { createdAt = value; }
    public static class Key implements java.io.Serializable {
        private Long userId;
        private Long destinationId;
        public Key() {}
        @Override public boolean equals(Object other) {
            if (!(other instanceof Key key)) return false;
            return java.util.Objects.equals(userId, key.userId) && java.util.Objects.equals(destinationId, key.destinationId);
        }
        @Override public int hashCode() { return java.util.Objects.hash(userId, destinationId); }
    }

}
