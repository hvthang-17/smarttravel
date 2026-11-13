package com.smarttravel.backend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(initializers = TestDatabaseGuard.class)
class SecurityIntegrationTest {
    @Autowired private TestRestTemplate http;
    @Autowired private ObjectMapper mapper;
    @Autowired private UserRepository users;
    @Autowired private PasswordEncoder encoder;

    private record Account(Long id, String email, String password, String token) {}

    private Account account(String role) throws Exception {
        String email = "security-" + UUID.randomUUID() + "@example.test";
        String password = UUID.randomUUID().toString();
        User user = users.save(new User(email, encoder.encode(password), "Security test", role));
        JsonNode login = call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", password), null, 200);
        return new Account(user.getId(), email, password, login.path("data").path("token").asText());
    }

    @Test
    void publicRegistrationCannotChooseAdminAndNormalizesEmail() throws Exception {
        String email = "register-" + UUID.randomUUID() + "@example.test";
        JsonNode result = call(HttpMethod.POST, "/auth/register", Map.of("email", "  " + email.toUpperCase(Locale.ROOT) + "  ",
                "password", "secure-test-password", "fullName", "Traveler", "role", "ROLE_ADMIN"), null, 200);
        assertEquals("ROLE_USER", result.path("data").path("role").asText());
        assertEquals(email, result.path("data").path("email").asText());
        call(HttpMethod.POST, "/auth/register", Map.of("email", email, "password", "secure-test-password", "fullName", "Duplicate"), null, 400);
        call(HttpMethod.POST, "/auth/register", Map.of("email", "short-" + email, "password", "1234567", "fullName", "Short"), null, 400);
        call(HttpMethod.POST, "/auth/login", Map.of("email", email.toUpperCase(Locale.ROOT), "password", "secure-test-password"), null, 200);
    }

    @Test
    void anonymousAndUserCannotWriteContentOrManageAccounts() throws Exception {
        Account user = account("ROLE_USER");
        for (String token : Arrays.asList(null, user.token())) {
            int status = token == null ? 401 : 403;
            for (String path : List.of("/destinations", "/categories", "/admin/users")) {
                call(HttpMethod.POST, path, Map.of(), token, status);
                call(HttpMethod.PUT, path + "/1", Map.of(), token, status);
                call(HttpMethod.DELETE, path + "/1", null, token, status);
            }
            call(HttpMethod.POST, "/destinations/upload-image", Map.of(), token, status);
            call(HttpMethod.POST, "/destinations/upload-images", Map.of(), token, status);
            call(HttpMethod.POST, "/categories/upload-image", Map.of(), token, status);
            call(HttpMethod.GET, "/admin/users", null, token, status);
            call(HttpMethod.GET, "/admin/itineraries", null, token, status);
        }
        call(HttpMethod.GET, "/destinations", null, null, 200);
        call(HttpMethod.GET, "/categories", null, null, 200);
        assertEquals("ok", call(HttpMethod.GET, "/health", null, null, 200).path("status").asText());
        call(HttpMethod.GET, "/auth/profile", null, "invalid.jwt.token", 401);
    }

    @Test
    void onlyAdminCanReadHiddenContentAndUseRealAdminEndpoints() throws Exception {
        Account admin = account("ROLE_ADMIN");
        Account user = account("ROLE_USER");
        JsonNode category = call(HttpMethod.POST, "/categories", Map.of("name", "Hidden " + UUID.randomUUID(),
                "status", "INACTIVE"), admin.token(), 201).path("data");
        long categoryId = category.path("id").asLong();
        JsonNode destination = call(HttpMethod.POST, "/destinations", Map.of("name", "Hidden destination",
                "categoryId", categoryId, "latitude", 16.05, "longitude", 108.2, "status", "INACTIVE"), admin.token(), 201).path("data");
        long destinationId = destination.path("id").asLong();
        long activeInHiddenCategory = call(HttpMethod.POST, "/destinations", Map.of("name", "Active point in hidden category",
                "categoryId", categoryId, "latitude", 16.05, "longitude", 108.2, "status", "ACTIVE"), admin.token(), 201)
                .path("data").path("id").asLong();
        for (String token : Arrays.asList(null, user.token())) {
            call(HttpMethod.GET, "/destinations?status=ALL", null, token, 403);
            call(HttpMethod.GET, "/categories?status=INACTIVE", null, token, 403);
            call(HttpMethod.GET, "/destinations/" + destinationId, null, token, 404);
            call(HttpMethod.GET, "/destinations/" + activeInHiddenCategory, null, token, 404);
            call(HttpMethod.GET, "/categories/" + categoryId, null, token, 404);
            JsonNode publicCategories = call(HttpMethod.GET, "/categories", null, token, 200).path("data");
            for (JsonNode item : publicCategories) assertNotEquals(categoryId, item.path("id").asLong());
        }
        call(HttpMethod.GET, "/destinations/" + destinationId, null, admin.token(), 200);
        call(HttpMethod.GET, "/destinations?status=ALL", null, admin.token(), 200);
        call(HttpMethod.GET, "/categories/" + categoryId, null, admin.token(), 200);
        call(HttpMethod.GET, "/admin/users", null, admin.token(), 200);
        call(HttpMethod.GET, "/admin/itineraries", null, admin.token(), 200);
        JsonNode trip = call(HttpMethod.POST, "/itineraries/generate", Map.of("title", "Visibility test",
                "startDate", "2026-12-01", "endDate", "2026-12-01", "travelersCount", 1,
                "maxBudgetVnd", 1000000, "pace", "balanced", "preferredCategories", List.of(category.path("code").asText())),
                user.token(), 200).path("data");
        for (JsonNode day : trip.path("days")) {
            for (JsonNode item : day.path("items")) {
                assertNotEquals(destinationId, item.path("destination").path("id").asLong());
                assertNotEquals(activeInHiddenCategory, item.path("destination").path("id").asLong());
            }
        }
        call(HttpMethod.PUT, "/itineraries/" + trip.path("id").asLong() + "/activities", Map.of("days", List.of(
                Map.of("dayId", trip.path("days").get(0).path("id").asLong(), "items", List.of(
                        Map.of("destinationId", activeInHiddenCategory, "sequenceOrder", 1, "startTime", "09:00", "durationMinutes", 60))))),
                user.token(), 404);
    }

    @Test
    void anotherTravelerCannotReadEditOrSharePrivateItinerary() throws Exception {
        Account owner = account("ROLE_USER");
        Account stranger = account("ROLE_USER");
        JsonNode trip = call(HttpMethod.POST, "/itineraries/generate", Map.of("title", "Private",
                "startDate", "2026-12-01", "endDate", "2026-12-01", "travelersCount", 1,
                "maxBudgetVnd", 1000000, "pace", "balanced"), owner.token(), 200).path("data");
        String path = "/itineraries/" + trip.path("id").asLong();
        call(HttpMethod.GET, path, null, stranger.token(), 403);
        call(HttpMethod.PUT, path + "/activities", Map.of("days", List.of(
                Map.of("dayId", trip.path("days").get(0).path("id").asLong(), "items", List.of()))), stranger.token(), 403);
        call(HttpMethod.POST, path + "/share", Map.of(), stranger.token(), 403);
        call(HttpMethod.GET, path, null, owner.token(), 200);
        String share = call(HttpMethod.POST, path + "/share", Map.of(), owner.token(), 200)
                .path("data").path("shareToken").asText();
        call(HttpMethod.GET, "/itineraries/shared/" + share, null, null, 200);
    }

    @Test
    void lockingRevokesExistingTokensEvenAfterUnlockAndSelfLockIsRejected() throws Exception {
        Account admin = account("ROLE_ADMIN");
        Account user = account("ROLE_USER");
        call(HttpMethod.PATCH, "/admin/users/" + user.id() + "/status", Map.of("status", "LOCKED"), admin.token(), 200);
        call(HttpMethod.GET, "/auth/profile", null, user.token(), 401);
        JsonNode lockedLogin = call(HttpMethod.POST, "/auth/login", Map.of("email", user.email(), "password", user.password()), null, 401);
        JsonNode absentLogin = call(HttpMethod.POST, "/auth/login", Map.of("email", "absent-" + user.email(), "password", user.password()), null, 401);
        assertEquals(lockedLogin.path("message"), absentLogin.path("message"));
        call(HttpMethod.PATCH, "/admin/users/" + user.id() + "/status", Map.of("status", "ACTIVE"), admin.token(), 200);
        call(HttpMethod.GET, "/auth/profile", null, user.token(), 401);
        String fresh = call(HttpMethod.POST, "/auth/login", Map.of("email", user.email(), "password", user.password()), null, 200)
                .path("data").path("token").asText();
        call(HttpMethod.GET, "/auth/profile", null, fresh, 200);
        call(HttpMethod.PATCH, "/admin/users/" + admin.id() + "/status", Map.of("status", "LOCKED"), admin.token(), 400);
        call(HttpMethod.DELETE, "/admin/users/" + admin.id(), null, admin.token(), 400);
        call(HttpMethod.PUT, "/admin/users/" + admin.id(), Map.of("fullName", "Admin", "role", "ROLE_USER"), admin.token(), 400);
    }

    @Test
    void adminCanManageUsersAndPasswordChangesRevokeOldSessions() throws Exception {
        Account admin = account("ROLE_ADMIN");
        String email = "managed-" + UUID.randomUUID() + "@example.test";
        long id = call(HttpMethod.POST, "/admin/users", Map.of("email", email, "password", "initial-password",
                "fullName", "Managed", "role", "ROLE_USER", "status", "ACTIVE"), admin.token(), 200)
                .path("data").path("id").asLong();
        String oldToken = call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", "initial-password"), null, 200)
                .path("data").path("token").asText();
        call(HttpMethod.PUT, "/admin/users/" + id, Map.of("fullName", "Updated", "password", "replacement-password"), admin.token(), 200);
        call(HttpMethod.GET, "/auth/profile", null, oldToken, 401);
        call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", "initial-password"), null, 401);
        String newToken = call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", "replacement-password"), null, 200)
                .path("data").path("token").asText();
        call(HttpMethod.GET, "/auth/profile", null, newToken, 200);
        call(HttpMethod.PATCH, "/admin/users/" + id + "/status", Map.of("status", "INVALID"), admin.token(), 400);
        call(HttpMethod.PUT, "/admin/users/" + id, Map.of("fullName", "Updated", "role", "ROLE_SUPERUSER"), admin.token(), 400);
        call(HttpMethod.DELETE, "/admin/users/" + id, null, admin.token(), 200);
        call(HttpMethod.GET, "/auth/profile", null, newToken, 401);
    }

    @Test
    void corsAllowsConfiguredOriginsAndRejectsUnknownOrigins() throws Exception {
        HttpHeaders headers = new HttpHeaders();
        headers.setOrigin("http://localhost:5173");
        headers.setAccessControlRequestMethod(HttpMethod.POST);
        ResponseEntity<String> allowed = http.exchange("/api/v1/destinations", HttpMethod.OPTIONS, new HttpEntity<>(headers), String.class);
        assertEquals("http://localhost:5173", allowed.getHeaders().getAccessControlAllowOrigin());
        headers.setOrigin("https://untrusted.example");
        ResponseEntity<String> denied = http.exchange("/api/v1/destinations", HttpMethod.OPTIONS, new HttpEntity<>(headers), String.class);
        assertEquals(HttpStatus.FORBIDDEN, denied.getStatusCode());
        assertNull(denied.getHeaders().getAccessControlAllowOrigin());
        assertFalse(mapper.readTree(denied.getBody()).path("success").asBoolean(true));
    }

    private JsonNode call(HttpMethod method, String path, Object body, String token, int expected) throws Exception {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        ResponseEntity<String> response = http.exchange("/api/v1" + path, method, new HttpEntity<>(body, headers), String.class);
        assertEquals(expected, response.getStatusCode().value(), () -> method + " " + path);
        JsonNode json = mapper.readTree(response.getBody());
        if (expected >= 400) {
            assertFalse(json.path("success").asBoolean(true));
            assertTrue(json.hasNonNull("message"));
            assertTrue(json.hasNonNull("timestamp"));
        }
        return json;
    }
}
