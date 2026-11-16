package com.smarttravel.backend.features.destination.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public final class OpeningHours {
    private static final ObjectMapper JSON = new ObjectMapper();
    private OpeningHours() {}

    public static String normalize(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            JsonNode root = JSON.readTree(value);
            if (!root.isObject() || !root.path("schema_version").isIntegralNumber()
                    || root.path("schema_version").asInt() != 1
                    || !"Asia/Ho_Chi_Minh".equals(root.path("timezone").asText())) {
                throw new IllegalArgumentException("Giờ mở cửa cần schema_version=1 và timezone=Asia/Ho_Chi_Minh");
            }
            JsonNode week = root.path("week");
            if (!week.isObject() || week.size() != 7) throw new IllegalArgumentException("Lịch tuần phải đủ 7 ngày");
            for (int day = 1; day <= 7; day++) {
                JsonNode periods = week.get(String.valueOf(day));
                if (periods == null) throw new IllegalArgumentException("Lịch tuần thiếu ngày " + day);
                if (periods.isNull()) continue;
                if (!periods.isArray()) throw new IllegalArgumentException("Khung giờ phải là mảng");
                int previousEnd = 0;
                for (JsonNode period : periods) {
                    if (!period.isArray() || period.size() != 2 || !period.get(0).isIntegralNumber()
                            || !period.get(1).isIntegralNumber() || !period.get(0).canConvertToInt() || !period.get(1).canConvertToInt()) throw new IllegalArgumentException("Khung giờ phải gồm hai số phút");
                    int start = period.get(0).asInt(-1), end = period.get(1).asInt(-1);
                    if (start < previousEnd || start < 0 || start >= end || end > 1440) {
                        throw new IllegalArgumentException("Khung giờ sai hoặc chồng lấn");
                    }
                    previousEnd = end;
                }
            }
            return JSON.writeValueAsString(root);
        } catch (IllegalArgumentException ex) { throw ex; }
        catch (Exception ex) { throw new IllegalArgumentException("Giờ mở cửa phải là JSON lịch tuần hợp lệ"); }
    }

    public static JsonNode tree(String value) {
        if (value == null) return null;
        try { return JSON.readTree(value); }
        catch (Exception ex) { throw new IllegalArgumentException("Dữ liệu giờ mở cửa không hợp lệ"); }
    }

    public static String display(String value) {
        JsonNode root = tree(value);
        if (root == null) return null;
        StringBuilder result = new StringBuilder();
        for (int day = 1; day <= 7; day++) {
            if (day > 1) result.append("; ");
            result.append(day == 7 ? "CN" : "T" + (day + 1)).append(": ");
            JsonNode periods = root.path("week").get(String.valueOf(day));
            if (periods == null || periods.isNull()) result.append("Chưa rõ");
            else if (periods.isEmpty()) result.append("Đóng cửa");
            else {
                for (int i = 0; i < periods.size(); i++) {
                    if (i > 0) result.append(", ");
                    JsonNode period = periods.get(i);
                    result.append(time(period.get(0).asInt())).append("–").append(time(period.get(1).asInt()));
                }
            }
        }
        return result.toString();
    }

    private static String time(int minute) { return String.format("%02d:%02d", minute / 60, minute % 60); }
}
