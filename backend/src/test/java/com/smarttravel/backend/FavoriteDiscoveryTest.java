package com.smarttravel.backend;

import com.fasterxml.jackson.databind.*;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.*;
import java.util.*;
import java.util.concurrent.*;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(initializers = TestDatabaseGuard.class)
class FavoriteDiscoveryTest {
    @Autowired TestRestTemplate http;
    @Autowired ObjectMapper json;
    @Autowired UserRepository users;
    @Autowired PasswordEncoder passwords;
    @Autowired JdbcTemplate db;

    record Account(long id, String token) {}

    Account account(String role) throws Exception {
        String email = "disc-" + UUID.randomUUID() + "@example.test";
        var user = users.save(new User(email, passwords.encode("Discovery-test-123!"), "Discovery tester", role));
        var token = call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", "Discovery-test-123!"), null, 200)
                .path("token").asText();
        return new Account(user.getId(), token);
    }

    JsonNode call(HttpMethod method, String path, Object body, String token, int expected) throws Exception {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        var response = http.exchange("/api/v1" + path, method, new HttpEntity<>(body, headers), String.class);
        assertEquals(expected, response.getStatusCode().value(), response.getBody());
        return json.readTree(response.getBody()).path("data");
    }

    JsonNode place(Account admin, String name, String category, Long min, Long max) throws Exception {
        var body = new HashMap<String, Object>(Map.of("name", name, "category", category,
                "latitude", 16.05, "longitude", 108.2, "nameEn", "Translated-" + name));
        body.put("priceMinVnd", min);
        body.put("priceMaxVnd", max);
        return call(HttpMethod.POST, "/destinations", body, admin.token(), 201);
    }

    private List<Long> ids(JsonNode items) {
        var result = new ArrayList<Long>();
        items.forEach(item -> result.add(item.path("id").asLong()));
        return result;
    }

    @Test void discoveryFiltersNameBothLanguagesPricesCategoriesAndPages() throws Exception {
        var admin = account("ROLE_ADMIN");
        var keyword = "discovery-" + UUID.randomUUID();
        long unknown = place(admin, keyword + " unknown", "FOOD", null, null).path("id").asLong();
        long range = place(admin, keyword + " range", "FOOD", 20000L, 50000L).path("id").asLong();
        long single = place(admin, keyword + " one-bound", "CAFE", null, 35000L).path("id").asLong();
        long free = place(admin, keyword + " free", "FOOD", 0L, 0L).path("id").asLong();
        long hidden = place(admin, keyword + " hidden", "FOOD", 25000L, 25000L).path("id").asLong();
        call(HttpMethod.DELETE, "/destinations/" + hidden, null, admin.token(), 200);

        var path = "/destinations/discover?search=" + keyword;
        var lowPage = call(HttpMethod.GET, path + "&page=0&size=2", null, null, 200);
        assertEquals(List.of(unknown, range), ids(lowPage.path("items")));
        assertTrue(lowPage.path("hasNext").asBoolean());
        var highPage = call(HttpMethod.GET, path + "&page=1&size=2", null, admin.token(), 200);
        assertEquals(List.of(single, free), ids(highPage.path("items")));
        assertFalse(highPage.path("hasNext").asBoolean());
        assertEquals(List.of(range, single), ids(call(HttpMethod.GET,
                "/destinations/discover?search=Translated-" + keyword + "&minPriceVnd=30000&maxPriceVnd=35000&category=FOOD,CAFE",
                null, null, 200).path("items")));
        assertEquals(List.of(free), ids(call(HttpMethod.GET, path + "&maxPriceVnd=0&category=FOOD", null, null, 200).path("items")));
        call(HttpMethod.GET, path + "&minPriceVnd=10&maxPriceVnd=5", null, null, 400);
        call(HttpMethod.GET, path + "&category=HOTEL", null, null, 400);
        call(HttpMethod.GET, "/destinations/discover/" + hidden, null, admin.token(), 404);
        assertEquals("Translated-" + keyword + " range", call(HttpMethod.GET, "/destinations/discover/" + range, null, null, 200).path("nameEn").asText());

        long cafe = db.queryForObject("select id from categories where code='CAFE'", Long.class);
        var categoryName = db.queryForObject("select name from categories where id=?", String.class, cafe);
        try {
            call(HttpMethod.DELETE, "/categories/" + cafe, null, admin.token(), 200);
            assertEquals(List.of(unknown, range, free), ids(call(HttpMethod.GET, path, null, admin.token(), 200).path("items")));
            call(HttpMethod.GET, "/destinations/discover/" + single, null, null, 404);
        } finally {
            call(HttpMethod.PUT, "/categories/" + cafe, Map.of("name", categoryName, "status", "ACTIVE"), admin.token(), 200);
        }
    }

    @Test void savedDestinationsAreOwnerScopedIdempotentAndValidatedWhenPlanning() throws Exception {
        var admin = account("ROLE_ADMIN");
        var owner = account("ROLE_USER");
        var other = account("ROLE_USER");
        var destination = place(admin, "Saved " + UUID.randomUUID(), "CAFE", 20000L, 40000L);
        long id = destination.path("id").asLong();
        String path = "/favorites/" + id;
        call(HttpMethod.GET, "/favorites", null, null, 401);
        call(HttpMethod.PUT, path, null, null, 401);
        try (var executor = Executors.newFixedThreadPool(2)) {
            Callable<Long> save = () -> call(HttpMethod.PUT, path, null, owner.token(), 200).path("id").asLong();
            for (var result : executor.invokeAll(List.of(save, save))) assertEquals(id, result.get());
        }
        assertEquals(1, db.queryForObject("select count(*) from favorites where user_id=? and destination_id=?", Integer.class, owner.id(), id));
        assertEquals(List.of(id), ids(call(HttpMethod.GET, "/favorites", null, owner.token(), 200)));
        assertEquals(List.of(), ids(call(HttpMethod.GET, "/favorites", null, other.token(), 200)));
        call(HttpMethod.DELETE, path, null, other.token(), 200);
        assertEquals(List.of(id), ids(call(HttpMethod.GET, "/favorites", null, owner.token(), 200)));

        var trip = Map.of("title", "Saved picks", "startDate", planningDate(0), "endDate", planningDate(0),
                "travelersCount", 1, "maxBudgetVnd", 1000000, "pace", "balanced",
                "preferredCategories", List.of("FOOD"), "favoriteDestinationIds", List.of(id));
        call(HttpMethod.POST, "/itineraries/generate", trip, other.token(), 409);
        var planned = call(HttpMethod.POST, "/itineraries/generate", trip, owner.token(), 200);
        assertEquals(id, planned.path("days").get(0).path("items").get(0).path("destination").path("id").asLong());

        call(HttpMethod.DELETE, "/destinations/" + id, null, admin.token(), 200);
        assertEquals(List.of(), ids(call(HttpMethod.GET, "/favorites", null, owner.token(), 200)));
        call(HttpMethod.PUT, path, null, owner.token(), 404);
        call(HttpMethod.POST, "/itineraries/generate", trip, owner.token(), 409);
        assertEquals(1, db.queryForObject("select count(*) from favorites where user_id=? and destination_id=?", Integer.class, owner.id(), id));
        call(HttpMethod.PUT, "/destinations/" + id, Map.of("name", destination.path("name").asText(),
                "latitude", 16.05, "longitude", 108.2, "status", "ACTIVE"), admin.token(), 200);
        assertEquals(List.of(id), ids(call(HttpMethod.GET, "/favorites", null, owner.token(), 200)));
        call(HttpMethod.DELETE, path, null, owner.token(), 200);
        call(HttpMethod.DELETE, path, null, owner.token(), 200);
        assertEquals(List.of(), ids(call(HttpMethod.GET, "/favorites", null, owner.token(), 200)));
    }
    private static String planningDate(int days) {
        return java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(days + 1L).toString();
    }
}
