package com.smarttravel.backend.features.itinerary.service;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

import java.math.BigDecimal;
import java.net.URI;
import java.time.Duration;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
final class OsrmRouting {
    record Point(BigDecimal lat, BigDecimal lon) {
        String coordinate() {
            return lon.stripTrailingZeros().toPlainString() + "," + lat.stripTrailingZeros().toPlainString();
        }
    }
    record Leg(int meters, int seconds, String geometry, String source) {}
    private record Profile(String endpoint, String name) {}
    private record Cached<T>(T value, Instant expires) {}

    private final Map<String, Profile> profiles;
    private final RestClient client;
    private final int requestsPerMinute;
    private final LinkedHashMap<String, Cached<Leg>> directionsCache = new LinkedHashMap<>(16, 0.75f, true);
    private final LinkedHashMap<String, Cached<JsonNode>> matrixCache = new LinkedHashMap<>(16, 0.75f, true);
    private Instant windowEnd = Instant.EPOCH;
    private Instant pausedUntil = Instant.EPOCH;
    private int requests;

    OsrmRouting(@Value("${app.routing.car-url:}") String car,
                @Value("${app.routing.foot-url:}") String foot,
                @Value("${app.routing.motorbike-url:}") String motorbike,
                @Value("${app.routing.token:}") String token,
                @Value("${app.routing.requests-per-minute:30}") int limit) {
        profiles = Map.of("car", new Profile(car, "driving"), "taxi", new Profile(car, "driving"),
                "walking", new Profile(foot, "walking"), "motorbike", new Profile(motorbike, "motorbike"));
        requestsPerMinute = Math.max(0, limit);
        var factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(Duration.ofMillis(500));
        factory.setReadTimeout(Duration.ofMillis(800));
        var builder = RestClient.builder().requestFactory(factory);
        if (!token.isBlank()) builder.defaultHeader("Authorization", "Bearer " + token);
        client = builder.build();
    }

    Leg directions(Point from, Point to, String transport, boolean allowNetwork) {
        var profile = profiles.get(transport);
        if (profile == null || profile.endpoint().isBlank()) return null;
        String coordinates = from.coordinate() + ";" + to.coordinate();
        String url = url(profile, "route", coordinates, "overview=simplified&geometries=geojson");
        var hit = cacheHit(directionsCache, url);
        if (hit != null) {
            return new Leg(hit.meters(), hit.seconds(), hit.geometry(), "CACHE");
        }
        if (!allowNetwork) return null;
        var body = request(url);
        if (body == null) return null;
        var route = body.path("routes").path(0);
        var geometry = route.path("geometry");
        var points = geometry.path("coordinates");
        if (!"LineString".equals(geometry.path("type").asText()) || !points.isArray()
                || points.size() < 2 || points.size() > 10_000) return null;
        for (var point : points) {
            if (!point.isArray() || point.size() != 2
                    || !coordinate(point.get(0), 180) || !coordinate(point.get(1), 90)) return null;
        }
        var meters = metric(route.path("distance"));
        var seconds = metric(route.path("duration"));
        if (meters == null || seconds == null) return null;
        var leg = new Leg(meters, seconds, points.toString(), "PROVIDER");
        remember(directionsCache, url, leg, 512);
        return leg;
    }

    JsonNode matrix(List<Point> points, String transport) {
        var profile = profiles.get(transport);
        if (profile == null || profile.endpoint().isBlank() || points.size() < 2 || points.size() > 25) return null;
        var coordinates = points.stream().map(Point::coordinate).collect(Collectors.joining(";"));
        String url = url(profile, "table", coordinates, "annotations=duration,distance");
        var hit = cacheHit(matrixCache, url);
        if (hit != null) return hit.deepCopy();
        var body = request(url);
        if (body == null || !validMatrix(body.path("durations"), points.size())
                || !validMatrix(body.path("distances"), points.size())) return null;
        remember(matrixCache, url, body.deepCopy(), 64);
        return body;
    }

    private synchronized <T> T cacheHit(LinkedHashMap<String, Cached<T>> cache, String url) {
        var hit = cache.get(url);
        if (hit != null && hit.expires().isAfter(Instant.now())) return hit.value();
        cache.remove(url);
        return null;
    }

    private synchronized <T> void remember(LinkedHashMap<String, Cached<T>> cache, String url, T value, int maxEntries) {
        cache.put(url, new Cached<>(value, Instant.now().plus(Duration.ofHours(1))));
        if (cache.size() > maxEntries) cache.pollFirstEntry();
    }

    private static boolean validMatrix(JsonNode rows, int size) {
        if (!rows.isArray() || rows.size() != size) return false;
        for (var row : rows) {
            if (!row.isArray() || row.size() != size) return false;
            for (var cell : row) if (!cell.isNull() && metric(cell) == null) return false;
        }
        return true;
    }

    private static String url(Profile profile, String service, String coordinates, String query) {
        return profile.endpoint().replaceFirst("/+$", "") + "/" + service + "/v1/"
                + profile.name() + "/" + coordinates + "?" + query;
    }

    private JsonNode request(String url) {
        if (!admit()) return null;
        try {
            var response = client.get().uri(URI.create(url)).retrieve().body(JsonNode.class);
            return response != null && "Ok".equals(response.path("code").asText()) ? response : null;
        } catch (RestClientResponseException e) {
            if (e.getStatusCode().value() == 429 || e.getStatusCode().is5xxServerError()) pause();
            return null;
        } catch (RestClientException | IllegalArgumentException e) {
            pause();
            return null;
        }
    }

    private synchronized boolean admit() {
        var now = Instant.now();
        if (now.isBefore(pausedUntil)) return false;
        if (!now.isBefore(windowEnd)) {
            windowEnd = now.plusSeconds(60);
            requests = 0;
        }
        if (requests >= requestsPerMinute) return false;
        requests++;
        return true;
    }

    private synchronized void pause() {
        pausedUntil = Instant.now().plusSeconds(60);
    }

    private static Integer metric(JsonNode value) {
        double number = value.asDouble(-1);
        return value.isNumber() && number >= 0 && number <= Integer.MAX_VALUE ? (int) Math.round(number) : null;
    }

    private static boolean coordinate(JsonNode value, int max) {
        return value.isNumber() && Math.abs(value.asDouble()) <= max;
    }
}
