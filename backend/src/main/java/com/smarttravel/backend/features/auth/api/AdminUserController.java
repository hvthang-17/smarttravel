package com.smarttravel.backend.features.auth.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.auth.dto.AdminCreateUserRequest;
import com.smarttravel.backend.features.auth.dto.AdminUpdateUserRequest;
import com.smarttravel.backend.features.auth.dto.AdminUserResponseDto;
import com.smarttravel.backend.features.auth.service.AdminUserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/users")
public class AdminUserController {

    private final AdminUserService adminUserService;

    public AdminUserController(AdminUserService adminUserService) {
        this.adminUserService = adminUserService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<AdminUserResponseDto>>> getAllUsers(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String status) {
        List<AdminUserResponseDto> users = adminUserService.getAllUsers(search, role, status);
        return ResponseEntity.ok(ApiResponse.success(users, "Lấy danh sách người dùng thành công"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<AdminUserResponseDto>> getUserById(@PathVariable Long id) {
        AdminUserResponseDto user = adminUserService.getUserById(id);
        return ResponseEntity.ok(ApiResponse.success(user, "Lấy chi tiết người dùng thành công"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<AdminUserResponseDto>> createUser(
            @Valid @RequestBody AdminCreateUserRequest request) {
        AdminUserResponseDto user = adminUserService.createUser(request);
        return ResponseEntity.ok(ApiResponse.success(user, "Tạo tài khoản người dùng thành công"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<AdminUserResponseDto>> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody AdminUpdateUserRequest request) {
        AdminUserResponseDto user = adminUserService.updateUser(id, request);
        return ResponseEntity.ok(ApiResponse.success(user, "Cập nhật tài khoản người dùng thành công"));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<ApiResponse<AdminUserResponseDto>> updateUserStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> payload) {
        String status = payload.get("status");
        if (status == null || status.isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Thiếu trường status"));
        }
        AdminUserResponseDto user = adminUserService.updateUserStatus(id, status);
        return ResponseEntity.ok(ApiResponse.success(user, "Cập nhật trạng thái người dùng thành công"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(
            @PathVariable Long id,
            Authentication authentication) {
        String currentUserEmail = authentication != null ? authentication.getName() : null;
        adminUserService.deleteUser(id, currentUserEmail);
        return ResponseEntity.ok(ApiResponse.success(null, "Xóa tài khoản người dùng thành công"));
    }
}
