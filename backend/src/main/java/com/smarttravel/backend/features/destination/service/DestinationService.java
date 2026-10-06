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
        List<Destination> destinations;
        if (category != null && !category.trim().isEmpty()) {
            destinations = destinationRepository.findByCategoryAndStatus(category.trim(), "ACTIVE");
        } else {
            destinations = destinationRepository.findByStatus("ACTIVE");
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

    private DestinationDto toDto(Destination entity) {
        DestinationDto dto = new DestinationDto();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setCategory(entity.getCategory());
        dto.setDescription(entity.getDescription());
        dto.setLatitude(entity.getLatitude());
        dto.setLongitude(entity.getLongitude());
        dto.setPriceMinVnd(entity.getPriceMinVnd());
        dto.setPriceMaxVnd(entity.getPriceMaxVnd());
        dto.setStatus(entity.getStatus());
        return dto;
    }

    private Destination toEntity(DestinationDto dto) {
        Destination entity = new Destination();
        entity.setName(dto.getName());
        entity.setCategory(dto.getCategory());
        entity.setDescription(dto.getDescription());
        entity.setLatitude(dto.getLatitude());
        entity.setLongitude(dto.getLongitude());
        entity.setPriceMinVnd(dto.getPriceMinVnd());
        entity.setPriceMaxVnd(dto.getPriceMaxVnd());
        entity.setStatus(dto.getStatus() != null ? dto.getStatus() : "ACTIVE");
        return entity;
    }
}

