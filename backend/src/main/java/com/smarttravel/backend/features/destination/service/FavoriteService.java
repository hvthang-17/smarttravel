package com.smarttravel.backend.features.destination.service;

import com.smarttravel.backend.common.*;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.category.service.CatalogPolicy;
import com.smarttravel.backend.features.destination.domain.Favorite;
import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.destination.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class FavoriteService {
    private final UserRepository users;
    private final FavoriteRepository favorites;
    private final DestinationRepository destinations;
    private final DestinationService mapper;
    private final DestinationRatings ratings;

    public FavoriteService(UserRepository users, FavoriteRepository favorites, DestinationRepository destinations,
                           DestinationService mapper, DestinationRatings ratings) {
        this.users = users;
        this.favorites = favorites;
        this.destinations = destinations;
        this.mapper = mapper;
        this.ratings = ratings;
    }

    @Transactional(readOnly = true)
    public List<DestinationDto> list() {
        var user = users.findByEmail(CurrentUser.email()).orElseThrow(FavoriteService::unauthenticated);
        CurrentUser.requireCurrentAccount(user);
        return ratings.enrich(favorites.visible(user.getId(), CatalogPolicy.CODES).stream().map(mapper::toDto).toList());
    }

    @Transactional
    public DestinationDto add(Long destinationId) {
        User user = lockOwner();
        var destination = destinations.lockForPublicSelection(destinationId)
                .filter(d -> "ACTIVE".equals(d.getStatus()) && CatalogPolicy.available(d.getCategory()))
                .orElseThrow(() -> new ResourceNotFoundException("Địa điểm không còn khả dụng để lưu"));
        if (!favorites.existsByUserIdAndDestinationId(user.getId(), destinationId)) {
            var favorite = new Favorite();
            favorite.setUserId(user.getId());
            favorite.setDestinationId(destinationId);
            favorites.save(favorite);
        }
        return ratings.enrich(List.of(mapper.toDto(destination))).getFirst();
    }

    @Transactional
    public void remove(Long destinationId) {
        User user = lockOwner();
        favorites.deleteByUserIdAndDestinationId(user.getId(), destinationId);
    }

    private User lockOwner() {
        var user = users.lockByEmail(CurrentUser.email()).orElseThrow(FavoriteService::unauthenticated);
        CurrentUser.requireCurrentAccount(user);
        return user;
    }

    private static org.springframework.security.authentication.BadCredentialsException unauthenticated() {
        return new org.springframework.security.authentication.BadCredentialsException("Phiên đăng nhập đã hết hiệu lực");
    }
}
