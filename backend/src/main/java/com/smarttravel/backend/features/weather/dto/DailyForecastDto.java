package com.smarttravel.backend.features.weather.dto;

public class DailyForecastDto {
    private String date;
    private double minTemp;
    private double maxTemp;
    private int precipitationProbability;
    private int weatherCode;
    private String condition;
    private String icon;

    public DailyForecastDto() {}

    public DailyForecastDto(String date, double minTemp, double maxTemp, int precipitationProbability, int weatherCode, String condition, String icon) {
        this.date = date;
        this.minTemp = minTemp;
        this.maxTemp = maxTemp;
        this.precipitationProbability = precipitationProbability;
        this.weatherCode = weatherCode;
        this.condition = condition;
        this.icon = icon;
    }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public double getMinTemp() { return minTemp; }
    public void setMinTemp(double minTemp) { this.minTemp = minTemp; }

    public double getMaxTemp() { return maxTemp; }
    public void setMaxTemp(double maxTemp) { this.maxTemp = maxTemp; }

    public int getPrecipitationProbability() { return precipitationProbability; }
    public void setPrecipitationProbability(int precipitationProbability) { this.precipitationProbability = precipitationProbability; }

    public int getWeatherCode() { return weatherCode; }
    public void setWeatherCode(int weatherCode) { this.weatherCode = weatherCode; }

    public String getCondition() { return condition; }
    public void setCondition(String condition) { this.condition = condition; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
}
