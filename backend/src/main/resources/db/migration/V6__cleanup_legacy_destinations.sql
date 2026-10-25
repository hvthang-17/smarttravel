-- V6__cleanup_legacy_destinations.sql
-- Delete all legacy destinations that have NULL images or NULL addresses to keep only the 200 curated destinations

DELETE FROM destinations WHERE image_url IS NULL OR address IS NULL;
