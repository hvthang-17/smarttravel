CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE COMMENT 'Mã danh mục hệ thống (VD: BEACH, FOOD, CULTURE)',
    slug VARCHAR(100) NOT NULL UNIQUE COMMENT 'Đường dẫn URL thân thiện (VD: bien-thien-nhien)',
    name VARCHAR(100) NOT NULL COMMENT 'Tên tiếng Việt hiển thị',
    name_en VARCHAR(100) NULL COMMENT 'Tên tiếng Anh cho khách quốc tế',
    description TEXT NULL COMMENT 'Mô tả chi tiết về danh mục',
    image_url VARCHAR(500) NULL COMMENT 'Đường dẫn ảnh bìa tải lên từ máy tính',
    icon VARCHAR(50) NOT NULL DEFAULT 'tag' COMMENT 'Mã icon đại diện (palmtree, utensils, landmark...)',
    color_hex VARCHAR(10) DEFAULT '#0077B6' COMMENT 'Mã màu HEX đại diện cho badge',
    display_order INT NOT NULL DEFAULT 0 COMMENT 'Thứ tự ưu tiên sắp xếp (số nhỏ xếp trước)',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT 'Trạng thái: ACTIVE hoặc INACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_categories_status_order (status, display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO categories (code, slug, name, name_en, description, image_url, icon, color_hex, display_order, status) 
VALUES
(
    'BEACH', 
    'bien-thien-nhien', 
    'Biển & Thiên nhiên', 
    'Beach & Nature', 
    'Khám phá dải bờ biển Mỹ Khê quyến rũ, bán đảo Sơn Trà hoang sơ và các bãi rêu đá kỳ vĩ.', 
    'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=800&q=80', 
    'palmtree', 
    '#10B981', 
    1, 
    'ACTIVE'
),
(
    'FOOD', 
    'am-thuc-dac-san', 
    'Ẩm thực & Đặc sản', 
    'Cuisine & Local Food', 
    'Thưởng thức mì Quảng gia truyền, bánh xèo tôm nhảy, hải sản tươi sống và món ngon chợ Cồn.', 
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80', 
    'utensils', 
    '#F97316', 
    2, 
    'ACTIVE'
),
(
    'CULTURE', 
    'van-hoa-di-san', 
    'Văn hóa & Di sản', 
    'Culture & Heritage', 
    'Tham quan danh thắng Ngũ Hành Sơn huyền bí, bảo tàng điêu khắc Chăm Pa và các ngôi chùa cổ linh thiêng.', 
    'https://images.unsplash.com/photo-1570789210967-2cac24afeb00?auto=format&fit=crop&w=800&q=80', 
    'landmark', 
    '#0077B6', 
    3, 
    'ACTIVE'
),
(
    'CHECKIN', 
    'song-ao-checkin', 
    'Sống ảo & Check-in', 
    'Photo Spots & Check-in', 
    'Các cây cầu biểu tượng sông Hàn, Cầu Vàng Bà Nà Hills, bến du thuyền và điểm ngắm hoàng hôn.', 
    'https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=800&q=80', 
    'camera', 
    '#8B5CF6', 
    4, 
    'ACTIVE'
),
(
    'HOTEL', 
    'nghi-duong-khach-san', 
    'Nghỉ dưỡng & Khách sạn', 
    'Hotels & Resorts', 
    'Hệ thống resort cao cấp 5 sao bên biển Non Nước và khách sạn view sông Hàn lung linh về đêm.', 
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80', 
    'hotel', 
    '#0284C7', 
    5, 
    'ACTIVE'
),
(
    'NIGHTLIFE', 
    'cho-dem-giai-tri', 
    'Chợ đêm & Giải trí', 
    'Nightlife & Markets', 
    'Sôi động cùng chợ đêm Helio, chợ đêm Sơn Trà chân Cầu Rồng và phố đi bộ Bạch Đằng.', 
    NULL, 
    'sparkles', 
    '#EF4444', 
    6, 
    'ACTIVE'
),
(
    'CAFE', 
    'ca-phe-thu-gian', 
    'Cà phê & Thư giãn', 
    'Coffee & Chill', 
    'Trải nghiệm những góc cafe vườn yên tĩnh, cafe ngắm máy bay và ngắm hoàng hôn bên biển.', 
    NULL, 
    'coffee', 
    '#D97706', 
    7, 
    'ACTIVE'
)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    icon = VALUES(icon),
    color_hex = VALUES(color_hex);

SET @dbname = DATABASE();
SET @tablename = 'destinations';
SET @columnname = 'category_id';
SET @preparedStatement = (SELECT IF(
    (
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = @dbname
          AND TABLE_NAME = @tablename
          AND COLUMN_NAME = @columnname
    ) > 0,
    'SELECT 1',
    'ALTER TABLE destinations ADD COLUMN category_id BIGINT NULL AFTER category'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

UPDATE destinations SET category_id = (SELECT id FROM categories WHERE code = 'BEACH') WHERE category = 'Beach';
UPDATE destinations SET category_id = (SELECT id FROM categories WHERE code = 'CULTURE') WHERE category = 'Culture';
UPDATE destinations SET category_id = (SELECT id FROM categories WHERE code = 'FOOD') WHERE category = 'Food';
UPDATE destinations SET category_id = (SELECT id FROM categories WHERE code = 'HOTEL') WHERE category = 'Hotel';
