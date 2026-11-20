package com.smarttravel.backend.features.itinerary.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;
import java.util.List;

public class GenerateItineraryRequest {

    @NotBlank(message = "Tiêu đề không được để trống")
    @Size(max = 255)
    private String title;

    @NotNull(message = "Ngày bắt đầu là bắt buộc")
    private LocalDate startDate;

    @NotNull(message = "Ngày kết thúc là bắt buộc")
    private LocalDate endDate;

    @Min(value = 1, message = "Số lượng khách tối thiểu là 1")
    @NotNull
    @Max(value = 10, message = "Số lượng khách tối đa là 10")
    private Integer travelersCount = 1;

    @NotNull(message = "Ngân sách tối đa là bắt buộc")
    @Min(value = 1, message = "Ngân sách phải lớn hơn 0")
    private Long maxBudgetVnd;

    @NotBlank(message = "Nhịp độ chuyến đi là bắt buộc")
    @Pattern(regexp = "relaxed|balanced|packed")
    private String pace = "balanced"; // relaxed, balanced, packed

    @Size(max = 6)
    private List<@NotBlank String> preferredCategories;

    @Pattern(regexp = "[a-z0-9_-]{1,64}")
    private String generationKey;
    @Size(max = 5)
    private List<@NotNull @Positive Long> requiredDestinationIds;
    @Size(max = 5)
    private List<@NotNull @Positive Long> excludedDestinationIds;
    public String getGenerationKey() { return generationKey; }
    public void setGenerationKey(String value) { generationKey = value; }
    public List<Long> getRequiredDestinationIds() { return requiredDestinationIds; }
    public void setRequiredDestinationIds(List<Long> value) { requiredDestinationIds = value; }
    public List<Long> getExcludedDestinationIds() { return excludedDestinationIds; }
    public void setExcludedDestinationIds(List<Long> value) { excludedDestinationIds = value; }

    @Size(max = 28)
    private List<@NotNull @Positive Long> favoriteDestinationIds;
    public List<Long> getFavoriteDestinationIds() { return favoriteDestinationIds; }
    public void setFavoriteDestinationIds(List<Long> ids) { favoriteDestinationIds = ids; }

    @Pattern(regexp = "walking|motorbike|car|taxi|unspecified")
    private String transport = "unspecified";
    @Size(max = 255)
    private String originName;
    @DecimalMin("-90") @DecimalMax("90") @Digits(integer = 2, fraction = 7)
    private java.math.BigDecimal originLatitude;
    @DecimalMin("-180") @DecimalMax("180") @Digits(integer = 3, fraction = 7)
    private java.math.BigDecimal originLongitude;
    public String getTransport() { return transport; }
    public void setTransport(String value) { transport = value; }
    public String getOriginName() { return originName; }
    public void setOriginName(String value) { originName = value; }
    public java.math.BigDecimal getOriginLatitude() { return originLatitude; }
    public void setOriginLatitude(java.math.BigDecimal value) { originLatitude = value; }
    public java.math.BigDecimal getOriginLongitude() { return originLongitude; }
    public void setOriginLongitude(java.math.BigDecimal value) { originLongitude = value; }
    @AssertTrue(message = "Điểm xuất phát cần đủ vĩ độ và kinh độ")
    public boolean isOriginValid() { return (originLatitude == null) == (originLongitude == null); }

    @AssertTrue(message = "Chuyến đi phải có từ 1 đến 7 ngày hợp lệ")
    public boolean isDateRangeValid() {
        if (startDate == null || endDate == null) return true;
        long days = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;
        return startDate.getYear() >= 1000 && endDate.getYear() <= 9999 && days >= 1 && days <= 7;
    }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public Integer getTravelersCount() { return travelersCount; }
    public void setTravelersCount(Integer travelersCount) { this.travelersCount = travelersCount; }
    public Long getMaxBudgetVnd() { return maxBudgetVnd; }
    public void setMaxBudgetVnd(Long maxBudgetVnd) { this.maxBudgetVnd = maxBudgetVnd; }
    public String getPace() { return pace; }
    public void setPace(String pace) { this.pace = pace; }
    public List<String> getPreferredCategories() { return preferredCategories; }
    public void setPreferredCategories(List<String> preferredCategories) { this.preferredCategories = preferredCategories; }
}
