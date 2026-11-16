-- =============================================================================
-- V5__seed_culture_destinations.sql
-- Seed 50 prominent CULTURE destinations covering all 7 mainland districts of Da Nang
-- Coordinates extracted directly from Google Maps POI pins (!3d<lat>!4d<lng>)
-- =============================================================================

INSERT INTO destinations (
    name,
    name_en,
    category_id,
    description,
    description_en,
    address,
    opening_hours,
    phone,
    website,
    image_url,
    sub_images,
    google_rating,
    google_review_count,
    visit_duration_minutes,
    osm_id,
    latitude,
    longitude,
    price_min_vnd,
    price_max_vnd,
    status,
    created_at,
    updated_at
) VALUES
-- =============================================================================
-- 1. QUẬN HẢI CHÂU (14 địa điểm)
-- =============================================================================

-- 1. Bảo Tàng Đà Nẵng (Cơ sở mới - 31 Trần Phú, P. Thạch Thang)
-- Google Maps: https://www.google.com/maps/place/B%E1%BA%A3o+T%C3%A0ng+%C4%90%C3%A0+N%E1%BA%B5ng/@16.0747441,108.2238426,17z/data=!3m1!4b1!4m6!3m5!1s0x3142183141fef901:0x1b1318fe00b2184b!8m2!3d16.0747441!4d108.2238426!16s%2Fm%2F09g8z0r?hl=vi
(
    'Bảo Tàng Đà Nẵng',
    'Da Nang Museum',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Bảo tàng lịch sử - văn hóa trọng điểm của thành phố tại tòa kiến trúc Pháp cổ (Tòa Đốc Lý xưa) bên bờ sông Hàn. Trưng bày hàng ngàn hiện vật, sa bàn và tư liệu hiện đại tái hiện lịch sử hình thành, văn hóa biển đảo và quá trình phát triển của Đà Nẵng.',
    'The flagship historical and cultural museum of Da Nang situated in a historic French colonial building by the Han River. Displays thousands of artifacts, topographical models, and modern exhibits portraying Da Nang''s formation, maritime culture, and development.',
    '31 Trần Phú, P. Thạch Thang, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"2": [[480, 690], [810, 1020]], "3": [[480, 690], [810, 1020]], "4": [[480, 690], [810, 1020]], "5": [[480, 690], [810, 1020]], "6": [[480, 690], [810, 1020]], "7": [[480, 690], [810, 1020]], "1": []}}',
    '+84 236 3886 236',
    'https://baotangdanang.vn',
    NULL,
    NULL,
    4.4,
    532,
    90,
    'seed/culture-bao-tang-da-nang',
    16.0747441,
    108.2238426,
    20000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 2. Bảo tàng Mỹ thuật Đà Nẵng (P. Thạch Thang)
-- Google Maps: https://www.google.com/maps/place/B%E1%BA%A3o+t%C3%A0ng+M%E1%BB%B9+thu%E1%BA%ADt+%C4%90%C3%A0+N%E1%BA%B5ng/@16.0722108,108.2185252,17z/data=!3m1!4b1!4m6!3m5!1s0x3142183733075d5f:0xbe8cb9a7164ff2cf!8m2!3d16.0722108!4d108.2185252!16s%2Fg%2F11b6x5g5j4?hl=vi
(
    'Bảo tàng Mỹ thuật Đà Nẵng',
    'Da Nang Fine Arts Museum',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Không gian trưng bày và bảo tồn các tác phẩm hội họa, điêu khắc, đồ họa mỹ thuật hiện đại cùng mỹ thuật dân gian truyền thống khu vực miền Trung - Tây Nguyên. Điểm tham quan giàu giá trị nghệ thuật ngay trung tâm thành phố.',
    'The premier modern art space of the Central and Western Highlands regions. Preserves and showcases over 1,000 valuable artworks including oil paintings, silk paintings, lacquer art, sculptures, and ethnic minority folk crafts.',
    '78 Lê Duẩn, P. Thạch Thang, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[480, 1020]], "2": [[480, 1020]], "3": [[480, 1020]], "4": [[480, 1020]], "5": [[480, 1020]], "6": [[480, 1020]], "7": [[480, 1020]]}}',
    '+84 236 3865 368',
    'https://vnfam.vn',
    NULL,
    NULL,
    4.6,
    1002,
    60,
    'seed/culture-bao-tang-my-thuat',
    16.0722108,
    108.2185252,
    20000,
    40000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 3. Đình Làng Hải Châu (P. Hải Châu I)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+L%C3%A0ng+H%E1%BA%A3i+Ch%C3%A2u/@16.0694158,108.2203004,17z/data=!3m1!4b1!4m6!3m5!1s0x3142183424d9d4f9:0xa7b9a52824cf4e7c!8m2!3d16.0694158!4d108.2203004!16s%2Fg%2F122x0815?hl=vi
(
    'Đình Làng Hải Châu',
    'Hai Chau Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử - Văn hóa cấp Quốc gia và là ngôi đình cổ nhất tại trung tâm Đà Nẵng, gắn với dấu tích hơn 500 năm mở cõi lập làng Hải Châu. Quần thể gồm đình chính, nhà thờ tiền hiền chư phái tộc và miếu Bà uy nghiêm.',
    'The oldest surviving village communal house in Da Nang, recognized as a National Historical Monument. Features traditional multi-compartment wooden architecture, ancient banyan trees, and tranquil courtyards commemorating ancestors who founded Da Nang.',
    'K42/12 Phan Châu Trinh, P. Hải Châu I, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1080]], "2": [[360, 1080]], "3": [[360, 1080]], "4": [[360, 1080]], "5": [[360, 1080]], "6": [[360, 1080]], "7": [[360, 1080]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.6,
    67,
    45,
    'seed/culture-dinh-lang-hai-chau',
    16.0694158,
    108.2203004,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 4. Giáo Xứ Chính Toà Đà Nẵng - Nhà thờ Con Gà (P. Hải Châu I)
-- Google Maps: https://www.google.com/maps/place/Gi%C3%A1o+X%E1%BB%A9+Ch%C3%ADnh+To%C3%A0+%C4%90%C3%A0+N%E1%BA%B5ng/@16.066708,108.2234057,17z/data=!3m1!4b1!4m6!3m5!1s0x314218324e934333:0x1b45dae8ceee97f1!8m2!3d16.066708!4d108.2234057!16zL20vMGI5eG56?hl=vi
(
    'Giáo Xứ Chính Toà Đà Nẵng (Nhà thờ Con Gà)',
    'Da Nang Cathedral (Pink Church)',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Công trình kiến trúc Gothic cổ điển biểu tượng của Đà Nẵng khánh thành năm 1924, nổi bật với sắc hồng phấn đặc trưng, các vòm cửa kính màu và tượng gà trống trên đỉnh tháp chuông cao gần 70m.',
    'A historic Gothic cathedral constructed in 1923 featuring pastel pink facades, stained-glass windows, and a distinctive rooster weather vane atop the bell tower. A beloved architectural and spiritual landmark in central Da Nang.',
    '156 Trần Phú, P. Hải Châu I, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[480, 690], [810, 990]], "2": [[480, 690], [810, 990]], "3": [[480, 690], [810, 990]], "4": [[480, 690], [810, 990]], "5": [[480, 690], [810, 990]], "6": [[480, 690], [810, 990]], "7": []}}',
    '+84 236 3825 285',
    'https://giaoxuchinhtoadanang.org',
    NULL,
    NULL,
    4.4,
    7458,
    45,
    'seed/culture-nha-tho-con-ga',
    16.0667080,
    108.2234057,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 5. Nhà Hát Trưng Vương (P. Hải Châu I)
-- Google Maps: https://www.google.com/maps/place/Nh%C3%A0+H%C3%A1t+Tr%C6%B0ng+V%C6%B0%C6%A1ng/@16.0690026,108.2201944,17z/data=!3m1!4b1!4m6!3m5!1s0x31421836a9926c8b:0x52c9fe8713d964f4!8m2!3d16.0690026!4d108.2201944!16s%2Fg%2F121k79q7?hl=vi
(
    'Nhà Hát Trưng Vương',
    'Trung Vuong Theater',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Nhà hát nghệ thuật biểu tượng giữa lòng thành phố với lịch sử lâu đời, nơi thường xuyên diễn ra các chương trình ca múa nhạc dân tộc, giao hưởng, kịch nói và sự kiện văn hóa lớn của Đà Nẵng.',
    'The city''s central performing arts theater, hosting prominent symphonic concerts, cultural performances, traditional plays, and major civic events.',
    '86 Hùng Vương, P. Hải Châu I, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[450, 1020]], "2": [[450, 1020]], "3": [[450, 1020]], "4": [[450, 1020]], "5": [[450, 1020]], "6": [[450, 1020]], "7": [[450, 1020]]}}',
    '+84 236 3810 515',
    NULL,
    NULL,
    NULL,
    4.4,
    1213,
    60,
    'seed/culture-nha-hat-trung-vuong',
    16.0690026,
    108.2201944,
    0,
    200000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 6. Chùa Bát Nhã (P. Hải Châu II)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+B%C3%A1t+Nh%C3%A3/@16.0628325,108.2180846,17z/data=!3m1!4b1!4m6!3m5!1s0x314219cc03328ce7:0xc68e42f9b177983f!8m2!3d16.0628325!4d108.2180846!16s%2Fg%2F11b8td5jfl?hl=vi
(
    'Chùa Bát Nhã',
    'Bat Nha Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa Phật giáo Bắc tông lâu năm nằm giữa khu phố trung tâm sầm uất nhưng giữ được không gian trang nghiêm, thanh tịnh. Kiến trúc chùa hài hòa với chính điện rộng rãi, là điểm chiêm bái quen thuộc của Phật tử và du khách.',
    'A peaceful Mahayana Buddhist temple on Trieu Nu Vuong Street with solemn architecture, lush bonsai gardens, and serene chanting atmospheres.',
    '176 Triệu Nữ Vương, P. Hải Châu II, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1260]], "2": [[360, 1260]], "3": [[360, 1260]], "4": [[360, 1260]], "5": [[360, 1260]], "6": [[360, 1260]], "7": [[360, 1260]]}}',
    NULL,
    'https://facebook.com/chuabatnhadn',
    NULL,
    NULL,
    4.7,
    389,
    45,
    'seed/culture-chua-bat-nha',
    16.0628325,
    108.2180846,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 7. Bảo tàng Điêu khắc Chăm Đà Nẵng (P. Bình Hiên / P. Phước Ninh)
-- Google Maps: https://www.google.com/maps/place/B%E1%BA%A3o+t%C3%A0ng+%C4%90i%C3%AAu+kh%E1%BA%AFc+Ch%C4%83m+%C4%90%C3%A0+N%E1%BA%B5ng/@16.0601362,108.2234479,17z/data=!3m1!4b1!4m6!3m5!1s0x314219d35cb67035:0x868b41e86095039f!8m2!3d16.0601362!4d108.2234479!16s%2Fm%2F0407pbf?hl=vi
(
    'Bảo tàng Điêu khắc Chăm Đà Nẵng',
    'Da Nang Museum of Cham Sculpture',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Bảo tàng nghệ thuật điêu khắc Chăm Pa quy mô lớn và độc đáo nhất thế giới, được người Pháp xây dựng từ năm 1915. Nơi lưu giữ hàng trăm hiện vật sa thạch và nhiều bảo vật quốc gia từ Trà Kiệu, Mỹ Sơn, Đồng Dương.',
    'The world''s foremost museum of Champa sculptural art, established in 1915. Houses hundreds of sandstone and terracotta masterpieces from the 7th to 15th centuries depicting Hindu deities, mythical creatures, and ancient altars.',
    'Số 02 Đường 2 Tháng 9, P. Bình Hiên, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[450, 1020]], "2": [[450, 1020]], "3": [[450, 1020]], "4": [[450, 1020]], "5": [[450, 1020]], "6": [[450, 1020]], "7": [[450, 1020]]}}',
    '+84 236 3572 935',
    'https://chammuseum.vn',
    NULL,
    NULL,
    4.4,
    8150,
    90,
    'seed/culture-bao-tang-cham',
    16.0601362,
    108.2234479,
    20000,
    60000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 8. Nhà Hát Tuồng Nguyễn Hiển Dĩnh (P. Phước Ninh)
-- Google Maps: https://www.google.com/maps/place/Nh%C3%A0+H%C3%A1t+Tu%E1%BB%93ng+Nguy%E1%BB%85n+Hi%E1%BB%83n+D%C4%A9nh/@16.0645624,108.2204561,17z/data=!3m1!4b1!4m6!3m5!1s0x31421832d20e77d3:0x1b45daecff7aa811!8m2!3d16.0645624!4d108.2204561!16s%2Fg%2F11bc596qdf?hl=vi
(
    'Nhà Hát Tuồng Nguyễn Hiển Dĩnh',
    'Nguyen Hien Dinh Classical Drama Theater',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Đơn vị nghệ thuật truyền thống bảo tồn và trình diễn Di sản nghệ thuật Tuồng cổ xứ Quảng. Du khách có thể thưởng thức trích đoạn tuồng kinh điển, hòa tấu nhạc cụ dân tộc và khám phá nghệ thuật vẽ mặt nạ tuồng đặc sắc.',
    'The premier stage dedicated to preserving Tuong (traditional Vietnamese classical opera), featuring colorful heritage performances, traditional makeup displays, and folk instruments.',
    '155 Phan Châu Trinh, P. Phước Ninh, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[450, 1020]], "2": [[450, 1020]], "3": [[450, 1020]], "4": [[450, 1020]], "5": [[450, 1020]], "6": [], "7": []}}',
    '+84 236 3561 292',
    'https://tuongnguyenhiendinhdanang.vn',
    NULL,
    NULL,
    4.4,
    193,
    60,
    'seed/culture-nha-hat-tuong',
    16.0645624,
    108.2204561,
    0,
    150000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 9. Chùa Pháp Lâm (P. Nam Dương)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Ph%C3%A1p+L%C3%A2m/@16.060377,108.2137684,17z/data=!3m1!4b1!4m6!3m5!1s0x314219cfa88db253:0xfcf29eb10a20bf77!8m2!3d16.060377!4d108.2137684!16s%2Fg%2F12239d_6?hl=vi
(
    'Chùa Pháp Lâm',
    'Phap Lam Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Danh lam cổ tự trung tâm đồng thời là trụ sở Ban Trị sự Giáo hội Phật giáo TP. Đà Nẵng. Khuôn viên rộng thoáng rợp bóng cây xanh cùng chánh điện tôn nghiêm và tượng Phật Thích Ca cao lớn uy nghi.',
    'The headquarters of the Buddhist Sangha of Da Nang, featuring a grand two-story sanctum, an imposing outdoor Buddha statue, and lush sacred grounds.',
    '574 Ông Ích Khiêm, P. Nam Dương, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1260]], "2": [[360, 1260]], "3": [[360, 1260]], "4": [[360, 1260]], "5": [[360, 1260]], "6": [[360, 1260]], "7": [[360, 1260]]}}',
    '+84 236 3827 758',
    NULL,
    NULL,
    NULL,
    4.6,
    642,
    45,
    'seed/culture-chua-phap-lam',
    16.0603770,
    108.2137684,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 10. Chùa Tam Bảo Theravāda (P. Bình Hiên / P. Nam Dương)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Tam+B%E1%BA%A3o+Therav%C4%81da/@16.0581626,108.2195083,17z/data=!3m1!4b1!4m6!3m5!1s0x314219c9570392cd:0x9208108324cc424d!8m2!3d16.0581626!4d108.2195083!16s%2Fg%2F1v_skqzf?hl=vi
(
    'Chùa Tam Bảo Theravāda',
    'Tam Bao Theravada Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Tổ đình Phật giáo Nguyên thủy Nam tông tại miền Trung với kiến trúc tháp vàng mang đậm phong cách Thái Lan - Myanmar - Lào. Ngôi chùa lưu giữ hai cây bồ đề chiết từ Ấn Độ và thu hút nhiều du khách quốc tế tham quan.',
    'The solitary Theravada Buddhist monastery in Da Nang, notable for Southeast Asian architectural elements, a sacred Bodhi tree brought from Bodh Gaya, and tranquil meditation halls.',
    '323 Phan Châu Trinh, P. Bình Hiên, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1200]], "2": [[360, 1200]], "3": [[360, 1200]], "4": [[360, 1200]], "5": [[360, 1200]], "6": [[360, 1200]], "7": [[360, 1200]]}}',
    '+84 906 435 827',
    'https://m.facebook.com/chuatambaodanang/',
    NULL,
    NULL,
    4.7,
    175,
    45,
    'seed/culture-chua-tam-bao',
    16.0581626,
    108.2195083,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 11. Chùa An Long (P. Bình Hiên)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+An+Long/@16.0597945,108.223266,17z/data=!3m1!4b1!4m6!3m5!1s0x314219cdb5d22801:0x90f009217c50c87f!8m2!3d16.0597945!4d108.223266!16s%2Fg%2F1tff0j3r?hl=vi
(
    'Chùa An Long',
    'An Long Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa cổ nằm ngay sau Bảo tàng Điêu khắc Chăm và đầu Cầu Rồng, lưu giữ Di tích Lịch sử cấp Quốc gia "Bia chùa Long Thủ" dựng năm 1653 — tấm bia đá cổ xưa nhất còn tồn tại ở Đà Nẵng.',
    'A sacred ancient pagoda nestled near the western approach of the Dragon Bridge, preserving historic stele and honoring river maritime deities.',
    '4 Đường 2 Tháng 9, P. Bình Hiên, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1200]], "2": [[360, 1200]], "3": [[360, 1200]], "4": [[360, 1200]], "5": [[360, 1200]], "6": [[360, 1200]], "7": [[360, 1200]]}}',
    '+84 236 3574 473',
    NULL,
    NULL,
    NULL,
    4.5,
    147,
    30,
    'seed/culture-chua-an-long',
    16.0597945,
    108.2232660,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 12. Chùa Phổ Đà (P. Bình Thuận)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Ph%E1%BB%95+%C4%90%C3%A0/@16.057398,108.2185255,17z/data=!3m1!4b1!4m6!3m5!1s0x314219c9b13aa509:0xd837936a29792040!8m2!3d16.057398!4d108.2185255!16s%2Fg%2F120r_3sq?hl=vi
(
    'Chùa Phổ Đà',
    'Pho Da Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Cổ tự thành lập từ năm 1915 bởi Hòa thượng Thích Tôn Thắng và là nơi đặt Trường Trung cấp Phật học Đà Nẵng. Kiến trúc Á Đông cổ kính nổi bật với bảo tháp và không gian yên bình giữa lòng đô thị.',
    'A major Buddhist center and monastic academy in central Da Nang, renowned for its towering Avalokiteshvara shrine and classical pagoda architecture.',
    '340 Phan Châu Trinh, P. Bình Thuận, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1260]], "2": [[360, 1260]], "3": [[360, 1260]], "4": [[360, 1260]], "5": [[360, 1260]], "6": [[360, 1260]], "7": [[360, 1260]]}}',
    '+84 906 553 928',
    NULL,
    NULL,
    NULL,
    4.6,
    192,
    45,
    'seed/culture-chua-pho-da',
    16.0573980,
    108.2185255,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 13. Bảo tàng Hồ Chí Minh - Chi nhánh Quân khu 5 (P. Hòa Cường Bắc)
-- Google Maps: https://www.google.com/maps/place/B%E1%BA%A3o+t%C3%A0ng+H%E1%BB%93+Ch%C3%AD+Minh/@16.0486814,108.217581,17z/data=!3m1!4b1!4m6!3m5!1s0x314219c69cf3c7a3:0x2927993f5153d336!8m2!3d16.0486814!4d108.217581!16s%2Fm%2F011py73s?hl=vi
(
    'Bảo tàng Hồ Chí Minh (Chi nhánh Quân khu 5)',
    'Ho Chi Minh Museum (Military Zone 5 Branch)',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Bảo tàng lịch sử quân sự và lưu niệm Chủ tịch Hồ Chí Minh quy mô lớn nhất miền Trung, nổi bật với mô hình nhà sàn, ao cá Bác Hồ theo tỷ lệ nguyên bản cùng khu trưng bày ngoài trời máy bay, xe tăng lịch sử.',
    'A prominent military history museum exhibiting historical aircraft, tanks, artillery, and an accurate replica of President Ho Chi Minh''s Hanoi stilt house and fish pond.',
    '3 Duy Tân, P. Hòa Cường Bắc, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[480, 690], [810, 990]], "2": [[480, 690], [810, 990]], "3": [[480, 690], [810, 990]], "4": [[480, 690], [810, 990]], "5": [[480, 690], [810, 990]], "6": [[480, 690], [810, 990]], "7": [[480, 690], [810, 990]]}}',
    '+84 24 3845 5435',
    'https://baotanghochiminh.vn',
    NULL,
    NULL,
    4.3,
    1642,
    75,
    'seed/culture-bao-tang-ho-chi-minh-qk5',
    16.0486814,
    108.2175810,
    0,
    20000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 14. Đình làng Nại Nam (P. Hòa Cường Bắc)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+l%C3%A0ng+N%E1%BA%A1i+Nam/@16.0370977,108.2274566,17z/data=!3m1!4b1!4m6!3m5!1s0x314219e87de7febb:0x5d8609a9b3081ccf!8m2!3d16.0370977!4d108.2274566!16s%2Fg%2F1pzyfxlmw?hl=vi
(
    'Đình làng Nại Nam',
    'Nai Nam Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Kiến trúc Nghệ thuật - Lịch sử cấp Quốc gia khởi dựng năm Ất Tỵ (1905) bên Cung thể thao Tiên Sơn. Giữ nguyên kết cấu vì kèo gỗ chạm khắc tinh xảo thời Nguyễn và là trung tâm lễ hội truyền thống vùng Hòa Cường.',
    'An ancient communal house dating back to the Nguyen Dynasty, honoring local village pioneers and preserving traditional architectural carvings.',
    'Đường Nam Sơn 1, P. Hòa Cường Bắc, Q. Hải Châu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.4,
    40,
    30,
    'seed/culture-dinh-lang-nai-nam',
    16.0370977,
    108.2274566,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- =============================================================================
-- 2. QUẬN THANH KHÊ (5 địa điểm)
-- =============================================================================

-- 15. Tượng đài Mẹ Nhu (P. Hòa Khê)
-- Google Maps: https://www.google.com/maps/place/T%C6%B0%E1%BB%A3ng+%C4%91%C3%A0i+M%E1%BA%B9+Nhu/@16.0652433,108.1833896,17z/data=!3m1!4b1!4m6!3m5!1s0x314219087ae08215:0x9472c9ae70460c83!8m2!3d16.0652433!4d108.1833896!16s%2Fg%2F11b7jhmt4k?hl=vi
(
    'Tượng đài Mẹ Nhu',
    'Mother Nhu Monument',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Công trình điêu khắc lịch sử biểu tượng của quận Thanh Khê cao gần 12m đúc từ vỏ đạn đồng do nhà điêu khắc Phạm Văn Hạng sáng tác, tôn vinh Mẹ VNAH Lê Thị Dảnh (Mẹ Nhu) và 7 Dũng sĩ Thanh Khê năm 1968.',
    'A monument constructed from bronze bullet casings commemorating Mother Nhu and heroic Da Nang mothers who harbored revolutionary soldiers during wartime.',
    'Ngã ba Điện Biên Phủ - Huỳnh Ngọc Huệ, P. Hòa Khê, Q. Thanh Khê, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.6,
    2137,
    30,
    'seed/culture-tuong-dai-me-nhu',
    16.0652433,
    108.1833896,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 16. Đình làng Thạc Gián (P. Chính Gián)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+l%C3%A0ng+Th%E1%BA%A1c+Gi%C3%A1n/@16.0678329,108.2059621,17z/data=!3m1!4b1!4m6!3m5!1s0x314219b205a03081:0xa017ffbbfc29b06b!8m2!3d16.0678329!4d108.2059621!16s%2Fg%2F11gj71593_?hl=vi
(
    'Đình làng Thạc Gián',
    'Thac Gian Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Kiến trúc Nghệ thuật cấp Quốc gia (2007) mang giá trị tiêu biểu bậc nhất về kiến trúc đình làng thế kỷ XIX tại Đà Nẵng. Lưu giữ hàng chục sắc phong triều Nguyễn, giếng cổ và không gian nhà bia tiền hiền cổ kính.',
    'A historic village communal house preserving valuable royal imperial edicts and hosting festive spring and autumn ancestral ceremonies.',
    'K478 Lê Duẩn (thông K478 Điện Biên Phủ), P. Chính Gián, Q. Thanh Khê, Đà Nẵng',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    5.0,
    5,
    30,
    'seed/culture-dinh-lang-thac-gian',
    16.0678329,
    108.2059621,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 17. Nhà thờ Chính Trạch (P. Tân Chính)
-- Google Maps: https://www.google.com/maps/place/Nh%C3%A0+th%E1%BB%9D+Ch%C3%ADnh+Tr%E1%BA%A1ch/@16.0683058,108.2115162,17z/data=!3m1!4b1!4m6!3m5!1s0x3142183569578279:0x1b5592182fc657c9!8m2!3d16.0683058!4d108.2115162!16s%2Fg%2F1tcxc1cf?hl=vi
(
    'Nhà thờ Chính Trạch',
    'Chinh Trach Church',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Công trình tôn giáo Công giáo nổi bật gần khu vực Ga Đà Nẵng với kiến trúc thanh lịch, khang trang, là điểm sinh hoạt văn hóa tín ngưỡng lâu đời của giáo dân trung tâm quận Thanh Khê.',
    'A historic parish church on Ha Huy Tap Street serving the Catholic community with tranquil prayer grounds and stained-glass sanctuaries.',
    '68 Hoàng Hoa Thám, P. Tân Chính, Q. Thanh Khê, Đà Nẵng',
    NULL,
    '+84 236 3751 228',
    NULL,
    NULL,
    NULL,
    4.8,
    60,
    30,
    'seed/culture-nha-tho-chinh-trach',
    16.0683058,
    108.2115162,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 18. Chùa thạch quang (P. Xuân Hà)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+th%E1%BA%A1ch+quang/@16.0713002,108.201011,17z/data=!3m1!4b1!4m6!3m5!1s0x3142199aa0abfc07:0x72adf405521ee424!8m2!3d16.0713002!4d108.201011!16s%2Fg%2F11sv2v2z6x?hl=vi
(
    'Chùa thạch quang',
    'Thach Quang Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa Phật giáo mang nét kiến trúc cổ truyền Bắc bộ tọa lạc gần bờ vịnh Đà Nẵng, không gian yên tĩnh, thanh tịnh và được người dân địa phương lẫn khách hành hương đánh giá cao.',
    'A serene neighborhood Buddhist temple in Thanh Khe, offering a quiet oasis for meditation, floral offerings, and spiritual reflection.',
    '60 Tôn Thất Đạm, P. Xuân Hà, Q. Thanh Khê, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[300, 1260]], "2": [[300, 1260]], "3": [[300, 1260]], "4": [[300, 1260]], "5": [[300, 1260]], "6": [[300, 1260]], "7": [[300, 1260]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.5,
    43,
    30,
    'seed/culture-chua-thach-quang',
    16.0713002,
    108.2010110,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 19. Chùa Thuận Thành (P. Tam Thuận)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Thu%E1%BA%ADn+Th%C3%A0nh/@16.0744137,108.2085853,17z/data=!3m1!4b1!4m6!3m5!1s0x31421848ce3d7d69:0xdd0c8037d8e8da0a!8m2!3d16.0744137!4d108.2085853!16s%2Fg%2F1tlmktb1?hl=vi
(
    'Chùa Thuận Thành',
    'Thuan Thanh Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa Phật giáo Bắc truyền lâu đời gắn liền với đời sống tinh thần của làng cổ Thuận Phước - Tam Thuận bên vịnh Đà Nẵng, nổi bật với các sinh hoạt lễ hội Phật Đản và Vu Lan truyền thống.',
    'A traditional Buddhist pagoda in Thanh Khe with red-tiled curved roofs and lush bonsai courtyards.',
    'K112/5 Trần Cao Vân, P. Tam Thuận, Q. Thanh Khê, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1260]], "2": [[360, 1260]], "3": [[360, 1260]], "4": [[360, 1260]], "5": [[360, 1260]], "6": [[360, 1260]], "7": [[360, 1260]]}}',
    '+84 702 524 567',
    NULL,
    NULL,
    NULL,
    4.3,
    33,
    30,
    'seed/culture-chua-thuan-thanh',
    16.0744137,
    108.2085853,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- =============================================================================
-- 3. QUẬN SƠN TRÀ (7 địa điểm)
-- =============================================================================

-- 20. Chùa Linh Ứng - Bãi Bụt (P. Thọ Quang)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Linh+%E1%BB%A8ng+-+B%C3%A3i+B%E1%BB%A5t/@16.1001422,108.2776856,17z/data=!3m1!4b1!4m6!3m5!1s0x31421714bcde09ab:0x876f18dd18322c36!8m2!3d16.1001422!4d108.2776856!16s%2Fg%2F11c6z26v22
(
    'Chùa Linh Ứng - Bãi Bụt',
    'Linh Ung Pagoda - Bai But',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa lớn nhất và linh thiêng bậc nhất trên bán đảo Sơn Trà thuộc quần thể "Tam Linh Ứng tự". Nổi bật với tượng Phật Quán Thế Âm cao 67m hướng ra Biển Đông cùng tầm nhìn toàn cảnh vịnh Đà Nẵng tuyệt đẹp.',
    'The magnificent Buddhist sanctuary crowning Son Tra Peninsula, renowned for the colossal 67-meter white marble Lady Buddha statue gazing out over Da Nang bay.',
    'Vườn Lâm Tỳ Ni, Đường Hoàng Sa, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1260]], "2": [[360, 1260]], "3": [[360, 1260]], "4": [[360, 1260]], "5": [[360, 1260]], "6": [[360, 1260]], "7": [[360, 1260]]}}',
    '+84 236 3944 044',
    'http://chualinhungsontra.vn/',
    NULL,
    NULL,
    4.7,
    3816,
    90,
    'seed/culture-chua-linh-ung-bai-but',
    16.1001422,
    108.2776856,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 21. Bảo tàng Đồng Đình (P. Thọ Quang)
-- Google Maps: https://www.google.com/maps/place/B%E1%BA%A3o+t%C3%A0ng+%C4%90%E1%BB%93ng+%C4%90%C3%ACnh/@16.0963574,108.2741998,17z/data=!3m1!4b1!4m6!3m5!1s0x31421713d94b0d01:0x22ce67448d3db863!8m2!3d16.0963574!4d108.2741998!16s%2Fg%2F1tdr2t9s
(
    'Bảo tàng Đồng Đình',
    'Dong Dinh Museum',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Được ví như "Khu vườn ký ức" nằm ẩn mình dưới tán rừng nguyên sinh bán đảo Sơn Trà. Bảo tàng tư nhân này kết hợp kiến trúc nhà rường cổ truyền với bộ sưu tập cổ vật Sa Huỳnh, Chăm Pa, Đại Việt và mỹ thuật đương đại.',
    'A unique eco-cultural boutique museum set amidst the green forest canopy of Son Tra, showcasing antique pottery, fishing village artifacts, and contemporary art.',
    'Suối Bụt, Đường Hoàng Sa, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[480, 1020]], "2": [[480, 1020]], "3": [[480, 1020]], "4": [[480, 1020]], "5": [[480, 1020]], "6": [[480, 1020]], "7": [[480, 1020]]}}',
    '+84 905 419 619',
    'https://dongdinh.art/',
    NULL,
    NULL,
    4.3,
    662,
    75,
    'seed/culture-bao-tang-dong-dinh',
    16.0963574,
    108.2741998,
    0,
    35000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 22. Nhà Trưng bày Hoàng Sa (P. Thọ Quang)
-- Google Maps: https://www.google.com/maps/place/Nh%C3%A0+Tr%C6%B0ng+b%C3%A0y+Ho%C3%A0ng+Sa/@16.0970929,108.2464731,17z/data=!3m1!4b1!4m6!3m5!1s0x314217f0a9d18b6b:0x59aa8da6bb84eaeb!8m2!3d16.0970929!4d108.2464731!16s%2Fg%2F11b6mty9r3
(
    'Nhà Trưng bày Hoàng Sa',
    'Hoang Sa Exhibition House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Thiết chế văn hóa - lịch sử đặc biệt trưng bày bản đồ cổ, châu bản triều Nguyễn và hiện vật khẳng định chủ quyền lịch sử, pháp lý của Việt Nam đối với quần đảo Hoàng Sa cùng kiến trúc hình con dấu chủ quyền ấn tượng.',
    'An architecturally modern exhibition center displaying historical maps, royal administrative records, and maritime artifacts affirming Vietnam''s sovereignty over the Paracel Islands.',
    'Ngã ba Hoàng Sa - Phan Bá Phiến, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"2": [[480, 690], [810, 1050]], "3": [[480, 690], [810, 1050]], "4": [[480, 690], [810, 1050]], "5": [[480, 690], [810, 1050]], "6": [[480, 690], [810, 1050]], "7": [[480, 690], [810, 1050]], "1": []}}',
    '+84 236 3689 923',
    'http://hoangsa.danang.gov.vn/',
    NULL,
    NULL,
    4.8,
    340,
    60,
    'seed/culture-nha-trung-bay-hoang-sa',
    16.0970929,
    108.2464731,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 23. Chùa An Hải (P. An Hải Bắc)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+An+H%E1%BA%A3i/@16.0679048,108.2330077,17z/data=!3m1!4b1!4m6!3m5!1s0x31421960adc847db:0x5d68fb509b09f9d8!8m2!3d16.0679048!4d108.2330077!16s%2Fg%2F11g0m3zljy
(
    'Chùa An Hải',
    'An Hai Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Một trong những ngôi cổ tự lâu đời nhất vùng tả ngạn sông Hàn gắn liền với lịch sử làng An Hải xưa và di tích kháng chiến chống Pháp thế kỷ XIX, thu hút du khách và Phật tử tới chiêm bái.',
    'A revered ancient temple on Son Tra Peninsula founded during the Nguyen Dynasty, preserving ancient bell towers and solemn stone sculptures.',
    'K37/2 Nguyễn Công Trứ, P. An Hải Bắc, Q. Sơn Trà, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1200]], "2": [[360, 1200]], "3": [[360, 1200]], "4": [[360, 1200]], "5": [[360, 1200]], "6": [[360, 1200]], "7": [[360, 1200]]}}',
    '+84 236 3844 733',
    NULL,
    NULL,
    NULL,
    4.6,
    49,
    30,
    'seed/culture-chua-an-hai',
    16.0679048,
    108.2330077,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 24. Nhà thờ Tin Lành An Hải (P. An Hải Đông)
-- Google Maps: https://www.google.com/maps/place/Nh%C3%A0+th%E1%BB%9D+Tin+L%C3%A0nh+An+H%E1%BA%A3i/@16.0630696,108.2356701,17z/data=!3m1!4b1!4m6!3m5!1s0x3142182ad29b1115:0x45658daf4430d2d6!8m2!3d16.0630696!4d108.2356701!16s%2Fg%2F11b67rskfj
(
    'Nhà thờ Tin Lành An Hải',
    'An Hai Protestant Church',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Cơ sở tôn giáo Tin Lành lịch sử có kiến trúc khang trang và nhận được điểm đánh giá rất cao tại quận Sơn Trà, điểm nhấn văn hóa tâm linh gần trục Cầu Rồng hướng ra biển Mỹ Khê.',
    'A distinguished Protestant church in Son Tra featuring graceful mid-century architecture and community fellowship services.',
    '55 Phạm Cự Lượng, P. An Hải Đông, Q. Sơn Trà, Đà Nẵng',
    NULL,
    '+84 236 3831 462',
    'https://difvn.org/connect/',
    NULL,
    NULL,
    4.9,
    37,
    30,
    'seed/culture-nha-tho-tin-lanh-an-hai',
    16.0630696,
    108.2356701,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 25. Đình Làng Phước Trường (P. Phước Mỹ)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+L%C3%A0ng+Ph%C6%B0%E1%BB%9Bc+Tr%C6%B0%E1%BB%9Dng/@16.0718698,108.2435586,17z/data=!3m1!4b1!4m6!3m5!1s0x314217804470c1d1:0x41ba9633ff28f73d!8m2!3d16.0718698!4d108.2435586!16s%2Fg%2F11b7zbb122
(
    'Đình Làng Phước Trường',
    'Phuoc Truong Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử cấp Thành phố có tuổi đời hơn 400 năm ngay gần bãi biển Mỹ Khê, gắn với cộng đồng ngư dân cổ Phước Trường và lưu giữ căn hầm bí mật cách mạng ngay trong khuôn viên đình.',
    'A coastal village communal house celebrating seafaring heritage, traditional whale worship rituals, and local ancestral benefactors.',
    'Đường Lê Mạnh Trinh, P. Phước Mỹ, Q. Sơn Trà, Đà Nẵng',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    4.6,
    21,
    30,
    'seed/culture-dinh-lang-phuoc-truong',
    16.0718698,
    108.2435586,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 26. Nhà thờ Tiền hiền Làng An Hải và Thoại Ngọc Hầu (P. An Hải Tây)
-- Google Maps: https://www.google.com/maps/place/Nh%C3%A0+th%E1%BB%9D+Ti%E1%BB%81n+hi%E1%BB%81n+L%C3%A0ng+An+H%E1%BA%A3i+v%C3%A0+Tho%E1%BA%A1i+Ng%E1%BB%8Dc+H%E1%BA%A7u/@16.0589495,108.2315935,17z/data=!3m1!4b1!4m6!3m5!1s0x314219d3f51ca33b:0x8e889e299c97e857!8m2!3d16.0589495!4d108.2315935!16s%2Fg%2F11fxzj4hq8
(
    'Nhà thờ Tiền hiền Làng An Hải và Thoại Ngọc Hầu',
    'An Hai Village Ancestral Hall & Thoai Ngoc Hau Shrine',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử - Văn hóa cấp Quốc gia tọa lạc ngay khu vực bờ Đông Cầu Rồng, nơi phụng tự tiền hiền 36 chư phái tộc lập làng An Hải và tưởng niệm danh tướng Thoại Ngọc Hầu — người con kiệt xuất quê hương Đà Nẵng.',
    'A designated historical relic honoring General Thoai Ngoc Hau and village founders who made profound contributions to southern territorial exploration and canal building.',
    '15 Hà Thị Thân, P. An Hải Tây, Q. Sơn Trà, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[420, 1020]], "2": [[420, 1020]], "3": [[420, 1020]], "4": [[420, 1020]], "5": [[420, 1020]], "6": [[420, 1020]], "7": [[420, 1020]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.5,
    18,
    45,
    'seed/culture-thoai-ngoc-hau-an-hai',
    16.0589495,
    108.2315935,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- =============================================================================
-- 4. QUẬN NGŨ HÀNH SƠN (7 địa điểm)
-- =============================================================================

-- 27. Danh thắng Ngũ Hành Sơn (P. Hòa Hải)
-- Google Maps: https://www.google.com/maps/place/Danh+th%E1%BA%AFng+Ng%C5%A9+H%C3%A0nh+S%C6%A1n/@16.0037104,108.2631605,17z/data=!3m1!4b1!4m6!3m5!1s0x314210959f6ad827:0x4d5b248a3cbb5848!8m2!3d16.0037104!4d108.2631605!16s%2Fm%2F02rpl25?hl=vi
(
    'Danh thắng Ngũ Hành Sơn',
    'Marble Mountains (Ngu Hanh Son)',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Quốc gia đặc biệt và biểu tượng văn hóa du lịch hàng đầu Đà Nẵng gồm 5 ngọn núi đá vôi Kim - Mộc - Thủy - Hỏa - Thổ, nổi tiếng với động Huyền Không, động Âm Phủ và hệ thống bia Ma nhai được UNESCO ghi danh Di sản tư liệu.',
    'A National Special Relic comprising five limestone peaks representing the five elements. Features sacred grottoes, natural skylights, ancient pagodas, and panoramic coastal vistas.',
    '81 Huyền Trân Công Chúa, P. Hòa Hải, Q. Ngũ Hành Sơn, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[420, 1050]], "2": [[420, 1050]], "3": [[420, 1050]], "4": [[420, 1050]], "5": [[420, 1050]], "6": [[420, 1050]], "7": [[420, 1050]]}}',
    '+84 236 3961 114',
    'http://nguhanhson.org/',
    NULL,
    NULL,
    4.5,
    30125,
    120,
    'seed/culture-danh-thang-ngu-hanh-son',
    16.0037104,
    108.2631605,
    40000,
    75000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 28. Chùa Linh Ứng – Ngũ Hành Sơn (P. Hòa Hải)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Linh+%E1%BB%A8ng+%E2%80%93+Ng%C5%A9+H%C3%A0nh+S%C6%A1n/@16.0044163,108.2654316,17z/data=!3m1!4b1!4m6!3m5!1s0x314210943aa58371:0x41ba0db7e1694f47!8m2!3d16.0044163!4d108.2654316!16s%2Fg%2F11fy01vkm6?hl=vi
(
    'Chùa Linh Ứng – Ngũ Hành Sơn',
    'Linh Ung Pagoda - Marble Mountains',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi Quốc tự cổ gần 200 năm tuổi trên sườn đông ngọn Thủy Sơn, được vua Minh Mạng ngự ban biển ngạch "Ngự chế Ứng Chơn Tự". Sở hữu Tháp Xá Lợi 7 tầng cao 28m cùng hàng trăm tôn tượng Phật đá mỹ nghệ Non Nước tinh xảo.',
    'An ancient 19th-century royal pagoda situated on Thuy Son (Water Mountain), housing historic Buddha statues, brick towers, and coastal viewpoints.',
    'Hòn Thủy Sơn, P. Hòa Hải, Q. Ngũ Hành Sơn, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[390, 1050]], "2": [[390, 1050]], "3": [[390, 1050]], "4": [[390, 1050]], "5": [[390, 1050]], "6": [[390, 1050]], "7": [[390, 1050]]}}',
    '+84 236 3961 114',
    NULL,
    NULL,
    NULL,
    4.6,
    1445,
    60,
    'seed/culture-chua-linh-ung-nhs',
    16.0044163,
    108.2654316,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 29. Chùa Quán Thế Âm (P. Hòa Hải)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Qu%C3%A1n+Th%E1%BA%BF+%C3%82m/@16.0016335,108.2568603,17z/data=!3m1!4b1!4m6!3m5!1s0x314210b06abfffff:0x1b7ba1dbf77c8e56!8m2!3d16.0016335!4d108.2568603!16s%2Fg%2F11b633j2k3?hl=vi
(
    'Chùa Quán Thế Âm',
    'Quan The Am Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi đại danh lam dưới chân núi Kim Sơn, nơi tổ chức Lễ hội Quán Thế Âm Ngũ Hành Sơn (Di sản văn hóa phi vật thể quốc gia) và cũng là nơi đặt Bảo tàng Văn hóa Phật giáo đầu tiên tại Việt Nam.',
    'A major Buddhist pilgrimage site at the foot of Kim Son mountain, renowned for the Quan The Am Festival and the mystical Quan Am grotto.',
    '48 Sư Vạn Hạnh, P. Hòa Hải, Q. Ngũ Hành Sơn, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1140]], "2": [[360, 1140]], "3": [[360, 1140]], "4": [[360, 1140]], "5": [[360, 1140]], "6": [[360, 1140]], "7": [[360, 1140]]}}',
    '+84 236 3847 487',
    'http://chuaviettoancau.com/',
    NULL,
    NULL,
    4.6,
    1002,
    45,
    'seed/culture-chua-quan-the-am',
    16.0016335,
    108.2568603,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 30. Chùa Bà Đa (P. Mỹ An)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+B%C3%A0+%C4%90a/@16.046522,108.243574,17z/data=!3m1!4b1!4m6!3m5!1s0x3142176371cf79eb:0x367f0823528b18f7!8m2!3d16.046522!4d108.243574!16s%2Fg%2F1tfpm7rq?hl=vi
(
    'Chùa Bà Đa',
    'Ba Da Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa Phật giáo nổi tiếng ngay gần khu du lịch biển Bắc Mỹ An và phố Tây An Thượng, được đông đảo du khách thập phương ghé chiêm bái nhờ không gian thanh tịnh, kiến trúc trang nghiêm và các hoạt động thiện nguyện.',
    'A tranquil Buddhist temple near Bac My An with ornate triple-gate entrances and peaceful lotus gardens.',
    '2 An Tư Công Chúa, P. Mỹ An, Q. Ngũ Hành Sơn, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    '+84 905 678 545',
    NULL,
    NULL,
    NULL,
    4.7,
    253,
    30,
    'seed/culture-chua-ba-da',
    16.0465220,
    108.2435740,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 31. Nhà thờ Giáo xứ An Thượng (P. Mỹ An)
-- Google Maps: https://www.google.com/maps/place/Nh%C3%A0+th%E1%BB%9D+Gi%C3%A1o+x%E1%BB%A9+An+Th%C6%B0%E1%BB%A3ng/@16.0478051,108.2415174,17z/data=!3m1!4b1!4m6!3m5!1s0x314217631317ba9b:0xd5fc47231dc9dc45!8m2!3d16.0478051!4d108.2415174!16s%2Fg%2F1tdmfxz9?hl=vi
(
    'Nhà thờ Giáo xứ An Thượng',
    'An Thuong Parish Church',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Nhà thờ Công giáo lớn và khang trang giữa khu phố du lịch đa quốc gia An Thượng, kiến trúc thanh thoát, là điểm sinh hoạt tôn giáo quen thuộc của giáo dân địa phương và cộng đồng du khách nước ngoài.',
    'A charming modern church serving local parishioners and international travelers in the cosmopolitan An Thuong tourist quarter.',
    '176 Châu Thị Vĩnh Tế, P. Mỹ An, Q. Ngũ Hành Sơn, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[270, 1170]], "2": [[270, 1170]], "3": [[270, 1170]], "4": [[270, 1170]], "5": [[270, 1170]], "6": [[270, 1170]], "7": [[270, 1170]]}}',
    '+84 236 3950 178',
    'http://giaophanlanhtinh.org/',
    NULL,
    NULL,
    4.6,
    218,
    30,
    'seed/culture-nha-tho-an-thuong',
    16.0478051,
    108.2415174,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 32. Khu Căn cứ Cách mạng K20 (P. Khuê Mỹ)
-- Google Maps: https://www.google.com/maps/place/Khu+C%C4%83n+c%E1%BB%A9+C%C3%A1ch+m%E1%BA%A1ng+K20/@16.0216185,108.2418983,17z/data=!3m1!4b1!4m6!3m5!1s0x314210a4023c0aa7:0xa19bfd0a2fe78fc8!8m2!3d16.0216185!4d108.2418983!16s%2Fg%2F11b6dfg9k8?hl=vi
(
    'Khu Căn cứ Cách mạng K20',
    'K20 Revolutionary Base',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử Cách mạng cấp Quốc gia nổi tiếng tại vùng Đa Mặn xưa, lưu giữ nguyên vẹn hệ thống địa đạo, hầm bí mật trong nhà dân nằm ngay sát căn cứ quân sự thời chiến, mang giá trị giáo dục lịch sử sâu sắc.',
    'A secret revolutionary base during wartime featuring a hidden network of underground tunnels, trapdoors, and historical resistance artifacts.',
    'K144 Mai Đăng Chơn, P. Khuê Mỹ, Q. Ngũ Hành Sơn, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[450, 1020]], "2": [[450, 1020]], "3": [[450, 1020]], "4": [[450, 1020]], "5": [[450, 1020]], "6": [[450, 1020]], "7": [[450, 1020]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.5,
    60,
    60,
    'seed/culture-can-cu-k20',
    16.0216185,
    108.2418983,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 33. Chùa Khái Tây (P. Hòa Quý)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Kh%C3%A1i+T%C3%A2y/@15.9805132,108.2381422,17z/data=!3m1!4b1!4m6!3m5!1s0x314210878e17b8f9:0x88689c1df5c4a6b2!8m2!3d15.9805132!4d108.2381422!16s%2Fg%2F11dxkt0h_1?hl=vi
(
    'Chùa Khái Tây',
    'Khai Tay Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa Phật giáo truyền thống gắn liền với lịch sử làng cổ Khái Tây bên dòng sông Cổ Cò ở phía Nam thành phố, sở hữu khuôn viên thanh tịnh và được cộng đồng đánh giá cao.',
    'A secluded Buddhist pagoda nestled along the Co Co River in Hoa Quy, providing a peaceful retreat for spiritual meditation.',
    'Đường Khái Tây 1, P. Hòa Quý, Q. Ngũ Hành Sơn, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1260]], "2": [[360, 1260]], "3": [[360, 1260]], "4": [[360, 1260]], "5": [[360, 1260]], "6": [[360, 1260]], "7": [[360, 1260]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.7,
    16,
    30,
    'seed/culture-chua-khai-tay',
    15.9805132,
    108.2381422,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- =============================================================================
-- 5. QUẬN LIÊN CHIỂU (4 địa điểm)
-- =============================================================================

-- 34. Hải Vân Quan (P. Hòa Hiệp Bắc)
-- Google Maps: https://www.google.com/maps/place/H%E1%BA%A3i+V%C3%A2n+Quan/@16.1953284,108.1306306,17z/data=!3m1!4b1!4m6!3m5!1s0x31418700201ca745:0x5e56e44b82d9255a!8m2!3d16.1953284!4d108.1306306!16s%2Fg%2F11w9g4y_85?hl=vi
(
    'Hải Vân Quan',
    'Hai Van Gate (Hai Van Quan)',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử và Kiến trúc Nghệ thuật cấp Quốc gia trên đỉnh đèo Hải Vân được mệnh danh "Thiên hạ đệ nhất hùng quan". Công trình cửa ải quân sự triều Nguyễn vừa được trùng tu khang trang với tầm nhìn bao quát vịnh Đà Nẵng và Lăng Cô.',
    'The historic mountain pass fortress perched atop Hai Van Pass at 496m altitude. Crowned as ''The Most Colossal Gateway Under Heaven'' with panoramic bay and mountain views.',
    'Đỉnh đèo Hải Vân, P. Hòa Hiệp Bắc, Q. Liên Chiểu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[480, 1020]], "2": [[480, 1020]], "3": [[480, 1020]], "4": [[480, 1020]], "5": [[480, 1020]], "6": [[480, 1020]], "7": [[480, 1020]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.6,
    1439,
    90,
    'seed/culture-hai-van-quan',
    16.1953284,
    108.1306306,
    35000,
    70000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 35. Đình làng Hòa Mỹ (P. Hòa Minh)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+l%C3%A0ng+H%C3%B2a+M%E1%BB%B9/@16.0515219,108.1664695,17z/data=!4m6!3m5!1s0x3142191f00000001:0x9ec52b2750a56c73!8m2!3d16.051397!4d108.168697!16s%2Fg%2F1v2j9dp0?hl=vi
(
    'Đình làng Hòa Mỹ',
    'Hoa My Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử - Văn hóa cấp Thành phố nổi tiếng với cây đa cổ thụ trăm tuổi rợp bóng, là nơi tổ chức Lễ hội Đình làng Hòa Mỹ đặc sắc hàng năm với nghi thức rước kiệu và trò chơi dân gian truyền thống.',
    'A recognized historical monument in Lien Chieu celebrating community solidarity and preserving ancient festival rites.',
    'Đường Nguyễn Huy Tưởng, P. Hòa Minh, Q. Liên Chiểu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.4,
    28,
    30,
    'seed/culture-dinh-lang-hoa-my',
    16.0513970,
    108.1686970,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 36. Đình làng Đà Sơn (P. Hòa Khánh Nam)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+l%C3%A0ng+%C4%90%C3%A0+S%C6%A1n/@16.0542608,108.1566057,17z/data=!3m1!4b1!4m6!3m5!1s0x3142197b0fda4f17:0xe63f74cb94ed1435!8m2!3d16.0542608!4d108.1566057!16s%2Fg%2F11ngq9g952?hl=vi
(
    'Đình làng Đà Sơn',
    'Da Son Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử - Văn hóa cấp Thành phố tại ngôi làng cổ gần 700 năm tuổi — một trong những vùng đất đầu tiên người Việt mở cõi tại Đà Nẵng và từng ghi dấu cuộc họp mật phong trào Duy Tân năm 1915.',
    'An ancient village hall located near the foot of the western hills, preserving ancestral altars and traditional ceremonies.',
    'Đà Sơn, P. Hòa Khánh Nam, Q. Liên Chiểu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.8,
    4,
    30,
    'seed/culture-dinh-lang-da-son',
    16.0542608,
    108.1566057,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 37. Đình làng Nam Ô (P. Hòa Hiệp Nam)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+l%C3%A0ng+Nam+%C3%94/@16.1202353,108.1287413,17z/data=!3m1!4b1!4m6!3m5!1s0x31421fa75ff1397b:0x5e165ca24838cebf!8m2!3d16.1202353!4d108.1287413!16s%2Fg%2F11g1_8r17b?hl=vi
(
    'Đình làng Nam Ô',
    'Nam O Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử - Văn hóa cấp Thành phố nằm ngay làng chài cổ Nam Ô hơn 700 năm bên Rạn Nam Ô và gắn liền với Làng nghề nước mắm Nam Ô — Di sản văn hóa phi vật thể quốc gia.',
    'A cultural heritage site in the ancient Nam O fishing village, closely intertwined with the historic fish sauce craft and coastal guardian worship.',
    'Trần Bích San, Nam Ô 1, P. Hòa Hiệp Nam, Q. Liên Chiểu, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.5,
    2,
    30,
    'seed/culture-dinh-lang-nam-o',
    16.1202353,
    108.1287413,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- =============================================================================
-- 6. QUẬN CẨM LỆ (5 địa điểm)
-- =============================================================================

-- 38. Khu Di Tích Nghĩa trủng Hoà Vang (P. Khuê Trung)
-- Google Maps: https://www.google.com/maps/place/Khu+Di+T%C3%ADch+Ngh%C4%A9a+tr%E1%BB%A7ng+Ho%C3%A0+Vang/@16.0241679,108.2143034,17z/data=!4m7!3m6!1s0x31421971736ec597:0xbac017ace8dd774!8m2!3d16.0241679!4d108.2143034!16s%2Fg%2F11n16qs61b?hl=vi
(
    'Khu Di Tích Nghĩa trủng Hoà Vang',
    'Hoa Vang Martyrs Cemetery Relic',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử cấp Quốc gia quy tập hơn 1.000 nghĩa sĩ và đồng bào yêu nước đã anh dũng hy sinh trong những ngày đầu kháng chiến chống liên quân Pháp - Tây Ban Nha (1858 - 1860), có công viên cảnh quan tưởng niệm khang trang.',
    'A National Historic Relic commemorating heroic martyrs and defenders who fought during the historic resistance battles in Da Nang.',
    '46 Trần Thủ Độ, P. Khuê Trung, Q. Cẩm Lệ, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.8,
    21,
    45,
    'seed/culture-nghia-trung-hoa-vang',
    16.0241679,
    108.2143034,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 39. Đình làng Lỗ Giáng (P. Hòa Xuân)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+l%C3%A0ng+L%E1%BB%97+Gi%C3%A1ng/@15.9983337,108.2124295,17z/data=!4m7!3m6!1s0x31421a3f94df62c1:0x4176c3717696276d!8m2!3d15.9983337!4d108.2124295!16s%2Fg%2F11cfdvsmn?hl=vi
(
    'Đình làng Lỗ Giáng',
    'Lo Giang Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Kiến trúc Nghệ thuật - Lịch sử Văn hóa cấp Quốc gia được dựng vào thời Nguyễn giữa khu đô thị Hòa Xuân. Ngôi đình lưu giữ kiến trúc gỗ truyền thống xứ Quảng và ký ức khai hoang lập ấp vùng sông Cẩm Lệ.',
    'An ancient communal house on the banks of Cam Le River showcasing intricately carved wooden beams and village ancestral genealogy.',
    'Đường Dương Đức Nhan, P. Hòa Xuân, Q. Cẩm Lệ, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.8,
    16,
    30,
    'seed/culture-dinh-lang-lo-giang',
    15.9983337,
    108.2124295,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 40. Chùa Trung Lương (P. Hòa Xuân)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Trung+L%C6%B0%C6%A1ng/@16.002596,108.2149756,17z/data=!4m7!3m6!1s0x31421a1609c060db:0x85adfe64f9ffe30b!8m2!3d16.002596!4d108.2149756!16s%2Fg%2F11c1nbtsk0?hl=vi
(
    'Chùa Trung Lương',
    'Trung Luong Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa Phật giáo khang trang nằm gần khu vực "Phố nhà thờ tộc" độc đáo của Hòa Xuân, sở hữu không gian tam bảo tôn nghiêm, thanh tịnh và nhận được điểm đánh giá 4.9 sao từ khách tham quan.',
    'A quiet Buddhist sanctuary in Hoa Xuan with traditional Central Vietnamese pagoda architecture and peaceful meditation spaces.',
    'Đường Hoàng Đình Ái, P. Hòa Xuân, Q. Cẩm Lệ, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1320]], "2": [[360, 1320]], "3": [[360, 1320]], "4": [[360, 1320]], "5": [[360, 1320]], "6": [[360, 1320]], "7": [[360, 1320]]}}',
    '+84 987 009 999',
    NULL,
    NULL,
    NULL,
    4.9,
    58,
    30,
    'seed/culture-chua-trung-luong',
    16.0025960,
    108.2149756,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 41. Chùa Hòa Thọ (P. Hòa Thọ Đông)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+H%C3%B2a+Th%E1%BB%8D/@16.0125853,108.1925728,17z/data=!4m7!3m6!1s0x31421a2d038b3269:0x664db0380d88b782!8m2!3d16.0125853!4d108.1925728!16s%2Fg%2F11b67rs5tz?hl=vi
(
    'Chùa Hòa Thọ',
    'Hoa Tho Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa Phật giáo cổ truyền quy mô lớn tại cửa ngõ phía Tây Nam quận Cẩm Lệ gần trục Cách Mạng Tháng Tám, trung tâm tín ngưỡng lâu đời của người dân vùng Hòa Thọ.',
    'A neighborhood pagoda in Cam Le with towering bell towers and serene tree-shaded grounds for prayer and merit-making.',
    'Quốc lộ 1A (gần 390 Cách Mạng Tháng Tám), P. Hòa Thọ Đông, Q. Cẩm Lệ, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1260]], "2": [[360, 1260]], "3": [[360, 1260]], "4": [[360, 1260]], "5": [[360, 1260]], "6": [[360, 1260]], "7": [[360, 1260]]}}',
    '+84 236 3670 951',
    NULL,
    NULL,
    NULL,
    4.6,
    63,
    30,
    'seed/culture-chua-hoa-tho',
    16.0125853,
    108.1925728,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 42. Chùa Huệ Quang (P. Hòa An)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Hu%E1%BB%87+Quang/@16.0472185,108.1781623,17z/data=!3m1!4b1!4m6!3m5!1s0x314219129b718e53:0xa2509cdf7b1d95af!8m2!3d16.0472185!4d108.1781623!16s%2Fg%2F11dxnjzrp8?hl=vi
(
    'Chùa Huệ Quang',
    'Hue Quang Pagoda',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa Phật giáo tiêu biểu lâu năm gần trục đường Tôn Đản - khu vực Hòa An, không gian yên tĩnh, kiến trúc thanh thoát và thường xuyên tổ chức các khóa tu, hoạt động thiện nguyện cộng đồng.',
    'A venerable pagoda in Cam Le known for charitable Buddhist programs and calm devotional halls.',
    'Khu vực đường Tôn Đản (25WH+V7M), P. Hòa An, Q. Cẩm Lệ, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[360, 1260]], "2": [[360, 1260]], "3": [[360, 1260]], "4": [[360, 1260]], "5": [[360, 1260]], "6": [[360, 1260]], "7": [[360, 1260]]}}',
    '+84 236 2221 089',
    NULL,
    NULL,
    NULL,
    4.6,
    69,
    30,
    'seed/culture-chua-hue-quang',
    16.0472185,
    108.1781623,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- =============================================================================
-- 7. HUYỆN HÒA VANG (8 địa điểm)
-- =============================================================================

-- 43. Chùa Linh Ứng - Bà Nà (Xã Hòa Ninh)
-- Google Maps: https://www.google.com/maps/place/Ch%C3%B9a+Linh+%E1%BB%A8ng+-+B%C3%A0+N%C3%A0/@15.9971357,107.9940442,17z/data=!3m1!4b1!4m6!3m5!1s0x314220b332bc0015:0x1bfeea74c2bc5525!8m2!3d15.9971357!4d107.9940442!16s%2Fg%2F11b6l_6w1s
(
    'Chùa Linh Ứng - Bà Nà',
    'Linh Ung Pagoda - Ba Na Hills',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi chùa nằm trong tam giác tâm linh "Tam Linh Ứng tự" của Đà Nẵng ở độ cao gần 1.500m trên đỉnh Bà Nà, nổi tiếng với đại tượng Phật Thích Ca Mâu Ni thiền định giữa mây ngàn (miễn phí vào chùa bên trong KDL Sun World Ba Na Hills).',
    'A majestic alpine pagoda situated 1,500m above sea level atop Ba Na Hills, featuring a monumental 27-meter seated white Shakyamuni Buddha statue.',
    'Thôn An Sơn (Đỉnh Bà Nà), Xã Hòa Ninh, H. Hòa Vang, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[480, 1020]], "2": [[480, 1020]], "3": [[480, 1020]], "4": [[480, 1020]], "5": [[480, 1020]], "6": [[480, 1020]], "7": [[480, 1020]]}}',
    NULL,
    'https://banahills.sunworld.vn',
    NULL,
    NULL,
    4.8,
    355,
    60,
    'seed/culture-chua-linh-ung-ba-na',
    15.9971357,
    107.9940442,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 44. Đình làng Túy Loan (Xã Hòa Phong)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+l%C3%A0ng+T%C3%BAy+Loan/@15.9983944,108.1345914,17z/data=!3m1!4b1!4m6!3m5!1s0x31421bfca726f1a9:0xc91bd670b336338b!8m2!3d15.9983944!4d108.1345914!16s%2Fg%2F12270911
(
    'Đình làng Túy Loan',
    'Tuy Loan Ancient Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử - Văn hóa cấp Quốc gia (1999) có bề dày hơn 500 năm bên ngã ba sông Túy Loan. Gắn liền với Lễ hội đình làng Túy Loan đầu xuân, đua ghe truyền thống và làng nghề bánh tráng - mì Quảng Túy Loan nức tiếng.',
    'A famous 500-year-old communal house on the picturesque banks of Tuy Loan River, celebrated for ancient architecture and the famous rice paper and noodle village.',
    'Túy Loan Tây 1, Xã Hòa Phong, H. Hòa Vang, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.6,
    135,
    45,
    'seed/culture-dinh-lang-tuy-loan',
    15.9983944,
    108.1345914,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 45. Trung tâm Văn hóa du lịch cộng đồng Tà Lang - Giàn Bí (Xã Hòa Bắc)
-- Google Maps: https://www.google.com/maps/place/Trung+t%C3%A2m+V%C4%83n+h%C3%B3a+du+l%E1%BB%8Bch+c%E1%BB%99ng+%C4%91%E1%BB%93ng+T%C3%A0+Lang+-+Gi%C3%A0n+B%C3%AD/@16.1204648,107.9922536,15z/data=!4m6!3m5!1s0x3141f5a582b1d9b1:0x193453939f1fbbf!8m2!3d16.1204648!4d107.9922536!16s%2Fg%2F11xp45805_
(
    'Trung tâm Văn hóa du lịch cộng đồng Tà Lang - Giàn Bí',
    'Ta Lang - Gian Bi Co Tu Community Cultural Center',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Điểm trải nghiệm văn hóa bản địa đặc sắc của đồng bào Cơ Tu bên thượng nguồn sông Cu Đê. Du khách được khám phá kiến trúc Nhà Gươl truyền thống, nghệ thuật dệt thổ cẩm, điệu múa Tung tung Da dá và âm vang cồng chiêng.',
    'An authentic ethnic eco-cultural center in Hoa Bac, showcasing Co Tu Guol stilt houses, brocade weaving, traditional dances, and community tourism.',
    'Thôn Tà Lang - Giàn Bí, Xã Hòa Bắc, H. Hòa Vang, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.6,
    38,
    90,
    'seed/culture-ta-lang-gian-bi',
    16.1204648,
    107.9922536,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 46. Đình làng Hưởng Phước (Xã Hòa Liên)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+l%C3%A0ng+H%C6%B0%E1%BB%9Fng+Ph%C6%B0%E1%BB%9Bc/@16.0787992,108.096427,15z/data=!4m6!3m5!1s0x31421f009131892b:0x63d50a45502fd89d!8m2!3d16.0787992!4d108.096427!16s%2Fg%2F11f57fw8rh
(
    'Đình làng Hưởng Phước',
    'Huong Phuoc Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Ngôi đình cổ kính của làng Hưởng Phước (Hiền Phước xưa) vùng hạ lưu sông Cu Đê. Lưu giữ kiến trúc truyền thống làng quê Hòa Vang và lễ hội Kỳ yên cầu quốc thái dân an mỗi dịp xuân về.',
    'A countryside communal hall in Hoa Vang preserving cultural roots and ancestral farming traditions.',
    'Đường Tân Ninh, Thôn Hưởng Phước, Xã Hòa Liên, H. Hòa Vang, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.6,
    20,
    30,
    'seed/culture-dinh-lang-huong-phuoc',
    16.0787992,
    108.0964270,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 47. Đình Thái Lai (Xã Hòa Nhơn)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+Th%C3%A1i+Lai/@16.0090886,108.1259508,17z/data=!3m1!4b1!4m6!3m5!1s0x31421b58532f7413:0x1b43aa9430c00465!8m2!3d16.0090886!4d108.1259508!16s%2Fg%2F11tflx_y33
(
    'Đình Thái Lai',
    'Thai Lai Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử - Văn hóa cấp Thành phố nằm trong làng du lịch sinh thái Thái Lai bên dòng sông Túy Loan. Đình cổ gắn với cây đa, bến nước yên bình, thường được kết hợp trong các tour trải nghiệm làng quê Hòa Vang.',
    'An architectural art relic in Hoa Vang surrounded by bamboo groves and traditional ancient houses along the river.',
    'Thôn Thái Lai, Xã Hòa Nhơn, H. Hòa Vang, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.8,
    18,
    45,
    'seed/culture-dinh-thai-lai',
    16.0090886,
    108.1259508,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 48. Công viên văn hoá Bia chiến tích Gò Hà (Xã Hòa Khương)
-- Google Maps: https://www.google.com/maps/place/C%C3%B4ng+vi%C3%AAn+v%C4%83n+ho%C3%A1+Bia+chi%E1%BA%BFn+t%C3%ADch+G%C3%B2+H%C3%A0/@15.9696984,108.136006,17z/data=!4m6!3m5!1s0x31421b0044eb014b:0xeab88ada9035bb94!8m2!3d15.9636268!4d108.1487043!16s%2Fg%2F11vsz0rdwk?hl=vi
(
    'Công viên văn hoá Bia chiến tích Gò Hà',
    'Go Ha Victory Memorial Park',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử cấp Quốc gia được đầu tư khang trang thành công viên văn hóa tưởng niệm chiến thắng Gò Hà (10/1965) bên dòng sông Yên, không gian xanh mát phục vụ tìm hiểu lịch sử kháng chiến.',
    'A historic military victory park commemorating the valiant battle of Go Ha in 1965.',
    'Thôn Hương Lam, Xã Hòa Khương, H. Hòa Vang, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    'https://nhandan.vn/da-nang-khanh-thanh-cong-vien-van-hoa-bia-chien-tich-go-ha-post690965.html',
    NULL,
    NULL,
    4.8,
    14,
    30,
    'seed/culture-bia-chien-tich-go-ha',
    15.9636268,
    108.1487043,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 49. Đình Làng Đại La (Xã Hòa Sơn)
-- Google Maps: https://www.google.com/maps/place/%C4%90%C3%ACnh+L%C3%A0ng+%C4%90%E1%BA%A1i+La/@16.0313459,108.117141,17z/data=!3m1!4b1!4m6!3m5!1s0x31421e9f0e5857ed:0x4f7d8114639b3e57!8m2!3d16.0313459!4d108.117141!16s%2Fg%2F11hcbrn59w
(
    'Đình Làng Đại La',
    'Dai La Communal House',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử - Văn hóa cấp Thành phố xây dựng từ cuối thế kỷ XVIII trên tuyến đường Bà Nà - Suối Mơ. Ngôi đình cổ lưu giữ nhiều sắc phong triều Nguyễn, nằm thuận tiện trên cung đường du lịch đi Bà Nà Hills.',
    'An ancient village hall situated in the rural valleys of Hoa Son, maintaining centuries-old communal harvest rituals.',
    'Tuyến Bà Nà - Suối Mơ, Thôn Đại La, Xã Hòa Sơn, H. Hòa Vang, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.8,
    11,
    30,
    'seed/culture-dinh-lang-dai-la',
    16.0313459,
    108.1171410,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 50. Mộ Ông Đỗ Thúc Tịnh (Xã Hòa Tiến)
-- Google Maps: https://www.google.com/maps/place/M%E1%BB%99+%C3%94ng+%C4%90%E1%BB%97+Th%C3%BAc+T%E1%BB%8Bnh+(di+t%C3%ADch+qu%E1%BB%91c+gia)/@15.9731144,108.1268923,17z/data=!3m1!4b1!4m6!3m5!1s0x31421bc270ba7ce1:0x15f6ee4f8be9eb87!8m2!3d15.9731144!4d108.1268923!16s%2Fg%2F11vdfd_354
(
    'Mộ Ông Đỗ Thúc Tịnh (Di tích Quốc gia)',
    'Do Thuc Tinh Tomb (National Relic)',
    (SELECT id FROM categories WHERE code = 'CULTURE' LIMIT 1),
    'Di tích Lịch sử cấp Quốc gia (2007) tôn vinh danh thần, chí sĩ yêu nước Đỗ Thúc Tịnh (1818 - 1862) — người con ưu tú của quê hương Hòa Tiến trong phong trào kháng chiến chống thực dân Pháp thế kỷ XIX.',
    'A National Historic Relic honoring the patriot and mandarin Do Thuc Tinh, a revered scholar and resistance leader from Da Nang.',
    'Thôn Giáp Ba, Xã Hòa Tiến, H. Hòa Vang, Đà Nẵng',
    '{"schema_version": 1, "timezone": "Asia/Ho_Chi_Minh", "week": {"1": [[0, 1440]], "2": [[0, 1440]], "3": [[0, 1440]], "4": [[0, 1440]], "5": [[0, 1440]], "6": [[0, 1440]], "7": [[0, 1440]]}}',
    NULL,
    NULL,
    NULL,
    NULL,
    4.8,
    4,
    30,
    'seed/culture-mo-do-thuc-tinh',
    15.9731144,
    108.1268923,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
);
