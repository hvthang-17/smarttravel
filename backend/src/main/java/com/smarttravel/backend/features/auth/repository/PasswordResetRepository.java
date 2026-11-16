package com.smarttravel.backend.features.auth.repository;

import com.smarttravel.backend.features.auth.domain.PasswordResetToken;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.*;
import java.time.LocalDateTime;
import java.util.Optional;

public interface PasswordResetRepository extends JpaRepository<PasswordResetToken, Long> {
    @Query("select t.userId from PasswordResetToken t where t.tokenHash = :hash")
    Optional<Long> owner(byte[] hash);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select t from PasswordResetToken t where t.tokenHash = :hash")
    Optional<PasswordResetToken> lockToken(byte[] hash);

    boolean existsByUserIdAndCreatedAtAfter(Long userId, java.time.Instant cutoff);

    @Modifying
    @Query("update PasswordResetToken t set t.usedAt = :now where t.userId = :userId and t.usedAt is null")
    void consumeAll(Long userId, LocalDateTime now);
}
