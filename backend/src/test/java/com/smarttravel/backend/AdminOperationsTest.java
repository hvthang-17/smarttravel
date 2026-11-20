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

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(initializers = TestDatabaseGuard.class)
class AdminOperationsTest {
    private static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    @Autowired TestRestTemplate http;
    @Autowired ObjectMapper json;
    @Autowired UserRepository users;
    @Autowired PasswordEncoder passwords;
    @Autowired JdbcTemplate db;

    @Test void auditFiltersAndExportRedactLegacySecretsAndPreserveAnonymizedEvents() throws Exception {
        var admin = account("ROLE_ADMIN", "Audit manager");
        var actor = account("ROLE_USER", "=AUDIT_ACTOR");
        var today = LocalDate.now(ZONE);
        var detail = "{\"role\":\"ROLE_USER\",\"token\":\"legacy-test-secret\",\"fields\":[\"name\",\"password\"]}";
        for (var date : List.of(today.minusDays(1), today)) {
            db.update("""
                    insert into audit_logs(user_id,actor_name,action,entity_type,entity_id,details,created_at)
                    values(?,?,?,?,?,?,?)
                    """, actor.id(), "=AUDIT_ACTOR", "UPDATE", "DESTINATION", actor.id(), detail,
                    Timestamp.from(date.atStartOfDay(ZONE).toInstant()));
        }
        String query = "?actor=AUDIT_ACTOR&actorId=" + actor.id()
                + "&action=UPDATE&entity=DESTINATION&from=" + today + "&to=" + today;
        call(HttpMethod.GET, "/admin/audit" + query, null, actor.token(), 403);
        var result = call(HttpMethod.GET, "/admin/audit" + query + "&size=1", null, admin.token(), 200);
        assertFalse(result.path("hasNext").asBoolean());
        var row = result.path("items").get(0);
        assertEquals("ROLE_USER", row.path("details").path("role").asText());
        assertEquals("name", row.path("details").path("fields").get(0).asText());
        assertFalse(row.toString().contains("legacy-test-secret"));
        assertFalse(row.toString().contains("password"));
        var csv = call(HttpMethod.GET, "/admin/audit/export" + query, null, admin.token(), 200).path("csv").asText();
        assertTrue(csv.contains("'=AUDIT_ACTOR"));
        assertFalse(csv.contains("legacy-test-secret"));
        call(HttpMethod.GET, "/admin/audit?from=" + today + "&to=" + today.minusDays(1), null, admin.token(), 400);
        call(HttpMethod.DELETE, "/admin/users/" + actor.id(), null, admin.token(), 200);
        assertTrue(call(HttpMethod.GET, "/admin/audit" + query, null, admin.token(), 200).path("items").isEmpty());
        assertEquals(2, db.queryForObject("""
                select count(*) from audit_logs where entity_id=? and entity_type='DESTINATION'
                and user_id is null and actor_name is null
                """, Integer.class, actor.id()));
    }

    @Test void databaseDashboardAndAdminPagesRespectScopeAndFilter() throws Exception {
        var admin = account("ROLE_ADMIN", "Operations manager");
        var initial = call(HttpMethod.GET, "/admin/dashboard?days=7", null, admin.token(), 200);
        String marker = "Ops" + UUID.randomUUID().toString().substring(0, 8);
        var user = account("ROLE_USER", marker);
        var metrics = call(HttpMethod.GET, "/admin/dashboard?days=7", null, admin.token(), 200);
        assertEquals(initial.path("totalUsers").asLong() + 1, metrics.path("totalUsers").asLong());
        assertEquals(initial.path("newUsers").asLong() + 1, metrics.path("newUsers").asLong());
        assertEquals(LocalDate.now(ZONE).minusDays(6).toString(), metrics.path("from").asText());
        call(HttpMethod.GET, "/admin/dashboard", null, user.token(), 403);
        var page = call(HttpMethod.GET, "/admin/users/page?search=" + marker + "&role=ROLE_USER&size=1",
                null, admin.token(), 200);
        assertEquals(user.id(), page.path("items").get(0).path("id").asLong());
        assertEquals(0, page.path("items").get(0).path("tripsCount").asInt());
        var today = LocalDate.now(ZONE).plusDays(1).toString();
        var trip = call(HttpMethod.POST, "/itineraries/generate", Map.of("title", marker,
                "startDate", today, "endDate", today, "maxBudgetVnd", 5_000_000,
                "travelersCount", 2, "pace", "relaxed", "preferredCategories", List.of("BEACH")), user.token(), 200);
        String query = "/admin/itineraries/page?search=" + marker + "&status=SAVED";
        assertTrue(call(HttpMethod.GET, query, null, admin.token(), 200).path("items").isEmpty());
        call(HttpMethod.PUT, "/itineraries/" + trip.path("id").asLong() + "/save", null, user.token(), 200);
        call(HttpMethod.GET, query, null, user.token(), 403);
        assertEquals(trip.path("id"), call(HttpMethod.GET, query, null, admin.token(), 200).path("items").get(0).path("id"));
    }

    private record Account(long id, String token) {}

    private Account account(String role, String name) throws Exception {
        String email = "operations-" + UUID.randomUUID() + "@example.test";
        String secret = "test-operations-password";
        var user = users.save(new User(email, passwords.encode(secret), name, role));
        var auth = call(HttpMethod.POST, "/auth/login", Map.of("email", email, "password", secret), null, 200);
        return new Account(user.getId(), auth.path("token").asText());
    }

    private JsonNode call(HttpMethod method, String path, Object body, String token, int expected) throws Exception {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        var result = http.exchange("/api/v1" + path, method, new HttpEntity<>(body, headers), String.class);
        assertEquals(expected, result.getStatusCode().value(), () -> path + " " + result.getBody());
        return json.readTree(result.getBody()).path("data");
    }
}
