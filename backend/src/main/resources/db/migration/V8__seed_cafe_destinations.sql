-- =============================================================================
-- SmartTravel — Seed 50 CAFE Destinations across Da Nang (7 Districts)
-- Category: CAFE (ca-phe-check-in)
-- Operating status (OPEN / ACTIVE), ratings, review counts, opening hours,
-- GPS coordinates (!3d!4d), and image_url verified directly on live Google Maps POIs.
-- Drink price ranges (VND) reflect verified menu & platform reference pricing.
-- =============================================================================

INSERT INTO destinations (
    name, category_id, description, address, opening_hours, phone, website,
    image_url, sub_images, rating, review_count, osm_id, latitude, longitude,
    price_min_vnd, price_max_vnd, status, created_at, updated_at
) VALUES

-- -----------------------------------------------------------------------------
-- 1. QUẬN HẢI CHÂU (14 địa điểm)
-- -----------------------------------------------------------------------------

-- 1. Cộng Cà Phê (98-96 Bạch Đằng)
(
    'Cộng Cà Phê',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Chi nhánh Cộng Cà Phê nổi tiếng bậc nhất bên bờ tây sông Hàn với kiến trúc hoài cổ phong cách bao cấp. Du khách và người dân thường ghé thưởng thức cà phê cốt dừa trứ danh, bạc xỉu, cà phê nâu kem muối và ngắm nhịp sống phố đi bộ Bạch Đằng.',
    '98-96 Bạch Đằng, Q. Hải Châu, Đà Nẵng 550000',
    '07:00 - 23:30',
    '+84 775 561 544',
    'http://congcaphe.com/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdkUlj7rk4PZnyh1IXq2PkIQRKtarX1LgmWJX8gLsKg5Kctj0LrSFzsYVaJwKUENieMLSZJyoMGtZmo19yMKcIHUSEHDyYrlxUc-m9CIGgP20IWgf1kbhD6Hnvl4rmOIUaTHxFP=w408-h272-k-no',
    NULL,
    4.1,
    10239,
    'seed/cafe-cong-ca-phe-bach-dang',
    16.0690486,
    108.2248767,
    35000,
    70000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 2. Trình cà phê (25 Phạm Hồng Thái)
(
    'Trình cà phê',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Thương hiệu cà phê bản địa được yêu thích tại trung tâm Hải Châu nhờ không gian vườn mộc mạc ấm cúng và món cà phê bơ đặc sản béo ngậy khó quên. Quán phục vụ cả phin truyền thống, cold brew và nhiều loại trà thảo mộc nhẹ nhàng.',
    '25 Phạm Hồng Thái, Q. Hải Châu, Đà Nẵng 55000',
    '06:30 - 23:00',
    '+84 932 453 811',
    'https://www.facebook.com/trinhcaphedn/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdY_hFngQdMFbvHkR5_9YTlehDM3xVpUq0F5C-Iuc1JQcYID1ErZI57GJ7uPkrxRubp1oapl0J3CUpNF-PSO6F9jYwI49xC1GpMCwrd_Tj5KjJbpXL6w4CItt2Gj5z9-JuK1XA=w408-h265-k-no',
    NULL,
    4.8,
    7925,
    'seed/cafe-trinh-ca-phe-pham-hong-thai',
    16.0673825,
    108.2217327,
    25000,
    60000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 3. Nia Coffee (14 Phan Thành Tài)
(
    'Nia Coffee',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê sân vườn xanh mát ẩn mình trong con kiệt trung tâm với thiết kế giếng trời mở, hồ cá Koi lớn và nhiều góc ngồi làm việc yên tĩnh. Đồ uống đa dạng từ cà phê truyền thống, espresso pha máy đến trà trái cây và sinh tố.',
    '14 Phan Thành Tài, Hòa Cường, Q. Hải Châu, Đà Nẵng 550000',
    '07:00 - 22:00',
    '+84 903 515 415',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLej2Tz9m3uAzhX3xwA2hB95nXdHznTkvmWoe4SW5zOoQZ40wlQtXCyql1VnBHwKDvNRIMbuOnKm0XvysPZMt4Tae69gbsKqPQlvn8sEzD_2AqDw-I9JUSgXT78wd4QgEwCbkHz0=w408-h544-k-no',
    NULL,
    4.3,
    2523,
    'seed/cafe-nia-coffee',
    16.0530744,
    108.2215045,
    15000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 4. Nối Café (113/25 Nguyễn Chí Thanh)
(
    'Nối Café',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Không gian hoài niệm đậm chất Đà Nẵng xưa nằm trong hẻm nhỏ Nguyễn Chí Thanh, trưng bày radio, xe cổ và phát nhạc Trịnh nhẹ nhàng. Quán nổi bật với các món cà phê trứng, cacao trứng kem mịn cùng bạc xỉu thơm béo.',
    '113/25 Nguyễn Chí Thanh, Q. Hải Châu, Đà Nẵng 550000',
    '06:30 - 22:00',
    '+84 935 804 537',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfi4FuVabQc1ROqQj-19Ajo3zvDfWNvkTux2yL5ClizGu91vO3ZsvzRL9C9abF7C8NMITBfxEIGoHtEwnPgUU2PEYecsREbXFubbJjdubVwPnpbY2P-9RPrP67LmKmQ_L4mkaR8=w408-h306-k-no',
    NULL,
    4.4,
    1028,
    'seed/cafe-noi-cafe',
    16.0738303,
    108.2217984,
    20000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 5. WONDERLUST - Coffee & Souvenir (96 Trần Phú)
(
    'WONDERLUST - Coffee & Souvenir',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tổ hợp quán cà phê, không gian làm việc sáng tạo và cửa hàng quà lưu niệm thiết kế tối giản tông trắng giếng trời ngập sáng trên đường Trần Phú. Thực đơn nổi bật với trà đặc sản, cold brew, mocktail và bánh ngọt thủ công.',
    '96 Trần Phú, Q. Hải Châu, Đà Nẵng 840236',
    '08:00 - 19:30',
    '+84 236 3744 678',
    'http://wonderlust.vn/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcXL8sXg1HFmmv814Q0W2R3hk7snuDyM1hYKbBy1hED-WTc1ULFkQxj9SZ3wpl-KA1h_hcU3dL44ncvHzHE6-vKR8va4zH2iVszMbJWlSWpl3XCIvJobGl7y_X3QT_1sFiTCKTx=w408-h613-k-no',
    NULL,
    4.5,
    1570,
    'seed/cafe-wonderlust-coffee-souvenir',
    16.0691557,
    108.2238430,
    40000,
    75000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 6. Boulevard Gelato, Pastry & Coffee (77 Trần Quốc Toản)
(
    'Boulevard Gelato, Pastry & Coffee',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm kem Ý thủ công kết hợp cà phê và bánh ngọt phong cách châu Âu sang trọng ngay góc phố trung tâm Hải Châu. Nổi tiếng với hơn chục vị gelato đặc trưng, bingsu trái cây tươi, espresso và các món trà pha chế sáng tạo.',
    '77 Trần Quốc Toản, Q. Hải Châu, Đà Nẵng 550000',
    '07:00 - 23:00',
    NULL,
    'https://www.boulevard.vn/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfsKAQuFeBvuRyWK41Dp-YA-xue1hqFTeTRASEnNlx-Jk-OnbgmYHWj6FEsvF4XR3eUmUjsALpnUNcbnIMH6zfRrQPkElkvDXHZA1fC3DwxO5LdhiQERBUdakM4LKbUNTtFGJ7ufrC9xlP-=w408-h272-k-no',
    NULL,
    4.4,
    1635,
    'seed/cafe-boulevard-gelato-coffee',
    16.0663141,
    108.2208847,
    40000,
    195000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 7. P Coffee (53-55 Nguyễn Văn Linh)
(
    'P Coffee',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê kết hợp tiệm bánh trên trục đường Nguyễn Văn Linh sầm uất gần Cầu Rồng, mang thiết kế tối giản tông trắng gỗ tinh tế. Phục vụ cà phê máy, kombucha nhà làm, trà trái cây và các loại bánh croissant nướng mới mỗi ngày.',
    '53-55 Nguyễn Văn Linh, Q. Hải Châu, Đà Nẵng 50211',
    '07:00 - 22:00',
    '+84 838 437 777',
    'https://www.facebook.com/p.poonacoffee/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLd4BISQ8-PbNC6hAdGYTsXVTi-YWB6b5D6YpKlXZssLjvGEsQQ7BS49v2XRBFjULYdS3TLXfPUUVE0Wvc4TkQGNG0KahpxlyYw0KjE6Sdu4sNdfn4S1HAwhIA4mKva_vm4ahAqQUg=w408-h402-k-no',
    NULL,
    4.5,
    1026,
    'seed/cafe-p-coffee-nguyen-van-linh',
    16.0607465,
    108.2206633,
    45000,
    80000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 8. Reply 1988 Cafe (45 Lê Hồng Phong)
(
    'Reply 1988 Cafe',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê phong cách retro Hàn Quốc kết hợp không gian mở khuya giữa lòng Hải Châu, được giới trẻ và sinh viên ưa chuộng để tụ họp và chụp ảnh check-in. Nổi bật với cà phê trứng béo mịn, trà sữa và cà phê pha máy hạt Arabica.',
    '45 Lê Hồng Phong, Q. Hải Châu, Đà Nẵng 550000',
    '07:00 - 02:00',
    '+84 935 273 277',
    'https://www.facebook.com/Reply1988Cafe',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeuGbXcFie2QxQ9puEOICurrcIlLbI3-ZkKhKCdcEokk16JSnhpqZyjmJN2_QbYjye_5LRb7D5ASzDaxzEXCb7X93eGdmQV234Skqnk4ufUIFzyjKN9uNt5lzuOfcwrnoOf_G8myDDwVA9N=w408-h613-k-no',
    NULL,
    4.6,
    1086,
    'seed/cafe-reply-1988',
    16.0637675,
    108.2210940,
    30000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 9. Cà Phê Long (123 Lê Lợi)
(
    'Cà Phê Long',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê cóc truyền thống hơn bốn thập kỷ gắn liền với ký ức của người dân Đà Nẵng tại ngã tư Lê Lợi – Quang Trung. Phục vụ cà phê phin đậm đà, cà phê sữa đá trong ly thủy tinh nhỏ quen thuộc với mức giá bình dân hiếm có giữa trung tâm.',
    '123 Lê Lợi, Q. Hải Châu, Đà Nẵng 550000',
    '05:00 - 19:00',
    '+84 795 995 757',
    'https://longcoffee.vn/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdIgTbFynl0FHWuB4REP7YEDb5yp0Vm2aIhipuso-iDQpKkdGEEXCDXYZLZdyThUXRHkfX8LPI-mZa7b4M8aUWmLcO3hPXHyWy3fxnCmspJeLTBsV4C_g3VzunI14MYn5sBCM0=w408-h367-k-no',
    NULL,
    4.4,
    381,
    'seed/cafe-long-123-le-loi',
    16.0749252,
    108.2201094,
    10000,
    30000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 10. NAM cafe - 36 Dong Da
(
    'NAM cafe - 36 Dong Da',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê mở cửa 24/7 nổi tiếng tại trung tâm Đà Nẵng trong ngôi nhà cổ ấm cúng với ánh đèn vàng dịu và bàn ghế gỗ mộc. Điểm đến lý tưởng cho dân chạy deadline hoặc du khách muốn thưởng thức cà phê muối, cà phê trứng bất kể ngày đêm.',
    '36 Đống Đa, Q. Hải Châu, Đà Nẵng 550000',
    '00:00 - 24:00 (Mở cả ngày)',
    '+84 857 786 869',
    'https://www.facebook.com/NAMcafe36DongDa/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdgy81pwOxBLKWnZNpfR7DgphSyQ3l2x_Kb8qRDfS6gOXB5mtszWxCBJEAYf0x6uKQ2bq13KeNg5MIRpC3_pd0dqiiAjxatmWIlukcEgF_DHOYmZdxp-1LTC0HqqPTnhFKW0JM_=w426-h240-k-no',
    NULL,
    4.4,
    442,
    'seed/cafe-nam-36-dong-da',
    16.0822505,
    108.2201328,
    25000,
    60000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 11. Út Tịch Café (102 Bạch Đằng)
(
    'Út Tịch Café',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê mang hơi thở Hội An mộc mạc tọa lạc ngay mặt tiền đường Bạch Đằng nhìn ra sông Hàn thơ mộng. Không gian rộng thoáng nhiều tầng, nổi tiếng với cà phê cốt dừa, sinh tố trái cây tươi và trà nhài giải nhiệt.',
    '102 Bạch Đằng, Q. Hải Châu, Đà Nẵng 550000',
    '06:30 - 22:30',
    '+84 911 777 207',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcXAf22VTvUOx6A1O4TxAmJ40VGWWwguWuk-o_du03fXzmYYPQVYFHmsdA4g-3Y8_Oe-7fCIIjWvxCbfVtI-Aj9fin75iAMGe1kOsI_SjpNic79wK2yjqLMbMn3NjEr_Mb-8zkCDmRurYw=w408-h306-k-no',
    NULL,
    4.5,
    1535,
    'seed/cafe-ut-tich-bach-dang',
    16.0689249,
    108.2248978,
    30000,
    60000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 12. Trà Quán Góc Nhà Tụi Mình (K36/36 Lê Duẩn)
(
    'Trà Quán Góc Nhà Tụi Mình',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm trà và cà phê tĩnh lặng ẩn sâu trong con hẻm đường Lê Duẩn với kiến trúc nhà xưa thập niên 70–80 và khoảng sân rợp bóng cây. Chuyên phục vụ các dòng trà thuần Việt, trà hoa thảo mộc, kombucha và cà phê thủ công cùng đêm nhạc acoustic ấm áp.',
    'K36/36 Lê Duẩn, Q. Hải Châu, Đà Nẵng 550000',
    '07:00 - 22:00',
    NULL,
    'https://www.facebook.com/gocnhatuiminh',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcrgvo-pBjdKLyNsv8SXG9Cc4UKr4Y36fCmXhL474tNHOhh2UyL4Hpc5ExO5hZefysi2kFG55ENUjRjh-_hMzObA8X5UrBiQP7SuOd7C14QZvG9RKzpMRYzIqGtVl1POUAVBR-5=w408-h306-k-no',
    NULL,
    4.7,
    530,
    'seed/cafe-tra-quan-goc-nha-tui-minh',
    16.0723858,
    108.2218489,
    15000,
    40000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 13. Phê La Bạch Đằng - Đà Nẵng (36 - 38 Bạch Đằng)
(
    'Phê La Bạch Đằng - Đà Nẵng',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Cửa hàng flagship của thương hiệu trà Ô Long đặc sản Phê La nằm ở vị trí đắc địa ven sông Hàn với thiết kế cắm trại du mục hiện đại. Nổi tiếng với Ô Long sữa, Phê Nâu, Trà Lụa Đào và các dòng trân châu làm thủ công mỗi ngày.',
    '36 - 38 Bạch Đằng, Q. Hải Châu, Đà Nẵng 550000',
    '07:00 - 22:45',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcwmDcm9TVNNszlVvzUBtUmM-k1gj2CN7zi1aOqsah92CuOyQe4pMn0nT1FMVJAiZxtO0KJ-SXScENegaARP5AZTF0m6gZd1m0L1tduDLGMTIrWpXBxEspcDts2yTSbswY5_wmrqvmTiQzR=w408-h307-k-no',
    NULL,
    4.7,
    1342,
    'seed/cafe-phe-la-bach-dang',
    16.0771891,
    108.2238641,
    40000,
    75000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 14. DỪA BẾN TRE 196 (196 Bạch Đằng)
(
    'DỪA BẾN TRE 196',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán giải khát dừa tươi và món tráng miệng ven sông Hàn quen thuộc với người dân địa phương và du khách đi dạo buổi tối. Nổi tiếng với dừa tươi Bến Tre ngọt thanh nhiều cơm, rau câu dừa, kem bơ dừa và các món giải nhiệt mát lành.',
    '196 Bạch Đằng, Q. Hải Châu, Đà Nẵng 550000',
    '08:00 - 23:30',
    '+84 935 133 138',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcUQJgZ5N9mAWObiW0wrOaI5lcEiPfEPby-OhXMOKS8PLSFUkEfcq5NaGyYn0vtb5wH6pxV9NI0pdv8GVg_LnApiy7l-59rhIVbDqKmebH7LFNtD7pLepiYi8Jas6nR08xstsDf-g=w408-h544-k-no',
    NULL,
    4.4,
    163,
    'seed/cafe-dua-ben-tre-196',
    16.0656230,
    108.2242332,
    25000,
    65000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- 2. QUẬN SƠN TRÀ (9 địa điểm)
-- -----------------------------------------------------------------------------

-- 15. Sơn Trà Marina (Hồ Xanh, Sơn Trà)
(
    'Sơn Trà Marina',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tổ hợp quán cà phê và nhà hàng kiến trúc Santorini tông trắng xanh sát bờ biển bán đảo Sơn Trà với tầm nhìn hướng thẳng vịnh Đà Nẵng. Điểm check-in ngắm bình minh và hoàng hôn nổi tiếng cùng thực đơn cà phê muối, trà trái cây và món Âu.',
    'Hồ Xanh, Q. Sơn Trà, Đà Nẵng 550000',
    '07:00 - 21:00',
    '+84 876 263 646',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfwUyKNxiaczZ9lsnc15-eowKghCWHmP4JAKUMUBy3TVX5UUJJo9LsHrqTsJr1VRMTOqjJSSUdQKQN0dsX0gJQIia2r5o7_8QwdMPaF-47a4_j1xI-Ae7ZXuyzHd88KRxSV7ZizAerSirqz=w408-h306-k-no',
    NULL,
    4.0,
    4074,
    'seed/cafe-son-tra-marina',
    16.0968369,
    108.2669597,
    40000,
    80000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 16. Wind Garden Coffee (72 Lê Mạnh Trinh)
(
    'Wind Garden Coffee',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê sân vườn nổi tiếng khu vực Phước Mỹ với không gian cây xanh mát rượi và hồ cá Koi sinh động bao quanh bàn ngồi. Thực đơn đa dạng từ cà phê truyền thống, cà phê muối, cold brew dừa đến trà trái cây và matcha sữa hạt.',
    '72 Lê Mạnh Trinh, An Hải, Q. Sơn Trà, Đà Nẵng 550000',
    '07:30 - 22:00',
    '+84 905 519 991',
    'https://www.facebook.com/windgardencoffee?mibextid=ZbWKwL',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLc7E_HDpOY-tBWoBcp6TEOyp_-WQxMgqotW6fZL01f6NH7Ix4kMDA1Y73oKNyD0qBXgxcDmHuKco9zyVbyvmZDFQxbR7IjgpZtP3w0nAguG9lEZFavAm5pW4TmGzlnEWJZ2yVWUrLvg8dgi=w408-h306-k-no',
    NULL,
    4.4,
    1619,
    'seed/cafe-wind-garden-coffee',
    16.0745120,
    108.2434614,
    25000,
    65000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 17. Acacia by CaySi cafe (05 An Cư 5)
(
    'Acacia by CaySi cafe',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê sân vườn phong cách cắm trại kết hợp nhiệt đới được đánh giá rất cao gần biển Phạm Văn Đồng. Không gian rợp bóng cây xanh dễ chịu, nổi bật với cà phê bơ đậu phộng, cà phê muối, trà trái cây và bánh chuối nhà làm.',
    '05 An Cư 5, An Hải, Q. Sơn Trà, Đà Nẵng 550000',
    '06:30 - 22:00',
    '+84 769 482 888',
    'http://facebook.com/caysidng',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeLDtgpxd7rZlPs1dtU2gg2aikWt6RxaqTp8X_LtQup9JjhnYPsZo7rrLRsGPamyEcIjIVSoWQWyfDGWVTge2T3lgiyUsPUa2DjLXOwOL60XcOESJ5XR6C5hVURxWe3eJRZBhQH=w426-h240-k-no',
    NULL,
    4.8,
    730,
    'seed/cafe-acacia-by-caysi',
    16.0740525,
    108.2419258,
    25000,
    55000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 18. Coffee Đom Đóm-Khu vui chơi trẻ em (117 Đinh Công Trứ)
(
    'Coffee Đom Đóm-Khu vui chơi trẻ em',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Điểm hẹn cà phê gia đình lý tưởng tại quận Sơn Trà với cả phòng máy lạnh, sân ngoài trời rộng rãi và khu vui chơi an toàn cho trẻ nhỏ. Phục vụ các loại cà phê truyền thống, nước ép, trà sữa với mức giá bình dân thân thiện.',
    '117 Đinh Công Trứ, Q. Sơn Trà, Đà Nẵng',
    '06:00 - 22:00',
    '+84 905 085 843',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfhT6dx9XRT7VVc36tgWclKo4pjbN0HCYCRINi2cgQKpdcKiBlVHdDV3zFjEwoergheh4D4n2L06_wuF3w6xI_rJwas7OOQyRdxbHHtrGCwNNq-wQG1t6KM0mTbO8Lo1IxBtg8=w408-h306-k-no',
    NULL,
    4.1,
    93,
    'seed/cafe-dom-dom-son-tra',
    16.0949457,
    108.2488127,
    25000,
    40000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 19. Nối - The Cabin (118 Chu Huy Mân)
(
    'Nối - The Cabin',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Chi nhánh phong cách vintage bao cấp thuộc hệ thống Nối Coffee nằm trên đường Chu Huy Mân gần cảng cá Thọ Quang. Ấn tượng với bộ sưu tập vật dụng xưa cũ, âm nhạc du dương cùng cà phê trứng và cacao kem béo ngậy.',
    '118 Chu Huy Mân, Q. Sơn Trà, Đà Nẵng 550000',
    '06:30 - 17:30',
    '+84 935 804 537',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLc_TxelA5ggahdmuNPWvcHAT4VwdgJ5GNXkc6hj5yay9nDpqPXayeG5oIlh1Qe7tOZMZxhRe7Ehe_DbtXkFs8qMNAROLmKo1u173IHZ2BKa2zAdSPZhZyGHvPxazml5nBwW-1w=w408-h679-k-no',
    NULL,
    4.5,
    600,
    'seed/cafe-noi-the-cabin',
    16.0946729,
    108.2344555,
    15000,
    100000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 20. NHÀN CAFE - 302 Hồ Nghinh
(
    'NHÀN CAFE - 302 Hồ Nghinh',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê mộc mạc nhiều cây xanh gần bãi biển Mỹ Khê được đánh giá gần như tuyệt đối nhờ hương vị đồ uống chỉn chu và không gian thư thái. Khách du lịch đặc biệt yêu thích cà phê muối, cà phê trứng và các loại trà thanh mát.',
    '302 Hồ Nghinh, An Hải, Q. Sơn Trà, Đà Nẵng 550000',
    '07:00 - 18:00',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfy0OKtJQcC7l-9iyE-UKkXAL63okWXTqY7ei3-FvmKsnol6UN7Z1zu5fLBItZRD2ihdkgEPevNoJuyOPFVq9IQdubYuqdkFCT37WUQoCq7gvO97nAB4CojvZO4NPABAem5Jy3i=w408-h544-k-no',
    NULL,
    4.9,
    852,
    'seed/cafe-nhan-302-ho-nghinh',
    16.0612743,
    108.2437698,
    30000,
    80000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 21. Cửa Ngõ Café (65/115 Tô Hiến Thành)
(
    'Cửa Ngõ Café',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm cà phê kiến trúc tường đất Địa Trung Hải kết hợp nét mộc Tây Bắc rất được giới trẻ săn đón chụp ảnh gần khu biển Mỹ Khê. Thực đơn nổi bật với cà phê kem muối, cà phê dừa, cà phê trứng và sinh tố trái cây nhiệt đới.',
    '65/115 Tô Hiến Thành, An Hải, Q. Sơn Trà, Đà Nẵng 550000',
    '06:30 - 21:30',
    '+84 914 101 119',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcB01vFdoB5D0TsJ2RfTE5LuLLUiZBkFvRU3T2nhGdXxAaCeGteUfQ5cWs8jFbsiv76tuLTaxOuYBLtTG-4kIGxECCxw_x4u9bY0J3rnnEMMbrJWx99OG8fwzISEe5-qzrdmFYT=w426-h240-k-no',
    NULL,
    4.7,
    1718,
    'seed/cafe-cua-ngo-cafe',
    16.0595780,
    108.2445979,
    27000,
    60000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 22. TaHi Garden (64 Mỹ Khê 7)
(
    'TaHi Garden',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê sân vườn sở hữu tiểu cảnh hồ nước và lối ngồi lơ lửng độc đáo ngay khu dân cư yên tĩnh gần biển Mỹ Khê. Ngoài cà phê và trà trái cây, quán còn phục vụ bữa sáng và brunch nhẹ nhàng cho khách du lịch.',
    '64 Mỹ Khê 7, An Hải, Q. Sơn Trà, Đà Nẵng 550000',
    '07:00 - 18:00',
    '+84 905 658 501',
    'https://facebook.com/k30vovankiet',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLewo8jevLL_YhdZP5mvyvXCRM1sNJtCofsbLqUe045JrqByu0ZJPAyhMPBVcqwA8Jgol2OIvL4qMzGOvcw595BcLFKmS3kDcCXCVmyyD0SHFBIMC08Nbtc5b9GvTQVDLg4YmvUq0A=w408-h276-k-no',
    NULL,
    4.5,
    323,
    'seed/cafe-tahi-garden',
    16.0629587,
    108.2386498,
    30000,
    60000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 23. Sơn Trà Cà Phê (Coffee Store) (143 Võ Văn Kiệt)
(
    'Sơn Trà Cà Phê (Coffee Store)',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê không gian mở ngập tràn cây xanh tọa lạc ngay mặt tiền đại lộ Võ Văn Kiệt hướng thẳng ra bãi biển Mỹ Khê. Thu hút cả người dân địa phương lẫn khách quốc tế với cà phê sữa đá, bạc xỉu, trà đào và đồ ăn sáng.',
    '143 Võ Văn Kiệt, An Hải, Q. Sơn Trà, Đà Nẵng 50000',
    '06:00 - 22:00',
    '+84 788 000 234',
    'https://www.facebook.com/caphestore143vovankietdanang',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfk_H8bBlxHudyXvIeDk1D5VW-bz3j1Y2kZMYufvS8PQRI7-PhZnlgsjyLvjVkIbpwISHeWv0TMqlCnx-B6KReNtkQETjaqbq7vEOIHBGrARuIJhxFoYxJVU2qvsa52YBz53x72WEXJwFQ=w408-h306-k-no',
    NULL,
    4.4,
    107,
    'seed/cafe-son-tra-coffee-store',
    16.0618446,
    108.2380405,
    25000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- 3. QUẬN NGŨ HÀNH SƠN (10 địa điểm)
-- -----------------------------------------------------------------------------

-- 24. XLIII Specialty Coffee (422 Ngô Thì Sĩ)
(
    'XLIII Specialty Coffee',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Thương hiệu cà phê đặc sản (Specialty Coffee) đẳng cấp quốc tế tiền thân là 43 Factory Coffee Roaster với kiến trúc công nghiệp tối giản bên mặt hồ cá rộng. Chuyên phục vụ hạt đơn nguồn rang nhẹ chiết xuất pour-over và espresso tinh tế.',
    '422 Ngô Thì Sĩ, Q. Ngũ Hành Sơn, Đà Nẵng 550000',
    '06:30 - 22:30',
    '+84 799 343 943',
    'https://xliiicoffee.com/location/xliii-coffee-da-nang/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfcSI-LAVLZaXPmRwaAEgBQ6nEg9uFguvd40k9-fpn6Rr0v6xo2g83LMRpDJocrsmQu7kRq0JcxnjwwKFfhmbmQ4kM0vE_PUFYUIV-PhkqUW0yM5dnEWtzM8Czrt8AMm4MBKI8HdQ=w408-h290-k-no',
    NULL,
    4.7,
    10388,
    'seed/cafe-xliii-specialty-coffee',
    16.0480872,
    108.2460233,
    50000,
    180000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 25. Lu Coffee (62 Lê Quang Đạo)
(
    'Lu Coffee',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê trẻ trung nằm gần khu phố du lịch An Thượng với không gian gọn gàng, sáng sủa và mức giá vô cùng dễ chịu. Phục vụ cà phê truyền thống, cà phê máy, cà phê muối và các món trà trái cây tươi mát.',
    '62 Lê Quang Đạo, Q. Ngũ Hành Sơn, Đà Nẵng 550000',
    '07:00 - 22:00',
    '+84 947 338 862',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfPerBJyUxLAanGdDZwsgsXAySuX_02cyfawrNEtn212_1EjUM44Z-u23HJd47cedNsYSL3LVKYusNRNeJxxXRx4HuhHcONmJvS5vL8FSO20zrL223DNs6OcNT1kxJ6jH16ADs=w408-h408-k-no',
    NULL,
    4.7,
    561,
    'seed/cafe-lu-coffee-le-quang-dao',
    16.0509469,
    108.2451784,
    15000,
    35000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 26. Roots (266 Trần Bạch Đằng)
(
    'Roots',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê và bếp thuần thực vật (Plant-based Café) cực kỳ đông khách gần bãi biển Mỹ Khê. Không gian nhiệt đới mộc mạc, nổi tiếng với smoothie bowl trái cây tươi, nước ép lạnh không đường tinh luyện, cà phê sữa hạt và brunch chay dinh dưỡng.',
    '266 Trần Bạch Đằng, Bắc Mỹ Phú, Q. Ngũ Hành Sơn, Đà Nẵng 550000',
    '07:30 - 22:30',
    '+84 905 565 826',
    'https://rootsplantbasedcafe.com/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdvuP8P_gfVhrwHpfqUgn9u4DhA11hNf1F_-uVL9IMm7dZeQkJnY82SsXoqsmOBf8Vv-grsV9seEGwqy4i5CiRhkvo1Dflnyk12r6zf1FTw7jj7y5LetB10bi9SEkr5Z_bHb6CW=w408-h544-k-no',
    NULL,
    4.7,
    4021,
    'seed/cafe-roots-plant-based-cafe',
    16.0486741,
    108.2477863,
    60000,
    120000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 27. Quán cà phê Sáu Trên Sáu (Six On Six Cafe - 64 Bà Huyện Thanh Quan)
(
    'Quán cà phê Sáu Trên Sáu',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm cà phê đặc sản kết hợp thực đơn eat-clean (Six On Six Cafe) nổi tiếng hàng đầu với cộng đồng digital nomad tại khu Mỹ An. Không gian vườn xanh rợp bóng nắng, phục vụ flat white chuẩn vị, cold brew, granola nhà làm và bagel kiểu Âu.',
    '64 Bà Huyện Thanh Quan, Q. Ngũ Hành Sơn, Đà Nẵng 550000',
    '07:30 - 21:00',
    '+84 946 114 967',
    'https://www.facebook.com/sixonsixcafe/menu/?id=100063485023387&sk=menu',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfIoS9KrKkeF0Qvvg8lskV1NLGRbVBZVs7e7QAzPFADkhMZevCgtJdvC3u5cZeX0OlZF7diYc9RG9F_nMGn8kqGDcjDxFykfy33Oqt7CQ3XhGUdA52utUZrz0pwdWljcT5RSQzCSXY4sD1I=w408-h544-k-no',
    NULL,
    4.7,
    2817,
    'seed/cafe-six-on-six',
    16.0432336,
    108.2442276,
    50000,
    150000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 28. The Hideout café (72/24 Nguyễn Văn Thoại)
(
    'The Hideout café',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê sân vườn ẩn mình trong con hẻm nhỏ Nguyễn Văn Thoại cách bãi biển Mỹ Khê vài phút đi bộ. Được yêu thích nhờ không gian yên tĩnh có ổ cắm làm việc, cà phê trứng, cà phê muối cùng các món ăn sáng phong cách phương Tây.',
    '72/24 Nguyễn Văn Thoại, Q. Ngũ Hành Sơn, Đà Nẵng 550000',
    '07:00 - 22:00',
    '+84 338 303 328',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcpkKSW9jzVoPSK-9HigIfWunKJThtRha2EgMT0njMSWsOLVljWr89Hll2jk8g1o6oa2wVtMV2cXfJcO5tVmUpaKw-yYDCmbVWZ2IkyXdawIwIaFaHaw9fVlJh-SO65p0ZWZjpm=w426-h240-k-no',
    NULL,
    4.6,
    1240,
    'seed/cafe-the-hideout',
    16.0534047,
    108.2404308,
    30000,
    90000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 29. Hôm nay Cà phê (31 An Thượng 29)
(
    'Hôm nay Cà phê',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm cà phê kiêm không gian làm việc và tạp hóa xanh xinh xắn nằm ngay trung tâm khu phố An Thượng. Thiết kế tối giản gần gũi với khu vườn thoáng phía dưới và phòng lạnh yên tĩnh tầng trên, phục vụ đa dạng cà phê, trà và brunch nhẹ.',
    '31 An Thượng 29, Q. Ngũ Hành Sơn, Đà Nẵng 550000',
    '07:00 - 22:00',
    '+84 815 707 699',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfeIEJxX3sG_o9YIk5Rkk6A5Nzbp9LsOEQLBL55Y0Quxkyp0AcvwdQEV-0WRjmFvE_godB6_ixHjyWSMbcYq2KNRMz18oCTrqEqMtWNQKZ-X7mYV6tcNQCZ-aVNLZ5JlBv4liD1nQMQaH-I=w408-h271-k-no',
    NULL,
    4.5,
    1274,
    'seed/cafe-hom-nay-ca-phe',
    16.0519493,
    108.2456243,
    40000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 30. Roost Coffee Roasters | Da Nang (57 Bà Huyện Thanh Quan)
(
    'Roost Coffee Roasters | Da Nang',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Xưởng rang xay cà phê đặc sản và không gian sân vườn tối giản yên bình dưới tán cây lớn tại khu Mỹ An. Điểm dừng chân yêu thích của tín đồ cà phê muốn thưởng thức pour-over, cold brew và espresso hạt rang mới chất lượng cao.',
    '57 Bà Huyện Thanh Quan, Q. Ngũ Hành Sơn, Đà Nẵng 50700',
    '07:00 - 21:00',
    '+84 914 002 628',
    'http://www.roostvn.cafe/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfjuW6SQjNHyqgHvgFmIX_eMfs52wbzglrM2IIUffJpma3KM6KnPlwYjq0El-Q48gG0EuZKC7WyESzIujf6RckEDcnjbWyWEtIoz_806-eGhD1Di4V8QIv5Kz-k9yvMlTHaBEPczZGTrEsS=w408-h612-k-no',
    NULL,
    4.8,
    533,
    'seed/cafe-roost-coffee-roasters',
    16.0433923,
    108.2440618,
    25000,
    60000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 31. Passion Café (19 An Thượng 5)
(
    'Passion Café',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê nhỏ ấm cúng trong khu phố Tây An Thượng nhận được điểm đánh giá cực cao 4.9 sao nhờ phong cách phục vụ tận tâm và đồ uống pha chế tỉ mỉ. Phục vụ cà phê truyền thống Việt Nam, cà phê dừa, sinh tố và đồ uống giải khát.',
    '19 An Thượng 5, Q. Ngũ Hành Sơn, Đà Nẵng 550000',
    'T2-T6: 07:00 - 22:00; T7-CN: 08:00 - 22:00',
    '+84 824 946 789',
    'https://www.facebook.com/Passion-Caf%C3%A9-28-Ho%C3%A0i-Thanh-104574644245862/?eid=ARAOpECXCthgms_CdkHWSM1qw4bB7x13Bvf14LOcmbc_Rpo5xpmCqf-Tb5oVCPNtKFqjJluZSLzUFdsZ',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfiuLWnPU8AZd6JkgHoPClkncBuHBSz-CcfLsG0XmDq0hZprmMbkBcz7Y87kHbVZn_2hvulIZwCsSVitG-98qzmntfMargVnEBvTEOIaiRAtPYYf78xe1a_nxvDtnMxDiNVdM_KJfI9szgv=w408-h306-k-no',
    NULL,
    4.9,
    1652,
    'seed/cafe-passion-cafe-an-thuong',
    16.0486935,
    108.2455003,
    25000,
    60000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 32. Cộng Cà Phê - An Thượng (Hoàng Kế Viêm)
(
    'Cộng Cà Phê - An Thượng',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Chi nhánh Cộng Cà Phê tọa lạc ngay giao lộ Hoàng Kế Viêm – An Thượng 6 nhộn nhịp sát biển Mỹ Khê. Mang đậm kiến trúc bao cấp đặc trưng, luôn tấp nập du khách ghé thưởng thức cốt dừa cà phê, cốt dừa cốm xanh và bạc xỉu đến tận khuya.',
    'An Thượng 6, Hoàng Kế Viêm, Q. Ngũ Hành Sơn, Đà Nẵng 550000',
    '07:30 - 23:30',
    '+84 775 761 114',
    'https://congcaphe.com/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLd2_u1Iiv3BMQCoLjEbqU5XdOBE7OrlpktSeuflGuEOKDbWUVYLGvKBpb0TZ5e1OCeAduUU_ket8TpjwrNxIhxak6Zi5lheKToOZh6MxjaCK1tyKq9EPpCEmbXeM55P9flp5t5J=w408-h271-k-no',
    NULL,
    4.3,
    715,
    'seed/cafe-cong-ca-phe-an-thuong',
    16.0490059,
    108.2450413,
    35000,
    70000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 33. Dng.coffee (05 An Thượng 2)
(
    'Dng.coffee',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê hai tầng phong cách tối giản kiểu Ý nằm tại khu An Thượng với không gian yên tĩnh chuyên biệt trên lầu dành cho người làm việc. Nổi bật với các dòng craft coffee, espresso, latte, cortado và cold brew rang thủ công.',
    '05 An Thượng 2, Q. Ngũ Hành Sơn, Đà Nẵng 550000',
    '08:00 - 21:30 (Thứ Ba đóng lúc 21:00)',
    '+84 384 211 502',
    'http://dng.coffee/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLedueBExNmuQopJwhf37prFIuruv4Pbk2e_2PVNGMu8CloEdtsubJ8tLglgchxSGqD6xnFaqu41v5hRRQ2jUaCACQLeoUucquBMW2ZKFrZtERBrTI4p7pap6lS9MM5sezolD4Tx=w408-h408-k-no',
    NULL,
    4.5,
    893,
    'seed/cafe-dng-coffee',
    16.0496115,
    108.2472289,
    40000,
    55000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- 4. QUẬN THANH KHÊ (5 địa điểm)
-- -----------------------------------------------------------------------------

-- 34. Nóc Rooftop (54 Lê Duy Đình)
(
    'Nóc Rooftop',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê sân thượng cực nổi tiếng tại quận Thanh Khê nhờ góc nhìn trực diện đường băng sân bay quốc tế Đà Nẵng để ngắm máy bay cất hạ cánh và săn hoàng hôn. Có thêm khu phòng lạnh làm việc yên tĩnh và phục vụ đồ uống mở khuya.',
    '54 Lê Duy Đình, Q. Thanh Khê, Đà Nẵng 550000',
    '15:00 - 02:45',
    '+84 901 310 599',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdcu5sndndz3RVaZ9lBKPr3T9trJPOHy-iqjhEX1Gd2-MhABAD6Y-RO43qN4DZT1hfPCvnnV225f6ejPHEba34EWBmn6Jc9iPoHw9KO_Owq4lUksbxMn83n4KJUS01xlrXNx2V-=w408-h544-k-no',
    NULL,
    4.6,
    523,
    'seed/cafe-noc-rooftop',
    16.0648228,
    108.2003250,
    30000,
    65000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 35. Gé Cafe (66 Đỗ Quang)
(
    'Gé Cafe',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm cà phê sân vườn kết hợp phòng máy lạnh tại khu vực Đỗ Quang mở cửa đến 3 giờ sáng. Không gian thoáng rộng nhiều cây xanh, menu phong phú từ cà phê muối, bạc xỉu sử dụng hạt Arabica/Robusta đến matcha kem muối và trà đào.',
    '66 Đỗ Quang, Q. Thanh Khê, Đà Nẵng 550000',
    '06:00 - 03:00',
    '+84 905 569 479',
    'https://gecafe.vn/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfgfwjjQTiVT5dYchEZfrRtk0RL0zCf2DYyY21gAJh_B3aIW8D-hQG4ykgtip1IngHLRJWAtVvYgtif3GsgLgDX87h4Oqe0lf5wPbTLp4w5lE8zkFch1DfT6O6yG8_fmDrZajR87G4g0-QB=w408-h510-k-no',
    NULL,
    4.3,
    483,
    'seed/cafe-ge-cafe-do-quang',
    16.0605706,
    108.2118763,
    25000,
    60000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 36. Túc Tắc Tea Đà Nẵng - Dũng Sĩ Thanh Khê (58 Dũng Sĩ Thanh Khê)
(
    'Túc Tắc Tea Đà Nẵng - Dũng Sĩ Thanh Khê',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Điểm hẹn trà sữa và trà trái cây đông khách bậc nhất khu vực Thanh Khê được sinh viên và giới trẻ địa phương đánh giá 4.7 sao. Nổi bật với trà sữa Kim Tuyên, Hokkaido, Ô Long và các dòng sữa dừa kem béo thanh mát.',
    '58 Dũng Sĩ Thanh Khê, Q. Thanh Khê, Đà Nẵng 50000',
    '09:00 - 22:00',
    '+84 566 664 343',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfMMVK9j9aC7VtpeeXyfn5QVG09ZYnSj8ULXslnGcj4r4o0uN79m2UJyVCcvkAbFVFl_1fWnt_t9lu-XGY8qFzw_ftF3G5BhZEcQoxF06qMvB7OfkUXtlIUsIqHZrXpNuDGCaRM-lMYGWYS=w408-h544-k-no',
    NULL,
    4.7,
    1123,
    'seed/cafe-tuc-tac-tea-thanh-khe',
    16.0717253,
    108.1791983,
    28000,
    46000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 37. THE LEAF HOUSE CAFE (1151 Nguyễn Tất Thành)
(
    'THE LEAF HOUSE CAFE',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê mặt tiền cung đường biển Nguyễn Tất Thành sở hữu tầm nhìn thoáng hướng ra vịnh Đà Nẵng mát mẻ. Thiết kế kết hợp khu sân ngoài trời lộng gió và phòng máy lạnh tiện nghi phục vụ cà phê, trà trái cây, matcha và bánh ngọt.',
    '1151 Nguyễn Tất Thành, Q. Thanh Khê, Đà Nẵng 50000',
    '06:00 - 22:00',
    '+84 399 511 151',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdRLcdHklnDEbsM2t__4AlH5omTdY9iv_RSD-g_v3jeLi8DjMeDetXYEhk2MGors4rZ0NYWenuuXxVr2JkMlg5ymlFJTpsjwWccV7uzqW3OC_kiK8G9sVZtKtnp9nKT4xvYRjeo1Cs9OAE=w426-h240-k-no',
    NULL,
    4.7,
    620,
    'seed/cafe-the-leaf-house',
    16.0731486,
    108.1868070,
    30000,
    65000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 38. MOR CÀ PHÊ (K385A/24 Nguyễn Văn Linh)
(
    'MOR CÀ PHÊ',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm cà phê nhỏ núp hẻm ngay khu vực Nguyễn Văn Linh mang phong cách vintage ấm cúng và đậm vị hoài niệm. Nổi tiếng với kỹ thuật cà phê vợt truyền thống, cà phê dừa nếp cẩm béo bùi, trà lựu hồng cùng các món ăn vặt nhẹ nhàng.',
    'K385A/24 Nguyễn Văn Linh, Q. Thanh Khê, Đà Nẵng 550000',
    '07:30 - 19:30',
    '+84 705 305 205',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcD69W5tv1zzT0PcPmE7lVy8Z7T_gQwimO9eLjjNLYXPd4c731oqy9_k9yF7dTeHQM-lEc1v_sshjAaEEEGYo9qxYL2Af-5hra7cZf6UEY5g8TeGrkn7mVo-1ye_5L4NnwnL5HWqbko--9x=w408-h305-k-no',
    NULL,
    4.4,
    226,
    'seed/cafe-mor-ca-phe',
    16.0583208,
    108.2070073,
    20000,
    65000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- 5. QUẬN CẨM LỆ (4 địa điểm)
-- -----------------------------------------------------------------------------

-- 39. La’s Cafe (36 Nguyễn Văn Thông, Hòa Xuân)
(
    'La’s Cafe',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm cà phê sân vườn xanh mát và yên tĩnh nổi bật tại khu đô thị Hòa Xuân, Cẩm Lệ. Quán được lòng khách địa phương nhờ không gian rộng thoáng nhiều cây xanh, phục vụ cà phê, trà trái cây và nước ép tươi với mức giá trần dễ chịu tối đa 45.000 đồng.',
    '36 Đ. Nguyễn Văn Thông, Hòa Xuân, Q. Cẩm Lệ, Đà Nẵng 840236',
    '06:30 - 22:00',
    '+84 943 747 599',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdw43501Sn9jVPu4YB2Mqkjtd_i9nuK2XikuXQeZP83WrMj13hgWJAyA0g4kHFVIRnA8xrnxbWpfUoIC-5WKMSXI0JtUD9TKhatzImx8xRRjEX1fuC11B5DOKdKynQy5b94baK8Xw=w425-h240-k-no',
    NULL,
    4.5,
    599,
    'seed/cafe-las-cafe-hoa-xuan',
    16.0198284,
    108.2222373,
    15000,
    45000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 40. Tiệm cà phê chú Mạnh (298/21 Cách Mạng Tháng 8)
(
    'Tiệm cà phê chú Mạnh',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê nhà vườn kiểu xưa ẩn mình trong con kiệt yên tĩnh đường Cách Mạng Tháng 8 đạt tới 4.9 sao đánh giá. Không gian gỗ mộc mạc có sân sau thoáng mát, thường xuyên tổ chức các buổi workshop vẽ tranh, làm nến vào dịp cuối tuần.',
    '298/21 Cách Mạng Tháng 8, Q. Cẩm Lệ, Đà Nẵng 550000',
    '06:00 - 22:30',
    '+84 349 051 850',
    'https://www.facebook.com/profile.php?id=100083278791776',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcGn52iWDWC1ZtyEWO4Hq4mb3DV_PLwm4AetTTxzqP0dOQfoBkREpzubk9nO5_NqC9lVdA4XFDJvIHcR78mGKn4OyBntI7FLRqV_LKi7EDUKAJoBksbaHZ-z8BNEeN6QBv9MSBa=w408-h408-k-no',
    NULL,
    4.9,
    316,
    'seed/cafe-tiem-ca-phe-chu-manh',
    16.0172861,
    108.2028716,
    20000,
    45000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 41. Dream House Coffee - Tiệm cà phê chill Hòa Xuân - Đà Nẵng (44 Bùi Thiện Ngộ)
(
    'Dream House Coffee - Tiệm cà phê chill Hòa Xuân - Đà Nẵng',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê nhẹ nhàng nổi tiếng tại khu đô thị Hòa Xuân với nhiều góc chụp ảnh xinh xắn và góc đọc sách thư giãn. Thực đơn nổi bật gồm cà phê muối, cacao nóng, matcha kem muối, trà trái cây và các hoạt động tô tượng cuối tuần.',
    '44 Bùi Thiện Ngộ, Hòa Xuân, Q. Cẩm Lệ, Đà Nẵng 550000',
    '07:00 - 22:00',
    '+84 337 127 467',
    'https://www.facebook.com/cafe.dreamhouse?mibextid=ZbWKwL',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfo8B7o4dmk1RUSd4UH2iEAxpZ33JWdfvul5TR5E1O2AGe4fUJRwXQTB_JXTNy4eTk1MuwQisWbWePWzYLdQjy1IZzC6YL19Ya59WoenPGrOVxtx95pIxF-mnwni5yCwmEt7IrT=w408-h544-k-no',
    NULL,
    4.5,
    232,
    'seed/cafe-dream-house-hoa-xuan',
    16.0149485,
    108.2174928,
    30000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 42. Ha Café (136 Trung Lương 9, Hòa Xuân)
(
    'Ha Café',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm cà phê sân vườn phong cách vintage an yên nằm tại khu Trung Lương, Hòa Xuân với điểm đánh giá ấn tượng 4.8 sao. Khuôn viên ngập sắc xanh dịu mát và yên ả, được yêu thích nhờ món cà phê muối đặc trưng và trà trái cây thanh nhẹ.',
    '136 Trung Lương 9, Hòa Xuân, Q. Cẩm Lệ, Đà Nẵng 55000',
    '07:00 - 18:00',
    '+84 919 551 317',
    'https://www.facebook.com/Hacafe.Hoaxuan?mibextid=LQQJ4d',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeC-E8fhbPran2hYs14LXcmBp6B1YF6ATSE9EfnqlYH5MBGvfXFXZYICTgHWlzzFI6OIY-rWZMdl2i2M3UPvDyh7xBN09OLkYQ_P69o0LP4rowGZsAfCR5XgmLb_IdgdQPeISkj=w408-h544-k-no',
    NULL,
    4.8,
    149,
    'seed/cafe-ha-cafe-hoa-xuan',
    16.0195923,
    108.2351918,
    20000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- 6. QUẬN LIÊN CHIỂU (4 địa điểm)
-- -----------------------------------------------------------------------------

-- 43. SaiGon Brown Coffee (1 Tân Trào)
(
    'SaiGon Brown Coffee',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê kết hợp ẩm thực quy mô lớn bậc nhất quận Liên Chiểu tại khu đô thị Phước Lý. Sở hữu không gian nhiều tầng sang trọng có hồ cá, phòng riêng và khu vui chơi trẻ em, phục vụ từ cà phê trứng, cà phê dừa đến cơm văn phòng và sinh tố.',
    '1 Tân Trào, Hòa Khánh, Q. Liên Chiểu, Đà Nẵng 550000',
    '06:30 - 22:30',
    '+84 1900 232747',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLewgOppWiNrHdNzMtd_TRjV-ezXd-xJxQqvcUzfYcWT3pbEpL-ChUQXUszN7spF-bt1Kxr-G_PGIZGpfxMwN0tGY0iwUAz92uPsv-6I1B5yrDw3OX3rMFOgJIp7qKloU4DxALReeQ=w408-h262-k-no',
    NULL,
    4.2,
    660,
    'seed/cafe-saigon-brown-lien-chieu',
    16.0602436,
    108.1744226,
    34000,
    82000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 44. Trạm 247 Study Cafe & Workspace CN Ninh Tốn (46 Ninh Tốn)
(
    'Trạm 247 Study Cafe & Workspace CN Ninh Tốn',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Không gian cà phê học tập và làm việc xuyên đêm 24/7 cực kỳ đông sinh viên các trường đại học khu vực Liên Chiểu. Trang bị đầy đủ bàn làm việc cá nhân, ổ cắm điện, wifi tốc độ cao cùng menu cà phê muối, trà sữa và đá xay giá phải chăng.',
    '46 Ninh Tốn, Q. Liên Chiểu, Đà Nẵng 550000',
    '00:00 - 24:00 (Mở cả ngày)',
    '+84 817 968 247',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeWmm3qtTwgZdolVzKfe9dVIhonkE4ngOWazJidZvqqk8OK-kxpdrUSSMDzKSVb81kQrdzrG2JnVCIINu7_6s3GeQl2YHdcp_4-N6-miVWbK9f1yqxNz46Lq-7r6oqx_2u0h_WZfRR-i3Q=w408-h306-k-no',
    NULL,
    4.4,
    206,
    'seed/cafe-tram-247-ninh-ton',
    16.0687491,
    108.1467266,
    25000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 45. THE POWERHOUSE 2 COFFEE & MORE (17 Âu Cơ)
(
    'THE POWERHOUSE 2 COFFEE & MORE',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê kiến trúc mái chóp độc đáo tọa lạc ngay ngã ba trục đường Âu Cơ sầm uất khu Hòa Khánh. Không gian mở hai mặt tiền thoáng mát nhiều cây xanh, nổi bật với cà phê pha máy, trà trái cây giải nhiệt và các đêm nhạc sôi động.',
    '17 Âu Cơ, Q. Liên Chiểu, Đà Nẵng 550000',
    '06:00 - 23:00',
    '+84 966 020 246',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLejwxG5F-rmcN-4XKawNMmX1T9-l2f1CGpibqqKlwxGpQr9sbc9B9EF-S0dbdCcxzXZumoWLBc_MJzu0Ih_Ppxfe0_AH44brT0PGo3Rkao9J0cDthNp1olbaQrA3hvMcMVI4w8O8g=w408-h543-k-no',
    NULL,
    4.6,
    411,
    'seed/cafe-the-powerhouse-2-au-co',
    16.0713011,
    108.1498415,
    25000,
    70000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 46. MÙA HÈ Study & Work Cafe (778 Tôn Đức Thắng)
(
    'MÙA HÈ Study & Work Cafe',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê học tập hai tầng khang trang trên mặt tiền đường Tôn Đức Thắng gần Đại học Bách Khoa Đà Nẵng. Bố trí khu tự học yên tĩnh có đèn dịu, bàn đơn và kệ sách đa dạng cùng thức uống matcha latte, cà phê và bánh ngọt mức giá sinh viên.',
    '778 Tôn Đức Thắng, Q. Liên Chiểu, Đà Nẵng 550000',
    '08:00 - 22:00',
    '+84 905 871 487',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLch8VUJocof94fnSRmiGkXR27x8DlxuJI66Xzz2KiKi06BWEJHreFNeIjaZRun9CIvW_54XAG3R9RoHK0AJOn7YG4tyca98FiGVSN3wj2RRhxCv6NO2bgmjUBKKZC4vam0S4teMllac1HFf=w408-h306-k-no',
    NULL,
    4.4,
    247,
    'seed/cafe-mua-he-study-work',
    16.0673733,
    108.1527166,
    20000,
    45000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- 7. HUYỆN HÒA VANG (4 địa điểm)
-- -----------------------------------------------------------------------------

-- 47. Tiệm Nhà Đô (Thôn Nam Yên, Hòa Bắc, Hòa Vang)
(
    'Tiệm Nhà Đô',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Tiệm cà phê đồng quê mộc mạc nằm lọt giữa thung lũng cánh đồng lúa và ao sen thanh bình tại xã Hòa Bắc, Hòa Vang. Điểm dừng chân chữa lành lý tưởng trên cung đường khám phá Tây Bắc Đà Nẵng với đồ uống bình dân và khung cảnh thiên nhiên lộng gió.',
    '42PX+7W8, Thôn Nam Yên, Hòa Bắc, H. Hòa Vang, Đà Nẵng',
    '06:00 - 22:00',
    '+84 775 188 134',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdEW459yqmU5SlQs9hN47c0QzMHBYRl0ohKbCccZM3f8Z776QhFKWepkbFkbN46WwEA_esZJ_OrcpBt-gEyIhMenN3l7grXE-KGoc5_WCDrCHSXB6wr8Lxj9UcEyCsZ1ejpt0SK=w531-h240-k-no',
    NULL,
    4.7,
    87,
    'seed/cafe-tiem-nha-do-hoa-bac',
    16.1356661,
    108.0498355,
    20000,
    35000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 48. Field Coffee (Thôn Phong Nam, Hòa Châu, Hòa Vang)
(
    'Field Coffee',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê đồng quê nổi tiếng nằm ẩn mình cạnh làng cổ Phong Nam (xã Hòa Châu, Hòa Vang) với tầm nhìn ôm trọn ruộng lúa xanh mướt và nếp nhà cổ hơn trăm tuổi. Phục vụ cà phê truyền thống, trà trái cây và nước ép tươi trong không gian lộng gió.',
    'Thôn Phong Nam, Phong Lệ, Hòa Châu, H. Hòa Vang, Đà Nẵng 550000',
    '05:00 - 23:00',
    '+84 903 515 645',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLecFrVNZv1u9w73Oo7KRvV8sIyqv5DsFBANWLeU9GYSC6zuu5IMDWNQsNnJEyFI1SiunJy11DK9MswTDCFvGSbl9qweLV6fADMUcLqf3H9uybwisQvbyIUwNqP6HEILQEoCPCKHtw=w408-h307-k-no',
    NULL,
    4.7,
    113,
    'seed/cafe-field-coffee-phong-nam',
    15.9811649,
    108.1909692,
    15000,
    40000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 49. Cafe Hương Lam Viên (QL14B, Hòa Tiến - Hòa Khương, Hòa Vang)
(
    'Cafe Hương Lam Viên',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Quán cà phê sân vườn rộng rãi tọa lạc ngay trên trục Quốc lộ 14B thuộc khu vực Hòa Tiến – Hòa Khương, Hòa Vang. Sở hữu khuôn viên nhiều cây xanh bóng mát thoáng đãng, phục vụ các loại cà phê truyền thống và nước giải khát bình dân.',
    'QL14B (X46Q+MRR), Hòa Tiến, H. Hòa Vang, Đà Nẵng',
    '07:00 - 23:00',
    '+84 905 280 946',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdZV4m7wocJZFnNkRJBx_1DL4rzEL0GxGlQjKNIGMWnz7JKtvKFXiM3xyLUiB5p-Mjq4e9GQTow-q6p9XYnP5Tj1CQIQ3xuM2JZeABrxS0BKiuGWp-lb38PlXAblqkWiOT5gIvX=w426-h240-k-no',
    NULL,
    4.2,
    77,
    'seed/cafe-huong-lam-vien-hoa-vang',
    15.9617469,
    108.1395109,
    10000,
    30000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 50. Bông Food & Drink Hoà Tiến (ĐT605, Lệ Sơn, Hòa Tiến, Hòa Vang)
(
    'Bông Food & Drink Hoà Tiến',
    (SELECT id FROM categories WHERE code = 'CAFE' LIMIT 1),
    'Chi nhánh Bông Food & Drink rất được giới trẻ khu vực Hòa Vang ưa chuộng với không gian ngoài trời thoáng đãng lung linh đèn dây và điểm đánh giá 4.8 sao. Thực đơn đa dạng trà sữa full topping, matcha kem sữa, trà trái cây và cà phê muối giá học sinh.',
    'ĐT605 (X58J+79Q), Lệ Sơn, Hòa Tiến, H. Hòa Vang, Đà Nẵng',
    '07:30 - 22:30',
    '+84 931 996 418',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLetGb0u4-Txc9ieM9njzCI_2zZkr349U_URiWEkPNZQbxUHq06-Gp7pO4ZuGkGOwnFj2rYx7ZLAOjhbSq4t6--jShKb39_l0-wvCLVejd4Sa5-ktF3r3jtvCE3ZQbwMUkQ49b6Le33jSPL2=w408-h576-k-no',
    NULL,
    4.8,
    356,
    'seed/cafe-bong-food-drink-hoa-tien',
    15.9655731,
    108.1807993,
    15000,
    45000,
    'ACTIVE',
    NOW(),
    NOW()
);
