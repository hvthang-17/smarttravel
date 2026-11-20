# Schema và ý nghĩa dữ liệu SmartTravel

Rà soát ngày 16/11/2026. Mô tả schema hiện hành trong [V1](../../backend/src/main/resources/db/migration/V1__init_schema.sql), thay thế đề xuất 33 bảng. [ERD đầy đủ](erd/smarttravel.mmd) liệt kê cột vật lý; [trạng thái yêu cầu](../planning/requirements-status.md) phân biệt đã triển khai với đã nghiệm thu. Database cũ có lịch sử migration khác vẫn cần phương án nâng cấp riêng.

## 1. Phạm vi và nguyên tắc

Trọng tâm đề tài: khám phá địa điểm Đà Nẵng, lập lịch trình theo sở thích/ngày/ngân sách, chỉnh sửa và tính lại, bản đồ, lưu chuyến và quản trị dữ liệu. Bộ gợi ý dựa trên quy tắc và chấm điểm, không bắt buộc LLM.

Điều chỉnh phạm vi theo người dùng: loại category HOTEL và nghiệp vụ gợi ý/tính tiền lưu trú khỏi MVP. Ngân sách chỉ gồm hoạt động và ăn uống; theo điều chỉnh tiếp theo của người dùng, không tính chi phí di chuyển hoặc lưu trú. UI phải ghi rõ phạm vi dự toán. Khoảng cách và thời gian di chuyển vẫn dùng để kiểm tra lịch và hiển thị bản đồ. Điểm xuất phát vẫn có thể do người dùng nhập tên/tọa độ tùy ý, không cần địa điểm khách sạn trong catalog. Phần khác với yêu cầu gốc được theo dõi tại [trạng thái yêu cầu](../planning/requirements-status.md).

Schema hiện hành có **12 bảng vật lý**, bao gồm đánh giá nội bộ SmartTravel. V1 hiện tại tạo đủ 12 bảng, bao gồm generation input, constraint snapshot và metadata gợi ý đã gộp từ V11/V12 theo yêu cầu người dùng. Các so sánh với mô hình cũ chỉ giải thích quyết định thu gọn, không mô tả migration nâng cấp đã chạy.

- Giữ PK/FK và tên cột V1 khi có thể; dùng BIGINT cho tiền VND, InnoDB, utf8mb4, MySQL 8.4.
- Tách thông tin xác thực ở users khỏi hồ sơ du lịch ở traveler_profiles. Thông tin đầu vào của mỗi chuyến vẫn đặt trong itineraries, không phụ thuộc vào hồ sơ sau khi tạo.
- Sở thích trong MVP chính là các danh mục địa điểm. Dùng categories.code làm mã lựa chọn; destinations.category_id xác định địa điểm phù hợp. Không cần hệ thống tag hoặc bảng liên kết sở thích địa điểm riêng.
- Giữ giá trị chưa biết là NULL, không tự coi là miễn phí, mở cả ngày hoặc mất 0 phút di chuyển.
- Ngày/giờ chuyến theo Asia/Ho_Chi_Minh; timestamp hệ thống lưu UTC. Không thay đồng loạt kiểu thời gian của V1 trong cùng một lần nâng cấp.

## 2. Danh sách bảng và lý do tồn tại

| Bảng | Nguồn trong chuỗi hiện tại | Mục đích / yêu cầu |
| --- | --- | --- |
| users | V1 | Tài khoản và quyền truy cập; FR-01/15 |
| categories | V1 | Danh mục chính của địa điểm; FR-03/14 |
| destinations | V1 | Địa điểm, giá và thời lượng; FR-03/04/07/14 (giới hạn FR-04 ghi bên dưới) |
| itineraries | V1 | Đầu vào và kết quả của chuyến, lưu/chia sẻ; FR-06/07/10/11/12 |
| itinerary_days | V1 | Ngày tham quan và điểm xuất phát; FR-08/10 |
| itinerary_items | V1 | Hoạt động, chi phí và chặng đi tới hoạt động; FR-08/09/10/13 |
| audit_logs | V1 | Ghi thao tác quản trị thật; FR-16 |
| destination_reviews | V1 | Đánh giá của người dùng SmartTravel; mở rộng phạm vi theo người dùng |
| traveler_profiles | V1 | Hồ sơ du lịch, mặc định và danh sách sở thích; FR-02 |
| favorites | V1 | Yêu thích theo tài khoản; FR-05 |
| itinerary_constraints | V1 | Điểm bắt buộc/loại trừ, có FK; FR-06/07 |
| password_reset_tokens | V1 | Quên mật khẩu theo luồng đăng nhập của PRD |

[ERD đầy đủ](erd/smarttravel.mmd) liệt kê toàn bộ cột của 12 bảng trong V1 hiện tại, gồm auth_version, generation input, constraint snapshot và metadata gợi ý. description là mô tả tiếng Việt có sẵn, description_en là tiếng Anh; tương tự name/name_en. Các trường đã loại khỏi thiết kế không được đưa lại vào ERD. Trường app_rating/app_review_count chỉ tính khi trả API nên không là cột trong sơ đồ. ERD thể hiện PK/FK/UK; độ dài, nullable, CHECK và unique ghép được giải thích trong báo cáo hoặc giữ theo V1 khi không có điều chỉnh.

## 3. Tài khoản và sở thích

**users:** giữ id, email UNIQUE, password_hash, full_name, role, status, created_at, updated_at; auth_version nằm trong V1 hiện tại. full_name vẫn là tên hiển thị tài khoản để tương thích API hiện tại; không lưu thêm bản sao tên trong hồ sơ.

**traveler_profiles:** user_id BIGINT PK/FK users ON DELETE CASCADE; language VARCHAR(5) DEFAULT 'vi'; default_budget_vnd BIGINT NULL; default_pace VARCHAR(30) DEFAULT 'balanced'; default_transport VARCHAR(20) DEFAULT 'unspecified'; preferred_categories JSON NOT NULL; created_at, updated_at. Một tài khoản có tối đa một hồ sơ; tài khoản quản trị có thể không cần hồ sơ du lịch. Nếu chưa có hồ sơ, API trả mặc định nhưng không tự ghi đè chuyến đã lưu.

- language vi/en; pace relaxed/balanced/packed; transport walking/motorbike/car/taxi/unspecified. Ngân sách là tổng chuyến mặc định, NULL hoặc >0.
- preferred_categories là mảng categories.code, ví dụ ["FOOD", "BEACH", "CULTURE", "CHECKIN", "CAFE", "NIGHTLIFE"], mặc định []. Mã NIGHTLIFE theo seed hiện tại (không phải NIGHLIFE). Không tạo bảng user_interests hoặc lưu chuỗi phân cách dấu phẩy.
- JSON không có FK từng phần tử: service kiểm tra từng code tồn tại và ACTIVE trong categories, loại trùng và từ chối mã sai/HOTEL ngoài phạm vi. Giữ categories.code ổn định; tên hiển thị lấy từ name/name_en. Không đổi code đang được tham chiếu bằng JSON.
- Đọc mã từ hồ sơ hoặc wizard, tra categories để lấy ID rồi lọc destinations.category_id IN (...) với địa điểm và danh mục đều ACTIVE. Hồ sơ cung cấp mặc định, lựa chọn wizard của từng chuyến được ưu tiên.
- [] nghĩa là chưa ưu tiên danh mục nào, không phải loại hết địa điểm. Danh mục đã ẩn được hiển thị là không còn khả dụng trong hồ sơ và bỏ khỏi lựa chọn mặc định; nếu request gửi mã ẩn thì trả lỗi rõ ràng, không âm thầm đổi bộ lọc.
- JSON phù hợp hồ sơ nhỏ đọc/ghi nguyên khối; thống kê sở thích theo danh mục không phải truy vấn chính. Một địa điểm khớp theo danh mục chính duy nhất, không có nhiều nhãn trải nghiệm độc lập. Đây là giới hạn phạm vi đã chọn để giữ mô hình đơn giản.
- Chỉ lưu các đặc điểm thực sự dùng để điền wizard/gợi ý. Chưa thêm tuổi, giới tính, sức khỏe hay tính cách khi PRD không cần.

**favorites:** user_id FK users, destination_id FK destinations, created_at; PK(user_id, destination_id). Xóa tài khoản/địa điểm vật lý thì cascade các bảng nối; danh mục đang dùng ưu tiên ẩn thay vì xóa. Điểm ẩn không xuất hiện trong khám phá hoặc được thêm vào chuyến mới.

**password_reset_tokens:** id PK, user_id FK users ON DELETE CASCADE, token_hash BINARY(32) UNIQUE, expires_at, used_at NULL, created_at; index(user_id, expires_at). Chỉ lưu hash, token dùng một lần bằng cập nhật có điều kiện trong transaction. Đổi mật khẩu tăng auth_version và vô hiệu các token reset còn lại. API không tiết lộ email tồn tại.

## 4. Địa điểm và giờ mở cửa

**categories:** giữ cấu trúc V1, dùng ACTIVE/INACTIVE; không tạo bảng phân cấp hoặc nối nhiều danh mục. Catalog MVP loại HOTEL khỏi khám phá và gợi ý. Seed hiện hành chỉ tạo sáu danh mục trong phạm vi và không có seed HOTEL. Dữ liệu HOTEL từ database lịch sử, nếu có, cần xử lý qua kế hoạch nâng cấp riêng; không xóa snapshot lịch trình để lấp khác biệt.

**destinations:** chứa category_id, tọa độ, thông tin liên hệ, ảnh và giá. Các trường cần lưu ý:

| Trường | Kiểu / ý nghĩa |
| --- | --- |
| name_en, description_en | VARCHAR(180) NULL, TEXT NULL; nội dung Việt/Anh, thiếu thì fallback tiếng Việt |
| visit_duration_minutes | INT NULL; thời lượng tham quan >0, thiếu thì cảnh báo và dùng mặc định có nhãn ước tính |
| opening_hours | JSON NULL; lịch tuần chuẩn hóa dùng chung cho hiển thị và kiểm tra lịch |

Giá NULL là chưa biết, 0 là đã xác nhận miễn phí; min >=0 và max >=min khi có. Latitude trong [-90,90], longitude trong [-180,180]. Với giá khoảng, dùng cận trên cho kiểm tra ngân sách thận trọng và ghi cách tính. Khoảng giá hoạt động quy ước theo một người cho một lần ghé; không áp dụng giá phòng, giá nhóm hoặc menu từng món trong MVP.

Giữ image_url và sub_images của V1 cho quy mô đồ án; service xác thực sub_images là mảng URL. Chưa cần destination_media. Phạm vi Đà Nẵng kiểm tra tại service bằng vùng phục vụ cấu hình.

**Rating Google Maps:** đổi rating/review_count của destinations thành google_rating DECIMAL(2,1) NULL và google_review_count INT NULL để phân biệt nguồn. Điểm tương ứng rating và số lượt tương ứng userRatingCount của Places API; cập nhật định kỳ chỉ tác động hai trường Google. google_rating từ 1–5 khi có; google_review_count >=0. NULL nghĩa chưa có dữ liệu, không tự gán điểm 4.5 hoặc số lượt 0. Cập nhật cặp giá trị trong cùng transaction để không ghép điểm mới với số lượt cũ; lần thu thập lỗi giữ dữ liệu cũ, không ghi 0 thay lỗi. V1 hiện tại đã dùng tên cột Google và cho phép NULL. Với database cũ dùng rating/review_count, cần migration nâng cấp riêng và rà soát dữ liệu; không coi mọi giá trị 4.5 là giả hoặc xóa số liệu thật. Nội dung Google vẫn chịu chính sách lưu trữ/attribution; lịch cập nhật định kỳ không mặc nhiên cho phép lưu vô thời hạn. Không dùng điểm Google để ghi vào bảng đánh giá nội bộ.

**Điểm SmartTravel:** app_rating và app_review_count là trường trả về API, tính từ SUM(rating)/COUNT(*) và COUNT(*) của destination_reviews WHERE status='PUBLISHED', không lưu thêm cột tổng hợp trong destinations ở MVP. Không có đánh giá thì app_rating=NULL, app_review_count=0. Chỉ làm tròn điểm khi hiển thị. Truy vấn nhóm theo destination_id và lấy cả điểm/số lượt cùng một truy vấn; danh sách nhiều địa điểm dùng truy vấn nhóm theo tập ID để tránh N+1. Hai nguồn hiển thị riêng, không cộng số lượt hoặc trộn điểm thành một rating duy nhất.

V1 chứa `destinations.featured_reason VARCHAR(240) NULL`. Admin nhập lý do đề xuất địa điểm tiêu biểu theo danh mục. NULL nghĩa là địa điểm chưa được đánh dấu tiêu biểu. [Hợp đồng REC](../reports/features/itinerary-generation.md#cơ-chế-gợi-ý-cá-nhân-hóa)

**Nguồn và thời điểm:** theo lựa chọn phạm vi của người dùng, không bổ sung trường định danh Google hoặc thời điểm cập nhật từ nguồn; source_url và verified_at cũng không nằm trong thiết kế đích. Giữ updated_at V1 để biết lần sửa bản ghi, không diễn giải thành thời điểm đồng bộ hoặc xác minh dữ liệu Google. Thiết kế hiện chưa đáp ứng phần hiển thị nguồn/thời điểm cập nhật từ nguồn của FR-04; đây là giới hạn đã ghi nhận, không tự thay đổi PRD. Không tạo trường thay thế hoặc bảng metadata cho các thông tin đã bỏ.

**opening_hours:** thay VARCHAR hiển thị và hours_status bằng một JSON; bỏ bảng destination_opening_hours. Cấu trúc ứng dụng chuẩn hóa, không lưu weekdayDescriptions để parse ngược và không sao chép nguyên payload Google:

```json
{
  "schema_version": 1,
  "timezone": "Asia/Ho_Chi_Minh",
  "week": {
    "1": [[480, 720], [810, 1050]],
    "2": [[480, 1050]],
    "3": [[480, 1050]],
    "4": [[480, 1050]],
    "5": [[480, 1050]],
    "6": [[0, 1440]],
    "7": []
  }
}
```

- SQL NULL: chưa biết toàn bộ lịch. week phải có đủ khóa 1–7 (thứ Hai–Chủ nhật); từng ngày NULL là chưa biết, [] là đóng cửa, [[0,1440]] là mở cả ngày. Không cần hours_status riêng.
- Mỗi cặp là [phút mở, phút đóng), 0 <= mở < đóng <=1440. Nhiều cặp là nhiều ca; sắp xếp và không chồng nhau. Mốc 1440 là đầu ngày kế tiếp. Ca qua đêm tách sang hai ngày.
- UI sinh chữ như “08:00–12:00, 13:30–17:30” từ JSON; engine kiểm tra toàn khoảng [giờ bắt đầu, giờ kết thúc hoạt động] nằm trong một ca, không chỉ kiểm tra lúc đến.
- Backend xác thực schema, timezone, khóa ngày và khoảng phút. JSON ở DB không tự bảo đảm những điều kiện này. Adapter chuyển quy ước ngày của Google (Chủ nhật=0) sang ứng dụng (Chủ nhật=7), xử lý riêng luôn mở 24/7.
- Ngày lễ/thay đổi đột xuất chưa mô hình hóa; cần cảnh báo kiểm tra lại. Dữ liệu chưa biết không được dùng để khẳng định hoạt động chắc chắn khả thi.
- Migration mới phải chuyển đổi VARCHAR cũ sang JSON theo dữ liệu đã kiểm tra; chuỗi không parse an toàn giữ trong bản sao lưu/chuyển đổi để rà soát, không tự biến thành đóng cửa hoặc mở 24/7.

**Ý nghĩa giá:** price_min_vnd/price_max_vnd là khoảng chi tiêu cho một người/lần ghé. Ví dụ 60.000–100.000/người với 4 khách thành 240.000–400.000 cho hoạt động; dùng cận trên cho dự toán thận trọng. Bỏ price_basis khỏi destinations và itinerary_items vì chỉ còn một đơn vị PER_PERSON cố định. Đây là quy ước dữ liệu, không phải khẳng định mọi dịch vụ thực tế tính theo người: nguồn giá nhóm/theo món phải được biên tập thành mức chi tiêu mỗi người có cơ sở, nếu chưa làm được thì giữ giá NULL hoặc loại khỏi catalog MVP. Giá vé trẻ em và người lớn không trộn thành min/max cho cùng đơn vị.

**Thời lượng tham quan:** visit_duration_minutes là ước tính biên tập do admin nhập, không tính từ google_rating, google_review_count hoặc giờ mở cửa và không giả định Google Places cung cấp. Giá trị minh họa: một điểm chụp ảnh 30 phút, bữa ăn 60 phút, bảo tàng 90 phút; phải rà lại theo địa điểm thật. Engine có thể điều chỉnh theo pace bằng chính sách rõ ràng; duration_minutes ở item lưu thời lượng cuối được chọn. Thời gian đi lại và đệm 30 phút tính riêng. Thiếu thời lượng dùng mặc định theo category có nhãn ước tính/cảnh báo.

**Phân loại chi phí:** dùng trực tiếp mã danh mục địa điểm, không gom FOOD/CAFE vào một nhóm ăn uống hoặc các danh mục còn lại vào ATTRACTION. itinerary_items.category_code VARCHAR(50) NOT NULL là snapshot của categories.code tại thời điểm thêm/thay địa điểm. Backend tra destinations.category_id -> categories.code và tự gán; client không nhập hay tự quyết định mã này. Không thêm trường phân loại chi phí khác vào destinations.

Ví dụ tổng tiền cả nhóm theo danh mục: BEACH 20.000đ, CAFE 30.000đ, FOOD 500.000đ -> tổng 550.000đ. Đây là tổng estimated_cost_vnd của các item tương ứng, không phải đơn giá mỗi người. Phân bổ theo danh mục phản ánh số tiền đã biết, không tự thêm tiền mua sắm hoặc chi phí chưa có dữ liệu.

## 5. Lịch trình: đầu vào, hoạt động, route và tiền

### itineraries

Các trường ngoài định danh/chủ sở hữu/ngày gồm transport VARCHAR(20), origin_name VARCHAR(255) NULL, origin_latitude/origin_longitude DECIMAL(10,7) NULL, preferred_categories_snapshot JSON NULL, generation_key VARCHAR(64) NULL, generation_status VARCHAR(20), warnings JSON NULL, cost_complete BOOLEAN, share_expires_at DATETIME NULL.

- preferred_categories_snapshot chỉ lưu mảng categories.code đã áp dụng tại thời điểm tạo, không chứa ID địa điểm và không phục vụ tìm kiếm quan hệ. Thay sở thích hồ sơ không làm đổi chuyến cũ.
- UNIQUE(user_id, generation_key) cho gửi lại cùng lần tạo. V1 chứa generation_input JSON NULL lưu đầu vào đã chuẩn hóa. Service so sánh với đầu vào này và trả 409 khi cùng key dùng đầu vào khác. Chuyến tạo mới bắt đầu ở DRAFT.
- Dùng status DRAFT/SAVED/ARCHIVED ở thiết kế đích. Khi nâng cấp, ánh xạ ACTIVE hiện có sang SAVED, không làm mất chuyến. generation_status COMPLETE/PARTIAL mô tả chất lượng kết quả riêng với trạng thái lưu. Không lưu kết quả rỗng thành chuyến hoàn chỉnh.
- share_token hiện có tiếp tục UNIQUE; thu hồi bằng xóa token, chia sẻ lại sinh token ngẫu nhiên mới. Kiểm tra hết hạn ở server; liên kết chỉ đọc, DTO công khai bỏ dữ liệu tài khoản và cấu hình riêng tư.
- Tổng ngày bằng end_date-start_date+1 và nằm trong 1–7; travelers_count 1–10; max_budget_vnd >0. version được kiểm tra khi cập nhật để chống ghi đè phiên sửa cũ; request sửa phải gửi version.
- Lịch sử lấy end_date < ngày hiện tại ở Đà Nẵng, không lưu thêm bảng history. Đổi tên cập nhật title; sao chép tạo lịch/ngày/item/constraints độc lập, không sao chép share_token.

**itinerary_constraints:** itinerary_id FK itineraries ON DELETE CASCADE, destination_id FK destinations ON DELETE RESTRICT, constraint_type VARCHAR(10) REQUIRED/EXCLUDED; PK(itinerary_id, destination_id). Một điểm không nằm ở cả hai loại; mỗi loại tối đa 5. Kiểm tra tại service trong transaction; điểm bắt buộc không khả dụng phải báo rõ. Bản nháp lưu các ràng buộc này ngay trong cùng transaction tạo chuyến, không cần trip_requests.

V1 chứa destination_snapshot JSON NULL lưu tên, mã danh mục, tọa độ và đơn giá lúc tạo, cùng index (status, updated_at) để dọn bản nháp quá hạn. Xem [luồng TRIP](../reports/features/itinerary-generation.md#đầu-vào-và-bản-nháp).

### itinerary_days

Có id, itinerary_id, day_number, date cùng origin_name/origin_latitude/origin_longitude nullable để ghi đè điểm đầu chuyến cho ngày tương ứng. Không thêm accommodation_cost_vnd hoặc accommodation_note.

UNIQUE(itinerary_id, day_number), UNIQUE(itinerary_id, date); date bắt buộc trong schema hiện hành. Service bảo đảm ngày liên tục và nằm trong khoảng chuyến. Không có nghiệp vụ lưu trú, phòng, booking hoặc thanh toán trong MVP.

### itinerary_items

Ngoài định danh, thứ tự, giờ, thời lượng, ghi chú và tiền hoạt động, mỗi item có các nhóm cột sau:

| Nhóm | Cột hiện hành |
| --- | --- |
| Snapshot hoạt động | destination_name VARCHAR(180), latitude/longitude DECIMAL(10,7) NULL, category_code VARCHAR(50) NOT NULL, unit_price_vnd BIGINT NULL, recommendation_reason VARCHAR(500) NULL, featured_recommendation BOOLEAN, upper_price_known BOOLEAN |
| Chặng đến hoạt động | travel_distance_m INT NULL, travel_duration_seconds INT NULL, route_source VARCHAR(20), route_polyline MEDIUMTEXT NULL |

Một dòng biểu diễn một hoạt động và chặng **đi tới** hoạt động đó: từ hoạt động trước, hoặc điểm xuất phát ngày nếu là hoạt động đầu. Không có origin thì chặng đầu UNKNOWN, không tự coi 0. MVP không tự thêm chặng quay về nơi ở cuối ngày; UI phải nêu giới hạn này.

- UNIQUE(day_id, sequence_order); thứ tự dương, thời lượng dương, tiền và khoảng cách/thời gian không âm. Cập nhật/reorder cần tránh xung đột unique tạm thời trong transaction.
- unit_price_vnd là đơn giá mỗi người được chọn khi lập/chỉnh hoạt động, lưu độc lập với giá catalog hiện tại để giải thích phép tính và tính lại khi đổi số khách. estimated_cost_vnd là tổng chi phí hoạt động của nhóm: unit_price_vnd × travelers_count theo quy ước giá mỗi người. Server tính từ dữ liệu tin cậy; không nhận tổng client như nguồn chuẩn. Giá chưa biết giữ NULL.
- category_code lưu mã danh mục tại lúc thêm/thay địa điểm, không là FK đến categories.code để không phụ thuộc danh mục về sau còn tồn tại hay không. Khi ghi mới, server phải kiểm tra category hiện hành tồn tại, ACTIVE và thuộc phạm vi. Chỉ đổi điểm mới lấy lại category_code; sửa ghi chú, thứ tự hoặc đơn thuần mở chuyến không đồng bộ lại mã từ catalog.
- Khi đổi category của địa điểm, các hoạt động đã lưu giữ category_code cũ; hoạt động mới dùng category mới. Vì snapshot chỉ lưu mã, categories.code phải ổn định, không được đổi hoặc tái sử dụng. Ưu tiên ẩn danh mục; tên hiển thị tra name/name_en theo mã; mã không xác định dùng nhãn danh mục chung, không tự gán sang danh mục khác hoặc đưa code thô vào vị trí tên. Tên danh mục có thể đổi, nhưng nhóm và số tiền lịch sử không thay đổi.
- Snapshot giữ lịch cũ đọc được nếu điểm về sau bị ẩn hoặc destination_id bị SET NULL theo V1. Không ghi đè snapshot cũ bằng catalog mới khi chỉ xem chuyến; thêm/thay điểm dùng dữ liệu hiện hành và kiểm tra ACTIVE cả điểm lẫn danh mục.
- route_source PROVIDER/CACHE/HAVERSINE/UNKNOWN. route_polyline lưu chuỗi JSON các cặp [kinh độ, vĩ độ] từ LineString của Directions. Haversine chỉ lưu ước tính khoảng cách và thời gian. Server tính lại chặng khi tạo hoặc sửa hoạt động. Cache có TTL trong bộ nhớ backend. Xem [hợp đồng MAP](../reports/features/routing-and-maps.md).
- Lịch hoạt động phải đủ thời gian đi lại và đệm 30 phút; khi không đủ hoặc thiếu dữ liệu phải trả cảnh báo rõ ràng. Không tự sửa giờ sai thành 09:00 mà báo thành công.

**Công thức tổng dùng chung cho tạo và sửa:**

`Tổng chuyến = SUM(estimated_cost_vnd) trên toàn bộ item`.

**Phân bổ theo danh mục:** nhóm toàn bộ item của chuyến theo category_code, cộng estimated_cost_vnd từng nhóm. Tổng các nhóm phải bằng total_estimated_cost. Khi một nhóm có giá NULL, trả tổng đã biết kèm số hoạt động thiếu giá; không đổi NULL thành miễn phí và không tuyên bố phân bổ đầy đủ. Danh mục có tất cả giá NULL phải thể hiện chưa có giá, thay vì một tổng 0 không giải thích.

```sql
SELECT i.category_code,
       SUM(i.estimated_cost_vnd) AS known_cost_vnd,
       SUM(CASE WHEN i.estimated_cost_vnd IS NULL THEN 1 ELSE 0 END) AS unknown_cost_count
FROM itinerary_items i
JOIN itinerary_days d ON d.id = i.day_id
WHERE d.itinerary_id = :itinerary_id
GROUP BY i.category_code;
```

Truy vấn minh họa cho schema đích; API phải kiểm tra chủ sở hữu/admin trước khi trả dữ liệu. Backend tính tổng chuyến từ các khoản đã biết và giữ cost_complete=false khi có giá thiếu, không tin số liệu tổng hợp từ client.

Tổng dự toán và max_budget_vnd đều không bao gồm chi phí di chuyển hoặc lưu trú; default_budget_vnd của hồ sơ có cùng phạm vi. Không tự trừ tiền khách sạn khỏi ngân sách đầu vào.

Tổng ngày/quãng đường/thời gian tính từ item, không thêm bảng tổng hợp. total_estimated_cost của V1 lưu tổng các khoản đã biết, cost_complete=false khi còn khoản bắt buộc chưa biết; không khẳng định trong ngân sách nếu còn thiếu. Chi phí hoạt động phân theo category_code đã lưu trên từng item. Không lưu hoặc cộng tiền di chuyển/lưu trú trong dự toán này; việc loại hai hạng mục là giới hạn phạm vi so với PRD, không được hiển thị như toàn bộ chi phí thực tế chuyến đi.

Sửa một ngày vẫn tính tổng từ **toàn bộ trạng thái cuối của chuyến**. Kiểm tra day/item thuộc lịch của chủ sở hữu, kiểm tra version và ghi thay đổi trong một transaction. Không giữ transaction mở trong lúc chờ nhà cung cấp route; lấy dữ liệu trước và kiểm tra lại version khi áp dụng.

## 6. Audit và đánh giá người dùng

**audit_logs:** có user_id nullable với ON DELETE SET NULL, actor_name VARCHAR(150) NULL, entity_type VARCHAR(50), entity_id BIGINT NULL, action, details, created_at. details chứa JSON trước/sau đã lọc dữ liệu nhạy cảm, service xác thực định dạng. actor_name mô tả tác nhân khi tài khoản còn tồn tại; luồng xóa tài khoản ẩn danh actor_name và bỏ liên kết user_id để không giữ bản sao hồ sơ cá nhân. Sự kiện nghiệp vụ vẫn được giữ. Index(created_at), (user_id, created_at), (entity_type, entity_id).

Ghi thay đổi quản trị và audit cùng transaction. Không log password_hash, token, khóa API. Dashboard truy vấn thống kê từ các bảng nghiệp vụ, không tạo bảng dashboard hoặc dữ liệu cảnh báo mẫu.

**destination_reviews:** kích hoạt trong phạm vi thiết kế theo xác nhận của người dùng; khác PRD gốc vốn để review ngoài MVP. CRUD, kiểm duyệt và nơi nhận báo cáo đã được triển khai ở [Mốc 11](../reports/features/reviews-and-moderation.md). Các trường và ràng buộc hiện hành:

| Trường | Kiểu / ý nghĩa |
| --- | --- |
| id | BIGINT PK; định danh đánh giá |
| destination_id | BIGINT NOT NULL FK destinations; địa điểm được đánh giá |
| user_id | BIGINT NOT NULL FK users; tác giả, phải đăng nhập |
| rating | INT NOT NULL CHECK 1–5; điểm người dùng tự chấm |
| comment | TEXT NULL; có thể chỉ chấm sao, nội dung bình luận phải có giới hạn độ dài ở DTO |
| status | VARCHAR(20) NOT NULL DEFAULT 'PUBLISHED'; PUBLISHED hoặc HIDDEN |
| created_at | TIMESTAMP; thời điểm gửi lần đầu |
| updated_at | TIMESTAMP; thời điểm sửa nội dung/điểm hoặc đổi trạng thái |

- UNIQUE(user_id, destination_id): mỗi tài khoản một đánh giá cho mỗi địa điểm. Sửa đánh giá không tăng số lượt. Index(destination_id, status) phục vụ danh sách và tổng hợp. Không đánh dấu từng FK riêng là UNIQUE trong ERD.
- Chỉ tác giả được sửa/xóa đánh giá của mình; admin có thể ẩn/hiện khi kiểm duyệt và phải ghi audit cùng transaction. Tác giả sửa bài HIDDEN không tự chuyển lại PUBLISHED. MVP cho phép gửi mới công khai; báo cáo nội dung được tiếp nhận qua luồng kiểm duyệt hiện có, không thêm bảng báo cáo riêng.
- Khi đăng mới phải kiểm tra tài khoản hợp lệ và địa điểm/danh mục ACTIVE, trong phạm vi MVP. Bình luận cũ của điểm ẩn không làm điểm đó công khai trở lại. Nội dung hiển thị như văn bản, không render HTML tùy ý.
- Tạo/sửa/xóa/ẩn/hiện chỉ thay đổi nguồn SmartTravel. Điểm và số lượt được tính lại từ các bản PUBLISHED khi đọc. Ví dụ 5,4,3 sao -> điểm 4 và 3 lượt; thêm 5 sao -> 4.25 và 4 lượt; sửa sao giữ số lượt; ẩn/xóa giảm số lượt tương ứng.
- Giữ ON DELETE CASCADE của FK V1: nếu xóa vật lý user hoặc destination, đánh giá liên quan bị xóa; phép tổng hợp phản ánh dữ liệu còn lại. Khóa tài khoản không tự xóa đánh giá đã công khai, admin xử lý nội dung riêng khi cần.
- Chưa xác minh việc ghé thăm: có lịch trình hoặc ngày chuyến đã qua không chứng minh người dùng thực sự đến địa điểm. Không gắn nhãn đã xác minh trải nghiệm.
- Thu thập Google định kỳ cập nhật độc lập google_rating/google_review_count, không ghi đè đánh giá SmartTravel. Nếu sau này cache số liệu nội bộ thì cần cơ chế nhất quán riêng; chưa thêm cache cột ở MVP.

## 7. Thu gọn từ đề xuất 33 bảng

| Nhóm cũ | Xử lý trong phạm vi đề tài |
| --- | --- |
| user_preferences, user_interest_preferences | Gộp thành traveler_profiles với preferred_categories JSON; bỏ bảng user_interests riêng |
| interest_tags, destination_interest_tags | Dùng trực tiếp categories và destinations.category_id; bỏ hệ thống tag riêng |
| areas, canonical destination, destination_evidence | Không đưa vào MVP; vùng phục vụ cấu hình; không bổ sung metadata nguồn vào destinations |
| destination_prices, destination_media | Dùng khoảng giá mỗi người và ảnh V1; chưa có biểu giá nhiều đối tượng hoặc quản lý media độc lập |
| destination_opening_windows/exceptions | Một trường opening_hours JSON; ngoại lệ lễ/tết cảnh báo thủ công |
| trip_requests, trip_request_interests/destinations | Đầu vào trên itineraries, snapshot sở thích và itinerary_constraints |
| recommendation_runs/candidates, ai_invocations, recommendation_feedback | Bỏ khỏi MVP; chấm điểm trong service, lưu lý do ở item và warnings trên chuyến; log thời gian/lỗi có mã request |
| itinerary_legs/stays/cost_lines | Route gắn item, tổng từ dữ liệu cuối; loại lưu trú và không mở rộng booking hay sổ kế toán |
| itinerary_share_links, route_cache | Một token/chuyến và hạn dùng; cache backend có TTL |
| itinerary_revisions | Hoàn tác phiên bản là mở rộng, chưa đưa vào MVP |

Không bổ sung OAuth, chatbot/chỉnh sửa ngôn ngữ tự nhiên, theo dõi hành vi, nhiều phương án AI, đa thành phố hoặc đặt dịch vụ chỉ để tăng số tính năng. Password reset được giữ vì PRD có luồng quên mật khẩu; nó không phụ thuộc LLM hay dịch vụ booking.

## 8. Đối chiếu và triển khai tăng dần

| Yêu cầu | Dữ liệu đáp ứng |
| --- | --- |
| FR-01/02/15 | users, traveler_profiles, categories; reset token cho luồng quên mật khẩu |
| FR-03/04/14 | categories, destinations; opening_hours JSON |
| FR-05 | favorites |
| FR-06/07 | itineraries, itinerary_constraints và catalog/danh mục/giờ |
| FR-08/09/10/13 | itinerary_days, itinerary_items, snapshot/route/chi phí và version chuyến |
| FR-11/12 | Chủ sở hữu, title/status/ngày của itineraries; thao tác sao chép/xóa tại service |
| FR-16 | audit_logs |
| Đánh giá nội bộ (phạm vi bổ sung) | destination_reviews; điểm/số lượt nội bộ tính khi đọc, tách biệt số liệu Google |

Schema hỗ trợ yêu cầu, không tự chứng minh thuật toán, API hay giao diện đã hoạt động. Bộ gợi ý vẫn phải lọc ACTIVE, thỏa required/excluded, chấm điểm, phân bố theo vị trí/giờ/pace và kiểm tra ngân sách bằng test.

### Chuỗi migration hiện hành

| Script | Nội dung |
| --- | --- |
| V1__init_schema.sql | Tạo đủ 12 bảng, auth_version, profile/reset/review/constraints, snapshot/route, generation_input/destination_snapshot, index dọn DRAFT và metadata gợi ý |
| V2__seed_system_data.sql | Seed sáu danh mục và dữ liệu hệ thống |
| V3–V8 | Seed lần lượt BEACH, FOOD, CULTURE, CHECKIN, CAFE, NIGHTLIFE; giá và giờ theo schema hiện tại |

Chuỗi hiện hành chỉ có 8 script V1–V8. V11/V12 đã được gộp vào V1 và bỏ khỏi thư mục theo yêu cầu người dùng; không có file V9–V12 hiện hành. V1 đã từng được viết lại theo yêu cầu trực tiếp của người dùng; đó là thay đổi baseline, không phải bằng chứng database cũ đã được nâng cấp. Entity/service và seed tiếp tục dùng cùng cấu trúc cột; nhận định cũ “chưa chạy được Flyway” không còn mô tả mã nguồn hiện hành.

### Database mới và database đã tồn tại

- Với database mới, chạy đúng chuỗi trong [thư mục migration](../../backend/src/main/resources/db/migration) và giữ `ddl-auto=validate`. Báo cáo Mốc 12 ghi kiểm thử trên MySQL 9.2 cô lập; MySQL 8.4 vẫn cần bằng chứng riêng trước phát hành.
- Với database đã tồn tại, đọc `flyway_schema_history` trên bản sao được phép truy cập, đối chiếu phiên bản/checksum (kể cả DB đã chạy V11/V12 hoặc V1 trước khi gộp), backup và thử phương án nâng cấp/rollback. Không tự chạy repair, xóa lịch sử, sửa migration đã áp dụng hoặc dựng lại DB có dữ liệu.
- [Checksum giai đoạn 0](../reports/evidence/baseline-migration-sha256.txt) là bằng chứng lịch sử, có tên seed/phiên bản khác hiện tại. Giữ nguyên byte; không dùng nó làm checksum của baseline hiện hành.
- Kiểm tra owner/admin, FK/unique, snapshot/version, giá/giờ NULL, ngân sách, route lỗi, reset dùng một lần và review hai nguồn trên chuỗi mới lẫn phương án nâng cấp. [Kế hoạch QA/OPS](../planning/completion-plan.md) quản lý tiêu chí còn mở.

## 9. Tham chiếu dữ liệu Google

- [Place resource: rating, userRatingCount, regularOpeningHours](https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places).
- [Places API policies: lưu trữ và attribution](https://developers.google.com/maps/documentation/places/web-service/policies).

Rating không phải thời lượng tham quan. Phần nguồn/thời điểm cập nhật từ nguồn của FR-04 chưa được đáp ứng trong thiết kế thu gọn; chính sách nhà cung cấp vẫn áp dụng.
