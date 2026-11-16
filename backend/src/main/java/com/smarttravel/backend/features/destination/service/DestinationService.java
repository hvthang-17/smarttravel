package com.smarttravel.backend.features.destination.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.common.CurrentUser;
import org.springframework.security.access.AccessDeniedException;
import com.smarttravel.backend.features.category.domain.Category;
import com.smarttravel.backend.features.category.repository.CategoryRepository;
import com.smarttravel.backend.features.category.service.CatalogPolicy;
import com.smarttravel.backend.features.category.service.CatalogImages;
import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class DestinationService {

    private final DestinationRatings ratings;
    private final DestinationRepository destinationRepository;
    private final CategoryRepository categoryRepository;
    private final ObjectMapper objectMapper;
    private final com.smarttravel.backend.features.audit.service.AuditService audit;

    public DestinationService(
            DestinationRepository destinationRepository,
            CategoryRepository categoryRepository,
            ObjectMapper objectMapper, DestinationRatings ratings,
            com.smarttravel.backend.features.audit.service.AuditService audit) {
        this.audit = audit;
        this.ratings = ratings;
        this.destinationRepository = destinationRepository;
        this.categoryRepository = categoryRepository;
        this.objectMapper = objectMapper;
    }

    @Transactional(readOnly = true)
    public List<DestinationDto> getDestinations(String category) {
        return getDestinations(category, null, "ACTIVE", null);
    }

    @Transactional(readOnly = true)
    public List<DestinationDto> getDestinations(String category, String status, String search) {
        return getDestinations(category, null, status, search);
    }

    @Transactional(readOnly = true)
    public List<DestinationDto> getDestinations(String category, Long categoryId, String status, String search) {
        if (categoryId != null && categoryId <= 0) throw new IllegalArgumentException("categoryId phải dương");
        if (category != null && !category.isBlank() && !List.of("ALL", "Tất cả").contains(category)) CatalogPolicy.requireCode(category);
        if (!CurrentUser.isAdmin() && status != null && !status.isBlank() && !"ACTIVE".equalsIgnoreCase(status.trim())) {
            throw new AccessDeniedException("Chỉ quản trị viên được xem địa điểm ẩn");
        }
        List<Destination> destinations;
        boolean isAllStatus = status != null && status.equalsIgnoreCase("ALL");
        String effectiveStatus = (status != null && !status.trim().isEmpty()) ? status.trim() : "ACTIVE";

        if (categoryId != null && categoryId > 0) {
            if (isAllStatus) {
                destinations = destinationRepository.findByCategoryId(categoryId);
            } else {
                destinations = destinationRepository.findByCategoryIdAndStatus(categoryId, effectiveStatus);
            }
        } else if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("Tất cả")) {
            if (isAllStatus) {
                destinations = destinationRepository.findByCategory(category.trim());
            } else {
                destinations = destinationRepository.findByCategoryAndStatus(category.trim(), effectiveStatus);
            }
        } else {
            if (isAllStatus) {
                destinations = destinationRepository.findAll();
            } else {
                destinations = destinationRepository.findByStatus(effectiveStatus);
            }
        }

        if (search != null && !search.trim().isEmpty()) {
            String query = search.trim().toLowerCase();
            destinations = destinations.stream()
                    .filter(d -> (d.getName() != null && d.getName().toLowerCase().contains(query))
                            || (d.getAddress() != null && d.getAddress().toLowerCase().contains(query))
                            || (d.getDescription() != null && d.getDescription().toLowerCase().contains(query)))
                    .collect(Collectors.toList());
        }

        return ratings.enrich(destinations.stream()
                .filter(d -> CurrentUser.isAdmin() || ("ACTIVE".equals(d.getStatus())
                        && CatalogPolicy.available(d.getCategory())))
                .map(this::toDto).collect(Collectors.toList()));
    }

    @Transactional(readOnly = true)
    public DestinationDto getDestinationById(Long id) {
        Destination destination = destinationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Destination", "id", id));
        if (!CurrentUser.isAdmin() && (!"ACTIVE".equals(destination.getStatus())
                || !CatalogPolicy.available(destination.getCategory()))) {
            throw new ResourceNotFoundException("Destination", "id", id);
        }
        return ratings.enrich(List.of(toDto(destination))).getFirst();
    }

    @Transactional
    public DestinationDto createDestination(DestinationDto dto) {
        validatePrices(dto);
        Destination destination = toEntity(dto);
        destination.setCreatedAt(Instant.now());
        destination.setUpdatedAt(Instant.now());
        Destination saved = destinationRepository.save(destination);
        audit.record("DESTINATION", saved.getId(), "CREATE", java.util.Map.of("categoryId", saved.getCategory().getId(), "status", saved.getStatus()));
        return toDto(saved);
    }

    @Transactional
    public DestinationDto updateDestination(Long id, DestinationDto dto) {
        Destination existing = destinationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Destination", "id", id));

        validatePrices(dto);
        Category category = resolveCategory(dto, existing.getCategory());
        if (category != null) {
            existing.setCategory(category);
        }

        existing.setName(dto.getName());
        if (dto.hasField("nameEn")) existing.setNameEn(dto.getNameEn());
        if (dto.hasField("featuredReason")) existing.setFeaturedReason(featuredReason(dto));
        if (dto.hasField("descriptionEn")) existing.setDescriptionEn(dto.getDescriptionEn());
        if (dto.hasField("visitDurationMinutes")) existing.setVisitDurationMinutes(dto.getVisitDurationMinutes());
        if (dto.hasField("description")) existing.setDescription(dto.getDescription());
        if (dto.hasField("address")) existing.setAddress(dto.getAddress());
        if (dto.hasField("openingHours") || dto.hasField("openingSchedule")) existing.setOpeningHours(schedule(dto, existing.getOpeningHours()));
        if (dto.hasField("phone")) existing.setPhone(dto.getPhone());
        if (dto.hasField("website")) existing.setWebsite(dto.getWebsite());
        if (dto.hasField("imageUrl")) existing.setImageUrl(dto.getImageUrl());
        if (dto.hasField("subImages")) {
            existing.setSubImages(serializeSubImages(dto.getSubImages()));
        }
        if (dto.hasField("rating")) {
            existing.setRating(dto.getRating());
        }
        if (dto.hasField("reviewCount")) {
            existing.setReviewCount(dto.getReviewCount());
        }
        if (dto.hasField("osmId")) existing.setOsmId(dto.getOsmId());
        existing.setLatitude(dto.getLatitude());
        existing.setLongitude(dto.getLongitude());
        if (dto.hasField("priceMinVnd")) existing.setPriceMinVnd(dto.getPriceMinVnd());
        if (dto.hasField("priceMaxVnd")) existing.setPriceMaxVnd(dto.getPriceMaxVnd());
        if (dto.getStatus() != null && !dto.getStatus().trim().isEmpty()) {
            if ("ACTIVE".equals(dto.getStatus()) && !"ACTIVE".equals(existing.getStatus()) && !CatalogPolicy.available(existing.getCategory())) {
                throw new com.smarttravel.backend.common.ResourceConflictException("Cần khôi phục danh mục trước khi hiện địa điểm");
            }
            existing.setStatus(dto.getStatus());
        }
        if (existing.getPriceMinVnd() != null && existing.getPriceMaxVnd() != null && existing.getPriceMinVnd() > existing.getPriceMaxVnd()) {
            throw new IllegalArgumentException("Giá thấp nhất không được lớn hơn giá cao nhất");
        }
        existing.setUpdatedAt(Instant.now());

        Destination saved = destinationRepository.save(existing);
        audit.record("DESTINATION", saved.getId(), "UPDATE", java.util.Map.of("fields", dto.suppliedFields(), "status", saved.getStatus(), "categoryId", saved.getCategory().getId()));
        return ratings.enrich(List.of(toDto(saved))).getFirst();
    }

    @Transactional
    public void deleteDestination(Long id) {
        Destination existing = destinationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Destination", "id", id));
        existing.setStatus("INACTIVE");
        destinationRepository.save(existing);
        audit.record("DESTINATION", existing.getId(), "ARCHIVE", java.util.Map.of("status", "INACTIVE"));
    }

    public DestinationDto toDto(Destination entity) {
        DestinationDto dto = new DestinationDto();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setNameEn(entity.getNameEn());
        dto.setFeaturedReason(entity.getFeaturedReason());
        dto.setDescriptionEn(entity.getDescriptionEn());
        dto.setVisitDurationMinutes(entity.getVisitDurationMinutes());
        if (entity.getCategory() != null) {
            dto.setSuggestedVisitDurationMinutes(entity.suggestedVisitDurationMinutes());
        }
        if (entity.getCategory() != null) {
            dto.setCategoryId(entity.getCategory().getId());
            dto.setCategory(entity.getCategory().getName());
            dto.setCategoryCode(entity.getCategory().getCode());
            dto.setCategoryNameEn(entity.getCategory().getNameEn());
            dto.setCategoryIcon(entity.getCategory().getIcon());
            dto.setCategoryColor(entity.getCategory().getColorHex());
        }
        dto.setDescription(entity.getDescription());
        dto.setAddress(entity.getAddress());
        dto.setOpeningHours(OpeningHours.display(entity.getOpeningHours()));
        dto.setOpeningSchedule(OpeningHours.tree(entity.getOpeningHours()));
        dto.setPhone(entity.getPhone());
        dto.setWebsite(entity.getWebsite());
        dto.setImageUrl(entity.getImageUrl());
        dto.setSubImages(parseSubImages(entity.getSubImages()));
        dto.setRating(entity.getRating());
        dto.setReviewCount(entity.getReviewCount());
        dto.setOsmId(entity.getOsmId());
        dto.setLatitude(entity.getLatitude());
        dto.setLongitude(entity.getLongitude());
        dto.setPriceMinVnd(entity.getPriceMinVnd());
        dto.setPriceMaxVnd(entity.getPriceMaxVnd());
        dto.setStatus(entity.getStatus());
        return dto;
    }

    public Destination toEntity(DestinationDto dto) {
        Destination entity = new Destination();
        entity.setName(dto.getName());
        entity.setNameEn(dto.getNameEn());
        entity.setFeaturedReason(featuredReason(dto));
        entity.setDescriptionEn(dto.getDescriptionEn());
        entity.setVisitDurationMinutes(dto.getVisitDurationMinutes());

        Category category = resolveCategory(dto, null);
        if (category == null) {
            throw new IllegalArgumentException("Valid categoryId or category is required");
        }
        entity.setCategory(category);

        entity.setDescription(dto.getDescription());
        entity.setAddress(dto.getAddress());
        entity.setOpeningHours(schedule(dto, null));
        entity.setPhone(dto.getPhone());
        entity.setWebsite(dto.getWebsite());
        entity.setImageUrl(dto.getImageUrl());
        entity.setSubImages(serializeSubImages(dto.getSubImages()));
        if (dto.getRating() != null) {
            entity.setRating(dto.getRating());
        }
        if (dto.getReviewCount() != null) {
            entity.setReviewCount(dto.getReviewCount());
        }
        entity.setOsmId(dto.getOsmId());
        entity.setLatitude(dto.getLatitude());
        entity.setLongitude(dto.getLongitude());
        entity.setPriceMinVnd(dto.getPriceMinVnd());
        entity.setPriceMaxVnd(dto.getPriceMaxVnd());
        entity.setStatus(dto.getStatus() != null ? dto.getStatus() : "ACTIVE");
        return entity;
    }

    private static String featuredReason(DestinationDto dto) {
        var value = dto.getFeaturedReason();
        return value == null || value.isBlank() ? null : value.strip();
    }

    private Category resolveCategory(DestinationDto dto, Category current) {
        Category selected = dto.getCategoryId() == null ? current : categoryRepository.findById(dto.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category", "id", dto.getCategoryId()));
        String code = dto.getCategoryCode() != null ? dto.getCategoryCode() : dto.getCategory();
        if (code != null) {
            CatalogPolicy.requireCode(code);
            if (dto.getCategory() != null && !dto.getCategory().equals(code)) throw new IllegalArgumentException("Mã danh mục gửi không khớp");
            if (dto.getCategoryId() != null && !selected.getCode().equals(code)) throw new IllegalArgumentException("ID và mã danh mục không khớp");
            selected = categoryRepository.findByCode(code).orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh mục: " + code));
        }
        if (selected == null) throw new IllegalArgumentException("Cần categoryId hoặc mã danh mục hợp lệ");
        CatalogPolicy.requireCode(selected.getCode());
        if ((current == null || !current.getId().equals(selected.getId())) && !CatalogPolicy.available(selected)) {
            throw new IllegalArgumentException("Không thể chọn danh mục đang ẩn");
        }
        return selected;
    }

    private String schedule(DestinationDto dto, String current) {
        if (dto.hasField("openingSchedule")) {
            return dto.getOpeningSchedule() == null || dto.getOpeningSchedule().isNull() ? null : OpeningHours.normalize(dto.getOpeningSchedule().toString());
        }
        if (current != null && java.util.Objects.equals(dto.getOpeningHours(), OpeningHours.display(current))) return current;
        return OpeningHours.normalize(dto.getOpeningHours());
    }

    private void validatePrices(DestinationDto dto) {
        if (dto.hasField("categoryId") && dto.getCategoryId() == null || dto.hasField("category") && dto.getCategory() == null
                || dto.hasField("categoryCode") && dto.getCategoryCode() == null) throw new IllegalArgumentException("Không thể xóa danh mục của địa điểm");
        if (dto.hasField("imageUrl")) dto.setImageUrl(CatalogImages.image(dto.getImageUrl(), "Ảnh đại diện"));
        if (dto.hasField("subImages")) dto.setSubImages(CatalogImages.gallery(dto.getSubImages()));
        if (dto.getPriceMinVnd() != null && dto.getPriceMaxVnd() != null && dto.getPriceMinVnd() > dto.getPriceMaxVnd()) {
            throw new IllegalArgumentException("Giá thấp nhất không được lớn hơn giá cao nhất");
        }
        if (dto.getStatus() != null && !List.of("ACTIVE", "INACTIVE").contains(dto.getStatus())) {
            throw new IllegalArgumentException("Trạng thái địa điểm không hợp lệ");
        }
    }

    private List<String> parseSubImages(String json) {
        if (json == null || json.trim().isEmpty()) {
            return Collections.emptyList();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    private String serializeSubImages(List<String> list) {
        if (list == null || list.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(list);
        } catch (Exception e) {
            return null;
        }
    }
}
