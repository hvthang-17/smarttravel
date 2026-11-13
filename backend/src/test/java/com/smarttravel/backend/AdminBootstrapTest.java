package com.smarttravel.backend;

import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.auth.service.AdminBootstrap;
import org.junit.jupiter.api.Test;
import org.springframework.boot.DefaultApplicationArguments;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import java.util.Optional;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AdminBootstrapTest {
    @Test
    void createsAdminOnlyFromExplicitBootstrapConfiguration() {
        var users = mock(UserRepository.class);
        var encoder = new BCryptPasswordEncoder();
        when(users.findByEmail("admin@example.test")).thenReturn(Optional.empty());
        new AdminBootstrap(users, encoder, " ADMIN@example.test ", "bootstrap-password").run(new DefaultApplicationArguments());
        verify(users).save(argThat(user -> "ROLE_ADMIN".equals(user.getRole())
                && "admin@example.test".equals(user.getEmail())
                && encoder.matches("bootstrap-password", user.getPasswordHash())));
    }

    @Test
    void neverPromotesExistingUserOrAcceptsWeakPassword() {
        var users = mock(UserRepository.class);
        var encoder = new BCryptPasswordEncoder();
        when(users.findByEmail("user@example.test")).thenReturn(Optional.of(new User("user@example.test", "hash", "User", "ROLE_USER")));
        assertThrows(IllegalStateException.class, () -> new AdminBootstrap(users, encoder, "user@example.test", "bootstrap-password").run(new DefaultApplicationArguments()));
        assertThrows(IllegalArgumentException.class, () -> new AdminBootstrap(users, encoder, "admin@example.test", "short").run(new DefaultApplicationArguments()));
        verify(users, never()).save(any());
    }
}
