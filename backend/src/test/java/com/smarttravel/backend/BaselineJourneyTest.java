package com.smarttravel.backend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(initializers = TestDatabaseGuard.class)
class BaselineJourneyTest {
    @Autowired private TestRestTemplate http;
    @Autowired private ObjectMapper mapper;

    @Test
    void travelerCanLoginGenerateEditAndReopenItinerary() throws Exception {
        String email = "baseline-" + UUID.randomUUID() + "@example.test";
        String password = UUID.randomUUID().toString();
        request(HttpMethod.POST, "/auth/register", Map.of(
                "email", email, "password", password, "fullName", "Baseline traveler"), null);
        JsonNode login = request(HttpMethod.POST, "/auth/login",
                Map.of("email", email, "password", password), null);
        String token = login.path("token").asText();
        assertFalse(token.isBlank());
        JsonNode generated = request(HttpMethod.POST, "/itineraries/generate", Map.of(
                "title", "Baseline trip", "startDate", planningDate(0), "endDate", planningDate(1),
                "travelersCount", 2, "maxBudgetVnd", 5000000, "pace", "balanced",
                "preferredCategories", List.of("FOOD")), token);
        long id = generated.path("id").asLong();
        assertTrue(id > 0);
        assertEquals(2, generated.path("days").size());
        List<Map<String, Object>> days = new ArrayList<>();
        for (JsonNode day : generated.path("days")) {
            List<Map<String, Object>> items = new ArrayList<>();
            for (JsonNode item : day.path("items")) {
                items.add(Map.of("destinationId", item.path("destination").path("id").asLong(),
                        "sequenceOrder", item.path("sequenceOrder").asInt(),
                        "startTime", item.path("startTime").asText(),
                        "durationMinutes", item.path("durationMinutes").asInt(),
                        "estimatedCostVnd", item.path("estimatedCostVnd").asLong(),
                        "notes", "Baseline persisted edit"));
            }
            assertFalse(items.isEmpty());
            days.add(Map.of("dayId", day.path("id").asLong(), "items", items));
        }
        request(HttpMethod.PUT, "/itineraries/" + id + "/activities", Map.of("version", generated.path("version").asInt(), "days", days), token);
        JsonNode reopened = request(HttpMethod.GET, "/itineraries/" + id, null, token);
        assertEquals("Baseline persisted edit",
                reopened.path("days").get(0).path("items").get(0).path("notes").asText());
        assertEquals(2, reopened.path("days").size());
        long sum = 0;
        for (JsonNode day : reopened.path("days")) {
            for (JsonNode item : day.path("items")) sum += item.path("estimatedCostVnd").asLong();
        }
        assertEquals(sum, reopened.path("totalEstimatedCost").asLong());
        request(HttpMethod.PUT, "/itineraries/" + id + "/save", null, token);
        JsonNode listed = request(HttpMethod.GET, "/itineraries", null, token);
        assertTrue(listed.isArray());
        boolean found = false;
        for (JsonNode trip : listed) found |= trip.path("id").asLong() == id;
        assertTrue(found);
    }

    private JsonNode request(HttpMethod method, String path, Object body, String token) throws Exception {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        ResponseEntity<String> response = http.exchange("/api/v1" + path, method,
                new HttpEntity<>(body, headers), String.class);
        assertTrue(response.getStatusCode().is2xxSuccessful(),
                () -> method + " " + path + " returned " + response.getStatusCode());
        JsonNode envelope = mapper.readTree(response.getBody());
        assertTrue(envelope.path("success").asBoolean());
        return envelope.path("data");
    }
    private static String planningDate(int days) {
        return java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(days + 1L).toString();
    }
}
