package com.smarttravel.backend.features.destination.service;

import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.features.category.service.CatalogPolicy;
import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service
@Transactional(readOnly = true)
public class DiscoveryService {
    public record Result(List<DestinationDto> items, int page, boolean hasNext) {}
    private final DestinationRepository destinations;
    private final DestinationService mapper;
    private final DestinationRatings ratings;

    public DiscoveryService(DestinationRepository destinations, DestinationService mapper, DestinationRatings ratings) {
        this.destinations = destinations;
        this.mapper = mapper;
        this.ratings = ratings;
    }

    public Result find(String search, List<String> categories, Long min, Long max, int page, int size) {
        if (page < 0 || size < 1 || size > 100 || (long) page * size > Integer.MAX_VALUE) throw new IllegalArgumentException("Trang hoặc kích thước trang không hợp lệ");
        if (min != null && min < 0 || max != null && max < 0 || min != null && max != null && min > max) {
            throw new IllegalArgumentException("Khoảng giá không hợp lệ");
        }
        String query = search == null ? "" : search.trim().toLowerCase(Locale.ROOT);
        if (query.length() > 180) throw new IllegalArgumentException("Từ khóa không được quá 180 ký tự");
        Set<String> codes = categories == null || categories.isEmpty() ? CatalogPolicy.CODES : new LinkedHashSet<>(categories);
        codes.forEach(CatalogPolicy::requireCode);
        var slice = destinations.discover(query, codes, min, max, PageRequest.of(page, size));
        return new Result(ratings.enrich(slice.getContent().stream().map(mapper::toDto).toList()), page, slice.hasNext());
    }

    public DestinationDto detail(Long id) {
        var destination = destinations.findById(id).filter(d -> "ACTIVE".equals(d.getStatus()) && CatalogPolicy.available(d.getCategory()))
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy địa điểm đang hiển thị"));
        return ratings.enrich(List.of(mapper.toDto(destination))).getFirst();
    }
}
