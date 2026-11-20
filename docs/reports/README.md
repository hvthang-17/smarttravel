# Báo cáo triển khai và kiểm chứng

Thư mục này trả lời ba câu hỏi: chức năng đã được triển khai thế nào, đã kiểm tra đến đâu và còn thiếu bằng chứng gì. Các báo cáo được nhóm theo chủ đề thay vì mã mốc; không cần biết các mã TRIP/REC/AUD để bắt đầu đọc.

Nếu chỉ cần biết tiến độ mới nhất, đọc [trạng thái yêu cầu](../planning/requirements-status.md). Nếu cần tiêu chí nghiệm thu hoặc thứ tự công việc, đọc [kế hoạch hoàn thiện](../planning/completion-plan.md). Báo cáo không thay hai tài liệu đó.

## Chức năng sản phẩm

Đọc theo thứ tự dưới đây để đi từ tài khoản đến một chuyến đi được lưu và chia sẻ.

| Bạn muốn hiểu | Báo cáo | Nội dung chính |
| --- | --- | --- |
| Dữ liệu cá nhân thuộc tài khoản nào? | [Tài khoản và hồ sơ](features/accounts.md) | Hồ sơ, phiên, reset mật khẩu và xóa tài khoản |
| Địa điểm được quản lý, tìm kiếm và lưu thế nào? | [Catalog, khám phá và yêu thích](features/catalog-and-discovery.md) | Sáu danh mục, giá/giờ/ảnh, xóa mềm, tìm/lọc và favorites |
| Hệ thống chọn địa điểm và xếp lịch ra sao? | [Tạo lịch trình và cá nhân hóa](features/itinerary-generation.md) | Đầu vào, bản nháp, generation key, thuật toán, ngân sách và điểm tiêu biểu |
| Tuyến thật khác đường ước tính thế nào? | [Định tuyến và bản đồ](features/routing-and-maps.md) | Provider/cache/Haversine/unknown, phương tiện, hình học và offline |
| Sau khi tạo chuyến, người dùng làm được gì? | [Chỉnh sửa, lưu và chia sẻ](features/itinerary-management.md) | Version/snapshot, tính lại, copy/xóa, lịch sử và link công khai |
| Review Google và review trong app được xử lý thế nào? | [Đánh giá và kiểm duyệt](features/reviews-and-moderation.md) | CRUD tác giả, tổng hợp điểm, báo cáo và ẩn/hiện |
| Admin đang đọc và quản lý dữ liệu gì? | [Dashboard và nhật ký quản trị](features/administration.md) | Định nghĩa chỉ số, phân trang, quyền và CSV audit |
| Khi nguồn thời tiết lỗi hoặc cũ, ứng dụng làm gì? | [Thời tiết và dữ liệu dự phòng](features/weather.md) | Timezone/locale, độ mới, cache/stale/fallback và kiểm thử nguồn ngoài |

## Dữ liệu và trải nghiệm dùng chung

| Mục đích | Báo cáo |
| --- | --- |
| Kiểm tra hợp đồng giữa backend/mobile/admin | [NULL, rating, version, snapshot và API tương thích](engineering/api-contracts.md) |
| Hiểu baseline database hiện tại và giới hạn nâng cấp | [V1–V8 và việc gộp V11/V12 vào V1](engineering/database-baseline.md) |
| Hiểu phần Việt/Anh, xử lý lỗi và accessibility | [Ngôn ngữ và khả năng tiếp cận](experience/localization-and-accessibility.md) |
| Xem quyết định thiết kế và kết quả kiểm tra UI admin | [Giao diện quản trị](experience/admin-interface.md) |

## Cách đọc kết quả kiểm chứng

- Mỗi báo cáo mở đầu bằng kết luận và phạm vi, sau đó mới đến API/quy tắc kỹ thuật, kết quả kiểm tra và giới hạn. Mã mốc chỉ dùng để đối chiếu với kế hoạch.
- Số test là kết quả của từng lần chạy đã ghi nhận. Ví dụ 49 test ở đợt tạo bản nháp và 78 test ở đợt thuật toán không cộng thành 127 test độc lập. Một bộ hồi quy có thể bao phủ nhiều chức năng.
- Browser dùng API fixture chứng minh hành vi giao diện trong ca đã chạy; không chứng minh ghi DB thật. Widget test không thay nghiệm thu Android native. Một lần gọi dịch vụ ngoài thành công không chứng minh kênh triển khai luôn hoạt động.
- Các báo cáo được biên tập lại ngày 16/11/2026 từ nội dung đã có. Lần biên tập này không chạy lại test sản phẩm và không tạo ảnh/UI evidence mới.
- Baseline hiện tại là V1–V8. Tên V11/V12 trong bằng chứng cũ chỉ lần triển khai trước khi gộp, không phải file cần chạy thêm hiện nay.
- Ảnh UI từng được dẫn trong báo cáo cũ không còn có ở đường dẫn đó trong workspace. Báo cáo giao diện đã ghi rõ tình trạng này và bỏ các liên kết hỏng.

## Lịch sử tham khảo

Chỉ cần đọc phần này khi muốn truy vết quyết định hoặc phát hiện ban đầu. Các nhận định “chưa có” trong lịch sử có thể đã được xử lý ở báo cáo theo chủ đề.

| Tài liệu | Giá trị tham khảo |
| --- | --- |
| [Đánh giá ban đầu và môi trường kiểm thử](history/initial-baseline.md) | Baseline giai đoạn 0, cấu hình máy và giới hạn kiểm tra lúc đầu |
| [Nền xác thực và phân quyền ban đầu](history/security-foundation.md) | Những kiểm tra bảo mật trước các đợt chức năng sau |
| [Các sai lệch trước đồng bộ](history/schema-findings.md) | Lý do cần sửa NULL, rating, ID, version và các luồng chưa hoàn chỉnh lúc review |
| [Lịch sử sắp xếp tài liệu](history/documentation-organization.md) | Cách tổ chức docs ở đợt trước, không phải cấu trúc báo cáo hiện tại |
| [Checksum migration lịch sử](evidence/baseline-migration-sha256.txt) | Bằng chứng giữ nguyên byte; không phải checksum của baseline hiện hành |

“Giai đoạn 0/1” trong tài liệu lịch sử là tên các đợt đầu, không đồng nghĩa Mốc 1/2 trong kế hoạch hoàn thiện sau đó.

## Thuật ngữ thường gặp

| Thuật ngữ | Cách hiểu trong các báo cáo |
| --- | --- |
| Catalog | Danh mục và dữ liệu địa điểm dùng cho tìm kiếm/gợi ý |
| Snapshot | Dữ liệu được giữ tại thời điểm tạo hoặc thay hoạt động, để chuyến cũ không tự đổi theo catalog mới |
| Version | Số phiên bản để phát hiện bản sửa cũ và tránh ghi đè thay đổi của phiên khác |
| Baseline | Bộ schema/migration khởi tạo database; không mặc nhiên là quy trình nâng cấp DB đang có |
| Fixture | Dữ liệu hoặc phản hồi được chuẩn bị để kiểm thử, không phải bằng chứng dịch vụ/DB thật đã hoạt động |
| Hồi quy | Chạy lại các kiểm tra để phát hiện chức năng cũ bị ảnh hưởng bởi thay đổi |
| E2E | Kiểm tra trọn luồng qua các tầng trên môi trường cụ thể; phải nêu rõ có UI, DB thật và thiết bị hay không |

## Quy tắc bổ sung báo cáo

Thêm nội dung vào chủ đề hiện có khi cùng một luồng, tránh tạo file mới cho mỗi lần sửa hoặc mỗi mốc. Chỉ tách tài liệu khi khác đối tượng đọc hoặc khác trách nhiệm, như quản trị dữ liệu và nguồn thời tiết. Khi ghi kết quả mới, nêu môi trường, loại bằng chứng và giới hạn; giữ các kết quả cũ có nhãn thời điểm rõ ràng.
