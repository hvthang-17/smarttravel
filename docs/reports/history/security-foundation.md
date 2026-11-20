# Nền xác thực và phân quyền ban đầu

> Tài liệu lịch sử. Những nhận định thiếu chức năng, tên migration và số test bên dưới thuộc thời điểm báo cáo gốc; không mô tả tiến độ hiện tại. Xem [trạng thái yêu cầu](../../planning/requirements-status.md) và [hướng dẫn đọc báo cáo](../README.md).

Ngày thực hiện: 12/11/2026. Phạm vi: backend, admin và xử lý phiên đăng nhập mobile. Không bổ sung dependency.

## Kết quả theo gói

| Gói | Thay đổi |
| --- | --- |
| SEC-01 | Đăng ký luôn tạo ROLE_USER, bỏ chọn role từ client; chuẩn hóa email; mật khẩu ít nhất 8 ký tự, tối đa 72 byte UTF-8 theo BCrypt. Bootstrap admin phải bật rõ qua môi trường, không nâng quyền tài khoản cũ |
| SEC-02 | Ghi/xóa/upload địa điểm/danh mục và /admin/** yêu cầu ROLE_ADMIN. Khách/user chỉ đọc ACTIVE; chặn status=ALL/INACTIVE và GET ID ẩn. Điểm ACTIVE thuộc danh mục ẩn không công khai, không lọt vào gợi ý và không được thêm bằng ID khi user sửa chuyến |
| SEC-03 | Mỗi request JWT tra role/status/auth_version trong database. Khóa, đổi quyền hoặc mật khẩu thu hồi token cũ; mở khóa không hồi sinh token. Chặn tự khóa/xóa/hạ quyền; khóa bi quan tập admin để bảo vệ admin cuối cùng |
| SEC-04 | Đọc/sửa/chia sẻ lịch trình kiểm tra chủ sở hữu hoặc admin; bỏ email fallback; endpoint admin trả dữ liệu thật. Xóa/sao chép chưa có API, thuộc USER-03 và phải áp dụng cùng quy tắc khi bổ sung |
| SEC-05 | Bỏ auth offline, token giả và cache mật khẩu cũ. Client chung gắn token localStorage/sessionStorage kể cả multipart; xác minh role qua /auth/profile khi mở app. 401 xóa phiên, 403 làm mới quyền/báo lỗi. Mobile không báo cập nhật hồ sơ thành công nếu server từ chối |
| SEC-06 | CORS dùng danh sách origin theo môi trường. 401/403/CORS/validation/upload quá cỡ có ApiResponse. Upload chỉ admin, tối đa 5MB/ảnh, 25MB/request và 10 ảnh; kiểm tra decoder/định dạng/pixel, ghi lại nội dung ảnh |

MVP dùng ROLE_ADMIN và ROLE_USER. ROLE_MODERATOR cũ không được vào admin; bộ lọc vẫn có thể hiển thị tài khoản cũ để quản trị viên chuyển vai trò.

## Migration và dữ liệu

- Thêm V10__add_user_auth_version.sql, chỉ bổ sung users.auth_version; giữ nguyên V1–V9 và thay đổi repair-on-migrate có sẵn, không commit thay người dùng.
- V10 chạy thành công trên smarttravel_test và đã áp dụng trên database phát triển trong lần chạy server UI đầu tiên.
- Lần UI đầu bật profile test nhưng vẫn nhận URL phát triển. Đã dừng sau khi phát hiện, xóa đúng tài khoản tạm phase1-browser@example.test (id=3, không có lịch trình), không rollback migration thành công hoặc xóa dữ liệu người dùng.
- Lần UI sau đặt rõ URL/user smarttravel_test; log xác nhận đúng database. Bổ sung TestDatabaseSafetyConfig để profile test bị chặn trước khởi tạo datasource nếu URL sai, kể cả chạy server thủ công. Có test chứng minh datasource chưa được tạo khi chốt chặn từ chối.

## Bằng chứng kiểm tra

- Backend: mvn test đạt 21/21 test trên database riêng, log backend/target/phase1-tests.log và báo cáo backend/target/surefire-reports. Có kiểm tra quyền khách/user/admin, email, role, dữ liệu ẩn, owner, khóa/mở khóa, đổi mật khẩu, xóa user, admin cuối cùng, CORS, bootstrap, upload và bảo vệ database test.
- Admin: npm run test:security (6 test) và npm run build. Test dùng Node 24.19.0 với built-in VM/type stripping, không thêm thư viện; Node có experimental warning. Kiểm tra phiên không ghi nhớ, lỗi mạng không fallback, 401/403, phản hồi cũ và role server.
- Mobile: flutter analyze --no-pub; flutter test --no-pub đạt 11/11 test. Kiểm tra 401 xóa storage/state, 403 giữ phiên, login sai không xóa phiên đang có, 401 cũ không xóa token mới và hồ sơ bị từ chối không thay state. Root navigation tạo lại các tab khi đổi tài khoản; cache lịch trình sinh lại theo tài khoản; màn hình chi tiết/sửa ẩn dữ liệu riêng khi chưa đăng nhập. Có test xóa cache khi logout và widget test không hiển thị dữ liệu riêng đã cache cho khách.
- Browser thật trên smarttravel_test: đăng nhập bootstrap với remember=false; địa điểm/người dùng/danh mục tải được; token chỉ ở sessionStorage. Sửa token thành không hợp lệ → profile trả 401 → quay về đăng nhập và xóa token. Tài khoản demo cũ bị từ chối 401, không đăng nhập offline.
- Snapshot: backend/target/phase1-admin-users.yml và backend/target/phase1-admin-login-rejected.yml. Các lỗi 401 trong console ở bước từ chối là dự kiến; có warning createRoot do Vite hot reload main.tsx trong lúc chỉnh sửa.
- Đã dừng server test 18080/18082 và đóng tab test. Không dừng backend người dùng ở 8080.

## Cấu hình cần biết

Spring Boot đọc biến môi trường của tiến trình, không tự nạp .env ở gốc repo; Docker Compose dùng .env theo cơ chế riêng.

- CORS_ALLOWED_ORIGINS: origin đầy đủ ngăn cách dấu phẩy; mặc định http://localhost:5173,http://127.0.0.1:5173. Flutter web/cổng Vite khác cần thêm đúng origin; native Android/iOS không chịu CORS trình duyệt.
- JWT_SECRET: secret riêng tối thiểu 32 byte UTF-8. Nếu bỏ trống, server tạo khóa ngẫu nhiên trong tiến trình và token mất hiệu lực sau restart. Khi triển khai phải đặt secret ổn định ngoài Git; secret quá ngắn làm startup thất bại.
- BOOTSTRAP_ADMIN_ENABLED=true, BOOTSTRAP_ADMIN_EMAIL, BOOTSTRAP_ADMIN_PASSWORD: bật tạm để tạo admin qua cấu hình máy chủ; sau đó tắt và gỡ mật khẩu khỏi môi trường. Không sử dụng tài khoản seed/demo khi triển khai.
- VITE_API_BASE_URL: mặc định http://localhost:8080/api/v1.
- app.upload.directory: mặc định uploads, test dùng target/test-uploads. Nhận PNG/JPG/GIF; GIF chỉ giữ frame đầu. Không nhận SVG/WebP mới vì runtime hiện không có decoder WebP phù hợp; không thêm dependency ngoài phạm vi.

Khởi động lại backend/admin để chạy mã mới và đăng nhập lại. JWT cũ không có authVersion sẽ bị từ chối. V10 đã áp dụng trên dev nên không chạy repair hoặc sửa checksum.

## Giới hạn và phần tiếp theo

- Chưa kiểm tra UI native Android/iOS vì chưa có thiết bị; test Flutter không thay thế kiểm tra này. BASE-03 về luồng tạo/sửa/mở lại trên mobile UI vẫn mở.
- MySQL local 9.2, chưa kiểm tra lại trên MySQL 8.4 của CI. Lỗi timezone thời tiết từ baseline giữ nguyên trong giai đoạn này.
- Engine, tổng tiền khi sửa một phần, dashboard/audit và các nghiệp vụ còn thiếu thuộc các giai đoạn sau.
- Chưa thêm refresh token, rate limit hay OAuth. Logout client xóa phiên thiết bị; thu hồi server trong giai đoạn này áp dụng khi khóa/đổi quyền/đổi mật khẩu/xóa tài khoản.
