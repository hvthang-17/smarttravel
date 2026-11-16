package com.smarttravel.backend.features.profile.service;

import com.smarttravel.backend.features.profile.domain.TravelerProfile;
import com.smarttravel.backend.features.profile.repository.TravelerProfileRepository;
import com.smarttravel.backend.features.auth.dto.UpdateProfileRequest;
import com.smarttravel.backend.features.category.repository.CategoryRepository;
import org.springframework.stereotype.Service;
import java.time.Instant;
import java.util.*;

@Service
public class TravelerProfileService {
    private final TravelerProfileRepository profiles;
    private final com.smarttravel.backend.features.category.service.CatalogPolicy catalog;

    public TravelerProfileService(TravelerProfileRepository profiles, com.smarttravel.backend.features.category.service.CatalogPolicy catalog) {
        this.profiles = profiles;
        this.catalog = catalog;
    }

    public TravelerProfile get(Long userId) {
        return profiles.findById(userId).orElseGet(() -> {
            TravelerProfile profile = new TravelerProfile();
            profile.setUserId(userId);
            return profile;
        });
    }

    public TravelerProfile update(Long userId, UpdateProfileRequest request) {
        TravelerProfile profile = get(userId);
        if (request.getLanguage() != null) profile.setLanguage(request.getLanguage());
        if (request.hasDefaultBudget()) profile.setDefaultBudgetVnd(request.getDefaultBudgetVnd());
        if (request.getDefaultPace() != null) profile.setDefaultPace(request.getDefaultPace());
        if (request.getDefaultTransport() != null) profile.setDefaultTransport(request.getDefaultTransport());
        if (request.getPreferredCategories() != null) profile.setPreferredCategories(validateCategories(request.getPreferredCategories()));
        profile.setUpdatedAt(Instant.now());
        return profiles.save(profile);
    }

    public List<String> validateCategories(List<String> values) {
        return catalog.preferences(values);
    }
}
