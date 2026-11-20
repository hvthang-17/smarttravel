# Tổng quan mã nguồn SmartTravel

Rà soát ngày 16/11/2026. Trang này mô tả phần triển khai hiện có; mức nghiệm thu và phần còn mở xem [trạng thái yêu cầu](planning/requirements-status.md). Mục lục đầy đủ ở [docs/README.md](README.md). Các báo cáo triển khai đã được gộp theo chủ đề ở [mục lục báo cáo](reports/README.md); đánh giá đầu kỳ được tách riêng trong history.

## Phạm vi sản phẩm

SmartTravel hỗ trợ khám phá và lập lịch trình cá nhân hóa tại Đà Nẵng. Catalog dùng sáu mã BEACH, FOOD, CULTURE, CHECKIN, CAFE, NIGHTLIFE. Không đưa HOTEL, đặt phòng hoặc thanh toán vào MVP. Dự toán chỉ tính hoạt động theo nhóm; không bao gồm lưu trú và di chuyển. Bộ gợi ý dùng chấm điểm, chèn tham lam và tìm kiếm cục bộ, không gọi LLM.

## Cấu trúc và chức năng

| Tầng | Mã nguồn | Phần đã triển khai |
| --- | --- | --- |
| Backend | [backend/](../backend) | Auth/JWT, hồ sơ, reset/xóa tài khoản, catalog, khám phá/yêu thích/review, tạo/sửa/lưu/copy/share chuyến, route adapter, audit, dashboard và thời tiết |
| Mobile | [mobile/lib/](../mobile/lib) | Riverpod/Dio/GoRouter; hồ sơ, khám phá và chi tiết, yêu thích/review, wizard, timeline/map/ngân sách, chỉnh sửa, danh sách/chia sẻ và locale Việt/Anh |
| Admin | [admin/src/](../admin/src) | React/TypeScript; catalog/ảnh/giờ tuần, user/role/lock, chuyến chỉ đọc, review moderation, audit/export và dashboard. Giao diện dùng tài nguyên dịch chung và lưu language qua hồ sơ |

Backend tổ chức theo `features/<feature>/{api,domain,dto,repository,service}` và `common/`. Mobile dùng `features/<feature>/data` và `presentation`, cùng `core/`. Admin dùng `features/`, `components/`, `core/`, `types/`; kiểu chữ và shell mới nằm trong `admin-design.css`.

Admin bổ sung AdminPageHeader, admin-pages.css và focus dialog dùng chung; bảy trang chính được điều chỉnh bố cục nội dung, bộ lọc, bảng và trạng thái. [Báo cáo UI theo trang](reports/experience/admin-interface.md#các-trang-nghiệp-vụ) có ảnh desktop/màn nhỏ và giới hạn kiểm chứng bằng fixture.

## Hợp đồng cần giữ

- `NULL` nghĩa chưa biết, khác 0 đồng hoặc 0 phút. Google và SmartTravel là hai nguồn rating/count riêng.
- Giờ tuần JSON dùng cho cả hiển thị và kiểm tra lịch. API có `openingSchedule` cấu trúc và `openingHours` hiển thị tương thích.
- Hồ sơ lưu category code và mặc định wizard; đầu vào chuyến được snapshot. Required/excluded và ownership được kiểm tra ở server.
- Tạo chuyến dùng generation key; sửa dùng version. Snapshot và tổng toàn chuyến phải nhất quán sau sửa một ngày.
- Route có PROVIDER/CACHE/HAVERSINE/UNKNOWN. Chỉ hình học provider/cache được vẽ như tuyến thật; không tự thêm chặng quay về origin.
- Catalog ẩn bằng INACTIVE để giữ review/snapshot. Audit cùng transaction với thay đổi quản trị, không chứa mật khẩu/token.

Chi tiết ở [kiến trúc](architecture/system-architecture.md), [schema](architecture/database-schema.md) và [báo cáo SYNC](reports/engineering/api-contracts.md).

## Database và cấu hình

V1 hiện tại tạo đủ 12 bảng, gồm generation input, constraint snapshot, metadata gợi ý và index dọn nháp. Thư mục [Flyway](../backend/src/main/resources/db/migration) chỉ còn 8 script V1–V8; V2–V8 seed dữ liệu. V11/V12 đã được gộp vào V1 theo yêu cầu người dùng. [ERD](architecture/erd/smarttravel.mmd) giữ cùng 136 cột. Database đã chạy baseline cũ hoặc V11/V12 cần kế hoạch riêng; không tự repair lịch sử Flyway.

MySQL 8.4 là cấu hình Docker/CI dự kiến. Báo cáo backend gần nhất ghi kiểm thử trên MySQL 9.2 cô lập, không chứng minh database cũ của người dùng đã nâng cấp. Không repair hoặc sửa migration lịch sử để bỏ qua checksum khác biệt.

Cấu hình đọc từ [application.yml](../backend/src/main/resources/application.yml), [.env.example](../.env.example), [docker-compose.yml](../docker-compose.yml). File `.env` không tự cấp biến cho mọi terminal Maven/Flutter/Vite; phải truyền cấu hình cho đúng tiến trình. Không chép secret vào tài liệu.

## Bằng chứng gần nhất và giới hạn

| Tầng | Kết quả đã ghi nhận | Nguồn và giới hạn |
| --- | --- | --- |
| Backend | 85 test | [Baseline đã gộp](reports/engineering/database-baseline.md); chạy lại trên DB mới MySQL 9.2 cô lập với V1–V8 |
| Mobile | Analyze sạch, 40 test | [Mốc 13](reports/experience/localization-and-accessibility.md); chưa nghiệm thu Android native, iOS hoặc Flutter web |
| Admin | Build và 22 test | [Thiết kế admin](reports/experience/admin-interface.md#khung-giao-diện); browser ở 1440/390 px với API fixture, build còn cảnh báo chunk JS lớn |

Còn mở: email đến hộp thư thật, endpoint route được duyệt, Google định kỳ, admin nhập metadata điểm tiêu biểu, E2E/hiệu năng/usability, MySQL 8.4 và nâng cấp/backup/restore DB cũ. CI hiện chỉ chạy thủ công và chưa chạy các bộ test admin. Mốc 13 chưa đóng nghiệm thu; Mốc 14 còn phải thực hiện theo [kế hoạch](planning/completion-plan.md).
