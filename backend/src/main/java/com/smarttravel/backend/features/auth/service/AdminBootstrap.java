package com.smarttravel.backend.features.auth.service;

import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.util.Locale;
import com.smarttravel.backend.common.PasswordPolicy;

@Component
@ConditionalOnProperty(name = "app.bootstrap.enabled", havingValue = "true")
public class AdminBootstrap implements ApplicationRunner {
    private final UserRepository users;
    private final PasswordEncoder encoder;
    private final String email;
    private final String password;

    public AdminBootstrap(UserRepository users, PasswordEncoder encoder,
                          @Value("${app.bootstrap.email:}") String email,
                          @Value("${app.bootstrap.password:}") String password) {
        this.users = users;
        this.encoder = encoder;
        this.email = email.trim().toLowerCase(Locale.ROOT);
        this.password = password;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        PasswordPolicy.validate(password);
        if (!email.matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+") || password.length() < 8 || password.length() > 72) {
            throw new IllegalArgumentException("Bootstrap requires a valid email and an 8–72 character password");
        }
        var existing = users.findByEmail(email);
        if (existing.isPresent()) {
            if (!"ROLE_ADMIN".equals(existing.get().getRole()) || !"ACTIVE".equals(existing.get().getStatus())) {
                throw new IllegalStateException("Bootstrap cannot promote or unlock an existing account");
            }
            return;
        }
        users.save(new User(email, encoder.encode(password), "Administrator", "ROLE_ADMIN"));
    }
}
