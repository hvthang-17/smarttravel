package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.common.ResourceConflictException;
import com.smarttravel.backend.common.CurrentUser;
import org.springframework.security.access.AccessDeniedException;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.dto.GenerateItineraryRequest;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;
import com.smarttravel.backend.features.itinerary.dto.UpdateActivitiesRequest;
import com.smarttravel.backend.features.itinerary.repository.ItineraryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import com.smarttravel.backend.features.profile.repository.TravelerProfileRepository;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
public class ItineraryService {

    private final ItineraryRepository itineraryRepository;
    private final DestinationRepository destinationRepository;
    private final UserRepository userRepository;
    private final com.smarttravel.backend.features.category.service.CatalogPolicy catalog;
    private final SavedDestinationSelection savedDestinations;
    private final TripConstraints constraints;
    private final TripGenerationInput generationInput;
    private final ItineraryCalculation calculation;
    private final RecommendationPlanner planner;
    private final TravelerProfileRepository profiles;

    public ItineraryService(ItineraryRepository itineraryRepository,
                            DestinationRepository destinationRepository,
                            UserRepository userRepository, com.smarttravel.backend.features.category.service.CatalogPolicy catalog,
                            SavedDestinationSelection savedDestinations, TripConstraints constraints, TripGenerationInput generationInput,
                            ItineraryCalculation calculation, RecommendationPlanner planner, TravelerProfileRepository profiles) {
        this.itineraryRepository = itineraryRepository;
        this.destinationRepository = destinationRepository;
        this.userRepository = userRepository;
        this.catalog = catalog;
        this.savedDestinations = savedDestinations;
        this.constraints = constraints;
        this.generationInput = generationInput;
        this.calculation = calculation;
        this.planner = planner;
        this.profiles = profiles;
    }

    @Transactional
    public Itinerary generateItinerary(String userEmail, GenerateItineraryRequest request) {
        User user = userRepository.lockByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng: " + userEmail));

        CurrentUser.requireCurrentAccount(user);
        if (request.getStartDate() == null || request.getEndDate() == null) throw new IllegalArgumentException("Thiếu ngày chuyến đi");
        long daysBetween = ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate()) + 1;
        if (daysBetween < 1 || daysBetween > 7 || request.getTravelersCount() == null
                || request.getTravelersCount() < 1 || request.getTravelersCount() > 10
                || request.getMaxBudgetVnd() == null || request.getMaxBudgetVnd() <= 0
                || !List.of("relaxed", "balanced", "packed").contains(request.getPace())) {
            throw new IllegalArgumentException("Thông tin chuyến đi không hợp lệ");
        }
        int totalDays = (int) daysBetween;
        String input = generationInput.snapshot(request);
        if (request.getGenerationKey() != null) {
            var existing = itineraryRepository.findByUserIdAndGenerationKey(user.getId(), request.getGenerationKey());
            if (existing.isPresent()) {
                generationInput.verifyReplay(existing.get(), input);
                return existing.get();
            }
        }
        generationInput.validatePlanningWindow(request);
        List<String> preferred = request.getPreferredCategories() == null
                ? catalog.profilePreferences(profiles.findById(user.getId())
                        .map(com.smarttravel.backend.features.profile.domain.TravelerProfile::getPreferredCategories).orElse(List.of()))
                : catalog.preferences(request.getPreferredCategories());
        var selection = constraints.resolve(request);
        var favorites = savedDestinations.load(user.getId(), request.getFavoriteDestinationIds(), totalDays * 7);
        Itinerary itinerary = new Itinerary();
        itinerary.setUser(user);
        itinerary.setTitle(request.getTitle().trim());
        itinerary.setStartDate(request.getStartDate());
        itinerary.setEndDate(request.getEndDate());
        itinerary.setTotalDays(totalDays);
        itinerary.setTravelersCount(request.getTravelersCount());
        itinerary.setMaxBudgetVnd(request.getMaxBudgetVnd());
        itinerary.setPace(request.getPace());
        itinerary.setTransport(TripGenerationInput.transport(request));
        itinerary.setOriginName(TripGenerationInput.origin(request));
        itinerary.setOriginLatitude(request.getOriginLatitude());
        itinerary.setOriginLongitude(request.getOriginLongitude());
        itinerary.setPreferredCategoriesSnapshot(preferred);
        itinerary.setGenerationKey(request.getGenerationKey());
        itinerary.setGenerationInput(input);
        planner.plan(itinerary, destinationRepository.findByStatus("ACTIVE"), selection.required(), favorites,
                selection.excludedIds(), preferred);
        var created = itineraryRepository.saveAndFlush(itinerary);
        constraints.persist(created.getId(), selection);
        return created;
    }

    @Transactional
    public ItineraryResponseDto generateItineraryDto(String userEmail, GenerateItineraryRequest request) {
        Itinerary itinerary = generateItinerary(userEmail, request);
        return toPrivateDto(itinerary);
    }

    @Transactional(readOnly = true)
    public List<ItineraryResponseDto> getUserItineraryDtos(String userEmail, String status) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng: " + userEmail));
        CurrentUser.requireCurrentAccount(user);
        return itineraryRepository.findByUserIdAndStatusOrderByUpdatedAtDescIdDesc(user.getId(), status)
                .stream().map(this::toPrivateDto).toList();
    }

    @Transactional(readOnly = true)
    public Itinerary getItineraryById(Long id) {
        Itinerary itinerary = itineraryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lịch trình ID: " + id));
        requireAccess(itinerary, CurrentUser.email());
        return itinerary;
    }

    @Transactional(readOnly = true)
    public ItineraryResponseDto getItineraryDtoById(Long id) {
        Itinerary itinerary = getItineraryById(id);
        return toPrivateDto(itinerary);
    }

    @Transactional
    public Itinerary updateActivities(String userEmail, Long itineraryId, UpdateActivitiesRequest request) {
        Itinerary itinerary = itineraryRepository.lockById(itineraryId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lịch trình ID: " + itineraryId));

        requireOwner(itinerary, userEmail);

        var previousActivities = TripConstraints.activityIds(itinerary);
        var routeDays = ItineraryEditor.apply(itinerary, request, destinationRepository, itineraryRepository::flush);
        constraints.verifyActivities(itinerary, previousActivities);
        calculation.recalculate(itinerary, request.isRecalculateAll() ? null : routeDays);
        ItineraryEditWarnings.refresh(itinerary, constraints.read(itinerary.getId()));
        itinerary.setUpdatedAt(Instant.now());
        return itineraryRepository.saveAndFlush(itinerary);
    }

    @Transactional
    public ItineraryResponseDto updateActivitiesDto(String userEmail, Long itineraryId, UpdateActivitiesRequest request) {
        Itinerary updated = updateActivities(userEmail, itineraryId, request);
        return toPrivateDto(updated);
    }

    @Transactional(readOnly = true)
    public List<ItineraryResponseDto> getAllItineraryDtos() {
        if (!CurrentUser.isAdmin()) throw new AccessDeniedException("Admin required");
        return itineraryRepository.findByStatusNot("DRAFT").stream().map(ItineraryMapper::toDto).toList();
    }

    @Transactional
    public ItineraryResponseDto saveDraft(Long id) {
        var trip = itineraryRepository.lockById(id).orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lịch trình"));
        requireOwner(trip, CurrentUser.email());
        if ("SAVED".equals(trip.getStatus())) return toPrivateDto(trip);
        if (!"DRAFT".equals(trip.getStatus())) throw new ResourceConflictException("Chỉ có thể lưu bản nháp");
        trip.setStatus("SAVED");
        trip.setUpdatedAt(Instant.now());
        return toPrivateDto(itineraryRepository.saveAndFlush(trip));
    }

    ItineraryResponseDto toPrivateDto(Itinerary itinerary) {
        var dto = ItineraryMapper.toDto(itinerary);
        dto.setConstraints(constraints.read(itinerary.getId()));
        dto.setOriginName(itinerary.getOriginName());
        dto.setOriginLatitude(itinerary.getOriginLatitude());
        dto.setOriginLongitude(itinerary.getOriginLongitude());
        dto.setPreferredCategories(itinerary.getPreferredCategoriesSnapshot());
        return dto;
    }

    private void requireAccess(Itinerary itinerary, String email) {
        if (CurrentUser.isAdmin() && !"DRAFT".equals(itinerary.getStatus())) return;
        requireOwner(itinerary, email);
    }

    static void requireOwner(Itinerary itinerary, String email) {
        if (!itinerary.getUser().getEmail().equals(email)) throw new AccessDeniedException("Bạn không có quyền truy cập lịch trình này");
        CurrentUser.requireCurrentAccount(itinerary.getUser());
    }
}
