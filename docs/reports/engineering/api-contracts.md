# Hợp đồng dữ liệu giữa backend, mobile và admin

Báo cáo tập trung vào những lỗi gây sai dữ liệu: NULL bị hiểu thành 0, rating giả, thiếu version và ID địa điểm dự phòng. Hợp đồng này là nền dùng chung; tiến độ chức năng nằm trong các báo cáo theo chủ đề.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Cả ba tầng |
| Công việc liên quan | Mốc 2: SYNC-01–05 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Hợp đồng hiện hành

| Dữ liệu | Quy tắc |
| --- | --- |
| Google và SmartTravel | `googleRating`/`googleReviewCount` là nguồn Google; `appRating`/`appReviewCount` là tổng hợp review công khai của ứng dụng. Không cộng chung hai nguồn. Trường Google hiện diện với NULL được ưu tiên hơn alias cũ, bất kể thứ tự thuộc tính JSON. |
| Giá | NULL là chưa biết; chỉ giá xác định bằng 0 mới là miễn phí. Có một cận thì hiển thị “Từ” hoặc “Tối đa”. Tổng chuyến/ngày là tổng phần đã biết; `costComplete=false` không được suy thành ngân sách an toàn hoặc tiền còn lại chắc chắn. |
| Chặng | Khoảng cách/thời gian NULL giữ nguyên. `routeSource=UNKNOWN` báo chưa có dữ liệu; HAVERSINE ghi rõ ước tính. Tổng khoảng cách/thời gian ngày là NULL nếu thiếu thành phần. Map giữ marker hợp lệ, không nối đường thẳng để mô phỏng tuyến giao thông thật. Provider/polyline thực tế thuộc MAP. |
| Snapshot | ID địa điểm có thể NULL sau khi xóa bản ghi nguồn. Tên, category, tọa độ và đơn giá snapshot vẫn đọc được. Không tạo ID 1/0 để thay thế địa điểm đã mất. Hoạt động mới chưa lưu có ID cục bộ 0 nhưng request bỏ trường ID; bắt buộc có destinationId dương. |
| Category | Chi phí theo mã BEACH/FOOD/CULTURE/CHECKIN/CAFE/NIGHTLIFE, dùng bảng nhãn Việt/Anh chung. Locale Việt/Anh và fallback được bổ sung ở [báo cáo trải nghiệm](../experience/localization-and-accessibility.md). |
| Bản dịch, giờ, trạng thái | Mobile nhận nameEn/descriptionEn, visitDurationMinutes, openingSchedule, costComplete, transport, warnings, generationStatus và route metadata. `openingSchedule` dùng JSON tuần schema_version=1. Status chuyến đọc từ server, thiếu thì DRAFT. |

### Cập nhật địa điểm

Giữ endpoint PUT hiện có; không thêm PATCH. `name`, `latitude`, `longitude` vẫn bắt buộc để tương thích validation hiện tại.

- Không gửi trường tùy chọn: giữ giá trị đã lưu.
- Gửi NULL cho trường nullable: xóa giá trị, gồm giá, điểm/lượt Google, bản dịch, lịch, mô tả/liên hệ/ảnh.
- Gửi mảng ảnh rỗng: xóa ảnh phụ. `status` và category không được xóa bằng NULL; khi bỏ qua vẫn giữ hiện trạng.
- Form admin gửi NULL khi bỏ trống giá/Google. Bật/tắt chỉ gửi các trường PUT bắt buộc và status, tránh ghi lại dữ liệu tùy chọn từ bản đọc cũ.
- Giá cuối cùng sau khi ghép dữ liệu cũ/mới vẫn phải thỏa min <= max. Google rating có một chữ số thập phân, khoảng 1–5; count không âm.

Ví dụ xóa điểm Google nhưng giữ bản dịch/lịch/ảnh:

```json
{"name":"Địa điểm","latitude":16.05,"longitude":108.2,"googleRating":null,"googleReviewCount":null}
```

Alias `rating`/`reviewCount` và chuỗi hiển thị `openingHours` được giữ trong suốt vòng đời `/api/v1`. Client mới dùng các trường Google và `openingSchedule`; chỉ loại alias trong `/api/v2` sau khi cả hai client được chuyển và chạy lại fixture/hồi quy. Không có lịch tự xóa alias trong v1. JSON lịch hiện diện được ưu tiên hơn chuỗi giờ cũ.

### Sửa lịch trình

Request `/itineraries/{id}/activities` bắt buộc `version >= 1` lấy từ response hiện tại. Thiếu version trả 400; cũ trả 409 qua ApiResponse, kể cả optimistic lock tại commit. Không tự giả định version=1 khi dữ liệu nhận thiếu version.

Mobile phân biệt 409 với lỗi kết nối/quyền. Bản sửa vẫn giữ khi đóng hộp thoại, chọn giữ bản sửa, hủy xác nhận hoặc tải bản mới thất bại. Chỉ thay thế sau khi người dùng xác nhận bỏ bản sửa. Với địa điểm đã xóa, giữ hoạt động bằng item ID + destinationId NULL; có thể xóa hoạt động và thêm điểm khác. Server tiếp tục tính tiền theo snapshot và số khách; không tin tổng tiền client.

## Bằng chứng tại lần đồng bộ

Fixture dùng chung: [contracts/schema-sync.json](../../../contracts/schema-sync.json). Có canonical Google NULL cạnh alias cũ, app rating độc lập, tọa độ 0 hợp lệ, lịch hai ca, unknown/closed/24h, snapshot không ID, route/giá NULL và request version.

| Tầng | Kết quả | Nội dung |
| --- | --- | --- |
| Backend | `mvn test`: 30/30 PASS | Fixture deserialize/serialize; NULL ưu tiên alias cả hai thứ tự; giữ/xóa trường; Google/app tách biệt; server tính tổng; cập nhật version cũ 409; null day/item, trùng sequence/day, giờ sai 400 và rollback; điểm không tồn tại 404; snapshot sau xóa lưu lại được; endpoint cũ/status/ID sai định dạng; hồi quy quyền/phiên/upload/database guard. |
| Admin | Build PASS; 9 test destinations + 6 security PASS | Giá/Google trống thành NULL; giữ số 0; thống kê chỉ lấy rating đã biết; CSV không chèn 4.5/0; lịch tuần và payload form; các kiểm tra phiên/quyền hiện có. |
| Mobile | Analyze không có issue; 16 test PASS | Fixture/model, canonical NULL và snapshot; từ chối request ID/version sai; widget ngân sách/chặng UNKNOWN; HTTP 409 giữ đăng nhập; widget editor giữ bản sửa qua giữ/hủy/tải lỗi; hồi quy auth/private itinerary/smoke. |

Backend chạy với MySQL 9.2 cô lập tại 13316/smarttravel_test, Flyway V1–V8 và ddl-auto=validate; dùng heap/buffer nhỏ sau một lần thiếu bộ nhớ máy. Không dùng database vận hành. Bộ kiểm thử mobile chạy `flutter test --no-pub --concurrency=1` để giảm bộ nhớ.


## Phạm vi của bằng chứng

Kết quả 30 test backend/16 test mobile/15 test admin ở trên thuộc đợt đồng bộ ban đầu. Các chức năng hồ sơ, yêu thích, tạo/sửa/chia sẻ chuyến, review và audit được bổ sung sau đó; không giữ nhận định “chưa triển khai” của đợt này làm trạng thái hiện tại.

MySQL 8.4, nâng cấp DB cũ và native E2E vẫn cần kiểm chứng riêng. Xem [baseline hiện hành](database-baseline.md), [tài khoản](../features/accounts.md), [tạo lịch trình](../features/itinerary-generation.md#cơ-chế-gợi-ý-cá-nhân-hóa) và [trạng thái yêu cầu](../../planning/requirements-status.md).

Quay lại [mục lục báo cáo](../README.md).
