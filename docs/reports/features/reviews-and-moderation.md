# Đánh giá địa điểm và kiểm duyệt nội dung

Google và SmartTravel là hai nguồn đánh giá độc lập. Người dùng quản lý bài của mình; admin ẩn/hiện và nhận báo cáo. Chỉ bài đang công khai được tính vào điểm trung bình SmartTravel.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Backend, mobile và admin |
| Công việc liên quan | Mốc 11: REV-01–03 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Đánh giá tại địa điểm

Khách xem các đánh giá `PUBLISHED` của địa điểm và danh mục đang khả dụng. Người đã đăng nhập có thể gửi một đánh giá cho mỗi địa điểm, với số sao nguyên từ 1 đến 5 và nhận xét tùy chọn tối đa 1.000 ký tự. Backend dùng tài khoản từ phiên và khóa khi ghi. Ràng buộc unique trong DB bảo vệ cả request đồng thời.

| API | Quyền và kết quả |
| --- | --- |
| `GET /api/v1/destinations/{id}/reviews?page=0&size=10` | Danh sách công khai phân trang, chỉ có bài đang hiển thị. Payload bỏ mã và thông tin tài khoản tác giả |
| `POST /api/v1/destinations/{id}/reviews` | Tạo bài cho tài khoản hiện tại |
| `GET/PUT/DELETE /api/v1/destinations/{id}/reviews/mine` | Đọc, sửa hoặc xóa bài của chính mình. Bài bị ẩn giữ trạng thái khi tác giả sửa |
| `POST /api/v1/destinations/{id}/reviews/{reviewId}/reports` | Gửi lý do báo cáo lên hàng chờ quản trị |
| `GET /api/v1/admin/reviews` | Xem theo trạng thái, địa điểm, phân trang và tùy chọn chỉ có báo cáo |
| `PUT /api/v1/admin/reviews/{reviewId}/status` | Ẩn hoặc hiện lại với audit cùng transaction |

Một tài khoản gửi tối đa một báo cáo cho mỗi bài. Báo cáo lưu trong `audit_logs` với loại `REVIEW`, hành động `REPORT` và mã lý do. Hàng chờ **Kiểm duyệt đánh giá** gộp báo cáo theo lý do và chỉ hiển thị cho admin. Báo cáo vẫn được giữ làm lịch sử sau khi quản trị xử lý. Luồng dùng các bảng hiện có. Mobile xác nhận đã gửi khi server phản hồi thành công.

## Tổng hợp và hiển thị

SmartTravel lấy tổng số sao và số bài `PUBLISHED` theo nhóm địa điểm trong một truy vấn, sau đó chia ở backend. Điều này giữ độ chính xác của điểm trung bình khi trả API. Khi không có bài được công khai, `appRating` là `NULL` và `appReviewCount` bằng 0. Sửa bài giữ nguyên số bài. Ẩn, hiện hoặc xóa cập nhật số liệu từ cùng nguồn. Mobile và admin hiển thị Google Maps và SmartTravel riêng, làm tròn điểm hiển thị đến một chữ số thập phân. SmartTravel chưa xác minh lượt ghé của tác giả.

## Bằng chứng tại lần triển khai

Backend đạt 83/83 test trên MySQL 9.2 cô lập. Flutter đạt 36/36 test và analyze sạch. Admin build thành công và đạt 20/20 test. Vite cảnh báo chunk chính 501,66 kB sau minify. Chưa kiểm thử luồng hoàn chỉnh trên thiết bị vật lý và dashboard triển khai.

## Giới hạn và tham khảo

Ứng dụng chưa xác minh tác giả đã đến địa điểm. Báo cáo review dùng bảng audit hiện có, không có bảng báo cáo riêng. Kiểm tra UI kiểm duyệt sau đợt này xem [giao diện quản trị](../experience/admin-interface.md#các-trang-nghiệp-vụ); không dùng fixture UI để thay nghiệm thu API/DB thật.

Quay lại [mục lục báo cáo](../README.md).
