# Thời tiết: nguồn dữ liệu, độ mới và dự phòng

Thời tiết được lấy qua backend, có nhãn dữ liệu mới/cache/cũ/không khả dụng. Nguồn là dữ liệu mô hình dự báo, không được trình bày như quan trắc trực tiếp.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Backend và mobile |
| Công việc liên quan | Mốc 12: WEATHER-01 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Request và dữ liệu phản hồi

`GET /api/v1/weather/current` nhận `timezone=Asia/Ho_Chi_Minh`, `locale=vi|en` và cặp `lat`/`lon` tùy chọn. Thiếu cả hai tọa độ thì dùng Đà Nẵng. Tọa độ lỗi hoặc tham số ngoài phạm vi trả 400. Backend xây URI và gửi đúng timezone một lần.

| Trạng thái | Chính sách |
| --- | --- |
| `FRESH` | Dữ liệu mô hình vừa lấy, với mốc mô hình chưa quá 30 phút |
| `CACHED` | Dữ liệu cache trong 15 phút và mốc mô hình vẫn còn mới |
| `STALE` | Dữ liệu mô hình cũ hơn hoặc dữ liệu gần nhất khi nguồn lỗi. Mốc mô hình tối đa 6 giờ |
| `UNAVAILABLE` | Thiếu dữ liệu có thể dùng. Các số đo, mốc thời gian trả NULL và dự báo ngày trả mảng rỗng |

Cache giới hạn 256 khóa theo tọa độ làm tròn 0,01 độ và locale. Sau lỗi, mỗi khóa chờ 60 giây trước khi gọi lại. `validAt` là mốc mô hình và `updatedAt` là lúc backend nhận dữ liệu. Mobile hiển thị nhãn cũ hoặc chưa có dữ liệu, dùng backend để cập nhật và thử lại. Open-Meteo cung cấp dữ liệu mô hình dự báo cho điều kiện hiện tại. [Open-Meteo Forecast API](https://open-meteo.com/en/docs)

## Bằng chứng đã ghi nhận

- Fixture HTTP kiểm tra tham số, cache, stale, fallback và dữ liệu lỗi; unit test không phụ thuộc Internet.
- Lần gọi mạng riêng tới Open-Meteo trả timezone Asia/Ho_Chi_Minh, UTC offset 25.200 giây và 7 ngày dự báo. Đây là kết quả của một lần gọi đã ghi nhận, không bảo đảm nguồn ngoài luôn hoạt động.
- Bộ hồi quy dùng chung với đợt quản trị: backend 85 test, Flutter 38 test và analyze sạch, admin build/20 test đạt. Không tính các con số này là bộ test riêng chỉ cho thời tiết.

## Giới hạn và đọc tiếp

Chưa nghiệm thu luồng đầy đủ trên thiết bị vật lý. Cần phân biệt validAt của mô hình với updatedAt là lúc backend nhận dữ liệu. Không thay số đo NULL bằng thời tiết giả khi nguồn lỗi. [Trạng thái yêu cầu](../../planning/requirements-status.md) theo dõi nghiệm thu; [quản trị](administration.md) mô tả phần dashboard/audit cùng đợt triển khai.

Quay lại [mục lục báo cáo](../README.md).
