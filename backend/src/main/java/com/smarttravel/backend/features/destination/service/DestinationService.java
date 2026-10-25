package com.smarttravel.backend.features.destination.service;

import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class DestinationService {

    private final DestinationRepository destinationRepository;

    public DestinationService(DestinationRepository destinationRepository) {
        this.destinationRepository = destinationRepository;
    }

    @Transactional(readOnly = true)
    public List<DestinationDto> getDestinations(String category) {
        return getDestinations(category, "ACTIVE", null);
    }

    @Transactional(readOnly = true)
    public List<DestinationDto> getDestinations(String category, String status, String search) {
        List<Destination> destinations;
        boolean hasCategory = category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("Tất cả");
        boolean isAllStatus = status != null && status.equalsIgnoreCase("ALL");
        String effectiveStatus = (status != null && !status.trim().isEmpty()) ? status.trim() : "ACTIVE";

        if (hasCategory) {
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

        existing.setName(dto.getName());
        existing.setCategory(dto.getCategory());
        existing.setDescription(dto.getDescription());
        existing.setAddress(dto.getAddress());
        existing.setOpeningHours(dto.getOpeningHours());
        existing.setPhone(dto.getPhone());
        existing.setWebsite(dto.getWebsite());
        existing.setImageUrl(dto.getImageUrl());
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
        dto.setCategory(entity.getCategory());
        dto.setDescription(entity.getDescription());
        dto.setAddress(entity.getAddress());
        dto.setOpeningHours(entity.getOpeningHours());
        dto.setPhone(entity.getPhone());
        dto.setWebsite(entity.getWebsite());
        dto.setImageUrl(entity.getImageUrl());
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
        entity.setCategory(dto.getCategory());
        entity.setDescription(dto.getDescription());
        entity.setAddress(dto.getAddress());
        entity.setOpeningHours(dto.getOpeningHours());
        entity.setPhone(dto.getPhone());
        entity.setWebsite(dto.getWebsite());
        entity.setImageUrl(dto.getImageUrl());
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
}
