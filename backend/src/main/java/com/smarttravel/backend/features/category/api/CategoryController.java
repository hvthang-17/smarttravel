package com.smarttravel.backend.features.category.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.category.dto.CategoryResponseDto;
import com.smarttravel.backend.features.category.dto.CreateCategoryRequest;
import com.smarttravel.backend.features.category.dto.UpdateCategoryRequest;
import com.smarttravel.backend.features.category.service.CategoryService;
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
@RequestMapping("/api/v1/categories")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<CategoryResponseDto>>> getAllCategories(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status) {
        List<CategoryResponseDto> categories = categoryService.getAllCategories(search, status);
        return ResponseEntity.ok(ApiResponse.success(categories, "Lấy danh sách danh mục thành công"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CategoryResponseDto>> getCategoryById(@PathVariable Long id) {
        CategoryResponseDto category = categoryService.getCategoryById(id);
        return ResponseEntity.ok(ApiResponse.success(category, "Lấy chi tiết danh mục thành công"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CategoryResponseDto>> createCategory(@Valid @RequestBody CreateCategoryRequest request) {
        CategoryResponseDto created = categoryService.createCategory(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(created, "Thêm danh mục mới thành công"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<CategoryResponseDto>> updateCategory(
            @PathVariable Long id,
            @Valid @RequestBody UpdateCategoryRequest request) {
        CategoryResponseDto updated = categoryService.updateCategory(id, request);
        return ResponseEntity.ok(ApiResponse.success(updated, "Cập nhật danh mục thành công"));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<ApiResponse<CategoryResponseDto>> toggleStatus(@PathVariable Long id) {
        CategoryResponseDto updated = categoryService.toggleStatus(id);
        return ResponseEntity.ok(ApiResponse.success(updated, "Thay đổi trạng thái danh mục thành công"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCategory(@PathVariable Long id) {
        categoryService.deleteCategory(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Xóa danh mục thành công"));
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

        Set<String> allowedExtensions = Set.of(".jpg", ".jpeg", ".png", ".webp", ".svg", ".gif");
        if (!allowedExtensions.contains(extension)) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Định dạng file không được hỗ trợ. Chỉ chấp nhận JPG, PNG, WEBP, SVG, GIF"));
        }

        if (file.getSize() > 10 * 1024 * 1024) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Dung lượng file tối đa là 10MB"));
        }

        try {
            Path uploadDir = Paths.get("uploads", "categories");
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            String uniqueFilename = "cat_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
            Path targetPath = uploadDir.resolve(uniqueFilename);

            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            String fileUrl = "/uploads/categories/" + uniqueFilename;
            Map<String, String> response = new HashMap<>();
            response.put("url", fileUrl);
            response.put("filename", uniqueFilename);

            return ResponseEntity.ok(ApiResponse.success(response, "Tải ảnh lên thành công"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Lỗi khi lưu trữ file: " + e.getMessage()));
        }
    }
}
