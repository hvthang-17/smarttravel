package com.smarttravel.backend;

import com.fasterxml.jackson.databind.*;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.itinerary.service.DraftCleanup;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.*;
import java.time.*;
import java.util.*;
import java.util.concurrent.*;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(initializers = TestDatabaseGuard.class)
class TripPlanningTest {
    @Autowired TestRestTemplate http;
    @Autowired ObjectMapper json;
    @Autowired UserRepository users;
    @Autowired PasswordEncoder passwords;
    @Autowired JdbcTemplate db;
    @Autowired DraftCleanup cleanup;

    private record Account(long id, String token) {}

    private Account account(String role) throws Exception {
        var email = "trip-" + UUID.randomUUID() + "@example.test";
        var password = "trip-testing-123!";
        var user = users.save(new User(email, passwords.encode(password), "Trip tester", role));
        var token = call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", password), null, 200)
                .path("token").asText();
        return new Account(user.getId(), token);
    }

    private JsonNode call(HttpMethod method, String path, Object payload, String token, int expected) throws Exception {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        var result = http.exchange("/api/v1" + path, method, new HttpEntity<>(payload, headers), String.class);
        assertEquals(expected, result.getStatusCode().value(), result.getBody());
        return json.readTree(result.getBody()).path("data");
    }

    private LocalDate today() { return LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")); }

    private Map<String, Object> input() {
        return new LinkedHashMap<>(Map.of("title", "Trip draft", "startDate", today().plusDays(1).toString(),
                "endDate", today().plusDays(3).toString(), "travelersCount", 10, "maxBudgetVnd", 2_000_000,
                "pace", "balanced", "transport", "taxi", "preferredCategories", List.of("FOOD"),
                "generationKey", UUID.randomUUID().toString()));
    }

    private JsonNode generate(Map<String, Object> input, Account owner, int expected) throws Exception {
        return call(HttpMethod.POST, "/itineraries/generate", input, owner.token(), expected);
    }

    private long point(Account admin, String category, String name) throws Exception {
        return call(HttpMethod.POST, "/destinations", Map.of("name", name, "category", category, "latitude", 16.05,
                "longitude", 108.21, "priceMinVnd", 40_000, "priceMaxVnd", 60_000), admin.token(), 201).path("id").asLong();
    }

    private Set<Long> activityIds(JsonNode itinerary) {
        var ids = new HashSet<Long>();
        itinerary.path("days").forEach(day -> day.path("items").forEach(item -> ids.add(item.path("destination").path("id").asLong())));
        return ids;
    }

    @Test void datesTravelersAndOriginMustBeValid() throws Exception {
        var user = account("ROLE_USER");
        for (var entry : List.of(
                Map.entry("startDate", today().minusDays(1).toString()),
                Map.entry("startDate", today().plusDays(4).toString()),
                Map.entry("endDate", today().plusDays(8).toString()),
                Map.entry("travelersCount", 0), Map.entry("travelersCount", 11),
                Map.entry("originLatitude", 91), Map.entry("originLongitude", 108.21),
                Map.entry("preferredCategories", List.of("HOTEL")))) {
            var invalid = input();
            invalid.put(entry.getKey(), entry.getValue());
            generate(invalid, user, 400);
        }
        var missing = input();
        missing.put("endDate", null);
        generate(missing, user, 400);
        var outOfWindow = input();
        outOfWindow.put("startDate", today().plusDays(364).toString());
        outOfWindow.put("endDate", today().plusDays(366).toString());
        generate(outOfWindow, user, 400);
        var valid = input();
        valid.put("endDate", today().plusDays(7).toString());
        valid.put("originName", "  Nơi ở tại Sơn Trà  ");
        valid.put("originLatitude", 16.05);
        valid.put("originLongitude", 108.21);
        var trip = generate(valid, user, 200);
        assertEquals(7, trip.path("totalDays").asInt());
        assertEquals("taxi", trip.path("transport").asText());
        assertEquals("Nơi ở tại Sơn Trà", trip.path("originName").asText());
        assertEquals(16.05, trip.path("originLatitude").asDouble());
    }

    @Test void rulesAreValidatedSavedAndEnforcedWhenEditing() throws Exception {
        var admin = account("ROLE_ADMIN");
        var owner = account("ROLE_USER");
        long must = point(admin, "CAFE", "Original required name");
        long exclude = point(admin, "FOOD", "Excluded restaurant");
        long hidden = point(admin, "FOOD", "Hidden point");
        call(HttpMethod.DELETE, "/destinations/" + hidden, null, admin.token(), 200);

        for (var ids : List.of(List.of(must, must), List.of(must, exclude, 3L, 4L, 5L, 6L), List.of(hidden))) {
            var invalid = input();
            invalid.put("requiredDestinationIds", ids);
            generate(invalid, owner, 400);
        }
        var overlap = input();
        overlap.put("requiredDestinationIds", List.of(must));
        overlap.put("excludedDestinationIds", List.of(must));
        generate(overlap, owner, 400);
        var unavailable = input();
        unavailable.put("excludedDestinationIds", List.of(hidden));
        generate(unavailable, owner, 400);

        var payload = input();
        payload.put("requiredDestinationIds", List.of(must));
        payload.put("excludedDestinationIds", List.of(exclude));
        var trip = generate(payload, owner, 200);
        long id = trip.path("id").asLong();
        assertEquals(2, trip.path("constraints").size());
        assertEquals(must, trip.path("days").get(0).path("items").get(0).path("destination").path("id").asLong());
        assertFalse(activityIds(trip).contains(exclude));
        assertEquals(2, db.queryForObject("select count(*) from itinerary_constraints where itinerary_id=?", Integer.class, id));

        call(HttpMethod.PUT, "/destinations/" + must, Map.of("name", "Renamed after generating", "latitude", 16.05, "longitude", 108.21), admin.token(), 200);
        var detail = call(HttpMethod.GET, "/itineraries/" + id, null, owner.token(), 200);
        var required = detail.path("constraints").get(1);
        assertEquals("REQUIRED", required.path("type").asText());
        assertEquals("Original required name", required.path("snapshot").path("name").asText());
        var edited = Map.of("version", detail.path("version").asInt(), "days", List.of(
                Map.of("dayNumber", 1, "items", List.of())));
        call(HttpMethod.PUT, "/itineraries/" + id + "/activities", edited, owner.token(), 409);
        assertTrue(activityIds(call(HttpMethod.GET, "/itineraries/" + id, null, owner.token(), 200)).contains(must));
    }

    @Test void adminFeaturedReasonAndProfilePreferencesReachPublishedStopSnapshot() throws Exception {
        var admin = account("ROLE_ADMIN");
        var owner = account("ROLE_USER");
        long id = point(admin, "BEACH", "Biển kiểm thử REC");
        var update = Map.of("name", "Biển kiểm thử REC", "latitude", 16.05, "longitude", 108.21,
                "featuredReason", "Trải nghiệm tiêu biểu trong catalog");
        call(HttpMethod.PUT, "/destinations/" + id, update, owner.token(), 403);
        assertEquals(update.get("featuredReason"), call(HttpMethod.PUT, "/destinations/" + id,
                update, admin.token(), 200).path("featuredReason").asText());
        call(HttpMethod.PUT, "/auth/profile", Map.of("fullName", "Trip tester",
                "preferredCategories", List.of("BEACH")), owner.token(), 200);
        var payload = input();
        payload.remove("preferredCategories");
        payload.put("endDate", payload.get("startDate"));
        var withProfile = generate(payload, owner, 200);
        assertEquals("BEACH", withProfile.path("preferredCategories").get(0).asText());
        var featured = withProfile.path("days").get(0).path("items").valueStream()
                .filter(item -> item.path("featuredRecommendation").asBoolean()).findFirst().orElseThrow();
        assertEquals(id, featured.path("destination").path("id").asLong());
        assertEquals(update.get("featuredReason"), featured.path("recommendationReason").asText());
        var override = new HashMap<>(payload);
        override.put("preferredCategories", List.of("CAFE"));
        override.put("generationKey", UUID.randomUUID().toString());
        assertEquals("CAFE", generate(override, owner, 200).path("preferredCategories").get(0).asText());
        call(HttpMethod.DELETE, "/destinations/" + id, null, admin.token(), 200);
    }

    @Test void concurrentReplayAndSeparateSavedListRespectOwnerAndCleanup() throws Exception {
        var owner = account("ROLE_USER");
        var other = account("ROLE_USER");
        var admin = account("ROLE_ADMIN");
        var payload = input();
        payload.put("originName", "Địa chỉ riêng");
        long id;
        try (var executor = Executors.newFixedThreadPool(2)) {
            Callable<JsonNode> submit = () -> generate(payload, owner, 200);
            var results = executor.invokeAll(List.of(submit, submit));
            var first = results.getFirst().get();
            id = first.path("id").asLong();
            assertEquals(id, results.getLast().get().path("id").asLong());
            assertEquals("DRAFT", first.path("status").asText());
        }
        assertEquals(1, db.queryForObject("select count(*) from itineraries where user_id=?", Integer.class, owner.id()));
        var mismatch = new HashMap<>(payload);
        mismatch.put("maxBudgetVnd", 3_000_000);
        generate(mismatch, owner, 409);
        assertNotEquals(id, generate(payload, other, 200).path("id").asLong());
        String path = "/itineraries/" + id;
        call(HttpMethod.GET, path, null, other.token(), 403);
        call(HttpMethod.GET, path, null, admin.token(), 403);
        call(HttpMethod.PUT, path + "/save", null, other.token(), 403);
        call(HttpMethod.PUT, path + "/save", null, admin.token(), 403);
        call(HttpMethod.POST, path + "/share", null, owner.token(), 409);
        assertTrue(call(HttpMethod.GET, "/itineraries", null, owner.token(), 200).isEmpty());
        assertEquals(id, call(HttpMethod.GET, "/itineraries/drafts", null, owner.token(), 200).get(0).path("id").asLong());

        var saved = call(HttpMethod.PUT, path + "/save", null, owner.token(), 200);
        assertEquals("SAVED", saved.path("status").asText());
        assertEquals(saved.path("version"), call(HttpMethod.PUT, path + "/save", null, owner.token(), 200).path("version"));
        assertEquals(id, generate(payload, owner, 200).path("id").asLong());
        assertTrue(call(HttpMethod.GET, "/itineraries/drafts", null, owner.token(), 200).isEmpty());
        assertEquals(id, call(HttpMethod.GET, "/itineraries", null, owner.token(), 200).get(0).path("id").asLong());
        var share = call(HttpMethod.POST, path + "/share", null, owner.token(), 200).path("shareToken").asText();
        assertFalse(call(HttpMethod.GET, "/itineraries/shared/" + share, null, null, 200).has("originName"));

        long expired = generate(input(), owner, 200).path("id").asLong();
        db.update("update itineraries set updated_at = '2020-01-01 00:00:00' where id in (?,?)", id, expired);
        cleanup.clean();
        call(HttpMethod.GET, "/itineraries/" + expired, null, owner.token(), 404);
        call(HttpMethod.GET, path, null, owner.token(), 200);
        call(HttpMethod.GET, "/itineraries/shared/" + share, null, null, 200);
    }

    @Test void ownedTripCopiesAreIndependentAndPagesUseDaNangEndDate() throws Exception {
        var owner = account("ROLE_USER");
        var other = account("ROLE_USER");
        var admin = account("ROLE_ADMIN");
        long point = point(admin, "CAFE", "Điểm bắt buộc sao chép");
        var payload = input();
        payload.put("requiredDestinationIds", List.of(point));
        var original = generate(payload, owner, 200);
        String path = "/itineraries/" + original.path("id").asLong();
        call(HttpMethod.PUT, path + "/save", null, owner.token(), 200);
        call(HttpMethod.PUT, path + "/title", Map.of("title", " Đà Nẵng 100% "), owner.token(), 200);
        call(HttpMethod.PUT, path + "/title", Map.of("title", "Tên khác"), admin.token(), 403);
        call(HttpMethod.POST, path + "/copy", null, other.token(), 403);
        call(HttpMethod.DELETE, path, null, other.token(), 403);
        call(HttpMethod.POST, path + "/share", null, owner.token(), 200);
        var copy = call(HttpMethod.POST, path + "/copy", null, owner.token(), 201);
        long copyId = copy.path("id").asLong();
        assertNotEquals(original.path("id").asLong(), copyId);
        assertEquals("DRAFT", copy.path("status").asText());
        assertEquals("Đà Nẵng 100% (bản sao)", copy.path("title").asText());
        assertEquals(original.path("constraints"), copy.path("constraints"));
        assertNotEquals(original.path("days").get(0).path("id"), copy.path("days").get(0).path("id"));
        assertNotEquals(original.path("days").get(0).path("items").get(0).path("id"),
                copy.path("days").get(0).path("items").get(0).path("id"));
        assertEquals("NONE", call(HttpMethod.GET, "/itineraries/" + copyId + "/share", null, owner.token(), 200)
                .path("state").asText());
        assertNull(db.queryForObject("select generation_key from itineraries where id=?", String.class, copyId));
        call(HttpMethod.PUT, "/itineraries/" + copyId + "/save", null, owner.token(), 200);
        db.update("update itineraries set start_date=?,end_date=? where id=?", today().minusDays(3), today().minusDays(1), copyId);
        db.update("update itineraries set start_date=?,end_date=? where id=?",
                today().minusDays(2), today(), original.path("id").asLong());
        var history = call(HttpMethod.GET, "/itineraries/mine?period=HISTORY&size=1", null, owner.token(), 200);
        assertEquals(copyId, history.path("items").get(0).path("id").asLong());
        assertEquals("HISTORY", history.path("items").get(0).path("period").asText());
        var upcoming = call(HttpMethod.GET, "/itineraries/mine?period=UPCOMING&size=1", null, owner.token(), 200);
        assertEquals(original.path("id"), upcoming.path("items").get(0).path("id"));
        assertEquals("UPCOMING", upcoming.path("items").get(0).path("period").asText());
        var all = call(HttpMethod.GET, "/itineraries/mine?size=1", null, owner.token(), 200);
        assertTrue(all.path("hasNext").asBoolean());
        assertEquals(2, all.path("total").asInt());
        assertEquals(1, call(HttpMethod.GET, "/itineraries/mine?page=1&size=1", null, owner.token(), 200).path("items").size());
        assertEquals(0, call(HttpMethod.GET, "/itineraries/mine?search=unmatched", null, owner.token(), 200).path("total").asInt());
        assertEquals(0, call(HttpMethod.GET, "/itineraries/mine", null, other.token(), 200).path("total").asInt());
        call(HttpMethod.DELETE, path, null, owner.token(), 200);
        assertEquals(1, db.queryForObject("select count(*) from itinerary_constraints where itinerary_id=?", Integer.class, copyId));
        call(HttpMethod.GET, "/itineraries/" + copyId, null, owner.token(), 200);
    }

    @Test void publicLinkLifecycleAndBrowserPageExposeOnlyReadOnlyFields() throws Exception {
        var owner = account("ROLE_USER");
        var other = account("ROLE_USER");
        var payload = input();
        payload.put("title", "<Demo> chuyến đi");
        payload.put("originName", "Nơi ở riêng tư");
        var trip = generate(payload, owner, 200);
        long id = trip.path("id").asLong();
        String path = "/itineraries/" + id;
        call(HttpMethod.PUT, path + "/save", null, owner.token(), 200);
        assertEquals("NONE", call(HttpMethod.GET, path + "/share", null, owner.token(), 200).path("state").asText());
        var link = call(HttpMethod.POST, path + "/share", null, owner.token(), 200);
        String token = link.path("shareToken").asText();
        assertEquals(32, token.length());
        assertEquals(token, call(HttpMethod.POST, path + "/share", null, owner.token(), 200).path("shareToken").asText());
        call(HttpMethod.DELETE, path + "/share", null, other.token(), 403);
        var publicTrip = call(HttpMethod.GET, "/itineraries/shared/" + token, null, null, 200);
        assertEquals(Set.of("title", "startDate", "endDate", "days"), publicTrip.properties().stream()
                .map(Map.Entry::getKey).collect(java.util.stream.Collectors.toSet()));
        var publicItems = publicTrip.path("days").get(0).path("items");
        assertFalse(publicItems.isEmpty());
        assertFalse(publicItems.get(0).has("notes"));
        assertEquals("UNKNOWN", publicItems.get(0).path("routeSource").asText());
        var browser = http.getForEntity("/itineraries/shared/" + token, String.class);
        assertEquals(200, browser.getStatusCode().value());
        assertTrue(browser.getBody().contains("&lt;Demo&gt;"));
        assertFalse(browser.getBody().contains("Nơi ở riêng tư"));
        db.update("update itineraries set share_expires_at='2020-01-01 00:00:00' where id=?", id);
        call(HttpMethod.GET, "/itineraries/shared/" + token, null, null, 410);
        var expired = call(HttpMethod.GET, path + "/share", null, owner.token(), 200);
        assertEquals("EXPIRED", expired.path("state").asText());
        assertTrue(expired.path("shareUrl").isNull());
        var renewed = call(HttpMethod.POST, path + "/share", null, owner.token(), 200).path("shareToken").asText();
        assertNotEquals(token, renewed);
        call(HttpMethod.GET, "/itineraries/shared/" + token, null, null, 404);
        var rotated = call(HttpMethod.POST, path + "/share?rotate=true", null, owner.token(), 200).path("shareToken").asText();
        assertNotEquals(renewed, rotated);
        call(HttpMethod.GET, "/itineraries/shared/" + renewed, null, null, 404);
        call(HttpMethod.DELETE, path + "/share", null, owner.token(), 200);
        call(HttpMethod.GET, "/itineraries/shared/" + rotated, null, null, 404);
        var beforeDelete = call(HttpMethod.POST, path + "/share", null, owner.token(), 200).path("shareToken").asText();
        call(HttpMethod.DELETE, path, null, owner.token(), 200);
        call(HttpMethod.GET, "/itineraries/shared/" + beforeDelete, null, null, 404);
    }
}
