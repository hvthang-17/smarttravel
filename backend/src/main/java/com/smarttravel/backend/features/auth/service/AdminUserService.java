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
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));

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
            if (request.getPassword().length() < 6) {
                throw new IllegalArgumentException("Mật khẩu phải có tối thiểu 6 ký tự");
            }
            user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        }

        User saved = userRepository.save(user);
        return toDto(saved);
    }

    @Transactional
    public AdminUserResponseDto updateUserStatus(Long id, String status) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));

        user.setStatus(status.trim().toUpperCase());
        User saved = userRepository.save(user);
        return toDto(saved);
    }

    @Transactional
    public void deleteUser(Long id, String currentUserEmail) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));

        if (currentUserEmail != null && currentUserEmail.equalsIgnoreCase(user.getEmail())) {
            throw new IllegalArgumentException("Không thể tự xóa tài khoản của chính bạn");
        }

        userRepository.delete(user);
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
