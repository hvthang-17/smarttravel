package com.smarttravel.backend.features.weather.dto;

import java.time.Instant;
import java.util.List;

public record WeatherResponse(String cityName, Double temperature, Double apparentTemperature, Integer humidity,
                              Double windSpeed, Double precipitation, Integer weatherCode, String condition,
                              String icon, Boolean isDay, String travelAdvice, List<DailyForecastDto> dailyForecast,
                              Instant updatedAt, Instant validAt, String status, String source,
                              String timezone, String locale) {
    public WeatherResponse withStatus(String value) {
        return new WeatherResponse(cityName, temperature, apparentTemperature, humidity, windSpeed, precipitation,
                weatherCode, condition, icon, isDay, travelAdvice, dailyForecast, updatedAt, validAt, value, source,
                timezone, locale);
    }
}
