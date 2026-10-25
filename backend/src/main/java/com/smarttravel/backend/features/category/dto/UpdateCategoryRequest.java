package com.smarttravel.backend.features.category.dto;

import jakarta.validation.constraints.NotBlank;

public class UpdateCategoryRequest {

    @NotBlank(message = "Tên danh mục không được để trống")
    private String name;

    private String nameEn;
    private String description;
    private String imageUrl;
    private String icon;
    private String colorHex;
    private Integer displayOrder;
    private String status;

    public UpdateCategoryRequest() {}

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
}
