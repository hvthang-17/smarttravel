package com.smarttravel.backend.features.auth.service;

import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.dto.*;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.auth.security.JwtTokenProvider;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.authentication.BadCredentialsException;
import java.util.Locale;
import com.smarttravel.backend.common.PasswordPolicy;

@Service
public class AuthService {

    private final com.smarttravel.backend.features.profile.service.TravelerProfileService travelerProfiles;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final com.smarttravel.backend.features.audit.service.AuditService audit;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtTokenProvider tokenProvider, com.smarttravel.backend.features.profile.service.TravelerProfileService travelerProfiles,
                       com.smarttravel.backend.features.audit.service.AuditService audit) {
        this.travelerProfiles = travelerProfiles;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
        this.audit = audit;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        PasswordPolicy.validate(request.getPassword());
        String email = request.getEmail().trim().toLowerCase(Locale.ROOT);
        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email is already in use");
        }

        User user = new User(
                email,
                passwordEncoder.encode(request.getPassword()),
                request.getFullName(),
                "ROLE_USER"
        );

        User savedUser = userRepository.save(user);
        audit.registration(savedUser.getId());
        String token = tokenProvider.generateToken(savedUser.getEmail(), savedUser.getRole(), savedUser.getAuthVersion(), savedUser.getId());

        return responseWithProfile(savedUser, token);
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        if (request.getPassword().getBytes(java.nio.charset.StandardCharsets.UTF_8).length > 72) {
            throw new BadCredentialsException("Invalid email or password");
        }
        User user = userRepository.findByEmail(request.getEmail().trim().toLowerCase(Locale.ROOT))
                .orElseThrow(() -> new BadCredentialsException("Invalid email or password"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash()) || !"ACTIVE".equals(user.getStatus())) {
            throw new BadCredentialsException("Invalid email or password");
        }

        String token = tokenProvider.generateToken(user.getEmail(), user.getRole(), user.getAuthVersion(), user.getId());

        return responseWithProfile(user, token);
    }

    @Transactional(readOnly = true)
    public AuthResponse getProfile(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với email: " + email));
        com.smarttravel.backend.common.CurrentUser.requireCurrentAccount(user);
        AuthResponse response = new AuthResponse(null, user.getId(), user.getEmail(), user.getFullName(), user.getRole());
        response.setTravelerProfile(travelerProfiles.get(user.getId()));
        return response;
    }

    @Transactional
    public AuthResponse updateProfile(String email, UpdateProfileRequest request) {
        User user = userRepository.lockByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với email: " + email));
        com.smarttravel.backend.common.CurrentUser.requireCurrentAccount(user);

        user.setFullName(request.getFullName().trim());
        User saved = userRepository.save(user);

        AuthResponse response = new AuthResponse(null, saved.getId(), saved.getEmail(), saved.getFullName(), saved.getRole());
        response.setTravelerProfile(travelerProfiles.update(saved.getId(), request));
        var fields = new java.util.ArrayList<String>(); fields.add("fullName");
        if (request.getLanguage() != null) fields.add("language");
        if (request.hasDefaultBudget()) fields.add("defaultBudgetVnd");
        if (request.getDefaultPace() != null) fields.add("defaultPace");
        if (request.getDefaultTransport() != null) fields.add("defaultTransport");
        if (request.getPreferredCategories() != null) fields.add("preferredCategories");
        audit.record("USER", saved.getId(), "PROFILE", java.util.Map.of("fields", fields));
        return response;
    }
    private AuthResponse responseWithProfile(User user, String token) {
        AuthResponse response = new AuthResponse(token, user.getId(), user.getEmail(), user.getFullName(), user.getRole());
        response.setTravelerProfile(travelerProfiles.get(user.getId()));
        return response;
    }
}
