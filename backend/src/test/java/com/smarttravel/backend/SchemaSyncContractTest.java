package com.smarttravel.backend;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarttravel.backend.features.destination.dto.DestinationDto;
import com.smarttravel.backend.features.itinerary.dto.UpdateActivitiesRequest;
import jakarta.validation.Validation;
import org.junit.jupiter.api.Test;
import java.nio.file.*;
import static org.junit.jupiter.api.Assertions.*;

class SchemaSyncContractTest {
    @Test void sharedFixtureDeserializesAndCanonicalNullWinsOverLegacyAlias() throws Exception {
        ObjectMapper json = new ObjectMapper();
        var fixture = json.readTree(Files.readString(Path.of("../contracts/schema-sync.json")));
        DestinationDto destination = json.treeToValue(fixture.path("destination"), DestinationDto.class);
        assertNull(destination.getRating()); assertNull(destination.getReviewCount());
        assertTrue(destination.hasField("rating")); assertTrue(destination.hasField("priceMinVnd"));
        assertEquals(0, destination.getLatitude().intValue());
        assertEquals(fixture.path("destination").path("openingSchedule"), destination.getOpeningSchedule());
        var serialized = json.valueToTree(destination);
        assertTrue(serialized.path("googleRating").isNull());
        assertEquals(3, serialized.path("appRating").asInt());
        assertFalse(serialized.has("suppliedFields"));
        DestinationDto reversed = json.readValue("{\"rating\":4.8,\"googleRating\":null}", DestinationDto.class);
        assertNull(reversed.getRating());
        UpdateActivitiesRequest update = json.treeToValue(fixture.path("update"), UpdateActivitiesRequest.class);
        assertEquals(3, update.getVersion());
        assertNull(update.getDays().getFirst().getItems().getFirst().getDestinationId());
        try (var factory = Validation.buildDefaultValidatorFactory()) {
            assertTrue(factory.getValidator().validate(update).isEmpty());
        }
    }
}
