package com.smarttravel.backend.features.itinerary.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarttravel.backend.common.ResourceConflictException;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.dto.GenerateItineraryRequest;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;
import java.time.*;
import java.util.*;

@Component
class TripGenerationInput {
    private final ObjectMapper json;
    TripGenerationInput(ObjectMapper json) { this.json = json; }

    String snapshot(GenerateItineraryRequest request) {
        var values = new LinkedHashMap<String, Object>();
        values.put("title", request.getTitle().trim());
        values.put("startDate", request.getStartDate().toString());
        values.put("endDate", request.getEndDate().toString());
        values.put("travelersCount", request.getTravelersCount());
        values.put("maxBudgetVnd", request.getMaxBudgetVnd());
        values.put("pace", request.getPace());
        values.put("transport", transport(request));
        values.put("originName", origin(request));
        values.put("originLatitude", coordinate(request.getOriginLatitude()));
        values.put("originLongitude", coordinate(request.getOriginLongitude()));
        values.put("preferredCategories", sorted(request.getPreferredCategories()));
        values.put("profileCategoryDefaults", request.getPreferredCategories() == null);
        values.put("requiredDestinationIds", sorted(request.getRequiredDestinationIds()));
        values.put("excludedDestinationIds", sorted(request.getExcludedDestinationIds()));
        values.put("favoriteDestinationIds", request.getFavoriteDestinationIds() == null ? List.of() : request.getFavoriteDestinationIds());
        try { return json.writeValueAsString(values); }
        catch (JsonProcessingException error) { throw new IllegalStateException("Không thể lưu đầu vào tạo chuyến", error); }
    }

    void verifyReplay(Itinerary existing, String input) {
        String original = existing.getGenerationInput();
        try {
            if (original != null) {
                var saved = json.readTree(original);
                var incoming = (com.fasterxml.jackson.databind.node.ObjectNode) json.readTree(input);
                if (!saved.has("profileCategoryDefaults")) incoming.remove("profileCategoryDefaults");
                if (saved.equals(incoming)) return;
            }
        } catch (JsonProcessingException error) {
            throw new IllegalStateException("Không đọc được đầu vào tạo chuyến đã lưu", error);
        }
        throw new ResourceConflictException("Mã tạo chuyến đã được dùng với đầu vào khác");
    }

    void validatePlanningWindow(GenerateItineraryRequest request) {
        LocalDate today = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        if (request.getStartDate().isBefore(today) || request.getEndDate().isAfter(today.plusDays(365))) {
            throw new IllegalArgumentException("Ngày chuyến đi phải nằm trong khoảng từ hôm nay đến 365 ngày tới");
        }
    }

    static String transport(GenerateItineraryRequest request) {
        return request.getTransport() == null ? "unspecified" : request.getTransport();
    }

    static String origin(GenerateItineraryRequest request) {
        var origin = request.getOriginName();
        return origin == null || origin.isBlank() ? null : origin.trim();
    }

    private static String coordinate(BigDecimal value) {
        return value == null ? null : value.stripTrailingZeros().toPlainString();
    }

    private static <T extends Comparable<? super T>> List<T> sorted(List<T> values) {
        return values == null ? List.of() : values.stream().sorted().toList();
    }
}
