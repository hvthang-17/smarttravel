package com.smarttravel.backend.features.destination.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.destination.service.FavoriteService;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/favorites")
public class FavoriteController {
    private final FavoriteService favorites;
    public FavoriteController(FavoriteService favorites) { this.favorites = favorites; }

    @GetMapping
    public ApiResponse<List<DestinationDto>> list() { return ApiResponse.success(favorites.list()); }

    @PutMapping("/{destinationId}")
    public ApiResponse<DestinationDto> add(@PathVariable Long destinationId) {
        return ApiResponse.success(favorites.add(destinationId));
    }

    @DeleteMapping("/{destinationId}")
    public ApiResponse<Void> remove(@PathVariable Long destinationId) {
        favorites.remove(destinationId);
        return ApiResponse.success(null, "Đã bỏ lưu địa điểm");
    }
}
