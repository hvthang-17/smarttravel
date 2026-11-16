package com.smarttravel.backend.features.destination.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.destination.service.ReviewModerationService;
import com.smarttravel.backend.features.destination.dto.ReviewDtos.*;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/admin/reviews")
public class ReviewModerationController {
    private final ReviewModerationService moderation;
    public ReviewModerationController(ReviewModerationService moderation) { this.moderation = moderation; }
    public record StatusRequest(@NotNull @Pattern(regexp = "PUBLISHED|HIDDEN") String status) {}
    @GetMapping
    public ApiResponse<Page<ModerationReview>> list(@RequestParam(defaultValue = "ALL") String status,
            @RequestParam(required = false) Long destinationId,
            @RequestParam(defaultValue = "false") boolean reportedOnly,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(moderation.list(status, destinationId, reportedOnly, page, size));
    }
    @PutMapping("/{id}/status")
    public ApiResponse<Void> changeStatus(@PathVariable Long id, @Valid @RequestBody StatusRequest request) {
        moderation.changeStatus(id, request.status());
        return ApiResponse.success(null, "Đã cập nhật trạng thái review");
    }
}
