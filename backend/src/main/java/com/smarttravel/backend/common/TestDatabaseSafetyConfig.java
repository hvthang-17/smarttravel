package com.smarttravel.backend.common;

import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;
import java.net.URI;

@Configuration
@Profile("test")
public class TestDatabaseSafetyConfig {
    @Bean
    public static BeanFactoryPostProcessor testDatabaseSafety(Environment environment) {
        return beanFactory -> requireTestDatabase(environment.getRequiredProperty("spring.datasource.url"));
    }

    public static void requireTestDatabase(String url) {
        if (!url.startsWith("jdbc:mysql://")
                || !"/smarttravel_test".equals(URI.create(url.substring(5)).getPath())) {
            throw new IllegalStateException("The test profile requires the smarttravel_test database");
        }
    }
}
