package com.smarttravel.backend.features.weather;

import com.smarttravel.backend.features.weather.service.WeatherService;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import java.time.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.queryParam;
import static org.springframework.test.web.client.response.MockRestResponseCreators.*;

class WeatherServiceTest {
    private static final String ZONE = WeatherService.TIMEZONE;
    private static final String FIXTURE = """
            {"current":{"time":"2026-11-16T08:00","temperature_2m":27.4,"apparent_temperature":29.5,
             "relative_humidity_2m":81,"wind_speed_10m":6.3,"precipitation":0.2,"weather_code":3,"is_day":1},
             "daily":{"time":["2026-11-16"],"temperature_2m_min":[23.5],"temperature_2m_max":[29.3],
             "precipitation_probability_max":[41],"weather_code":[61]}}
            """;
    private final RestTemplate template = new RestTemplate();
    private final MockRestServiceServer server = MockRestServiceServer.bindTo(template).build();
    private final MutableClock clock = new MutableClock();
    private final WeatherService weather = new WeatherService(template, clock, "https://weather.fixture.test/forecast");

    @Test void currentUsesSingleEncodedTimezoneAndRetainsModelDateAcrossCacheAndStale() {
        server.expect(queryParam("timezone", ZONE)).andExpect(queryParam("latitude", "16.05"))
                .andRespond(withSuccess(FIXTURE, MediaType.APPLICATION_JSON));
        server.expect(queryParam("timezone", ZONE)).andRespond(withServerError());
        server.expect(queryParam("timezone", ZONE)).andRespond(withServerError());

        var latest = weather.getDaNangWeather(null, null, ZONE, "vi");
        assertEquals("FRESH", latest.status());
        assertEquals("OPEN_METEO_MODEL", latest.source());
        assertEquals(Instant.parse("2026-11-16T01:00:00Z"), latest.validAt());
        assertEquals(27.4, latest.temperature());
        assertEquals(41, latest.dailyForecast().getFirst().getPrecipitationProbability());
        assertEquals("CACHED", weather.getDaNangWeather(16.054, 108.202, ZONE, "vi").status());
        clock.now = clock.now.plus(Duration.ofMinutes(20));
        var stale = weather.getDaNangWeather(null, null, ZONE, "vi");
        assertEquals("STALE", stale.status());
        assertEquals(latest.updatedAt(), stale.updatedAt());
        assertEquals(latest.validAt(), stale.validAt());
        assertEquals(stale, weather.getDaNangWeather(null, null, ZONE, "vi"));
        clock.now = clock.now.plus(Duration.ofHours(6));
        var missing = weather.getDaNangWeather(null, null, ZONE, "vi");
        assertEquals("UNAVAILABLE", missing.status());
        assertNull(missing.temperature());
        assertNull(missing.validAt());
        assertTrue(missing.dailyForecast().isEmpty());
        server.verify();
    }

    @Test void malformedSourceAndInvalidParametersCannotProduceInventedWeather() {
        assertThrows(IllegalArgumentException.class, () -> weather.getDaNangWeather(null, null, "UTC", "vi"));
        assertThrows(IllegalArgumentException.class, () -> weather.getDaNangWeather(null, null, ZONE, "fr"));
        assertThrows(IllegalArgumentException.class, () -> weather.getDaNangWeather(16.0, null, ZONE, "vi"));
        assertThrows(IllegalArgumentException.class, () -> weather.getDaNangWeather(Double.NaN, 108.2, ZONE, "vi"));
        server.expect(queryParam("timezone", ZONE)).andRespond(withSuccess("{\"current\":{}}", MediaType.APPLICATION_JSON));
        var result = weather.getDaNangWeather(null, null, ZONE, "en");
        assertEquals("UNAVAILABLE", result.status());
        assertNull(result.humidity());
        assertNull(result.updatedAt());
        assertEquals("Weather unavailable", result.condition());
        server.verify();
    }

    private static class MutableClock extends Clock {
        private Instant now = Instant.parse("2026-11-16T01:05:00Z");
        @Override public ZoneId getZone() { return ZoneOffset.UTC; }
        @Override public Clock withZone(ZoneId zone) { return Clock.fixed(now, zone); }
        @Override public Instant instant() { return now; }
    }
}
