# Tạo lịch trình và gợi ý cá nhân hóa

Bộ gợi ý kết hợp chấm điểm theo nội dung, chèn tham lam và tìm kiếm cục bộ. Kết quả là bản nháp có lý do/cảnh báo, không phải lịch trình được bảo đảm đầy đủ khi thiếu giá, giờ hoặc điểm khả dụng.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Backend và mobile |
| Công việc liên quan | Mốc 6: TRIP-01–03; Mốc 8: REC-01–04 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Luồng tổng quát

```text
Hồ sơ + lựa chọn chuyến
  -> kiểm tra ngày, khách, ngân sách và điểm bắt buộc/loại trừ
  -> lọc catalog khả dụng và chấm điểm ứng viên
  -> thử chèn, kiểm tra giờ mở cửa, chặng và ngân sách
  -> cải thiện thứ tự/lựa chọn bằng tìm kiếm cục bộ
  -> trả DRAFT cùng lý do, cảnh báo và COMPLETE hoặc PARTIAL
```

## Đầu vào và bản nháp

### Wizard và đầu vào

Wizard dùng ngân sách, nhịp độ, danh mục và phương tiện từ hồ sơ khi bắt đầu. Người dùng có thể đặt ngân sách riêng và chọn từ 1 đến 10 khách. Ngày chuyến đi tính theo giờ Đà Nẵng, dài từ 1 đến 7 ngày và nằm trong khoảng hôm nay đến 365 ngày tới. Server từ chối ngày thiếu, đảo ngược hoặc nằm ngoài miền. Nơi ở là tên điểm xuất phát nhập tự do, có thể kèm một cặp tọa độ. Chi phí chỉ tính theo hoạt động.

### Ràng buộc

Wizard cho chọn điểm bắt buộc hoặc muốn bỏ qua từ catalog và danh sách yêu thích. Mỗi loại nhận tối đa 5 ID duy nhất. API kiểm tra xung đột, điểm ẩn và danh mục ngoài phạm vi tại lúc tạo. Điểm bắt buộc được đưa vào trước. Những điểm đã chọn từ yêu thích tiếp tục được kiểm tra theo chủ sở hữu. Các điểm còn lại được chọn theo danh mục, sau khi loại điểm bị ràng buộc bỏ qua.

Chuyến, hoạt động, đầu vào và các dòng `itinerary_constraints` được ghi cùng transaction. Mỗi dòng giữ snapshot tên, mã danh mục, tọa độ và đơn giá. Giá trị lịch sử giữ nguyên khi catalog đổi. Khi sửa hoạt động, server kiểm tra lịch vẫn chứa điểm bắt buộc và không chứa điểm đã loại. Nếu ít điểm khả dụng hơn số khung hoạt động, kết quả là PARTIAL và có cảnh báo.

### Tạo, mở lại và lưu bản nháp

- `POST /api/v1/itineraries/generate` tạo DRAFT. Mobile giữ `generationKey` cho cùng đầu vào khi thử lại trong wizard. Backend giữ khóa theo tài khoản và so sánh đầu vào đã chuẩn hóa. Cùng khóa/cùng đầu vào trả chuyến hiện có. Cùng khóa/đầu vào khác trả 409. Tên chuyến và origin được cắt khoảng trắng. Thứ tự mã danh mục và ID ràng buộc không ảnh hưởng đối chiếu. Thứ tự điểm yêu thích có ảnh hưởng vì quyết định thứ tự ưu tiên. Client v1 cũ có thể bỏ khóa để tạo từng bản nháp riêng.
- `GET /api/v1/itineraries/drafts` liệt kê bản nháp của chủ sở hữu. Mở từ nút Bản nháp trong màn Lịch trình. Bản nháp bị loại khỏi danh sách đã lưu và màn quản trị chuyến. API chặn chia sẻ bản nháp và chặn truy cập của tài khoản khác.
- `PUT /api/v1/itineraries/{id}/save` chuyển DRAFT sang SAVED. Gửi lặp trả cùng trạng thái SAVED. Danh sách `GET /api/v1/itineraries` chỉ gồm SAVED. Mobile chờ server xác nhận rồi mới báo thành công và bật chia sẻ. DTO của link chia sẻ không trả tên hay tọa độ origin.
- Tác vụ dọn nháp chạy hàng ngày sau một giờ khởi động. Nó xóa DRAFT không cập nhật trong hơn 7 ngày, kèm dữ liệu con theo FK. Chuyến SAVED vẫn được giữ kể cả khi cập nhật lần cuối đã lâu. Khóa của bản nháp tồn tại cùng bản nháp và được giải phóng khi bản nháp hết hạn bị xóa.


## Cơ chế gợi ý cá nhân hóa

Backend tạo bản nháp cá nhân hóa bằng chấm điểm theo nội dung, chèn tham lam và tìm kiếm cục bộ. Lựa chọn danh mục gửi trong chuyến ưu tiên hơn hồ sơ. Nếu request bỏ trường `preferredCategories`, backend dùng danh mục còn khả dụng trong hồ sơ. Mảng rỗng là lựa chọn không giới hạn danh mục. Điểm bắt buộc và yêu thích có thể thuộc danh mục khác. `FOOD` được xét riêng để xếp bữa ăn. Các điểm được chọn phải còn ACTIVE trong danh mục ACTIVE thuộc phạm vi.

### Chọn và xếp lịch

- Backend thử bố trí điểm bắt buộc trước, ưu tiên điểm có ít ngày khả thi. Với chuyến một ngày, backend thử một điểm tiêu biểu khả thi trong danh mục được ưu tiên. Nhãn tiêu biểu là ưu tiên xếp hạng. Người dùng tự quyết định điểm bắt buộc.
- Điểm ứng viên phản ánh sở thích, yêu thích, đánh giá và số lượt đánh giá Google nếu có, cùng giá tham khảo. Khi thử chèn, backend tính thêm chặng đi và ưu tiên phân bổ lượt tham quan giữa các ngày. Dữ liệu và đầu vào giống nhau cho cùng thứ tự phân giải. Tìm kiếm cục bộ thử đổi thứ tự, hoán đổi hai ngày hoặc thay điểm tùy chọn bằng điểm rẻ hơn khi lợi ích tăng.
- Lịch bắt đầu từ 08:30. Giữa hai điểm, chừa 30 phút đệm ngoài thời gian di chuyển. Nhịp độ thư thả, cân bằng và dày đặc đặt mục tiêu lần lượt 2–3, 3–4 và 4–5 lượt tham quan. Tối đa hai bữa ăn, trong các khung 11:30–14:00 và 17:30–21:00. Toàn bộ lượt ghé phải nằm trong ca mở cửa đã biết. Ca NIGHTLIFE kéo qua nửa đêm được nối từ hai phần lịch tuần liền nhau, với giờ kết thúc tối đa 02:00. Lượt ghé thuộc ngày bắt đầu.
- Bộ lập lịch thử Haversine lúc tìm ứng viên, rồi lấy Directions/cache cho các chặng đã chọn trong giới hạn Mốc 7. Nếu có số liệu mới, backend chạy lại phép xếp ca. Chặng mới chưa có Directions vẫn có thể dùng Haversine. Khi thiếu tọa độ, thời gian chặng vẫn NULL và lịch tạm chừa 30 phút với cảnh báo. Khi chưa rõ giờ mở cửa, lịch yêu cầu khách xác nhận trước khi ghé.
- Tổng chi phí lấy đơn giá nhân số khách và phân bổ theo category. Ưu tiên cận trên. Giá chỉ có cận dưới được đánh dấu mức tối thiểu. Giá thiếu giữ NULL. Cả hai trường hợp khiến chi phí chưa đầy đủ. Di chuyển và lưu trú nằm ngoài tổng. Thiếu lượt tham quan theo mục tiêu hoặc không xếp được điểm bắt buộc trả `PARTIAL` và hướng dẫn. Chuyến rỗng trả lỗi 409 có hướng dẫn trước khi ghi bản nháp.

### Biên tập điểm tiêu biểu

Dùng API quản trị hiện có `POST /api/v1/destinations` hoặc `PUT /api/v1/destinations/{id}`. Thêm `featuredReason` tối đa 240 ký tự vào payload địa điểm. Nên gửi lý do mô tả đặc trưng Đà Nẵng mà khách có thể hiểu. Bỏ trường trong PUT để giữ nội dung cũ. Gửi `null` hoặc chuỗi trắng để gỡ nhãn. API tiếp tục yêu cầu quyền admin và ghi audit cùng transaction. Dashboard web hiện chưa có ô nhập trường này. Dữ liệu điểm tiêu biểu được biên tập thông qua API.


### Dữ liệu được giữ trong chuyến

Chuyến giữ đầu vào chuẩn hóa, sở thích và ràng buộc; hoạt động giữ snapshot giá/danh mục, lý do đề xuất và cờ điểm tiêu biểu. Mobile hiển thị lý do, nhãn tiêu biểu, giá tối thiểu và cảnh báo. LLM thuộc phạm vi mở rộng sau MVP.

Các cột generation_input, destination_snapshot, featured_reason, featured_recommendation và upper_price_known hiện nằm trong [V1](../../../backend/src/main/resources/db/migration/V1__init_schema.sql). V11/V12 là tên migration từng dùng ở lần triển khai ban đầu, đã gộp vào V1; xem [baseline](../engineering/database-baseline.md).

## Bằng chứng đã ghi nhận

| Đợt kiểm tra | Kết quả | Nội dung |
| --- | --- | --- |
| Đầu vào/bản nháp, Mốc 6 | Backend 49 test, Flutter 27 test; analyze sạch | Request đồng thời, cùng key khác input trả 409, quyền bản nháp/lưu, dọn nháp và ràng buộc |
| Bộ gợi ý, Mốc 8 | Backend 78 test, Flutter 30 test; analyze sạch | Có 24 ca lập lịch, quyền admin, mặc định hồ sơ, metadata tiêu biểu và snapshot |

Backend ở hai đợt dùng MySQL 9.2 cô lập, với baseline trước khi gộp V11/V12. Lần [kiểm tra baseline mới](../engineering/database-baseline.md) xác nhận chuỗi hiện hành V1–V8; không cộng các bộ test thành tổng mới.

## Giới hạn và bước tiếp theo

- Chưa có ô nhập featuredReason trong form admin; biên tập thông qua API quản trị.
- Chưa nghiệm thu bằng endpoint định tuyến thật và thiết bị vật lý. Kết quả fixture không thay cho dữ liệu địa điểm đã xác minh.
- Hiệu năng và usability vẫn cần kiểm tra theo [kế hoạch](../../planning/completion-plan.md).
- Chi tiết route/fallback xem [định tuyến và bản đồ](routing-and-maps.md); cách sửa chuyến xem [chỉnh sửa và chia sẻ](itinerary-management.md#chỉnh-sửa-và-tính-lại).

Quay lại [mục lục báo cáo](../README.md).
