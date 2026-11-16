package com.smarttravel.backend.features.destination.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.common.ImageUploadService;
import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.destination.service.DestinationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;

@RestController
@RequestMapping("/api/v1/destinations")
public class DestinationController {

    private final DestinationService destinationService;
    private final ImageUploadService imageUploadService;

    public DestinationController(DestinationService destinationService, ImageUploadService imageUploadService) {
        this.destinationService = destinationService;
        this.imageUploadService = imageUploadService;
    }

    @GetMapping
    public ApiResponse<List<DestinationDto>> getDestinations(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String search) {
        return ApiResponse.success(destinationService.getDestinations(category, categoryId, status, search));
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
    public ApiResponse<DestinationDto> updateDestination(
            @PathVariable Long id,
            @Valid @RequestBody DestinationDto dto) {
        return ApiResponse.success(destinationService.updateDestination(id, dto), "Destination updated successfully");
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteDestination(@PathVariable Long id) {
        destinationService.deleteDestination(id);
        return ApiResponse.success(null, "Đã ẩn địa điểm; giữ nguyên review và lịch trình đã lưu");
    }

    @PostMapping("/upload-image")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadImage(@RequestParam("file") MultipartFile file) throws IOException {
        return ResponseEntity.ok(ApiResponse.success(imageUploadService.store(file, "destinations"), "Tải ảnh lên thành công"));
    }

    @PostMapping("/upload-images")
    public ResponseEntity<ApiResponse<List<String>>> uploadMultipleImages(@RequestParam("files") List<MultipartFile> files) throws IOException {
        return ResponseEntity.ok(ApiResponse.success(imageUploadService.storeAll(files, "destinations"), "Tải ảnh lên thành công"));
    }
}
