package com.smarttravel.backend.features.audit.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.*;

@Service
public class AuditQueryService {
    public record Filter(String actor, Long actorId, String action, String entity,
                         @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate from,
                         @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate to) {}
    public record Row(long id, Long actorId, String actorName, String action, String entity, Long entityId,
                      Instant createdAt, Map<String, Object> details) {}
    public record Page(List<Row> items, boolean hasNext, int page) {}
    public record Export(String filename, String csv) {}
    private static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final int EXPORT_LIMIT = 5000;
    private final NamedParameterJdbcTemplate db;
    private final ObjectMapper json;

    public AuditQueryService(NamedParameterJdbcTemplate db, ObjectMapper json) {
        this.db = db;
        this.json = json;
    }

    public Page page(Filter filter, int page, int size) {
        if (page < 0 || page > 100_000 || size < 1 || size > 100) {
            throw new IllegalArgumentException("Phân trang audit không hợp lệ");
        }
        var rows = query(filter, page * size, size + 1);
        return new Page(rows.subList(0, Math.min(size, rows.size())), rows.size() > size, page);
    }

    public Export export(Filter filter) {
        var rows = query(filter, 0, EXPORT_LIMIT + 1);
        if (rows.size() > EXPORT_LIMIT) throw new IllegalArgumentException("Hãy thu hẹp bộ lọc để xuất tối đa 5.000 sự kiện");
        var csv = new StringBuilder("id,actorId,actorName,action,entity,entityId,createdAtUtc,details\r\n");
        for (var row : rows) {
            csv.append(String.join(",", cell(row.id()), cell(row.actorId()), cell(row.actorName()),
                    cell(row.action()), cell(row.entity()), cell(row.entityId()), cell(row.createdAt()),
                    cell(serialize(row.details())))).append("\r\n");
        }
        return new Export("audit-" + LocalDate.now(ZONE) + ".csv", csv.toString());
    }

    private List<Row> query(Filter filter, int offset, int limit) {
        var actor = text(filter.actor());
        if (actor.length() > 150 || (filter.actorId() != null && filter.actorId() <= 0)
                || (filter.from() != null && filter.to() != null && filter.from().isAfter(filter.to()))) {
            throw new IllegalArgumentException("Bộ lọc audit không hợp lệ");
        }
        var params = new MapSqlParameterSource().addValue("offset", offset).addValue("limit", limit);
        var sql = new StringBuilder("""
                select id,user_id,actor_name,action,entity_type,entity_id,created_at,details from audit_logs where 1=1
                """);
        if (!actor.isEmpty()) {
            sql.append(" and locate(:actor, lower(actor_name)) > 0");
            params.addValue("actor", actor.toLowerCase(Locale.ROOT));
        }
        if (filter.actorId() != null) {
            sql.append(" and user_id = :actorId");
            params.addValue("actorId", filter.actorId());
        }
        equal(sql, params, "action", filter.action());
        equal(sql, params, "entity_type", filter.entity());
        if (filter.from() != null) {
            sql.append(" and created_at >= :lower");
            params.addValue("lower", boundary(filter.from()));
        }
        if (filter.to() != null) {
            sql.append(" and created_at < :upper");
            params.addValue("upper", boundary(filter.to().plusDays(1)));
        }
        sql.append(" order by created_at desc,id desc limit :limit offset :offset");
        return db.query(sql.toString(), params, (rs, index) -> new Row(rs.getLong("id"),
                rs.getObject("user_id", Long.class), rs.getString("actor_name"), rs.getString("action"),
                rs.getString("entity_type"), rs.getObject("entity_id", Long.class),
                rs.getTimestamp("created_at").toInstant(),
                details(rs.getString("entity_type"), rs.getString("action"), rs.getString("details"))));
    }

    private Map<String, Object> details(String type, String action, String value) {
        if (value == null) return Map.of();
        try {
            Map<String, Object> raw = json.readValue(value, new TypeReference<>() {});
            return raw == null ? Map.of() : AuditService.safeDetails(type, action, raw);
        } catch (com.fasterxml.jackson.core.JsonProcessingException ignored) {
            return Map.of();
        }
    }

    private String serialize(Map<String, Object> value) {
        try { return json.writeValueAsString(value); }
        catch (com.fasterxml.jackson.core.JsonProcessingException error) { throw new IllegalStateException(error); }
    }

    private static void equal(StringBuilder sql, MapSqlParameterSource params, String column, String value) {
        var normalized = text(value).toUpperCase(Locale.ROOT);
        if (normalized.isEmpty()) return;
        if (!normalized.matches("[A-Z_]{1,50}")) throw new IllegalArgumentException("Mã bộ lọc audit không hợp lệ");
        sql.append(" and ").append(column).append(" = :").append(column);
        params.addValue(column, normalized);
    }

    private static Timestamp boundary(LocalDate date) {
        return Timestamp.from(date.atStartOfDay(ZONE).toInstant());
    }

    private static String text(String value) { return value == null ? "" : value.strip(); }

    private static String cell(Object value) {
        var text = value == null ? "" : String.valueOf(value);
        var stripped = text.stripLeading();
        if (!stripped.isEmpty() && "=+-@".indexOf(stripped.charAt(0)) >= 0) text = "'" + text;
        return "\"" + text.replace("\"", "\"\"") + "\"";
    }
}
