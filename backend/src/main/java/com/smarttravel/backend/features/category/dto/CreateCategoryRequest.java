package com.smarttravel.backend.features.category.dto;

import jakarta.validation.constraints.NotBlank;

public class CreateCategoryRequest {

    @NotBlank(message = "Tên danh mục không được để trống")
    @jakarta.validation.constraints.Size(max = 100)
    private String name;

    @jakarta.validation.constraints.Size(max = 100)
    @jakarta.validation.constraints.Size(max = 100)
    private String nameEn;
    @jakarta.validation.constraints.Size(max = 50)
    private String code;
    @jakarta.validation.constraints.Size(max = 100)
    private String slug;
    private String description;
    @jakarta.validation.constraints.Size(max = 500)
    private String imageUrl;
    @jakarta.validation.constraints.Size(max = 50)
    private String icon = "tag";
    @jakarta.validation.constraints.Size(max = 10)
    private String colorHex = "#0077B6";
    private Integer displayOrder = 0;
    @jakarta.validation.constraints.Pattern(regexp = "(?i)ACTIVE|INACTIVE", message = "Trạng thái danh mục không hợp lệ")
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
