-- V8__add_destination_sub_images.sql
-- Add sub_images column to destinations table for image gallery (JSON array of URLs)

ALTER TABLE destinations
    ADD COLUMN sub_images TEXT NULL COMMENT 'JSON array of additional gallery image URLs' AFTER image_url;
