package com.smarttravel.backend;

import com.fasterxml.jackson.databind.*;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.destination.domain.DestinationReview;
import com.smarttravel.backend.features.destination.repository.DestinationReviewRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.*;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(initializers = TestDatabaseGuard.class)
class SchemaCompatibilityTest {
    @Autowired TestRestTemplate http;
    @Autowired ObjectMapper json;
    @Autowired UserRepository users;
    @Autowired PasswordEncoder encoder;
    @Autowired DestinationReviewRepository reviews;

    private record Account(long id, String token) {}
    private Account account(String role) throws Exception {
        String email = "schema-" + UUID.randomUUID() + "@example.test";
        User user = users.save(new User(email, encoder.encode("schema-test-password"), "Schema traveler", role));
        JsonNode login = call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", "schema-test-password"), null, 200);
        return new Account(user.getId(), login.path("token").asText());
    }
    private JsonNode call(HttpMethod method, String path, Object body, String token, int expected) throws Exception {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        var result = http.exchange("/api/v1" + path, method, new HttpEntity<>(body, headers), String.class);
        assertEquals(expected, result.getStatusCode().value(), () -> path + " " + result.getBody());
        return json.readTree(result.getBody()).path("data");
    }
    private JsonNode destination(String token, Object schedule, boolean priced) throws Exception {
        Map<String, Object> body = new HashMap<>();
        body.put("name", "Schema destination " + UUID.randomUUID());
        body.put("nameEn", "English destination");
        body.put("descriptionEn", "English description");
        body.put("category", "FOOD");
        body.put("latitude", 16.05); body.put("longitude", 108.2);
        body.put("visitDurationMinutes", 60);
        body.put("googleRating", 4.5); body.put("googleReviewCount", 100);
        if (schedule != null) body.put("openingSchedule", schedule);
        if (priced) { body.put("priceMinVnd", 10000); body.put("priceMaxVnd", 20000); }
        return call(HttpMethod.POST, "/destinations", body, token, 201);
    }
    private Map<String, Object> tripInput() {
        return Map.of("title", "Schema trip", "startDate", planningDate(0), "endDate", planningDate(1),
                "travelersCount", 2, "maxBudgetVnd", 5000000, "pace", "balanced", "preferredCategories", List.of("FOOD"));
    }
    private Map<String, Object> activity(long destinationId, int sequence) {
        return Map.of("destinationId", destinationId, "sequenceOrder", sequence, "startTime", "12:00",
                "durationMinutes", 60, "estimatedCostVnd", 1);
    }

    @Test void jsonHoursTranslationsAndGoogleRatingsRoundTrip() throws Exception {
        Account admin = account("ROLE_ADMIN");
        Map<String, Object> week = new LinkedHashMap<>();
        for (int day = 1; day <= 7; day++) week.put(String.valueOf(day), List.of(List.of(480, 690), List.of(810, 1020)));
        Map<String, Object> schedule = Map.of("schema_version", 1, "timezone", "Asia/Ho_Chi_Minh", "week", week);
        JsonNode created = destination(admin.token(), schedule, true);
        JsonNode reopened = call(HttpMethod.GET, "/destinations/" + created.path("id").asLong(), null, null, 200);
        assertEquals(json.valueToTree(schedule), reopened.path("openingSchedule"));
        assertTrue(reopened.path("openingHours").asText().contains("08:00"));
        assertEquals("English description", reopened.path("descriptionEn").asText());
        assertEquals(4.5, reopened.path("googleRating").asDouble());
        assertEquals(100, reopened.path("googleReviewCount").asInt());
        week.put("1", List.of(List.of(480, 720), List.of(600, 900)));
        call(HttpMethod.POST, "/destinations", Map.of("name", "Bad hours", "category", "FOOD",
                "latitude", 16.05, "longitude", 108.2, "openingSchedule", schedule), admin.token(), 400);
    }

    @Test void partialEditKeepsOtherDaysAndIgnoresClientTotals() throws Exception {
        Account admin = account("ROLE_ADMIN"), owner = account("ROLE_USER");
        JsonNode point = destination(admin.token(), null, true);
        JsonNode trip = call(HttpMethod.POST, "/itineraries/generate", tripInput(), owner.token(), 200);
        long id = trip.path("id").asLong();
        long otherDayTotal = trip.path("days").get(1).path("dayCostVnd").asLong();
        Map<String, Object> edit = Map.of("version", trip.path("version").asInt(), "days", List.of(
                Map.of("dayId", trip.path("days").get(0).path("id").asLong(), "items", List.of(activity(point.path("id").asLong(), 1)))));
        JsonNode edited = call(HttpMethod.PUT, "/itineraries/" + id + "/activities", edit, owner.token(), 200);
        assertEquals(40000, edited.path("days").get(0).path("dayCostVnd").asLong());
        assertEquals(otherDayTotal + 40000, edited.path("totalEstimatedCost").asLong());
        assertEquals("FOOD", edited.path("days").get(0).path("items").get(0).path("categoryCode").asText());
        call(HttpMethod.PUT, "/itineraries/" + id + "/activities", edit, owner.token(), 409);
        JsonNode reopened = call(HttpMethod.GET, "/itineraries/" + id, null, owner.token(), 200);
        assertEquals(edited.path("totalEstimatedCost"), reopened.path("totalEstimatedCost"));
    }

    @Test void unknownPricesRemainUnknownAndGoogleStatsStaySeparate() throws Exception {
        Account admin = account("ROLE_ADMIN"), owner = account("ROLE_USER");
        JsonNode point = destination(admin.token(), null, false);
        long pointId = point.path("id").asLong();
        DestinationReview published = new DestinationReview();
        published.setDestinationId(pointId); published.setUserId(owner.id()); published.setRating(3);
        reviews.saveAndFlush(published);
        DestinationReview hidden = new DestinationReview();
        hidden.setDestinationId(pointId); hidden.setUserId(admin.id()); hidden.setRating(5); hidden.setStatus("HIDDEN");
        reviews.saveAndFlush(hidden);
        JsonNode detail = call(HttpMethod.GET, "/destinations/" + pointId, null, null, 200);
        assertEquals(3, detail.path("appRating").asDouble());
        assertEquals(1, detail.path("appReviewCount").asInt());
        assertEquals(4.5, detail.path("googleRating").asDouble());
        assertEquals(100, detail.path("googleReviewCount").asInt());
        JsonNode trip = call(HttpMethod.POST, "/itineraries/generate", tripInput(), owner.token(), 200);
        JsonNode updated = call(HttpMethod.PUT, "/itineraries/" + trip.path("id").asLong() + "/activities",
                Map.of("version", trip.path("version").asInt(), "days", List.of(Map.of("dayId", trip.path("days").get(0).path("id").asLong(),
                        "items", List.of(activity(pointId, 1))))), owner.token(), 200);
        assertFalse(updated.path("costComplete").asBoolean());
        assertEquals("UNKNOWN", updated.path("budgetHealth").asText());
        assertTrue(updated.path("days").get(0).path("items").get(0).path("estimatedCostVnd").isNull());
    }

    @Test void profilePreferencesPersistAndInvalidInputIsRejected() throws Exception {
        Account user = account("ROLE_USER");
        Map<String, Object> profile = Map.of("fullName", "Schema traveler", "language", "en", "defaultBudgetVnd", 2000000,
                "defaultPace", "relaxed", "defaultTransport", "walking", "preferredCategories", List.of("BEACH", "CAFE"));
        call(HttpMethod.PUT, "/auth/profile", profile, user.token(), 200);
        JsonNode loaded = call(HttpMethod.GET, "/auth/profile", null, user.token(), 200).path("travelerProfile");
        assertEquals("en", loaded.path("language").asText());
        assertEquals(2, loaded.path("preferredCategories").size());
        call(HttpMethod.PUT, "/auth/profile", Map.of("fullName", "Schema traveler", "preferredCategories", List.of("HOTEL")), user.token(), 400);
        Map<String, Object> invalidTrip = new HashMap<>(tripInput());
        invalidTrip.put("travelersCount", 11);
        call(HttpMethod.POST, "/itineraries/generate", invalidTrip, user.token(), 400);
        invalidTrip.put("travelersCount", 2); invalidTrip.put("endDate", planningDate(8));
        call(HttpMethod.POST, "/itineraries/generate", invalidTrip, user.token(), 400);
    }

    @Test void omittedOptionalFieldsKeepValuesAndExplicitNullClearsThem() throws Exception {
        Account admin = account("ROLE_ADMIN");
        JsonNode point = destination(admin.token(), null, true);
        String path = "/destinations/" + point.path("id").asLong();
        Map<String, Object> edit = new LinkedHashMap<>();
        edit.put("name", point.path("name").asText()); edit.put("latitude", 16.05); edit.put("longitude", 108.2);
        JsonNode retained = call(HttpMethod.PUT, path, edit, admin.token(), 200);
        assertEquals("English description", retained.path("descriptionEn").asText());
        assertEquals(4.5, retained.path("googleRating").asDouble());
        assertEquals(20000, retained.path("priceMaxVnd").asLong());
        edit.put("googleRating", null); edit.put("rating", 4.9);
        edit.put("googleReviewCount", null); edit.put("reviewCount", 999);
        edit.put("priceMinVnd", null); edit.put("priceMaxVnd", null);
        edit.put("descriptionEn", null); edit.put("openingSchedule", null);
        JsonNode cleared = call(HttpMethod.PUT, path, edit, admin.token(), 200);
        for (String field : List.of("googleRating", "rating", "googleReviewCount", "priceMinVnd", "priceMaxVnd", "descriptionEn", "openingSchedule")) assertTrue(cleared.path(field).isNull(), field);
        JsonNode reopened = call(HttpMethod.GET, path, null, null, 200);
        assertTrue(reopened.path("googleRating").isNull());
        edit.remove("googleRating"); edit.remove("googleReviewCount"); edit.put("rating", 4.2);
        assertEquals(4.2, call(HttpMethod.PUT, path, edit, admin.token(), 200).path("googleRating").asDouble());
    }

    @Test void malformedNestedUpdatesRollbackAndRequireVersion() throws Exception {
        Account admin = account("ROLE_ADMIN"), owner = account("ROLE_USER");
        JsonNode point = destination(admin.token(), null, true);
        JsonNode trip = call(HttpMethod.POST, "/itineraries/generate", tripInput(), owner.token(), 200);
        String path = "/itineraries/" + trip.path("id").asLong();
        long day = trip.path("days").get(0).path("id").asLong();
        int version = trip.path("version").asInt();
        call(HttpMethod.PUT, path + "/activities", Map.of("days", List.of()), owner.token(), 400);
        List<Object> invalid = new ArrayList<>();
        invalid.add(Collections.singletonList(null));
        invalid.add(List.of(Map.of("dayId", day, "items", Collections.singletonList(null))));
        invalid.add(List.of(Map.of("dayId", day, "dayNumber", 2, "items", List.of())));
        invalid.add(List.of(Map.of("dayId", day, "items", List.of(activity(point.path("id").asLong(), 1), activity(point.path("id").asLong(), 1)))));
        invalid.add(List.of(Map.of("dayId", day, "items", List.of()), Map.of("dayId", day, "items", List.of())));
        Map<String, Object> badTime = new HashMap<>(activity(point.path("id").asLong(), 1)); badTime.put("startTime", "25:00");
        invalid.add(List.of(Map.of("dayId", day, "items", List.of(badTime))));
        for (Object days : invalid) call(HttpMethod.PUT, path + "/activities", Map.of("version", version, "days", days), owner.token(), 400);
        JsonNode reopened = call(HttpMethod.GET, path, null, owner.token(), 200);
        assertEquals(trip.path("days"), reopened.path("days"));
        assertEquals(version, reopened.path("version").asInt());
        call(HttpMethod.PUT, path + "/activities", Map.of("version", version, "days", List.of(Map.of("dayId", day, "items", List.of(activity(999999999, 1))))), owner.token(), 404);
    }

    @Test void editPreservesItemIdsAndSnapshotsAcrossReorderReplacementAndRollback() throws Exception {
        var admin = account("ROLE_ADMIN");
        var owner = account("ROLE_USER");
        var a = destination(admin.token(), null, true);
        var week = new LinkedHashMap<String, Object>();
        for (int i = 1; i <= 7; i++) week.put(Integer.toString(i), List.of(List.of(780, 840)));
        var b = call(HttpMethod.POST, "/destinations", Map.of("name", "Điểm thay thế EDIT",
                "category", "CHECKIN", "latitude", 16.06, "longitude", 108.25, "priceMinVnd", 5000,
                "openingSchedule", Map.of("schema_version", 1, "timezone", "Asia/Ho_Chi_Minh", "week", week)),
                admin.token(), 201);
        assertEquals(45, b.path("suggestedVisitDurationMinutes").asInt());
        var trip = call(HttpMethod.POST, "/itineraries/generate", tripInput(), owner.token(), 200);
        String path = "/itineraries/" + trip.path("id").asLong() + "/activities";
        long day = trip.path("days").get(0).path("id").asLong();
        long otherDay = trip.path("days").get(1).path("id").asLong();
        var inserted = call(HttpMethod.PUT, path, Map.of("version", trip.path("version").asInt(),
                "days", List.of(Map.of("dayId", day, "items", List.of(
                        activity(a.path("id").asLong(), 1), activity(a.path("id").asLong(), 2))))), owner.token(), 200);
        var original = inserted.path("days").get(0).path("items");
        long first = original.get(0).path("id").asLong();
        long second = original.get(1).path("id").asLong();
        call(HttpMethod.PUT, "/destinations/" + a.path("id").asLong(), Map.of("name", "Tên catalog mới",
                "latitude", 16.055, "longitude", 108.23, "priceMaxVnd", 80000, "visitDurationMinutes", 120), admin.token(), 200);
        var change = Map.of("dayId", day, "items", List.of(
                Map.of("id", second, "sequenceOrder", 1, "notes", "Giữ ảnh chụp cũ"),
                Map.of("id", first, "destinationId", b.path("id").asLong(), "sequenceOrder", 2)));
        var version = inserted.path("version").asInt();
        call(HttpMethod.PUT, path, Map.of("version", version, "days", List.of(change,
                Map.of("dayId", otherDay, "items", List.of(Map.of("id", first, "sequenceOrder", 1))))), owner.token(), 400);
        var rollback = call(HttpMethod.GET, path.replace("/activities", ""), null, owner.token(), 200);
        assertEquals(inserted.path("days"), rollback.path("days"));
        var updated = call(HttpMethod.PUT, path, Map.of("version", version, "days", List.of(change)), owner.token(), 200);
        var items = updated.path("days").get(0).path("items");
        assertEquals(second, items.get(0).path("id").asLong());
        assertEquals(first, items.get(1).path("id").asLong());
        assertEquals(original.get(1).path("destination"), items.get(0).path("destination"));
        assertEquals("Giữ ảnh chụp cũ", items.get(0).path("notes").asText());
        assertEquals(60, items.get(0).path("durationMinutes").asInt());
        assertEquals(45, items.get(1).path("durationMinutes").asInt());
        assertEquals(40000, items.get(0).path("estimatedCostVnd").asLong());
        assertEquals(10000, items.get(1).path("estimatedCostVnd").asLong());
        assertEquals("HAVERSINE", items.get(1).path("routeSource").asText());
        assertEquals(inserted.path("days").get(1), updated.path("days").get(1));
        assertEquals(updated.path("days").valueStream().mapToLong(d -> d.path("dayCostVnd").asLong()).sum(),
                updated.path("totalEstimatedCost").asLong());
        assertTrue(updated.path("warnings").toString().contains("chồng giờ"));
        assertTrue(updated.path("warnings").toString().contains("ngoài ca mở cửa"));
        assertFalse(updated.path("costComplete").asBoolean());
        call(HttpMethod.PUT, path, Map.of("version", updated.path("version").asInt(), "recalculateAll", true,
                "days", List.of()), owner.token(), 200);
    }

    @Test void archivedDestinationKeepsSnapshotAndItsOriginalId() throws Exception {
        Account admin = account("ROLE_ADMIN"), owner = account("ROLE_USER");
        JsonNode point = destination(admin.token(), null, false);
        JsonNode trip = call(HttpMethod.POST, "/itineraries/generate", tripInput(), owner.token(), 200);
        String path = "/itineraries/" + trip.path("id").asLong();
        long day = trip.path("days").get(0).path("id").asLong();
        JsonNode edited = call(HttpMethod.PUT, path + "/activities", Map.of("version", trip.path("version").asInt(), "days", List.of(Map.of("dayId", day, "items", List.of(activity(point.path("id").asLong(), 1))))), owner.token(), 200);
        call(HttpMethod.DELETE, "/destinations/" + point.path("id").asLong(), null, admin.token(), 200);
        JsonNode reopened = call(HttpMethod.GET, path, null, owner.token(), 200);
        JsonNode item = reopened.path("days").get(0).path("items").get(0);
        assertEquals(point.path("id"), item.path("destination").path("id"));
        assertEquals(point.path("name"), item.path("destination").path("name"));
        assertTrue(reopened.path("days").get(0).path("totalDistanceKm").isNull());
        Map<String, Object> snapshot = new HashMap<>(); snapshot.put("id", item.path("id").asLong()); snapshot.put("destinationId", point.path("id").asLong()); snapshot.put("sequenceOrder", 1);
        JsonNode saved = call(HttpMethod.PUT, path + "/activities", Map.of("version", edited.path("version").asInt(), "days", List.of(Map.of("dayId", day, "items", List.of(snapshot)))), owner.token(), 200);
        assertEquals(item.path("destination"), saved.path("days").get(0).path("items").get(0).path("destination"));
    }

    @Test void legacyEndpointsReturnValidationAndNotFoundEnvelopes() throws Exception {
        Account admin = account("ROLE_ADMIN");
        call(HttpMethod.POST, "/categories", Map.of("name", "Invalid", "status", "UNKNOWN"), admin.token(), 400);
        call(HttpMethod.PUT, "/categories/999999999", Map.of("name", "Missing"), admin.token(), 404);
        call(HttpMethod.GET, "/destinations/not-an-id", null, null, 400);
        call(HttpMethod.POST, "/destinations", Map.of("name", "Bad status", "category", "FOOD", "latitude", 16.05, "longitude", 108.2, "status", "DELETED"), admin.token(), 400);
    }
    private static String planningDate(int days) {
        return java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(days + 1L).toString();
    }
}
