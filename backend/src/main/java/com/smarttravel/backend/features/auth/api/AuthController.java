package com.smarttravel.backend.features.auth.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.auth.dto.*;
import com.smarttravel.backend.features.auth.service.AuthService;
import com.smarttravel.backend.features.auth.service.AccountDeletionService;
import com.smarttravel.backend.features.auth.service.PasswordResetRequests;
import com.smarttravel.backend.features.auth.service.PasswordResetService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;
    private final PasswordResetRequests requests;
    private final PasswordResetService resets;
    private final AccountDeletionService deletion;

    public AuthController(AuthService authService, PasswordResetRequests requests, PasswordResetService resets, AccountDeletionService deletion) {
        this.authService = authService;
        this.requests = requests;
        this.resets = resets;
        this.deletion = deletion;
    }

    public record ResetEmail(@NotBlank @Email @Size(max = 180) String email) {}
    public record ResetPassword(@NotBlank @Pattern(regexp = "[A-Za-z0-9_-]{43}") String code,
                                @NotBlank @Size(max = 72) String password) {}
    public record DeleteAccount(@NotBlank @Size(max = 72) String password, @NotNull @AssertTrue Boolean confirmed) {}

    @PostMapping("/forgot-password")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public ApiResponse<Void> requestReset(@Valid @RequestBody ResetEmail request) {
        requests.submit(request.email());
        return ApiResponse.success(null, "Nếu email đủ điều kiện, bạn sẽ nhận được mã đặt lại mật khẩu");
    }

    @PostMapping("/reset-password")
    public ApiResponse<Void> resetPassword(@Valid @RequestBody ResetPassword request) {
        resets.reset(request.code(), request.password());
        return ApiResponse.success(null, "Đã đặt lại mật khẩu. Vui lòng đăng nhập lại");
    }

    @PostMapping("/account/delete")
    public ApiResponse<Void> deleteAccount(@Valid @RequestBody DeleteAccount request) {
        deletion.delete(request.password());
        return ApiResponse.success(null, "Đã xóa tài khoản");
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(ApiResponse.success(response, "User registered successfully"));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success(response, "User logged in successfully"));
    }

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<AuthResponse>> getProfile(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(ApiResponse.error("Vui lòng đăng nhập để xem thông tin"));
        }
        AuthResponse response = authService.getProfile(authentication.getName());
        return ResponseEntity.ok(ApiResponse.success(response, "Lấy thông tin hồ sơ thành công"));
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<AuthResponse>> updateProfile(
            Authentication authentication,
            @Valid @RequestBody UpdateProfileRequest request) {
        if (authentication == null || authentication.getName() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(ApiResponse.error("Vui lòng đăng nhập để cập nhật"));
        }
        AuthResponse response = authService.updateProfile(authentication.getName(), request);
        return ResponseEntity.ok(ApiResponse.success(response, "Cập nhật hồ sơ thành công"));
    }
}
