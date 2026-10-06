package com.smarttravel.backend.features.destination.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.destination.service.DestinationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/destinations")
public class DestinationController {

    private final DestinationService destinationService;

    public DestinationController(DestinationService destinationService) {
        this.destinationService = destinationService;
    }

    @GetMapping
    public ApiResponse<List<DestinationDto>> getDestinations(@RequestParam(required = false) String category) {
        return ApiResponse.success(destinationService.getDestinations(category));
    }

    @GetMapping("/{id}")
    public ApiResponse<DestinationDto> getDestinationById(@PathVariable Long id) {
        return ApiResponse.success(destinationService.getDestinationById(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<DestinationDto> createDestination(@Valid @RequestBody DestinationDto dto) {
        return ApiResponse.success(destinationService.createDestination(dto), "Destination created successfully");
    }

    @PutMapping("/{id}")
    public ApiResponse<DestinationDto> updateDestination(@PathVariable Long id, @Valid @RequestBody DestinationDto dto) {
        return ApiResponse.success(destinationService.updateDestination(id, dto), "Destination updated successfully");
    }
}

