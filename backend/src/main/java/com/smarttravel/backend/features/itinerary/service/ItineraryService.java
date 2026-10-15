package com.smarttravel.backend.features.itinerary.service;

import com.smarttravel.backend.common.ResourceNotFoundException;
import com.smarttravel.backend.features.auth.domain.User;
import com.smarttravel.backend.features.auth.repository.UserRepository;
import com.smarttravel.backend.features.destination.domain.Destination;
import com.smarttravel.backend.features.destination.repository.DestinationRepository;
import com.smarttravel.backend.features.itinerary.domain.Itinerary;
import com.smarttravel.backend.features.itinerary.domain.ItineraryDay;
import com.smarttravel.backend.features.itinerary.domain.ItineraryItem;
import com.smarttravel.backend.features.itinerary.dto.GenerateItineraryRequest;
import com.smarttravel.backend.features.itinerary.dto.ItineraryResponseDto;
import com.smarttravel.backend.features.itinerary.dto.UpdateActivitiesRequest;
import com.smarttravel.backend.features.itinerary.repository.ItineraryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ItineraryService {

    private final ItineraryRepository itineraryRepository;
    private final DestinationRepository destinationRepository;
    private final UserRepository userRepository;

    public ItineraryService(ItineraryRepository itineraryRepository,
                            DestinationRepository destinationRepository,
                            UserRepository userRepository) {
        this.itineraryRepository = itineraryRepository;
        this.destinationRepository = destinationRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Itinerary generateItinerary(String userEmail, GenerateItineraryRequest request) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng: " + userEmail));

        long daysBetween = ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate()) + 1;
        int totalDays = daysBetween > 0 ? (int) daysBetween : 1;

        List<Destination> allDestinations = destinationRepository.findByStatus("ACTIVE");
        if (allDestinations.isEmpty()) {
            throw new IllegalStateException("Không có địa điểm nào khả dụng trong hệ thống.");
        }

        List<Destination> candidateDestinations = allDestinations;
        if (request.getPreferredCategories() != null && !request.getPreferredCategories().isEmpty()) {
            candidateDestinations = allDestinations.stream()
                    .filter(d -> request.getPreferredCategories().contains(d.getCategory()))
                    .collect(Collectors.toList());
            if (candidateDestinations.isEmpty()) candidateDestinations = allDestinations;
        }

        int itemsPerDay = 3;
        String pace = request.getPace() != null ? request.getPace().toLowerCase() : "balanced";
        if (pace.equals("relaxed")) itemsPerDay = 2;
        else if (pace.equals("packed")) itemsPerDay = 4;

        Itinerary itinerary = new Itinerary();
        itinerary.setUser(user);
        itinerary.setTitle(request.getTitle());
        itinerary.setStartDate(request.getStartDate());
        itinerary.setEndDate(request.getEndDate());
        itinerary.setTotalDays(totalDays);
        itinerary.setTravelersCount(request.getTravelersCount());
        itinerary.setMaxBudgetVnd(request.getMaxBudgetVnd());
        itinerary.setPace(pace);

        List<ItineraryDay> itineraryDays = new ArrayList<>();
        long totalCost = 0L;
        LocalDate currentDate = request.getStartDate();
        List<Destination> pool = new ArrayList<>(candidateDestinations);
        Collections.shuffle(pool);
        int poolIndex = 0;

        for (int i = 1; i <= totalDays; i++) {
            ItineraryDay day = new ItineraryDay();
            day.setItinerary(itinerary);
            day.setDayNumber(i);
            day.setDate(currentDate);

            List<ItineraryItem> items = new ArrayList<>();
            LocalTime startTime = LocalTime.of(8, 30);

            for (int seq = 1; seq <= itemsPerDay; seq++) {
                if (pool.isEmpty()) break;
                Destination dest = pool.get(poolIndex % pool.size());
                poolIndex++;

                ItineraryItem item = new ItineraryItem();
                item.setDay(day);
                item.setDestination(dest);
                item.setSequenceOrder(seq);
                item.setStartTime(startTime);
                item.setDurationMinutes(120);

                long itemCost = (dest.getPriceMinVnd() != null ? dest.getPriceMinVnd() : 0L) * request.getTravelersCount();
                item.setEstimatedCostVnd(itemCost);
                item.setNotes("Khám phá " + dest.getName() + " (" + dest.getCategory() + ")");

                totalCost += itemCost;
                items.add(item);
                startTime = startTime.plusMinutes(150);
            }

            day.setItems(items);
            itineraryDays.add(day);
            currentDate = currentDate.plusDays(1);
        }

        itinerary.setDays(itineraryDays);
        itinerary.setTotalEstimatedCost(totalCost);
        return itineraryRepository.save(itinerary);
    }

    @Transactional
    public ItineraryResponseDto generateItineraryDto(String userEmail, GenerateItineraryRequest request) {
        Itinerary itinerary = generateItinerary(userEmail, request);
        return ItineraryMapper.toDto(itinerary);
    }

    @Transactional(readOnly = true)
    public List<Itinerary> getUserItineraries(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng: " + userEmail));
        return itineraryRepository.findByUserId(user.getId());
    }

    @Transactional(readOnly = true)
    public List<ItineraryResponseDto> getUserItineraryDtos(String userEmail) {
        List<Itinerary> list = getUserItineraries(userEmail);
        return list.stream().map(ItineraryMapper::toDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Itinerary getItineraryById(Long id) {
        return itineraryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lịch trình ID: " + id));
    }

    @Transactional(readOnly = true)
    public ItineraryResponseDto getItineraryDtoById(Long id) {
        Itinerary itinerary = getItineraryById(id);
        return ItineraryMapper.toDto(itinerary);
    }

    @Transactional
    public Itinerary updateActivities(String userEmail, Long itineraryId, UpdateActivitiesRequest request) {
        Itinerary itinerary = itineraryRepository.findById(itineraryId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lịch trình ID: " + itineraryId));

        if (!itinerary.getUser().getEmail().equals(userEmail)) {
            User currentUser = userRepository.findByEmail(userEmail)
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng: " + userEmail));
            if (!"ROLE_ADMIN".equals(currentUser.getRole())) {
                throw new IllegalStateException("Bạn không có quyền chỉnh sửa lịch trình này");
            }
        }

        Map<Long, ItineraryDay> existingDayMap = itinerary.getDays().stream()
                .collect(Collectors.toMap(ItineraryDay::getId, d -> d));

        long totalCost = 0L;

        if (request.getDays() != null) {
            for (UpdateActivitiesRequest.DayUpdateDto dayDto : request.getDays()) {
                ItineraryDay day = null;
                if (dayDto.getDayId() != null) {
                    day = existingDayMap.get(dayDto.getDayId());
                } else if (dayDto.getDayNumber() != null) {
                    day = itinerary.getDays().stream()
                            .filter(d -> d.getDayNumber().equals(dayDto.getDayNumber()))
                            .findFirst().orElse(null);
                }

                if (day == null) continue;

                List<ItineraryItem> updatedItems = new ArrayList<>();
                if (dayDto.getItems() != null) {
                    for (UpdateActivitiesRequest.ItemUpdateDto itemDto : dayDto.getItems()) {
                        ItineraryItem item = new ItineraryItem();
                        item.setDay(day);

                        if (itemDto.getDestinationId() != null) {
                            Destination dest = destinationRepository.findById(itemDto.getDestinationId())
                                    .orElse(null);
                            item.setDestination(dest);
                        }

                        item.setSequenceOrder(itemDto.getSequenceOrder());
                        if (itemDto.getStartTime() != null && !itemDto.getStartTime().isEmpty()) {
                            try {
                                item.setStartTime(LocalTime.parse(itemDto.getStartTime()));
                            } catch (Exception e) {
                                item.setStartTime(LocalTime.of(9, 0));
                            }
                        }
                        item.setDurationMinutes(itemDto.getDurationMinutes() != null ? itemDto.getDurationMinutes() : 90);

                        long cost = itemDto.getEstimatedCostVnd() != null
                                ? itemDto.getEstimatedCostVnd()
                                : (item.getDestination() != null && item.getDestination().getPriceMinVnd() != null
                                    ? item.getDestination().getPriceMinVnd() * itinerary.getTravelersCount()
                                    : 0L);
                        item.setEstimatedCostVnd(cost);
                        item.setNotes(itemDto.getNotes());

                        totalCost += cost;
                        updatedItems.add(item);
                    }
                }

                day.getItems().clear();
                day.getItems().addAll(updatedItems);
            }
        }

        itinerary.setTotalEstimatedCost(totalCost);
        itinerary.setVersion(itinerary.getVersion() + 1);
        itinerary.setUpdatedAt(Instant.now());
        return itineraryRepository.save(itinerary);
    }

    @Transactional
    public String createShareToken(String userEmail, Long itineraryId) {
        Itinerary itinerary = itineraryRepository.findById(itineraryId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lịch trình ID: " + itineraryId));

        if (!itinerary.getUser().getEmail().equals(userEmail)) {
            User currentUser = userRepository.findByEmail(userEmail)
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng: " + userEmail));
            if (!"ROLE_ADMIN".equals(currentUser.getRole())) {
                throw new IllegalStateException("Bạn không có quyền chia sẻ lịch trình này");
            }
        }

        if (itinerary.getShareToken() == null || itinerary.getShareToken().isEmpty()) {
            String token = UUID.randomUUID().toString().replace("-", "").substring(0, 16);
            itinerary.setShareToken(token);
            itineraryRepository.save(itinerary);
        }

        return itinerary.getShareToken();
    }

    @Transactional
    public ItineraryResponseDto updateActivitiesDto(String userEmail, Long itineraryId, UpdateActivitiesRequest request) {
        Itinerary updated = updateActivities(userEmail, itineraryId, request);
        return ItineraryMapper.toDto(updated);
    }

    @Transactional(readOnly = true)
    public Itinerary getSharedItinerary(String shareToken) {
        return itineraryRepository.findByShareToken(shareToken)
                .orElseThrow(() -> new ResourceNotFoundException("Liên kết chia sẻ không hợp lệ hoặc đã hết hạn"));
    }

    @Transactional(readOnly = true)
    public ItineraryResponseDto getSharedItineraryDto(String shareToken) {
        Itinerary itinerary = getSharedItinerary(shareToken);
        return ItineraryMapper.toDto(itinerary);
    }
}

