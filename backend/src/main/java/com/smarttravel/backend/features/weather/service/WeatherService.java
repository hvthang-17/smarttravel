package com.smarttravel.backend.features.weather.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.smarttravel.backend.features.weather.dto.DailyForecastDto;
import com.smarttravel.backend.features.weather.dto.WeatherResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.time.*;
import java.util.*;

@Service
public class WeatherService {
    public static final String TIMEZONE = "Asia/Ho_Chi_Minh";
    private static final ZoneId ZONE = ZoneId.of(TIMEZONE);
    private static final Duration FRESHNESS = Duration.ofMinutes(15);
    private static final Duration MAX_STALE = Duration.ofHours(6);
    private static final String CURRENT = "temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m";
    private static final String DAILY = "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max";

    private record Key(int lat100, int lon100, String locale) {}
    private record Entry(WeatherResponse reading, Instant retryAfter) {}
    private final RestTemplate client;
    private final Clock clock;
    private final String endpoint;
    private final LinkedHashMap<Key, Entry> cache = new LinkedHashMap<>(32, .75f, true);
    private final Object[] stripes = new Object[32];

    @Autowired
    public WeatherService(RestTemplateBuilder builder,
                          @Value("${app.weather.endpoint:https://api.open-meteo.com/v1/forecast}") String endpoint) {
        this(builder.connectTimeout(Duration.ofSeconds(3)).readTimeout(Duration.ofSeconds(3)).build(),
                Clock.systemUTC(), endpoint);
    }

    public WeatherService(RestTemplate client, Clock clock, String endpoint) {
        this.client = client;
        this.clock = clock;
        this.endpoint = endpoint;
        Arrays.setAll(stripes, index -> new Object());
    }

    public WeatherResponse getDaNangWeather(Double lat, Double lon, String timezone, String locale) {
        if (!TIMEZONE.equals(timezone) || !Set.of("vi", "en").contains(locale)) {
            throw new IllegalArgumentException("Dùng timezone Asia/Ho_Chi_Minh và locale vi hoặc en");
        }
        if ((lat == null) != (lon == null) || (lat != null &&
                (!Double.isFinite(lat) || !Double.isFinite(lon) || Math.abs(lat) > 90 || Math.abs(lon) > 180))) {
            throw new IllegalArgumentException("Cần cặp tọa độ hợp lệ");
        }
        var key = new Key(bucket(lat == null ? 16.0544 : lat), bucket(lon == null ? 108.2022 : lon), locale);
        synchronized (stripes[key.hashCode() & 31]) {
            return load(key);
        }
    }

    private WeatherResponse load(Key key) {
        var now = clock.instant();
        var old = find(key);
        if (old != null) {
            var reading = old.reading();
            if (reading != null && reading.updatedAt().plus(FRESHNESS).isAfter(now)
                    && reading.validAt().plus(Duration.ofMinutes(30)).isAfter(now)) return reading.withStatus("CACHED");
            if (old.retryAfter().isAfter(now)) return fallback(reading, key, now);
        }
        try {
            var payload = client.getForObject(uri(key), JsonNode.class);
            var reading = parse(payload, key, clock.instant());
            put(key, new Entry(reading, Instant.EPOCH));
            return reading;
        } catch (RestClientException | IllegalArgumentException | DateTimeException error) {
            var reading = old == null ? null : old.reading();
            put(key, new Entry(reading, now.plusSeconds(60)));
            return fallback(reading, key, now);
        }
    }

    private URI uri(Key key) {
        return UriComponentsBuilder.fromUriString(endpoint)
                .queryParam("latitude", key.lat100() / 100.0)
                .queryParam("longitude", key.lon100() / 100.0)
                .queryParam("current", CURRENT).queryParam("daily", DAILY)
                .queryParam("timezone", TIMEZONE).queryParam("forecast_days", 7)
                .build().encode().toUri();
    }

    private static int bucket(double coordinate) {
        return (int) Math.round(coordinate * 100);
    }

    private synchronized Entry find(Key key) { return cache.get(key); }

    private synchronized void put(Key key, Entry entry) {
        cache.put(key, entry);
        if (cache.size() > 256) cache.pollFirstEntry();
    }

    private static WeatherResponse fallback(WeatherResponse previous, Key key, Instant now) {
        if (previous != null && previous.validAt().plus(MAX_STALE).isAfter(now)) {
            return previous.withStatus("STALE");
        }
        return new WeatherResponse(location(key), null, null, null, null, null, null,
                key.locale().equals("vi") ? "Chưa có dữ liệu thời tiết" : "Weather unavailable",
                null, null, null, List.of(), null, null, "UNAVAILABLE", null, TIMEZONE, key.locale());
    }

    private static WeatherResponse parse(JsonNode root, Key key, Instant now) {
        if (root == null || root.path("error").asBoolean() || !root.path("current").isObject()) {
            throw new IllegalArgumentException("Thiếu dữ liệu hiện tại");
        }
        var current = root.path("current");
        var validAt = LocalDateTime.parse(current.path("time").asText()).atZone(ZONE).toInstant();
        if (validAt.isAfter(now.plusSeconds(900)) || !validAt.plus(MAX_STALE).isAfter(now)) {
            throw new IllegalArgumentException("Mốc thời tiết nằm ngoài khoảng hợp lệ");
        }
        int code = integer(current.path("weather_code"));
        boolean day = integer(current.path("is_day")) == 1;
        double temp = number(current.path("temperature_2m"));
        var daily = daily(root.path("daily"), validAt.atZone(ZONE).toLocalDate(), key.locale());
        int rain = daily.isEmpty() ? -1 : daily.getFirst().getPrecipitationProbability();
        return new WeatherResponse(location(key), temp, number(current.path("apparent_temperature")),
                integer(current.path("relative_humidity_2m")), number(current.path("wind_speed_10m")),
                number(current.path("precipitation")), code, condition(code, key.locale()), icon(code, day), day,
                advice(code, temp, rain, key.locale()), daily, now, validAt,
                validAt.plus(Duration.ofMinutes(30)).isAfter(now) ? "FRESH" : "STALE",
                "OPEN_METEO_MODEL", TIMEZONE, key.locale());
    }

    private static List<DailyForecastDto> daily(JsonNode source, LocalDate day, String locale) {
        var result = new ArrayList<DailyForecastDto>();
        var times = source.path("time");
        for (int i = 0; i < Math.min(7, times.size()); i++) {
            try {
                var date = LocalDate.parse(times.path(i).asText());
                if (date.isBefore(day)) continue;
                int code = integer(source.path("weather_code").path(i));
                result.add(new DailyForecastDto(date.toString(),
                        number(source.path("temperature_2m_min").path(i)), number(source.path("temperature_2m_max").path(i)),
                        integer(source.path("precipitation_probability_max").path(i)), code, condition(code, locale), icon(code, true)));
            } catch (IllegalArgumentException | DateTimeException ignored) {
                // A provider may omit an individual daily value.
            }
        }
        return List.copyOf(result);
    }

    private static double number(JsonNode value) {
        if (!value.isNumber() || !Double.isFinite(value.asDouble())) throw new IllegalArgumentException("Thiếu chỉ số thời tiết");
        return value.asDouble();
    }

    private static int integer(JsonNode value) {
        if (!value.isIntegralNumber() || !value.canConvertToInt()) throw new IllegalArgumentException("Chỉ số thời tiết không hợp lệ");
        return value.asInt();
    }

    private static String location(Key key) {
        boolean danang = Math.abs(key.lat100() - 1605) <= 33 && Math.abs(key.lon100() - 10820) <= 35;
        return danang ? "Đà Nẵng" : key.locale().equals("vi") ? "Vị trí đã chọn" : "Selected location";
    }

    private static String condition(int code, String locale) {
        boolean vi = locale.equals("vi");
        if (code == 0) return vi ? "Trời quang" : "Clear sky";
        if (code <= 3) return vi ? "Có mây" : "Cloudy";
        if (code == 45 || code == 48) return vi ? "Có sương mù" : "Fog";
        if (code >= 95) return vi ? "Có dông" : "Thunderstorm";
        if (code >= 71 && code <= 86 && (code < 80 || code >= 85)) return vi ? "Có tuyết" : "Snow";
        if (code >= 51) return vi ? "Có mưa" : "Rain";
        return vi ? "Chưa phân loại" : "Unclassified";
    }

    private static String icon(int code, boolean daylight) {
        if (code == 0) return daylight ? "☀️" : "🌙";
        if (code <= 3) return "☁️";
        if (code == 45 || code == 48) return "🌫️";
        return code >= 95 ? "⛈️" : "🌧️";
    }

    private static String advice(int code, double temp, int rain, String locale) {
        boolean vi = locale.equals("vi");
        if (code >= 95 || rain >= 70) return vi ? "Ưu tiên hoạt động trong nhà và kiểm tra cảnh báo thời tiết."
                : "Consider indoor activities and check local weather alerts.";
        if (code >= 51) return vi ? "Chuẩn bị áo mưa và kiểm tra lại trước khi đi." : "Bring rain protection and check the forecast before leaving.";
        if (temp >= 34) return vi ? "Ưu tiên giờ mát và mang theo nước." : "Choose cooler hours and bring water.";
        return vi ? "Kiểm tra dự báo trước các hoạt động ngoài trời." : "Check the forecast before outdoor activities.";
    }
}
