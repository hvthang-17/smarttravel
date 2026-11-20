# Đánh giá ban đầu và môi trường kiểm thử

> Tài liệu lịch sử. Những nhận định thiếu chức năng, tên migration và số test bên dưới thuộc thời điểm báo cáo gốc; không mô tả tiến độ hiện tại. Xem [trạng thái yêu cầu](../../planning/requirements-status.md) và [hướng dẫn đọc báo cáo](../README.md).

## Kết quả

Đã có baseline tái lập được cho backend, admin và Flutter, database test riêng và ma trận FR-01–FR-16. Kiểm tra luồng API có bằng chứng tự động; nghiệm thu luồng giao diện trên thiết bị/trình duyệt còn bị chặn bởi tài nguyên máy. Đây không phải nghiệm thu hoàn thành tính năng MVP.

## BASE-01 — Trạng thái ban đầu và migration

Trước thay đổi giai đoạn 0:

- `backend/src/main/resources/application.yml` đã có thay đổi của người dùng: thêm `repair-on-migrate: true`. Giữ nguyên file; không dùng cờ này thay cho quy trình phục hồi migration.
- V4–V9 là file chưa được Git theo dõi. Giữ nguyên nội dung; không đổi version, không commit.
- `docs/planning/completion-plan.md` là kế hoạch tạo ở lượt trước, chưa được Git theo dõi.
- Database phát triển đã chạy thành công V1–V9 sau lần phục hồi trước. Đọc lịch sử xác nhận cả 9 version success=1.
- Snapshot SHA256 các migration tại [checksum lịch sử](../evidence/baseline-migration-sha256.txt); dùng để phát hiện thay đổi ngoài ý muốn.

Database test mới chạy migration thành công từ V1 đến V9. Có 358 điểm đến: BEACH 18, FOOD 80, CULTURE 50, CHECKIN 50, HOTEL 60, CAFE 50, NIGHTLIFE 50. Truy vấn test trả 0 tọa độ ngoài miền, 0 khoảng giá âm/đảo, 0 nhóm osm_id trùng.

Giới hạn: chưa xác minh tọa độ nằm trong ranh giới Đà Nẵng, nguồn ảnh/rating, giá và giờ mở cửa ngoài thực tế. SQL hợp lệ không đồng nghĩa dữ liệu biên tập chính xác.

## BASE-02 — Môi trường và cô lập test

- Node shim chưa chọn version; dùng Node 24.19.0/npm 11.17.0 đã cài qua PATH trong phiên shell, không thay cấu hình toàn máy.
- Flutter 3.47.1/Dart 3.13.1 hoạt động. Cache/package config ban đầu thiếu dependency; `flutter pub get` khôi phục được, không đổi pubspec/lockfile.
- MySQL92 đang chạy. Tạo `smarttravel_test` và user local chỉ được grant trên database đó. Không cấp quyền trên `smarttravel`.
- Thêm `application-test.yml`, script SQL tạo database test và TestDatabaseGuard trước refresh context. Guard từ chối URL database phát triển; có unit test cho URL hợp lệ, URL phát triển và tên test nằm trong query string.
- Thay test chỉ in dữ liệu/bắt lỗi bằng assert đúng database, migration không thất bại và seed có dữ liệu.
- Runbook: `baseline-runbook.md`. CI hiện dùng database test qua biến môi trường; không bật trigger push/PR ở giai đoạn này.

## BASE-03 — Bằng chứng kiểm tra

| Kiểm tra | Kết quả / bằng chứng |
| --- | --- |
| Admin npm run build | PASS: TypeScript và Vite 8.3.4 build 68 modules; chạy bằng Node 24.19.0 |
| Flutter analyze --no-pub | PASS: No issues found; log mobile/build/phase0-analyze.log |
| Flutter test --no-pub | PASS: 3 test; log mobile/build/phase0-tests.log; dùng TEMP/TMP trên D |
| Backend baseline đầu | PASS: 4 test, gồm HTTP journey và database assertion; chạy smarttravel_test |
| Backend cuối | PASS: 6 test, 0 failures/errors; backend/target/phase0-tests.log và surefire-reports; có 2 test database guard. Lượt cuối chạy tuần tự với heap 256 MB |
| Luồng HTTP | BaselineJourneyTest: đăng ký email ngẫu nhiên → login JWT → tạo 2 ngày FOOD → sửa ghi chú mọi ngày → GET chi tiết → đối chiếu tổng tiền → GET danh sách |
| Luồng giao diện | Chưa nghiệm thu: Flutter web chưa khởi chạy hoàn tất; server test bổ sung gặp lỗi native memory/pagefile. Đã dừng tiến trình kiểm tra tạm; không đổi cổng 8080 của người dùng |

Test HTTP lưu dữ liệu trên database test, không gọi backend phát triển. Test không in token/mật khẩu. Test sửa toàn bộ ngày nên không xác nhận sửa một phần đã đúng; xem lỗi DATA-03 trong kế hoạch.

## Lỗi môi trường đã phân loại

| Mã | Hiện tượng | Xử lý / phần còn lại |
| --- | --- | --- |
| ENV-01 | Node shim báo No active Node.js version | Đã dùng executable có sẵn bằng PATH phiên shell; runbook có lệnh |
| ENV-02 | Flutter import package không tồn tại | Đã flutter pub get; analyze và 3 test qua sau khôi phục |
| ENV-03 | C chỉ còn khoảng 4 MB, copy output.dill báo errno 112 | Đã chuyển thư mục tạm test sang D, không xóa file cá nhân; cần người dùng giải phóng dung lượng C |
| ENV-04 | Java/MySQL thiếu native memory, pagefile quá nhỏ khi chạy compiler và server | Dừng tiến trình kiểm tra, giới hạn heap và chạy tuần tự; UI cần chạy lại khi máy đủ RAM/pagefile |
| ENV-05 | MySQL local 9.2 khác MySQL 8.4 của dự án/CI | Migration/test local có thể chạy; chưa xác nhận tương thích 8.4 trong lượt này |
| ENV-06 | Không phát hiện thiết bị Android/iOS | Chưa thể nghiệm thu luồng trên điện thoại; không coi web/API là bằng chứng nền tảng native |

## Lỗi mã/nghiệp vụ đã ghi nhận, chưa sửa trong giai đoạn 0

1. P0: API ghi và quản lý user mở public; đăng ký nhận role; JWT filter gán ROLE_USER; thiếu owner check khi GET lịch trình; trạng thái khóa chưa chặn login.
2. P1: shuffle và quay vòng điểm, chưa áp ràng buộc ngân sách/giờ/vị trí; input backend chưa khớp PRD.
3. P1: updateActivities có nguy cơ sai tổng khi chỉ gửi một phần ngày; chưa có test hồi quy trường hợp này trong baseline.
4. P1: yêu thích, xóa chuyến mobile, reset mật khẩu, social login và nhiều thao tác dashboard mới đổi state/thông báo; audit UI hardcode.
5. P1: tuyến bản đồ nối tọa độ; chưa Directions/Matrix; chưa đủ chi phí đi lại/lưu trú.
6. P1: thời tiết thật trả 400 Invalid timezone; test fallback vẫn qua, chưa chứng minh API thật hoạt động.
7. Chất lượng: thiếu bộ test quyền/validation/ràng buộc; tài liệu codebase-summary cũ; CI chỉ workflow_dispatch.

Đối chiếu từng FR, API, màn hình và test tại `requirements-status.md`.

## Bàn giao

- BASE-01, BASE-02, BASE-04: hoàn thành trong phạm vi kiểm tra local đã ghi.
- BASE-03: ba kiểm tra chuẩn đã có lượt chạy; luồng HTTP qua; phần giao diện còn chờ máy đủ tài nguyên và thiết bị mục tiêu. Không đánh dấu hoàn tất toàn bộ BASE-03.
- Không thay production code, migration cũ, dependency manifest hoặc cấu hình phát triển của người dùng; không commit.
- Tiếp tục SEC-01–SEC-06 sau khi chốt báo cáo baseline; không cần chờ UI để sửa các lỗi quyền đã rõ. Nghiệm thu UI BASE-03 vẫn là việc còn mở.
