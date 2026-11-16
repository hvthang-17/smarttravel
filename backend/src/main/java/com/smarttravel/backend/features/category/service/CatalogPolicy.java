package com.smarttravel.backend.features.category.service;

import com.smarttravel.backend.features.category.domain.Category;
import com.smarttravel.backend.features.category.repository.CategoryRepository;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class CatalogPolicy {
    public static final Set<String> CODES = Set.of("BEACH", "FOOD", "CULTURE", "CHECKIN", "CAFE", "NIGHTLIFE");
    private final CategoryRepository categories;
    public CatalogPolicy(CategoryRepository categories) { this.categories = categories; }

    public static boolean inScope(Category category) { return category != null && CODES.contains(category.getCode()); }
    public static boolean available(Category category) { return inScope(category) && "ACTIVE".equals(category.getStatus()); }
    public static void requireCode(String code) {
        if (!CODES.contains(code == null ? "" : code)) throw new IllegalArgumentException(
                "Mã danh mục không còn được hỗ trợ: " + code + ". Dùng BEACH, FOOD, CULTURE, CHECKIN, CAFE hoặc NIGHTLIFE; HOTEL đã bỏ khỏi phạm vi.");
    }
    public List<String> preferences(List<String> values) {
        if (values == null) return List.of();
        Set<String> result = new LinkedHashSet<>();
        for (String code : values) {
            requireCode(code);
            Category category = categories.findByCode(code).orElseThrow(() -> new IllegalArgumentException("Danh mục không tồn tại: " + code));
            if (!available(category)) throw new IllegalArgumentException("Danh mục đang ẩn: " + code);
            if (!result.add(code)) throw new IllegalArgumentException("Danh mục bị trùng: " + code);
        }
        return List.copyOf(result);
    }

    public List<String> profilePreferences(List<String> values) {
        return values.stream().distinct().filter(CODES::contains)
                .filter(code -> categories.findByCode(code).filter(CatalogPolicy::available).isPresent()).toList();
    }
}
