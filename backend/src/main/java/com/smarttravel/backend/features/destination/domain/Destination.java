package com.smarttravel.backend.features.destination.domain;

import com.smarttravel.backend.features.category.domain.Category;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "destinations")
public class Destination {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 180)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 255)
    private String address;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "opening_hours", columnDefinition = "json")
    private String openingHours;
    @Column(name = "featured_reason", length = 240)
    private String featuredReason;

    public String getFeaturedReason() { return featuredReason; }
    public void setFeaturedReason(String value) { featuredReason = value; }

    public int suggestedVisitDurationMinutes() {
        if (visitDurationMinutes != null) return visitDurationMinutes;
        return switch (category.getCode()) {
            case "FOOD", "CAFE" -> 60;
            case "CHECKIN" -> 45;
            case "NIGHTLIFE" -> 120;
            default -> 90;
        };
    }

    @Column(length = 50)
    private String phone;

    @Column(length = 255)
    private String website;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "sub_images", columnDefinition = "TEXT")
    private String subImages;

    @Column(name = "google_rating", precision = 2, scale = 1)
    private BigDecimal rating;

    @Column(name = "google_review_count")
    private Integer reviewCount;

    @Column(name = "osm_id", length = 50)
    private String osmId;

    @Column(nullable = false, precision = 10, scale = 7)
    private BigDecimal latitude;

    @Column(nullable = false, precision = 10, scale = 7)
    private BigDecimal longitude;

    @Column(name = "price_min_vnd")
    private Long priceMinVnd;

    @Column(name = "price_max_vnd")
    private Long priceMaxVnd;

    @Column(nullable = false, length = 20)
    private String status = "ACTIVE";

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    @Column(name = "name_en")
    private String nameEn;

    @Column(name = "description_en")
    private String descriptionEn;

    @Column(name = "visit_duration_minutes")
    private Integer visitDurationMinutes;

    public BigDecimal getGoogleRating() { return rating; }
    public void setGoogleRating(BigDecimal value) { rating = value; }
    public Integer getGoogleReviewCount() { return reviewCount; }
    public void setGoogleReviewCount(Integer value) { reviewCount = value; }

    public Destination() {}

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = Instant.now();
        }
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = Instant.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    @Transient
    public Long getCategoryId() {
        return category != null ? category.getId() : null;
    }

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

    public String getSubImages() { return subImages; }
    public void setSubImages(String subImages) { this.subImages = subImages; }

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

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    public String getNameEn() { return nameEn; }
    public void setNameEn(String nameEn) { this.nameEn = nameEn; }
    public String getDescriptionEn() { return descriptionEn; }
    public void setDescriptionEn(String descriptionEn) { this.descriptionEn = descriptionEn; }
    public Integer getVisitDurationMinutes() { return visitDurationMinutes; }
    public void setVisitDurationMinutes(Integer visitDurationMinutes) { this.visitDurationMinutes = visitDurationMinutes; }
}
