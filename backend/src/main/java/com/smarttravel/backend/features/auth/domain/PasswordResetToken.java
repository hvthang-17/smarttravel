package com.smarttravel.backend.features.auth.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "password_reset_tokens")
public class PasswordResetToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "token_hash", columnDefinition = "BINARY(32)", nullable = false)
    private byte[] tokenHash;

    @Column(name = "expires_at", nullable = false)
    private java.time.LocalDateTime expiresAt;

    @Column(name = "used_at")
    private java.time.LocalDateTime usedAt;

    @Column(name = "created_at", nullable = false)
    private java.time.Instant createdAt = java.time.Instant.now();

    public Long getId() { return id; }
    public void setId(Long value) { id = value; }
    public Long getUserId() { return userId; }
    public void setUserId(Long value) { userId = value; }
    public byte[] getTokenHash() { return tokenHash; }
    public void setTokenHash(byte[] value) { tokenHash = value; }
    public java.time.LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(java.time.LocalDateTime value) { expiresAt = value; }
    public java.time.LocalDateTime getUsedAt() { return usedAt; }
    public void setUsedAt(java.time.LocalDateTime value) { usedAt = value; }
    public java.time.Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.time.Instant value) { createdAt = value; }
}
