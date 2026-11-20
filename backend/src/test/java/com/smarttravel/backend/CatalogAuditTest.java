package com.smarttravel.backend;

import com.fasterxml.jackson.databind.*;
import com.smarttravel.backend.features.audit.service.AuditService;
import com.smarttravel.backend.features.audit.repository.AuditLogRepository;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.destination.domain.DestinationReview;
import com.smarttravel.backend.features.destination.repository.DestinationReviewRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.*;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(initializers = TestDatabaseGuard.class)
class CatalogAuditTest {
    @Autowired TestRestTemplate http;
    @Autowired ObjectMapper json;
    @Autowired UserRepository users;
    @Autowired PasswordEncoder encoder;
    @Autowired JdbcTemplate db;
    @Autowired AuditLogRepository logs;
    @Autowired DestinationReviewRepository reviews;
    @Autowired com.smarttravel.backend.features.category.repository.CategoryRepository categories;
    @Autowired com.smarttravel.backend.features.destination.repository.DestinationRepository destinations;
    @MockitoSpyBean AuditService audit;

    private record Account(long id, String token) {}
    private Account account(String role) throws Exception {
        String email = "audit-" + UUID.randomUUID() + "@example.test";
        User user = users.save(new User(email, encoder.encode("test-audit-password"), "Audit actor", role));
        return new Account(user.getId(), call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", "test-audit-password"), null, 200).path("token").asText());
    }
    private JsonNode call(HttpMethod method, String path, Object body, String token, int status) throws Exception {
        HttpHeaders headers = new HttpHeaders(); headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        var result = http.exchange("/api/v1" + path, method, new HttpEntity<>(body, headers), String.class);
        assertEquals(status, result.getStatusCode().value(), result.getBody());
        JsonNode envelope = json.readTree(result.getBody());
        assertEquals(status < 400, envelope.path("success").asBoolean());
        return envelope.path("data");
    }
    private Map<String, Object> pointInput() {
        return new HashMap<>(Map.of("name", "Catalog " + UUID.randomUUID(), "category", "FOOD", "latitude", 16.05,
                "longitude", 108.2, "nameEn", "English name", "descriptionEn", "English description", "priceMaxVnd", 20000,
                "imageUrl", "https://example.test/cover.png", "subImages", List.of("https://example.test/sub.png")));
    }
    private long categoryId(String code, String token) throws Exception {
        for (JsonNode item : call(HttpMethod.GET, "/categories", null, token, 200)) if (code.equals(item.path("code").asText())) return item.path("id").asLong();
        throw new AssertionError("Missing category " + code);
    }

    @Test void metadataRoundTripsAndSoftArchivePreservesReviews() throws Exception {
        Account admin = account("ROLE_ADMIN"), owner = account("ROLE_USER");
        Map<String, Object> body = pointInput();
        Map<String, Object> week = new LinkedHashMap<>();
        for (int day = 1; day <= 7; day++) week.put(String.valueOf(day), List.of(List.of(480, 690), List.of(810, 1020)));
        body.put("openingSchedule", Map.of("schema_version", 1, "timezone", "Asia/Ho_Chi_Minh", "week", week));
        body.put("visitDurationMinutes", 60);
        JsonNode created = call(HttpMethod.POST, "/destinations", body, admin.token(), 201);
        long id = created.path("id").asLong();
        DestinationReview review = new DestinationReview(); review.setDestinationId(id); review.setUserId(owner.id()); review.setRating(4); reviews.saveAndFlush(review);
        call(HttpMethod.DELETE, "/destinations/" + id, null, admin.token(), 200);
        call(HttpMethod.GET, "/destinations/" + id, null, null, 404);
        JsonNode hidden = call(HttpMethod.GET, "/destinations/" + id, null, admin.token(), 200);
        assertEquals("INACTIVE", hidden.path("status").asText()); assertEquals(1, hidden.path("appReviewCount").asInt());
        assertEquals(created.path("openingSchedule"), hidden.path("openingSchedule"));
        assertEquals(created.path("subImages"), hidden.path("subImages")); assertEquals(60, hidden.path("visitDurationMinutes").asInt());
        call(HttpMethod.PUT, "/destinations/" + id, Map.of("name", created.path("name").asText(), "latitude", 16.05, "longitude", 108.2, "status", "ACTIVE"), admin.token(), 200);
        JsonNode restored = call(HttpMethod.GET, "/destinations/" + id, null, null, 200);
        assertEquals("English description", restored.path("descriptionEn").asText()); assertEquals(4, restored.path("appRating").asInt());
        assertEquals(admin.id(), db.queryForObject("SELECT user_id FROM audit_logs WHERE entity_type='DESTINATION' AND entity_id=? AND action='ARCHIVE' ORDER BY id DESC LIMIT 1", Long.class, id));
    }

    @Test void codesAreImmutableAndLegacyOrOutOfScopePayloadsNeverFallback() throws Exception {
        Account admin = account("ROLE_ADMIN"), owner = account("ROLE_USER");
        long food = categoryId("FOOD", admin.token());
        call(HttpMethod.POST, "/categories", Map.of("name", "Hotel", "code", "HOTEL"), admin.token(), 400);
        call(HttpMethod.POST, "/categories", Map.of("name", "Food duplicate", "code", "FOOD", "slug", "duplicate-" + UUID.randomUUID()), admin.token(), 409);
        call(HttpMethod.PUT, "/categories/" + food, Map.of("name", "Wrong code", "code", "BEACH"), admin.token(), 400);
        for (String legacy : List.of("HOTEL", "Tham quan", "UNKNOWN", "Food")) {
            Map<String, Object> body = pointInput(); body.put("category", legacy);
            call(HttpMethod.POST, "/destinations", body, admin.token(), 400);
            call(HttpMethod.PUT, "/auth/profile", Map.of("fullName", "Traveler", "preferredCategories", List.of(legacy)), owner.token(), 400);
            call(HttpMethod.POST, "/itineraries/generate", Map.of("title", "Legacy", "startDate", planningDate(0), "endDate", planningDate(0), "travelersCount", 1, "maxBudgetVnd", 100000, "pace", "balanced", "preferredCategories", List.of(legacy)), owner.token(), 400);
        }
        Map<String, Object> mismatch = pointInput(); mismatch.put("categoryId", food); mismatch.put("category", "CAFE");
        call(HttpMethod.POST, "/destinations", mismatch, admin.token(), 400);
        call(HttpMethod.GET, "/destinations?category=HOTEL", null, null, 400);
        Map<String, Object> unsafe = pointInput(); unsafe.put("imageUrl", "/uploads/../secret.png");
        call(HttpMethod.POST, "/destinations", unsafe, admin.token(), 400);
        unsafe = pointInput(); unsafe.put("subImages", Collections.nCopies(11, "https://example.test/a.png"));
        call(HttpMethod.POST, "/destinations", unsafe, admin.token(), 400);
        assertEquals("FOOD", call(HttpMethod.GET, "/categories/" + food, null, admin.token(), 200).path("code").asText());
    }

    @Test void hiddenCategoryRejectsNewSelectionsAndMetadataCanBeClearedOrRestored() throws Exception {
        Account admin = account("ROLE_ADMIN");
        long id = categoryId("FOOD", admin.token());
        String path = "/categories/" + id;
        JsonNode original = call(HttpMethod.GET, path, null, admin.token(), 200);
        JsonNode point = call(HttpMethod.POST, "/destinations", pointInput(), admin.token(), 201);
        try {
            call(HttpMethod.PUT, path, Map.of("name", original.path("name").asText(), "nameEn", "English category", "description", "Description", "imageUrl", "https://example.test/category.png"), admin.token(), 200);
            JsonNode retained = call(HttpMethod.PUT, path, Map.of("name", original.path("name").asText()), admin.token(), 200);
            assertEquals("English category", retained.path("nameEn").asText());
            Map<String, Object> clear = new HashMap<>(); clear.put("name", original.path("name").asText());
            for (String field : List.of("nameEn", "description", "imageUrl")) clear.put(field, null);
            JsonNode cleared = call(HttpMethod.PUT, path, clear, admin.token(), 200);
            for (String field : List.of("nameEn", "description", "imageUrl")) assertTrue(cleared.path(field).isNull());
            call(HttpMethod.DELETE, path, null, admin.token(), 200);
            call(HttpMethod.POST, "/destinations", pointInput(), admin.token(), 400);
            call(HttpMethod.GET, path, null, null, 404);
            call(HttpMethod.GET, "/destinations/" + point.path("id").asLong(), null, null, 404);
            JsonNode saved = call(HttpMethod.PUT, "/destinations/" + point.path("id").asLong(), Map.of("name", "Edited under hidden category", "latitude", 16.05, "longitude", 108.2), admin.token(), 200);
            assertEquals(id, saved.path("categoryId").asLong());
            call(HttpMethod.DELETE, "/destinations/" + point.path("id").asLong(), null, admin.token(), 200);
            call(HttpMethod.PUT, "/destinations/" + point.path("id").asLong(), Map.of("name", "Restore blocked", "latitude", 16.05, "longitude", 108.2, "status", "ACTIVE"), admin.token(), 409);
        } finally {
            Map<String, Object> restore = new HashMap<>(); restore.put("name", original.path("name").asText()); restore.put("status", original.path("status").asText());
            for (String field : List.of("nameEn", "description", "imageUrl")) restore.put(field, original.path(field).isNull() ? null : original.path(field).asText());
            call(HttpMethod.PUT, path, restore, admin.token(), 200);
        }
    }

    @Test void legacyHotelRowsStayAdminReadableButCannotEnterPublicOrNewWrites() throws Exception {
        Account admin = account("ROLE_ADMIN");
        var existing = categories.findByCode("HOTEL");
        var hotel = existing.orElseGet(() -> {
            var c = new com.smarttravel.backend.features.category.domain.Category(); c.setCode("HOTEL"); c.setSlug("legacy-hotel"); c.setName("Legacy hotel"); return categories.saveAndFlush(c);
        });
        var legacy = new com.smarttravel.backend.features.destination.domain.Destination();
        legacy.setName("Legacy hotel fixture"); legacy.setCategory(hotel); legacy.setLatitude(new java.math.BigDecimal("16.05")); legacy.setLongitude(new java.math.BigDecimal("108.2"));
        legacy = destinations.saveAndFlush(legacy);
        try {
            call(HttpMethod.GET, "/categories/" + hotel.getId(), null, admin.token(), 200);
            call(HttpMethod.GET, "/destinations/" + legacy.getId(), null, admin.token(), 200);
            call(HttpMethod.GET, "/categories/" + hotel.getId(), null, null, 404);
            call(HttpMethod.GET, "/destinations/" + legacy.getId(), null, null, 404);
            for (JsonNode point : call(HttpMethod.GET, "/destinations", null, null, 200)) assertNotEquals(legacy.getId(), point.path("id").asLong());
            Map<String, Object> body = pointInput(); body.remove("category"); body.put("categoryId", hotel.getId());
            call(HttpMethod.POST, "/destinations", body, admin.token(), 400);
            call(HttpMethod.PUT, "/destinations/" + legacy.getId(), body, admin.token(), 400);
        } finally {
            destinations.deleteById(legacy.getId());
            if (existing.isEmpty()) categories.deleteById(hotel.getId());
        }
    }

    @Test void auditFailureRollsBackCatalogAccountAndModerationWrites() throws Exception {
        Account admin = account("ROLE_ADMIN"), owner = account("ROLE_USER");
        JsonNode point = call(HttpMethod.POST, "/destinations", pointInput(), admin.token(), 201);
        long id = point.path("id").asLong();
        DestinationReview review = new DestinationReview(); review.setDestinationId(id); review.setUserId(owner.id()); review.setRating(3); reviews.saveAndFlush(review);
        long count = logs.count();
        AuditService target = org.springframework.test.util.AopTestUtils.getUltimateTargetObject(audit);
        doAnswer(invocation -> { invocation.callRealMethod(); throw new IllegalStateException("audit unavailable after flush"); })
                .when(target).record(anyString(), anyLong(), anyString(), anyMap());
        call(HttpMethod.PUT, "/destinations/" + id, Map.of("name", "Should rollback", "latitude", 16.05, "longitude", 108.2), admin.token(), 500);
        call(HttpMethod.PUT, "/admin/reviews/" + review.getId() + "/status", Map.of("status", "HIDDEN"), admin.token(), 500);
        call(HttpMethod.PUT, "/admin/users/" + owner.id(), Map.of("fullName", "Should rollback"), admin.token(), 500);
        assertEquals(point.path("name").asText(), db.queryForObject("SELECT name FROM destinations WHERE id=?", String.class, id));
        assertEquals("PUBLISHED", db.queryForObject("SELECT status FROM destination_reviews WHERE id=?", String.class, review.getId()));
        assertEquals("Audit actor", db.queryForObject("SELECT full_name FROM users WHERE id=?", String.class, owner.id()));
        assertEquals(count, logs.count());
    }

    @Test void moderationAndAccountEventsUseServerActorWithoutSecrets() throws Exception {
        Account admin = account("ROLE_ADMIN"), owner = account("ROLE_USER");
        JsonNode point = call(HttpMethod.POST, "/destinations", pointInput(), admin.token(), 201);
        long id = point.path("id").asLong();
        DestinationReview review = new DestinationReview(); review.setDestinationId(id); review.setUserId(owner.id()); review.setRating(3); reviews.saveAndFlush(review);
        call(HttpMethod.PUT, "/admin/reviews/" + review.getId() + "/status", Map.of("status", "HIDDEN", "userId", owner.id()), owner.token(), 403);
        call(HttpMethod.PUT, "/admin/reviews/" + review.getId() + "/status", Map.of("status", "HIDDEN", "userId", owner.id()), admin.token(), 200);
        assertEquals(0, call(HttpMethod.GET, "/destinations/" + id, null, null, 200).path("appReviewCount").asInt());
        String secret = "NeverLogThisSecret123!";
        call(HttpMethod.PUT, "/admin/users/" + owner.id(), Map.of("password", secret, "fullName", "Updated actor", "token", secret), admin.token(), 200);
        assertEquals(admin.id(), db.queryForObject("SELECT user_id FROM audit_logs WHERE entity_type='REVIEW' AND entity_id=? ORDER BY id DESC LIMIT 1", Long.class, review.getId()));
        String details = db.queryForObject("SELECT details FROM audit_logs WHERE entity_type='USER' AND entity_id=? ORDER BY id DESC LIMIT 1", String.class, owner.id());
        assertFalse(details.contains(secret)); assertFalse(details.toLowerCase().contains("password")); assertFalse(details.contains("token")); assertFalse(details.contains("$2"));
        call(HttpMethod.PUT, "/admin/reviews/" + review.getId() + "/status", Map.of("status", "INVALID"), admin.token(), 400);
    }
    private static String planningDate(int days) {
        return java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(days + 1L).toString();
    }
}
