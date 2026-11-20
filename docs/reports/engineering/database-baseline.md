# Baseline database và giới hạn nâng cấp

Baseline hiện tại chỉ có V1–V8. V1 tạo đủ 12 bảng/136 cột, đã gộp phần từng nằm trong V11/V12. Khởi tạo DB mới đã được kiểm tra; DB cũ cần phương án chuyển đổi riêng.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | SQL Flyway và kiểm thử backend |
| Công việc liên quan | Quyết định gộp baseline theo yêu cầu người dùng |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Thay đổi

| Bảng | Cột/index đã đưa vào V1 |
| --- | --- |
| itineraries | generation_input JSON NULL; index idx_itineraries_draft_cleanup(status, updated_at) |
| itinerary_constraints | destination_snapshot JSON NULL |
| destinations | featured_reason VARCHAR(240) NULL |
| itinerary_items | featured_recommendation BOOLEAN NOT NULL DEFAULT FALSE; upper_price_known BOOLEAN NOT NULL DEFAULT TRUE |

Đã bỏ file V11/V12 khỏi thư mục migration nguồn. Chuỗi hiện hành chỉ còn V1–V8; V2–V8 vẫn là seed, không cần thay nội dung seed cho việc gộp này. Entity, DTO, API và logic gợi ý không đổi. ERD vẫn có cùng 12 bảng và 136 cột.

## Database và bằng chứng

Kiểm tra database mới trên MySQL 9.2 cô lập, cổng 13317, schema smarttravel_test; không dùng database phát triển. Flyway đã áp dụng đúng 8 migration, history có version 1–8, không có V11/V12. Truy vấn xác nhận đủ 12 bảng/136 cột và index dọn DRAFT. JPA khởi tạo thành công với ddl-auto=validate. Log của lần chạy local ở `backend/target/baseline-v1-tests.log`.

`mvn test` đạt **85 test, 0 lỗi, 0 thất bại, 0 bỏ qua** trên database mới này. Không có thay đổi client nên không chạy lại build/test mobile/admin. MySQL 8.4 và nâng cấp database cũ vẫn cần bằng chứng riêng.

Đây là thay đổi baseline cho database mới, không phải migration nâng cấp DB đã chạy V1 cũ hoặc V11/V12. Các DB đó có thể gặp checksum mismatch hoặc applied migration not resolved khi dùng mã mới. Chưa thay flyway_schema_history, chạy repair hoặc xóa/dựng lại DB hiện có. Cần backup và thử phương án chuyển đổi trên bản sao trước khi áp dụng cho dữ liệu cần giữ.

Checksum giai đoạn 0 tiếp tục được giữ như bằng chứng lịch sử, không thay thành checksum V1 mới. Các báo cáo TRIP/REC nhắc V11/V12 là kết quả trước lần gộp này; [schema hiện hành](../../architecture/database-schema.md) và [tổng quan](../../codebase-summary.md) đã cập nhật baseline V1–V8.

Quay lại [mục lục báo cáo](../README.md).
