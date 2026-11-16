package com.smarttravel.backend.features.category.dto;

import jakarta.validation.constraints.NotBlank;

public class UpdateCategoryRequest {
    @com.fasterxml.jackson.annotation.JsonIgnore
    private final java.util.Set<String> supplied = new java.util.HashSet<>();
    public boolean hasField(String name) { return supplied.contains(name); }
    private String code;
    public String getCode() { return code; }
    public void setCode(String code) { supplied.add("code"); this.code = code; }

    @NotBlank(message = "Tên danh mục không được để trống")
    @jakarta.validation.constraints.Size(max = 100)
    private String name;

    @jakarta.validation.constraints.Size(max = 100)
    @jakarta.validation.constraints.Size(max = 100)
    private String nameEn;
    private String description;
    @jakarta.validation.constraints.Size(max = 500)
    private String imageUrl;
    @jakarta.validation.constraints.Size(max = 50)
    private String icon;
    @jakarta.validation.constraints.Size(max = 10)
    private String colorHex;
    private Integer displayOrder;
    @jakarta.validation.constraints.Pattern(regexp = "(?i)ACTIVE|INACTIVE", message = "Trạng thái danh mục không hợp lệ")
    private String status;

    public UpdateCategoryRequest() {}

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getNameEn() { return nameEn; }
    public void setNameEn(String nameEn) { supplied.add("nameEn"); this.nameEn = nameEn; }
    public String getDescription() { return description; }
    public void setDescription(String description) { supplied.add("description"); this.description = description; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { supplied.add("imageUrl"); this.imageUrl = imageUrl; }
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
    public String getColorHex() { return colorHex; }
    public void setColorHex(String colorHex) { this.colorHex = colorHex; }
    public Integer getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(Integer displayOrder) { this.displayOrder = displayOrder; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
