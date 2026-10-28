-- =============================================================================
-- V1__init_schema.sql
-- SmartTravel Database Schema Initialization
-- Tables: categories, users, destinations, destination_reviews,
--         itineraries, itinerary_days, itinerary_items, audit_logs
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
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Destinations Table (Liên kết khóa ngoại chuẩn hóa với categories)
CREATE TABLE destinations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(180) NOT NULL,
    category_id BIGINT NOT NULL,
    description TEXT,
    address VARCHAR(255) NULL,
    opening_hours VARCHAR(100) NULL,
    phone VARCHAR(50) NULL,
    website VARCHAR(255) NULL,
    image_url VARCHAR(500) NULL,
    sub_images TEXT NULL COMMENT 'JSON array of additional gallery image URLs',
    rating DECIMAL(2, 1) NOT NULL DEFAULT 4.5,
    review_count INT NOT NULL DEFAULT 0,
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
    INDEX idx_destinations_osm_id (osm_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Destination Reviews Table
CREATE TABLE destination_reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    destination_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reviews_destination (destination_id),
    INDEX idx_reviews_user (user_id)
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
    total_estimated_cost BIGINT DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    share_token VARCHAR(100) UNIQUE NULL,
    version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itineraries_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_itineraries_user (user_id),
    INDEX idx_itineraries_share_token (share_token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Itinerary Days Table
CREATE TABLE itinerary_days (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id BIGINT NOT NULL,
    day_number INT NOT NULL,
    date DATE,
    CONSTRAINT fk_itinerary_days_itinerary FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
    INDEX idx_itinerary_days_itinerary (itinerary_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Itinerary Items Table
CREATE TABLE itinerary_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    day_id BIGINT NOT NULL,
    destination_id BIGINT,
    sequence_order INT NOT NULL,
    start_time TIME,
    duration_minutes INT DEFAULT 90,
    estimated_cost_vnd BIGINT DEFAULT 0,
    notes TEXT,
    CONSTRAINT fk_itinerary_items_day FOREIGN KEY (day_id) REFERENCES itinerary_days(id) ON DELETE CASCADE,
    CONSTRAINT fk_itinerary_items_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE SET NULL,
    INDEX idx_itinerary_items_day (day_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Audit Logs Table
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
