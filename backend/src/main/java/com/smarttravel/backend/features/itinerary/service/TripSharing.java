package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.common.ResourceConflictException;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.dto.PublicItinerary;
import com.smarttravel.backend.features.itinerary.repository.ItineraryRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.net.URI;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Comparator;
import java.util.UUID;
import java.util.stream.IntStream;

@Service
public class TripSharing {
    public record Link(String state, String shareToken, String shareUrl, Instant expiresAt) {}

    private final ItineraryRepository trips;
    private final String base;

    public TripSharing(ItineraryRepository trips, @Value("${app.share.base-url:}") String base) {
        this.trips = trips;
        this.base = base.strip().replaceFirst("/+$", "");
        if (!this.base.isEmpty()) {
            var url = URI.create(this.base);
            if (url.getHost() == null || url.getUserInfo() != null || url.getQuery() != null
                    || url.getFragment() != null || !("https".equals(url.getScheme()) || "http".equals(url.getScheme()))) {
                throw new IllegalArgumentException("APP_SHARE_BASE_URL phải là URL HTTP(S) công khai");
            }
        }
    }

    @Transactional
    public Link status(long id) {
        return describe(TripManagement.lockOwned(trips, id), now());
    }

    @Transactional
    public Link create(long id, boolean rotate) {
        var trip = TripManagement.lockOwned(trips, id);
        if (!"SAVED".equals(trip.getStatus())) throw new ResourceConflictException("Hãy lưu lịch trình trước khi chia sẻ");
        var now = now();
        if (rotate || !active(trip, now)) {
            trip.setShareToken(UUID.randomUUID().toString().replace("-", ""));
            trip.setShareExpiresAt(now.plusDays(7));
            trips.saveAndFlush(trip);
        }
        return describe(trip, now);
    }

    @Transactional
    public Link revoke(long id) {
        var trip = TripManagement.lockOwned(trips, id);
        trip.setShareToken(null);
        trip.setShareExpiresAt(null);
        trips.saveAndFlush(trip);
        return describe(trip, now());
    }

    @Transactional(readOnly = true)
    public PublicItinerary read(String token) {
        if (!token.matches("(?:[0-9a-f]{16}|[0-9a-f]{32})")) throw missing();
        var trip = trips.findByShareToken(token)
                .filter(found -> "SAVED".equals(found.getStatus()) && "ACTIVE".equals(found.getUser().getStatus()))
                .orElseThrow(TripSharing::missing);
        if (!active(trip, now())) throw new ResponseStatusException(HttpStatus.GONE, "Liên kết chia sẻ đã hết hạn");
        var days = trip.getDays().stream().map(day -> {
            var items = day.getItems().stream().sorted(Comparator.comparing(item -> item.getSequenceOrder())).toList();
            var stops = IntStream.range(0, items.size()).mapToObj(index -> {
                var item = items.get(index);
                boolean hiddenLeg = index == 0;
                var place = new PublicItinerary.Place(item.getDestinationName(), item.getCategoryCode(),
                        item.getLatitude() == null ? null : item.getLatitude().doubleValue(),
                        item.getLongitude() == null ? null : item.getLongitude().doubleValue());
                return new PublicItinerary.Stop(item.getSequenceOrder(),
                        item.getStartTime() == null ? null : item.getStartTime().toString(), item.getDurationMinutes(), place,
                        hiddenLeg ? "UNKNOWN" : item.getRouteSource(), hiddenLeg ? null : item.getRoutePolyline(),
                        hiddenLeg || item.getTravelDistanceM() == null ? null : item.getTravelDistanceM() / 1000.0,
                        hiddenLeg || item.getTravelDurationSeconds() == null ? null
                                : ItineraryCalculation.travelMinutes(item.getTravelDurationSeconds()));
            }).toList();
            return new PublicItinerary.Day(day.getDayNumber(), day.getDate(), stops);
        }).toList();
        return new PublicItinerary(trip.getTitle(), trip.getStartDate(), trip.getEndDate(), days);
    }

    private Link describe(Itinerary trip, LocalDateTime now) {
        if (trip.getShareToken() == null) return new Link("NONE", null, null, null);
        if (!active(trip, now)) return new Link("EXPIRED", null, null, null);
        return new Link("ACTIVE", trip.getShareToken(), base + "/itineraries/shared/" + trip.getShareToken(),
                trip.getShareExpiresAt().toInstant(ZoneOffset.UTC));
    }

    private static boolean active(Itinerary trip, LocalDateTime now) {
        return "SAVED".equals(trip.getStatus()) && trip.getShareToken() != null
                && trip.getShareExpiresAt() != null && trip.getShareExpiresAt().isAfter(now);
    }

    private static LocalDateTime now() { return LocalDateTime.now(ZoneOffset.UTC).withNano(0); }

    private static ResponseStatusException missing() {
        return new ResponseStatusException(HttpStatus.NOT_FOUND, "Liên kết không hợp lệ hoặc đã bị thu hồi");
    }
}
