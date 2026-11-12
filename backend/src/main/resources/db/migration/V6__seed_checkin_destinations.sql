-- =============================================================================
-- SmartTravel — Seed 50 CHECKIN Destinations across Da Nang (7 Districts)
-- Category: CHECKIN (song-ao-checkin)
-- Coordinates, ratings & review counts verified on Google Maps POI cards.
-- Image URLs extracted from live Google Maps place photography.
-- Ticket prices reflect 2025-2026 published admission & service rates (VND).
-- =============================================================================

INSERT INTO destinations (
    name, category_id, description, address, opening_hours, phone, website,
    image_url, sub_images, rating, review_count, osm_id, latitude, longitude,
    price_min_vnd, price_max_vnd, status, created_at, updated_at
) VALUES

-- -----------------------------------------------------------------------------
-- QUẬN HẢI CHÂU (12 địa điểm) & CẦU TIÊN SƠN (Hải Châu - Ngũ Hành Sơn)
-- -----------------------------------------------------------------------------

-- 1. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+R%E1%BB%93ng,+%C4%90%C3%A0+N%E1%BA%B5ng+550000,+Vi%E1%BB%87t+Nam/@16.0611042,108.2276926,17z/data=!4m6!3m5!1s0x314219d2f38ce45d:0xbfa47dd116d4db88!8m2!3d16.0611042!4d108.2276926!16s%2Fg%2F1jkz6cxjc
(
    'Cầu Rồng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Biểu tượng kiến trúc hiện đại của Đà Nẵng bắc qua sông Hàn với hình dáng con rồng vươn ra biển lớn. Cuối tuần (thứ 6, 7, Chủ nhật lúc 21:00) cầu có màn trình diễn phun lửa và phun nước thu hút đông đảo du khách check-in. Miễn phí tham quan.',
    'Đường Nguyễn Văn Linh, P. Phước Ninh, Q. Hải Châu, Đà Nẵng',
    'Mở cả ngày (Phun lửa/nước 21:00 T6, T7, CN)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcajdEyPJ-iyTBSFfVOH9RHttXx-c1Ibdn1UJaLbMp66wNhm6bZoaP-B2UltZDhJiZA8DbVx5snSW9Irt8bZuJFIVtcLtVrdH0DKbOh5GE1egQ67ukInP5kJ6LNIeY-rUHkamU=w408-h306-k-no',
    NULL,
    4.7,
    26697,
    'seed/checkin-cau-rong',
    16.0611042,
    108.2276926,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 2. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+S%C3%B4ng+H%C3%A0n/@16.0722216,108.2275685,17z/data=!3m1!4b1!4m6!3m5!1s0x314218311a3d6f7f:0xbebfdc82d02a5c10!8m2!3d16.0722216!4d108.2275685!16s%2Fm%2F0407p3j
(
    'Cầu Sông Hàn',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu dây văng quay đầu tiên do kỹ sư Việt Nam thiết kế và thi công, nối liền hai bờ trung tâm Đà Nẵng. Điểm dạo mát, ngắm cảnh đêm và check-in khoảnh khắc cầu xoay nhịp giữa dòng sông Hàn vào 23:00 cuối tuần. Miễn phí tham quan.',
    'Đường Lê Duẩn, P. Hải Châu I, Q. Hải Châu, Đà Nẵng',
    'Mở cả ngày (Quay 23:00 - 24:00 T7, CN)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdU-x607bvPXcske6O9pPNn49aMLIdXkkf_hoQqt5H9HTxPou1tDkrUPAEHJbUtzrAwcctp-by-V-Lex6mbstAbutdSpT5NF0jxtRr5QnVSCmGJXHzDxZ3nefn5ub62KlOjvtltphlbLpUa=w426-h240-k-no',
    NULL,
    4.6,
    3882,
    'seed/checkin-cau-song-han',
    16.0722216,
    108.2275685,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 3. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+Tr%E1%BA%A7n+Th%E1%BB%8B+L%C3%BD/@16.0505193,108.2284903,17z/data=!3m1!4b1!4m6!3m5!1s0x314219d7aeb82463:0x1b14a29a6e1fe85!8m2!3d16.0505193!4d108.2284903!16s%2Fm%2F09rzj_x
(
    'Cầu Trần Thị Lý',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu dây văng thiết kế tháp nghiêng như cánh buồm căng gió vươn ra Biển Đông, rực rỡ ánh đèn LED nghệ thuật về đêm. Góc chụp ảnh kiến trúc nổi bật từ bờ công viên hoặc dọc cầu đi bộ Nguyễn Văn Trỗi ngay bên cạnh. Miễn phí tham quan.',
    'Cầu Trần Thị Lý, P. Hòa Cường Bắc, Q. Hải Châu, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfr_meVivrS3lJnECRgSplqzzpnlSgTyewNlGjPX-BrmT9SOHxvZxhBhMyv6SMgrhi1Sn4K5y5gueqrEIUqEKsswFnNf76lN-m2Udn4Fo79VLOCBgN56albBAj2Q0gt-dbjQDso486N1Aw=w408-h306-k-no',
    NULL,
    4.7,
    2571,
    'seed/checkin-cau-tran-thi-ly',
    16.0505193,
    108.2284903,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 4. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+Thu%E1%BA%ADn+Ph%C6%B0%E1%BB%9Bc/@16.0961805,108.2234039,17z/data=!3m1!4b1!4m6!3m5!1s0x314218151227f719:0xd67f2e1df15f57f6!8m2!3d16.0961805!4d108.2234039!16s%2Fm%2F05q5cfl
(
    'Cầu Thuận Phước',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu treo dây võng bắc qua cửa biển nơi sông Hàn đổ ra vịnh Đà Nẵng, mang vẻ đẹp thanh thoát nối quận Hải Châu với bán đảo Sơn Trà. Địa điểm ngắm hoàng hôn buông trên vịnh và ánh đèn cảng biển cực kỳ ấn tượng. Miễn phí tham quan.',
    'Đường Nguyễn Tất Thành, P. Thuận Phước, Q. Hải Châu, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdFMdTV3g0mIagNB1q5QEUGHRL8l6pPPV9Dwi88QMVBkEbulgjy956Pmr9sSG216KfDTFunrtLTCfdPaF5TLMfhTZvTElzLsXLbeltLEp-XVXUS9kPhkSrDupcJjBN4iavbGjg=w408-h272-k-no',
    NULL,
    4.6,
    2894,
    'seed/checkin-cau-thuan-phuoc',
    16.0961805,
    108.2234039,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 5. Google Maps: https://www.google.com/maps/place/Nguyen+Van+Troi+Bridge/@16.0514136,108.2272828,17z/data=!4m7!3m6!1s0x314219c43d8e5781:0x1e36f01daee40eeb!8m2!3d16.0514136!4d108.2272828!16s%2Fg%2F122c1n1s
(
    'Cầu đi bộ Nguyễn Văn Trỗi',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu giàn thép vòm màu vàng cổ điển mang dấu ấn lịch sử, nay được cải tạo thành cầu đi bộ và không gian sinh hoạt cộng đồng trên sông Hàn. Tọa độ chụp ảnh vintage, đón bình minh và hoàng hôn ngắm trọn cầu Trần Thị Lý. Miễn phí tham quan.',
    'Cầu Nguyễn Văn Trỗi, P. Hòa Cường Bắc, Q. Hải Châu, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLf5LFM_9ZGMluh-aWc185zuq7XgmD8on3k0PoGYPhAdhZ2LgGwn8bmkQUnHFwFMWETxNPSqd2RdBjGpGBY__awG_ZtFcssIZrT2VGE76oOn4YLlB8xQlHDRskCdWZCF7UZymCLL=w408-h544-k-no',
    NULL,
    4.6,
    244,
    'seed/checkin-cau-nguyen-van-troi',
    16.0514136,
    108.2272828,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 6. Google Maps: https://www.google.com/maps/place/C%C3%B4ng+Vi%C3%AAn+APEC/@16.059436,108.2232535,17z/data=!3m1!4b1!4m6!3m5!1s0x3142194a2fa2b80f:0x6bfe76ea6fa3693e!8m2!3d16.059436!4d108.2232535!16s%2Fg%2F11fy014z70
(
    'Công Viên APEC',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Điểm nhấn kiến trúc mái vòm Cánh diều bay cao bên bờ Tây sông Hàn, cùng vườn tượng nghệ thuật của các nền kinh tế APEC. Không gian hiện đại với mảng xanh, giếng trời và góc chụp hình đối xứng cực hot với giới trẻ Đà Nẵng. Miễn phí vào cổng.',
    'Ngã ba Bạch Đằng - 2 Tháng 9, P. Bình Hiên, Q. Hải Châu, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLclLiphzaxTeoFVs-e8vFhA46tW8vFoGo-xIlYLxA6kHDoSvac0hnnnP7dGud95qBJn-vTtkSYFrSNcGi3FQ4RgoT5IXNZnqt78vy6zi51C24nHzcQv_0mNWibfOZGOcc8MkZHy=w408-h306-k-no',
    NULL,
    4.6,
    3864,
    'seed/checkin-cong-vien-apec',
    16.0594360,
    108.2232535,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 7. Google Maps: https://www.google.com/maps/place/Ph%E1%BB%91+%C4%91i+b%E1%BB%99+B%E1%BA%A1ch+%C4%90%E1%BA%B1ng+%C4%90%C3%A0+N%E1%BA%B5ng+-+Danang+walking+street/data=!4m7!3m6!1s0x314219001ac03b1b:0x941be3c494d6c70f!8m2!3d16.0595812!4d108.224016!16s%2Fg%2F11y4zs7dmz
(
    'Phố đi bộ Bạch Đằng Đà Nẵng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Tuyến phố đi bộ ven sông Hàn kéo dài từ đuôi Cầu Rồng đến cầu Trần Thị Lý với nhiều tiểu cảnh check-in, biểu diễn nghệ thuật đường phố và các ki-ốt ẩm thực về đêm. Không gian tản bộ sôi động nhìn thẳng sang sông Hàn lung linh. Miễn phí dạo chơi.',
    'Đường Bạch Đằng (Cầu Rồng - Trần Thị Lý), P. Bình Hiên, Q. Hải Châu, Đà Nẵng',
    'Mở cả ngày (Sôi động 15:00 - 24:00)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcVEPTc7KO74zP-zCie-mvSypyfezVCVCvLP65CdMD0O8-esw6jSDS1cy10fdA2M9hrsDprVkVCqRr1hJ6To61MWquBjT27kZ0dLXLk3vNQPJb_6cv77dtH-PpK2wkmpw7NlD0=w408-h544-k-no',
    NULL,
    4.6,
    129,
    'seed/checkin-pho-di-bo-bach-dang',
    16.0595812,
    108.2240160,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 8. Google Maps: https://www.google.com/maps/place/Trung+t%C3%A2m+H%C3%A0nh+ch%C3%ADnh+Th%C3%A0nh+ph%E1%BB%91+%C4%90%C3%A0+N%E1%BA%B5ng/@16.0778734,108.2234032,17z/data=!3m1!4b1!4m6!3m5!1s0x314218306e680a65:0x51b8bca167c1e550!8m2!3d16.0778734!4d108.2234032!16s%2Fm%2F0126786g
(
    'Trung tâm Hành chính Thành phố Đà Nẵng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Tòa nhà 34 tầng thiết kế hình ngọn hải đăng độc đáo bên bờ sông Hàn, thường được ví như tòa nhà trái bắp biểu tượng của đô thị hiện đại. Du khách thường check-in ngoại cảnh dọc bờ sông Bạch Đằng và tuyến phố Trần Phú. Miễn phí chụp ảnh ngoại cảnh.',
    '24 Trần Phú, P. Thạch Thang, Q. Hải Châu, Đà Nẵng',
    'Ngoại cảnh 24/7 (Hành chính T2-T6: 07:30 - 17:00)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfbdx9MmhQp0Ymq0nr5QhYBsse9vAUYtPFReF00SYwlsmH6WLgF8co7ErzcZn6PoQNPoUoSKAWg4yFb-XJ5JMlhHnT84vYzqypAD20W3LhJG2YGwM65z7qa4L0Ar98YWayDMH-P=w408-h544-k-no',
    NULL,
    4.3,
    360,
    'seed/checkin-trung-tam-hanh-chinh-dn',
    16.0778734,
    108.2234032,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 9. Google Maps: https://www.google.com/maps/place/Cung+Thi%E1%BA%BFu+Nhi+%C4%90%C3%A0+N%E1%BA%B5ng/@16.0374151,108.2242551,17z/data=!3m1!4b1!4m6!3m5!1s0x314219cd3008d511:0x39a13e2bb97f5d6f!8m2!3d16.0374151!4d108.2242551!16s%2Fg%2F1tdr9v0v
(
    'Cung Thiếu Nhi Đà Nẵng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Tổ hợp công trình lấy cảm hứng từ trò chơi xếp hình Tangram với các mảng tường kính đa sắc rực rỡ, khu vui chơi và sân khấu ngoài trời. Một trong những background chụp ảnh đậm chất hình học và màu sắc được yêu thích tại quận Hải Châu. Miễn phí tham quan khuôn viên.',
    '2A Phan Đăng Lưu, P. Hòa Cường Bắc, Q. Hải Châu, Đà Nẵng',
    '07:00 - 21:30',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdFo7KSIZ0WLNvgkmJuSwC5HhuRKAcS9-3u1Ip70-7pbu8UHG6Tw9HdU3wCFuBcmQNKx4DSq3i9MsDJQ3--RJTla_htnI7157BiUHmCYfgh_J0vVy2xJESGmyCVR-sGLTZRlYqS=w408-h271-k-no',
    NULL,
    4.4,
    1520,
    'seed/checkin-cung-thieu-nhi-dn',
    16.0374151,
    108.2242551,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 10. Google Maps: https://www.google.com/maps/place/Du+Thuy%E1%BB%81n+S%C3%B4ng+H%C3%A0n+%C4%90%C3%A0+N%E1%BA%B5ng+%282Da+Tickets%29/data=!4m7!3m6!1s0x314219bbf6a1c67b:0x3c19dccc641354e9!8m2!3d16.0791411!4d108.2242785!16s%2Fg%2F11b6q_8m6f
(
    'Du Thuyền Sông Hàn Đà Nẵng (2Da Tickets)',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Bến du thuyền du lịch sông Hàn đưa du khách lướt qua chuỗi cầu biểu tượng như Cầu Rồng, Cầu Sông Hàn, Cầu Trần Thị Lý trong không gian lộng gió về đêm. Vé du thuyền ngắm cảnh: 120.000đ - 150.000đ ngày thường; 150.000đ - 200.000đ cuối tuần T6-CN (xem Cầu Rồng phun lửa); tour ăn tối 450.000đ - 570.000đ.',
    '26 Bạch Đằng, P. Thạch Thang, Q. Hải Châu, Đà Nẵng',
    'Mở cả ngày (Tàu chạy 18:00 - 22:00)',
    '+84 796 768 636',
    'https://duthuyensonghan.vn/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfEWyH5bqvLIces-K-hjXiScMxBsVKVNEm9LL75nwUyAlqN17hxMmuKqx7-hI-fPXA75_Rd1oj8NtyKu94dLJ4jSAy1aqbqNwENpD2oVL4nc7vvRKsZaF_D1EUOPm3e2NnHgWtr0OnQiJ9O=w426-h240-k-no',
    NULL,
    4.3,
    1063,
    'seed/checkin-ben-du-thuyen-song-han',
    16.0791411,
    108.2242785,
    120000,
    200000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 11. Google Maps: https://www.google.com/maps/place/Qu%E1%BA%A3ng+Tr%C6%B0%E1%BB%9Dng+29%2F3/data=!4m10!1m2!2m1!1zUXXhuqNuZyB0csaw4budbmcgMjkgVGjDoW5nIDMgxJDDoCBO4bq1bmc!3m6!1s0x31421900520d5b99:0xeabc3c18b28dd97e!8m2!3d16.0407608!4d108.2220892!16s%2Fg%2F11vz5hg7qn
(
    'Quảng Trường 29/3',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Quảng trường rộng lớn nằm trên trục đường 2 Tháng 9 gần Cung Thể thao Tiên Sơn và Tượng đài 2/9, thường xuyên diễn ra các lễ hội và sự kiện ngoài trời của thành phố. Không gian thoáng đãng lý tưởng để hóng gió và chụp ảnh toàn cảnh công trình. Miễn phí tham quan.',
    'Đường 30 Tháng 4 giao Đường 2 Tháng 9, P. Hòa Cường Bắc, Q. Hải Châu, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfN18WrWizPgVGEgeBewAjkAoOTUErsgsZ1pnVU194QASns80Oh1Nzr27-2xYMnpvZ9DDUxxzjp83LVG_F0xprDA_90efJB0ogp-MYVN1GbOmu4f0yYl8a64xrdAoWxuCxPPVM1geiN8NHE=w408-h306-k-no',
    NULL,
    4.5,
    60,
    'seed/checkin-quang-truong-29-3',
    16.0407608,
    108.2220892,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 12. Google Maps: https://www.google.com/maps/place/Th%C6%B0+vi%E1%BB%87n+%C4%90%C3%A0+N%E1%BA%B5ng/@16.0738274,108.2240663,17z/data=!4m6!3m5!1s0x314218304674f139:0x5e4d117e1cdd4656!8m2!3d16.0738274!4d108.2240663!16s%2Fg%2F1tdpjkpk
(
    'Thư viện Đà Nẵng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Thư viện Khoa học Tổng hợp bên bờ sông Hàn mang kiến trúc hiện đại thanh lịch với khoảng sân vườn rợp bóng cây và ban công nhìn sang Cầu Rồng. Góc sống ảo nhẹ nhàng mang hơi hướng học thuật giữa trung tâm đường Bạch Đằng - Trần Phú. Miễn phí tham quan khuôn viên.',
    '33 Trần Phú (mặt tiền 46 Bạch Đằng), P. Hải Châu I, Q. Hải Châu, Đà Nẵng',
    '07:30 - 19:00',
    NULL,
    'https://thuvien.danang.gov.vn/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLc7nsfKtsM6jCP_dVAZGI1WXzHLgMdFXQ_E5Q6ul1OGyW4uvevJgN6cSRXvNe4_GKJlBlS5ZSIijIOaGPxAHAuvNjlN99EeH6GeLWA_aZtUGz1nq9iMGvdzthZUaj3kSl16bySXLFNWJsU=w408-h306-k-no',
    NULL,
    4.5,
    338,
    'seed/checkin-thu-vien-da-nang',
    16.0738274,
    108.2240663,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- QUẬN SƠN TRÀ (11 địa điểm)
-- -----------------------------------------------------------------------------

-- 13. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+T%C3%ACnh+Y%C3%AAu+%C4%90%C3%A0+N%E1%BA%B5ng/@16.0629967,108.2298146,17z/data=!3m1!4b1!4m6!3m5!1s0x31421832049d1073:0x1b41ea87588e1465!8m2!3d16.0629967!4d108.2298146
(
    'Cầu Tình Yêu Đà Nẵng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cầu tàu hình vòng cung nằm bên bờ Đông sông Hàn nổi bật với hàng cột đèn lồng trái tim đỏ rực và hàng trăm ổ khóa tình yêu gắn dọc lan can. Góc check-in lãng mạn nhìn thẳng sang Cầu Rồng và toàn cảnh phố thị bờ Tây khi lên đèn. Miễn phí tham quan (mua ổ khóa lưu niệm tính riêng).',
    'Đường Trần Hưng Đạo, P. An Hải Tây, Q. Sơn Trà, Đà Nẵng',
    'Mở cả ngày (24/24)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfo3cVI17n2FdYxP-4rALF8RER5VgbNPNSaCgLMqEHU2AqDL64ddWBkJwYiijF4oPNFtA-q6sDtw8ysw9WTWa9WmrfyBlwQhpFK98HG7ulxNTHOBakFyMPvlVwiaUzfdv4KQrCa8Zbmr2rQ=w408-h544-k-no',
    NULL,
    4.5,
    1154,
    'seed/checkin-cau-tinh-yeu',
    16.0629967,
    108.2298146,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 14. Google Maps: https://www.google.com/maps/place/T%C6%B0%E1%BB%A3ng+C%C3%A1+Ch%C3%A9p+H%C3%B3a+R%E1%BB%93ng/@16.0629054,108.2298191,17z/data=!3m1!4b1!4m6!3m5!1s0x3142198c825000e1:0x9b011fe03c346db3!8m2!3d16.0629054!4d108.2298191
(
    'Tượng Cá Chép Hóa Rồng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Tác phẩm điêu khắc đá trắng nguyên khối nặng gần 200 tấn cao 7,5m đặt ngay cạnh Cầu Tình Yêu bên bến du thuyền DHC Marina. Biểu tượng phun nước hướng về Cầu Rồng tạo nên khung hình check-in đặc trưng bậc nhất bờ Đông sông Hàn. Miễn phí tham quan.',
    'Đường Trần Hưng Đạo, P. An Hải Tây, Q. Sơn Trà, Đà Nẵng',
    'Mở cả ngày (24/24)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLf1KY8zeQg-I9ZqMITKYvgAVNxXEhWtv39OWUVf5zFYgCTIdThs8C-xeB9rRWN9lhW3VRsb9VHyb4zFb1GJD9vZ3vsfJqi_Q-CPuEdf323qzNdLkJoFijKsIAjD8C9v78p_8gG7rg=w408-h306-k-no',
    NULL,
    4.5,
    1490,
    'seed/checkin-ca-chep-hoa-rong',
    16.0629054,
    108.2298191,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 15. Google Maps: https://www.google.com/maps/place/C%C3%B4ng+vi%C3%AAn+Bi%E1%BB%83n+%C4%90%C3%B4ng/@16.0703173,108.2458368,17z/data=!3m1!4b1!4m6!3m5!1s0x314217f7bce72a73:0x1b777a56c4aa029f!8m2!3d16.0703173!4d108.2458368
(
    'Công viên Biển Đông',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Quảng trường ven biển đường Võ Nguyên Giáp nổi tiếng với đàn chim bồ câu hàng trăm con bay lượn mỗi sáng sớm và chiều muộn. Điểm chụp ảnh mang phong vị châu Âu giữa lòng biển Mỹ Khê cùng tượng Mẹ Âu Cơ. Miễn phí tham quan.',
    '1 Võ Nguyên Giáp, P. Phước Mỹ, Q. Sơn Trà, Đà Nẵng',
    'Mở cả ngày (24/24)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdaowAU8dPt89j1fGsYzjaV_VuGIglHz5Qxh8k3E08l1nqMuSfWMvz84V9jbuYLk3YDKmsXEBZ-ngkCLiOhL6ge5oVHyxWq6l0Du4QN2Cb32FbdrmmJmd4NX8yj0qs3KdxSkWrx=w408-h306-k-no',
    NULL,
    4.5,
    3398,
    'seed/checkin-cong-vien-bien-dong',
    16.0703173,
    108.2458368,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 16. Google Maps: https://www.google.com/maps/place/%C4%90%E1%BB%89nh+B%C3%A0n+C%E1%BB%9D/@16.1199862,108.2759459,17z/data=!3m1!4b1!4m6!3m5!1s0x3142171c7b89ee33:0x4d5462cf6c429ff8!8m2!3d16.1199862!4d108.2759459
(
    'Đỉnh Bàn Cờ',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Điểm ngắm toàn cảnh ở độ cao gần 700m trên bán đảo Sơn Trà nổi tiếng với bức tượng Đế Thích ngồi đánh cờ trên phiến đá. Nơi săn mây, đón bình minh và thu trọn vẻ đẹp thành phố Đà Nẵng cùng vịnh biển vào ống kính. Miễn phí tham quan (hạn chế xe tay ga lên dốc đứng).',
    'Bán đảo Sơn Trà, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    '07:00 - 17:30 (lưu thông đèo)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLetCVcmqsB8NdRECmkqLgLMwMPzNiGmmUWRyvQPQsCp2liQfg_aoxGruVKlSGpoRxq_E4RVgjCeIfZAb5jgbWC4CZQv-H-OL9BnpEiS14Umw2LVQAFa4haCxFM0ja8nH0_ybxkq3Q=w408-h271-k-no',
    NULL,
    4.5,
    1796,
    'seed/checkin-dinh-ban-co',
    16.1199862,
    108.2759459,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 17. Google Maps: https://www.google.com/maps/place/C%C3%A2y+%C4%91a+S%C6%A1n+Tr%C3%A0/@16.1225401,108.3317027,17z/data=!3m1!4b1!4m6!3m5!1s0x314216a698d363b7:0xdbb00f1c305a6104!8m2!3d16.1225401!4d108.3317027
(
    'Cây đa Sơn Trà',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cụm cây đa di sản cổ thụ hàng trăm năm tuổi tại Tiểu khu 63 bán đảo Sơn Trà với tán rộng sum suê và hàng chục rễ phụ đâm thẳng xuống lòng đất đầy kỳ vĩ. Điểm dừng chân khám phá thiên nhiên hoang sơ và chụp ảnh rừng nguyên sinh độc đáo. Miễn phí tham quan.',
    'Tiểu khu 63 Bán đảo Sơn Trà, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    '07:30 - 17:00',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcXaNIhzTLp4EMOdxC8CmBpHzuSBa0Lc3O80QM3A8HOL1lGAUyrDjvIXLwbAnapu1DoihX4JaGqubo7_w7QLxFgv4I4QnN0Z9pVwSQgFg0vYvQxvIEI65c1ePRoH6c9TwXIdKN-=w408-h306-k-no',
    NULL,
    4.5,
    320,
    'seed/checkin-cay-da-son-tra',
    16.1225401,
    108.3317027,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 18. Google Maps: https://www.google.com/maps/place/H%E1%BB%93+Xanh,+S%C6%A1n+Tr%C3%A0,+%C4%90%C3%A0+N%E1%BA%B5ng,+Vi%E1%BB%87t+Nam/@16.097047,108.2675457,17z/data=!4m6!3m5!1s0x314217db86d7f27d:0xda8cbfa16b2f9d1!8m2!3d16.097047!4d108.2675457
(
    'Hồ Xanh',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Hồ nước ngọt tự nhiên nằm uốn lượn ngay bên cung đường Hoàng Sa dẫn lên bán đảo Sơn Trà với mặt nước trong vắt phản chiếu sắc xanh cây cỏ và núi đá. Phim trường chụp ảnh cưới và điểm check-in dã ngoại quen thuộc gần Bãi Bụt. Miễn phí tham quan.',
    'Đường Hoàng Sa, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    'Mở cả ngày (24/24)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLd0cqx1zojDc_JpEUjPRxCHclnliMzotJ1IHSgVWU3OaKifq6mH1VrD-zEP3A3HHh2Bgl-7CbWwCnMSFnEUsQeY6xOtduoorro_ZmW1uwR4_46VOTu_3dkLgDHlPYD2LHAMsCPD=w408-h306-k-no',
    NULL,
    4.5,
    0,
    'seed/checkin-ho-xanh-son-tra',
    16.0970470,
    108.2675457,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 19. Google Maps: https://www.google.com/maps/place/H%E1%BA%A3i+%C4%91%C4%83ng+Ti%C3%AAn+Sa/@16.1396875,108.3220625,17z/data=!3m1!4b1!4m6!3m5!1s0x31423dd18d128a23:0xab60f4ad03227395!8m2!3d16.1396875!4d108.3220625
(
    'Hải đăng Tiên Sa',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Ngọn hải đăng cổ xây dựng từ thời Pháp nằm trên mũi Đông bán đảo Sơn Trà, sơn hai tông trắng vàng nổi bật giữa nền trời biển xanh ngắt. Từ đây có thể phóng tầm mắt ngắm cảng Tiên Sa và toàn cảnh vịnh biển. Vé vào cổng tham quan: 20.000đ - 25.000đ/người.',
    'Bán đảo Sơn Trà, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    '07:00 - 21:00',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLd4ZGWfr05w3weU3e2AlE00vx3yHjuhBiox4qPbcymOAKBBcNu2Ol2LK_iR6e3qZGMQhnjx6JMAJ_eDFjt8LS6uaYB47-aYPpk4RwiUvKBvd-_MFgJYDimEKqEyd4xjVocZSU72nQ=w408-h544-k-no',
    NULL,
    4.3,
    479,
    'seed/checkin-hai-dang-tien-sa',
    16.1396875,
    108.3220625,
    20000,
    25000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 20. Google Maps: https://www.google.com/maps/place/M%C5%A9i+Ngh%C3%AA/@16.1186244,108.3368715,17z/data=!3m1!4b1!4m6!3m5!1s0x31423e0ba11a79fd:0x8f8037a21e1385fc!8m2!3d16.1186244!4d108.3368715
(
    'Mũi Nghê',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Mỏm đá nhô ra biển ở cực Đông Nam bán đảo Sơn Trà mang hình dáng đầu sư tử biển, nơi đón ánh bình minh đầu tiên tại thành phố Đà Nẵng. Nổi tiếng với hồ nước tự nhiên giữa gành đá và cung trekking cho dân phượt. Miễn phí tham quan.',
    'Phía Đông Nam Bán đảo Sơn Trà, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    'Mở cả ngày (24/24)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcA5r85RGBK-VI-5_oGJN_iMHrY0SUbPh7fj1awduFugI5m9bvRzGq13jhI-ZSWaQ29o1j0cQScEbU0EBlRPFsU_6YyX4j4Fs9iEiFXwPWyDGWbJYVBfELfn3n2di7EQO5qMn4e=w408-h398-k-no',
    NULL,
    4.6,
    394,
    'seed/checkin-mui-nghe',
    16.1186244,
    108.3368715,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 21. Google Maps: https://www.google.com/maps/place/Nh%C3%A0+V%E1%BB%8Dng+C%E1%BA%A3nh/@16.1351089,108.2453758,17z/data=!3m1!4b1!4m6!3m5!1s0x31423d36cec8c0d3:0xb004d995e07257e2!8m2!3d16.1351089!4d108.2453758
(
    'Nhà Vọng Cảnh',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Chòi nghỉ chân nhô ra sườn núi ở độ cao hơn 500m trên đường lên đỉnh Sơn Trà, sở hữu tầm nhìn không vật cản ra vịnh Đà Nẵng, cảng Tiên Sa và ngọn hải đăng xa xa. Điểm hóng gió và chụp ảnh núi biển giao hòa tuyệt đẹp. Miễn phí tham quan.',
    'Bán đảo Sơn Trà, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    'Mở cả ngày (24/24)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcZ-xByLHdw1zOEBc81IKpuQyUE_ZxcLzlkd5IjgbkVRWevv42GdLpnYop8GVgsOxVOC_msD3xz-hZoX9lat7quagYZj-7RDAYxL1dlYERMzdWIcoK4K-S_erLeiHyrrTifuGQPaw=w408-h306-k-no',
    NULL,
    4.5,
    1146,
    'seed/checkin-nha-vong-canh',
    16.1351089,
    108.2453758,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 22. Google Maps: https://www.google.com/maps/place/B%E1%BA%A3o+t%C3%A0ng+3D+Art+In+Paradise/@16.0954282,108.2431088,17z/data=!3m1!4b1!4m6!3m5!1s0x314217f750645271:0x91c392fc753f0fb0!8m2!3d16.0954282!4d108.2431088
(
    'Bảo tàng 3D Art In Paradise',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Thế giới tranh đánh lừa thị giác 3D lớn tại Đà Nẵng với hàng trăm tác phẩm nghệ thuật theo nhiều chủ đề như Đại dương, Safari, Ai Cập cổ đại và Thế giới kỳ ảo. Giá vé: khách Việt Nam 140.000đ (trẻ em 100.000đ); khách nước ngoài 200.000đ (trẻ dưới 1m miễn phí).',
    'Lô C2-10 Trần Nhân Tông, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    '08:30 - 22:00',
    '+84 911 641 100',
    'http://artinparadise.com.vn/',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcVW9uFHccdlp4Cq1OkcOUFAmyItDaUz-eIY2OB3boEsowHcuzQ9Ue-DRDXbJlSNGdsymPQLX-emrpn305dZHXzN2aeOpohImn0vqJ4A4wvibkaAomblA9MgDwGTE9OuDDos-WY=w408-h272-k-no',
    NULL,
    4.4,
    3448,
    'seed/checkin-3d-art-in-paradise',
    16.0954282,
    108.2431088,
    140000,
    200000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 23. Google Maps: https://www.google.com/maps/place/Radar+S%C6%A1n+Tr%C3%A0+1/@16.133828,108.2464926,17z/data=!3m1!4b1!4m6!3m5!1s0x31423d36e009b83d:0x2f48e36f3fa3e4ec!8m2!3d16.133828!4d108.2464926
(
    'Radar Sơn Trà 1',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Trạm radar hàng không mang biệt danh Mắt thần Đông Dương nằm trên đỉnh núi Sơn Trà, nổi bật với hai quả cầu radar trắng khổng lồ giữa mây trời. Du khách thường dừng tại đoạn đường bên ngoài khuôn viên để check-in góc núi rừng kỳ vĩ. Miễn phí ngắm cảnh từ bên ngoài.',
    'Đỉnh núi Sơn Trà, P. Thọ Quang, Q. Sơn Trà, Đà Nẵng',
    'Mở cả ngày (Tham quan cung đường đèo ban ngày)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLf1FDdGMG2fTTANld97i4WVX4tlC6qIhP9R5rgWnLr6ytapA0-iJygXqzr4Sw8ZEK7qIAaw1X8UMzd9tQgCkNE85Owj62DM0s2VLVihluq1jkZzwGWguHdK8I7hqzqD_vNiQkRrKw=w408-h272-k-no',
    NULL,
    4.4,
    159,
    'seed/checkin-radar-son-tra-1',
    16.1338280,
    108.2464926,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- QUẬN NGŨ HÀNH SƠN (5 địa điểm)
-- -----------------------------------------------------------------------------

-- 24. Google Maps: https://www.google.com/maps/place/L%C3%A0ng+%C4%91%C3%A1+m%E1%BB%B9+ngh%E1%BB%87+Non+N%C6%B0%E1%BB%9Bc/@16.0076269,108.2618844,17z/data=!3m1!4b1!4m6!3m5!1s0x314210a5e8dc905d:0xceab9c60e0a58e23!8m2!3d16.0076269!4d108.2618844!16s%2Fg%2F1hm3j0m4n?hl=vi
(
    'Làng đá mỹ nghệ Non Nước',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Làng nghề truyền thống hơn 300 năm tuổi dưới chân Ngũ Hành Sơn quy tụ hàng trăm cơ sở chế tác tượng đá cẩm thạch tinh xảo. Không gian trưng bày tượng nghệ thuật ngoài trời đồ sộ tạo nên background check-in đậm nét thủ công mỹ nghệ. Miễn phí tham quan.',
    '45 Huyền Trân Công Chúa, P. Hòa Hải, Q. Ngũ Hành Sơn, Đà Nẵng',
    'Mở cả ngày (Cơ sở mở 08:00 - 18:00)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/geougc/AF1QipO0D5oTHy1wjdlInvFAKHc9lXZlYWe3k_Xjtyr2=h400-no',
    NULL,
    4.4,
    1732,
    'seed/checkin-lang-da-non-nuoc',
    16.0076269,
    108.2618844,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 25. Google Maps: https://www.google.com/maps/place/KHU+PH%E1%BB%90+DU+L%E1%BB%8ACH+AN+TH%C6%AF%E1%BB%A2NG/@16.0504106,108.243572,17z/data=!3m1!4b1!4m6!3m5!1s0x314217112ea1bc83:0x1b9d14693836eb3d!8m2!3d16.0504106!4d108.243572!16s%2Fg%2F11b6ddn631?hl=vi
(
    'KHU PHỐ DU LỊCH AN THƯỢNG',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Phố Tây sôi động bậc nhất bên bãi biển Mỹ Khê với tổ hợp đường đi bộ lát đá, quán cafe phong cách nhiệt đới, nhà hàng quốc tế và đèn đường rực rỡ. Địa điểm dạo phố đêm, chụp ảnh street-style trẻ trung. Miễn phí dạo phố.',
    '298 Võ Nguyên Giáp, P. Mỹ An, Q. Ngũ Hành Sơn, Đà Nẵng',
    'Mở cả ngày (nhộn nhịp 17:00 - 24:00)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeSLHm_moo6mEZO9TuMKRW-j_99A2GV4k7CC-4jbnyGMeF2ob7kwyu-Cut6QvhFu5Cep0msn72eKUaZvadWjSU54W6Fj6Z_yophznSH-rT8QCj6CYRBwLEWZ2MW_Df_2Jero3-BQXmpuTWn=w408-h306-k-no',
    NULL,
    4.7,
    11,
    'seed/checkin-khu-pho-an-thuong',
    16.0504106,
    108.2435720,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 26. Google Maps: https://www.google.com/maps/place/Qu%E1%BA%A3ng+tr%C6%B0%E1%BB%9Dng+FPT+CITY/@15.9868779,108.2625807,17z/data=!3m1!4b1!4m6!3m5!1s0x3142111d4e0b04c9:0x8797f1f6c4d7ec49!8m2!3d15.9868779!4d108.2625807!16s%2Fg%2F11pv7v234b?hl=vi
(
    'Quảng trường FPT CITY',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Công viên quảng trường trung tâm trong Khu đô thị FPT City Đà Nẵng với thảm cỏ xanh mướt, đường dạo bộ uốn lượn và hồ cảnh quan hiện đại. Điểm check-in dã ngoại chiều tà và ngắm kiến trúc khuôn viên khu công nghệ xanh phía Nam thành phố. Miễn phí tham quan.',
    'Đường Võ Quí Huân, KĐT FPT City, P. Hòa Hải, Q. Ngũ Hành Sơn, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcIDe__GRCHdRKAIMZA7qpNSnSXzHFVYd4ze02nT0cR8q4lL6MrLzlpaVp7Vcgn6CTSucAMvlnJgksZAMGW2RGu2FX4JeqaXj6zgLYlOWvMm3Y-twae0RSh6ukml5kJQC1NdrQu-tmrzlMC=w408-h306-k-no',
    NULL,
    4.6,
    14,
    'seed/checkin-quang-truong-fpt-city',
    15.9868779,
    108.2625807,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 27. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+C%E1%BB%95+C%C3%B2/@15.9840901,108.2606876,17z/data=!3m1!4b1!4m6!3m5!1s0x314211234a6ef4e5:0x221c6063bb8c7921!8m2!3d15.9840901!4d108.2606876!16s%2Fg%2F11cs27s_89?hl=vi
(
    'Cầu Cổ Cò',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu thanh thoát bắc qua dòng sông Cổ Cò đoạn giáp khu đô thị FPT City và trục đường hướng biển Non Nước. Khung cảnh sông nước yên bình, hàng dừa ven bờ và nắng chiều phản chiếu tạo nên góc chụp ảnh hoàng hôn thơ mộng. Miễn phí tham quan.',
    'Đường Võ Quí Huân - Nam Kỳ Khởi Nghĩa, P. Hòa Hải, Q. Ngũ Hành Sơn, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfpAqN6z4TM9jJCYaY5D-gOQURR26xqXsBFjTTg7qUWAX0Rq2KKMVnpP8M5fjWa4qARuZOo4jRZpBixX3GgiKJeQcCn2XjfUzOblvLL6Sjoz82WPjTWaoUq-zgM91Xr9JjfijNd=w426-h240-k-no',
    NULL,
    4.6,
    39,
    'seed/checkin-cau-co-co',
    15.9840901,
    108.2606876,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 28. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+Minh+M%E1%BA%A1ng/@16.0125867,108.2465366,17z/data=!3m1!4b1!4m6!3m5!1s0x314210a4db7d5db1:0xc6d790d85918732e!8m2!3d16.0125867!4d108.2465366!16s%2Fg%2F11bz0p6mms?hl=vi
(
    'Cầu Minh Mạng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu hiện đại trên trục đường Minh Mạng nối trung tâm Ngũ Hành Sơn ra dải resort ven biển Non Nước. Từ thành cầu có thể ngắm dòng sông Cổ Cò êm đềm và dáng núi Ngũ Hành Sơn sừng sững phía chân trời. Miễn phí tham quan.',
    'Đường Minh Mạng, P. Khuê Mỹ, Q. Ngũ Hành Sơn, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfTtd2xHtPfhRgcDNqGyyNuoCVR-emSJe8aGV2KWEQUDMmoLMZBemo3e25pMMZLckAJkBjQSQxMMcuVpW0J_8wxbSJwOeuLSdIOEONdbPmoxQlp86gmBOUuUPmtWz7B65mRtyZe=w426-h240-k-no',
    NULL,
    4.6,
    64,
    'seed/checkin-cau-minh-mang',
    16.0125867,
    108.2465366,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- QUẬN THANH KHÊ (3 địa điểm)
-- -----------------------------------------------------------------------------

-- 29. Google Maps: https://www.google.com/maps/place/H%E1%BB%93+C%C3%B4ng+vi%C3%AAn+29%2F3/@16.0617302,108.2040994,17z/data=!3m1!4b1!4m6!3m5!1s0x314218501ff8ae15:0x8532f80ec4fa7d37!8m2!3d16.0617302!4d108.2040994!16s%2Fg%2F11b6ghsw50?hl=vi
(
    'Hồ Công viên 29/3',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Công viên lá phổi xanh lớn nhất nội đô Đà Nẵng nổi bật với hồ nước rộng, cây cầu chữ Y vươn ra mặt hồ và hàng cây cổ thụ rợp bóng. Không gian dạo mát, đạp vịt và chụp ảnh picnic cuối tuần ngay trung tâm quận Thanh Khê. Miễn phí vào cổng.',
    'Đường Điện Biên Phủ - Nguyễn Tri Phương, P. Thạc Gián, Q. Thanh Khê, Đà Nẵng',
    '05:00 - 22:00',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeQtl-PwS0Gi8WTxkbpFlPZa2l1d0F86CRM3bAsBcUwcdRJeu3y-yQTo5Vem6hr6WhAliinEKIq0CWfXawwmmMoCU_ITtWGOjf639PbVBc-rGX9RLJsJFuAF7Tdpvd5wiP-IdjV7w=w408-h271-k-no',
    NULL,
    4.5,
    81,
    'seed/checkin-ho-cong-vien-29-3',
    16.0617302,
    108.2040994,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 30. Google Maps: https://www.google.com/maps/place/C%C3%B4ng+vi%C3%AAn+bi%E1%BB%83n+H%C3%A0+Kh%C3%AA/@16.0718567,108.1923769,17z/data=!3m1!4b1!4m6!3m5!1s0x314218451bdfef33:0x1b1c341b55909249!8m2!3d16.0718567!4d108.1923769!16s%2Fg%2F11ghq84b9y?hl=vi
(
    'Công viên biển Hà Khê',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Công viên biển khang trang nằm dọc đường Nguyễn Tất Thành bên vịnh Đà Nẵng, nổi bật với con đường đi bộ ven biển, hàng dừa xanh và tượng đài cảnh quan. Điểm check-in ngắm bình minh sớm và đón gió biển mát lành của người dân Thanh Khê. Miễn phí tham quan.',
    'Đường Nguyễn Tất Thành, P. Xuân Hà, Q. Thanh Khê, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLc5SCD1473jWj-_HgaAIRy0es2xCLsvhdStUWx__5w5yejHD6QQYdvLfEOnVpchH6Nyfnph7OkiLBG_OD9Vz0JOH_aI5ORLPUqSZWRuSP9Qic687RrnrMe-5phr4Tlary5m3JWFpuO7BQ=w426-h240-k-no',
    NULL,
    4.5,
    1150,
    'seed/checkin-cong-vien-bien-ha-khe',
    16.0718567,
    108.1923769,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 31. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+v%C6%B0%E1%BB%A3t+Ng%C3%A3+Ba+Hu%E1%BA%BF/@16.0645604,108.1764722,17z/data=!3m1!4b1!4m6!3m5!1s0x3142190100438183:0x393c83b8b609bc97!8m2!3d16.0645604!4d108.1764722!16s%2Fg%2F11b61b_4l_?hl=vi
(
    'Cầu vượt Ngã Ba Huế',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Nút giao thông 3 tầng hình vòng xuyến khổng lồ với trụ tháp dây văng hình chữ Y vươn cao 65m lấy cảm hứng từ biểu tượng Linga - Yoni Champa. Góc chụp ảnh kiến trúc giao thông hiện đại rực rỡ ánh đèn LED từ công viên chân cầu vào ban đêm. Miễn phí ngắm cảnh.',
    'Nút giao Ngã Ba Huế, P. An Khê, Q. Thanh Khê, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdJ86j5738wqwJ_qY6L3OI7brtFY_pJ-NJOOO72pXdCSNSlTE_52peM1YbbzmRe3zR4_zCa8dZi7kpCX6UQvPtjZgqF4ZqWFGlGUsi6yD98ZdxgpRizVbvQbk6pvB91H6IhkvU=w408-h396-k-no',
    NULL,
    4.7,
    793,
    'seed/checkin-cau-vuot-nga-ba-hue',
    16.0645604,
    108.1764722,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- QUẬN CẨM LỆ (4 địa điểm)
-- -----------------------------------------------------------------------------

-- 32. Google Maps: https://www.google.com/maps/place/C%C3%B4ng+vi%C3%AAn+Thanh+Ni%C3%AAn/@16.0267491,108.2149119,17z/data=!4m10!1m2!2m1!1zQ8O0bmcgdmnDqm4gVGhhbmggTmnDqm4gxJDDoCBO4bq1bmc!3m6!1s0x314219449be90635:0xa293c17e58d1068d!8m2!3d16.0267491!4d108.2149119!16s%2Fg%2F11lqjs7cy3?hl=vi
(
    'Công viên Thanh Niên',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Công viên rộng lớn thuộc quận Cẩm Lệ nổi bật với hồ điều hòa thoáng đãng, những hàng cây xanh rợp bóng và không gian sân vườn sạch đẹp. Địa điểm chạy bộ, dã ngoại cuối tuần và chụp ảnh ngoại cảnh thiên nhiên yên tĩnh. Miễn phí tham quan.',
    '5 Đường Nguyễn Thượng Hiền, P. Khuê Trung, Q. Cẩm Lệ, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcmSn4UjJn3JOd-nTIuqA9LE0QPle8EIB-H5Hkw6RnjxrbWdWr0eblDLM4IZb-RBqwEcLRqfbEnIStY3eKk2muihav8DloBc11urqq9DhJ99xjOGgVsI87R8H_M1VsvcTaE04wqt65SPH0=w408-h291-k-no',
    NULL,
    4.7,
    143,
    'seed/checkin-cong-vien-thanh-nien',
    16.0267491,
    108.2149119,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 33. Google Maps: https://www.google.com/maps/place/C%C3%B4ng+vi%C3%AAn+H%C3%B2a+Xu%C3%A2n/@16.0148795,108.2194286,17z/data=!4m6!3m5!1s0x31421a1e98f0d0bd:0xe8285e7305f1760c!8m2!3d16.0148795!4d108.2194286!16s%2Fg%2F11f5dywcnt?hl=vi
(
    'Công viên Hòa Xuân',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Không gian công viên cộng đồng thoáng mát nằm trong khu đô thị sinh thái Hòa Xuân bên sông Cẩm Lệ, sở hữu hàng cây xanh, lối đi bộ ven công viên và sân tập thể thao. Phù hợp dạo bộ thư giãn và chụp ảnh đời thường chiều hoàng hôn. Miễn phí tham quan.',
    'Khu Cồn Dầu - Thanh Lương 18, P. Hòa Xuân, Q. Cẩm Lệ, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcjVS21IWZ90fyV9hsGVe59UXlpn5VySP_BU5abu2h697qBRPS8kI-ysByHcKeDxSDrgErIIeurxwv3skYFFTAiEd0yofnrF3eb9KoELtpQq_QFhAwnLCotcpcU18qWLUmJAcY=w408-h306-k-no',
    NULL,
    4.3,
    35,
    'seed/checkin-cong-vien-hoa-xuan',
    16.0148795,
    108.2194286,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 34. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+C%E1%BA%A9m+L%E1%BB%87/@16.0089231,108.2068196,17z/data=!3m1!4b1!4m6!3m5!1s0x31421a3b4e8a83b9:0xd8bb071fa4aac29!8m2!3d16.0089231!4d108.2068196!16s%2Fg%2F11bzypgl71?hl=vi
(
    'Cầu Cẩm Lệ',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu huyết mạch bắc qua dòng sông Cẩm Lệ kết nối khu vực trung tâm quận với Hòa Xuân và vùng ven Hòa Vang. Từ bờ kè gần chân cầu vào lúc bình minh hoặc chiều tà dễ dàng bắt trọn cảnh sông nước êm đềm cùng nhịp sống địa phương. Miễn phí tham quan.',
    'Cầu Cẩm Lệ, P. Khuê Trung, Q. Cẩm Lệ, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdHZsTUtgVlH1MJURoJXMeltMj2xgdAwPi4k9KeWyl3E3JbCt1KuO0lyI8t_KMEgiPCCLDwR5pcfawSxgM8fov1UkfCliLBiefWf1NN1kxEjJ7y64aeu-B5jlujSoNXJq0vnwXy=w408-h306-k-no',
    NULL,
    4.2,
    60,
    'seed/checkin-cau-cam-le',
    16.0089231,
    108.2068196,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 35. Google Maps: https://www.google.com/maps/place/Trung+t%C3%A2m+H%E1%BB%99i+ch%E1%BB%A3+Tri%E1%BB%83n+l%C3%A3m+%C4%90%C3%A0+N%E1%BA%B5ng/@16.0219157,108.217274,17z/data=!3m1!4b1!4m6!3m5!1s0x314219f4e9a55949:0x3777b4b0c3d5e5d7!8m2!3d16.0219157!4d108.217274!16s%2Fg%2F1hc2j4krz?hl=vi
(
    'Trung tâm Hội chợ Triển lãm Đà Nẵng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Khu tổ hợp triển lãm quy mô lớn mặt tiền đường Cách Mạng Tháng 8 với kiến trúc mái vòm không gian rộng mở và quảng trường sự kiện ngoài trời. Thường diễn ra các hội chợ thương mại, lễ hội hoa xuân và triển lãm trưng bày hấp dẫn. Miễn phí tham quan khuôn viên (một số triển lãm có vé riêng).',
    '9 Cách Mạng Tháng 8, P. Khuê Trung, Q. Cẩm Lệ, Đà Nẵng',
    'Mở cả ngày (theo lịch sự kiện)',
    '+84 985 001 011',
    'https://www.facebook.com/TrungtamhoichotrienlamDaNang',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeBYYaooh8MBpwoA_cTt6Mo76-lOV3netvWRNWESWJp8w5ezqf6c-Dg-0Fn-Wpa4jWOb6wC2MNowhN-S29wNOg1uEuRnWZMztJNDLym-ZnnlVcNQQ-wuN5uf8wYrwCzOOExOnzn=w425-h240-k-no',
    NULL,
    4.3,
    1261,
    'seed/checkin-trung-tam-trien-lam-dn',
    16.0219157,
    108.2172740,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- QUẬN LIÊN CHIỂU (5 địa điểm)
-- -----------------------------------------------------------------------------

-- 36. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+V%C3%B2m+%C4%90%E1%BB%93n+C%E1%BA%A3/@16.1950468,108.1342939,17z/data=!3m1!4b1!4m6!3m5!1s0x314187042a4a75e3:0xc7a04870c538cb10!8m2!3d16.1950468!4d108.1342939!16s%2Fg%2F11fdj4v53_?hl=vi
(
    'Cầu Vòm Đồn Cả',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu đường sắt vòm đá rêu phong nằm ẩn mình dưới chân đèo Hải Vân gần ga Bắc Hải Vân, phía dưới là dòng suối mát trong lành. Tọa độ săn ảnh tàu hỏa uốn lượn qua rừng xanh được cộng đồng phượt thủ săn đón bậc nhất. Miễn phí tham quan (chú ý an toàn đường sắt).',
    'Ga Đồn Cả, Đèo Hải Vân, P. Hòa Hiệp Bắc, Q. Liên Chiểu, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdoNM7_B8UGcJbZ1Ge4p2Hxildg3NCsugt4P6wkZ0WZJmDNM15YPQOjauxn0TOEvmraWC39ZHvqJk_Qb1A5rFV0oiQjdB52GwJ-fPI5bOykWE5q4o3Cf7ZsKah92OdbZPcxRHQ0Z0p84iB8=w408-h544-k-no',
    NULL,
    4.6,
    623,
    'seed/checkin-cau-vom-don-ca',
    16.1950468,
    108.1342939,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 37. Google Maps: https://www.google.com/maps/place/C%C3%A2y+th%C3%B4ng+C%C3%B4+%C4%91%C6%A1n/@16.1824424,108.1352427,17z/data=!3m1!4b1!4m6!3m5!1s0x314187e148e678bf:0xfa11854ea21d1d9f!8m2!3d16.1824424!4d108.1352427!16s%2Fg%2F11lflg8263?hl=vi
(
    'Cây thông Cô đơn',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây thông mọc đơn độc vươn cao ngay khúc cua nổi tiếng trên đèo Hải Vân, mở ra tầm nhìn ngoạn mục xuống biển Lăng Cô và đường đèo uốn lượn. Điểm dừng chân check-in kinh điển cho du khách đi xe máy vượt đèo ngắm bình minh và hoàng hôn. Miễn phí tham quan.',
    'Đèo Hải Vân, P. Hòa Hiệp Bắc, Q. Liên Chiểu, Đà Nẵng',
    'Mở cả ngày (An toàn vào ban ngày)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLcgEd3OqJOHMTOCjdKKYFMXP3sVdKziJfIJ_eOLZ5nNNYgn1BPcR8BOJrV9xnQUHknaU24cNT7CSZvKnHat4A-8ExLBcvuWbBFSRAaJmhJQ5e4FEWMRXk8GkDizTEk_dnujasmsig=w408-h544-k-no',
    NULL,
    4.4,
    605,
    'seed/checkin-cay-thong-co-don',
    16.1824424,
    108.1352427,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 38. Google Maps: https://www.google.com/maps/place/B%C3%A3i+Bi%E1%BB%83n+l%C3%A0ng+v%C3%A2n/@16.1472535,108.1315579,17z/data=!3m1!4b1!4m6!3m5!1s0x31422116045ee3df:0x87a7cb740d12e690!8m2!3d16.1466092!4d108.1311059!16s%2Fg%2F11b6dwcsqj?hl=vi
(
    'Làng Vân (Bãi Biển làng vân)',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Ngôi làng nhỏ biệt lập nằm nép mình dưới chân đèo Hải Vân với bãi cát trắng hoang sơ, nước biển xanh trong và background vách núi hùng vĩ. Thiên đường cắm trại qua đêm, đón bình minh và check-in thiên nhiên tách biệt hoàn toàn phố thị. Miễn phí tham quan (thuê thuyền/dịch vụ tính riêng).',
    'Chân đèo Hải Vân, P. Hòa Hiệp Bắc, Q. Liên Chiểu, Đà Nẵng',
    'Mở cả ngày',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLe4mfGKmOhs3iDECyQ0o5zVZR-UJrhpuSPD7wY80sWUFnS3Ig2xRm6CbadpS05rTO50Bj_kv7DcS-CxFMOnVO9VkoO_uFVQzY0X9mfu438DO9bsK9auQ3RFxny-LCVa0AGdz_EqtyMk8gY=w408-h271-k-no',
    NULL,
    4.5,
    109,
    'seed/checkin-lang-van',
    16.1466092,
    108.1311059,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 39. Google Maps: https://www.google.com/maps/place/Su%E1%BB%91i+L%C6%B0%C6%A1ng+-+Hai+Van+Park/@16.1436154,108.1189334,17z/data=!3m1!4b1!4m6!3m5!1s0x314221008dffdf2d:0xceab5fcb8b7aebaa!8m2!3d16.1436154!4d108.1189334!16s%2Fg%2F1tdy0661?hl=vi
(
    'Suối Lương - Hai Van Park',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Khu du lịch sinh thái nằm ngay phía Nam hầm Hải Vân với cổng chào thiết kế hình cánh chim Lạc khổng lồ, dòng suối tự nhiên mát rượi và cầu treo gỗ giữa rừng cây. Vé vào cổng tham quan: người lớn 50.000đ, trẻ em 20.000đ (thuê chòi và ăn uống tính riêng).',
    'Phía Nam Hầm Hải Vân, P. Hòa Hiệp Bắc, Q. Liên Chiểu, Đà Nẵng',
    '07:30 - 18:00',
    '+84 236 3773 222',
    'https://suoiluong.vn',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdms2i8M6ZE0dheGCP0hcNPD9EJAxuLtG1LRqBoDYdR4p7K4j6xpYRffMVE97iJxmMPYbKkGX9BlLvVBejUToD2P_xX4dzgxsG5_wXUJ0VtLTSSKDbXUSdidcBhvVjLDbZ3un65Q3f1yyaU=w425-h240-k-no',
    NULL,
    4.0,
    991,
    'seed/checkin-suoi-luong-hai-van',
    16.1436154,
    108.1189334,
    20000,
    50000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 40. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+v%C6%B0%E1%BB%A3t+%C4%91i+b%E1%BB%99+Mikazuki/@16.0946471,108.1465699,17z/data=!3m1!4b1!4m6!3m5!1s0x31421f26a19f2ba9:0x87eeef879c9339e3!8m2!3d16.0946471!4d108.1465699!16s%2Fg%2F11v5k91ffm?hl=vi
(
    'Cầu vượt đi bộ Mikazuki',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu đi bộ bắc ngang đường Nguyễn Tất Thành mang đậm kiến trúc Nhật Bản với hai trụ tròn đỏ son, dầm thép uốn lượn và lan can mô phỏng sóng biển. Điểm check-in siêu hot về đêm khi cầu lên đèn lung linh hướng thẳng ra bãi biển Xuân Thiều. Miễn phí tham quan.',
    'Đường Nguyễn Tất Thành, P. Hòa Hiệp Nam, Q. Liên Chiểu, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdGI36kCjyLGTOmYFdzsfw_bDvgknDKO3A_XEI6AabGkOWQ0WojD5wR6zvvR8KeLD34C10Qla8DpLS85WDFkpx8me344WkMMQdxQNLj4pYTkpleSmvz0UuXEcvt-KbLoAZ7kAQF=w408-h306-k-no',
    NULL,
    4.6,
    377,
    'seed/checkin-cau-vuot-mikazuki',
    16.0946471,
    108.1465699,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- -----------------------------------------------------------------------------
-- HUYỆN HÒA VANG (9 địa điểm) & CẦU TIÊN SƠN (#48: Hải Châu - Ngũ Hành Sơn)
-- -----------------------------------------------------------------------------

-- 41. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+V%C3%A0ng/@15.9949375,107.9965625,17z/data=!3m1!4b1!4m6!3m5!1s0x3141f71fecf60551:0x41ab919f860fa03c!8m2!3d15.9949375!4d107.9965625!16s%2Fg%2F11h0ffl503?hl=vi
(
    'Cầu Vàng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Kiệt tác kiến trúc biểu tượng toàn cầu nằm ở độ cao 1.414m tại Sun World Bà Nà Hills với đôi bàn tay khổng lồ nâng dải lụa vàng uốn lượn giữa biển mây. Vé cáp treo khứ hồi Sun World Bà Nà Hills: 650.000đ (người Đà Nẵng) - 1.000.000đ (khách ngoại tỉnh); combo kèm buffet ~1.300.000đ.',
    'Sun World Ba Na Hills, Thôn An Sơn, Xã Hòa Ninh, H. Hòa Vang, Đà Nẵng',
    '08:00 - 18:30',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeOCHpehDnrZGpF6c823gCzOVVh5JClG_JbuQM7XR9LVk436_XTDqDKl7KalrRTvBXs0-ePI-zG-EwXwM2WVguLHpVcglVZocJ7TdVsbQw5j8qSuxmmgCpECyipF8Ks-gmxHJP0Jw=w408-h306-k-no',
    NULL,
    4.7,
    15464,
    'seed/checkin-cau-vang-ba-na',
    15.9949375,
    107.9965625,
    650000,
    1000000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 42. Google Maps: https://www.google.com/maps/place/Du+DoMe+Square/@15.9958117,107.9963283,17z/data=!3m1!4b1!4m6!3m5!1s0x3141f7360256eaab:0xdf29143bf2bb1797!8m2!3d15.9958117!4d107.9963283!16s%2Fg%2F11b6dwcsqj?hl=vi
(
    'Quảng Trường Du Dôme (Làng Pháp Bà Nà Hills)',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Trái tim của Làng Pháp trên đỉnh Bà Nà Hills với nhà thờ đá Gothic, quảng trường lát gạch, đài phun nước và dãy lâu đài châu Âu cổ kính. Trải nghiệm check-in trời Âu mờ sương cùng chuỗi lễ hội đường phố. Đã bao gồm trong vé cáp treo Bà Nà Hills (650.000đ - 1.000.000đ).',
    'Làng Pháp, Sun World Ba Na Hills, Xã Hòa Ninh, H. Hòa Vang, Đà Nẵng',
    'Mở cả ngày',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdRtwmXzOuui3QVvkoz_P0KaSE5XVA9QUbPVsx0w2gAcJ41pP_sY66kOTtOTW2jMWMWNBrjdvsvhXKInG34tDbZlfIRnP_4c7pFqRCCKzsMEFr7RrhH7h-TL8_ANr7A1PZuWSw=w408-h306-k-no',
    NULL,
    4.6,
    143,
    'seed/checkin-quang-truong-du-dome',
    15.9958117,
    107.9963283,
    650000,
    1000000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 43. Google Maps: https://www.google.com/maps/place/Le+Jardin+D%27Amour/@15.995314,107.994973,17z/data=!3m1!4b1!4m6!3m5!1s0x3141f720059c9d7d:0xfa11854ea21d1d9f!8m2!3d15.995314!4d107.994973!16s%2Fg%2F11f04k6f78?hl=vi
(
    'Vườn Hoa Le Jardin D''Amour',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Quần thể 9 khu vườn hoa rực rỡ sắc màu trên sườn núi Bà Nà với thiết kế mang phong cách Pháp lãng mạn như Vườn Uyên Ương, Vườn Địa Đàng, Vườn Thần Thoại. Nơi tụ hội hàng trăm loài hoa ôn đới nở rộ quanh năm. Đã bao gồm trong vé cáp treo Bà Nà Hills (650.000đ - 1.000.000đ).',
    'Sun World Ba Na Hills, Xã Hòa Ninh, H. Hòa Vang, Đà Nẵng',
    'Mở cả ngày',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLd0arFABxwjGWc7J4HbVJbbItujHWATbdm3at9VR-YuM6wjkjTX9C3shNhE7fEtnMAJTWF2iHQxpOzDN7HuvRucVmG1KP7XG-nVuRBey0mZ77KlPkxqJC9FBBE9iciGNFHm8Kvr=w408-h306-k-no',
    NULL,
    4.4,
    35,
    'seed/checkin-le-jardin-damour',
    15.9953140,
    107.9949730,
    650000,
    1000000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 44. Google Maps: https://www.google.com/maps/place/Lunar+Castle+Gardens/@15.9972382,107.9866032,17z/data=!3m1!4b1!4m6!3m5!1s0x3141f70a16b9cb43:0xa33ecfa8cfaf0618!8m2!3d15.9972382!4d107.9866032!16s%2Fg%2F11hyb9_3t1?hl=vi
(
    'Lunar Castle Gardens (Lâu Đài Mặt Trăng)',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Công trình Lâu đài Mặt Trăng kỳ vĩ phong cách Trung cổ châu Âu kết nối qua tuyến tàu hỏa leo núi trên đỉnh Chúa Bà Nà. Nổi bật với quảng trường Nhật Thực, tháp lâu đài cao vút giữa sương mù và vườn cảnh quan huyền bí. Đã bao gồm trong vé cáp treo Bà Nà Hills (650.000đ - 1.000.000đ).',
    'Sun World Ba Na Hills, Thôn An Sơn, Xã Hòa Ninh, H. Hòa Vang, Đà Nẵng',
    '08:30 - 17:00',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfjV0DO2LrtPXPqhuauHxugD_9K1soEtIuo_lGAYkP59cKOqWOgYBOPN0h-iACZfTLFyFVRVsVvW2eBUFRvBTtCETC7hNiQIBYUQ-o5l0PQW3uxbWBeeITY7hFsi30_HwpGNmWdYxvxrqt3=w408-h544-k-no',
    NULL,
    4.7,
    48,
    'seed/checkin-lunar-castle-gardens',
    15.9972382,
    107.9866032,
    650000,
    1000000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 45. Google Maps: https://www.google.com/maps/place/H%E1%BB%93+Ho%C3%A0+Trung/@16.0799757,108.0699049,15z/data=!3m1!4b1!4m6!3m5!1s0x3142202a0cf16e01:0x4465b8296a6042db!8m2!3d16.0799757!4d108.0699049!16s%2Fg%2F11b6dwcsqj?hl=vi
(
    'Hồ Hoà Trung',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Hồ nước nhân tạo rộng lớn ở Hòa Liên nổi tiếng với thảo nguyên cỏ xanh mênh mông uốn lượn bên các đảo đất nổi giữa hồ vào mùa nước cạn. Thiên đường cắm trại, chèo thuyền kayak và check-in phong cách du mục yên bình. Miễn phí tham quan (thuê thuyền/camping tính riêng).',
    'Xã Hòa Liên, H. Hòa Vang, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdNsiuqztrFKd1laZZ1DF2wUWIqRit8KqFT7VHEt7CllaJfejodTHW0J8_RcKED26XdplUwPB0xUdjWPBVpiD0FbruvjhBmRinqEipJL00Wc4pqGXc3o3qQRitJofYnGB14EgQqQQ=w408-h306-k-no',
    NULL,
    4.3,
    234,
    'seed/checkin-ho-hoa-trung',
    16.0799757,
    108.0699049,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 46. Google Maps: https://www.google.com/maps/place/C%C3%B4ng+vi%C3%AAn+Su%E1%BB%91i+kho%C3%A1ng+n%C3%B3ng+N%C3%BAi+Th%E1%BA%A7n+T%C3%A0i+%C4%90%C3%A0+N%E1%BA%B5ng/@15.9734914,108.0336219,17z/data=!3m1!4b1!4m6!3m5!1s0x314223f038426d03:0x4d5ad778ff95fb52!8m2!3d15.9734914!4d108.0336219!16s%2Fg%2F11b6y06qj9?hl=vi
(
    'Công viên Suối khoáng nóng Núi Thần Tài Đà Nẵng',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Khu du lịch suối khoáng nóng tự nhiên giữa rừng nguyên sinh Bà Nà - Núi Chúa nổi tiếng với tắm onsen chuẩn Nhật, công viên nước, sông Lười, tắm bùn và Công viên Khủng long check-in. Gói Phổ thông người lớn 470.000đ - 490.000đ (trẻ em 1m-1m4: 235.000đ - 245.000đ); combo kèm buffet/tắm bùn lên đến 935.000đ.',
    'Thôn Phú Túc, Xã Hòa Phú, H. Hòa Vang, Đà Nẵng',
    '08:30 - 17:30',
    '+84 898 181 777',
    'https://nuithantai.vn',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeuJ_oasO75BR8-pDUhaw7ZL2znQ8xugoQJsY0pyObapcq9je_2fBY4sszYcQO_kWYATPGKb21egsXmhdJcmomgXGPopVazZVpWYYH--7NtfnZlxXDO7ihJAC-OhvrVWRlx-zcv=w408-h272-k-no',
    NULL,
    4.3,
    4883,
    'seed/checkin-nui-than-tai',
    15.9734914,
    108.0336219,
    470000,
    935000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 47. Google Maps: https://www.google.com/maps/place/H%C3%B2a+Ph%C3%BA+Th%C3%A0nh+Tourist/@15.9602492,108.006939,17z/data=!3m1!4b1!4m6!3m5!1s0x314223b2465719e7:0x52c6f1a8c3d97f8!8m2!3d15.9602492!4d108.006939!16s%2Fg%2F1pp2vb08j?hl=vi
(
    'Hòa Phú Thành Tourist',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Khu du lịch sinh thái mạo hiểm dọc dòng sông Lỗ Đông giữa núi rừng Hòa Phú, nổi bật với trò chơi chèo xuồng cao su trượt thác vượt ghềnh, zipline và cầu treo gỗ ngắm rừng. Vé vào cổng tham quan 150.000đ; trò chơi trượt thác 300.000đ; combo tham quan + trượt thác 420.000đ - 450.000đ.',
    'QL14G, Xã Hòa Phú, H. Hòa Vang, Đà Nẵng',
    '07:30 - 17:30',
    '+84 961 861 689',
    'https://hoaphuthanh.com.vn',
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdMwLu3WvznHpdmdTr_YKPDmqdSi71KH5YMHSyHSnoAkGMge6uhDaPyclgMYvYkqB9DISFBp_-SLGz9LsE-KkUX2YIdSIteRdOLc7C_KjtoBSRR0w1XGIlxsCMQObRgtB42rFo=w426-h240-k-no',
    NULL,
    4.3,
    2193,
    'seed/checkin-hoa-phu-thanh',
    15.9602492,
    108.0069390,
    150000,
    450000,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 48. Google Maps: https://www.google.com/maps/place/C%E1%BA%A7u+Ti%C3%AAn+S%C6%A1n,+%C4%90%C3%A0+N%E1%BA%B5ng,+Vi%E1%BB%87t+Nam/@16.0353346,108.2357338,17z/data=!4m6!3m5!1s0x314219e1916038c3:0x933d3edd23a695f1!8m2!3d16.0353346!4d108.2357338!16s%2Fm%2F0gfh38h?hl=vi
(
    'Cầu Tiên Sơn',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Cây cầu huyết mạch bắc qua sông Hàn nối quận Hải Châu với quận Ngũ Hành Sơn trên tuyến Hành lang Kinh tế Đông - Tây. Sở hữu vỉa hè đi bộ rộng rãi cùng góc nhìn panorama về phía Bắc thu trọn Vòng quay Mặt Trời, cầu Nguyễn Văn Trỗi, cầu Trần Thị Lý và dòng sông Hàn thơ mộng. Miễn phí tham quan.',
    'Đường Xô Viết Nghệ Tĩnh - Hồ Xuân Hương, P. Hòa Cường Nam, Q. Hải Châu / Q. Ngũ Hành Sơn, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLeVmjHlFVRcwiq_0z-v5KyLwzBb-JBGZCJryWYfBfJoWkrUWeKgG3A1P7MiEdjHbLK_QB90ha_eh7MKjJ-dMfPJee19qJJx4X_YYfZ1R7er1MDJwrNpAptyHCOq7nQA7strbESK=w408-h306-k-no',
    NULL,
    4.5,
    0,
    'seed/checkin-cau-tien-son',
    16.0353346,
    108.2357338,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 49. Google Maps: https://www.google.com/maps/place/Gi%E1%BA%BFng+Tr%E1%BB%9Di/@16.02,107.98,12z/data=!4m6!3m5!1s0x3141f6831262b307:0xa64c6ed6f98b579b!8m2!3d16.0347599!4d107.9909156!16s%2Fg%2F11b7csmqgr?hl=vi
(
    'Giếng Trời',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Thác nước tự nhiên nằm sâu giữa rừng nguyên sinh Bà Nà với hồ nước ngọc bích mát lạnh quanh năm và ghềnh đá hùng vĩ bao quanh. Điểm trekking, tắm suối và chụp ảnh khám phá thiên nhiên hoang dã được dân phượt ưa thích. Miễn phí tham quan.',
    'Rừng nguyên sinh Bà Nà, Xã Hòa Ninh, H. Hòa Vang, Đà Nẵng',
    '09:00 - 18:00',
    '+84 962 856 318',
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLfJfI67NPgDFem55LG7aFolcfFmnZ4FWQaq9JltDFuy1uqa7HCZUXOtlQWi8ljnowVYhsqOU64Z9hIlWraPsUCXctGqqL1Kyk9_35MGVreSgv9ePdgMLlZPbQiA4T2YUFPlRjrf8rQcTdV2=w408-h544-k-no',
    NULL,
    4.1,
    118,
    'seed/checkin-gieng-troi',
    16.0347599,
    107.9909156,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
),

-- 50. Google Maps: https://www.google.com/maps/place/H%E1%BB%93+%C4%90%E1%BB%93ng+Xanh+-+%C4%90%E1%BB%93ng+Ngh%E1%BB%87/@15.9477444,108.0694098,15z/data=!3m1!4b1!4m6!3m5!1s0x31421d374a16e2bf:0xfe0c7eac32913b30!8m2!3d15.951284!4d108.0703743!16s%2Fg%2F1td_2njw?hl=vi
(
    'Hồ Đồng Xanh - Đồng Nghệ',
    (SELECT id FROM categories WHERE code = 'CHECKIN' LIMIT 1),
    'Hồ chứa thủy lợi rộng lớn nằm giữa thung lũng núi non trùng điệp ở xã Hòa Khương với mặt hồ phẳng lặng như gương soi. Tọa độ chèo SUP, cắm trại cuối tuần và chụp ảnh cảnh quan sơn thủy hữu tình. Miễn phí tham quan.',
    'Xã Hòa Khương, H. Hòa Vang, Đà Nẵng',
    'Mở cả ngày (24/7)',
    NULL,
    NULL,
    'https://lh3.googleusercontent.com/grass-cs/AABkmLdDHk-G2Wxk5gH461AtjE6W-uKidcUnBO6ENx9qtLSTgtKne2KO1Kkl1WYwvzcbDrVRwL7cZhE3A3q6tH6X3-tN4_gfkgWv3KYR97sQnLMb-sD03tdETFIM57aLIwQnICVsqUo=w426-h240-k-no',
    NULL,
    4.4,
    77,
    'seed/checkin-ho-dong-nghe',
    15.9512840,
    108.0703743,
    0,
    0,
    'ACTIVE',
    NOW(),
    NOW()
);
