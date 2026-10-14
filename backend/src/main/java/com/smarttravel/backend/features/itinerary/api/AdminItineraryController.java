package com.smarttravel.backend.features.itinerary.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.dto.ItineraryRequestDto;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;
import com.smarttravel.backend.features.itinerary.service.ItineraryMapper;
import com.smarttravel.backend.features.itinerary.service.ItineraryService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/itineraries")
public class AdminItineraryController {

    private final ItineraryService itineraryService;

    public AdminItineraryController(ItineraryService itineraryService) {
        this.itineraryService = itineraryService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ItineraryResponseDto>> createItinerary(
            Authentication authentication,
            @RequestBody ItineraryRequestDto request) {
        String email = authentication != null ? authentication.getName() : "admin@smarttravel.com";
        // Map request DTO to GenerateItineraryRequest
        com.smarttravel.backend.features.itinerary.dto.GenerateItineraryRequest genReq =
                new com.smarttravel.backend.features.itinerary.dto.GenerateItineraryRequest();
        genReq.setTitle(request.getTitle() != null ? request.getTitle() : "Chuyến đi Đà Nẵng");
        genReq.setStartDate(request.getStartDate() != null ? request.getStartDate() : java.time.LocalDate.now());
        genReq.setEndDate(request.getEndDate() != null ? request.getEndDate() : java.time.LocalDate.now().plusDays(2));
        genReq.setTravelersCount(request.getTravelersCount() != null ? request.getTravelersCount() : 2);
        genReq.setMaxBudgetVnd(request.getMaxBudgetVnd() != null ? request.getMaxBudgetVnd() : 5000000L);
        genReq.setPace(request.getPace() != null ? request.getPace() : "balanced");
        genReq.setPreferredCategories(request.getPreferredCategories());

        Itinerary itinerary = itineraryService.generateItinerary(email, genReq);
        return ResponseEntity.ok(ApiResponse.success(ItineraryMapper.toDto(itinerary), "Tạo lịch trình thành công"));
    }
}
