# Quy trình thực hiện công việc

## 1. Xác định yêu cầu và hiện trạng

1. Đọc [AGENTS.md](../../AGENTS.md), quy tắc trong `.claude/rules/` và [mục lục tài liệu](../README.md).
2. Đối chiếu [PRD](../../tasks/prd-smarttravel.md), [user stories](../../tasks/smarttravel-user-stories.md), [phạm vi/trạng thái hiện tại](../planning/requirements-status.md) và mã công việc trong [kế hoạch](../planning/completion-plan.md).
3. Kiểm tra mã nguồn, migration và git status. Không dùng báo cáo cũ để kết luận chức năng hiện tại chưa có; không dùng bảng/entity để kết luận đã hoàn thành.
4. Chọn tầng cần sửa, nêu giả định và tiêu chí kiểm tra. Không mở rộng phạm vi hoặc sửa dữ liệu vận hành khi chưa có yêu cầu.

## 2. Triển khai theo hợp đồng

| Tầng | Trình tự |
| --- | --- |
| Backend | Chốt DTO/validation/quyền; thêm Flyway mới nếu đổi schema; entity/repository/service/transaction; controller và test dữ liệu/lỗi/quyền |
| Mobile | Model và repository đúng DTO; Riverpod theo phiên; screen/route và trạng thái loading/error; giữ bản sửa và dữ liệu nguồn |
| Admin | Kiểu DTO ở types hoặc core; API/session ở core; view/form ở features và thành phần chung ở components; pending/error và keyboard |
| Tài liệu | Cập nhật mô tả chịu ảnh hưởng, trạng thái và báo cáo tương ứng; sửa liên kết khi di chuyển, giữ nguyên bằng chứng lịch sử |

Đổi schema bắt buộc có migration mới và kiểm tra entity với `ddl-auto=validate`. Chuỗi hiện hành và giới hạn database cũ xem [schema](../architecture/database-schema.md). Không bắt buộc tạo service interface khi một implementation cụ thể đã đủ nhu cầu.

Thay đổi chỉ giao diện phải giữ nguyên API/payload/validation/handler nghiệp vụ. Áp dụng skill giao diện/copy/accessibility liên quan theo AGENTS và lựa chọn phiên của người dùng.

## 3. Kiểm chứng và báo cáo

- Chạy kiểm tra đúng tầng theo [quy chuẩn](code-standards.md) và [runbook](testing-runbook.md). Test DB dùng smarttravel_test, không dùng DB phát triển hoặc root.
- Với luồng người dùng, kiểm tra trực tiếp khi có môi trường. Ghi rõ browser fixture, API/DB thật và native UI; không thay thế bằng chứng giữa các loại.
- Báo phần đổi, lý do, kết quả kiểm tra và giới hạn. Không báo đạt dịch vụ email/route thật khi mới dùng fixture; không nhận dự án hoàn thành khi còn nghiệm thu bắt buộc.
- Đọc lại diff để tránh sửa ngoài phạm vi và lộ dữ liệu. Cập nhật [tổng quan mã nguồn](../codebase-summary.md) nếu cấu trúc/chức năng đổi, [trạng thái](../planning/requirements-status.md) nếu mức nghiệm thu đổi.
