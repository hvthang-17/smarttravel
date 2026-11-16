-- =============================================================================
-- V2__seed_system_data.sql
-- Seed system categories 
-- =============================================================================

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
    'NIGHTLIFE', 
    'cho-dem-giai-tri', 
    'Chợ đêm & Giải trí', 
    'Nightlife & Markets', 
    'Sôi động cùng chợ đêm Helio, chợ đêm Sơn Trà chân Cầu Rồng và phố đi bộ Bạch Đằng.', 
    NULL, 
    'sparkles', 
    '#EF4444', 
    5, 
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
    6, 
    'ACTIVE'
);
