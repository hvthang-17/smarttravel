package com.smarttravel.backend;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarttravel.backend.features.audit.domain.AuditLog;
import com.smarttravel.backend.features.audit.repository.AuditLogRepository;
import com.smarttravel.backend.features.audit.service.AuditService;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.category.domain.Category;
import com.smarttravel.backend.features.category.dto.CreateCategoryRequest;
import com.smarttravel.backend.features.category.repository.CategoryRepository;
import com.smarttravel.backend.features.category.service.*;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.util.ReflectionTestUtils;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CatalogPolicyTest {
    @Test void auditOnlyStoresAllowlistedMachineMetadataAndServerIdentity() {
        var logs = mock(AuditLogRepository.class); var users = mock(UserRepository.class);
        User actor = new User("server@example.test", "encoded-secret", "Server actor", "ROLE_ADMIN");
        ReflectionTestUtils.setField(actor, "id", 15L);
        when(users.findByEmail(actor.getEmail())).thenReturn(Optional.of(actor));
        SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(actor.getEmail(), "ignored", List.of()));
        try {
            new AuditService(logs, users, new ObjectMapper()).record("USER", 17L, "UPDATE", Map.of(
                    "fields", List.of("fullName", "password", "passwordHash", "token"), "password", "never-log", "nested", Map.of("token", "never-log"),
                    "actorName", "Spoofed", "userId", 999L, "status", "ACTIVE", "role", "never-log"));
            var captured = ArgumentCaptor.forClass(AuditLog.class); verify(logs).saveAndFlush(captured.capture());
            var log = captured.getValue();
            assertEquals(15L, log.getUserId()); assertEquals("Server actor", log.getActorName());
            assertEquals("{\"fields\":[\"fullName\"],\"status\":\"ACTIVE\"}", log.getDetails());
            assertFalse(log.getDetails().contains("never-log"));
        } finally { SecurityContextHolder.clearContext(); }
    }

    @Test void categoryCreationUsesExactCodeAndRejectsDuplicateInsteadOfAppendingSuffix() {
        var categories = mock(CategoryRepository.class); var audit = mock(AuditService.class);
        when(categories.save(any(Category.class))).thenAnswer(call -> { Category c = call.getArgument(0); ReflectionTestUtils.setField(c, "id", 91L); return c; });
        var service = new CategoryService(categories, mock(DestinationRepository.class), audit);
        var input = new CreateCategoryRequest(); input.setName("Ẩm thực"); input.setCode("FOOD");
        assertEquals("FOOD", service.createCategory(input).getCode());
        verify(audit).record(eq("CATEGORY"), eq(91L), eq("CREATE"), anyMap());
        when(categories.existsByCode("FOOD")).thenReturn(true);
        assertThrows(com.smarttravel.backend.common.ResourceConflictException.class, () -> service.createCategory(input));
        input.setCode("HOTEL"); assertThrows(IllegalArgumentException.class, () -> service.createCategory(input));
        verify(categories, times(1)).save(any());
    }

    @Test void catalogImagesAndPreferencesRejectInvalidOrHiddenInputs() {
        assertNull(CatalogImages.image("", "Ảnh"));
        assertEquals("/uploads/categories/abc.png", CatalogImages.image("/uploads/categories/abc.png", "Ảnh"));
        for (String url : List.of("javascript:alert(1)", "data:image/png;base64,abc", "/uploads/../secret.png", "https://user:secret@example.test/a.png")) assertThrows(IllegalArgumentException.class, () -> CatalogImages.image(url, "Ảnh"));
        assertThrows(IllegalArgumentException.class, () -> CatalogImages.gallery(Collections.nCopies(11, "https://example.test/a.png")));
        assertThrows(IllegalArgumentException.class, () -> CatalogImages.gallery(Arrays.asList((String) null)));
        var categories = mock(CategoryRepository.class); var category = new Category(); category.setCode("FOOD"); category.setStatus("INACTIVE");
        when(categories.findByCode("FOOD")).thenReturn(Optional.of(category));
        var policy = new CatalogPolicy(categories);
        assertThrows(IllegalArgumentException.class, () -> policy.preferences(List.of("FOOD")));
        assertThrows(IllegalArgumentException.class, () -> policy.preferences(List.of("HOTEL")));
        category.setStatus("ACTIVE"); assertEquals(List.of("FOOD"), policy.preferences(List.of("FOOD")));
        assertThrows(IllegalArgumentException.class, () -> policy.preferences(List.of("FOOD", "FOOD")));
    }
}
