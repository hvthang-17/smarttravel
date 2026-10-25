-- V4__enrich_destinations_schema.sql
-- Enrich destinations with address, opening hours, phone, website, image_url, rating, review_count, and osm_id

ALTER TABLE destinations
    ADD COLUMN address VARCHAR(255) NULL AFTER description,
    ADD COLUMN opening_hours VARCHAR(100) NULL AFTER address,
    ADD COLUMN phone VARCHAR(50) NULL AFTER opening_hours,
    ADD COLUMN website VARCHAR(255) NULL AFTER phone,
    ADD COLUMN image_url VARCHAR(500) NULL AFTER website,
    ADD COLUMN rating DECIMAL(2, 1) NOT NULL DEFAULT 4.5 AFTER image_url,
    ADD COLUMN review_count INT NOT NULL DEFAULT 0 AFTER rating,
    ADD COLUMN osm_id VARCHAR(50) NULL AFTER review_count;

CREATE INDEX idx_destinations_osm_id ON destinations (osm_id);
CREATE INDEX idx_destinations_category_rating ON destinations (category, rating);

-- Create table for user reviews and ratings
CREATE TABLE destination_reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    destination_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reviews_destination (destination_id),
    INDEX idx_reviews_user (user_id)
);
