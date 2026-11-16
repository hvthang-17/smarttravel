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
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.Executors;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(initializers = TestDatabaseGuard.class)
class DestinationReviewsTest {
    @Autowired TestRestTemplate http;
    @Autowired ObjectMapper json;
    @Autowired UserRepository users;
    @Autowired PasswordEncoder passwords;
    @Autowired JdbcTemplate db;

    @Test void ratingOwnershipAndAggregateFollowPublishedReviewsWithoutChangingGoogle() throws Exception {
        String admin = account("ROLE_ADMIN");
        String first = account("ROLE_USER");
        String second = account("ROLE_USER");
        String third = account("ROLE_USER");
        long id = destination(admin);
        String path = "/destinations/" + id + "/reviews";

        request(HttpMethod.GET, path + "/mine", null, null, 401);
        request(HttpMethod.POST, path, Map.of("rating", 5), null, 401);
        assertNullRating(id);
        for (var invalid : List.of(Map.of("rating", 0), Map.of("rating", 6), Map.of("rating", 4.5),
                Map.of("rating", 4, "comment", "x".repeat(1001)))) {
            request(HttpMethod.POST, path, invalid, first, 400);
        }
        var review = request(HttpMethod.POST, path, Map.of("rating", 5, "comment", " Original "), first, 201);
        assertEquals("Original", review.path("comment").asText());
        request(HttpMethod.POST, path, Map.of("rating", 5), first, 409);
        request(HttpMethod.PUT, path + "/mine", Map.of("rating", 1), second, 404);
        request(HttpMethod.DELETE, path + "/mine", null, admin, 404);
        request(HttpMethod.POST, path, Map.of("rating", 4), second, 201);
        request(HttpMethod.POST, path, Map.of("rating", 4), third, 201);
        var published = request(HttpMethod.GET, path + "?size=1", null, null, 200);
        assertTrue(published.path("hasNext").asBoolean());
        assertEquals(1, published.path("items").size());
        assertFalse(published.path("items").get(0).has("userId"));
        assertRating(id, 13.0 / 3, 3);
        var updated = request(HttpMethod.PUT, path + "/mine", Map.of("rating", 2, "comment", "Updated"), first, 200);
        assertEquals(review.path("id"), updated.path("id"));
        assertRating(id, 10.0 / 3, 3);
        for (var actor : List.of(first, second, third)) request(HttpMethod.DELETE, path + "/mine", null, actor, 200);
        assertNullRating(id);
    }

    @Test void duplicateCreatesAndReportsAreSafeAndModerationSurvivesAuthorEdit() throws Exception {
        String admin = account("ROLE_ADMIN");
        String author = account("ROLE_USER");
        String reporter = account("ROLE_USER");
        long id = destination(admin);
        String path = "/destinations/" + id + "/reviews";
        try (var executor = Executors.newFixedThreadPool(2)) {
            Callable<Integer> submit = () -> exchange(HttpMethod.POST, path, Map.of("rating", 5, "comment", "Test comment"),
                    author).getStatusCode().value();
            var attempts = executor.invokeAll(List.of(submit, submit));
            assertEquals(List.of(201, 409), attempts.stream().map(result -> result.resultNow()).sorted().toList());
        }
        long reviewId = request(HttpMethod.GET, path + "/mine", null, author, 200).path("id").asLong();
        String report = path + "/" + reviewId + "/reports";
        request(HttpMethod.POST, report, Map.of("reason", "SPAM"), author, 400);
        request(HttpMethod.POST, report, Map.of("reason", "SPAM"), reporter, 200);
        request(HttpMethod.POST, report, Map.of("reason", "ABUSE"), reporter, 200);
        String moderation = "/admin/reviews";
        request(HttpMethod.GET, moderation, null, reporter, 403);
        var inbox = request(HttpMethod.GET, moderation + "?reportedOnly=true&destinationId=" + id, null, admin, 200);
        assertEquals(1, inbox.path("items").size());
        assertEquals(1, inbox.path("items").get(0).path("reports").path("SPAM").asInt());
        assertFalse(inbox.path("items").get(0).path("reports").has("ABUSE"));
        String status = moderation + "/" + reviewId + "/status";
        request(HttpMethod.PUT, status, Map.of("status", "HIDDEN"), admin, 200);
        assertNullRating(id);
        assertTrue(request(HttpMethod.GET, path, null, null, 200).path("items").isEmpty());
        var own = request(HttpMethod.PUT, path + "/mine",
                Map.of("rating", 3, "comment", "Changed while hidden", "status", "PUBLISHED"), author, 200);
        assertEquals("HIDDEN", own.path("status").asText());
        assertNullRating(id);
        request(HttpMethod.POST, report, Map.of("reason", "SPAM"), reporter, 404);
        request(HttpMethod.PUT, status, Map.of("status", "PUBLISHED"), admin, 200);
        assertRating(id, 3, 1);
        assertEquals(2, db.queryForObject("""
                select count(*) from audit_logs where entity_type='REVIEW' and entity_id=? and action='MODERATE'
                """, Integer.class, reviewId));
        assertEquals(1, db.queryForObject("""
                select count(*) from audit_logs where entity_type='REVIEW' and entity_id=? and action='REPORT'
                and actor_name is null and details='{"reason":"SPAM"}'
                """, Integer.class, reviewId));
        request(HttpMethod.DELETE, "/destinations/" + id, null, admin, 200);
        request(HttpMethod.GET, path, null, null, 404);
        request(HttpMethod.POST, path, Map.of("rating", 3), reporter, 404);
        request(HttpMethod.DELETE, path + "/mine", null, author, 200);
    }

    private void assertNullRating(long id) throws Exception {
        var ratings = request(HttpMethod.GET, "/destinations/discover/" + id, null, null, 200);
        assertTrue(ratings.path("appRating").isNull());
        assertEquals(0, ratings.path("appReviewCount").asLong());
        assertGoogle(ratings);
    }

    private void assertRating(long id, double average, int count) throws Exception {
        var ratings = request(HttpMethod.GET, "/destinations/discover/" + id, null, null, 200);
        assertEquals(average, ratings.path("appRating").asDouble(), 0.000001);
        assertEquals(count, ratings.path("appReviewCount").asLong());
        assertGoogle(ratings);
    }

    private static void assertGoogle(JsonNode ratings) {
        assertEquals(4.6, ratings.path("googleRating").asDouble());
        assertEquals(172, ratings.path("googleReviewCount").asInt());
    }

    private long destination(String admin) throws Exception {
        return request(HttpMethod.POST, "/destinations", Map.of("name", "Review " + UUID.randomUUID(),
                "category", "CAFE", "latitude", 16.05, "longitude", 108.21,
                "googleRating", 4.6, "googleReviewCount", 172), admin, 201).path("id").asLong();
    }

    private String account(String role) throws Exception {
        String email = "review-" + UUID.randomUUID() + "@example.test";
        String password = "review-test-password";
        users.save(new User(email, passwords.encode(password), "Review tester", role));
        return request(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", password), null, 200)
                .path("token").asText();
    }

    private JsonNode request(HttpMethod method, String path, Object body, String token, int status) throws Exception {
        var response = exchange(method, path, body, token);
        assertEquals(status, response.getStatusCode().value(), () -> path + " " + response.getBody());
        return json.readTree(response.getBody()).path("data");
    }

    private ResponseEntity<String> exchange(HttpMethod method, String path, Object body, String token) {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        return http.exchange("/api/v1" + path, method, new HttpEntity<>(body, headers), String.class);
    }
}
