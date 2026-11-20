# Dashboard, quản lý tài khoản và nhật ký quản trị

Các màn quản trị đọc dữ liệu thật từ DB thay cho dữ liệu hardcode. Thay đổi tài khoản vẫn kiểm quyền và thu hồi phiên; nhật ký hỗ trợ tra cứu và xuất CSV. Báo cáo thời tiết được tách riêng vì dùng nguồn và tiêu chí kiểm chứng khác.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Backend và admin |
| Công việc liên quan | Mốc 12: AUD-02, ADM-01–03 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## API và chức năng

| Nhóm | API chính | Nội dung |
| --- | --- | --- |
| Dashboard | `GET /api/v1/admin/dashboard` | Số liệu hiện tại và hoạt động trong kỳ |
| Tài khoản | `GET /api/v1/admin/users/page` | Tìm theo tên/email; lọc role/status và phân trang |
| Lịch trình | `GET /api/v1/admin/itineraries/page` | Tìm theo tên chuyến/chủ chuyến; lọc trạng thái, chỉ đọc SAVED hoặc ARCHIVED |
| Nhật ký | `GET /api/v1/admin/audit` | Lọc actor, actorId, action, entity, from, to và phân trang |
| Xuất nhật ký | `GET /api/v1/admin/audit/export` | Cùng bộ lọc, CSV tối đa 5.000 dòng |

## Đọc đúng số liệu dashboard

- Số địa điểm đang hiển thị và tổng tài khoản theo trạng thái/vai trò là số liệu tại lúc tải.
- Các chỉ số trong kỳ dùng ngày Đà Nẵng: tài khoản mới; chuyến được tạo trong kỳ và hiện đã lưu; review tạo trong kỳ và hiện công khai; số bài review khác nhau có báo cáo trong kỳ.
- Kỳ không có hoạt động có trạng thái rỗng. Lỗi API không được hiển thị thành số liệu đồng bộ thành công.
- Lượt chuyến trên trang user được lấy theo nhóm, tránh một truy vấn cho từng tài khoản.

## Quyền và bảo vệ dữ liệu

Các thao tác user giữ kiểm tra tự khóa, tự xóa, tự hạ quyền và quản trị viên hoạt động cuối cùng. Thay role/status thu hồi phiên cũ. Quản trị lịch trình là chỉ đọc; không suy ra quyền sửa/xóa chuyến thay chủ sở hữu từ việc có màn quản trị.

Bộ lọc ngày audit gồm cả hai đầu theo Asia/Ho_Chi_Minh. Chi tiết được lọc bằng danh sách trường an toàn kể cả log cũ. CSV xử lý chuỗi có thể bị hiểu thành công thức. Khi xóa tài khoản, ID và tên actor được ẩn danh nhưng sự kiện nghiệp vụ được giữ. Cơ chế ghi audit cùng transaction xem [catalog và audit](catalog-and-discovery.md#quản-trị-catalog).

## Loại bỏ thao tác mô phỏng

Các nút OAuth, góp ý tổng quát, chia sẻ hồ sơ, nhắc chuyến và thông báo mẫu không nằm trong giao diện phát hành. Đổi thông tin tài khoản tập trung vào họ tên; thiết lập du lịch lưu qua hồ sơ máy chủ. Đổi mật khẩu hoặc xóa chuyến chỉ báo thành công sau khi server xác nhận.

## Bằng chứng đã ghi nhận

Đợt quản trị và thời tiết dùng chung bộ hồi quy: backend 85 test trên MySQL 9.2 cô lập; Flutter 38 test và analyze sạch; admin build, 14 test catalog và 6 test security đạt. Đây là một lần chạy chung, không phải 85 test riêng cho từng tính năng.

Các ca mới kiểm tra lọc audit theo ngày Đà Nẵng, CSV, lọc bí mật trong log cũ, ẩn danh sau xóa tài khoản và phân trang quản trị. Đợt [gộp baseline](../engineering/database-baseline.md) sau đó chạy lại backend trên chuỗi V1–V8. Đợt [thiết kế admin](../experience/admin-interface.md#các-trang-nghiệp-vụ) ghi thêm kiểm tra browser bằng fixture.

## Giới hạn

Chưa có bằng chứng E2E toàn bộ dashboard triển khai/API/DB thật trong lần kiểm tra UI mới. Không dùng việc build qua hoặc thấy màn hình để khẳng định mọi luồng quản trị đã nghiệm thu. Cấu hình phát hành, backup/restore và kiểm tra hiệu năng còn theo [kế hoạch](../../planning/completion-plan.md).

Quay lại [mục lục báo cáo](../README.md).
