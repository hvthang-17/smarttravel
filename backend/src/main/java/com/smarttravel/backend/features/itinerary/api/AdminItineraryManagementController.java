package com.smarttravel.backend.features.itinerary.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;
import com.smarttravel.backend.features.itinerary.service.ItineraryMapper;
import com.smarttravel.backend.features.itinerary.service.ItineraryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/admin/itineraries")
public class AdminItineraryManagementController {

    private final ItineraryService itineraryService;

    public AdminItineraryManagementController(ItineraryService itineraryService) {
        this.itineraryService = itineraryService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ItineraryResponseDto>>> getAllItinerariesForAdmin() {
        // For admin monitoring, return all itineraries or simulated list
        List<Itinerary> list = itineraryService.getUserItineraries("admin@smarttravel.com");
        if (list.isEmpty()) {
            list = itineraryService.getUserItineraries("user@smarttravel.com");
        }
        List<ItineraryResponseDto> dtos = list.stream().map(ItineraryMapper::toDto).collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(dtos));
    }
}
