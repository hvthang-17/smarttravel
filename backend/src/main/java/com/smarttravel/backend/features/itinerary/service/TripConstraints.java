package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.common.ResourceConflictException;
import com.smarttravel.backend.features.category.service.CatalogPolicy;
import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import com.smarttravel.backend.features.itinerary.domain.*;
import com.smarttravel.backend.features.itinerary.dto.*;
import com.smarttravel.backend.features.itinerary.repository.ItineraryConstraintRepository;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;

@Service
class TripConstraints {
    record Selection(List<Destination> required, List<Destination> excluded) {
        Set<Long> excludedIds() { return excluded.stream().map(Destination::getId).collect(Collectors.toSet()); }
    }
    private final DestinationRepository destinations;
    private final ItineraryConstraintRepository constraints;

    TripConstraints(DestinationRepository destinations, ItineraryConstraintRepository constraints) {
        this.destinations = destinations;
        this.constraints = constraints;
    }

    Selection resolve(GenerateItineraryRequest request) {
        var required = distinct(request.getRequiredDestinationIds());
        var excluded = distinct(request.getExcludedDestinationIds());
        if (!Collections.disjoint(required, excluded)
                || (request.getFavoriteDestinationIds() != null && !Collections.disjoint(request.getFavoriteDestinationIds(), excluded))) {
            throw new IllegalArgumentException("Một điểm không thể vừa được chọn vừa bị loại");
        }
        var all = new TreeSet<>(required);
        all.addAll(excluded);
        Map<Long, Destination> locked = new HashMap<>();
        for (Long id : all) {
            var destination = destinations.lockForPublicSelection(id)
                    .filter(d -> "ACTIVE".equals(d.getStatus()) && CatalogPolicy.available(d.getCategory()))
                    .orElseThrow(() -> new IllegalArgumentException("Điểm ràng buộc không còn khả dụng: " + id));
            locked.put(id, destination);
        }
        return new Selection(required.stream().map(locked::get).toList(), excluded.stream().map(locked::get).toList());
    }

    void persist(Long itineraryId, Selection selection) {
        var rows = new ArrayList<ItineraryConstraint>();
        selection.required().forEach(destination -> rows.add(row(itineraryId, destination, "REQUIRED")));
        selection.excluded().forEach(destination -> rows.add(row(itineraryId, destination, "EXCLUDED")));
        constraints.saveAll(rows);
    }

    List<ItineraryResponseDto.ConstraintDto> read(Long itineraryId) {
        return constraints.findByItineraryIdOrderByConstraintTypeAscDestinationIdAsc(itineraryId).stream()
                .map(row -> new ItineraryResponseDto.ConstraintDto(row.getDestinationId(), row.getConstraintType(), row.getDestinationSnapshot()))
                .toList();
    }

    void verifyActivities(Itinerary trip, Set<Long> previousActivities) {
        var rules = read(trip.getId());
        if (rules.isEmpty()) return;
        Set<Long> activityIds = activityIds(trip);
        for (var rule : rules) {
            boolean present = activityIds.contains(rule.destinationId());
            boolean required = "REQUIRED".equals(rule.type());
            if ((!required && present) || (required && previousActivities.contains(rule.destinationId()) && !present)) {
                throw new ResourceConflictException("Lịch trình phải giữ điểm bắt buộc và bỏ điểm đã loại",
                        "ITINERARY_CONSTRAINT_CONFLICT");
            }
        }
    }

    static Set<Long> activityIds(Itinerary trip) {
        return trip.getDays().stream().flatMap(day -> day.getItems().stream())
                .map(ItineraryItem::getDestination).filter(Objects::nonNull)
                .map(Destination::getId).collect(Collectors.toSet());
    }

    private static Set<Long> distinct(List<Long> ids) {
        if (ids == null) return Set.of();
        var set = new TreeSet<>(ids);
        if (set.size() != ids.size() || set.size() > 5) throw new IllegalArgumentException("Mỗi loại ràng buộc có tối đa 5 điểm khác nhau");
        return set;
    }

    private static ItineraryConstraint row(Long itineraryId, Destination d, String type) {
        var row = new ItineraryConstraint();
        row.setItineraryId(itineraryId);
        row.setDestinationId(d.getId());
        row.setConstraintType(type);
        Long price = d.getPriceMaxVnd() == null ? d.getPriceMinVnd() : d.getPriceMaxVnd();
        row.setDestinationSnapshot(new ItineraryConstraint.Snapshot(d.getName(), d.getCategory().getCode(), d.getLatitude(), d.getLongitude(), price));
        return row;
    }
}
