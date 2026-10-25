package com.smarttravel.backend.features.destination.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public class DestinationDto {
    private Long id;

    @NotBlank(message = "Name is required")
    @Size(max = 180, message = "Name must not exceed 180 characters")
    private String name;

    @NotBlank(message = "Category is required")
    @Size(max = 40, message = "Category must not exceed 40 characters")
    private String category;

    private String description;

    @Size(max = 255, message = "Address must not exceed 255 characters")
    private String address;

    @Size(max = 100, message = "Opening hours must not exceed 100 characters")
    private String openingHours;

    @Size(max = 50, message = "Phone must not exceed 50 characters")
    private String phone;

    @Size(max = 255, message = "Website must not exceed 255 characters")
    private String website;

    @Size(max = 500, message = "ImageUrl must not exceed 500 characters")
    private String imageUrl;

    @DecimalMin(value = "0.0", message = "Rating must be at least 0.0")
    @DecimalMax(value = "5.0", message = "Rating must not exceed 5.0")
    private BigDecimal rating;

    @Min(value = 0, message = "Review count must be at least 0")
    private Integer reviewCount;

    @Size(max = 50, message = "OSM ID must not exceed 50 characters")
    private String osmId;

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

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getOpeningHours() { return openingHours; }
    public void setOpeningHours(String openingHours) { this.openingHours = openingHours; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getWebsite() { return website; }
    public void setWebsite(String website) { this.website = website; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public BigDecimal getRating() { return rating; }
    public void setRating(BigDecimal rating) { this.rating = rating; }

    public Integer getReviewCount() { return reviewCount; }
    public void setReviewCount(Integer reviewCount) { this.reviewCount = reviewCount; }

    public String getOsmId() { return osmId; }
    public void setOsmId(String osmId) { this.osmId = osmId; }

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
