package com.smarttravel.backend.common;

import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class CurrentUser {
    private CurrentUser() {}

    public static void requireCurrentAccount(com.smarttravel.backend.features.auth.domain.User user) {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getDetails() instanceof com.smarttravel.backend.features.auth.security.JwtAuthenticationFilter.Session session)
                || session.userId() != user.getId() || session.authVersion() != user.getAuthVersion()) {
            throw new org.springframework.security.authentication.BadCredentialsException("Phiên đăng nhập đã hết hiệu lực");
        }
    }

    public static boolean isAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null && auth.getAuthorities().stream()
                .anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()));
    }

    public static String email() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getName())) {
            throw new AuthenticationCredentialsNotFoundException("Vui lòng đăng nhập");
        }
        return auth.getName();
    }
}
