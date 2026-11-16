package com.smarttravel.backend.features.destination.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.destination.dto.ReviewDtos.*;
import com.smarttravel.backend.features.destination.service.DestinationReviews;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/destinations/{destinationId}/reviews")
public class DestinationReviewController {
    private final DestinationReviews reviews;

    public DestinationReviewController(DestinationReviews reviews) {
        this.reviews = reviews;
    }

    @GetMapping
    public ApiResponse<Page<PublicReview>> list(@PathVariable long destinationId,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.success(reviews.list(destinationId, page, size));
    }

    @GetMapping("/mine")
    public ApiResponse<OwnedReview> mine(@PathVariable long destinationId) {
        return ApiResponse.success(reviews.mine(destinationId));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<OwnedReview> create(@PathVariable long destinationId, @Valid @RequestBody Write input) {
        return ApiResponse.success(reviews.create(destinationId, input));
    }

    @PutMapping("/mine")
    public ApiResponse<OwnedReview> update(@PathVariable long destinationId, @Valid @RequestBody Write input) {
        return ApiResponse.success(reviews.update(destinationId, input));
    }

    @DeleteMapping("/mine")
    public ApiResponse<Void> delete(@PathVariable long destinationId) {
        reviews.delete(destinationId);
        return ApiResponse.success(null, "Đã xóa đánh giá");
    }

    @PostMapping("/{reviewId}/reports")
    public ApiResponse<Void> report(@PathVariable long destinationId, @PathVariable long reviewId,
                                    @Valid @RequestBody Report input) {
        reviews.report(destinationId, reviewId, input.reason());
        return ApiResponse.success(null, "Đã chuyển báo cáo đến quản trị viên");
    }
}
