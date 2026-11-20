package com.smarttravel.backend.features.itinerary.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "itinerary_constraints")
@IdClass(ItineraryConstraint.Key.class)
public class ItineraryConstraint {
    public record Snapshot(String name, String categoryCode, java.math.BigDecimal latitude,
                           java.math.BigDecimal longitude, Long unitPriceVnd) {}
    @Id
    @Column(name = "itinerary_id", nullable = false)
    private Long itineraryId;

    @Id
    @Column(name = "destination_id", nullable = false)
    private Long destinationId;

    @Column(name = "constraint_type", length = 10, nullable = false)
    private String constraintType;

    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    @Column(name = "destination_snapshot", columnDefinition = "json")
    private Snapshot destinationSnapshot;

    public Snapshot getDestinationSnapshot() { return destinationSnapshot; }
    public void setDestinationSnapshot(Snapshot value) { destinationSnapshot = value; }

    public Long getItineraryId() { return itineraryId; }
    public void setItineraryId(Long value) { itineraryId = value; }
    public Long getDestinationId() { return destinationId; }
    public void setDestinationId(Long value) { destinationId = value; }
    public String getConstraintType() { return constraintType; }
    public void setConstraintType(String value) { constraintType = value; }
    public static class Key implements java.io.Serializable {
        private Long itineraryId;
        private Long destinationId;
        public Key() {}
        @Override public boolean equals(Object other) {
            if (!(other instanceof Key key)) return false;
            return java.util.Objects.equals(itineraryId, key.itineraryId) && java.util.Objects.equals(destinationId, key.destinationId);
        }
        @Override public int hashCode() { return java.util.Objects.hash(itineraryId, destinationId); }
    }

}
