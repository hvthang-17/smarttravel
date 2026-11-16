package com.smarttravel.backend.features.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class UpdateProfileRequest {

    @NotBlank(message = "Họ và tên không được để trống")
    @Size(min = 2, max = 150, message = "Họ và tên phải từ 2 đến 150 ký tự")
    private String fullName;

    @jakarta.validation.constraints.Pattern(regexp = "vi|en")
    private String language;
    @jakarta.validation.constraints.Min(1)
    private Long defaultBudgetVnd;
    @com.fasterxml.jackson.annotation.JsonIgnore
    private boolean budgetSupplied;
    @jakarta.validation.constraints.Pattern(regexp = "relaxed|balanced|packed")
    private String defaultPace;
    @jakarta.validation.constraints.Pattern(regexp = "walking|motorbike|car|taxi|unspecified")
    private String defaultTransport;
    @jakarta.validation.constraints.Size(max = 50)
    private java.util.List<String> preferredCategories;
    public UpdateProfileRequest() {}

    public UpdateProfileRequest(String fullName) {
        this.fullName = fullName;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    public String getLanguage() { return language; }
    public void setLanguage(String value) { language = value; }
    public Long getDefaultBudgetVnd() { return defaultBudgetVnd; }
    public void setDefaultBudgetVnd(Long value) { defaultBudgetVnd = value; budgetSupplied = true; }
    public boolean hasDefaultBudget() { return budgetSupplied; }
    public String getDefaultPace() { return defaultPace; }
    public void setDefaultPace(String value) { defaultPace = value; }
    public String getDefaultTransport() { return defaultTransport; }
    public void setDefaultTransport(String value) { defaultTransport = value; }
    public java.util.List<String> getPreferredCategories() { return preferredCategories; }
    public void setPreferredCategories(java.util.List<String> value) { preferredCategories = value; }
}
