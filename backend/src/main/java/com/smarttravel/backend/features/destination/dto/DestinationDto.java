package com.smarttravel.backend.features.destination.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class DestinationDto {
    private Long id;

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Category is required")
    private String category;

    private String description;

    @NotNull(message = "Latitude is required")
    @DecimalMin(value = "-90.0", message = "Latitude must be greater than or equal to -90.0")
    @DecimalMax(value = "90.0", message = "Latitude must be less than or equal to 90.0")
    private BigDecimal latitude;

    @NotNull(message = "Longitude is required")
    @DecimalMin(value = "-180.0", message = "Longitude must be greater than or equal to -180.0")
    @DecimalMax(value = "180.0", message = "Longitude must be less than or equal to 180.0")
    private BigDecimal longitude;

    @Min(value = 0, message = "priceMinVnd must be greater than or equal to 0")
    private Long priceMinVnd;

    @Min(value = 0, message = "priceMaxVnd must be greater than or equal to 0")
    private Long priceMaxVnd;

    private String status;

    public DestinationDto() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }
    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }
    public Long getPriceMinVnd() { return priceMinVnd; }
    public void setPriceMinVnd(Long priceMinVnd) { this.priceMinVnd = priceMinVnd; }
    public Long getPriceMaxVnd() { return priceMaxVnd; }
    public void setPriceMaxVnd(Long priceMaxVnd) { this.priceMaxVnd = priceMaxVnd; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}

