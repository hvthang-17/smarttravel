-- =============================================================================
-- V1__init_schema.sql
-- SmartTravel Database Schema Initialization
-- Target schema: docs/erd/smarttravel-v2.mmd (12 tables).
-- Rewritten baseline for a fresh schema; not an upgrade for an existing database.
-- Existing V3-V9 seeds and V10 must be reconciled before running the full chain.
-- =============================================================================

-- 1. Categories Table (Tạo trước để destinations tham chiếu khóa ngoại)
CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE COMMENT 'Mã danh mục hệ thống (VD: BEACH, FOOD, CULTURE)',
    slug VARCHAR(100) NOT NULL UNIQUE COMMENT 'Đường dẫn URL thân thiện (VD: bien-thien-nhien)',
    name VARCHAR(100) NOT NULL COMMENT 'Tên tiếng Việt hiển thị',
    name_en VARCHAR(100) NULL COMMENT 'Tên tiếng Anh cho khách quốc tế',
    description TEXT NULL COMMENT 'Mô tả chi tiết về danh mục',
    image_url VARCHAR(500) NULL COMMENT 'Đường dẫn ảnh bìa',
    icon VARCHAR(50) NOT NULL DEFAULT 'tag' COMMENT 'Mã icon đại diện (palmtree, utensils, landmark...)',
    color_hex VARCHAR(10) DEFAULT '#0077B6' COMMENT 'Mã màu HEX đại diện cho badge',
    display_order INT NOT NULL DEFAULT 0 COMMENT 'Thứ tự ưu tiên sắp xếp (số nhỏ xếp trước)',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT 'Trạng thái: ACTIVE hoặc INACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_categories_status_order (status, display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Users Table
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(180) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'ROLE_USER',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    auth_version BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Destinations Table (Liên kết khóa ngoại chuẩn hóa với categories)
CREATE TABLE destinations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(180) NOT NULL,
    name_en VARCHAR(180) NULL,
    category_id BIGINT NOT NULL,
    description TEXT,
    description_en TEXT NULL,
    address VARCHAR(255) NULL,
    opening_hours JSON NULL,
    phone VARCHAR(50) NULL,
    website VARCHAR(255) NULL,
    image_url VARCHAR(500) NULL,
    sub_images TEXT NULL COMMENT 'JSON array of additional gallery image URLs',
    google_rating DECIMAL(2, 1) NULL,
    google_review_count INT NULL,
    featured_reason VARCHAR(240) NULL,
    visit_duration_minutes INT NULL,
    osm_id VARCHAR(50) NULL,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    price_min_vnd BIGINT,
    price_max_vnd BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_destinations_category FOREIGN KEY (category_id) REFERENCES categories(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_destinations_category_id_status (category_id, status),
    INDEX idx_destinations_osm_id (osm_id),
    CONSTRAINT chk_destination_coordinates CHECK (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_destination_prices CHECK ((price_min_vnd IS NULL OR price_min_vnd >= 0) AND (price_max_vnd IS NULL OR price_max_vnd >= 0) AND (price_min_vnd IS NULL OR price_max_vnd IS NULL OR price_max_vnd >= price_min_vnd)),
    CONSTRAINT chk_google_rating CHECK (google_rating IS NULL OR google_rating BETWEEN 1 AND 5),
    CONSTRAINT chk_google_count CHECK (google_review_count IS NULL OR google_review_count >= 0),
    CONSTRAINT chk_visit_duration CHECK (visit_duration_minutes IS NULL OR visit_duration_minutes > 0),
    CONSTRAINT chk_opening_hours_object CHECK (opening_hours IS NULL OR JSON_TYPE(opening_hours) = 'OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Destination Reviews Table
CREATE TABLE destination_reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    destination_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'PUBLISHED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reviews_destination (destination_id),
    INDEX idx_reviews_user (user_id),
    UNIQUE KEY uq_reviews_user_destination (user_id, destination_id),
    INDEX idx_reviews_destination_status (destination_id, status),
    CONSTRAINT chk_review_status CHECK (status IN ('PUBLISHED', 'HIDDEN'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Itineraries Table
CREATE TABLE itineraries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INT NOT NULL,
    travelers_count INT NOT NULL,
    max_budget_vnd BIGINT NOT NULL,
    pace VARCHAR(30) NOT NULL DEFAULT 'balanced',
    transport VARCHAR(20) NOT NULL DEFAULT 'unspecified',
    origin_name VARCHAR(255) NULL,
    origin_latitude DECIMAL(10, 7) NULL,
    origin_longitude DECIMAL(10, 7) NULL,
    preferred_categories_snapshot JSON NULL,
    generation_key VARCHAR(64) NULL,
    generation_input JSON NULL,
    generation_status VARCHAR(20) NOT NULL DEFAULT 'COMPLETE',
    warnings JSON NULL,
    cost_complete BOOLEAN NOT NULL DEFAULT FALSE,
    total_estimated_cost BIGINT DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    share_token VARCHAR(100) UNIQUE NULL,
    share_expires_at DATETIME NULL,
    version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itineraries_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_itineraries_user (user_id),
    INDEX idx_itineraries_share_token (share_token),
    INDEX idx_itineraries_draft_cleanup (status, updated_at),
    UNIQUE KEY uq_itineraries_generation (user_id, generation_key),
    CONSTRAINT chk_itinerary_dates CHECK (total_days BETWEEN 1 AND 7 AND DATEDIFF(end_date, start_date) + 1 = total_days),
    CONSTRAINT chk_travelers CHECK (travelers_count BETWEEN 1 AND 10),
    CONSTRAINT chk_trip_budget CHECK (max_budget_vnd > 0 AND (total_estimated_cost IS NULL OR total_estimated_cost >= 0)),
    CONSTRAINT chk_trip_pace CHECK (pace IN ('relaxed', 'balanced', 'packed')),
    CONSTRAINT chk_trip_transport CHECK (transport IN ('walking', 'motorbike', 'car', 'taxi', 'unspecified')),
    CONSTRAINT chk_trip_status CHECK (status IN ('DRAFT', 'SAVED', 'ARCHIVED')),
    CONSTRAINT chk_generation_status CHECK (generation_status IN ('COMPLETE', 'PARTIAL')),
    CONSTRAINT chk_trip_version CHECK (version >= 1),
    CONSTRAINT chk_trip_categories CHECK (preferred_categories_snapshot IS NULL OR JSON_TYPE(preferred_categories_snapshot) = 'ARRAY'),
    CONSTRAINT chk_trip_origin CHECK ((origin_latitude IS NULL AND origin_longitude IS NULL) OR (origin_latitude IS NOT NULL AND origin_longitude IS NOT NULL AND origin_latitude BETWEEN -90 AND 90 AND origin_longitude BETWEEN -180 AND 180))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Itinerary Days Table
CREATE TABLE itinerary_days (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id BIGINT NOT NULL,
    day_number INT NOT NULL,
    date DATE NOT NULL,
    origin_name VARCHAR(255) NULL,
    origin_latitude DECIMAL(10, 7) NULL,
    origin_longitude DECIMAL(10, 7) NULL,
    CONSTRAINT fk_itinerary_days_itinerary FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
    INDEX idx_itinerary_days_itinerary (itinerary_id),
    UNIQUE KEY uq_itinerary_day_number (itinerary_id, day_number),
    UNIQUE KEY uq_itinerary_day_date (itinerary_id, date),
    CONSTRAINT chk_day_number CHECK (day_number BETWEEN 1 AND 7),
    CONSTRAINT chk_day_origin CHECK ((origin_latitude IS NULL AND origin_longitude IS NULL) OR (origin_latitude IS NOT NULL AND origin_longitude IS NOT NULL AND origin_latitude BETWEEN -90 AND 90 AND origin_longitude BETWEEN -180 AND 180))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Itinerary Items Table
CREATE TABLE itinerary_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    day_id BIGINT NOT NULL,
    destination_id BIGINT,
    sequence_order INT NOT NULL,
    start_time TIME,
    duration_minutes INT DEFAULT 90,
    estimated_cost_vnd BIGINT NULL,
    notes TEXT,
    destination_name VARCHAR(180) NOT NULL,
    latitude DECIMAL(10, 7) NULL,
    longitude DECIMAL(10, 7) NULL,
    category_code VARCHAR(50) NOT NULL,
    unit_price_vnd BIGINT NULL,
    recommendation_reason VARCHAR(500) NULL,
    featured_recommendation BOOLEAN NOT NULL DEFAULT FALSE,
    upper_price_known BOOLEAN NOT NULL DEFAULT TRUE,
    travel_distance_m INT NULL,
    travel_duration_seconds INT NULL,
    route_source VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN',
    route_polyline MEDIUMTEXT NULL,
    CONSTRAINT fk_itinerary_items_day FOREIGN KEY (day_id) REFERENCES itinerary_days(id) ON DELETE CASCADE,
    CONSTRAINT fk_itinerary_items_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE SET NULL,
    INDEX idx_itinerary_items_day (day_id),
    UNIQUE KEY uq_item_sequence (day_id, sequence_order),
    CONSTRAINT chk_item_sequence CHECK (sequence_order > 0),
    CONSTRAINT chk_item_duration CHECK (duration_minutes IS NULL OR duration_minutes > 0),
    CONSTRAINT chk_item_prices CHECK ((estimated_cost_vnd IS NULL OR estimated_cost_vnd >= 0) AND (unit_price_vnd IS NULL OR unit_price_vnd >= 0)),
    CONSTRAINT chk_item_travel CHECK ((travel_distance_m IS NULL OR travel_distance_m >= 0) AND (travel_duration_seconds IS NULL OR travel_duration_seconds >= 0)),
    CONSTRAINT chk_item_route_source CHECK (route_source IN ('PROVIDER', 'CACHE', 'HAVERSINE', 'UNKNOWN')),
    CONSTRAINT chk_item_polyline CHECK (route_source IN ('PROVIDER', 'CACHE') OR route_polyline IS NULL),
    CONSTRAINT chk_item_coordinates CHECK ((latitude IS NULL AND longitude IS NULL) OR (latitude IS NOT NULL AND longitude IS NOT NULL AND latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Audit Logs Table
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    actor_name VARCHAR(150) NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id BIGINT NULL,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_audit_created (created_at),
    INDEX idx_audit_actor_created (user_id, created_at),
    INDEX idx_audit_entity (entity_type, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE traveler_profiles (
    user_id BIGINT PRIMARY KEY,
    language VARCHAR(5) NOT NULL DEFAULT 'vi',
    default_budget_vnd BIGINT NULL,
    default_pace VARCHAR(30) NOT NULL DEFAULT 'balanced',
    default_transport VARCHAR(20) NOT NULL DEFAULT 'unspecified',
    preferred_categories JSON NOT NULL DEFAULT (JSON_ARRAY()),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_profile_language CHECK (language IN ('vi', 'en')),
    CONSTRAINT chk_profile_budget CHECK (default_budget_vnd IS NULL OR default_budget_vnd > 0),
    CONSTRAINT chk_profile_pace CHECK (default_pace IN ('relaxed', 'balanced', 'packed')),
    CONSTRAINT chk_profile_transport CHECK (default_transport IN ('walking', 'motorbike', 'car', 'taxi', 'unspecified')),
    CONSTRAINT chk_profile_categories CHECK (JSON_TYPE(preferred_categories) = 'ARRAY')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE favorites (
    user_id BIGINT NOT NULL,
    destination_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, destination_id),
    CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_favorites_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE,
    INDEX idx_favorites_destination (destination_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE itinerary_constraints (
    itinerary_id BIGINT NOT NULL,
    destination_id BIGINT NOT NULL,
    constraint_type VARCHAR(10) NOT NULL,
    destination_snapshot JSON NULL,
    PRIMARY KEY (itinerary_id, destination_id),
    CONSTRAINT fk_constraints_itinerary FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
    CONSTRAINT fk_constraints_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE RESTRICT,
    CONSTRAINT chk_constraint_type CHECK (constraint_type IN ('REQUIRED', 'EXCLUDED')),
    INDEX idx_constraints_destination (destination_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash BINARY(32) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reset_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reset_user_expiry (user_id, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
