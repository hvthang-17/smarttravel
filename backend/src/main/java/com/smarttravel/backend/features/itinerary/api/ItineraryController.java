package com.smarttravel.backend.features.itinerary.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.dto.GenerateItineraryRequest;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;
import com.smarttravel.backend.features.itinerary.service.ItineraryMapper;
import com.smarttravel.backend.features.itinerary.service.ItineraryService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.smarttravel.backend.features.itinerary.dto.UpdateActivitiesRequest;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/itineraries")
public class ItineraryController {

    private final ItineraryService itineraryService;

    public ItineraryController(ItineraryService itineraryService) {
        this.itineraryService = itineraryService;
    }

    @PostMapping("/generate")
    public ResponseEntity<ApiResponse<ItineraryResponseDto>> generateItinerary(
            Authentication authentication,
            @Valid @RequestBody GenerateItineraryRequest request) {
        String email = authentication != null ? authentication.getName() : "user@smarttravel.com";
        ItineraryResponseDto dto = itineraryService.generateItineraryDto(email, request);
        return ResponseEntity.ok(ApiResponse.success(dto, "Sinh lịch trình thành công"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ItineraryResponseDto>>> getMyItineraries(Authentication authentication) {
        String email = authentication != null ? authentication.getName() : "user@smarttravel.com";
        List<ItineraryResponseDto> dtos = itineraryService.getUserItineraryDtos(email);
        return ResponseEntity.ok(ApiResponse.success(dtos));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ItineraryResponseDto>> getItineraryById(@PathVariable Long id) {
        ItineraryResponseDto dto = itineraryService.getItineraryDtoById(id);
        return ResponseEntity.ok(ApiResponse.success(dto));
    }

    @PutMapping("/{id}/activities")
    public ResponseEntity<ApiResponse<ItineraryResponseDto>> updateActivities(
            Authentication authentication,
            @PathVariable Long id,
            @Valid @RequestBody UpdateActivitiesRequest request) {
        String email = authentication != null ? authentication.getName() : "user@smarttravel.com";
        ItineraryResponseDto dto = itineraryService.updateActivitiesDto(email, id, request);
        return ResponseEntity.ok(ApiResponse.success(dto, "Cập nhật lịch trình thành công"));
    }

    @PostMapping("/{id}/share")
    public ResponseEntity<ApiResponse<Map<String, String>>> shareItinerary(
            Authentication authentication,
            @PathVariable Long id) {
        String email = authentication != null ? authentication.getName() : "user@smarttravel.com";
        String token = itineraryService.createShareToken(email, id);
        return ResponseEntity.ok(ApiResponse.success(
                Map.of("shareToken", token, "shareUrl", "/itineraries/shared/" + token),
                "Tạo liên kết chia sẻ thành công"
        ));
    }

    @GetMapping("/shared/{shareToken}")
    public ResponseEntity<ApiResponse<ItineraryResponseDto>> getSharedItinerary(@PathVariable String shareToken) {
        ItineraryResponseDto dto = itineraryService.getSharedItineraryDto(shareToken);
        return ResponseEntity.ok(ApiResponse.success(dto));
    }
}

