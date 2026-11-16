package com.smarttravel.backend.features.destination.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;

public class DestinationDto {
    @com.fasterxml.jackson.annotation.JsonIgnore
    private final java.util.Set<String> suppliedFields = new java.util.HashSet<>();
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean hasField(String name) { return suppliedFields.contains(name); }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.util.Set<String> suppliedFields() { return java.util.Set.copyOf(suppliedFields); }

    private Double appRating;
    private Long appReviewCount = 0L;
    public Double getAppRating() { return appRating; }
    public void setAppRating(Double value) { suppliedFields.add("appRating"); appRating = value; }
    public Long getAppReviewCount() { return appReviewCount; }
    public void setAppReviewCount(Long value) { suppliedFields.add("appReviewCount"); appReviewCount = value; }
    private Long id;

    @NotBlank(message = "Name is required")
    @Size(max = 180, message = "Name must not exceed 180 characters")
    private String name;

    @Size(max = 50, message = "Category must not exceed 50 characters")
    private String category;

    private Long categoryId;

    private String categoryCode;
    private String categoryNameEn;
    public String getCategoryNameEn() { return categoryNameEn; }
    public void setCategoryNameEn(String value) { categoryNameEn = value; }

    private String categoryIcon;

    private String categoryColor;

    private String description;

    @Size(max = 255, message = "Address must not exceed 255 characters")
    private String address;

    private String openingHours;
    @jakarta.validation.constraints.Size(max = 240)
    private String featuredReason;

    public String getFeaturedReason() { return featuredReason; }
    public void setFeaturedReason(String value) { suppliedFields.add("featuredReason"); featuredReason = value; }

    @Size(max = 50, message = "Phone must not exceed 50 characters")
    private String phone;

    @Size(max = 255, message = "Website must not exceed 255 characters")
    private String website;

    @Size(max = 500, message = "ImageUrl must not exceed 500 characters")
    private String imageUrl;

    private List<String> subImages;

    @DecimalMin(value = "1.0", message = "Rating must be at least 1.0")
    @DecimalMax(value = "5.0", message = "Rating must not exceed 5.0")
    @jakarta.validation.constraints.Digits(integer = 1, fraction = 1)
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

    @Size(max = 180)
    private String nameEn;
    private String descriptionEn;
    @Min(1)
    private Integer visitDurationMinutes;
    @com.fasterxml.jackson.annotation.JsonProperty(access = com.fasterxml.jackson.annotation.JsonProperty.Access.READ_ONLY)
    private Integer suggestedVisitDurationMinutes;
    public Integer getSuggestedVisitDurationMinutes() { return suggestedVisitDurationMinutes; }
    public void setSuggestedVisitDurationMinutes(Integer value) { suggestedVisitDurationMinutes = value; }
    private com.fasterxml.jackson.databind.JsonNode openingSchedule;

    public String getNameEn() { return nameEn; }
    public void setNameEn(String value) { suppliedFields.add("nameEn"); nameEn = value; }
    public String getDescriptionEn() { return descriptionEn; }
    public void setDescriptionEn(String value) { suppliedFields.add("descriptionEn"); descriptionEn = value; }
    public Integer getVisitDurationMinutes() { return visitDurationMinutes; }
    public void setVisitDurationMinutes(Integer value) { suppliedFields.add("visitDurationMinutes"); visitDurationMinutes = value; }
    public com.fasterxml.jackson.databind.JsonNode getOpeningSchedule() { return openingSchedule; }
    public void setOpeningSchedule(com.fasterxml.jackson.databind.JsonNode value) { suppliedFields.add("openingSchedule"); openingSchedule = value; }
    public BigDecimal getGoogleRating() { return rating; }
    public void setGoogleRating(BigDecimal value) { suppliedFields.add("googleRating"); suppliedFields.add("rating"); rating = value; }
    public Integer getGoogleReviewCount() { return reviewCount; }
    public void setGoogleReviewCount(Integer value) { suppliedFields.add("googleReviewCount"); suppliedFields.add("reviewCount"); reviewCount = value; }

    public DestinationDto() {}

    public Long getId() { return id; }
    public void setId(Long id) { suppliedFields.add("id"); this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { suppliedFields.add("name"); this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { suppliedFields.add("category"); this.category = category; }

    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { suppliedFields.add("categoryId"); this.categoryId = categoryId; }

    public String getCategoryCode() { return categoryCode; }
    public void setCategoryCode(String categoryCode) { suppliedFields.add("categoryCode"); this.categoryCode = categoryCode; }

    public String getCategoryIcon() { return categoryIcon; }
    public void setCategoryIcon(String categoryIcon) { suppliedFields.add("categoryIcon"); this.categoryIcon = categoryIcon; }

    public String getCategoryColor() { return categoryColor; }
    public void setCategoryColor(String categoryColor) { suppliedFields.add("categoryColor"); this.categoryColor = categoryColor; }

    public String getDescription() { return description; }
    public void setDescription(String description) { suppliedFields.add("description"); this.description = description; }

    public String getAddress() { return address; }
    public void setAddress(String address) { suppliedFields.add("address"); this.address = address; }

    public String getOpeningHours() { return openingHours; }
    public void setOpeningHours(String openingHours) { suppliedFields.add("openingHours"); this.openingHours = openingHours; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { suppliedFields.add("phone"); this.phone = phone; }

    public String getWebsite() { return website; }
    public void setWebsite(String website) { suppliedFields.add("website"); this.website = website; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { suppliedFields.add("imageUrl"); this.imageUrl = imageUrl; }

    public List<String> getSubImages() { return subImages; }
    public void setSubImages(List<String> subImages) { suppliedFields.add("subImages"); this.subImages = subImages; }

    public BigDecimal getRating() { return rating; }
    public void setRating(BigDecimal rating) { suppliedFields.add("rating"); if (!hasField("googleRating")) this.rating = rating; }

    public Integer getReviewCount() { return reviewCount; }
    public void setReviewCount(Integer reviewCount) { suppliedFields.add("reviewCount"); if (!hasField("googleReviewCount")) this.reviewCount = reviewCount; }

    public String getOsmId() { return osmId; }
    public void setOsmId(String osmId) { suppliedFields.add("osmId"); this.osmId = osmId; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { suppliedFields.add("latitude"); this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { suppliedFields.add("longitude"); this.longitude = longitude; }

    public Long getPriceMinVnd() { return priceMinVnd; }
    public void setPriceMinVnd(Long priceMinVnd) { suppliedFields.add("priceMinVnd"); this.priceMinVnd = priceMinVnd; }

    public Long getPriceMaxVnd() { return priceMaxVnd; }
    public void setPriceMaxVnd(Long priceMaxVnd) { suppliedFields.add("priceMaxVnd"); this.priceMaxVnd = priceMaxVnd; }

    public String getStatus() { return status; }
    public void setStatus(String status) { suppliedFields.add("status"); this.status = status; }
}
