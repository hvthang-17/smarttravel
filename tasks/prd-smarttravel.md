# PRD: SmartTravel — Ứng dụng gợi ý lộ trình du lịch Đà Nẵng

> **Tóm tắt:** SmartTravel là ứng dụng di động giúp khách du lịch tạo lịch trình Đà Nẵng theo ngày — tự động sắp xếp điểm đến, ước tính chi phí và thời gian di chuyển dựa trên sở thích, ngân sách và số ngày của người dùng. Ứng dụng nhắm đến khách Việt Nam và quốc tế đi tự túc, cung cấp giao diện tiếng Việt/Anh kèm bản đồ tuyến đường, đồng thời trang bị khu vực quản trị để duy trì dữ liệu địa điểm.

## 1. Tổng quan sản phẩm

### Tên sản phẩm

SmartTravel.

### Vấn đề

Khách du lịch Việt Nam và quốc tế đến Đà Nẵng thường phải tìm kiếm, đối chiếu và tự sắp xếp rất nhiều thông tin về điểm tham quan, ăn uống, lưu trú, thời gian di chuyển và chi phí. Việc này mất thời gian, lịch trình dễ thiếu thực tế (đi lại vòng xa, quá nhiều điểm trong ngày, vượt ngân sách), đặc biệt với người lần đầu đến thành phố.

### Tầm nhìn

Trở thành trợ lý lập kế hoạch chuyến đi Đà Nẵng trên thiết bị di động: biến sở thích, ngân sách và thời lượng chuyến đi thành lịch trình ngày-qua-ngày có thể xem trên bản đồ, chỉnh sửa và lưu lại.

### Mục tiêu

- Cho phép người dùng tạo lịch trình Đà Nẵng phù hợp trong dưới 3 phút sau khi nhập thông tin chuyến đi.
- Đề xuất thứ tự điểm đến hợp lý theo vị trí, giờ mở cửa (nếu có), thời lượng tham quan và ngân sách.
- Hiển thị minh bạch tổng chi phí ước tính, khoảng cách và thời gian di chuyển theo ngày.
- Cho phép người dùng chỉnh sửa và lưu nhiều lịch trình vào tài khoản.
- Cung cấp công cụ cho quản trị viên duy trì danh mục địa điểm hiển thị trong ứng dụng.

### Mục tiêu và kết quả then chốt (OKR)

**Objective:** Giúp khách du lịch lập kế hoạch chuyến đi Đà Nẵng nhanh, hợp lý và minh bạch chi phí thông qua ứng dụng di động.

| # | Key Result | Cách đo |
| --- | --- | --- |
| KR-1 | ≥ 90% người dùng thử nghiệm hoàn thành tạo và lưu lịch trình 2–3 ngày trong ≤ 3 phút | Kiểm thử usability với ≥ 5 người dùng mẫu |
| KR-2 | 100% lịch trình sinh ra đúng số ngày, không chứa điểm bị loại trừ và không vượt số hoạt động/ngày | Bộ test tự động ≥ 20 bộ input hợp lệ |
| KR-3 | ≥ 90% truy vấn gợi ý hợp lệ (với ≥ 30 địa điểm seed) trả kết quả hoặc fallback có hướng dẫn rõ ràng | Bộ test tự động + kiểm thử thủ công |
| KR-4 | 95% API thường dưới 2 s và 95% lần sinh lịch trình dưới 10 s | Kiểm thử tải quy mô đồ án |

### Người dùng mục tiêu

- Khách Việt Nam du lịch tự túc tại Đà Nẵng.
- Khách quốc tế đến Đà Nẵng cần nội dung/giao diện tiếng Việt và tiếng Anh.
- Quản trị viên dự án quản lý dữ liệu điểm tham quan, nhà hàng, khách sạn và người dùng.

## 2. Background

### Bối cảnh

Đà Nẵng liên tục nằm trong top 5 điểm đến du lịch Việt Nam. Lượng khách nội địa và quốc tế tăng trở lại mạnh sau đại dịch, nhưng hầu hết du khách tự túc vẫn phải lập lịch trình thủ công — tổng hợp thông tin rời rạc từ blog, Google Maps và mạng xã hội, dễ dẫn đến lịch trình thiếu thực tế hoặc tốn nhiều giờ nghiên cứu.

### Tại sao lúc này?

- **Nhu cầu thực tế:** Chưa có ứng dụng nào tập trung hoàn toàn vào việc gợi ý lịch trình *theo ngày* cho riêng Đà Nẵng — kết hợp sở thích, ngân sách, khoảng cách và giờ mở cửa.
- **Sự sẵn sàng công nghệ:** Các API bản đồ (Google Maps Platform) đủ chín muồi và Flutter cho phép xây dựng ứng dụng đa nền tảng với một codebase.
- **Yêu cầu đồ án:** Dự án phục vụ đồ án tốt nghiệp — cần sản phẩm có tính ứng dụng thực tế, phạm vi kiểm soát được và có thể demo đầy đủ luồng end-to-end.

## 3. Contacts

| Vai trò | Trách nhiệm |
| --- | --- |
| Product Owner / PM | Định nghĩa yêu cầu, ưu tiên backlog, kiểm tra chất lượng PRD và luồng nghiệp vụ |
| Mobile Developer | Phát triển ứng dụng Flutter, giao diện người dùng và tích hợp API |
| Backend Developer | Xây dựng REST API (Spring Boot), database, recommendation engine và tích hợp Google Maps |
| Admin Frontend Developer | Phát triển giao diện quản trị React + TypeScript |
| QA / Tester | Kiểm thử chức năng, usability, phân quyền và hiệu năng |
| Giảng viên hướng dẫn | Phản hồi và nghiệm thu đồ án |


## 4. User personas

### P1 — Minh, khách nội địa đi cuối tuần

- 24 tuổi, dùng điện thoại Android, đi Đà Nẵng 2 ngày cùng bạn.
- Có ngân sách cố định, quan tâm biển, ẩm thực địa phương và ảnh đẹp.
- Cần lịch trình nhanh, chi phí rõ ràng và ít thao tác.

### P2 — Emma, khách quốc tế lần đầu đến Đà Nẵng

- 31 tuổi, dùng iPhone, du lịch 4 ngày cùng bạn đời.
- Cần giao diện tiếng Anh, thông tin vị trí rõ ràng và đường đi trên bản đồ.
- Muốn cân bằng văn hóa, ẩm thực, điểm ngắm cảnh và thời gian nghỉ.

### P3 — Lan, quản trị viên nội dung

- Thành viên nhóm dự án phụ trách dữ liệu.
- Cần thêm/sửa/ẩn địa điểm, kiểm tra thông tin trước khi đưa vào gợi ý.
- Cần quản lý tài khoản ở mức cơ bản và xử lý nội dung đánh giá không phù hợp nếu tính năng này được bật.

## 5. Value proposition

### Công việc / nhu cầu của khách hàng

Khách du lịch tự túc cần **một lịch trình hoàn chỉnh theo ngày** — biết đi đâu, ăn ở đâu, di chuyển bao lâu và tốn bao nhiêu — thay vì tự ghép nối hàng chục nguồn thông tin rời rạc.

### Giá trị mang lại

- **Tiết kiệm thời gian:** Từ hàng giờ nghiên cứu & sắp xếp → dưới 3 phút có lịch trình phù hợp.
- **Thực tế hơn:** Sắp xếp điểm theo cụm địa lý, giờ mở cửa và thời gian di chuyển — tránh lịch trình "vẽ" không khả thi.
- **Minh bạch chi phí:** Hiển thị ước tính tham quan, ăn uống, đi lại theo từng ngày — biết trước có vượt ngân sách không.
- **Linh hoạt:** Chỉnh sửa, thay thế điểm đến tùy ý rồi hệ thống tự tính lại.

### So với giải pháp hiện tại

| Giải pháp hiện tại | Hạn chế | SmartTravel giải quyết |
| --- | --- | --- |
| Blog / bài review | Thông tin chung, không cá nhân hóa, không tính khoảng cách / chi phí | Cá nhân hóa theo sở thích, ngân sách, số người; tự động tính route |
| Google Maps | Tìm được địa điểm nhưng không tạo lịch trình theo ngày | Lịch trình ngày-qua-ngày, thứ tự tối ưu, tổng hợp chi phí |
| TripAdvisor / Klook | Thiên về đặt tour/khách sạn, không gợi ý lộ trình tự túc | Tập trung vào lập kế hoạch tự túc, không ràng buộc đặt dịch vụ |
| Tự lập bảng Excel | Tốn thời gian, thiếu dữ liệu khoảng cách/giờ mở cửa | Tự động, trực quan, cập nhật khi chỉnh sửa |

## 6. Core features

| Nhóm | Tính năng MVP | Hành vi chính |
| --- | --- | --- |
| Tài khoản | Đăng ký, đăng nhập, đăng xuất | Email/mật khẩu; phiên đăng nhập an toàn. |
| Hồ sơ | Hồ sơ và sở thích du lịch | Ngôn ngữ, sở thích, ngân sách mặc định, nhịp độ tham quan và phương thức di chuyển ưu tiên. |
| Khám phá | Tìm kiếm và chi tiết điểm đến | Tìm theo tên, loại, sở thích; xem ảnh, mô tả, tọa độ, giờ mở cửa, giá tham khảo và liên kết bản đồ. |
| Lập kế hoạch | Tạo gợi ý lịch trình | Nhập ngày, ngân sách, số người, sở thích, nơi ở/điểm xuất phát và ràng buộc; hệ thống tạo lịch trình theo ngày. |
| Chỉnh sửa | Tùy biến lịch trình | Thêm, xóa, đổi thứ tự, thay thế điểm; tính toán lại thông tin ngày và tổng chuyến đi. |
| Bản đồ | Tuyến đường, thời gian, khoảng cách | Xem các điểm theo ngày và tuyến giữa các điểm từ API bản đồ. |
| Tài chính | Ước tính ngân sách | Phân tách tham quan, ăn uống, lưu trú (nếu người dùng chọn), đi lại; hiển thị tổng và cảnh báo vượt mức. |
| Lưu trữ | Yêu thích, lịch trình đã lưu, lịch sử | Lưu điểm yêu thích; tạo/sửa/xóa/sao chép lịch trình; lịch sử các chuyến đã kết thúc. |
| Quản trị | Quản lý dữ liệu | CRUD và ẩn/hiện địa điểm; quản lý danh mục, ảnh, giá, giờ mở cửa và trạng thái người dùng. |

### Reviews/ratings

Không thuộc MVP. Có thể đưa vào giai đoạn sau khi có cơ chế kiểm duyệt; trong MVP dùng dữ liệu biên tập bởi quản trị viên và/hoặc rating công khai từ nhà cung cấp Places theo điều khoản API, không sao chép review đầy đủ.

## 7. Hệ thống gợi ý AI/dựa trên quy tắc

Trong phạm vi đồ án, “AI recommendation” là bộ máy ra quyết định có thể giải thích được, dựa trên lọc ràng buộc và chấm điểm; không phụ thuộc LLM để tạo dữ liệu địa điểm.

### Đầu vào người dùng

- Ngày bắt đầu và số ngày du lịch (MVP: 1–7 ngày).
- Số khách (MVP: 1–10 người).
- Ngân sách tổng bằng VND; người dùng chọn bao gồm/không bao gồm lưu trú.
- Sở thích: biển, văn hóa/lịch sử, ẩm thực, thiên nhiên, giải trí, mua sắm, check-in.
- Cường độ: thư thả, cân bằng, dày đặc.
- Phương tiện ưu tiên: đi bộ, xe máy/ô tô/taxi, hoặc không xác định.
- Điểm xuất phát mỗi ngày/nơi lưu trú (tùy chọn); ràng buộc bắt buộc như điểm muốn đi hoặc điểm cần tránh (tối đa 5 mỗi loại).

### Logic đề xuất

1. Lọc các địa điểm đang hoạt động ở Đà Nẵng, phù hợp loại hình, sở thích, ngày/giờ mở cửa và ràng buộc loại trừ.
2. Gán điểm cho từng ứng viên từ độ khớp sở thích, độ phổ biến/điểm chất lượng, mức chi phí, khoảng cách đến điểm trước đó và thời lượng phù hợp cường độ.
3. Phân bổ số hoạt động trong ngày: thư thả 2–3, cân bằng 3–4, dày đặc 4–5; không tính bữa ăn là hoạt động nếu chưa có dữ liệu phù hợp.
4. Sắp xếp theo cụm địa lý và dùng Distance Matrix/Directions API để giảm tổng thời gian di chuyển; tôn trọng thời gian đệm mặc định 30 phút giữa các hoạt động.
5. Kiểm tra tổng chi phí và thời gian mỗi ngày. Nếu vi phạm, thay bằng phương án có điểm tương đương nhưng rẻ/gần hơn hoặc loại hoạt động có điểm thấp nhất.
6. Trả về lịch trình ngày-qua-ngày cùng lý do ngắn cho từng đề xuất (ví dụ: “phù hợp sở thích biển, cách điểm trước 2,1 km”).

### Ràng buộc và fallback

- Không tạo tuyến qua ngoài phạm vi thành phố Đà Nẵng trong MVP.
- Không khẳng định giá, giờ mở cửa, thời gian di chuyển là chính xác tuyệt đối; hiển thị “ước tính” và thời điểm cập nhật.
- Nếu ngân sách quá thấp hoặc bộ lọc không đủ địa điểm, trả lịch trình một phần kèm thông báo ràng buộc gây thiếu kết quả và các lựa chọn: tăng ngân sách, bỏ điểm bắt buộc, giảm số ngày hoặc đổi sở thích.
- Nếu API bản đồ lỗi/hết hạn mức, dùng khoảng cách đường chim bay — Haversine (công thức tính khoảng cách giữa 2 vị trí địa lý dựa vào tọa độ GPS) — để sắp xếp sơ bộ, gắn nhãn “ước tính”; không hiển thị polyline tuyến đường.
- Nếu không có giờ mở cửa, cho phép đề xuất nhưng gắn cờ yêu cầu người dùng kiểm tra trước chuyến đi.

## 8. Functional requirements

- FR-01: Hệ thống phải cho phép đăng ký bằng email duy nhất, mật khẩu tối thiểu 8 ký tự và đăng nhập/đăng xuất.
- FR-02: Hệ thống phải cho phép người dùng đã đăng nhập xem và cập nhật tên hiển thị, ngôn ngữ, sở thích, ngân sách và cường độ mặc định.
- FR-03: Hệ thống phải cung cấp tìm kiếm điểm đến theo tên và lọc theo loại, sở thích, khoảng giá.
- FR-04: Mỗi trang chi tiết phải hiển thị tối thiểu tên, loại, mô tả, tọa độ, ảnh (nếu có), giá tham khảo, giờ mở cửa (nếu có) và nguồn/thời điểm cập nhật.
- FR-05: Người dùng đã đăng nhập phải có thể thêm/xóa một địa điểm khỏi danh sách yêu thích.
- FR-06: Biểu mẫu tạo lịch trình phải xác thực ngày, 1–7 ngày, 1–10 khách và ngân sách lớn hơn 0 trước khi gửi.
- FR-07: Bộ máy gợi ý phải tạo lịch trình theo ngày từ đầu vào tại mục 4 và chỉ sử dụng điểm đến được phép hiển thị.
- FR-08: Mỗi ngày trong lịch trình phải có thứ tự hoạt động, thời lượng đề xuất, khoảng cách/thời gian di chuyển ước tính đến điểm kế tiếp và chi phí ước tính.
- FR-09: Người dùng phải có thể thêm, xóa, di chuyển, thay thế hoạt động và yêu cầu tính lại một ngày hoặc toàn lịch trình.
- FR-10: Khi lịch trình thay đổi, hệ thống phải tính lại tổng chi phí, tổng quãng đường và tổng thời gian; cảnh báo nếu ngân sách bị vượt.
- FR-11: Người dùng phải có thể lưu, đổi tên, xem danh sách, sao chép và xóa lịch trình của chính mình.
- FR-12: Lịch trình có ngày kết thúc trước ngày hiện tại phải xuất hiện trong lịch sử chuyến đi; người dùng vẫn có thể xem và sao chép chúng.
- FR-13: Bản đồ phải hiển thị marker theo thứ tự và tuyến đường của một ngày khi dữ liệu Directions API khả dụng.
- FR-14: Chỉ quản trị viên mới được tạo, sửa, ẩn/hiện hoặc xóa mềm địa điểm và danh mục.
- FR-15: Quản trị viên phải có thể tìm kiếm, xem và khóa/mở khóa tài khoản; tài khoản bị khóa không thể đăng nhập.
- FR-16: Mọi thao tác thay đổi dữ liệu quản trị phải lưu người thực hiện, thời điểm và loại thao tác trong nhật ký audit.

## 9. Non-functional requirements

- NFR-01 Performance: 95% yêu cầu API thông thường phản hồi dưới 2 giây; quá trình tạo lịch trình phản hồi dưới 10 giây trong điều kiện API bên thứ ba bình thường.
- NFR-02 Security: Mật khẩu phải băm bằng Argon2 (thuật toán băm mật khẩu an toàn, chuyển mật khẩu thành chuỗi không thể đảo ngược) hoặc bcrypt; dùng HTTPS; token/phiên có thời hạn; phân quyền server-side; không đưa API key bản đồ vào mã nguồn hay mobile app nếu nhà cung cấp hỗ trợ proxy/restriction.
- NFR-03 Privacy: Chỉ thu thập dữ liệu hồ sơ cần thiết; cho phép xóa tài khoản và dữ liệu cá nhân; không chia sẻ lịch trình riêng tư mặc định.
- NFR-04 Scalability: API không trạng thái và dữ liệu địa điểm/map cache có TTL (thời gian sống — khoảng thời gian dữ liệu cache được phép tồn tại trước khi phải làm mới) để có thể mở rộng ngang; việc gọi API Places phải có hạn mức và cache.
- NFR-05 Availability: Mục tiêu 99% trong thời gian demo/vận hành; thao tác lưu lịch trình không bị phụ thuộc vào API map khi đã có dữ liệu cục bộ.
- NFR-06 Usability: Giao diện mobile hỗ trợ tiếng Việt/Anh, các bước tạo lịch trình có nhãn rõ ràng, trạng thái tải/lỗi/rỗng, cỡ chạm tối thiểu 44px.
- NFR-07 Accessibility: Độ tương phản văn bản đạt tối thiểu WCAG AA (tiêu chuẩn quốc tế về khả năng tiếp cận web, mức AA yêu cầu tỷ lệ tương phản tối thiểu 4.5:1) ở các màn hình chính; ảnh có mô tả thay thế khi framework hỗ trợ.
- NFR-08 Observability: Ghi log lỗi có mã yêu cầu, dashboard tối thiểu về lỗi API bên thứ ba và thời gian sinh lịch trình; không ghi mật khẩu/token vào log.

## 10. User stories

### US-001: Thiết lập xác thực và vai trò
**Description:** Là khách du lịch, tôi muốn đăng ký và đăng nhập bằng email để lưu dữ liệu riêng của mình và truy cập lại lịch trình trên bất kỳ thiết bị nào.

**Acceptance Criteria:**
- [ ] Đăng ký từ chối email đã tồn tại và mật khẩu dưới 8 ký tự.
- [ ] Đăng nhập sai trả lỗi chung, không tiết lộ tài khoản có tồn tại hay không.
- [ ] API trả vai trò `user` hoặc `admin`; các route quản trị từ chối `user`.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Must-have. **Dependencies:** US-002.

### US-002: Cập nhật hồ sơ và sở thích
**Description:** Là người dùng, tôi muốn lưu sở thích và thiết lập du lịch để hệ thống đưa ra gợi ý lịch trình phù hợp hơn mà không cần nhập lại mỗi lần.

**Acceptance Criteria:**
- [ ] Có thể lưu ngôn ngữ, ít nhất một sở thích, ngân sách mặc định, cường độ và phương tiện.
- [ ] Giá trị hợp lệ vẫn tồn tại sau đăng xuất/đăng nhập.
- [ ] Form báo lỗi rõ ràng cho dữ liệu không hợp lệ.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Must-have. **Dependencies:** US-001.

### US-003: Quản lý danh mục địa điểm
**Description:** Là quản trị viên, tôi muốn quản lý địa điểm Đà Nẵng để dữ liệu đề xuất cho người dùng luôn đáng tin cậy và cập nhật.

**Acceptance Criteria:**
- [ ] Admin tạo/sửa/ẩn một địa điểm với tên, loại, tọa độ và giá tham khảo.
- [ ] Địa điểm bị ẩn không xuất hiện trong tìm kiếm hay bộ gợi ý.
- [ ] Mỗi thay đổi sinh audit log chứa admin và thời gian.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Must-have. **Dependencies:** US-001.

### US-004: Tìm kiếm và xem chi tiết điểm đến
**Description:** Là khách du lịch, tôi muốn tìm và xem thông tin điểm đến để quyết định có nên thêm vào chuyến đi hay không.

**Acceptance Criteria:**
- [ ] Tìm theo tên và lọc theo loại/sở thích trả về địa điểm đang hiển thị.
- [ ] Chi tiết có dữ liệu bắt buộc theo FR-04 hoặc hiện “chưa cập nhật”.
- [ ] Người dùng có thể mở vị trí trên bản đồ từ chi tiết.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Must-have. **Dependencies:** US-003.

### US-005: Lưu địa điểm yêu thích
**Description:** Là người dùng, tôi muốn lưu địa điểm yêu thích để dễ dàng tìm lại và sử dụng khi tạo lịch trình sau này.

**Acceptance Criteria:**
- [ ] Nút yêu thích thêm/xóa không tạo bản ghi trùng.
- [ ] Danh sách yêu thích chỉ hiển thị dữ liệu của người dùng hiện tại.
- [ ] Có thể thêm điểm yêu thích vào biểu mẫu lịch trình.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Should-have. **Dependencies:** US-001, US-004.

### US-006: Nhập yêu cầu chuyến đi
**Description:** Là khách du lịch, tôi muốn nhập thông tin chuyến đi để hệ thống tạo gợi ý lịch trình phù hợp với nhu cầu cá nhân.

**Acceptance Criteria:**
- [ ] Form nhận mọi trường đầu vào bắt buộc tại mục 4 và kiểm tra giới hạn FR-06.
- [ ] Có thể chọn điểm bắt buộc/cần tránh từ danh mục.
- [ ] Sau khi gửi, người dùng thấy trạng thái đang tạo và lỗi có thể hành động nếu thất bại.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Must-have. **Dependencies:** US-002, US-004.

### US-007: Sinh lịch trình theo quy tắc
**Description:** Là khách du lịch, tôi muốn nhận lịch trình theo ngày để không phải tự sắp xếp từ đầu và tiết kiệm thời gian lên kế hoạch.

**Acceptance Criteria:**
- [ ] Kết quả không chứa điểm bị loại trừ và chứa điểm bắt buộc nếu dữ liệu cho phép.
- [ ] Mỗi hoạt động có lý do đề xuất, thời lượng và chi phí ước tính.
- [ ] Kết quả tuân theo số ngày và giới hạn hoạt động theo cường độ.
- [ ] Trường hợp không đủ dữ liệu trả fallback theo mục 4, không trả lịch trình sai im lặng.
- [ ] Typecheck/lint passes.

**Priority:** Must-have. **Dependencies:** US-003, US-006.

### US-008: Hiển thị bản đồ và số liệu tuyến đường
**Description:** Là khách du lịch, tôi muốn xem lộ trình từng ngày trên bản đồ để đánh giá tính thực tế của lịch trình và hình dung quãng đường di chuyển.

**Acceptance Criteria:**
- [ ] Hiển thị marker được đánh số theo thứ tự hoạt động trong ngày.
- [ ] Hiển thị tổng khoảng cách và thời gian từ Directions/Distance Matrix API.
- [ ] Khi API lỗi, giao diện gắn nhãn số liệu ước tính và không bị vỡ.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Must-have. **Dependencies:** US-007, cấu hình API bản đồ.

### US-009: Chỉnh sửa và tính lại lịch trình
**Description:** Là khách du lịch, tôi muốn chỉnh lịch trình do hệ thống gợi ý để phù hợp nhu cầu thực tế mà vẫn giữ được thông tin chi phí và thời gian chính xác.

**Acceptance Criteria:**
- [ ] Có thể thêm/xóa/đổi thứ tự/thay thế hoạt động trong một ngày.
- [ ] Sau thay đổi, tổng chi phí/thời gian/khoảng cách cập nhật hoặc báo trạng thái đang tính.
- [ ] Cảnh báo rõ ràng khi tổng chi phí vượt ngân sách đã nhập.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Must-have. **Dependencies:** US-007, US-008.

### US-010: Lưu và quản lý lịch trình
**Description:** Là khách du lịch, tôi muốn lưu và quản lý lịch trình để dùng lại, so sánh các phương án hoặc xem trong chuyến đi.

**Acceptance Criteria:**
- [ ] Lưu mới, đổi tên, xem danh sách, sao chép và xóa lịch trình của mình.
- [ ] Người dùng không thể đọc/sửa lịch trình của tài khoản khác.
- [ ] Lịch trình đã qua ngày kết thúc xuất hiện trong lịch sử.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Must-have. **Dependencies:** US-001, US-007.

### US-011: Quản lý người dùng
**Description:** Là quản trị viên, tôi muốn khóa/mở khóa tài khoản để bảo vệ hệ thống khỏi tài khoản vi phạm hoặc bất thường.

**Acceptance Criteria:**
- [ ] Admin tìm được tài khoản theo email/tên và xem trạng thái.
- [ ] Khóa tài khoản chặn phiên đăng nhập mới; mở khóa cho phép đăng nhập lại.
- [ ] Không thể khóa tài khoản admin cuối cùng.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Should-have. **Dependencies:** US-001.

### US-012: Xem ước tính ngân sách chi tiết
**Description:** Là khách du lịch, tôi muốn xem tổng chi phí ước tính phân tách theo hạng mục (tham quan, ăn uống, di chuyển, lưu trú) để kiểm soát ngân sách chuyến đi.

**Acceptance Criteria:**
- [ ] Hiển thị ước tính chi phí theo từng hạng mục: tham quan, ăn uống, di chuyển và lưu trú (nếu bao gồm).
- [ ] Hiển thị tổng chi phí theo từng ngày và tổng toàn chuyến.
- [ ] Cảnh báo trực quan rõ ràng khi tổng chi phí vượt ngân sách đã nhập.
- [ ] Khi người dùng thêm/xóa/thay hoạt động, số liệu ngân sách cập nhật lại.
- [ ] Các giá trị hiển thị kèm nhãn "ước tính" và đơn vị VND.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

**Priority:** Must-have. **Dependencies:** US-007, US-009.

## 11. Main user flows

### Flow A — Tạo và lưu lịch trình

1. Người dùng mở ứng dụng, đăng nhập/đăng ký.
2. Chọn “Tạo chuyến đi”, nhập ngày, số ngày, số người, ngân sách, sở thích, cường độ và ràng buộc.
3. Ứng dụng xác thực đầu vào, gọi dịch vụ gợi ý và hiển thị trạng thái tải.
4. Dịch vụ trả lịch trình theo ngày hoặc fallback kèm lý do/cách nới ràng buộc.
5. Người dùng xem ngày đầu tiên ở dạng danh sách và bản đồ, chuyển giữa các ngày.
6. Người dùng tùy chỉnh hoạt động; hệ thống tính lại số liệu.
7. Người dùng đặt tên và lưu lịch trình; lịch trình xuất hiện trong “Lịch trình của tôi”.

### Flow B — Khám phá và thêm điểm mong muốn

1. Người dùng tìm kiếm/lọc địa điểm.
2. Mở chi tiết, kiểm tra thông tin và vị trí.
3. Đánh dấu yêu thích hoặc thêm làm điểm bắt buộc khi tạo/chỉnh lịch trình.
4. Ứng dụng cập nhật lịch trình và cảnh báo nếu ràng buộc làm vượt ngân sách/thời gian.

### Flow C — Quản trị dữ liệu

1. Admin đăng nhập và mở khu vực quản trị.
2. Tạo hoặc chỉnh sửa địa điểm, xác nhận tọa độ/loại/giá/giờ mở cửa/trạng thái hiển thị.
3. Hệ thống lưu thay đổi, ghi audit log và dữ liệu có hiệu lực ở tìm kiếm/gợi ý.

## 12. Data requirements

| Entity | Trường chính | Quan hệ |
| --- | --- | --- |
| User | id, email, passwordHash, displayName, role, status, locale | 1–1 TravelPreference; 1–N Itinerary, Favorite, AuditLog. |
| TravelPreference | userId, interests, defaultBudgetVnd, pace, transportMode | Thuộc một User. |
| Destination | id, externalPlaceId, name, categoryId, description, lat, lng, priceMin/Max, openingHours, status, source, updatedAt | N–1 Category; N–M InterestTag; được tham chiếu bởi ItineraryItem/Favorite. |
| Category | id, name, type | 1–N Destination. Các type: attraction, restaurant, hotel. |
| InterestTag | id, name | N–M Destination qua DestinationInterest. |
| Favorite | userId, destinationId, createdAt | Bảng nối User–Destination; unique(userId, destinationId). |
| TripRequest | id, itineraryId?, startDate, durationDays, travelerCount, budgetVnd, includeAccommodation, pace, transportMode, origin | Lưu dữ liệu đầu vào của một lần tạo lịch trình. |
| Itinerary | id, userId, title, status, startDate, endDate, totalCost, totalDistance, totalDuration | 1–N ItineraryDay. |
| ItineraryDay | id, itineraryId, dayNumber, date, estimatedCost, estimatedDistance, estimatedDuration | 1–N ItineraryItem. |
| ItineraryItem | id, itineraryDayId, destinationId?, sequence, startTime?, stayMinutes, cost, travelDistance, travelMinutes, rationale | Một hoạt động; cho phép `destinationId` rỗng chỉ khi hỗ trợ mục tùy chỉnh ở giai đoạn sau. |
| RouteCache | origin/destination hoặc route key, provider, distance, duration, polyline?, expiresAt | Cache phản hồi API bản đồ, không phải dữ liệu người dùng. |
| AuditLog | id, actorUserId, action, entityType, entityId, createdAt, metadata | Ghi thao tác admin. |

Ràng buộc dữ liệu: toàn bộ tiền tệ là VND số nguyên; tọa độ WGS84 (hệ tọa độ GPS toàn cầu); thời gian lưu ISO 8601 (định dạng quốc tế cho ngày giờ, ví dụ `2025-06-15T08:30:00+07:00`); xóa `Destination` là xóa mềm (đánh dấu ẩn thay vì xóa vĩnh viễn) để giữ tính toàn vẹn lịch trình cũ.

## 13. API requirements

API được version hóa `/api/v1`, dùng JSON và xác thực Bearer token/secure session. Endpoint quản trị yêu cầu role `admin`.

| Method | Endpoint | Mục đích |
| --- | --- | --- |
| POST | `/auth/register` | Đăng ký. |
| POST | `/auth/login` | Đăng nhập. |
| POST | `/auth/logout` | Kết thúc phiên. |
| GET/PATCH | `/me` | Xem/cập nhật hồ sơ. |
| GET/PATCH | `/me/preferences` | Xem/cập nhật sở thích. |
| GET | `/destinations` | Tìm kiếm/lọc/pagination: `q`, `category`, `interest`, `priceMax`, `page`. |
| GET | `/destinations/{id}` | Chi tiết địa điểm. |
| GET/POST/DELETE | `/favorites` và `/favorites/{destinationId}` | Liệt kê/thêm/xóa yêu thích. |
| POST | `/itineraries/generate` | Nhận TripRequest và trả bản nháp lịch trình cùng cảnh báo/fallback. |
| GET/POST | `/itineraries` | Liệt kê/tạo lịch trình đã lưu. |
| GET/PATCH/DELETE | `/itineraries/{id}` | Xem/sửa metadata/xóa lịch trình. |
| PATCH | `/itineraries/{id}/days/{dayNumber}/items` | Thêm, xóa, sắp xếp hoặc thay thế hoạt động; trả số liệu tính lại. |
| POST | `/itineraries/{id}/recalculate` | Tính lại route/chi phí sau chỉnh sửa. |
| POST | `/itineraries/{id}/duplicate` | Sao chép lịch trình. |
| GET | `/trips/history` | Danh sách lịch trình đã kết thúc. |
| GET/POST/PATCH/DELETE | `/admin/destinations` và `/admin/destinations/{id}` | Quản lý địa điểm. |
| GET/PATCH | `/admin/users` và `/admin/users/{id}/status` | Tìm và khóa/mở khóa người dùng. |
| GET | `/admin/audit-logs` | Xem audit log có phân trang. |

Mọi endpoint danh sách phải phân trang; endpoint generate/recalculate phải rate-limit theo user; lỗi phải dùng định dạng nhất quán gồm `code`, `message`, `requestId`.

## 14. MVP scope

### Must-have

- Mobile app tiếng Việt/Anh, đăng ký/đăng nhập email-mật khẩu và hồ sơ/sở thích.
- Danh mục điểm tham quan, nhà hàng, khách sạn ở Đà Nẵng; tìm kiếm, lọc và trang chi tiết.
- Máy gợi ý theo quy tắc/ràng buộc cho 1–7 ngày; đầu vào ngân sách, số người, sở thích, cường độ và phương tiện.
- Lịch trình theo ngày, chi phí/thời gian/khoảng cách ước tính, bản đồ/tuyến từ một nhà cung cấp API.
- Chỉnh sửa cơ bản lịch trình, lưu/quản lý/lịch sử, cùng danh sách yêu thích.
- Khu vực admin CRUD địa điểm và phân quyền.

### Should-have

- Đăng nhập Google.
- Quản lý trạng thái người dùng bởi admin.
- Tính điểm xuất phát/nơi lưu trú mỗi ngày và giờ mở cửa trong tối ưu hóa.
- Thông báo khi dữ liệu địa điểm hoặc chi phí thay đổi.

### Future features

- Đánh giá/rating do người dùng tạo, ảnh do người dùng tải lên và luồng kiểm duyệt.
- Thanh toán/đặt khách sạn, nhà hàng hoặc tour.
- Chia sẻ/cộng tác lịch trình, xuất PDF, làm việc offline.
- Dự báo thời tiết, sự kiện thời gian thực, tắc đường và đa phương tiện chi tiết.
- Mở rộng ngoài Đà Nẵng, đa tiền tệ và mô hình ML/LLM cá nhân hóa sau khi có dữ liệu hợp lệ.

## 15. Technical considerations

### Hiện trạng

Repository hiện chỉ có `README.md` (“AI Product Development”), chưa có source code, dependency, database hay kiến trúc cần kế thừa. Vì vậy đây là đề xuất kỹ thuật, không phải thay đổi vào code hiện tại.

### Kiến trúc khuyến nghị cho đồ án

- Mobile client: **Flutter + Dart**, dùng một codebase cho Android/iOS. Tổ chức theo feature (`auth`, `destinations`, `itineraries`, `profile`, `admin` nếu cần màn hình admin mobile) và tách presentation, state, domain, data. Dùng Riverpod (thư viện quản lý trạng thái ứng dụng trong Flutter) cho state management, Dio (thư viện HTTP client cho Dart) cho HTTP và `go_router` cho điều hướng.
- Admin: giao diện web riêng tối giản (React + TypeScript) gọi cùng REST API; không mở rộng toàn bộ chức năng quản trị vào ứng dụng mobile người dùng.
- Backend: **Java 21 + Spring Boot** cung cấp REST API; dùng Spring Security cho xác thực/phân quyền, Spring Data JPA cho truy cập dữ liệu và tách package/module `auth`, `users`, `destinations`, `itineraries`, `recommendation` và `admin`. Không cần microservices trong MVP.
- Database: **MySQL 8** với Spring Data JPA/Hibernate và Flyway (công cụ quản lý phiên bản cấu trúc database, tự động áp dụng các thay đổi schema theo thứ tự) cho migration; seed một bộ dữ liệu Đà Nẵng đã kiểm duyệt.
- Map/Places: dùng Google Maps Platform (Places, Geocoding, Routes/Directions) làm nhà cung cấp duy nhất trong MVP. Kiểm tra hạn mức, billing, điều khoản hiển thị/attribution trước khi demo; đặt key ở biến môi trường, giới hạn key theo API/app và gọi API nhạy cảm qua backend khi cần.
- Recommendation service: Spring service thuần có unit test với bộ input/output cố định. Tách interface `RouteProvider` để mock (tạo đối tượng giả lập) khi test và thay nhà cung cấp map sau này.
- Cache: Redis là tùy chọn; nếu không dùng, dùng bảng `RouteCache` MySQL với TTL để giữ chi phí thấp.
- CI: chạy `flutter analyze`, Flutter unit/widget tests, `./mvnw test`, kiểm tra style, kiểm tra migration Flyway và build backend. Có môi trường `.env.example`, không commit secrets.

## 16. Design considerations

### Nguyên tắc thiết kế

- **Mobile-first:** Mọi màn hình được thiết kế ưu tiên cho điện thoại; thao tác một tay thuận tiện.
- **Progressive disclosure:** Chỉ hiển thị thông tin cần thiết ở mỗi bước; chi tiết bổ sung mở khi người dùng yêu cầu.
- **Trạng thái rõ ràng:** Luôn có trạng thái tải (loading), rỗng (empty state) và lỗi (error state) cho mỗi màn hình.

### Các màn hình chính

| Màn hình | Mô tả tóm tắt |
| --- | --- |
| Onboarding / Đăng ký / Đăng nhập | Form đơn giản, ít trường, có thông báo lỗi inline |
| Trang chủ / Khám phá | Thanh tìm kiếm nổi bật, bộ lọc loại/sở thích, danh sách điểm đến dạng card có ảnh |
| Chi tiết điểm đến | Ảnh, mô tả, tọa độ/liên kết bản đồ, giá tham khảo, giờ mở cửa, nút yêu thích |
| Tạo chuyến đi (Wizard) | Form nhiều bước: ngày → ngân sách/số người → sở thích/cường độ → ràng buộc → xác nhận |
| Kết quả lịch trình | Danh sách hoạt động theo ngày, tab chuyển ngày, tổng chi phí/khoảng cách/thời gian; nút chuyển sang bản đồ |
| Bản đồ lịch trình | Marker đánh số, polyline tuyến đường, bottom sheet chi tiết điểm đang chọn |
| Chỉnh sửa lịch trình | Kéo-thả hoặc nút di chuyển để đổi thứ tự; thêm/xóa/thay thế hoạt động; cập nhật số liệu tức thời |
| Lịch trình đã lưu | Danh sách card lịch trình, trạng thái (nháp/sắp tới/đã đi), thao tác đổi tên/sao chép/xóa |
| Hồ sơ & sở thích | Chỉnh sửa tên, ngôn ngữ, sở thích, ngân sách mặc định, cường độ, phương tiện |
| Admin — Quản lý địa điểm | Bảng danh sách có tìm kiếm/lọc, form tạo/sửa, toggle ẩn/hiện |
| Admin — Quản lý người dùng | Bảng danh sách, trạng thái tài khoản, nút khóa/mở khóa |

### Ghi chú UX

- Wireframe hoặc mockup chi tiết nên được tạo trên Figma trước khi phát triển; link cập nhật vào PRD khi có.
- Tuân thủ Material Design 3 (Flutter) cho ứng dụng mobile và component library nhất quán (ví dụ: MUI hoặc Ant Design) cho admin web.

### Các quyết định đã chốt cho MVP

- Framework mobile: Flutter + Dart.
- Backend: Java 21 + Spring Boot; database: MySQL 8 + Spring Data JPA/Hibernate + Flyway.
- Admin: React + TypeScript web app tối giản, dùng chung REST API.
- Map/Places: Google Maps Platform; nhóm phải xác minh billing, quota, API key restriction và attribution trước khi demo.
- Bộ dữ liệu seed phải có nguồn hợp lệ và quy trình kiểm tra/cập nhật bởi admin.
- Chính sách quyền riêng tư và tài khoản demo/admin phải được chuẩn bị trước buổi bảo vệ.

## 17. Risks and assumptions

| Hạng mục | Rủi ro/giả định | Giảm thiểu |
| --- | --- | --- |
| API bên thứ ba | Maps/Places cần API key, có hạn mức/chi phí và dữ liệu có thể thiếu/sai. | Đặt quota/caching, khóa key, seed dữ liệu cốt lõi, có Haversine fallback. |
| Tối ưu lịch trình | Bài toán tối ưu route phức tạp nếu bổ sung quá nhiều ràng buộc. | MVP dùng heuristic (thuật toán tìm lời giải đủ tốt thay vì tối ưu tuyệt đối) chấm điểm + sắp xếp theo cụm, giới hạn 1–7 ngày và 5 hoạt động/ngày. |
| “AI” | Không có dữ liệu lịch sử để huấn luyện mô hình đáng tin cậy. | Mô tả trung thực là recommendation engine giải thích được; chỉ nghiên cứu LLM/ML ở future scope. |
| Dữ liệu | Giờ mở cửa, giá và thông tin địa điểm thay đổi nhanh. | Hiển thị thời điểm cập nhật/nguồn; cho admin cập nhật và dùng nhãn “ước tính”. |
| Tiến độ đồ án | Mobile, backend, admin, map và thuật toán dễ vượt năng lực/thời gian. | Làm theo Must-have, dùng dữ liệu seed giới hạn, hoãn review/booking/offline. |
| Bảo mật | Rò rỉ API key/mật khẩu hoặc phân quyền admin sai. | Secrets qua env, hash mật khẩu, RBAC (phân quyền theo vai trò) server-side, test authorization và audit log. |

Giả định: ứng dụng chỉ phục vụ Đà Nẵng ở MVP; người dùng có internet; ngân sách dùng VND; dữ liệu Places được sử dụng theo điều khoản nhà cung cấp; nhóm có quyền cấu hình một tài khoản API map phù hợp.

## 18. Success criteria

- Một người dùng mới hoàn thành tạo lịch trình 2–3 ngày và lưu nó trong tối đa 3 phút ở bài kiểm thử usability với dữ liệu mẫu.
- Với ít nhất 20 bộ input kiểm thử hợp lệ, 100% lịch trình trả về đúng số ngày, không chứa điểm bị loại trừ và không vượt số hoạt động/ngày đã định nghĩa.
- Với tối thiểu 30 địa điểm seed đa dạng, ít nhất 90% truy vấn gợi ý hợp lệ trả kết quả hoặc fallback có hướng dẫn rõ ràng.
- 95% API thông thường dưới 2 giây và 95% lần tạo lịch trình dưới 10 giây trong kiểm thử tải quy mô đồ án.
- Không có lỗi phân quyền nghiêm trọng trong kiểm thử: user không đọc/sửa dữ liệu user khác, user không gọi được API admin.
- Chi phí, quãng đường, thời gian hiển thị nhất quán sau mỗi thao tác chỉnh sửa theo test case đã định nghĩa.

## 19. Non-goals

- Không cung cấp chức năng đặt vé, thanh toán hoặc bảo đảm đặt chỗ.
- Không cam kết giá, tình trạng mở cửa, giao thông hay thời tiết theo thời gian thực.
- Không xây dựng mạng xã hội du lịch, chat, đánh giá người dùng hoặc upload ảnh trong MVP.
- Không tối ưu hóa cấp độ thương mại như điều phối tài xế, dynamic pricing hoặc mô hình ML được huấn luyện riêng.
- Không mở rộng địa lý ra ngoài Đà Nẵng trong MVP.

## 20. Open questions

- Xác minh khả năng sử dụng Google Maps Platform, billing, quota, API key restriction và attribution cho đồ án.
- Xác định bộ dữ liệu seed tối thiểu (số lượng và nguồn) trước khi đánh giá chất lượng gợi ý.
- Quy định cụ thể về chỗ ở: người dùng tự chọn điểm xuất phát hay hệ thống đề xuất khách sạn là một hoạt động trong MVP.
