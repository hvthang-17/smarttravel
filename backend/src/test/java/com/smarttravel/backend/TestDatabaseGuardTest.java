package com.smarttravel.backend;

import org.junit.jupiter.api.Test;
import org.springframework.context.support.GenericApplicationContext;
import org.springframework.core.env.MapPropertySource;
import java.util.Map;
import static org.junit.jupiter.api.Assertions.*;
import com.smarttravel.backend.common.TestDatabaseSafetyConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import java.util.concurrent.atomic.AtomicBoolean;

class TestDatabaseGuardTest {
    @Test
    void manualTestProfileRejectsDevelopmentDatabaseBeforeAnyDataSourceBeanIsCreated() {
        AtomicBoolean created = new AtomicBoolean();
        try (var context = new AnnotationConfigApplicationContext()) {
            context.getEnvironment().setActiveProfiles("test");
            context.getEnvironment().getPropertySources().addFirst(new MapPropertySource("unsafe-url",
                    Map.of("spring.datasource.url", "jdbc:mysql://localhost:3306/smarttravel")));
            context.register(TestDatabaseSafetyConfig.class);
            context.registerBean("dataSourceProbe", Object.class, () -> {
                created.set(true);
                return new Object();
            });
            assertThrows(IllegalStateException.class, context::refresh);
            assertFalse(created.get());
        }
    }

    @Test
    void rejectsDevelopmentDatabaseBeforeContextRefresh() {
        try (var context = context("jdbc:mysql://localhost:3306/smarttravel?serverTimezone=UTC")) {
            assertThrows(IllegalStateException.class, () -> new TestDatabaseGuard().initialize(context));
            assertFalse(context.isActive());
        }
    }

    @Test
    void acceptsOnlyDedicatedDatabasePath() {
        try (var context = context("jdbc:mysql://localhost:3306/smarttravel_test?serverTimezone=UTC")) {
            assertDoesNotThrow(() -> new TestDatabaseGuard().initialize(context));
        }
        try (var context = context("jdbc:mysql://localhost:3306/smarttravel?name=smarttravel_test")) {
            assertThrows(IllegalStateException.class, () -> new TestDatabaseGuard().initialize(context));
        }
    }

    private GenericApplicationContext context(String url) {
        var context = new GenericApplicationContext();
        context.getEnvironment().getPropertySources().addFirst(
                new MapPropertySource("test-url", Map.of("spring.datasource.url", url)));
        return context;
    }
}
