package com.smarttravel.backend.features.itinerary.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;

@Service
public class AdminTripOverview {
    public record Trip(long id, String title, String owner, String status, LocalDate startDate, LocalDate endDate) {}
    public record Page(List<Trip> items, boolean hasNext) {}

    private final JdbcTemplate db;

    public AdminTripOverview(JdbcTemplate db) {
        this.db = db;
    }

    public Page page(String search, String status, int page, int size) {
        if (search.length() > 255 || !java.util.Set.of("ALL", "SAVED", "ARCHIVED").contains(status)
                || page < 0 || page > 100_000 || size < 1 || size > 100) {
            throw new IllegalArgumentException("Bộ lọc lịch trình không hợp lệ");
        }
        var query = search.strip().toLowerCase(java.util.Locale.ROOT);
        var results = db.query("""
                select i.id,i.title,u.full_name,i.status,i.start_date,i.end_date from itineraries i
                join users u on u.id=i.user_id where i.status<>'DRAFT' and (?='ALL' or i.status=?)
                and (?='' or locate(?, lower(i.title))>0 or locate(?, lower(u.full_name))>0)
                order by i.updated_at desc,i.id desc limit ? offset ?
                """, (rs, row) -> new Trip(rs.getLong(1), rs.getString(2), rs.getString(3), rs.getString(4),
                rs.getObject(5, LocalDate.class), rs.getObject(6, LocalDate.class)),
                status, status, query, query, query, size + 1, page * size);
        return new Page(results.subList(0, Math.min(size, results.size())), results.size() > size);
    }
}
