package com.smarttravel.backend;

import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;

import com.smarttravel.backend.common.TestDatabaseSafetyConfig;

public class TestDatabaseGuard implements ApplicationContextInitializer<ConfigurableApplicationContext> {
    @Override
    public void initialize(ConfigurableApplicationContext context) {
        String url = context.getEnvironment().getRequiredProperty("spring.datasource.url");
        TestDatabaseSafetyConfig.requireTestDatabase(url);
    }
}
