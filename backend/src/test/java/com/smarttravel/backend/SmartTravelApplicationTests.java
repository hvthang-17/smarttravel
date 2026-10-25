package com.smarttravel.backend;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import java.util.List;
import java.util.Map;

@SpringBootTest
@ActiveProfiles("test")
public class SmartTravelApplicationTests {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void contextLoads() {
        try {
            List<Map<String, Object>> cols = jdbcTemplate.queryForList("DESCRIBE categories");
            for (Map<String, Object> col : cols) {
                System.out.println(">>> CATEGORIES COL: " + col);
            }
            List<Map<String, Object>> rows = jdbcTemplate.queryForList("SELECT * FROM categories");
            System.out.println(">>> CATEGORIES COUNT: " + rows.size());
            for (Map<String, Object> r : rows) {
                System.out.println(">>> CATEGORY ROW: " + r);
            }
        } catch (Exception e) {
            System.out.println(">>> ERROR: " + e.getMessage());
        }
    }
}
