package com.smarttravel.backend.features.category.dto;

import java.time.Instant;

public class CategoryResponseDto {
    private Long id;
    private String code;
    private String slug;
    private String name;
    private String nameEn;
    private String description;
    private String imageUrl;
    private String icon;
    private String colorHex;
    private Integer displayOrder;
    private String status;
    private Integer destinationsCount;
    private Instant createdAt;
    private Instant updatedAt;

    public CategoryResponseDto() {}

    public CategoryResponseDto(Long id, String code, String slug, String name, String nameEn, String description, String imageUrl, String icon, String colorHex, Integer displayOrder, String status, Integer destinationsCount, Instant createdAt, Instant updatedAt) {
        this.id = id;
        this.code = code;
        this.slug = slug;
        this.name = name;
        this.nameEn = nameEn;
        this.description = description;
        this.imageUrl = imageUrl;
        this.icon = icon;
        this.colorHex = colorHex;
        this.displayOrder = displayOrder;
        this.status = status;
        this.destinationsCount = destinationsCount;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getNameEn() { return nameEn; }
    public void setNameEn(String nameEn) { this.nameEn = nameEn; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
    public String getColorHex() { return colorHex; }
    public void setColorHex(String colorHex) { this.colorHex = colorHex; }
    public Integer getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(Integer displayOrder) { this.displayOrder = displayOrder; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getDestinationsCount() { return destinationsCount; }
    public void setDestinationsCount(Integer destinationsCount) { this.destinationsCount = destinationsCount; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
