# Catalog, khám phá địa điểm và yêu thích

Catalog có quy tắc chung cho sáu danh mục; người dùng tìm/lọc địa điểm và lưu yêu thích theo tài khoản. Ẩn địa điểm không xóa review hoặc snapshot lịch trình.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Backend, admin và mobile |
| Công việc liên quan | Mốc 3: CAT-01/02, AUD-01; Mốc 5: DISC-01/02, FAV-01 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Đọc nhanh

| Tình huống | Cách xử lý |
| --- | --- |
| Danh mục/địa điểm bị ẩn | Không vào khám phá hoặc lựa chọn mới; dữ liệu lịch sử được giữ |
| Giá chưa biết | Giữ NULL, không hiển thị như miễn phí |
| Thêm lại điểm yêu thích | Không tạo liên kết trùng |
| Người dùng đổi tài khoản | Trạng thái yêu thích theo phiên của tài khoản mới |
| Đổi mã danh mục đang dùng | Không cho phép; chỉ sửa tên/nội dung hoặc ẩn |

## Quản trị catalog

### Chính sách catalog

- Chỉ nhận BEACH, FOOD, CULTURE, CHECKIN, CAFE, NIGHTLIFE. Mã bắt buộc khi tạo và không đổi khi sửa. Mã/slug trùng trả 409; không nối hậu tố và không suy mã từ tên. Nếu đã seed đủ sáu mã, dùng sửa/khôi phục danh mục hiện có. API tạo phục vụ trường hợp thiếu danh mục, không mở thêm phạm vi nghiệp vụ.
- Category ID, categoryCode và category trong request phải nhất quán. Chuỗi category phải là mã chuẩn; tên tiếng Việt, slug cũ, sai chữ hoa/thường và HOTEL trả 400 có hướng dẫn. Profile preferences và request tạo chuyến dùng cùng policy; không tự chọn danh mục đầu hoặc lấy tất cả địa điểm khi lựa chọn không hợp lệ. Danh mục hợp lệ nhưng thiếu địa điểm khả dụng trả 409 để chọn lại.
- Public chỉ đọc category trong phạm vi và ACTIVE; destination phải ACTIVE và thuộc category khả dụng. Admin vẫn đọc được bản ghi ẩn/legacy. HOTEL/nhóm ngoài phạm vi không được tạo, gán qua ID, sửa để đưa vào nghiệp vụ mới hoặc hiện lại bằng toggle. Snapshot/JSON lịch sử không bị tự viết lại.
- Không chọn mới hoặc chuyển destination sang category ẩn. Destination đang gắn với category ẩn vẫn sửa metadata và giữ liên kết cũ được. Muốn khôi phục destination INACTIVE cần hiện category trước; nếu chưa, API trả 409.

### Xóa mềm và dữ liệu liên quan

DELETE category/destination đặt INACTIVE, không xóa hàng. Admin có xác nhận ẩn và có thể hiện lại qua trạng thái. Không còn API xóa cứng catalog.

Ẩn category không đổi category_id hoặc trạng thái riêng của các destination con. Public/gợi ý loại chúng theo trạng thái category. Khi hiện lại category, destination vốn ACTIVE xuất hiện lại; destination đã ẩn riêng vẫn INACTIVE.

Review, favorite, snapshot và FK giữ nguyên. Không xóa file ảnh cũ khi gỡ liên kết vì ảnh có thể còn được tham chiếu. Vì DELETE không xóa hàng nên không gây lỗi FK/cascade mất review. Vi phạm FK/unique từ database trên các đường ghi còn lại trả ApiResponse 409; lỗi lựa chọn/trạng thái trả 400/409 có nội dung cụ thể.

### Metadata và ảnh

- PUT destination giữ semantics SYNC: trường nullable bị bỏ qua thì giữ, NULL thì xóa. Form gửi NULL khi xóa ảnh đại diện, bản dịch, mô tả hoặc liên hệ. Category PUT có cùng semantics cho nameEn/description/imageUrl; code không đổi.
- Giờ tuần/multiple shifts, giá NULL, giá 0 và thời lượng giữ qua lưu/mở lại. Form sửa có thể giữ category ẩn hiện tại và có thông báo; thiếu category không được thay bằng category đầu.
- URL ảnh chỉ HTTP(S) không chứa user info hoặc đường dẫn upload hợp lệ; tối đa 500 ký tự, 10 ảnh phụ, không trống/trùng. Backend kiểm tra cả API trực tiếp.
- Upload PNG/JPG/GIF, tối đa 5MB/ảnh, 1–10 ảnh/batch, tổng 25MB, 25 triệu pixel/ảnh. Backend kiểm tra định dạng thực, ghi lại ảnh và dọn file đã ghi nếu batch lỗi. Lỗi lưu trữ trả 503, vượt giới hạn request trả 413.
- Admin kiểm tra loại/dung lượng trước khi gửi, báo lỗi và khóa lưu/đóng khi upload; chọn lại cùng file sau lỗi được. Upload chuẩn bị file, còn liên kết catalog và audit ghi khi lưu form. File orphan do hủy form chưa có tác vụ dọn tự động.
- Sidebar tự thu gọn dưới 768px, giảm padding nội dung để nút catalog không bị che trên màn hình nhỏ.

### Audit cùng transaction

AuditService dùng propagation MANDATORY, không tạo transaction độc lập hoặc nuốt lỗi. Service nghiệp vụ ghi thay đổi và audit trong cùng transaction; audit saveAndFlush để lỗi ghi không bị bỏ qua. Lỗi audit rollback cả nghiệp vụ và audit đã flush.

Actor tra từ tài khoản của phiên server qua CurrentUser, không nhận user_id/actor_name từ request. Actor name lưu snapshot. Đăng ký công khai không có phiên dùng user_id NULL và PUBLIC_REGISTRATION; khi có phiên thì dùng actor của phiên. Seed/bootstrap là khởi tạo hệ thống, không gán actor quản trị giả.

Các đường đã nối audit:

- Tạo/sửa/đổi trạng thái/ẩn category, tạo/sửa/ẩn/khôi phục destination.
- Admin tạo/sửa/đổi trạng thái/xóa user; đăng ký và sửa hồ sơ cá nhân.
- Kiểm duyệt review qua `PUT /api/v1/admin/reviews/{id}/status`, body `{"status":"HIDDEN"}` hoặc PUBLISHED, chỉ admin được gọi. Status và audit nguyên tử. CRUD review và nơi nhận báo cáo được mô tả riêng trong [đánh giá và kiểm duyệt](reviews-and-moderation.md).

Details chỉ lưu tên trường trong allowlist, categoryId, status/role hợp lệ và cờ credentialsChanged. Không serialize entity/request body, text tự do, password/hash/token hoặc dữ liệu lồng ngoài allowlist. Không ghi đầy đủ giá trị trước/sau. API đọc/lọc/xuất audit đã được bổ sung ở [báo cáo quản trị](administration.md).


## Khám phá và yêu thích

### Khám phá địa điểm

`GET /api/v1/destinations/discover` tìm theo tên Việt hoặc Anh, nhận mã danh mục và lọc giá tham khảo theo người. `category` có thể chứa nhiều mã phân cách bằng dấu phẩy. Màn khám phá dùng danh mục đang hoạt động từ catalog, gồm lựa chọn lọc theo sở thích trong hồ sơ. Backend chỉ trả địa điểm thuộc danh mục trong phạm vi khi cả điểm và danh mục đều ACTIVE. Chính sách này áp dụng cả khi người gọi là admin.

Khoảng giá địa điểm và khoảng lọc cần có giao nhau. Nếu địa điểm chỉ có một cận, dùng cận đó làm mốc so sánh. Điểm thiếu cả hai cận xuất hiện khi chưa lọc giá và bị bỏ qua khi có cận giá lọc. Cặp giá 0–0 là miễn phí. Một cận bằng 0 hiển thị đúng dạng “Từ 0” hoặc “Tối đa 0”.

API trả `items`, `page`, `hasNext` với thứ tự theo ID. Mặc định 24 điểm mỗi trang, tối đa 100. Mobile trở về trang đầu khi đổi bộ lọc và có trạng thái tải, rỗng và thử lại. Trang chủ dùng cùng API cho tìm nhanh và chuyển điều kiện tìm sang màn khám phá.

`GET /api/v1/destinations/discover/{id}` trả chi tiết công khai. Mobile dùng tên danh mục từ catalog và ưu tiên dữ liệu Anh khi hồ sơ chọn tiếng Anh, rồi dùng tiếng Việt nếu thiếu bản dịch. Hình lấy từ ảnh bìa và ảnh phụ. Giờ tuần gộp các ngày liên tiếp có cùng lịch, giữ các ca và trạng thái chưa rõ hoặc đóng cửa. Giá, thời lượng và đánh giá hiển thị theo dữ liệu thực. Google Maps và SmartTravel có điểm và số lượt riêng. Nút bản đồ dùng vĩ độ, kinh độ đầy đủ từ API.

### Yêu thích và wizard

| API | Hành vi |
| --- | --- |
| `GET /api/v1/favorites` | Liệt kê điểm đã lưu của tài khoản hiện tại khi điểm và danh mục đang hiển thị |
| `PUT /api/v1/favorites/{id}` | Lưu điểm đang khả dụng, lặp lại vẫn chỉ có một liên kết |
| `DELETE /api/v1/favorites/{id}` | Bỏ liên kết của tài khoản hiện tại, kể cả khi điểm đã ẩn hoặc liên kết đã bị bỏ |

Backend dùng ID từ phiên và khóa hàng của chủ sở hữu khi ghi. Khóa chính ghép của bảng giữ duy nhất một liên kết cho mỗi cặp user/destination. Ẩn điểm hoặc danh mục giữ liên kết trong DB và bỏ mục khỏi danh sách công khai, yêu thích và lựa chọn mới. Khi khôi phục điểm và danh mục, mục xuất hiện lại.

Mobile dùng cùng trạng thái yêu thích theo token cho trang chủ, khám phá, chi tiết và mục Địa điểm đã lưu trong hồ sơ. Thay đổi chỉ xuất hiện sau khi server xác nhận. Danh sách được tải lại theo phiên và khi vào mục đã lưu. Wizard cho chọn các điểm đã lưu hoặc nhận lựa chọn ban đầu từ chi tiết điểm đã lưu.

Request tạo chuyến có thể gửi `favoriteDestinationIds`. Backend kiểm tra điểm thuộc danh sách của người dùng và còn khả dụng tại lúc tạo. Điểm đã chọn được đưa vào trước trong giới hạn số hoạt động của chuyến. Danh mục sở thích lọc các điểm bổ sung. Lựa chọn đã bị bỏ lưu hoặc ẩn trả 409 để người dùng tải lại và chọn lại.


## Bằng chứng đã ghi nhận

| Đợt kiểm tra | Kết quả | Phạm vi thực sự được kiểm tra |
| --- | --- | --- |
| Catalog/audit, Mốc 3 | Backend 39 test; admin 13 test catalog và 6 test security; build đạt | Rollback khi audit lỗi, actor server, code bất biến, trạng thái ẩn, metadata NULL, upload và quyền |
| Browser catalog, Mốc 3 | Backend/DB cô lập; desktop 1280 px và modal 390 px | Tạo/sửa/mở lại/ẩn/khôi phục, ảnh PNG thật, lỗi SVG, hai ca giờ, giá và bản dịch; audit được ghi |
| Khám phá/yêu thích, Mốc 5 | Backend 46 test, Flutter 25 test và analyze sạch | Tìm Việt/Anh, giá một cận/NULL, phân trang, lưu đồng thời, cách ly tài khoản, chọn vào wizard |

Các đợt backend dùng MySQL 9.2 cô lập, không phải bằng chứng MySQL 8.4 hoặc DB đang triển khai. Không cộng số test giữa các dòng.

## Giới hạn

Chưa có bằng chứng thu thập Google định kỳ, xác minh catalog thực tế hoặc E2E mobile trên thiết bị. File upload không còn liên kết sau khi hủy form chưa có tác vụ dọn tự động. Việc đọc audit/kiểm duyệt đã được triển khai sau đợt catalog và có báo cáo riêng, không còn là chức năng “chưa có” như ghi nhận đầu kỳ.

Quay lại [mục lục báo cáo](../README.md).
