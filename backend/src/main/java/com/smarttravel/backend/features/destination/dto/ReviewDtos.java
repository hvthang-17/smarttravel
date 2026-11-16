package com.smarttravel.backend.features.destination.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;

public final class ReviewDtos {
    private ReviewDtos() {}

    public record Write(@NotNull @Min(1) @Max(5) @Digits(integer = 1, fraction = 0) BigDecimal rating,
                        @Size(max = 1000) String comment) {}
    public enum Reason { SPAM, ABUSE, IRRELEVANT, OTHER }
    public record Report(@NotNull Reason reason) {}
    public record PublicReview(Long id, int rating, String comment, Instant createdAt, Instant updatedAt) {}
    public record OwnedReview(Long id, int rating, String comment, String status, Instant createdAt, Instant updatedAt) {}
    public record ModerationReview(Long id, Long destinationId, String destinationName, int rating, String comment,
                                   String status, Instant createdAt, Map<String, Long> reports) {}
    public record Page<T>(List<T> items, boolean hasNext) {}
}
