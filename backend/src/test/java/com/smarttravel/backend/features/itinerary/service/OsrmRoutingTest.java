package com.smarttravel.backend.features.itinerary.service;

import com.sun.net.httpserver.HttpServer;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.domain.ItineraryDay;
import com.smarttravel.backend.features.itinerary.domain.ItineraryItem;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;

class OsrmRoutingTest {
    private static final String ROUTE = """
            {"code":"Ok","routes":[{"distance":1240.3,"duration":152.4,"geometry":{
            "type":"LineString","coordinates":[[108.2,16.05],[108.21,16.06],[108.23,16.05]]}}]}
            """;
    private static final String MATRIX = """
            {"code":"Ok","durations":[[0,152],[null,0]],"distances":[[0,1240],[null,0]]}
            """;
    private final OsrmRouting.Point origin = point("16.05", "108.2");
    private final OsrmRouting.Point stop = point("16.05", "108.23");
    private final AtomicReference<String> path = new AtomicReference<>();
    private final AtomicReference<String> auth = new AtomicReference<>();
    private final AtomicInteger calls = new AtomicInteger();
    private final AtomicInteger status = new AtomicInteger(200);
    private final AtomicReference<String> route = new AtomicReference<>(ROUTE);
    private HttpServer server;

    @BeforeEach
    void start() throws IOException {
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/", exchange -> {
            try (exchange) {
                calls.incrementAndGet();
                path.set(exchange.getRequestURI().toString());
                auth.set(exchange.getRequestHeaders().getFirst("Authorization"));
                byte[] bytes = (path.get().contains("/table/") ? MATRIX : route.get()).getBytes(StandardCharsets.UTF_8);
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(status.get(), bytes.length);
                exchange.getResponseBody().write(bytes);
            }
        });
        server.start();
    }

    @AfterEach
    void stop() {
        server.stop(0);
    }

    @Test
    void directionsCacheKeepsProviderMetricsAndGeometryAndUsesSelectedProfile() {
        var routing = adapter(5);
        var leg = routing.directions(origin, stop, "taxi", true);
        assertThat(path.get()).startsWith("/car/route/v1/driving/108.2,16.05;108.23,16.05?");
        assertThat(auth.get()).isEqualTo("Bearer test-token");
        assertThat(leg).isNotNull();
        assertThat(leg.source()).isEqualTo("PROVIDER");
        assertThat(leg.meters()).isEqualTo(1240);
        assertThat(leg.seconds()).isEqualTo(152);
        assertThat(routing.directions(origin, stop, "car", false))
                .isEqualTo(new OsrmRouting.Leg(leg.meters(), leg.seconds(), leg.geometry(), "CACHE"));
        assertThat(calls.get()).isEqualTo(1);
        assertThat(routing.matrix(List.of(origin, stop), "walking").path("distances").path(1).path(0).isNull()).isTrue();
        assertThat(path.get()).startsWith("/foot/table/v1/walking/");
        assertThat(routing.matrix(List.of(origin, stop), "walking").path("durations").path(0).path(1).asInt())
                .isEqualTo(152);
        assertThat(routing.directions(origin, stop, "motorbike", true)).isNull();
        assertThat(calls.get()).isEqualTo(2);
    }

    @Test
    void localQuotaAndProvider429KeepCacheButSkipNewRequests() {
        var limited = adapter(1);
        assertThat(limited.directions(origin, stop, "car", true)).isNotNull();
        assertThat(limited.directions(stop, origin, "car", true)).isNull();
        var routing = adapter(10);
        assertThat(routing.directions(origin, stop, "car", true)).isNotNull();
        status.set(429);
        assertThat(routing.directions(stop, origin, "car", true)).isNull();
        assertThat(routing.matrix(List.of(origin, stop), "car")).isNull();
        assertThat(routing.directions(origin, stop, "car", true).source()).isEqualTo("CACHE");
        assertThat(calls.get()).isEqualTo(3);
    }

    @Test
    void errorsAndMalformedGeometryNeverProduceProviderLeg() {
        var routing = adapter(10);
        route.set("{\"code\":\"NoRoute\"}");
        assertThat(routing.directions(origin, stop, "car", true)).isNull();
        route.set(ROUTE.replace("[108.21,16.06]", "[200,16.06]"));
        assertThat(routing.directions(origin, stop, "car", true)).isNull();
        status.set(503);
        assertThat(routing.directions(origin, stop, "car", true)).isNull();
        assertThat(routing.directions(origin, stop, "car", true)).isNull();
        assertThat(calls.get()).isEqualTo(3);
    }

    @Test
    void calculationUsesOriginAndPreviousStopInSequenceWithoutBridgingMissingCoordinates() {
        var plan = new Itinerary();
        plan.setTransport("car");
        plan.setTravelersCount(2);
        plan.setOriginLatitude(origin.lat());
        plan.setOriginLongitude(origin.lon());
        var day = new ItineraryDay();
        plan.getDays().add(day);
        var first = item(1, stop);
        var missing = item(2, null);
        var afterMissing = item(3, origin);
        var last = item(4, stop);
        day.getItems().addAll(List.of(last, first, missing, afterMissing));
        new ItineraryCalculation(adapter(5)).recalculate(plan);
        assertThat(first.getRouteSource()).isEqualTo("PROVIDER");
        assertThat(first.getTravelDistanceM()).isEqualTo(1240);
        assertThat(first.getTravelDurationSeconds()).isEqualTo(152);
        assertThat(last.getRouteSource()).isEqualTo("CACHE");
        assertThat(last.getRoutePolyline()).isEqualTo(first.getRoutePolyline());
        for (var item : List.of(missing, afterMissing)) {
            assertThat(item.getRouteSource()).isEqualTo("UNKNOWN");
            assertThat(item.getRoutePolyline()).isNull();
            assertThat(item.getTravelDistanceM()).isNull();
            assertThat(item.getTravelDurationSeconds()).isNull();
        }
        status.set(503);
        new ItineraryCalculation(adapter(5)).recalculate(plan);
        assertThat(first.getRouteSource()).isEqualTo("HAVERSINE");
        assertThat(first.getRoutePolyline()).isNull();
        assertThat(first.getTravelDistanceM()).isPositive();
        assertThat(first.getTravelDurationSeconds()).isPositive();
        assertThat(calls.get()).isEqualTo(2);
    }

    private static ItineraryItem item(int sequence, OsrmRouting.Point point) {
        var item = new ItineraryItem();
        item.setSequenceOrder(sequence);
        if (point != null) {
            item.setLatitude(point.lat());
            item.setLongitude(point.lon());
        }
        return item;
    }

    private OsrmRouting adapter(int limit) {
        String base = "http://127.0.0.1:" + server.getAddress().getPort();
        return new OsrmRouting(base + "/car", base + "/foot", "", "test-token", limit);
    }

    private static OsrmRouting.Point point(String lat, String lon) {
        return new OsrmRouting.Point(new BigDecimal(lat), new BigDecimal(lon));
    }
}
