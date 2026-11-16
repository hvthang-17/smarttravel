package com.smarttravel.backend.features.auth.service;

import com.smarttravel.backend.common.*;
import com.smarttravel.backend.features.audit.service.AuditService;
import com.smarttravel.backend.features.audit.repository.AuditLogRepository;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Map;

@Service
public class AccountDeletionService {
    private final UserRepository users;
    private final PasswordEncoder encoder;
    private final AuditService audit;
    private final AuditLogRepository logs;

    public AccountDeletionService(UserRepository users, PasswordEncoder encoder, AuditService audit, AuditLogRepository logs) {
        this.users = users;
        this.encoder = encoder;
        this.audit = audit;
        this.logs = logs;
    }

    @Transactional
    public void delete(String password) {
        var admins = users.lockAdministrators();
        var user = users.lockByEmail(CurrentUser.email()).orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản"));
        CurrentUser.requireCurrentAccount(user);
        if (password.getBytes(java.nio.charset.StandardCharsets.UTF_8).length > 72 || !encoder.matches(password, user.getPasswordHash())) {
            throw new IllegalArgumentException("Mật khẩu hiện tại không đúng");
        }
        if (!"ACTIVE".equals(user.getStatus())) throw new org.springframework.security.access.AccessDeniedException("Tài khoản không hoạt động");
        if ("ROLE_ADMIN".equals(user.getRole()) && admins.stream().filter(admin -> "ACTIVE".equals(admin.getStatus())).count() <= 1) {
            throw new ResourceConflictException("Không thể xóa quản trị viên đang hoạt động cuối cùng");
        }
        audit.record("USER", user.getId(), "DELETE", Map.of());
        logs.anonymizeActor(user.getId());
        users.delete(user);
        users.flush();
    }
}
