package com.smarttravel.backend;

import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.dto.AdminUpdateUserRequest;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.auth.service.AdminUserService;
import com.smarttravel.backend.features.itinerary.repository.ItineraryRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AdminAccountProtectionTest {
    @AfterEach void clearAuthentication() { SecurityContextHolder.clearContext(); }

    @Test
    void lastActiveAdminCannotBeLockedDeletedOrDemoted() {
        var users = mock(UserRepository.class);
        var service = new AdminUserService(users, mock(ItineraryRepository.class), new BCryptPasswordEncoder());
        var admin = new User("last@example.test", "hash", "Last admin", "ROLE_ADMIN");
        when(users.findById(1L)).thenReturn(Optional.of(admin));
        when(users.lockAdministrators()).thenReturn(List.of(admin));
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken("other@example.test", null, List.of()));
        assertThrows(IllegalArgumentException.class, () -> service.updateUserStatus(1L, "LOCKED"));
        assertThrows(IllegalArgumentException.class, () -> service.deleteUser(1L, "other@example.test"));
        var request = new AdminUpdateUserRequest();
        request.setFullName("Last admin");
        request.setRole("ROLE_USER");
        assertThrows(IllegalArgumentException.class, () -> service.updateUser(1L, request));
        verify(users, never()).delete(any());
        verify(users, never()).save(any());
    }
}
