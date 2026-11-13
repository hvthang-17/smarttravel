package com.smarttravel.backend.features.auth.service;

import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.dto.AdminCreateUserRequest;
import com.smarttravel.backend.features.auth.dto.AdminUpdateUserRequest;
import com.smarttravel.backend.features.auth.dto.AdminUserResponseDto;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.itinerary.repository.ItineraryRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import com.smarttravel.backend.common.CurrentUser;
import com.smarttravel.backend.common.PasswordPolicy;
import java.util.stream.Collectors;

@Service
public class AdminUserService {

    private final UserRepository userRepository;
    private final ItineraryRepository itineraryRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminUserService(UserRepository userRepository, ItineraryRepository itineraryRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.itineraryRepository = itineraryRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<AdminUserResponseDto> getAllUsers(String search, String role, String status) {
        List<User> all = userRepository.findAll();

        return all.stream()
                .filter(u -> {
                    if (role != null && !role.isBlank() && !role.equalsIgnoreCase("ALL") && !role.equalsIgnoreCase("Tất cả")) {
                        if (!u.getRole().equalsIgnoreCase(role)) return false;
                    }
                    if (status != null && !status.isBlank() && !status.equalsIgnoreCase("ALL") && !status.equalsIgnoreCase("Tất cả")) {
                        if (!u.getStatus().equalsIgnoreCase(status)) return false;
                    }
                    if (search != null && !search.isBlank()) {
                        String query = search.trim().toLowerCase();
                        boolean matchName = u.getFullName() != null && u.getFullName().toLowerCase().contains(query);
                        boolean matchEmail = u.getEmail() != null && u.getEmail().toLowerCase().contains(query);
                        return matchName || matchEmail;
                    }
                    return true;
                })
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public AdminUserResponseDto getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));
        return toDto(user);
    }

    @Transactional
    public AdminUserResponseDto createUser(AdminCreateUserRequest request) {
        PasswordPolicy.validate(request.getPassword());
        String normalizedEmail = request.getEmail().trim().toLowerCase();
        if (userRepository.existsByEmail(normalizedEmail)) {
            throw new IllegalArgumentException("Địa chỉ email này đã được sử dụng");
        }

        String assignedRole = (request.getRole() != null && !request.getRole().isBlank())
                ? request.getRole().trim()
                : "ROLE_USER";

        String assignedStatus = (request.getStatus() != null && !request.getStatus().isBlank())
                ? request.getStatus().trim().toUpperCase()
                : "ACTIVE";
        validateRoleAndStatus(assignedRole, assignedStatus);

        User user = new User(
                normalizedEmail,
                passwordEncoder.encode(request.getPassword()),
                request.getFullName().trim(),
                assignedRole
        );
        user.setStatus(assignedStatus);

        User saved = userRepository.save(user);
        return toDto(saved);
    }

    @Transactional
    public AdminUserResponseDto updateUser(Long id, AdminUpdateUserRequest request) {
        List<User> admins = userRepository.lockAdministrators();
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));
        String nextRole = request.getRole() == null || request.getRole().isBlank() ? user.getRole() : request.getRole().trim();
        String nextStatus = request.getStatus() == null || request.getStatus().isBlank() ? user.getStatus() : request.getStatus().trim().toUpperCase();
        validateRoleAndStatus(nextRole, nextStatus);
        protectAdministrator(user, nextRole, nextStatus, admins);
        if (!user.getRole().equals(nextRole) || !user.getStatus().equals(nextStatus)
                || (request.getPassword() != null && !request.getPassword().isBlank())) {
            user.revokeSessions();
        }

        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            user.setFullName(request.getFullName().trim());
        }

        if (request.getRole() != null && !request.getRole().isBlank()) {
            user.setRole(request.getRole().trim());
        }

        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            user.setStatus(request.getStatus().trim().toUpperCase());
        }

        if (request.getPassword() != null && !request.getPassword().isBlank()) {
            PasswordPolicy.validate(request.getPassword());
            user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        }

        User saved = userRepository.save(user);
        return toDto(saved);
    }

    @Transactional
    public AdminUserResponseDto updateUserStatus(Long id, String status) {
        List<User> admins = userRepository.lockAdministrators();
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));

        String nextStatus = status.trim().toUpperCase();
        validateRoleAndStatus(user.getRole(), nextStatus);
        protectAdministrator(user, user.getRole(), nextStatus, admins);
        if (!user.getStatus().equals(nextStatus)) user.revokeSessions();
        user.setStatus(nextStatus);
        User saved = userRepository.save(user);
        return toDto(saved);
    }

    @Transactional
    public void deleteUser(Long id, String currentUserEmail) {
        List<User> admins = userRepository.lockAdministrators();
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));

        if (currentUserEmail != null && currentUserEmail.equalsIgnoreCase(user.getEmail())) {
            throw new IllegalArgumentException("Không thể tự xóa tài khoản của chính bạn");
        }

        protectAdministrator(user, user.getRole(), "INACTIVE", admins);
        userRepository.delete(user);
    }

    private void validateRoleAndStatus(String role, String status) {
        if (!Set.of("ROLE_USER", "ROLE_ADMIN").contains(role)
                || !Set.of("ACTIVE", "LOCKED", "INACTIVE").contains(status)) {
            throw new IllegalArgumentException("Vai trò hoặc trạng thái không hợp lệ");
        }
    }

    private void protectAdministrator(User user, String role, String status, List<User> admins) {
        boolean removesAccess = !"ACTIVE".equals(status) || !user.getRole().equals(role);
        if (removesAccess && user.getEmail().equals(CurrentUser.email())) {
            throw new IllegalArgumentException("Không thể tự khóa hoặc thay đổi quyền tài khoản của chính bạn");
        }
        if ("ROLE_ADMIN".equals(user.getRole()) && "ACTIVE".equals(user.getStatus())
                && (!"ROLE_ADMIN".equals(role) || !"ACTIVE".equals(status))
                && admins.stream().filter(a -> "ACTIVE".equals(a.getStatus())).count() <= 1) {
            throw new IllegalArgumentException("Không thể vô hiệu hóa quản trị viên cuối cùng");
        }
    }

    private AdminUserResponseDto toDto(User u) {
        int tripsCount = 0;
        try {
            tripsCount = itineraryRepository.findByUserId(u.getId()).size();
        } catch (Exception e) {
            tripsCount = 0;
        }

        return new AdminUserResponseDto(
                u.getId(),
                u.getEmail(),
                u.getFullName(),
                u.getRole(),
                u.getStatus(),
                u.getCreatedAt(),
                u.getUpdatedAt(),
                tripsCount
        );
    }
}
