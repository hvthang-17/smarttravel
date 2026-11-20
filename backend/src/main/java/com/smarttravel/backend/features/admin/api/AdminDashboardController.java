package com.smarttravel.backend.features.admin.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.admin.service.AdminDashboardService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/admin/dashboard")
public class AdminDashboardController {
    private final AdminDashboardService metrics;

    public AdminDashboardController(AdminDashboardService metrics) {
        this.metrics = metrics;
    }

    @GetMapping
    public ApiResponse<AdminDashboardService.Metrics> summary(@RequestParam(defaultValue = "7") int days) {
        return ApiResponse.success(metrics.summary(days));
    }
}
