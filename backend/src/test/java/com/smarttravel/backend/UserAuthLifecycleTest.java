package com.smarttravel.backend;

import com.fasterxml.jackson.databind.*;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.*;
import java.net.InetSocketAddress;
import java.util.*;
import java.util.concurrent.*;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(initializers = TestDatabaseGuard.class)
class UserAuthLifecycleTest {
    private static final BlockingQueue<JsonNode> MAIL = new LinkedBlockingQueue<>();
    private static final HttpServer EMAIL = startEmail();
    private static final String OLD_PASSWORD = "Travel-initial-123!";
    private static final String NEW_PASSWORD = "Travel-replaced-456!";
    @Autowired TestRestTemplate http;
    @Autowired ObjectMapper json;
    @Autowired JdbcTemplate db;
    @Autowired UserRepository users;
    @Autowired PasswordEncoder passwords;

    private static HttpServer startEmail() {
        try {
            HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
            server.createContext("/emails", exchange -> {
                try (exchange) {
                    MAIL.add(new ObjectMapper().readTree(exchange.getRequestBody()));
                    exchange.sendResponseHeaders("Bearer local-test-key".equals(exchange.getRequestHeaders().getFirst("Authorization")) ? 202 : 401, -1);
                }
            });
            server.start();
            return server;
        } catch (java.io.IOException e) { throw new IllegalStateException(e); }
    }

    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("app.reset.email-endpoint", () -> "http://127.0.0.1:" + EMAIL.getAddress().getPort() + "/emails");
        registry.add("app.reset.email-api-key", () -> "local-test-key");
        registry.add("app.reset.email-from", () -> "SmartTravel <reset@example.test>");
    }

    @AfterAll static void stopEmail() { EMAIL.stop(0); }
    record Account(long id, String email, String token) {}

    private JsonNode call(HttpMethod method, String path, Object data, String token, int status) throws Exception {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        var response = http.exchange("/api/v1" + path, method, new HttpEntity<>(data, headers), String.class);
        assertEquals(status, response.getStatusCode().value(), response.getBody());
        return json.readTree(response.getBody());
    }

    private Account register(String email) throws Exception {
        var user = call(HttpMethod.POST, "/auth/register", Map.of("fullName", "Lifecycle traveler", "email", email, "password", OLD_PASSWORD), null, 200).path("data");
        return new Account(user.path("id").asLong(), email, user.path("token").asText());
    }

    private Account account() throws Exception { return register("lifecycle-" + UUID.randomUUID() + "@example.test"); }

    private JsonNode login(String email, String password, int code) throws Exception {
        return call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", password), null, code).path("data");
    }

    private String mailedCode(String email) throws Exception {
        call(HttpMethod.POST, "/auth/forgot-password", Map.of("email", email), null, 202);
        var message = MAIL.poll(8, TimeUnit.SECONDS);
        assertNotNull(message);
        assertEquals(email, message.path("to").get(0).asText());
        return message.path("text").asText().split("\\R\\R")[1];
    }

    @Test void profileIsReturnedOnAnotherLoginAndBudgetCanBeCleared() throws Exception {
        var user = account();
        var profile = new HashMap<String, Object>(Map.of("fullName", "Lifecycle traveler", "preferredCategories", List.of("FOOD"),
                "defaultBudgetVnd", 1200000, "language", "en", "defaultTransport", "taxi", "defaultPace", "relaxed"));
        call(HttpMethod.PUT, "/auth/profile", profile, user.token(), 200);
        var fresh = login(user.email(), OLD_PASSWORD, 200);
        var saved = fresh.path("travelerProfile");
        assertEquals("taxi", saved.path("defaultTransport").asText());
        assertEquals("en", saved.path("language").asText());
        assertEquals("relaxed", saved.path("defaultPace").asText());
        assertEquals("FOOD", saved.path("preferredCategories").get(0).asText());
        assertEquals(1200000, saved.path("defaultBudgetVnd").asInt());
        profile.put("defaultBudgetVnd", null);
        call(HttpMethod.PUT, "/auth/profile", profile, fresh.path("token").asText(), 200);
        assertTrue(call(HttpMethod.GET, "/auth/profile", null, user.token(), 200).path("data")
                .path("travelerProfile").path("defaultBudgetVnd").isNull());
    }

    @Test void emailIsGenericAndOnlyOneConcurrentResetWins() throws Exception {
        var user = account();
        var unknown = call(HttpMethod.POST, "/auth/forgot-password", Map.of("email", UUID.randomUUID() + "@example.test"), null, 202);
        var accepted = call(HttpMethod.POST, "/auth/forgot-password", Map.of("email", user.email()), null, 202);
        assertEquals(unknown.path("message"), accepted.path("message"));
        var mail = MAIL.poll(8, TimeUnit.SECONDS);
        assertNotNull(mail);
        assertEquals(user.email(), mail.path("to").get(0).asText());
        var code = mail.path("text").asText().split("\\R\\R")[1];
        var stored = db.queryForObject("select token_hash from password_reset_tokens where user_id=?", byte[].class, user.id());
        assertArrayEquals(java.security.MessageDigest.getInstance("SHA-256").digest(code.getBytes(java.nio.charset.StandardCharsets.UTF_8)), stored);
        var request = Map.of("code", code, "password", NEW_PASSWORD);
        try (var executor = Executors.newFixedThreadPool(2)) {
            Callable<Integer> reset = () -> http.postForEntity("/api/v1/auth/reset-password", request, String.class).getStatusCode().value();
            var results = executor.invokeAll(List.of(reset, reset));
            assertEquals(Set.of(200, 400), Set.of(results.get(0).get(), results.get(1).get()));
        }
        call(HttpMethod.GET, "/auth/profile", null, user.token(), 401);
        login(user.email(), OLD_PASSWORD, 401);
        login(user.email(), NEW_PASSWORD, 200);
        assertEquals(1, db.queryForObject("select count(*) from password_reset_tokens where user_id=? and used_at is not null", Integer.class, user.id()));
    }

    @Test void expiredCodeIsRejected() throws Exception {
        var user = account();
        String code = mailedCode(user.email());
        db.update("update password_reset_tokens set expires_at = '2020-01-01 00:00:00' where user_id=?", user.id());
        call(HttpMethod.POST, "/auth/reset-password", Map.of("code", code, "password", NEW_PASSWORD), null, 400);
        login(user.email(), OLD_PASSWORD, 200);
    }

    @Test void deletingCascadesRevokesShareAnonymizesAuditAndRejectsOldTokenAfterReregistration() throws Exception {
        var user = account();
        call(HttpMethod.PUT, "/auth/profile", Map.of("fullName", "Private actor", "preferredCategories", List.of("FOOD")), user.token(), 200);
        var trip = call(HttpMethod.POST, "/itineraries/generate", Map.of("title", "Private", "startDate", planningDate(0),
                "endDate", planningDate(0), "travelersCount", 1, "maxBudgetVnd", 1000000, "pace", "balanced"), user.token(), 200).path("data");
        call(HttpMethod.PUT, "/itineraries/" + trip.path("id").asLong() + "/save", null, user.token(), 200);
        var share = call(HttpMethod.POST, "/itineraries/" + trip.path("id").asLong() + "/share", null, user.token(), 200)
                .path("data").path("shareToken").asText();
        call(HttpMethod.GET, "/itineraries/shared/" + share, null, null, 200);
        call(HttpMethod.POST, "/auth/account/delete", Map.of("password", OLD_PASSWORD, "confirmed", false), user.token(), 400);
        call(HttpMethod.POST, "/auth/account/delete", Map.of("password", "Wrong-password", "confirmed", true), user.token(), 400);
        call(HttpMethod.POST, "/auth/account/delete", Map.of("password", OLD_PASSWORD, "confirmed", true), user.token(), 200);
        assertFalse(users.existsById(user.id()));
        assertEquals(0, db.queryForObject("select count(*) from traveler_profiles where user_id=?", Integer.class, user.id()));
        assertEquals(0, db.queryForObject("select count(*) from itineraries where user_id=?", Integer.class, user.id()));
        assertEquals(0, db.queryForObject("select count(*) from audit_logs where actor_name='Private actor' and entity_id=?", Integer.class, user.id()));
        call(HttpMethod.GET, "/itineraries/shared/" + share, null, null, 404);
        var replacement = register(user.email());
        assertNotEquals(user.id(), replacement.id());
        call(HttpMethod.GET, "/auth/profile", null, user.token(), 401);
    }

    @Test void lastActiveAdminCannotDeleteOwnAccount() throws Exception {
        var name = "last-self-" + UUID.randomUUID() + "@example.test";
        var admin = users.save(new User(name, passwords.encode(OLD_PASSWORD), "Last lifecycle admin", "ROLE_ADMIN"));
        var active = db.queryForList("select id from users where role='ROLE_ADMIN' and status='ACTIVE' and id<>?", Long.class, admin.getId());
        try {
            for (long id : active) db.update("update users set status='INACTIVE' where id=?", id);
            String token = login(name, OLD_PASSWORD, 200).path("token").asText();
            call(HttpMethod.POST, "/auth/account/delete", Map.of("password", OLD_PASSWORD, "confirmed", true), token, 409);
            assertTrue(users.existsById(admin.getId()));
        } finally {
            for (long id : active) db.update("update users set status='ACTIVE' where id=?", id);
        }
    }
    private static String planningDate(int days) {
        return java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(days + 1L).toString();
    }
}
