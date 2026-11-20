package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.common.ResourceConflictException;
import com.smarttravel.backend.features.category.service.CatalogPolicy;
import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.destination.domain.Favorite;
import com.smarttravel.backend.features.destination.repository.*;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
class SavedDestinationSelection {
    private final FavoriteRepository favorites;
    private final DestinationRepository destinations;

    SavedDestinationSelection(FavoriteRepository favorites, DestinationRepository destinations) {
        this.favorites = favorites;
        this.destinations = destinations;
    }

    List<Destination> load(Long userId, List<Long> ids, int capacity) {
        if (ids == null || ids.isEmpty()) return List.of();
        var ordered = new LinkedHashSet<>(ids);
        if (ordered.size() != ids.size() || ids.size() > capacity) {
            throw new IllegalArgumentException("Số điểm đã lưu phải vừa với lịch trình và không được trùng");
        }
        var owned = favorites.findByUserIdAndDestinationIdIn(userId, ids).stream()
                .map(Favorite::getDestinationId).collect(java.util.stream.Collectors.toSet());
        if (!owned.containsAll(ids)) throw unavailable();
        return ordered.stream().map(id -> destinations.lockForPublicSelection(id)
                .filter(d -> "ACTIVE".equals(d.getStatus()) && CatalogPolicy.available(d.getCategory()))
                .orElseThrow(SavedDestinationSelection::unavailable)).toList();
    }

    private static ResourceConflictException unavailable() {
        return new ResourceConflictException("Có điểm đã lưu không còn khả dụng. Hãy tải lại danh sách yêu thích và chọn lại.");
    }
}
