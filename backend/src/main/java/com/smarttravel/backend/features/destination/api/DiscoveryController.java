package com.smarttravel.backend.features.destination.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.destination.service.DiscoveryService;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/destinations/discover")
public class DiscoveryController {
    private final DiscoveryService discovery;
    public DiscoveryController(DiscoveryService discovery) { this.discovery = discovery; }

    @GetMapping
    public ApiResponse<DiscoveryService.Result> find(@RequestParam(required = false) String search,
            @RequestParam(required = false) List<String> category,
            @RequestParam(required = false) Long minPriceVnd, @RequestParam(required = false) Long maxPriceVnd,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "24") int size) {
        return ApiResponse.success(discovery.find(search, category, minPriceVnd, maxPriceVnd, page, size));
    }

    @GetMapping("/{id}")
    public ApiResponse<DestinationDto> detail(@PathVariable Long id) {
        return ApiResponse.success(discovery.detail(id));
    }
}
