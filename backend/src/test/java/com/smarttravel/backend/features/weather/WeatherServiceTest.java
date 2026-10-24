package com.smarttravel.backend.features.weather;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarttravel.backend.features.weather.dto.WeatherResponse;
import com.smarttravel.backend.features.weather.service.WeatherService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.web.client.RestTemplateBuilder;

import static org.junit.jupiter.api.Assertions.*;

class WeatherServiceTest {

    private WeatherService weatherService;

    @BeforeEach
    void setUp() {
        weatherService = new WeatherService(new RestTemplateBuilder(), new ObjectMapper());
    }

    @Test
    void testTravelAdviceGeneration() {
        String sunnyAdvice = WeatherService.generateTravelAdvice(0, 28.0, 10);
        assertTrue(sunnyAdvice.contains("Bán đảo Sơn Trà") || sunnyAdvice.contains("nắng ráo"));

        String rainyAdvice = WeatherService.generateTravelAdvice(80, 26.0, 80);
        assertTrue(rainyAdvice.contains("mưa to") || rainyAdvice.contains("Bảo tàng Điêu khắc Chăm"));
    }

    @Test
    void testFallbackWeatherNotNull() {
        WeatherResponse response = weatherService.getDaNangWeather();
        assertNotNull(response);
        assertTrue(response.getCityName().contains("Đà Nẵng"));
        assertTrue(response.getTemperature() > 0);
        assertNotNull(response.getCondition());
        assertNotNull(response.getDailyForecast());
        assertFalse(response.getDailyForecast().isEmpty());
    }
}
