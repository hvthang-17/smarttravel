# Lịch sử sắp xếp tài liệu

> Tài liệu lịch sử. Những nhận định thiếu chức năng, tên migration và số test bên dưới thuộc thời điểm báo cáo gốc; không mô tả tiến độ hiện tại. Xem [trạng thái yêu cầu](../../planning/requirements-status.md) và [hướng dẫn đọc báo cáo](../README.md).

> Cập nhật sau lần rà tài liệu: V11/V12 đã được gộp vào V1 theo yêu cầu người dùng. Nội dung chuỗi 10 script bên dưới là snapshot trước khi gộp; xem [baseline hiện hành](../engineering/database-baseline.md).

Ngày thực hiện: 16/11/2026. Phạm vi chỉ gồm tài liệu và các tham chiếu liên quan; không thay mã nghiệp vụ, schema SQL hoặc cấu hình chạy ứng dụng.

## Cấu trúc mới

| Nơi lưu | Nội dung |
| --- | --- |
| docs/README.md | Điểm bắt đầu, mục lục và cách đọc tài liệu |
| docs/codebase-summary.md | Tổng quan phần triển khai hiện tại |
| architecture/ | Kiến trúc, ý nghĩa dữ liệu và ERD hiện hành |
| development/ | Quy chuẩn, quy trình và hướng dẫn chạy/kiểm thử |
| planning/ | Trạng thái yêu cầu và tiêu chí nghiệm thu theo mã việc |
| reports/ | Kết quả của từng mốc, review và thiết kế theo thời điểm |
| reports/evidence/ | Checksum migration lịch sử được giữ nguyên nội dung |

Các tài liệu trước đây nằm phẳng ở docs đã được chuyển theo nhóm. `database-schema-v2.md` đổi thành `architecture/database-schema.md`, `erd/smarttravel-v2.mmd` thành `architecture/erd/smarttravel.mmd`, `baseline-runbook.md` thành `development/testing-runbook.md` để tên file phản ánh vai trò thay vì một phiên bản hoặc lần chạy cũ.

## Nội dung đã sửa

- Thay các đoạn tổng hợp chồng lên nhau bằng một tổng quan hiện hành và một trang trạng thái yêu cầu. Báo cáo cũ được đánh dấu snapshot, giữ nguyên kết quả kiểm thử lịch sử.
- Sửa nhận định cũ rằng hồ sơ mobile, reset mật khẩu, xóa tài khoản, review và API đọc audit chưa triển khai. Phân biệt phần có mã/test với phần email thật, native, route provider và phát hành chưa nghiệm thu.
- Đồng bộ schema: V1 hiện tại tạo 12 bảng; có 10 script V1–V8, V11, V12; auth_version nằm trong V1. Bỏ mô tả cũ rằng V10 sẽ thêm auth_version và seed/entity chưa đồng bộ.
- Cập nhật runbook theo vị trí test resources và script npm hiện có; ghi rõ biến môi trường Maven/Vite/Flutter, database test và giới hạn widget/browser fixture so với native.
- Cập nhật liên kết trong docs, README, AGENTS và các tài liệu compatibility liên quan. Giữ PRD/user stories trong tasks làm tài liệu yêu cầu, không tự sửa phạm vi gốc.

## Kiểm chứng và giới hạn

- Đã kiểm tra toàn bộ liên kết tương đối trong docs và các trang tham chiếu chính: đích tồn tại, không còn tham chiếu Markdown tới vị trí docs cũ.
- Đối chiếu ERD với CREATE TABLE và ADD COLUMN trong chuỗi migration: 12 bảng, 136 cột, khớp tên và kiểu cơ sở. Kiểm tra này không chứng nhận đầy đủ nullability/index/CHECK/FK hoặc dữ liệu DB triển khai; các chi tiết đó vẫn lấy SQL làm căn cứ.
- Checksum baseline được di chuyển bằng thao tác giữ nguyên byte, có kiểm tra SHA-256 trước/sau; không cập nhật nó thành checksum mới.
- Không chạy lại test sản phẩm, truy vấn DB vận hành, kiểm tra liên kết web bên ngoài hoặc nghiệm thu UI trong lần rà tài liệu. Số test trong trang trạng thái dẫn lại báo cáo đã có, không tạo bằng chứng mới.

Tiến độ và các việc còn mở tiếp tục được quản lý ở [trạng thái yêu cầu](../../planning/requirements-status.md), không dùng báo cáo tổ chức tài liệu để đóng Mốc 13/14 hoặc xác nhận sản phẩm đã phát hành.
