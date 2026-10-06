package com.smarttravel.backend.common;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/health", "/actuator/health").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/destinations", "/api/v1/destinations/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/api/v1/destinations", "/api/v1/destinations/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/v1/destinations", "/api/v1/destinations/**").hasRole("ADMIN")
                .anyRequest().authenticated());
        return http.build();
    }
}



