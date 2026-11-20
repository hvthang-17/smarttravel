package com.smarttravel.backend.features.audit.api;

import com.smarttravel.backend.common.ApiResponse;
import com.smarttravel.backend.features.audit.service.AuditQueryService;
import com.smarttravel.backend.features.audit.service.AuditQueryService.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/admin/audit")
public class AdminAuditController {
    private final AuditQueryService audit;

    public AdminAuditController(AuditQueryService audit) { this.audit = audit; }

    @GetMapping
    public ApiResponse<Page> page(@ModelAttribute Filter filter, @RequestParam(defaultValue = "0") int page,
                                  @RequestParam(defaultValue = "25") int size) {
        return ApiResponse.success(audit.page(filter, page, size));
    }

    @GetMapping("/export")
    public ApiResponse<Export> export(@ModelAttribute Filter filter) {
        return ApiResponse.success(audit.export(filter));
    }
}
