# Kế hoạch hoàn thiện và đồng bộ SmartTravel

Cập nhật: 16/11/2026. Thay thế kế hoạch 12/11 vốn mô tả trạng thái trước khi đồng bộ schema. Đây là backlog thực hiện, không phải xác nhận các chức năng bên dưới đã hoàn thành. Phạm vi backend, mobile, admin; mỗi gói triển khai theo thứ tự hợp đồng -> backend -> client -> kiểm thử -> cập nhật bằng chứng.

## 1. Phạm vi đã thống nhất

- 12 bảng trong [ERD](../architecture/erd/smarttravel.mmd), V1 schema và V2–V8 seed hiện tại. Không quay lại mô hình 33 bảng.
- Danh mục BEACH, FOOD, CULTURE, CHECKIN, CAFE, NIGHTLIFE. Sở thích hồ sơ là categories.code; không có interest_tags/destination_interests riêng.
- Bỏ HOTEL, lưu trú, booking, thanh toán. Ngân sách chỉ cộng chi phí hoạt động cho cả nhóm; không cộng tiền di chuyển. Vẫn tính thời gian/khoảng cách và hiển thị tuyến đường.
- Giá mỗi người/lần ghé; giữ unit_price_vnd snapshot, estimated_cost_vnd tổng nhóm và category_code snapshot. NULL khác 0.
- Giờ mở cửa JSON tuần là dữ liệu chuẩn; openingHours API là chữ hiển thị tương thích, openingSchedule là cấu trúc nhập/đọc.
- Rating Google và review SmartTravel tách biệt. Review nội bộ thuộc phạm vi bổ sung đã được người dùng chấp thuận; không tự xác nhận người viết đã đến địa điểm.
- Giữ các quyết định bỏ engine_version, route_provider, route_calculated_at và metadata nguồn/thời điểm bị loại. Quyết định cuối hiện chưa thêm source vào schema; nếu muốn source cần chốt và migration mới riêng. Phần thời điểm nguồn của FR-04 gốc là giới hạn phạm vi, không được nhận là đã đáp ứng.
- Không tự đưa OAuth, chỉnh sửa ngôn ngữ tự nhiên, lịch sử phiên bản/hoàn tác, hệ thống báo sai nội dung tổng quát, đa thành phố hoặc hệ thống AI nhiều lần chạy vào MVP. Các nút đang mô phỏng phải ẩn hoặc thể hiện đúng trạng thái chưa hỗ trợ.

## 2. Hiện trạng và cách dùng kế hoạch

Kế hoạch này giữ mã việc và tiêu chí nghiệm thu. [Trạng thái yêu cầu](requirements-status.md) là trang tiến độ hiện hành; [mục lục báo cáo](../README.md#báo-cáo-theo-chủ-đề) cung cấp bằng chứng theo mốc. Không dùng phần mô tả thiếu chức năng trong review cũ làm trạng thái hiện tại.

| Nhóm | Hiện trạng được ghi nhận | Phần còn mở |
| --- | --- | --- |
| SYNC và Mốc 3–12 | Đã triển khai các hợp đồng và luồng chính, có báo cáo/kiểm thử từng mốc | Email thật, route endpoint được duyệt, Google định kỳ, metadata tiêu biểu ở form admin và E2E toàn chuỗi |
| Mốc 13 UX | Tài nguyên Việt/Anh, hồ sơ language, bảo vệ bản sửa và bố cục responsive; mobile 40 test, admin 22 test/build | Rà thông báo động và nghiệm thu Android native; iOS/Flutter web chưa công bố hỗ trợ |
| BASE và Mốc 14 | Test guard, runbook và CI thủ công đã có | DB cũ/MySQL 8.4, CI push/PR + test admin, hiệu năng, usability, backup/restore và phát hành |

Các số kiểm thử là kết quả đã ghi ở báo cáo, không được chạy lại trong lần rà tài liệu này. Mốc có mã đã triển khai vẫn có thể chưa đủ điều kiện nghiệm thu tích hợp hoặc phát hành.

## 3. Thứ tự và các mốc bắt buộc

P0: có thể gây lỗi chạy, sai dữ liệu hoặc mất cập nhật. P1: chức năng cần có để đóng phạm vi phát hành. Bảng sau là thứ tự thực hiện chính; không được bỏ các bước test trong từng gói để dồn hết đến cuối.

| Thứ tự | Mốc | Phụ thuộc | Điều kiện chuyển mốc |
| --- | --- | --- | --- |
| 1 | BASE: chốt DB đích, baseline và CI | Không | DB test tái lập được; biết trạng thái DB thật, không repair/xóa tùy tiện |
| 2 | SYNC: hợp đồng và sửa lỗi sai dữ liệu | BASE | NULL, version, category và API alias được xử lý thống nhất ba tầng |
| 3 | CAT/AUD: catalog và nền audit | SYNC | CRUD đáng tin cậy; thay đổi admin có audit thật |
| 4 | USER/AUTH: hồ sơ, phiên, reset, riêng tư | CAT/AUD | Dữ liệu theo tài khoản, reset thật, không lẫn người dùng |
| 5 | FAV/DISC: khám phá và yêu thích | USER, CAT | Lọc đúng và yêu thích tồn tại sau đăng nhập lại |
| 6 | TRIP: wizard và ràng buộc chuyến | FAV, SYNC | Input chuẩn; required/excluded và trạng thái nháp/lưu có hợp đồng |
| 7 | MAP: dịch vụ tuyến đường | TRIP | Adapter test được; route/fallback khác biệt rõ |
| 8 | REC: engine theo quy tắc | TRIP, MAP, CAT | Kết quả đáp ứng ràng buộc hoặc trả thiếu có giải thích |
| 9 | EDIT: chỉnh sửa/tính lại | REC | Snapshot/tổng/route/version nhất quán sau lưu và mở lại |
| 10 | TRIPS/SHARE: quản lý, lịch sử, chia sẻ | EDIT | Xóa/sao chép/chia sẻ/thu hồi là thao tác thật có quyền |
| 11 | REV: đánh giá nội bộ | USER, CAT/AUD | CRUD/ẩn hiện review đúng, không làm đổi số liệu Google |
| 12 | ADM/WEATHER: vận hành thật | AUD, TRIPS, REV | Dashboard/audit/thời tiết không báo thành công giả |
| 13 | UX: Việt/Anh và độ bền giao diện | Các luồng trên | Mobile/admin đạt trạng thái lỗi/rỗng/offline và khả năng tiếp cận |
| 14 | QA/OPS/DOC: nghiệm thu và phát hành | Tất cả | Có bằng chứng E2E, hiệu năng, usability, migration và vận hành |

Việc triển khai adapter route bằng fixture, local email sink, test hoặc Việt/Anh có thể chuẩn bị khi gói trước chưa đóng, nhưng không gọi đó là nghiệm thu tích hợp thật. Không tự thêm dịch vụ trả phí/dependency.

## 4. Công việc thực hiện

### Mốc 1: BASE, P0

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| BASE-01 | Backend/DB: xác nhận URL, phiên bản MySQL, Flyway history và dữ liệu cần giữ. Tách đường khởi tạo DB mới và nâng cấp DB cũ | Chạy baseline hiện hành V1–V8 (V11/V12 đã gộp vào V1) trên DB trống và ddl-auto=validate; nếu có DB cũ thì có phương án backup/chuyển đổi/rollback đã thử trên bản sao. Không mặc định DB người dùng đã được nâng cấp |
| BASE-02 | Backend: rà seed tài khoản/quyền, osm_id giả, giá theo người, giờ hoạt động, bản dịch, nguồn rating và phạm vi địa lý | Danh sách seed cần xác minh; không nhận seed/ID tự đặt là dữ liệu thực. Nếu script đã áp dụng, sửa bằng migration mới, không sửa checksum lịch sử |
| BASE-03 | CI: bật kiểm tra push/PR sau khi baseline tái lập; chọn Node hỗ trợ test hiện có, MySQL 8.4 và khóa phiên bản công cụ | Backend test, Flutter analyze/test, admin build/test:security/test:destinations chạy trong CI. Không chỉ workflow_dispatch và không dùng DB phát triển |

### Mốc 2: SYNC, P0

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| SYNC-01 | Backend/mobile/admin: thống nhất DTO và fixture hợp đồng cho Google/app rating, JSON giờ, price NULL, costComplete, routeSource, status, snapshot | Test deserialize/serialize ba tầng; NULL không thành miễn phí/0 phút/4.5 sao; tài liệu nêu thời hạn giữ alias rating/reviewCount/openingHours |
| SYNC-02 | Mobile: cập nhật model, timeline, ngân sách, map và chi phí trước/sau lưu | budgetHealth UNKNOWN có cảnh báo thiếu giá; không báo ngân sách an toàn/còn lại chắc chắn; route UNKNOWN không coi là 0; phân bổ theo category code với nhãn Việt/Anh |
| SYNC-03 | Mobile/backend: gửi version khi sửa; bắt 409 và cung cấp tải lại mà không mất bản sửa cục bộ; loại fallback destinationId=1/0 | Hai phiên sửa tuần tự hoặc đồng thời không ghi đè im lặng; điểm đã xóa vẫn xem được từ snapshot và có cách thay/xóa hoạt động rõ ràng |
| SYNC-04 | Admin/backend: bỏ rating mặc định giả trong bảng/thẻ/chi tiết/thống kê/CSV; định nghĩa xóa giá trị Google và cập nhật một phần | Thiếu dữ liệu hiển thị/CSV đúng; bỏ trống có thể đặt NULL theo hợp đồng đã chọn, khác với không gửi field; PUT/PATCH không vô tình xóa bản dịch/lịch/ảnh |
| SYNC-05 | Backend: rà endpoint cũ và validation lồng nhau, null item/day, định dạng giờ, status, FK/unique/conflict | Dữ liệu sai trả ApiResponse 400/404/409 thích hợp, không 500 do schema; test rollback, duplicate sequence/day và serializer. Giữ các kiểm tra quyền hiện có |

Trạng thái SYNC-01–05: đã triển khai và kiểm thử ngày 16/11/2026. Xem [báo cáo SYNC](../reports/engineering/api-contracts.md) cho hợp đồng NULL/alias/version, fixture ba tầng, 30 test backend, 16 test mobile và 15 test admin. Giới hạn nghiệm thu native/MySQL 8.4 và các chức năng thuộc mốc khác vẫn giữ nguyên.

### Mốc 3: CAT/AUD, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| AUD-01 | Backend: triển khai service ghi audit dùng chung, actor lấy từ phiên server, lọc bí mật | Thay đổi catalog/tài khoản/kiểm duyệt và audit commit hoặc rollback cùng nhau; không log password/hash/token |
| CAT-01 | Backend/admin: hoàn thiện CRUD/ẩn hiện danh mục, địa điểm, ảnh, bản dịch, giá, giờ tuần và thời lượng | Reload giữ đúng dữ liệu; xử lý upload lỗi/giới hạn ảnh; chọn chính sách xóa mềm nhất quán và trả lỗi rõ khi còn FK; không phá snapshot/review cũ |
| CAT-02 | Backend: giữ categories.code ổn định, xử lý danh mục ẩn và HOTEL trên mọi đường ghi/public, không chỉ form | API trực tiếp không lách phạm vi; mã JSON cũ được xử lý có thông báo, không tự đổi sang category đầu; quyền admin đọc dữ liệu ẩn vẫn đúng |
| CAT-03 | Backend/admin: hoàn thiện quy trình cập nhật thống kê Google định kỳ độc lập với review app | Lỗi nguồn không ghi 0 thay dữ liệu cũ; không trộn điểm/số lượt; có test adapter và cấu hình thực phù hợp điều kiện sử dụng dữ liệu. Không tự bổ sung metadata đã bỏ |

Trạng thái ngày 16/11/2026: AUD-01, CAT-01 và CAT-02 đã triển khai; backend 39/39 test, admin 19/19 test/build và click-through với backend/database cô lập đạt. Xem [báo cáo CAT/AUD](../reports/features/catalog-and-discovery.md#quản-trị-catalog) cho policy code cố định, DELETE thành INACTIVE, audit cùng transaction và giới hạn. CAT-03 và AUD-02 vẫn mở.

### Mốc 4: USER/AUTH, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| USER-01 | Mobile/backend: model travelerProfile, GET/PUT hồ sơ, category preferences, language/default budget/pace/transport | Đăng xuất, đăng nhập/thiết bị khác nhận đúng; request theo mã category; cache tách user và xóa khi đổi phiên. Không tự gán pref_* không rõ chủ cũ sang tài khoản đang đăng nhập |
| AUTH-01 | Mobile/backend/admin: hồi quy đăng ký/login/role/khóa tài khoản/401/403, startup bootstrap và phiên cũ | Bảo toàn các test phân quyền đã đạt; lỗi mạng không đăng nhập giả; dữ liệu riêng/cache không lộ sau logout |
| AUTH-02 | Backend/mobile: reset mật khẩu qua password_reset_tokens và email adapter, thay SnackBar báo gửi giả | Token hash, hết hạn, dùng một lần nguyên tử; trả thông báo không lộ email tồn tại; reset thu hồi phiên cũ; test local mail và tích hợp kênh gửi thật trước nghiệm thu |
| AUTH-03 | Backend/mobile: xóa tài khoản/dữ liệu cá nhân theo NFR-03; bảo vệ tài khoản admin cuối cùng | Xác thực lại, xác nhận và transaction; dữ liệu theo chính sách FK, share không còn truy cập; audit không chứa thông tin nhạy cảm dư thừa |

USER-01, AUTH-01 và AUTH-03 đã triển khai. AUTH-02 đã qua kiểm thử tích hợp email local. Nghiệm thu hộp thư thật chờ cấu hình người gửi và địa chỉ thử nghiệm. Xem [báo cáo USER/AUTH](../reports/features/accounts.md).

### Mốc 5: FAV/DISC, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| DISC-01 | Backend/mobile: tìm/lọc tên, category sở thích và khoảng giá; phân trang khi cần | Kết quả chỉ điểm/danh mục ACTIVE trong phạm vi; quy tắc lọc giá NULL rõ; đổi filter/error/empty hoạt động đúng |
| DISC-02 | Mobile: chi tiết địa điểm, ảnh/bản dịch/giờ rút gọn/thời lượng/giá và hai nguồn đánh giá | Không giả rating/miễn phí; tên category lấy catalog; mở bản đồ đúng tọa độ; fallback tiếng Việt khi thiếu bản dịch |
| FAV-01 | Backend/mobile: API thêm/bỏ/list favorites theo chủ sở hữu, nối nút lưu và lựa chọn wizard | Unique(user,destination), thao tác lặp không tạo trùng; lưu/mở lại đúng tài khoản; điểm ẩn có chính sách hiển thị và không được thêm vào chuyến mới |

DISC-01, DISC-02 và FAV-01 đã triển khai. Quy tắc giá, phân trang, điểm ẩn và chọn điểm yêu thích được ghi trong [báo cáo FAV/DISC](../reports/features/catalog-and-discovery.md#khám-phá-và-yêu-thích).

### Mốc 6: TRIP, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| TRIP-01 | Mobile/backend: wizard dùng mặc định hồ sơ; gửi dates/1–10 khách/budget/pace/category/transport/origin | 1–7 ngày, ngày đảo/null/ngoài miền bị từ chối server; nơi ở nhập tự do chỉ là origin, không tái thêm HOTEL hoặc chi phí lưu trú |
| TRIP-02 | Backend/mobile: DTO/repository/service cho itinerary_constraints, required/excluded từ catalog/favorites | Mỗi loại tối đa 5, không trùng/xung đột, không nhận điểm ẩn/ngoài phạm vi; input và snapshot được lưu cùng chuyến |
| TRIP-03 | Backend/mobile: nối generation_key, DRAFT/SAVED và hành động lưu đúng luồng | Cùng key cùng input không tạo trùng, cùng key khác input trả 409; bản nháp có chủ sở hữu, không công khai; chỉ SAVED xuất hiện danh sách đã lưu theo quy tắc; policy dọn nháp không xóa chuyến đã lưu |

TRIP-01, TRIP-02 và TRIP-03 đã triển khai. Xem [hợp đồng wizard và bản nháp](../reports/features/itinerary-generation.md#đầu-vào-và-bản-nháp).

### Mốc 7: MAP, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| MAP-01 | Backend: adapter Directions/Matrix, timeout/cache/quota và chuyển đổi phương tiện | Fixture thành công/lỗi/quota; cấu hình provider/key ngoài Git; chọn provider theo điều kiện sử dụng và chi phí đã chấp thuận, không tự đăng ký dịch vụ |
| MAP-02 | Backend/mobile: chặng đến item từ origin/điểm trước, route_source/polyline/thời gian và fallback | PROVIDER/CACHE không làm mất ý nghĩa dữ liệu gốc; HAVERSINE ghi ước tính và không vẽ đường giao thông giả; UNKNOWN giữ NULL; không tạo lại route_provider/route_calculated_at |
| MAP-03 | Mobile: vẽ tuyến thật nếu có, marker theo thứ tự/ngày, mở điều hướng ngoài; đồng bộ map/timeline | Thiếu tọa độ, API lỗi hoặc offline vẫn xem được chuyến đã lưu; không nối thẳng như đường thật; giới hạn chưa tính chặng quay về origin được nêu rõ |

Đã nối adapter, tính chặng và bản đồ. Nghiệm thu provider thật cần endpoint đã duyệt. Xem [báo cáo MAP](../reports/features/routing-and-maps.md).

### Mốc 8: REC, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| REC-01 | Backend: chấm điểm theo nội dung và áp dụng dữ liệu điểm tiêu biểu do admin biên tập | Điểm và danh mục ACTIVE trong phạm vi. Sở thích theo chuyến ưu tiên hơn hồ sơ, điểm loại trừ bị bỏ, điểm bắt buộc được xét. Chuyến một ngày thử điểm tiêu biểu khả thi, xử lý bằng điểm ổn định và tránh lặp |
| REC-02 | Backend: chèn tham lam và tìm kiếm cục bộ theo ca mở cửa, địa lý, pace, thời gian đi và đệm | Khi chèn hoặc đổi điểm, kiểm tra toàn bộ ca và các chặng bị ảnh hưởng. Xử lý ca qua đêm. Nhịp độ 2–3, 3–4 hoặc 4–5 lượt tham quan; bữa ăn có khung riêng. Cảnh báo khi chưa biết giờ |
| REC-03 | Backend: ngân sách chung từ unit price × khách, phân bổ category, điều chỉnh điểm rẻ/gần hơn và kết quả một phần | Không tin tổng client; giá NULL/cận trên thiếu có policy rõ; không tự coi đã đủ chi phí. Không cộng lưu trú/di chuyển; không bỏ required/excluded im lặng |
| REC-04 | Backend/mobile: lý do đề xuất, nhãn tiêu biểu, cảnh báo và hướng dẫn điều chỉnh | Ít nhất 20 bộ input gồm khác sở thích trên cùng catalog, điểm tiêu biểu đầu bảng đóng cửa, 7 ngày, ngân sách thấp, dữ liệu ít, required xung đột và route lỗi. Kết quả một phần nêu điểm thiếu. Chuyến rỗng trả hướng dẫn |

Đã triển khai REC trên backend và mobile. Quản trị biên tập điểm tiêu biểu qua API. Xem [báo cáo REC](../reports/features/itinerary-generation.md#cơ-chế-gợi-ý-cá-nhân-hóa) và [PRD mục 7](../../tasks/prd-smarttravel.md#7-gợi-ý-lộ-trình-cá-nhân-hóa).

### Mốc 9: EDIT, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| EDIT-01 | Mobile/backend: thêm/xóa/đổi thứ tự/thay thế hoạt động và sửa ghi chú/giờ/thời lượng | Kiểm tra ownership của item/day; không gửi ID dự phòng; giữ snapshot khi chỉ sửa ghi chú, lấy snapshot mới khi thay điểm; rollback không mất bản cũ |
| EDIT-02 | Backend: dùng chung calculator/route/kiểm tra giờ cho tạo và sửa, hỗ trợ tính lại ngày/toàn chuyến | Sửa một ngày vẫn cộng đủ mọi ngày; tổng nhóm=ngày=chuyến; route bị ảnh hưởng được tính lại; cảnh báo chồng giờ/thiếu dữ liệu rõ |
| EDIT-03 | Mobile: bỏ dự toán giá min/90 phút cứng; hiển thị đang tính/số liệu cũ và xử lý 409 | Preview và kết quả server cùng đơn giá/thời lượng/chính sách; không báo lưu thành công khi request lỗi; mở lại thấy đúng timeline/map/ngân sách |

Đã triển khai trên backend và mobile. Xem [báo cáo EDIT](../reports/features/itinerary-management.md#chỉnh-sửa-và-tính-lại).

### Mốc 10: TRIPS/SHARE, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| TRIPS-01 | Backend/mobile: lưu nháp, đổi tên, sao chép, xóa chuyến thật | Chỉ chủ sở hữu/admin theo hợp đồng; bản sao ngày/item/constraints độc lập, không sao chép token; xóa không chỉ removeWhere trên UI |
| TRIPS-02 | Backend/mobile: danh sách, phân loại lịch sử, tìm/lọc/phân trang chuyến | Dựa endDate và ngày tại Đà Nẵng, không dùng index; refresh/thiết bị khác phản ánh đúng DB; không lẫn cache tài khoản |
| SHARE-01 | Backend/mobile: route chia sẻ chỉ đọc, deep link và DTO công khai | Link mở khi chưa login, không nhầm token thành itinerary ID; không lộ user/token/settings riêng; token sai/hết hạn có màn lỗi phù hợp |
| SHARE-02 | Backend/mobile: thu hồi, tạo lại và hết hạn share token | Token cũ mất hiệu lực sau thu hồi; tạo lại token mới; đã hết hạn không trả link cũ như đang dùng; xóa tài khoản/chuyến chặn link |

Đã triển khai trên backend và mobile. Xem [API và triển khai link chia sẻ](../reports/features/itinerary-management.md#lưu-trữ-sao-chép-và-chia-sẻ).

### Mốc 11: REV, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| REV-01 | Backend/mobile: list/create/update/delete destination_reviews | Một review/user/điểm, 1–5 sao, giới hạn comment; chủ bài mới được sửa/xóa; sửa không tăng count; giữ nguyên số liệu Google |
| REV-02 | Backend/admin/mobile: ẩn/hiện review và cơ chế báo cáo tối thiểu có nơi tiếp nhận | HIDDEN không vào AVG/COUNT; tác giả sửa không tự hiện lại; admin có audit. Không thêm bảng báo cáo mới khi chưa cần; không có nút báo cáo chỉ hiện SnackBar |
| REV-03 | Backend/mobile/admin: tổng hợp PUBLISHED và hiển thị Google/app riêng | Không review -> appRating NULL/count 0; chỉ làm tròn lúc hiển thị; tránh N+1; không gắn nhãn đã ghé thăm nếu chưa có bằng chứng |

Đã triển khai trên backend, admin và mobile. Xem [báo cáo REV](../reports/features/reviews-and-moderation.md).

### Mốc 12: ADM/WEATHER, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| AUD-02 | Backend/admin: API list/filter/page/export audit, thay danh sách hardcode | Filter actor/action/entity/date đúng; dữ liệu actor tồn tại hợp lý sau xóa user; kiểm tra admin, không rò bí mật |
| ADM-01 | Backend/admin: dashboard lấy số liệu thật, định nghĩa chỉ số/khoảng thời gian | Không INITIAL_ALERTS hoặc setTimeout giả đồng bộ; không có dữ liệu thì hiện trạng thái rỗng, lỗi API không báo thành công |
| ADM-02 | Backend/admin: hồi quy quản lý user/role/lock và quản trị lịch trình | Chặn tự khóa/xóa/hạ quyền và admin cuối cùng; phiên bị khóa không dùng lại; lọc/phân trang và audit đúng |
| WEATHER-01 | Backend/mobile: kiểm tra request timezone/locale, cache/stale/fallback và độ mới thời tiết | Response kiểm soát được; lỗi nguồn không giả thời tiết quan trắc trực tiếp; test mạng thật riêng không làm unit test phụ thuộc Internet |
| ADM-03 | Mobile/admin: rà mọi nút và thông báo còn mô phỏng | Góp ý có nơi nhận hoặc bỏ khỏi bản phát hành; OAuth ẩn khi chưa triển khai; reset và xóa chuyến không báo thành công giả |

Đã triển khai trên backend, admin và mobile. Xem [báo cáo ADM/WEATHER](../reports/features/weather.md).

### Mốc 13: UX, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| UX-01 | Mobile/admin: Việt/Anh cho luồng phát hành, nhãn category, fallback bản dịch | Lựa chọn ngôn ngữ lưu theo hồ sơ; code kỹ thuật không lộ thay nhãn; chữ dài không phá bố cục |
| UX-02 | Mobile/admin: loading/empty/error/timeout/offline, lưu nháp thao tác và xác nhận xóa | Không mất dữ liệu đã lưu/bản sửa khi lỗi; retry không tạo trùng; thông báo có hành động và phản ánh kết quả server |
| UX-03 | Mobile/admin: chữ lớn, focus, keyboard, contrast, tap target, màn hình nhỏ | Kiểm tra trực tiếp Android ưu tiên + admin browser; không lấy Flutter widget test thay native UI. iOS/web chỉ công bố hỗ trợ khi đã có bằng chứng |

Trạng thái Mốc 13: đã triển khai phần mã UX và kiểm tra tự động/browser trong phạm vi ghi ở [báo cáo UX](../reports/experience/localization-and-accessibility.md); chưa đóng nghiệm thu Android native và E2E toàn bộ luồng phát hành.

### Mốc 14: QA/OPS/DOC, P1

| Mã | Công việc / tier | Tiêu chí nghiệm thu |
| --- | --- | --- |
| QA-01 | Cả ba tầng: ma trận regression theo API/FR và lỗi review | Test quyền/NULL/snapshot/version/transaction/FK/unique; schema fresh + upgrade nếu phát hành nâng cấp. Các check bắt buộc qua trên môi trường ghi rõ |
| QA-02 | Cả ba tầng: E2E tài khoản A/B, mobile và admin với dữ liệu riêng | Đăng ký -> profile -> lọc/favorite -> wizard -> tạo -> sửa -> lưu -> mở lại -> share/thu hồi -> copy/xóa -> review/ẩn -> audit; đổi tài khoản không rò dữ liệu |
| QA-03 | Backend: đo tải trên seed/môi trường cố định, log request ID và thời gian engine/provider | Đo p95 API thường <2s, tạo lịch <10s; ít nhất 90% truy vấn hợp lệ có kết quả/fallback hướng dẫn. Báo số đo và giới hạn, không nhận đạt khi chưa đo |
| QA-04 | Mobile: usability với ít nhất 5 người | Ít nhất 90% tạo/lưu chuyến 2–3 ngày trong 3 phút theo mục tiêu PRD; ghi kết quả thực và sửa lỗi phát hiện, không dùng nội dung mẫu làm bằng chứng |
| OPS-01 | Backend/admin/mobile: cấu hình môi trường, HTTPS, secrets/upload storage/mail/share domain/provider quota | Không khóa/password thật trong Git; URL đúng nền tảng; dữ liệu/upload tồn tại sau restart, log không lộ thông tin riêng |
| OPS-02 | DB: backup/restore, retention nháp/token/log, tài liệu xử lý migration lỗi | Thử restore trên database riêng; thao tác dữ liệu thật chỉ theo kế hoạch có đường lui. Không dùng repair để thay đổi schema |
| DOC-01 | Docs: đồng bộ README, kiến trúc, runbook, ERD, trạng thái yêu cầu và giới hạn | Mỗi mục hoàn thành có file/test/log/UI evidence; tài liệu phân biệt schema đích, mã nguồn và DB đang triển khai |

## 5. Điều kiện đóng từng gói và đóng dự án

Một gói chỉ đóng khi có hợp đồng rõ, xử lý thật, dữ liệu lưu đúng, quyền đúng, test liên quan đạt và kiểm tra UI khi có tương tác. Ghi lại mã việc, file đổi, kết quả chạy và giới hạn. Không đánh dấu xong chỉ vì đã có bảng/entity hoặc build qua.

Lệnh chuẩn: backend `mvn test`; mobile `flutter analyze` và `flutter test`; admin `npm run build`, `npm run test:security`, `npm run test:destinations`. Kiểm thử DB phải dùng cấu hình guarded riêng, không dùng database phát triển. Bổ sung test chuyên biệt theo gói, không chạy lại rộng khi chưa có thay đổi/lỗi mới.

Đóng phạm vi phát hành khi không còn P0/P1 trong phạm vi đã thống nhất, các luồng E2E đạt, ba tầng thống nhất dữ liệu, có bằng chứng hiệu năng/usability/khôi phục và danh sách giới hạn công khai. Không yêu cầu phục hồi các chức năng đã được người dùng loại khỏi phạm vi để gọi là hoàn thành.

## 6. Phụ thuộc bên ngoài và quyết định còn mở

- Chưa chốt database đích nào cần giữ dữ liệu cũ: BASE-01 phải kiểm tra trước thao tác thật.
- Route provider/key/quota và quyền sử dụng tile/polyline cần xác định trước nghiệm thu MAP. Có thể viết adapter/test trước; không tự lấy dữ liệu Google vẽ trên nền khác trái điều kiện nhà cung cấp.
- Email sender và tên miền/deep link cần cấu hình thật trước nghiệm thu tương ứng; báo cáo review đã có nơi nhận trong dashboard, góp ý tổng quát chưa thuộc bản phát hành; chưa có không được báo thành công giả.
- Phát hành mặc định kiểm tra Android + admin web trước; iOS/web cần thiết bị và tiêu chí riêng nếu đưa vào phạm vi công bố.
- Chưa có deadline/nhân lực xác nhận, nên chưa gắn ngày công hoặc ngày giao giả định. Kế hoạch giữ thứ tự phụ thuộc; chọn từng mã việc để triển khai và hiệu chỉnh sau bằng chứng thực tế.
