package com.smarttravel.backend.features.itinerary.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;
import java.util.List;

public class GenerateItineraryRequest {

    @NotBlank(message = "Tiêu đề không được để trống")
    private String title;

    @NotNull(message = "Ngày bắt đầu là bắt buộc")
    private LocalDate startDate;

    @NotNull(message = "Ngày kết thúc là bắt buộc")
    private LocalDate endDate;

    @Min(value = 1, message = "Số lượng khách tối thiểu là 1")
    @Max(value = 50, message = "Số lượng khách tối đa là 50")
    private Integer travelersCount = 1;

    @NotNull(message = "Ngân sách tối đa là bắt buộc")
    @Min(value = 100000, message = "Ngân sách tối thiểu là 100,000 VNĐ")
    private Long maxBudgetVnd;

    @NotBlank(message = "Nhịp độ chuyến đi là bắt buộc")
    private String pace = "balanced"; // relaxed, balanced, packed

    private List<String> preferredCategories; // Tham quan, Ăn uống, Lưu trú, Giải trí

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
