package com.smarttravel.backend.features.weather.dto;

import java.util.List;

public class WeatherResponse {
    private String cityName = "Đà Nẵng";
    private double temperature;
    private double apparentTemperature;
    private int humidity;
    private double windSpeed;
    private double precipitation;
    private int weatherCode;
    private String condition;
    private String icon;
    private boolean isDay;
    private String travelAdvice;
    private List<DailyForecastDto> dailyForecast;
    private String updatedAt;

    public WeatherResponse() {}

    public WeatherResponse(String cityName, double temperature, double apparentTemperature, int humidity,
                           double windSpeed, double precipitation, int weatherCode, String condition,
                           String icon, boolean isDay, String travelAdvice,
                           List<DailyForecastDto> dailyForecast, String updatedAt) {
        this.cityName = cityName;
        this.temperature = temperature;
        this.apparentTemperature = apparentTemperature;
        this.humidity = humidity;
        this.windSpeed = windSpeed;
        this.precipitation = precipitation;
        this.weatherCode = weatherCode;
        this.condition = condition;
        this.icon = icon;
        this.isDay = isDay;
        this.travelAdvice = travelAdvice;
        this.dailyForecast = dailyForecast;
        this.updatedAt = updatedAt;
    }

    public String getCityName() { return cityName; }
    public void setCityName(String cityName) { this.cityName = cityName; }

    public double getTemperature() { return temperature; }
    public void setTemperature(double temperature) { this.temperature = temperature; }

    public double getApparentTemperature() { return apparentTemperature; }
    public void setApparentTemperature(double apparentTemperature) { this.apparentTemperature = apparentTemperature; }

    public int getHumidity() { return humidity; }
    public void setHumidity(int humidity) { this.humidity = humidity; }

    public double getWindSpeed() { return windSpeed; }
    public void setWindSpeed(double windSpeed) { this.windSpeed = windSpeed; }

    public double getPrecipitation() { return precipitation; }
    public void setPrecipitation(double precipitation) { this.precipitation = precipitation; }

    public int getWeatherCode() { return weatherCode; }
    public void setWeatherCode(int weatherCode) { this.weatherCode = weatherCode; }

    public String getCondition() { return condition; }
    public void setCondition(String condition) { this.condition = condition; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public boolean isDay() { return isDay; }
    public void setDay(boolean day) { isDay = day; }

    public String getTravelAdvice() { return travelAdvice; }
    public void setTravelAdvice(String travelAdvice) { this.travelAdvice = travelAdvice; }

    public List<DailyForecastDto> getDailyForecast() { return dailyForecast; }
    public void setDailyForecast(List<DailyForecastDto> dailyForecast) { this.dailyForecast = dailyForecast; }

    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
