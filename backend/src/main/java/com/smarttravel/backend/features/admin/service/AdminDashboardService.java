package com.smarttravel.backend.features.admin.service;

import org.springframework.stereotype.Service;
import org.springframework.jdbc.core.JdbcTemplate;


import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.ZoneId;

@Service
public class AdminDashboardService {
    public record Metrics(LocalDate from, LocalDate to, long activeDestinations, long totalUsers, long activeUsers,
                          long lockedUsers, long administrators, long newUsers, long createdSavedTrips,
                          long publishedReviews, long reportedReviews) {}
    private static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private final JdbcTemplate db;

    public AdminDashboardService(JdbcTemplate db) { this.db = db; }

    public Metrics summary(int days) {
        if (!java.util.Set.of(7, 30, 90).contains(days)) throw new IllegalArgumentException("Chọn 7, 30 hoặc 90 ngày");
        var today = LocalDate.now(ZONE);
        var start = today.minusDays(days - 1L);
        var from = Timestamp.from(start.atStartOfDay(ZONE).toInstant());
        var to = Timestamp.from(today.plusDays(1).atStartOfDay(ZONE).toInstant());
        var metrics = db.queryForObject("""
                select
                  (select count(*) from destinations d join categories c on c.id=d.category_id
                   where d.status='ACTIVE' and c.status='ACTIVE' and c.code in ('BEACH','FOOD','CULTURE','CHECKIN','CAFE','NIGHTLIFE')),
                  (select count(*) from users),
                  (select count(*) from users where status='ACTIVE'),
                  (select count(*) from users where status='LOCKED'),
                  (select count(*) from users where role='ROLE_ADMIN'),
                  (select count(*) from users where created_at>=? and created_at<?),
                  (select count(*) from itineraries where status='SAVED' and created_at>=? and created_at<?),
                  (select count(*) from destination_reviews where status='PUBLISHED' and created_at>=? and created_at<?),
                  (select count(distinct a.entity_id) from audit_logs a join destination_reviews r on r.id=a.entity_id
                   where a.entity_type='REVIEW' and a.action='REPORT' and a.created_at>=? and a.created_at<?)
                """, (rs, row) -> new Metrics(start, today, rs.getLong(1), rs.getLong(2), rs.getLong(3),
                rs.getLong(4), rs.getLong(5), rs.getLong(6), rs.getLong(7), rs.getLong(8), rs.getLong(9)),
                from, to, from, to, from, to, from, to);
        return metrics;
    }
}
