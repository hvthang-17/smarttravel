package com.smarttravel.backend.features.destination.api;

import com.smarttravel.backend.common.ApiResponse;
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

    public DestinationController(DestinationService destinationService) {
        this.destinationService = destinationService;
    }

    @GetMapping
    public ApiResponse<List<DestinationDto>> getDestinations(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String search) {
        return ApiResponse.success(destinationService.getDestinations(category, status, search));
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
        return ApiResponse.success(null, "Destination deleted successfully");
    }

    @PostMapping("/upload-image")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadImage(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Vui lòng chọn file hình ảnh hợp lệ"));
        }

        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
        }

        if (!extension.matches("\\.(jpg|jpeg|png|webp|gif)$")) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Chỉ chấp nhận các định dạng ảnh: JPG, PNG, WEBP, GIF"));
        }

        try {
            Path uploadDir = Paths.get("uploads", "destinations");
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            String uniqueFilename = "dest_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
            Path targetPath = uploadDir.resolve(uniqueFilename);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            String fileUrl = "/uploads/destinations/" + uniqueFilename;
            Map<String, String> response = new HashMap<>();
            response.put("url", fileUrl);
            response.put("filename", uniqueFilename);

            return ResponseEntity.ok(ApiResponse.success(response, "Tải ảnh lên thành công"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Lỗi khi lưu trữ file: " + e.getMessage()));
        }
    }

    @PostMapping("/upload-images")
    public ResponseEntity<ApiResponse<List<String>>> uploadMultipleImages(@RequestParam("files") List<MultipartFile> files) {
        if (files == null || files.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Vui lòng chọn ít nhất một file ảnh"));
        }

        List<String> uploadedUrls = new ArrayList<>();
        Path uploadDir = Paths.get("uploads", "destinations");
        try {
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            for (MultipartFile file : files) {
                if (file.isEmpty()) continue;
                String originalFilename = file.getOriginalFilename();
                String extension = "";
                if (originalFilename != null && originalFilename.contains(".")) {
                    extension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
                }
                if (!extension.matches("\\.(jpg|jpeg|png|webp|gif)$")) continue;

                String uniqueFilename = "dest_sub_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
                Path targetPath = uploadDir.resolve(uniqueFilename);
                Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
                uploadedUrls.add("/uploads/destinations/" + uniqueFilename);
            }

            return ResponseEntity.ok(ApiResponse.success(uploadedUrls, "Tải các ảnh phụ lên thành công"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Lỗi khi tải ảnh: " + e.getMessage()));
        }
    }
}
