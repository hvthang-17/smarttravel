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

import java.util.List;
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
        Itinerary itinerary = itineraryService.generateItinerary(email, request);
        return ResponseEntity.ok(ApiResponse.success(ItineraryMapper.toDto(itinerary), "Sinh lịch trình thành công"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ItineraryResponseDto>>> getMyItineraries(Authentication authentication) {
        String email = authentication != null ? authentication.getName() : "user@smarttravel.com";
        List<Itinerary> list = itineraryService.getUserItineraries(email);
        List<ItineraryResponseDto> dtos = list.stream().map(ItineraryMapper::toDto).collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(dtos));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ItineraryResponseDto>> getItineraryById(@PathVariable Long id) {
        Itinerary itinerary = itineraryService.getItineraryById(id);
        return ResponseEntity.ok(ApiResponse.success(ItineraryMapper.toDto(itinerary)));
    }
}

