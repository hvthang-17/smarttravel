package com.smarttravel.backend.features.destination.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.features.category.domain.Category;
import com.smarttravel.backend.features.category.repository.CategoryRepository;
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

    private final DestinationRepository destinationRepository;
    private final CategoryRepository categoryRepository;
    private final ObjectMapper objectMapper;

    public DestinationService(
            DestinationRepository destinationRepository,
            CategoryRepository categoryRepository,
            ObjectMapper objectMapper) {
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

        return destinations.stream().map(this::toDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public DestinationDto getDestinationById(Long id) {
        Destination destination = destinationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Destination", "id", id));
        return toDto(destination);
    }

    @Transactional
    public DestinationDto createDestination(DestinationDto dto) {
        Destination destination = toEntity(dto);
        destination.setCreatedAt(Instant.now());
        destination.setUpdatedAt(Instant.now());
        Destination saved = destinationRepository.save(destination);
        return toDto(saved);
    }

    @Transactional
    public DestinationDto updateDestination(Long id, DestinationDto dto) {
        Destination existing = destinationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Destination", "id", id));

        Category category = resolveCategory(dto);
        if (category != null) {
            existing.setCategory(category);
        }

        existing.setName(dto.getName());
        existing.setDescription(dto.getDescription());
        existing.setAddress(dto.getAddress());
        existing.setOpeningHours(dto.getOpeningHours());
        existing.setPhone(dto.getPhone());
        existing.setWebsite(dto.getWebsite());
        existing.setImageUrl(dto.getImageUrl());
        if (dto.getSubImages() != null) {
            existing.setSubImages(serializeSubImages(dto.getSubImages()));
        }
        if (dto.getRating() != null) {
            existing.setRating(dto.getRating());
        }
        if (dto.getReviewCount() != null) {
            existing.setReviewCount(dto.getReviewCount());
        }
        existing.setOsmId(dto.getOsmId());
        existing.setLatitude(dto.getLatitude());
        existing.setLongitude(dto.getLongitude());
        existing.setPriceMinVnd(dto.getPriceMinVnd());
        existing.setPriceMaxVnd(dto.getPriceMaxVnd());
        if (dto.getStatus() != null && !dto.getStatus().trim().isEmpty()) {
            existing.setStatus(dto.getStatus());
        }
        existing.setUpdatedAt(Instant.now());

        Destination saved = destinationRepository.save(existing);
        return toDto(saved);
    }

    @Transactional
    public void deleteDestination(Long id) {
        Destination existing = destinationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Destination", "id", id));
        destinationRepository.delete(existing);
    }

    public DestinationDto toDto(Destination entity) {
        DestinationDto dto = new DestinationDto();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        if (entity.getCategory() != null) {
            dto.setCategoryId(entity.getCategory().getId());
            dto.setCategory(entity.getCategory().getName());
            dto.setCategoryCode(entity.getCategory().getCode());
            dto.setCategoryIcon(entity.getCategory().getIcon());
            dto.setCategoryColor(entity.getCategory().getColorHex());
        }
        dto.setDescription(entity.getDescription());
        dto.setAddress(entity.getAddress());
        dto.setOpeningHours(entity.getOpeningHours());
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

        Category category = resolveCategory(dto);
        if (category == null) {
            throw new IllegalArgumentException("Valid categoryId or category is required");
        }
        entity.setCategory(category);

        entity.setDescription(dto.getDescription());
        entity.setAddress(dto.getAddress());
        entity.setOpeningHours(dto.getOpeningHours());
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

    private Category resolveCategory(DestinationDto dto) {
        if (dto.getCategoryId() != null) {
            return categoryRepository.findById(dto.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category", "id", dto.getCategoryId()));
        }
        if (dto.getCategory() != null && !dto.getCategory().trim().isEmpty()) {
            String catStr = dto.getCategory().trim();
            return categoryRepository.findByCodeIgnoreCase(catStr)
                    .or(() -> categoryRepository.findByNameIgnoreCase(catStr))
                    .or(() -> categoryRepository.findBySlug(catStr))
                    .or(() -> categoryRepository.findAll().stream()
                            .filter(c -> c.getName().equalsIgnoreCase(catStr)
                                    || c.getCode().equalsIgnoreCase(catStr)
                                    || (c.getNameEn() != null && c.getNameEn().equalsIgnoreCase(catStr)))
                            .findFirst())
                    .orElseThrow(() -> new ResourceNotFoundException("Category", "name/code", catStr));
        }
        return null;
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
