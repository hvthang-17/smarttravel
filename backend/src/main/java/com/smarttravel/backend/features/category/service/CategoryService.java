package com.smarttravel.backend.features.category.service;

import com.smarttravel.backend.features.category.domain.Category;
import com.smarttravel.backend.features.category.dto.CategoryResponseDto;
import com.smarttravel.backend.features.category.dto.CreateCategoryRequest;
import com.smarttravel.backend.features.category.dto.UpdateCategoryRequest;
import com.smarttravel.backend.features.category.repository.CategoryRepository;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import org.springframework.stereotype.Service;
import com.smarttravel.backend.common.CurrentUser;
import com.smarttravel.backend.common.ResourceNotFoundException;
import org.springframework.security.access.AccessDeniedException;
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
    private final com.smarttravel.backend.features.audit.service.AuditService audit;

    public CategoryService(CategoryRepository categoryRepository, DestinationRepository destinationRepository,
                           com.smarttravel.backend.features.audit.service.AuditService audit) {
        this.categoryRepository = categoryRepository;
        this.destinationRepository = destinationRepository;
        this.audit = audit;
    }

    public List<CategoryResponseDto> getAllCategories(String search, String status) {
        if (!CurrentUser.isAdmin() && status != null && !status.isBlank() && !"ACTIVE".equalsIgnoreCase(status.trim())) {
            throw new AccessDeniedException("Chỉ quản trị viên được xem danh mục ẩn");
        }
        List<Category> all = categoryRepository.findAllByOrderByDisplayOrderAsc();

        return all.stream()
                .filter(c -> CurrentUser.isAdmin() || CatalogPolicy.inScope(c))
                .filter(c -> CurrentUser.isAdmin() || "ACTIVE".equals(c.getStatus()))
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
                .orElseThrow(() -> new ResourceNotFoundException("Category", "id", id));
        if (!CurrentUser.isAdmin() && !CatalogPolicy.available(c)) {
            throw new ResourceNotFoundException("Category", "id", id);
        }
        return toDto(c);
    }

    @Transactional
    public CategoryResponseDto createCategory(CreateCategoryRequest request) {
        CatalogPolicy.requireCode(request.getCode());
        String slug = (request.getSlug() != null && !request.getSlug().isBlank())
                ? toSlug(request.getSlug())
                : toSlug(request.getName());

        if (categoryRepository.existsBySlug(slug)) {
            throw new com.smarttravel.backend.common.ResourceConflictException("Slug danh mục đã tồn tại; hãy sửa danh mục hiện có hoặc chọn slug khác");
        }

        String code = request.getCode();

        if (categoryRepository.existsByCode(code)) {
            throw new com.smarttravel.backend.common.ResourceConflictException("Mã danh mục đã tồn tại và không được tự đổi. Hãy sửa hoặc khôi phục danh mục hiện có");
        }

        Category category = new Category(
                code,
                slug,
                request.getName().trim(),
                request.getNameEn() != null ? request.getNameEn().trim() : null,
                request.getDescription() != null ? request.getDescription().trim() : null,
                CatalogImages.image(request.getImageUrl(), "Ảnh danh mục"),
                request.getIcon() != null && !request.getIcon().isBlank() ? request.getIcon().trim() : "tag",
                request.getColorHex() != null && !request.getColorHex().isBlank() ? request.getColorHex().trim() : "#0077B6",
                request.getDisplayOrder() != null ? request.getDisplayOrder() : 0,
                request.getStatus() != null && !request.getStatus().isBlank() ? request.getStatus().trim().toUpperCase() : "ACTIVE"
        );

        Category saved = categoryRepository.save(category);
        audit.record("CATEGORY", saved.getId(), "CREATE", java.util.Map.of("status", saved.getStatus()));
        return toDto(saved);
    }

    @Transactional
    public CategoryResponseDto updateCategory(Long id, UpdateCategoryRequest request) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category", "id", id));

        CatalogPolicy.requireCode(c.getCode());
        if (request.hasField("code") && !java.util.Objects.equals(request.getCode(), c.getCode())) {
            throw new IllegalArgumentException("Mã danh mục đã được sử dụng trong hồ sơ và snapshot, không thể thay đổi");
        }
        c.setName(request.getName().trim());
        if (request.hasField("nameEn")) c.setNameEn(nullableText(request.getNameEn()));
        if (request.hasField("description")) c.setDescription(nullableText(request.getDescription()));
        if (request.hasField("imageUrl")) c.setImageUrl(CatalogImages.image(request.getImageUrl(), "Ảnh danh mục"));
        if (request.getIcon() != null && !request.getIcon().isBlank()) c.setIcon(request.getIcon().trim());
        if (request.getColorHex() != null && !request.getColorHex().isBlank()) c.setColorHex(request.getColorHex().trim());
        if (request.getDisplayOrder() != null) c.setDisplayOrder(request.getDisplayOrder());
        if (request.getStatus() != null && !request.getStatus().isBlank()) c.setStatus(request.getStatus().trim().toUpperCase());

        Category saved = categoryRepository.save(c);
        audit.record("CATEGORY", saved.getId(), "UPDATE", java.util.Map.of("status", saved.getStatus()));
        return toDto(saved);
    }

    @Transactional
    public CategoryResponseDto toggleStatus(Long id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category", "id", id));

        String nextStatus = "ACTIVE".equalsIgnoreCase(c.getStatus()) ? "INACTIVE" : "ACTIVE";
        if ("ACTIVE".equals(nextStatus)) CatalogPolicy.requireCode(c.getCode());
        c.setStatus(nextStatus);
        Category saved = categoryRepository.save(c);
        audit.record("CATEGORY", saved.getId(), "STATUS", java.util.Map.of("status", saved.getStatus()));
        return toDto(saved);
    }

    @Transactional
    public void deleteCategory(Long id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category", "id", id));

        c.setStatus("INACTIVE");
        categoryRepository.save(c);
        audit.record("CATEGORY", c.getId(), "ARCHIVE", java.util.Map.of("status", "INACTIVE"));
    }

    private static String nullableText(String value) { return value == null || value.isBlank() ? null : value.trim(); }

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
