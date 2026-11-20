# Quy chuẩn mã nguồn SmartTravel

Áp dụng cùng [AGENTS.md](../../AGENTS.md) và [development-rules](../../.claude/rules/development-rules.md). Đây là quy chuẩn phát triển, không phải khẳng định mọi file cũ đã đạt.

## Quy tắc chung

- Chỉ sửa tầng/phần được yêu cầu, giữ thay đổi người dùng trong worktree và không thêm dependency chưa được chấp thuận.
- Giữ file dưới 300 dòng khi phù hợp; tách theo trách nhiệm, tránh rewrite/format phần không liên quan.
- Không tạo placeholder chức năng, không báo thành công khi request thất bại và không điền dữ liệu giả để che NULL/lỗi mạng.
- Không commit `.env`, password, hash, token hoặc khóa dịch vụ. Log/audit chỉ giữ metadata cần thiết đã lọc bí mật.
- Thay hợp đồng dữ liệu phải đối chiếu cả DTO/client và snapshot. Chi tiết quy ước NULL, giá, giờ và route nằm ở [schema](../architecture/database-schema.md).

## Backend

- Java 21, Spring Boot 3.5.5; package `com.smarttravel.backend.features.<feature>` với api/domain/dto/repository/service.
- Constructor injection và trường final; validation Jakarta trên DTO lẫn cấu trúc lồng nhau.
- API JSON dùng ApiResponse và lỗi qua GlobalExceptionHandler, HTTP status phản ánh kết quả. CSV/HTML công khai theo media type đã định nghĩa; không tạo ngoại lệ mới tùy tiện.
- Ownership/role/status kiểm tra phía server. Thay đổi nghiệp vụ và audit bắt buộc cùng transaction khi thuộc đường quản trị được audit.
- Schema thay bằng Flyway phiên bản mới; không sửa script đã áp dụng hoặc repair để che checksum. Giữ `ddl-auto=validate` và entity khớp chuỗi SQL hiện hành.

## Mobile

- Dart SDK theo [pubspec](../../mobile/pubspec.yaml); Riverpod/GoRouter/Dio, cấu trúc feature-first.
- Tách model/repository khỏi UI. Dữ liệu riêng và cache theo phiên/user, xóa đúng khi logout/401.
- Dùng token AppTheme, nhãn category từ catalog/helper, tài nguyên dịch chung và fallback Việt. Không đổi giá trị nghiệp vụ theo nhãn dịch.
- Giữ const khi phù hợp; analyze không cảnh báo. Loading/empty/error/retry có hành vi thật; lỗi lưu giữ bản sửa và có xử lý 409.
- Thiết kế tham khảo [design system](../../tasks/DESIGN-SYSTEM.md), đối chiếu token đang dùng và [báo cáo UX](../reports/experience/localization-and-accessibility.md) cho điều chỉnh tương phản hiện hành.

## Admin

- TypeScript strict; không thêm any mới. Interface phải khớp DTO server, request qua lớp API/session dùng chung.
- API/session/config ở core, UI nghiệp vụ ở features, thành phần dùng chung ở components, kiểu chia sẻ ở types.
- Giữ CSS có phạm vi và thứ tự specificity rõ; hệ token shell trong admin-design.css, không sửa handler nghiệp vụ cho thay đổi chỉ trình bày.
- Form cần nhãn truy cập, focus/keyboard và trạng thái pending/error; không đóng hoặc reset nội dung khi lưu lỗi.

## Kiểm tra trước bàn giao

| Phần thay đổi | Kiểm tra |
| --- | --- |
| Backend | `mvn test` trên database test được guard |
| Mobile | `flutter analyze`, `flutter test` cho logic/UI liên quan |
| Admin | `npm run build`, test chuyên biệt hoặc toàn bộ bộ test khi thay hợp đồng/phiên |
| Tài liệu | Liên kết/file tham chiếu tồn tại; ERD/schema khớp SQL; tách mô tả hiện hành khỏi bằng chứng lịch sử |

Xem [runbook](testing-runbook.md) cho cấu hình, lệnh và giới hạn bằng chứng. Thay đổi chỉ tài liệu không yêu cầu chạy lại toàn bộ test sản phẩm; không được ghi là đã chạy nếu chỉ đối chiếu báo cáo cũ.
