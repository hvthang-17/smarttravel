package com.smarttravel.backend.features.auth.service;

import com.smarttravel.backend.common.PasswordPolicy;
import com.smarttravel.backend.features.auth.domain.PasswordResetToken;
import com.smarttravel.backend.features.auth.repository.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.time.*;
import java.util.*;

@Service
public class PasswordResetService {
    public record Delivery(String email, String code, byte[] hash) {}
    private final UserRepository users;
    private final PasswordResetRepository tokens;
    private final PasswordEncoder encoder;
    private final SecureRandom random = new SecureRandom();

    public PasswordResetService(UserRepository users, PasswordResetRepository tokens, PasswordEncoder encoder) {
        this.users = users;
        this.tokens = tokens;
        this.encoder = encoder;
    }

    @Transactional
    public Optional<Delivery> issue(String email) {
        var user = users.lockByEmail(email.trim().toLowerCase(Locale.ROOT)).orElse(null);
        Instant now = Instant.now();
        if (user == null || !"ACTIVE".equals(user.getStatus())
                || tokens.existsByUserIdAndCreatedAtAfter(user.getId(), now.minusSeconds(60))) return Optional.empty();
        byte[] secret = new byte[32];
        random.nextBytes(secret);
        String code = Base64.getUrlEncoder().withoutPadding().encodeToString(secret);
        byte[] hash = hash(code);
        var token = new PasswordResetToken();
        token.setUserId(user.getId());
        token.setTokenHash(hash);
        token.setCreatedAt(now);
        token.setExpiresAt(LocalDateTime.ofInstant(now.plusSeconds(1200), ZoneOffset.UTC));
        tokens.save(token);
        return Optional.of(new Delivery(user.getEmail(), code, hash));
    }

    @Transactional
    public void discardFailedDelivery(byte[] hash) {
        tokens.lockToken(hash).filter(token -> token.getUsedAt() == null).ifPresent(tokens::delete);
    }

    @Transactional
    public void reset(String code, String password) {
        PasswordPolicy.validate(password);
        byte[] hash = hash(code);
        Long id = tokens.owner(hash).orElseThrow(PasswordResetService::invalid);
        var user = users.lockById(id).orElseThrow(PasswordResetService::invalid);
        var token = tokens.lockToken(hash).orElseThrow(PasswordResetService::invalid);
        var now = LocalDateTime.now(ZoneOffset.UTC);
        if (!"ACTIVE".equals(user.getStatus()) || token.getUsedAt() != null || !token.getExpiresAt().isAfter(now)) throw invalid();
        user.setPasswordHash(encoder.encode(password));
        user.revokeSessions();
        tokens.consumeAll(id, now);
    }

    private static IllegalArgumentException invalid() {
        return new IllegalArgumentException("Mã đặt lại mật khẩu không hợp lệ hoặc đã hết hạn");
    }

    private static byte[] hash(String code) {
        try { return MessageDigest.getInstance("SHA-256").digest(code.getBytes(StandardCharsets.UTF_8)); }
        catch (NoSuchAlgorithmException ex) { throw new IllegalStateException(ex); }
    }
}
