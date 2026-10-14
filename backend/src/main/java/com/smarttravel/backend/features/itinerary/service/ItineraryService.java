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
import com.smarttravel.backend.features.itinerary.repository.ItineraryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
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

    public List<Itinerary> getUserItineraries(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng: " + userEmail));
        return itineraryRepository.findByUserId(user.getId());
    }

    public Itinerary getItineraryById(Long id) {
        return itineraryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lịch trình ID: " + id));
    }
}

