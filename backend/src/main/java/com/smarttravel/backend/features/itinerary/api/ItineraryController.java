package com.smarttravel.backend.features.itinerary.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.itinerary.dto.GenerateItineraryRequest;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;
import com.smarttravel.backend.features.itinerary.dto.PublicItinerary;
import com.smarttravel.backend.features.itinerary.service.ItineraryService;
import com.smarttravel.backend.features.itinerary.service.TripManagement;
import com.smarttravel.backend.features.itinerary.service.TripSharing;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.smarttravel.backend.features.itinerary.dto.UpdateActivitiesRequest;
import java.util.List;

@RestController
@RequestMapping("/api/v1/itineraries")
public class ItineraryController {

    private final ItineraryService itineraryService;
    private final TripManagement management;
    private final TripSharing sharing;

    public ItineraryController(ItineraryService itineraryService, TripManagement management, TripSharing sharing) {
        this.itineraryService = itineraryService;
        this.management = management;
        this.sharing = sharing;
    }

    @PostMapping("/generate")
    public ResponseEntity<ApiResponse<ItineraryResponseDto>> generateItinerary(
            Authentication authentication,
            @Valid @RequestBody GenerateItineraryRequest request) {
        String email = authentication.getName();
        ItineraryResponseDto dto = itineraryService.generateItineraryDto(email, request);
        return ResponseEntity.ok(ApiResponse.success(dto, "Sinh lịch trình thành công"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ItineraryResponseDto>>> getMyItineraries(Authentication authentication) {
        String email = authentication.getName();
        List<ItineraryResponseDto> dtos = itineraryService.getUserItineraryDtos(email, "SAVED");
        return ResponseEntity.ok(ApiResponse.success(dtos));
    }

    @GetMapping("/drafts")
    public ApiResponse<List<ItineraryResponseDto>> getDrafts(Authentication authentication) {
        return ApiResponse.success(itineraryService.getUserItineraryDtos(authentication.getName(), "DRAFT"));
    }

    @PutMapping("/{id}/save")
    public ApiResponse<ItineraryResponseDto> save(@PathVariable Long id) {
        return ApiResponse.success(itineraryService.saveDraft(id), "Đã lưu lịch trình");
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
        String email = authentication.getName();
        ItineraryResponseDto dto = itineraryService.updateActivitiesDto(email, id, request);
        return ResponseEntity.ok(ApiResponse.success(dto, "Cập nhật lịch trình thành công"));
    }

    @GetMapping("/mine")
    public ApiResponse<TripManagement.TripPage> page(
            @RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "ALL") TripManagement.Period period,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(management.page(search, period, page, size));
    }

    public record Title(@jakarta.validation.constraints.NotBlank @jakarta.validation.constraints.Size(max = 255) String title) {}

    @PutMapping("/{id}/title")
    public ApiResponse<ItineraryResponseDto> rename(@PathVariable long id, @Valid @RequestBody Title request) {
        return ApiResponse.success(management.rename(id, request.title()));
    }

    @PostMapping("/{id}/copy")
    @ResponseStatus(org.springframework.http.HttpStatus.CREATED)
    public ApiResponse<ItineraryResponseDto> copy(@PathVariable long id) {
        return ApiResponse.success(management.duplicate(id));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable long id) {
        management.delete(id);
        return ApiResponse.success(null, "Đã xóa lịch trình");
    }

    @GetMapping("/{id}/share")
    public ApiResponse<TripSharing.Link> shareStatus(@PathVariable long id) {
        return ApiResponse.success(sharing.status(id));
    }

    @PostMapping("/{id}/share")
    public ApiResponse<TripSharing.Link> shareItinerary(@PathVariable long id,
            @RequestParam(defaultValue = "false") boolean rotate) {
        return ApiResponse.success(sharing.create(id, rotate));
    }

    @DeleteMapping("/{id}/share")
    public ApiResponse<TripSharing.Link> revokeShare(@PathVariable long id) {
        return ApiResponse.success(sharing.revoke(id));
    }

    @GetMapping("/shared/{shareToken}")
    public ApiResponse<PublicItinerary> getSharedItinerary(@PathVariable String shareToken) {
        return ApiResponse.success(sharing.read(shareToken));
    }
}

