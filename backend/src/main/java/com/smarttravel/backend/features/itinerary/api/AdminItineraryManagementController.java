package com.smarttravel.backend.features.itinerary.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;
import com.smarttravel.backend.features.itinerary.service.ItineraryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.smarttravel.backend.features.itinerary.service.AdminTripOverview;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/itineraries")
public class AdminItineraryManagementController {

    private final ItineraryService itineraryService;
    private final AdminTripOverview overview;

    public AdminItineraryManagementController(ItineraryService itineraryService, AdminTripOverview overview) {
        this.itineraryService = itineraryService;
        this.overview = overview;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ItineraryResponseDto>>> getAllItinerariesForAdmin() {
        List<ItineraryResponseDto> dtos = itineraryService.getAllItineraryDtos();
        return ResponseEntity.ok(ApiResponse.success(dtos));
    }

    @GetMapping("/page")
    public ApiResponse<AdminTripOverview.Page> page(@RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "ALL") String status, @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(overview.page(search, status, page, size));
    }
}
