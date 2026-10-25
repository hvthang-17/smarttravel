package com.smarttravel.backend.features.auth.dto;

import jakarta.validation.constraints.NotBlank;

public class AdminUpdateUserRequest {

    @NotBlank(message = "Họ và tên không được để trống")
    private String fullName;

    private String role;
    private String status;
    private String password;

    public AdminUpdateUserRequest() {}

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
