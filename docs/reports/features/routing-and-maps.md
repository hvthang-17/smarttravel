# Định tuyến và hiển thị bản đồ

Đã có adapter lấy khoảng cách, thời gian và hình học tuyến; thiếu dịch vụ hoặc dữ liệu thì phân biệt rõ ước tính với chưa biết. Chưa nghiệm thu endpoint định tuyến thật tại Đà Nẵng.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Backend và mobile |
| Công việc liên quan | Mốc 7: MAP-01–03 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Chọn dịch vụ định tuyến

Adapter hỗ trợ OSRM Directions (`/route`) và Matrix (`/table`). Luồng tạo và sửa lịch dùng Directions để lấy đồng thời khoảng cách, thời gian và hình học. Matrix nhận tối đa 25 điểm và giữ ô `null` khi không có tuyến. Kiểm tra bản triển khai OSRM hỗ trợ Table với annotation distance. [OSRM HTTP API](https://project-osrm.org/docs/v5.24.0/api/)

OSRM tự vận hành là phương án triển khai. Chỉ cấu hình endpoint sau khi duyệt hạ tầng, chi phí vận hành, điều kiện lưu kết quả và ghi công dữ liệu bản đồ. Các URL mặc định để trống. Dịch vụ demo công cộng có điều kiện sử dụng riêng. [Chính sách demo OSRM](https://github.com/Project-OSRM/osrm-backend/wiki/Api-usage-policy)

| Biến môi trường | Giá trị |
| --- | --- |
| `APP_ROUTING_CAR_URL` | Base URL chạy dữ liệu ô tô cho `car` và `taxi` |
| `APP_ROUTING_FOOT_URL` | Base URL chạy dữ liệu đi bộ cho `walking` |
| `APP_ROUTING_MOTORBIKE_URL` | Base URL chạy dữ liệu/profile xe máy phù hợp cho `motorbike` |
| `APP_ROUTING_TOKEN` | Bearer token nếu reverse proxy của các endpoint yêu cầu |
| `APP_ROUTING_REQUESTS_PER_MINUTE` | Hạn mức trên mỗi instance backend, mặc định 30. Giá trị 0 chặn gọi mới |

Mỗi endpoint phải nạp dữ liệu xử lý đúng theo phương tiện. `unspecified` dùng ước tính khi đủ tọa độ. Timeout kết nối và đọc lần lượt 500 ms và 800 ms. Khi tính một chuyến, backend dừng khởi tạo request mới sau 3 giây và vẫn đọc được cache. Cache hợp lệ giữ một giờ, tối đa 512 Directions và 64 Matrix. Lỗi 429, 5xx và lỗi kết nối tạm dừng các cuộc gọi mới trong 60 giây. [OSRM profiles](https://github.com/Project-OSRM/osrm-backend/blob/master/docs/profiles.md)

## Chặng và bản đồ

- Chặng đầu dùng origin của ngày nếu có đủ tọa độ, nếu thiếu thì dùng origin của chuyến. Chặng sau bắt đầu tại hoạt động liền trước. Tọa độ thiếu làm chặng thành `UNKNOWN` và giữ khoảng cách, thời gian, hình học là `null`. Chưa tính chặng quay về origin.
- `PROVIDER` lưu mét, giây và chuỗi JSON các cặp `[kinh độ, vĩ độ]` của LineString. `CACHE` dùng lại cùng số liệu và hình học. `HAVERSINE` lưu khoảng cách và thời gian ước tính. Bản đồ chỉ vẽ hình học hợp lệ từ `PROVIDER` hoặc `CACHE`. Dùng các cột schema hiện có.
- Marker và timeline dùng cùng ngày và thứ tự. Khi có tọa độ, Google Maps mở đúng điểm đến và dùng chế độ theo phương tiện. Link chia sẻ ẩn chặng từ origin để giữ riêng tư. [Google Maps URLs](https://developers.google.com/maps/documentation/urls/get-started)
- Mobile giữ chuyến SAVED đã tải trong bộ nhớ phiên hiện tại. Khi mất mạng hoặc backend lỗi 5xx, dữ liệu đã tải vẫn mở được và có nhãn bản tải gần nhất. Đổi phiên loại bỏ cache. Lỗi phân quyền từ chối dữ liệu cache. Khởi động lại app vẫn cần mạng để khôi phục phiên. Nền bản đồ trực tuyến có thể trống khi offline, trong khi marker và tuyến đã tải vẫn hiển thị.


## Bằng chứng đã ghi nhận

Đợt MAP đạt 53 test backend trên MySQL 9.2 cô lập; fixture HTTP kiểm tra Directions/Matrix, cache/quota, 429/5xx và hình học lỗi. Flutter đạt 29 test và analyze sạch. Đây là số của lần triển khai MAP, không phải tổng mới nhất của hệ thống.

## Giới hạn

Cần endpoint được duyệt về hạ tầng, chi phí và điều kiện sử dụng trước nghiệm thu tuyến thật. Mở điều hướng ngoài cần kiểm tra trên thiết bị. Cache chuyến đang có chỉ sống trong phiên; khởi động lại vẫn cần mạng để kiểm tra phiên. Chưa tính chặng quay về origin.

Quay lại [mục lục báo cáo](../README.md).
