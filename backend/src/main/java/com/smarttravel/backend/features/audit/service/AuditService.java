package com.smarttravel.backend.features.audit.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarttravel.backend.common.CurrentUser;
import com.smarttravel.backend.features.audit.domain.AuditLog;
import com.smarttravel.backend.features.audit.repository.AuditLogRepository;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service
public class AuditService {
    private final AuditLogRepository logs;
    private final UserRepository users;
    private final ObjectMapper json;
    private static final Set<String> SAFE_FIELDS = Set.of("name", "nameEn", "description", "descriptionEn", "address",
            "phone", "website", "imageUrl", "subImages", "categoryId", "openingSchedule", "openingHours",
            "priceMinVnd", "priceMaxVnd", "googleRating", "googleReviewCount", "visitDurationMinutes", "osmId",
            "latitude", "longitude", "status", "fullName", "role", "language", "defaultBudgetVnd", "defaultPace",
            "defaultTransport", "preferredCategories", "icon", "colorHex", "displayOrder", "featuredReason");

    public AuditService(AuditLogRepository logs, UserRepository users, ObjectMapper json) {
        this.logs = logs; this.users = users; this.json = json;
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public void record(String entityType, Long entityId, String action, Map<String, ?> details) {
        var actor = users.findByEmail(CurrentUser.email()).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người thực hiện"));
        write(entityType, entityId, action, actor.getId(), "REPORT".equals(action) ? null : actor.getFullName(), details);
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public void registration(Long userId) {
        var actor = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        if (actor != null && actor.isAuthenticated() && !"anonymousUser".equals(actor.getName())) {
            record("USER", userId, "REGISTER", Map.of());
        } else {
            write("USER", userId, "REGISTER", null, "PUBLIC_REGISTRATION", Map.of());
        }
    }

    private void write(String type, Long id, String action, Long actorId, String actorName, Map<String, ?> details) {
        if (!Set.of("CATEGORY", "DESTINATION", "USER", "REVIEW").contains(type)
                || !Set.of("CREATE", "UPDATE", "ARCHIVE", "STATUS", "DELETE", "PROFILE", "REGISTER", "MODERATE", "REPORT").contains(action)) {
            throw new IllegalArgumentException("Loại sự kiện audit không hợp lệ");
        }
        AuditLog log = new AuditLog();
        log.setUserId(actorId); log.setActorName(actorName); log.setEntityType(type); log.setEntityId(id); log.setAction(action);
        try { log.setDetails(json.writeValueAsString(safeDetails(type, action, details))); }
        catch (JsonProcessingException ex) { throw new IllegalArgumentException("Không thể ghi audit", ex); }
        logs.saveAndFlush(log);
    }

    static Map<String, Object> safeDetails(String type, String action, Map<String, ?> details) {
        Map<String, Object> safe = new LinkedHashMap<>();
        if (details.get("fields") instanceof Collection<?> fields) {
            safe.put("fields", fields.stream().filter(value -> value instanceof String && SAFE_FIELDS.contains(value)).toList());
        }
        for (String key : List.of("status", "role")) {
            Object value = details.get(key);
            if (value instanceof String && Set.of("ACTIVE", "INACTIVE", "LOCKED", "ROLE_USER", "ROLE_ADMIN", "PUBLISHED", "HIDDEN").contains(value)) safe.put(key, value);
        }
        if (details.get("categoryId") instanceof Number value) safe.put("categoryId", value.longValue());
        if (details.get("credentialsChanged") instanceof Boolean value) safe.put("credentialsChanged", value);
        if ("REVIEW".equals(type) && "REPORT".equals(action)
                && details.get("reason") instanceof String reason
                && Set.of("SPAM", "ABUSE", "IRRELEVANT", "OTHER").contains(reason)) safe.put("reason", reason);
        return safe;
    }
}
