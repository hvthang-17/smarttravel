# Backend tương thích schema mới

Cập nhật CAT/AUD (16/11/2026): [báo cáo](../docs/reports/features/catalog-and-discovery.md#quản-trị-catalog) thay policy xóa cứng bằng INACTIVE, thêm audit cùng transaction và policy sáu mã ổn định; bộ test hiện tại 39/39 đạt. Bằng chứng 25 test và policy trước đó bên dưới là lịch sử, không mô tả đầy đủ hợp đồng hiện hành.

Cập nhật: 16/11/2026. Schema nguồn: `src/main/resources/db/migration/V1__init_schema.sql`; seed hiện tại V2–V8. Không sửa migration trong lần điều chỉnh backend này.

## Phần đã cập nhật

- Entity ánh xạ đủ 12 bảng, gồm hồ sơ, yêu thích, review, audit, ràng buộc lịch trình và token reset. Mapping không đồng nghĩa đã có API nghiệp vụ cho mọi bảng.
- Destination ánh xạ rating/review_count Java cũ sang google_rating/google_review_count; thêm name_en, description_en, visit_duration_minutes. Không giữ giá trị rating giả 4.5 khi thiếu dữ liệu.
- opening_hours lưu JSON tuần. Service kiểm tra schema_version, timezone, đủ bảy ngày, phút trong 0–1440 và không chồng ca. Không suy diễn chuỗi giờ tự do thành lịch tuần.
- Trạng thái chuyến mới là SAVED để giữ hành vi tạo và lưu hiện có; phù hợp CHECK DRAFT/SAVED/ARCHIVED. version dùng JPA optimistic locking.
- Tạo/sửa item lưu snapshot tên, tọa độ, category_code và đơn giá. Giá dùng cận trên khi có, nếu chỉ biết cận dưới thì dùng cận dưới; không coi đó là bảo đảm ngân sách tối đa. Giá chưa biết giữ NULL, costComplete=false, budgetHealth=UNKNOWN.
- Tổng chuyến tính từ toàn bộ hoạt động, kể cả khi chỉ sửa một ngày. estimatedCostVnd do client gửi không được dùng làm giá nguồn. Không cộng tiền di chuyển/lưu trú.
- Chỉnh sửa thay tập item có bước flush các orphan trước khi insert để không vi phạm UNIQUE(day_id, sequence_order). Các bước vẫn trong cùng transaction; lỗi sẽ rollback.
- Phân bổ chi phí dùng category_code snapshot, không đọc lại category hiện tại để thay nhóm chuyến cũ. Đổi địa điểm lấy snapshot mới; khi gửi id hoạt động hiện có cùng destinationId, giữ snapshot cũ.
- Khoảng cách/thời gian hiện chỉ ước tính Haversine, lưu routeSource=HAVERSINE và không tạo polyline giả. Chặng đầu thiếu origin là UNKNOWN với số liệu NULL. Chưa tích hợp Directions.
- Chia sẻ kiểm tra share_expires_at nếu có; DTO công khai không trả shareToken.

## API và tương thích client

- Các endpoint hiện có giữ ApiResponse và chính sách phân quyền.
- Destination giữ rating/reviewCount như tên tương thích của số liệu Google, bổ sung googleRating/googleReviewCount. appRating/appReviewCount tính riêng từ review PUBLISHED theo truy vấn nhóm, không cộng số liệu Google.
- openingHours ở API tiếp tục là văn bản hiển thị sinh từ JSON. openingSchedule chứa object JSON chuẩn để đọc/ghi lịch. Có thể gửi chuỗi JSON vào openingHours; chuỗi giờ tự do bị từ chối 400. Khi form cũ gửi lại đúng văn bản đã đọc, lịch JSON hiện có được giữ nguyên.
- GET/PUT /api/v1/auth/profile bổ sung travelerProfile. PUT nhận thêm language, defaultBudgetVnd, defaultPace, defaultTransport, preferredCategories bên cạnh fullName. Trường mặc định bị bỏ qua trong request giữ giá trị cũ; mã category phải tồn tại, ACTIVE, không trùng và không thuộc HOTEL.
- Tạo chuyến giới hạn 1–7 ngày, 1–10 khách, ngân sách >0, pace hợp lệ; hỗ trợ transport và originName/originLatitude/originLongitude. Hai tọa độ origin phải được gửi cùng nhau.
- PUT activities nhận version tùy chọn để phát hiện request cũ, trả 409 khi lệch. Client cũ không gửi version vẫn hoạt động; JPA phát hiện ghi đè giữa các transaction đồng thời nhưng không phát hiện mọi request cũ gửi tuần tự nếu thiếu version.
- Item trả categoryCode, unitPriceVnd, routeSource, routePolyline. Category breakdown có khóa là code (BEACH, FOOD, CAFE...), cần kiểm tra cách client hiển thị nhãn. Số liệu route chưa biết có thể NULL.

## Bằng chứng kiểm thử

`mvn test -DargLine=-Xmx256m`: 25 test, 0 lỗi, 0 thất bại. Log: `target/schema-compat-tests.log`.

MySQL kiểm thử riêng tại 127.0.0.1:13316, datadir `target/schema-mysql-20261116`, database smarttravel_test. Tất cả 8 migration đã chạy và Hibernate ddl-auto=validate thành công. Server kiểm thử đã tắt sau chạy; không thao tác database đang dùng ở cổng 3306.

Bốn test mới tại SchemaCompatibilityTest kiểm tra JSON giờ/bản dịch/rating Google, sửa một ngày/tổng server/version conflict, giá chưa biết và tách rating nội bộ, hồ sơ và validation đầu vào. Bộ test cũ về quyền và hành trình tạo/sửa/mở lại vẫn đạt.

Giới hạn: môi trường kiểm thử có MySQL 9.2, chưa kiểm chứng trên MySQL 8.4 mục tiêu. Chưa kiểm tra mobile/admin UI trong công việc backend này. Không tuyên bố bộ gợi ý tối ưu hoặc kiểm tra giờ mở cửa khi sắp lịch đã hoàn thiện; việc xác thực dữ liệu giờ không thay thế thuật toán lập lịch.

## Database hiện có

V1 đã được viết lại trước đó và các seed được sắp lại. Thay Java không tự nâng cấp database cũ. Đã bỏ cấu hình repair-on-migrate; không chạy repair hoặc xóa database để che khác biệt checksum/lịch sử. Cần kế hoạch chuyển đổi riêng nếu giữ dữ liệu cũ.

Không thay tài khoản seed, osm_id mẫu hoặc dữ liệu địa điểm trong lần đồng bộ backend này. API CRUD đầy đủ cho favorite/review/constraints/reset và luồng ghi audit chưa được bổ sung chỉ vì có entity; phải triển khai theo từng gói nghiệp vụ.
