# Trạng thái yêu cầu và nghiệm thu

Rà soát ngày 16/11/2026 theo mã nguồn, chuỗi migration hiện hành và báo cáo các mốc. Lần rà tài liệu này không chạy lại test sản phẩm, truy vấn DB vận hành hoặc tạo bằng chứng E2E mới. [Kế hoạch](completion-plan.md) giữ mã công việc/tiêu chí; [mục lục báo cáo](../README.md#báo-cáo-theo-chủ-đề) giữ bằng chứng theo thời điểm.

“Đã triển khai” nghĩa có đường xử lý trong các tầng liên quan và kiểm thử được ghi nhận. Điều đó không đồng nghĩa đã nghiệm thu trên thiết bị, dịch vụ ngoài hoặc môi trường phát hành.

## Phạm vi đã thống nhất

- Chỉ Đà Nẵng và sáu category BEACH/FOOD/CULTURE/CHECKIN/CAFE/NIGHTLIFE. Không HOTEL/booking/thanh toán.
- Giá theo người/lần ghé. Dự toán nhóm chỉ gồm hoạt động, không lưu trú/di chuyển; NULL khác 0. Chi phí phân theo category snapshot.
- Sở thích là category code, không có hệ tag riêng. Lựa chọn chuyến ưu tiên hơn hồ sơ.
- Google rating/count và review SmartTravel hiển thị riêng. Review nội bộ là phạm vi bổ sung được chấp thuận; không chứng nhận người viết đã ghé điểm.
- Không thêm engine_version, route_provider/route_calculated_at, google_place_id/data_updated_at/source_url/verified_at. Trường source đã được thảo luận nhưng chưa có trong schema. Thu thập Google định kỳ và metadata nguồn theo FR-04 gốc chưa hoàn thiện.
- OAuth, chatbot/chỉnh sửa ngôn ngữ tự nhiên, undo/revision, đa thành phố và báo sai dữ liệu tổng quát chưa thuộc MVP. Báo cáo review tối thiểu đã có nơi tiếp nhận.

## FR-01 đến FR-16

| Yêu cầu | Phần đã triển khai | Bằng chứng | Còn cần nghiệm thu / hoàn thiện |
| --- | --- | --- | --- |
| FR-01 Tài khoản | Đăng ký/login, JWT/role/lock, reset nguyên tử, thu hồi phiên và xóa tài khoản có xác thực lại | [USER/AUTH](../reports/features/accounts.md) | Email tới hộp thư thật, E2E hai tài khoản/thiết bị; AUTH-02, QA-02 |
| FR-02 Hồ sơ | GET/PUT travelerProfile, category preferences, mặc định và language; cache theo phiên/user, không gán pref_* cũ | [USER/AUTH](../reports/features/accounts.md), [UX](../reports/experience/localization-and-accessibility.md) | E2E đăng nhập lại/thiết bị khác trên native; QA-02 |
| FR-03 Tìm/lọc | Tên Việt/Anh, category/sở thích/giá, chỉ ACTIVE, phân trang và trạng thái rỗng/lỗi | [DISC](../reports/features/catalog-and-discovery.md#khám-phá-và-yêu-thích) | E2E native và dữ liệu phát hành; QA-02 |
| FR-04 Chi tiết | Ảnh/bản dịch, giờ tuần, giá/thời lượng và hai nguồn đánh giá | [DISC](../reports/features/catalog-and-discovery.md#khám-phá-và-yêu-thích), [REV](../reports/features/reviews-and-moderation.md) | Google định kỳ/metadata nguồn còn giới hạn phạm vi; xác minh catalog thật |
| FR-05 Yêu thích | API chủ sở hữu, thao tác lặp, nút lưu/list và lựa chọn wizard; chính sách điểm ẩn | [FAV](../reports/features/catalog-and-discovery.md#khám-phá-và-yêu-thích) | E2E tài khoản A/B, QA-02 |
| FR-06 Wizard | Mặc định hồ sơ, ngày 1–7/khách 1–10, budget/pace/category/transport/origin, mỗi loại required/excluded tối đa 5 | [TRIP](../reports/features/itinerary-generation.md#đầu-vào-và-bản-nháp) | Hồi quy native và usability; QA-02/04 |
| FR-07 Gợi ý | Chấm điểm theo nội dung, điểm tiêu biểu, chèn tham lam/tìm kiếm cục bộ, giờ/ngân sách và kết quả PARTIAL | [REC](../reports/features/itinerary-generation.md#cơ-chế-gợi-ý-cá-nhân-hóa) | Metadata tiêu biểu hiện nhập qua API, chưa có ô admin; cần catalog thực, hiệu năng và usability |
| FR-08 Hoạt động/chặng | Chặng từ origin/điểm trước; provider/cache/haversine/unknown tách rõ | [MAP](../reports/features/routing-and-maps.md) | Endpoint route được duyệt và kiểm tra tích hợp; không tính chặng quay về origin |
| FR-09 Chỉnh sửa/tính lại | Ownership, version/409, giữ snapshot khi sửa ghi chú, lấy snapshot mới khi thay điểm | [EDIT](../reports/features/itinerary-management.md#chỉnh-sửa-và-tính-lại), [UX](../reports/experience/localization-and-accessibility.md) | E2E native, lỗi mạng trong chuỗi sửa/lưu/mở lại |
| FR-10 Tổng/ngân sách | Server tính unit price × khách, cộng mọi ngày, breakdown category và costComplete | [REC](../reports/features/itinerary-generation.md#cơ-chế-gợi-ý-cá-nhân-hóa), [EDIT](../reports/features/itinerary-management.md#chỉnh-sửa-và-tính-lại) | Kiểm tra catalog thực/giá thiếu trong E2E, không nhận tổng là toàn chi phí du lịch |
| FR-11 Quản lý chuyến | Lưu DRAFT/SAVED, đổi tên, copy độc lập và xóa DB, không sao token | [TRIPS](../reports/features/itinerary-management.md#lưu-trữ-sao-chép-và-chia-sẻ) | E2E nhiều phiên và dọn nháp trong vận hành |
| FR-12 Lịch sử | Phân loại theo endDate và ngày Đà Nẵng, tìm/lọc/phân trang | [TRIPS](../reports/features/itinerary-management.md#lưu-trữ-sao-chép-và-chia-sẻ) | E2E refresh/đổi thiết bị, QA-02 |
| FR-13 Bản đồ | Marker ngày/thứ tự, hình học tuyến thật, mở điều hướng ngoài; đọc SAVED đã tải trong phiên khi mất mạng | [MAP](../reports/features/routing-and-maps.md) | Native Android và provider thật; không suy ra cache bền vững qua khởi động lại |
| FR-14 Quản trị nội dung | CRUD/ẩn/khôi phục, ảnh/bản dịch/giá/giờ/thời lượng và audit cùng transaction | [CAT/AUD](../reports/features/catalog-and-discovery.md#quản-trị-catalog), [thiết kế admin](../reports/experience/admin-interface.md#khung-giao-diện) | Google định kỳ; ô nhập featuredReason; E2E đầy đủ API/DB thật |
| FR-15 Quản trị user | Tìm/lọc/page, role/lock, tự bảo vệ và admin cuối cùng, thu hồi phiên và audit | [ADM](../reports/features/administration.md) | Hồi quy phát hành trên môi trường đích, QA-01/02 |
| FR-16 Audit | Ghi chung transaction, list/filter/page/export CSV, lọc bí mật, ẩn danh khi xóa user | [CAT/AUD](../reports/features/catalog-and-discovery.md#quản-trị-catalog), [ADM](../reports/features/administration.md) | Kiểm tra vận hành/quyền trên môi trường đích, QA-01/02 |

## NFR, dịch vụ ngoài và phát hành

| Nhóm | Hiện trạng | Phần còn mở |
| --- | --- | --- |
| Xóa dữ liệu cá nhân (NFR-03) | Tự xóa có mật khẩu/xác nhận/transaction; cascade và ẩn danh audit | E2E dữ liệu liên quan và link chia sẻ trên DB đích |
| Chia sẻ | Trang HTML công khai, deep link, public DTO; thu hồi/tạo lại/hết hạn | Kiểm tra deep link và phiên bản ứng dụng native phát hành |
| Dashboard | Chỉ số DB thật, kỳ 7/30/90 ngày theo Đà Nẵng | E2E dashboard triển khai |
| Thời tiết | Timezone/locale, cache/stale/fallback, mốc mô hình và retry | Kiểm tra mạng trên thiết bị; test unit không phụ thuộc Internet |
| Việt/Anh và accessibility | Tài nguyên chung, language hồ sơ, fallback, giữ bản sửa, điều chỉnh chữ lớn/focus/vùng bấm | UX-01 còn rà thông báo động; UX-03 chưa nghiệm thu Android, không công bố iOS/Flutter web |
| DB và migration | Baseline hiện tại V1–V8; V1 đã gộp cột/index từ V11/V12; báo cáo kiểm thử DB mới MySQL 9.2 | MySQL 8.4, DB cũ/checksum, nâng cấp và rollback trên bản sao |
| CI | Workflow hiện chỉ workflow_dispatch, backend/mobile checks và admin build | Chưa bật push/PR, chưa chạy test admin, Node CI cần đối chiếu yêu cầu bộ test |
| Hiệu năng/observability | Chưa có bằng chứng đo đạt mục tiêu | p95, thời gian engine/provider, request ID, tỷ lệ kết quả/fallback; QA-03/OPS |
| Usability | Chưa có nghiên cứu đủ người | Ít nhất 5 người, tỷ lệ hoàn thành trong 3 phút; QA-04 |
| Vận hành | Cấu hình qua biến môi trường, adapter/test guard đã có | HTTPS, endpoint/chi phí được duyệt, backup/restore và chính sách dọn nháp được kiểm chứng |

## Bằng chứng gần nhất

- Backend: [baseline đã gộp](../reports/engineering/database-baseline.md) đạt 85 test trên DB mới MySQL 9.2 cô lập với V1–V8. Không phải bằng chứng MySQL 8.4 hoặc database đang dùng đã chuyển đổi.
- Mobile: [Mốc 13](../reports/experience/localization-and-accessibility.md) ghi analyze sạch và 40 test. ADB không có thiết bị và không có AVD; widget test không thay native UI.
- Admin: [thiết kế mới](../reports/experience/admin-interface.md#khung-giao-diện) ghi build và 22 test, browser desktop/màn nhỏ bằng fixture. Các mốc catalog trước có kiểm tra DB cô lập; không suy thành toàn bộ admin đã đạt E2E.
- Số test trong báo cáo cũ là lịch sử của từng mốc, không cộng dồn. [Review đầu kỳ](../reports/history/schema-findings.md) chỉ dùng để truy vết lỗi đã phát hiện, không phải backlog hiện tại.

Mốc 2–12 có triển khai và bằng chứng theo từng báo cáo, còn các phụ thuộc tích hợp nêu trên. Mốc 13 chưa đóng nghiệm thu; Mốc 14 QA/OPS/DOC chưa có đủ bằng chứng để đóng dự án. Không quy đổi số bảng/màn hình/test thành phần trăm hoàn thành.
