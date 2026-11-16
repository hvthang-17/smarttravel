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
    private final com.smarttravel.backend.features.auth.repository.PasswordResetRepository resetTokens;
    private final com.smarttravel.backend.features.audit.repository.AuditLogRepository auditLogs;
    private final com.smarttravel.backend.features.audit.service.AuditService audit;

    public AdminUserService(UserRepository userRepository, ItineraryRepository itineraryRepository, PasswordEncoder passwordEncoder,
                            com.smarttravel.backend.features.audit.service.AuditService audit,
                            com.smarttravel.backend.features.auth.repository.PasswordResetRepository resetTokens,
                            com.smarttravel.backend.features.audit.repository.AuditLogRepository auditLogs) {
        this.userRepository = userRepository;
        this.itineraryRepository = itineraryRepository;
        this.passwordEncoder = passwordEncoder;
        this.audit = audit;
        this.resetTokens = resetTokens;
        this.auditLogs = auditLogs;
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

    public record UserPage(List<AdminUserResponseDto> items, boolean hasNext) {}

    @Transactional(readOnly = true)
    public UserPage page(String search, String role, String status, int page, int size) {
        if (search.length() > 255 || !Set.of("ALL", "ROLE_ADMIN", "ROLE_USER").contains(role)
                || !Set.of("ALL", "ACTIVE", "LOCKED", "INACTIVE").contains(status)
                || page < 0 || page > 100_000 || size < 1 || size > 100) {
            throw new IllegalArgumentException("Bộ lọc người dùng không hợp lệ");
        }
        var result = userRepository.adminPage(search.strip().toLowerCase(java.util.Locale.ROOT), role, status,
                org.springframework.data.domain.PageRequest.of(page, size));
        var counts = new java.util.HashMap<Long, Long>();
        if (!result.isEmpty()) itineraryRepository.countByOwners(result.stream().map(User::getId).toList())
                .forEach(entry -> counts.put(entry.getOwnerId(), entry.getTripCount()));
        return new UserPage(result.stream().map(u -> toDto(u, counts.getOrDefault(u.getId(), 0L))).toList(), result.hasNext());
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
        audit.record("USER", saved.getId(), "CREATE", java.util.Map.of("role", saved.getRole(), "status", saved.getStatus()));
        return toDto(saved);
    }

    @Transactional
    public AdminUserResponseDto updateUser(Long id, AdminUpdateUserRequest request) {
        List<User> admins = userRepository.lockAdministrators();
        User user = userRepository.lockById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));
        String nextRole = request.getRole() == null || request.getRole().isBlank() ? user.getRole() : request.getRole().trim();
        String nextStatus = request.getStatus() == null || request.getStatus().isBlank() ? user.getStatus() : request.getStatus().trim().toUpperCase();
        validateRoleAndStatus(nextRole, nextStatus);
        protectAdministrator(user, nextRole, nextStatus, admins);
        if (!user.getRole().equals(nextRole) || !user.getStatus().equals(nextStatus)
                || (request.getPassword() != null && !request.getPassword().isBlank())) {
            revokeCredentials(user);
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
        var fields = new java.util.ArrayList<String>();
        if (request.getFullName() != null && !request.getFullName().isBlank()) fields.add("fullName");
        if (request.getRole() != null && !request.getRole().isBlank()) fields.add("role");
        if (request.getStatus() != null && !request.getStatus().isBlank()) fields.add("status");
        audit.record("USER", saved.getId(), "UPDATE", java.util.Map.of("fields", fields, "role", saved.getRole(), "status", saved.getStatus(),
                "credentialsChanged", request.getPassword() != null && !request.getPassword().isBlank()));
        return toDto(saved);
    }

    @Transactional
    public AdminUserResponseDto updateUserStatus(Long id, String status) {
        List<User> admins = userRepository.lockAdministrators();
        User user = userRepository.lockById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));

        String nextStatus = status.trim().toUpperCase();
        validateRoleAndStatus(user.getRole(), nextStatus);
        protectAdministrator(user, user.getRole(), nextStatus, admins);
        if (!user.getStatus().equals(nextStatus)) revokeCredentials(user);
        user.setStatus(nextStatus);
        User saved = userRepository.save(user);
        audit.record("USER", saved.getId(), "STATUS", java.util.Map.of("status", saved.getStatus()));
        return toDto(saved);
    }

    @Transactional
    public void deleteUser(Long id, String currentUserEmail) {
        List<User> admins = userRepository.lockAdministrators();
        User user = userRepository.lockById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + id));

        if (currentUserEmail != null && currentUserEmail.equalsIgnoreCase(user.getEmail())) {
            throw new IllegalArgumentException("Không thể tự xóa tài khoản của chính bạn");
        }

        protectAdministrator(user, user.getRole(), "INACTIVE", admins);
        auditLogs.anonymizeActor(user.getId());
        userRepository.delete(user);
        audit.record("USER", user.getId(), "DELETE", java.util.Map.of());
    }

    private void revokeCredentials(User user) {
        user.revokeSessions();
        resetTokens.consumeAll(user.getId(), java.time.LocalDateTime.now(java.time.ZoneOffset.UTC));
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
        return toDto(u, itineraryRepository.countByUserId(u.getId()));
    }

    private AdminUserResponseDto toDto(User u, long tripsCount) {
        return new AdminUserResponseDto(
                u.getId(),
                u.getEmail(),
                u.getFullName(),
                u.getRole(),
                u.getStatus(),
                u.getCreatedAt(),
                u.getUpdatedAt(),
                Math.toIntExact(tripsCount)
        );
    }
}
