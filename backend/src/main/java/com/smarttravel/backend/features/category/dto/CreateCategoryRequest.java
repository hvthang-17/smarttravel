package com.smarttravel.backend.features.category.dto;

import jakarta.validation.constraints.NotBlank;

public class CreateCategoryRequest {

    @NotBlank(message = "Tên danh mục không được để trống")
    private String name;

    private String nameEn;
    private String code;
    private String slug;
    private String description;
    private String imageUrl;
    private String icon = "tag";
    private String colorHex = "#0077B6";
    private Integer displayOrder = 0;
    private String status = "ACTIVE";

    public CreateCategoryRequest() {}

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getNameEn() { return nameEn; }
    public void setNameEn(String nameEn) { this.nameEn = nameEn; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
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
}
