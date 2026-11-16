package com.smarttravel.backend.features.profile.repository;

import com.smarttravel.backend.features.profile.domain.TravelerProfile;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TravelerProfileRepository extends JpaRepository<TravelerProfile, Long> {}
