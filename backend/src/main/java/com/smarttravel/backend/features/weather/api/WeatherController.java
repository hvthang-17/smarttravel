package com.smarttravel.backend.features.weather.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.weather.dto.WeatherResponse;
import com.smarttravel.backend.features.weather.service.WeatherService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/weather")
public class WeatherController {

    private final WeatherService weatherService;

    public WeatherController(WeatherService weatherService) {
        this.weatherService = weatherService;
    }

    @GetMapping({"/current", "/danang"})
    public ResponseEntity<ApiResponse<WeatherResponse>> getCurrentWeather(
            @RequestParam(value = "lat", required = false) Double lat,
            @RequestParam(value = "lon", required = false) Double lon) {
        WeatherResponse weather = weatherService.getDaNangWeather(lat, lon);
        return ResponseEntity.ok(ApiResponse.success(weather, "Lấy thông tin thời tiết thành công"));
    }
}
