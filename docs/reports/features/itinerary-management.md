# Chỉnh sửa, lưu trữ và chia sẻ lịch trình

Chủ chuyến chỉnh hoạt động, lưu bản nháp, đổi tên, sao chép, xóa và quản lý link chia sẻ. Server kiểm quyền/phiên bản và tính lại số liệu; lỗi lưu không được làm mất bản sửa.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Backend và mobile; admin đọc chuyến theo quyền |
| Công việc liên quan | Mốc 9: EDIT-01–03; Mốc 10: TRIPS-01/02, SHARE-01/02 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Chỉnh sửa và tính lại

Chủ chuyến có thể thêm, xóa, đổi thứ tự và thay địa điểm. Menu từng hoạt động cho chỉnh giờ bắt đầu, thời lượng và ghi chú. Hoạt động mới có thể để trống giờ bắt đầu.

### Hợp đồng cập nhật

`PUT /api/v1/itineraries/{id}/activities` nhận `version` và danh sách ngày cần chỉnh. Với mỗi ngày gửi lên, `items` là danh sách hoàn chỉnh theo thứ tự mới. Ngày có thể tham chiếu bằng `dayId` hoặc `dayNumber`. Khi có cả hai, chúng phải khớp. Hoạt động mới gửi `destinationId` thật và bỏ `id`. Hoạt động cũ dùng ID thuộc đúng ngày.

Server giữ ID, tên, tọa độ, giá snapshot và dữ liệu đề xuất khi chỉnh thông tin của hoạt động hiện có. Khi thay địa điểm, server lấy snapshot mới từ catalog đang khả dụng, áp dụng thời lượng gợi ý nếu khách chưa chọn thời lượng riêng và xóa lý do đề xuất của điểm cũ. Trường giờ, thời lượng và ghi chú bị bỏ qua trong payload sẽ giữ giá trị hiện có của hoạt động. Một thao tác lỗi hoàn tác toàn bộ cập nhật, gồm cả những ngày đã được ghi tạm để đổi thứ tự.

Thay đổi thứ tự hoặc tọa độ sẽ tính lại tuyến của ngày liên quan. Đặt `recalculateRoute: true` trên ngày gửi lên để yêu cầu tính lại tuyến ngày đó. Dùng `recalculateAll: true` với `days: []` để tính lại toàn chuyến. Tổng chi phí luôn tính từ snapshot đơn giá × số khách của mọi ngày rồi phân bổ theo danh mục. Server bỏ qua tổng chi phí do client gửi.

Kiểm tra ca mở cửa dùng cùng dữ liệu lịch tuần và quy tắc qua nửa đêm như bộ gợi ý, dựa trên giờ mở cửa hiện có trong catalog. Sau chỉnh sửa, server cảnh báo nếu hoạt động nằm ngoài ca, chồng giờ, thiếu thời gian đi hoặc thiếu dữ liệu. Giờ người dùng nhập được giữ để họ quyết định sửa. Giới hạn chuyến và các ràng buộc điểm bắt buộc hoặc loại trừ vẫn được kiểm tra ở server.

### Xem trước và xử lý lỗi

Màn chỉnh sửa dùng `suggestedVisitDurationMinutes` từ API catalog và quy tắc cận trên, cận dưới hoặc giá chưa rõ. Dự toán nhân với số khách. Dữ liệu mới ở catalog được áp dụng cho điểm thêm hoặc thay ở lúc lưu. Trong lúc server tính, mobile giữ số liệu đã lưu và báo đang tính. Khi thành công, màn chi tiết nhận lại cả phiên bản mới, tuyến, timeline và ngân sách.

Lỗi version trả 409 với `ITINERARY_VERSION_CONFLICT`. Bản sửa chỉ bị thay bằng phiên bản từ server khi người dùng xác nhận tải lại và nhận được dữ liệu mới. Lỗi ràng buộc trả 409 với `ITINERARY_CONSTRAINT_CONFLICT` và hiển thị lý do để khách sửa tiếp. Lỗi kết nối giữ bản chỉnh sửa tại chỗ.


## Lưu trữ, sao chép và chia sẻ

### Quản lý chuyến đi

Chủ chuyến có thể lưu bản nháp, đổi tên, sao chép hoặc xóa chuyến. Quản trị viên giữ quyền đọc chuyến đã lưu qua hợp đồng quản trị hiện có. Các thao tác ghi và quản lý chia sẻ thuộc chủ chuyến.

| API | Kết quả |
| --- | --- |
| `PUT /api/v1/itineraries/{id}/save` | Chuyển bản nháp sang SAVED |
| `PUT /api/v1/itineraries/{id}/title` | Đổi tên với payload `{"title":"Tên chuyến"}` |
| `POST /api/v1/itineraries/{id}/copy` | Tạo DRAFT với ID, ngày, hoạt động và các dòng ràng buộc riêng |
| `DELETE /api/v1/itineraries/{id}` | Xóa chuyến trong DB. Ngày, hoạt động và ràng buộc xóa theo quan hệ FK |
| `GET /api/v1/itineraries/mine` | Danh sách SAVED theo chủ tài khoản, hỗ trợ `search`, `period`, `page` và `size` |

Bản sao giữ ngày đi, snapshot địa điểm, chi phí, tuyến và nội dung đã chỉnh. Bản sao có thể lưu như chuyến mới. Khóa sinh lịch và token chia sẻ bắt đầu trống. Lịch sử gồm các chuyến có `endDate` trước hôm nay theo múi giờ `Asia/Ho_Chi_Minh`. Chuyến kết thúc hôm nay thuộc nhóm hiện tại hoặc sắp tới. API sắp theo lần cập nhật và ID giảm dần. Mobile tải lại danh sách sau thao tác thành công. Cache trang và chi tiết chỉ sống trong phiên, theo truy vấn và tài khoản.

### Vòng đời liên kết

Chủ chuyến xem trạng thái bằng `GET /api/v1/itineraries/{id}/share`. `POST` cùng đường dẫn tạo liên kết khi chưa có link hiệu lực và trả link đang hoạt động nếu còn hạn. `POST ?rotate=true` thay bằng token mới. `DELETE` thu hồi ngay. Token ngẫu nhiên hết hạn sau 7 ngày. Token cũ thiếu ngày hết hạn được xem là đã hết hạn. Link hết hạn trả 410, còn token sai, đã thu hồi hoặc thuộc chuyến/tài khoản bị xóa trả 404.

Khách mở link qua trang trình duyệt `/itineraries/shared/{token}` hoặc route mobile cùng đường dẫn. JSON `GET /api/v1/itineraries/shared/{token}` dùng DTO riêng chỉ gồm tiêu đề, ngày, điểm dừng và dữ liệu tuyến giữa các điểm dừng. API công khai bỏ ghi chú, thông tin tài khoản, token, cấu hình, ngân sách, ràng buộc và chặng xuất phát riêng tư. Trang trình duyệt có nút mở route Android `smarttravel://share/itineraries/shared/{token}`. Khách có thể đọc ngay trong trình duyệt nếu chưa cài ứng dụng. [Flutter deep linking](https://docs.flutter.dev/ui/navigation/deep-linking)

Đặt `APP_SHARE_BASE_URL` thành URL gốc công khai trỏ tới backend khi triển khai. Nếu để trống, mobile dùng máy chủ API đang cấu hình để dựng URL. Link từ môi trường localhost hoặc LAN chỉ dùng được trên thiết bị truy cập được máy chủ đó. Native Android hiện dùng custom scheme. Chưa cấu hình HTTPS App Links đã xác minh và repo chưa có native iOS. [Android App Links](https://docs.flutter.dev/cookbook/navigation/set-up-app-links)


## Bằng chứng đã ghi nhận

| Đợt kiểm tra | Kết quả | Nội dung |
| --- | --- | --- |
| Chỉnh sửa, Mốc 9 | Backend 79 test, Flutter 31 test; analyze sạch | Giữ ID, thay snapshot đúng lúc, rollback liên ngày, tổng tiền/cảnh báo, giữ bản sửa khi 409 hoặc lưu lỗi |
| Quản lý/chia sẻ, Mốc 10 | Backend 81 test, Flutter 34 test; analyze sạch | Quyền chủ chuyến, độc lập bản sao, biên ngày lịch sử, trang khách, public DTO, thu hồi/hết hạn token |

Backend dùng MySQL 9.2 cô lập. Deep link đã được kiểm tra trong Flutter, chưa phải bằng chứng mở link trên Android vật lý hoặc máy chủ công khai.

## Giới hạn

Chưa nghiệm thu trên thiết bị với mạng lỗi hoặc endpoint route thật. Link localhost/LAN chỉ dùng được khi thiết bị truy cập được máy chủ. Native Android dùng custom scheme; HTTPS App Links và native iOS chưa được xác nhận. Các thay đổi focus/bảo vệ form sau đó xem [trải nghiệm và khả năng tiếp cận](../experience/localization-and-accessibility.md).

Quay lại [mục lục báo cáo](../README.md).
