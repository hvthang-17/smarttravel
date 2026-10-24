package com.smarttravel.backend.features.weather.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarttravel.backend.features.weather.dto.DailyForecastDto;
import com.smarttravel.backend.features.weather.dto.WeatherResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class WeatherService {

    private static final Logger log = LoggerFactory.getLogger(WeatherService.class);

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    private static class CachedEntry {
        final WeatherResponse response;
        final long timestamp;

        CachedEntry(WeatherResponse response, long timestamp) {
            this.response = response;
            this.timestamp = timestamp;
        }
    }

    // In-memory 15-minute cache keyed by rounded coordinates
    private final Map<String, CachedEntry> cacheMap = new ConcurrentHashMap<>();
    private static final long CACHE_DURATION_MS = 15 * 60 * 1000;

    public WeatherService(RestTemplateBuilder restTemplateBuilder, ObjectMapper objectMapper) {
        this.restTemplate = restTemplateBuilder
                .setConnectTimeout(Duration.ofSeconds(4))
                .setReadTimeout(Duration.ofSeconds(4))
                .build();
        this.objectMapper = objectMapper;
    }

    public WeatherResponse getDaNangWeather() {
        return getDaNangWeather(null, null);
    }

    public synchronized WeatherResponse getDaNangWeather(Double lat, Double lon) {
        double targetLat = (lat != null && lat >= -90 && lat <= 90) ? lat : 16.0544;
        double targetLon = (lon != null && lon >= -180 && lon <= 180) ? lon : 108.2022;
        String cacheKey = String.format("%.2f_%.2f", targetLat, targetLon);

        long now = System.currentTimeMillis();
        CachedEntry entry = cacheMap.get(cacheKey);
        if (entry != null && (now - entry.timestamp < CACHE_DURATION_MS)) {
            return entry.response;
        }

        String locationName = resolveLocationName(targetLat, targetLon);
        String url = String.format(
                "https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=Asia%%2FBangkok",
                targetLat, targetLon
        );

        try {
            String jsonStr = restTemplate.getForObject(url, String.class);
            if (jsonStr != null) {
                JsonNode root = objectMapper.readTree(jsonStr);
                WeatherResponse response = parseOpenMeteoResponse(root, locationName);
                cacheMap.put(cacheKey, new CachedEntry(response, now));
                return response;
            }
        } catch (Exception ex) {
            log.warn("Could not fetch live weather from Open-Meteo for ({}, {}): {}. Using fallback/cached.",
                    targetLat, targetLon, ex.getMessage());
        }

        if (entry != null) {
            return entry.response;
        }

        return createFallbackWeather(locationName);
    }

    public static String resolveLocationName(double lat, double lon) {
        if (distanceKm(lat, lon, 15.9988, 107.9880) < 8.0) return "Bà Nà Hills, Đà Nẵng";
        if (distanceKm(lat, lon, 16.1150, 108.2750) < 7.0) return "Bán đảo Sơn Trà, Đà Nẵng";
        if (distanceKm(lat, lon, 16.0590, 108.2430) < 4.0) return "Biển Mỹ Khê, Đà Nẵng";
        if (distanceKm(lat, lon, 16.0040, 108.2630) < 5.0) return "Ngũ Hành Sơn, Đà Nẵng";
        if (distanceKm(lat, lon, 16.0610, 108.2230) < 4.0) return "Hải Châu, Đà Nẵng";
        if (distanceKm(lat, lon, 16.0544, 108.2022) < 35.0) return "Vị trí của bạn (Đà Nẵng)";
        return "Đà Nẵng";
    }

    private static double distanceKm(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private WeatherResponse parseOpenMeteoResponse(JsonNode root, String locationName) {
        JsonNode current = root.path("current");
        double temp = current.path("temperature_2m").asDouble(28.5);
        double apparentTemp = current.path("apparent_temperature").asDouble(temp + 2);
        int humidity = current.path("relative_humidity_2m").asInt(75);
        double windSpeed = current.path("wind_speed_10m").asDouble(10.0);
        double precipitation = current.path("precipitation").asDouble(0.0);
        int weatherCode = current.path("weather_code").asInt(1);
        boolean isDay = current.path("is_day").asInt(1) == 1;

        String condition = mapWeatherCodeToCondition(weatherCode);
        String icon = mapWeatherCodeToIcon(weatherCode, isDay);

        // Daily forecast parsing
        List<DailyForecastDto> dailyForecast = new ArrayList<>();
        JsonNode daily = root.path("daily");
        JsonNode times = daily.path("time");
        JsonNode codes = daily.path("weather_code");
        JsonNode maxTemps = daily.path("temperature_2m_max");
        JsonNode minTemps = daily.path("temperature_2m_min");
        JsonNode rainProbs = daily.path("precipitation_probability_max");

        int count = Math.min(times.size(), 7);
        int todayRainProb = 0;
        for (int i = 0; i < count; i++) {
            String date = times.path(i).asText();
            int dayCode = codes.path(i).asInt(0);
            double maxT = maxTemps.path(i).asDouble(30.0);
            double minT = minTemps.path(i).asDouble(24.0);
            int rainProb = rainProbs.path(i).asInt(0);
            if (i == 0) todayRainProb = rainProb;

            String dayCondition = mapWeatherCodeToCondition(dayCode);
            String dayIcon = mapWeatherCodeToIcon(dayCode, true);

            dailyForecast.add(new DailyForecastDto(
                    date, minT, maxT, rainProb, dayCode, dayCondition, dayIcon
            ));
        }

        String advice = generateTravelAdvice(weatherCode, temp, todayRainProb);
        String updatedAt = DateTimeFormatter.ofPattern("HH:mm - dd/MM/yyyy")
                .withZone(ZoneId.of("Asia/Bangkok"))
                .format(Instant.now());

        return new WeatherResponse(
                locationName,
                temp,
                apparentTemp,
                humidity,
                windSpeed,
                precipitation,
                weatherCode,
                condition,
                icon,
                isDay,
                advice,
                dailyForecast,
                updatedAt
        );
    }

    private WeatherResponse createFallbackWeather(String locationName) {
        String updatedAt = DateTimeFormatter.ofPattern("HH:mm - dd/MM/yyyy")
                .withZone(ZoneId.of("Asia/Bangkok"))
                .format(Instant.now());

        List<DailyForecastDto> fallbackDaily = List.of(
                new DailyForecastDto("Hôm nay", 24.0, 31.0, 10, 1, "Nắng ráo", "🌤️"),
                new DailyForecastDto("Ngày mai", 24.5, 30.5, 20, 2, "Ít mây", "⛅"),
                new DailyForecastDto("Hôm kia", 24.0, 29.5, 45, 51, "Mưa rào nhẹ", "🌦️"),
                new DailyForecastDto("Thứ sáu", 23.5, 29.0, 30, 2, "Dịu mát", "⛅"),
                new DailyForecastDto("Thứ bảy", 24.0, 30.0, 15, 1, "Nắng đẹp", "☀️")
        );

        return new WeatherResponse(
                locationName != null ? locationName : "Đà Nẵng",
                29.0,
                32.5,
                72,
                8.5,
                0.0,
                1,
                "Nắng ráo dịu nhẹ",
                "🌤️",
                true,
                "Thời tiết Đà Nẵng nắng ráo rất đẹp! Rất thích hợp để tham quan Bán đảo Sơn Trà, Ngũ Hành Sơn, Bà Nà Hills và ngắm hoàng hôn biển Mỹ Khê.",
                fallbackDaily,
                updatedAt
        );
    }

    public static String mapWeatherCodeToCondition(int code) {
        if (code == 0) return "Trời quang đãng";
        if (code == 1) return "Chủ yếu quang mây";
        if (code == 2) return "Mây rải rác";
        if (code == 3) return "Nhiều mây";
        if (code == 45 || code == 48) return "Có sương mù";
        if (code >= 51 && code <= 55) return "Mưa phùn nhẹ";
        if (code >= 61 && code <= 65) return "Mưa rào rải rác";
        if (code >= 80 && code <= 82) return "Mưa rào từng cơn";
        if (code >= 95) return "Có dông sét";
        return "Thời tiết dịu mát";
    }

    public static String mapWeatherCodeToIcon(int code, boolean isDay) {
        if (code == 0) return isDay ? "☀️" : "🌙";
        if (code == 1 || code == 2) return isDay ? "🌤️" : "☁️";
        if (code == 3) return "☁️";
        if (code == 45 || code == 48) return "🌫️";
        if (code >= 51 && code <= 55) return "🌦️";
        if (code >= 61 && code <= 65) return "🌧️";
        if (code >= 80 && code <= 82) return "⛈️";
        if (code >= 95) return "🌩️";
        return "⛅";
    }

    public static String generateTravelAdvice(int code, double temp, int rainProb) {
        if (code >= 80 || rainProb >= 70) {
            return "Thời tiết có thể có mưa to hoặc dông. Bạn nên ưu tiên các điểm tham quan trong nhà như Bảo tàng Điêu khắc Chăm, Chợ Cồn hoặc các quán cà phê ngắm cảnh sông Hàn.";
        }
        if (code >= 51 && code <= 65) {
            return "Có mưa nhẹ hoặc mưa rào rải rác. Hãy mang theo ô/áo mưa khi dạo phố Bạch Đằng và lưu ý đường trơn khi lên Bán đảo Sơn Trà.";
        }
        if (temp >= 34) {
            return "Thời tiết nắng nóng, thích hợp tắm biển Mỹ Khê vào sáng sớm hoặc chiều mát. Buổi trưa nên ghé các không gian nghỉ mát hoặc thưởng thức đặc sản Đà Nẵng.";
        }
        if (code <= 2) {
            return "Thời tiết nắng ráo rất đẹp! Rất thích hợp để tham quan Bán đảo Sơn Trà, Ngũ Hành Sơn, Bà Nà Hills và ngắm hoàng hôn biển Mỹ Khê.";
        }
        return "Thời tiết mát mẻ dễ chịu, rất thích hợp cho mọi hoạt động khám phá và dạo phố Đà Nẵng hôm nay.";
    }
}
