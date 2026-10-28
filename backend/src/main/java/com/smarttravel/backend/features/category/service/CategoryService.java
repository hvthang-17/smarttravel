package com.smarttravel.backend.features.category.service;

import com.smarttravel.backend.features.category.domain.Category;
import com.smarttravel.backend.features.category.dto.CategoryResponseDto;
import com.smarttravel.backend.features.category.dto.CreateCategoryRequest;
import com.smarttravel.backend.features.category.dto.UpdateCategoryRequest;
import com.smarttravel.backend.features.category.repository.CategoryRepository;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final DestinationRepository destinationRepository;

    public CategoryService(CategoryRepository categoryRepository, DestinationRepository destinationRepository) {
        this.categoryRepository = categoryRepository;
        this.destinationRepository = destinationRepository;
    }

    public List<CategoryResponseDto> getAllCategories(String search, String status) {
        List<Category> all = categoryRepository.findAllByOrderByDisplayOrderAsc();

        return all.stream()
                .filter(c -> {
                    if (status != null && !status.isBlank() && !status.equalsIgnoreCase("ALL") && !status.equalsIgnoreCase("Tất cả")) {
                        if (!c.getStatus().equalsIgnoreCase(status)) return false;
                    }
                    if (search != null && !search.isBlank()) {
                        String q = search.trim().toLowerCase();
                        boolean matchName = c.getName() != null && c.getName().toLowerCase().contains(q);
                        boolean matchEn = c.getNameEn() != null && c.getNameEn().toLowerCase().contains(q);
                        boolean matchCode = c.getCode() != null && c.getCode().toLowerCase().contains(q);
                        return matchName || matchEn || matchCode;
                    }
                    return true;
                })
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public CategoryResponseDto getCategoryById(Long id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục với ID: " + id));
        return toDto(c);
    }

    @Transactional
    public CategoryResponseDto createCategory(CreateCategoryRequest request) {
        String slug = (request.getSlug() != null && !request.getSlug().isBlank())
                ? toSlug(request.getSlug())
                : toSlug(request.getName());

        if (categoryRepository.existsBySlug(slug)) {
            slug = slug + "-" + System.currentTimeMillis() % 10000;
        }

        String code = (request.getCode() != null && !request.getCode().isBlank())
                ? request.getCode().trim().toUpperCase().replaceAll("[^A-Z0-9_]", "_")
                : slug.toUpperCase().replace("-", "_");

        if (categoryRepository.existsByCode(code)) {
            code = code + "_" + System.currentTimeMillis() % 10000;
        }

        Category category = new Category(
                code,
                slug,
                request.getName().trim(),
                request.getNameEn() != null ? request.getNameEn().trim() : null,
                request.getDescription() != null ? request.getDescription().trim() : null,
                request.getImageUrl() != null && !request.getImageUrl().isBlank() ? request.getImageUrl().trim() : null,
                request.getIcon() != null && !request.getIcon().isBlank() ? request.getIcon().trim() : "tag",
                request.getColorHex() != null && !request.getColorHex().isBlank() ? request.getColorHex().trim() : "#0077B6",
                request.getDisplayOrder() != null ? request.getDisplayOrder() : 0,
                request.getStatus() != null && !request.getStatus().isBlank() ? request.getStatus().trim().toUpperCase() : "ACTIVE"
        );

        Category saved = categoryRepository.save(category);
        return toDto(saved);
    }

    @Transactional
    public CategoryResponseDto updateCategory(Long id, UpdateCategoryRequest request) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục với ID: " + id));

        c.setName(request.getName().trim());
        if (request.getNameEn() != null) c.setNameEn(request.getNameEn().trim());
        if (request.getDescription() != null) c.setDescription(request.getDescription().trim());
        if (request.getImageUrl() != null) c.setImageUrl(request.getImageUrl().trim());
        if (request.getIcon() != null && !request.getIcon().isBlank()) c.setIcon(request.getIcon().trim());
        if (request.getColorHex() != null && !request.getColorHex().isBlank()) c.setColorHex(request.getColorHex().trim());
        if (request.getDisplayOrder() != null) c.setDisplayOrder(request.getDisplayOrder());
        if (request.getStatus() != null && !request.getStatus().isBlank()) c.setStatus(request.getStatus().trim().toUpperCase());

        Category saved = categoryRepository.save(c);
        return toDto(saved);
    }

    @Transactional
    public CategoryResponseDto toggleStatus(Long id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục với ID: " + id));

        String nextStatus = "ACTIVE".equalsIgnoreCase(c.getStatus()) ? "INACTIVE" : "ACTIVE";
        c.setStatus(nextStatus);
        Category saved = categoryRepository.save(c);
        return toDto(saved);
    }

    @Transactional
    public void deleteCategory(Long id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục với ID: " + id));

        categoryRepository.delete(c);
    }

    private CategoryResponseDto toDto(Category c) {
        int count = 0;
        try {
            count = (int) destinationRepository.countByCategoryId(c.getId());
        } catch (Exception ignored) {
            count = 0;
        }

        return new CategoryResponseDto(
                c.getId(),
                c.getCode(),
                c.getSlug(),
                c.getName(),
                c.getNameEn(),
                c.getDescription(),
                c.getImageUrl(),
                c.getIcon(),
                c.getColorHex(),
                c.getDisplayOrder(),
                c.getStatus(),
                count,
                c.getCreatedAt(),
                c.getUpdatedAt()
        );
    }

    private static final Pattern NONLATIN = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE = Pattern.compile("[\\s]");

    public static String toSlug(String input) {
        if (input == null) return "";
        String nowhitespace = WHITESPACE.matcher(input.trim()).replaceAll("-");
        String normalized = Normalizer.normalize(nowhitespace, Normalizer.Form.NFD);
        String slug = Pattern.compile("\\p{InCombiningDiacriticalMarks}+").matcher(normalized).replaceAll("");
        slug = slug.replace("đ", "d").replace("Đ", "D");
        slug = NONLATIN.matcher(slug).replaceAll("");
        return slug.toLowerCase(Locale.ENGLISH).replaceAll("-+", "-").replaceAll("^-|-$", "");
    }
}
