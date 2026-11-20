# Các sai lệch phát hiện trước khi đồng bộ

> Tài liệu lịch sử. Những nhận định thiếu chức năng, tên migration và số test bên dưới thuộc thời điểm báo cáo gốc; không mô tả tiến độ hiện tại. Xem [trạng thái yêu cầu](../../planning/requirements-status.md) và [hướng dẫn đọc báo cáo](../README.md).

Bản review ngày 16/11/2026 ghi nhận các sai lệch trước khi triển khai đầy đủ những luồng sau đó. Các mã R-01 đến R-12 được giữ để truy vết nguyên nhân và quyết định sửa; không phải danh sách lỗi còn tồn tại hôm nay. Review dựa trên mã nguồn và bằng chứng có sẵn, không truy vấn DB vận hành hoặc chạy test mới ở thời điểm lập kế hoạch.

## Các phát hiện tại thời điểm review

| Mã / mức | Phát hiện và ảnh hưởng | Bằng chứng | Công việc |
| --- | --- | --- | --- |
| R-01 / P0 | Giá NULL bị hiểu là miễn phí; ngân sách UNKNOWN vẫn có thể hiển thị xanh và tiền còn lại như đầy đủ | [Timeline](../../../mobile/lib/features/itinerary/presentation/widgets/itinerary/timeline_activity_card.dart:83), [budget meter](../../../mobile/lib/features/itinerary/presentation/widgets/itinerary/budget_health_meter.dart:25); backend đã có costComplete/UNKNOWN nhưng model chưa nhận costComplete | SYNC-01/02 |
| R-02 / P0 | Sở thích mobile lưu khóa thiết bị không có user ID, không đồng bộ traveler_profiles; đổi tài khoản có thể nhận tùy chọn cũ | [Profile preferences](../../../mobile/lib/features/profile/presentation/widgets/profile_travel_preferences.dart:51), [auth repository](../../../mobile/lib/features/auth/data/repositories/auth_repository.dart:67) chỉ PUT fullName, [user model](../../../mobile/lib/features/auth/data/models/user_model.dart:55) chưa đọc travelerProfile | USER-01, AUTH-01 |
| R-03 / P0 | Response có version nhưng request sửa mobile không gửi; không phát hiện request cũ tuần tự | [Update model](../../../mobile/lib/features/itinerary/data/models/itinerary_model.dart:204), [save](../../../mobile/lib/features/itinerary/presentation/screens/edit_itinerary_screen.dart:175), [editor](../../../backend/src/main/java/com/smarttravel/backend/features/itinerary/service/ItineraryEditor.java:16) chỉ so version khi client gửi | SYNC-03 |
| R-04 / P0 | Sửa mobile dùng giá min, thời lượng 90 phút cứng và fallback destinationId=1 khi thiếu điểm; preview lệch server hoặc không xử lý được điểm đã xóa | [Edit screen](../../../mobile/lib/features/itinerary/presentation/screens/edit_itinerary_screen.dart:141), [snapshot calculator](../../../backend/src/main/java/com/smarttravel/backend/features/itinerary/service/ItineraryCalculation.java) lấy giá max nếu có; destination snapshot có thể có ID NULL sau xóa | SYNC-03, EDIT-01/03 |
| R-05 / P1 | Admin bảng/thẻ/chi tiết/thống kê/CSV vẫn tạo rating 4.5 khi thiếu, CSV đổi giá NULL thành 0 | [List/statistics](../../../admin/src/features/destinations/DestinationList.tsx:117), [CSV](../../../admin/src/features/destinations/DestinationList.tsx:280), [table](../../../admin/src/features/destinations/table/DestinationTableRow.tsx:173), [mobile card](../../../admin/src/features/destinations/table/DestinationMobileCard.tsx:113) | SYNC-04 |
| R-06 / P1 | Xóa rating/count Google ở form sửa không làm mất giá trị cũ: DTO NULL bị service bỏ qua | [Destination update](../../../backend/src/main/java/com/smarttravel/backend/features/destination/service/DestinationService.java:138), form gửi optional googleRating/googleReviewCount | SYNC-04 |
| R-07 / P1 | Backend item.category là mã snapshot, mobile còn switch tên tiếng Việt; route NULL thành 0 và thiếu routeSource/polyline | [Mapper](../../../backend/src/main/java/com/smarttravel/backend/features/itinerary/service/ItineraryMapper.java), [icons](../../../mobile/lib/features/itinerary/presentation/widgets/itinerary/timeline_activity_card.dart:28), [model](../../../mobile/lib/features/itinerary/data/models/itinerary_model.dart:197) | SYNC-01/02, MAP-02/03 |
| R-08 / P1 | Engine vẫn shuffle và có thể lặp điểm; chưa kiểm tra giờ, required/excluded hoặc ngân sách khi chọn điểm | [ItineraryService](../../../backend/src/main/java/com/smarttravel/backend/features/itinerary/service/ItineraryService.java); không coi calculator đúng là engine đạt PRD | TRIP-02, REC-01/04 |
| R-09 / P1 | Yêu thích/xóa chuyến trên mobile có state cục bộ, thiếu luồng DB hoàn chỉnh; review/audit/reset/constraints chưa có đủ API | [Favorite toggle](../../../mobile/lib/features/destination/presentation/screens/destination_detail_screen.dart:131), [removeWhere](../../../mobile/lib/features/itinerary/presentation/screens/my_trips_screen.dart:70), [backend report](../../../backend/SCHEMA-COMPATIBILITY.md) | FAV-01, TRIPS-01, REV, AUD, AUTH-02, TRIP-02 |
| R-10 / P1 | Map đang nối tọa độ, chia sẻ chưa có route token riêng, lịch sử dựa index; backend DTO mới chưa bảo đảm client hiểu đúng | [Map](../../../mobile/lib/features/itinerary/presentation/widgets/itinerary/itinerary_map_view.dart), [router](../../../mobile/lib/core/router/app_router.dart), [trip card](../../../mobile/lib/features/itinerary/presentation/widgets/itinerary/my_trip_card.dart) | MAP-03, TRIPS-02, SHARE-01/02 |
| R-11 / P1 | Dashboard/audit dùng dữ liệu mẫu; quên mật khẩu chỉ báo gửi email; chưa có bằng chứng về route/email thật | [Dashboard](../../../admin/src/features/dashboard/DashboardView.tsx), [audit view](../../../admin/src/features/audit/AuditLogsView.tsx), [login](../../../mobile/lib/features/auth/presentation/screens/login_screen.dart:85) | ADM-01/03, AUD-02, AUTH-02 |
| R-12 / P0 nền tảng | V1/seed đã viết lại và sắp phiên bản; không biết lịch sử DB người dùng ở hiện tại; CI chỉ chạy tay và chưa chạy hai test admin mới | [V1](../../../backend/src/main/resources/db/migration/V1__init_schema.sql), [CI](../../../.github/workflows/ci.yml), [baseline report](initial-baseline.md) | BASE-01/03 |

R-01/R-03 có nguy cơ sai hoặc mất dữ liệu nên cần đóng sớm, trước khi thêm các màn hình khác. R-04 không khẳng định mọi request sẽ ghi nhầm điểm 1: với snapshot ID=0, hiện cũng có thể trả lỗi không tìm thấy; cả hai là fallback không đúng dữ liệu nguồn.

## Nền đã có cần bảo toàn

- Entity backend ánh xạ 12 bảng; auth_version ở V1 hiện tại; Google rating cột riêng, opening_hours JSON, snapshot/đơn giá/category_code/route fields mới.
- Owner/admin checks, giới hạn đăng ký user, khóa/revoke phiên, upload và database test guard đã có bằng chứng giai đoạn trước; không tự viết lại nền bảo mật.
- Tạo/sửa chuyến tính tổng từ toàn bộ trạng thái cuối, không tin tổng tiền client; version JPA, kiểm tra hạn share và snapshot đã có test. Kiểm tra lịch giờ chỉ mới là kiểm tra dữ liệu JSON, chưa là engine xếp lịch.
- Form thêm/sửa admin có bản dịch, giờ tuần nhiều ca, thời lượng/category, số liệu Google optional và giữ field khi bật/tắt; đã kiểm tra lưu qua backend thật trên DB cô lập.
- Rating/reviewCount/openingHours API cũ là lớp tương thích, không phải lỗi SQL chỉ vì tên khác schema. Cần test và lộ trình rõ trước khi bỏ alias.

## Giới hạn bằng chứng

Không có số đo tải/usability, không kiểm thử native Android/iOS mới hoặc kiểm tra dữ liệu Google ngoài thực tế. Kết quả 25 test backend và 14 test admin được dẫn từ các báo cáo trước, không tuyên bố là lần chạy mới. Việc có bảng trong ERD, entity hoặc build qua không đủ đóng chức năng.

Không tự khôi phục HOTEL, chi phí di chuyển/lưu trú, tags hoặc metadata bị loại để sửa sai lệch. Việc bổ sung API/service thực hiện theo từng mã việc trong kế hoạch, cùng test quyền và persistence.

## Đọc kết quả xử lý ở đâu?

| Nhóm phát hiện ban đầu | Báo cáo liên quan sau review |
| --- | --- |
| R-01, R-03, R-05, R-06: NULL, version, rating và cập nhật một phần | [Hợp đồng ba tầng](../engineering/api-contracts.md) |
| R-02: hồ sơ và dữ liệu theo tài khoản | [Tài khoản](../features/accounts.md) |
| R-04, R-07: snapshot/ID, sửa và route | [Quản lý lịch trình](../features/itinerary-management.md), [bản đồ](../features/routing-and-maps.md) |
| R-08: thuật toán chọn và xếp lịch | [Tạo lịch trình](../features/itinerary-generation.md) |
| R-09: các luồng lưu dữ liệu còn thiếu lúc đầu | [Catalog/yêu thích](../features/catalog-and-discovery.md), [review](../features/reviews-and-moderation.md), [tài khoản](../features/accounts.md) |
| R-10: lịch sử, map và link chia sẻ | [Quản lý/chia sẻ](../features/itinerary-management.md), [bản đồ](../features/routing-and-maps.md) |
| R-11: dashboard, audit và reset | [Quản trị](../features/administration.md), [tài khoản](../features/accounts.md) |
| R-12: migration và môi trường | [Baseline database](../engineering/database-baseline.md); nâng cấp DB cũ/CI còn theo kế hoạch |

Các báo cáo sau review có kết quả và giới hạn riêng; bảng này chỉ dẫn đường đọc, không xác nhận mọi tiêu chí phát hành đã đóng.
