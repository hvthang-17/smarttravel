# Hướng dẫn chạy và kiểm thử

Các lệnh chạy trong PowerShell từ thư mục được ghi. Chỉ dùng database test riêng khi kiểm thử; không tắt Flyway hoặc `ddl-auto=validate`. [Trạng thái](../planning/requirements-status.md) ghi mức nghiệm thu, còn [báo cáo giai đoạn 0](../reports/history/initial-baseline.md) giữ cấu hình và kết quả lịch sử.

## Công cụ và cấu hình

| Thành phần | Căn cứ và lưu ý |
| --- | --- |
| Java/Maven | Java 21; kiểm tra `java -version`, `mvn -version` trước khi chạy |
| Node/npm | Node 24.19.0 được dùng trong lần kiểm tra admin gần nhất. Bộ test security dùng API Node `stripTypeScriptTypes`; Node 20 trong CI hiện chưa được chứng minh chạy được bộ test này |
| Flutter/Dart | Dùng SDK phù hợp [pubspec.yaml](../../mobile/pubspec.yaml); lần kiểm tra trước ghi Flutter 3.47.1/Dart 3.13.1. Kiểm tra lại bằng `flutter --version` |
| MySQL | [Compose](../../docker-compose.yml) cấu hình 8.4. Các báo cáo backend gần nhất chạy MySQL 9.2 cô lập; chưa thay bằng chứng 8.4 |
| Thiết bị | `flutter devices` và `adb devices` xác định thiết bị hiện có; chưa có thiết bị/AVD ở lần kiểm tra UX ngày 16/11/2026 |

`.env` ở gốc repo được Docker Compose đọc, không tự được Maven/Flutter/Vite đọc. Cấp biến cho đúng tiến trình theo [application.yml](../../backend/src/main/resources/application.yml) và [.env.example](../../.env.example). Không chép mật khẩu hoặc token thật vào Git/log.

- Backend: `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`; `JWT_SECRET` riêng tối thiểu 32 byte UTF-8 để giữ phiên qua restart. Nếu để trống, mã hiện tại dùng khóa JWT ngẫu nhiên mỗi lần khởi động.
- Admin: `VITE_API_BASE_URL`, mặc định `http://localhost:8080/api/v1`; backend CORS phải cho phép origin dev server thực tế.
- Mobile: `--dart-define=API_BASE_URL=...`. Thiết bị Android không truy cập máy tính qua localhost nếu chưa cấu hình kết nối/reverse.
- Các biến route/email/share xem [MAP](../reports/features/routing-and-maps.md), [USER/AUTH](../reports/features/accounts.md) và [TRIPS/SHARE](../reports/features/itinerary-management.md#lưu-trữ-sao-chép-và-chia-sẻ). Chưa có endpoint thật không được coi fixture là nghiệm thu tích hợp.

## Backend: database test riêng

Dùng instance/port riêng hoặc tài khoản chỉ có quyền trên `smarttravel_test`. Nếu cần tạo database/user local bằng script hiện có, chạy từ gốc repo với MySQL client đã cấu hình PATH:

```powershell
mysql -u root -p --execute="source backend/src/test/resources/create-test-database.sql"
```

Đây là bước chuẩn bị có quyền quản trị, không phải tài khoản chạy bộ test. Script không xóa bảng; user đã tồn tại không được tự đổi mật khẩu. Xem [SQL chuẩn bị test](../../backend/src/test/resources/create-test-database.sql) trước khi chạy.

Trong terminal kiểm thử riêng, tại `backend/`, nhập tài khoản test qua prompt:

```powershell
$testCredential = Get-Credential -UserName 'smarttravel_test'
$env:SMARTTRAVEL_TEST_DB_USERNAME = $testCredential.UserName
$env:SMARTTRAVEL_TEST_DB_PASSWORD = $testCredential.GetNetworkCredential().Password
$env:SPRING_DATASOURCE_URL = 'jdbc:mysql://localhost:3306/smarttravel_test?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC'
$env:SPRING_DATASOURCE_USERNAME = $env:SMARTTRAVEL_TEST_DB_USERNAME
$env:SPRING_DATASOURCE_PASSWORD = $env:SMARTTRAVEL_TEST_DB_PASSWORD
mvn test
```

Đổi port cho đúng instance test của bạn. [application-test.yml](../../backend/src/test/resources/application-test.yml) nằm trong test resources, không nằm trong main resources. TestDatabaseGuard và TestDatabaseSafetyConfig từ chối URL có tên database khác `smarttravel_test`. Không dùng root hoặc database phát triển để chạy test. Một số test tích hợp ghi dữ liệu; dùng DB được phép ghi/xóa dữ liệu thử.

JUnit ghi báo cáo ở `backend/target/surefire-reports/`. Nếu thiếu RAM, chạy tuần tự và cân nhắc `mvn test '-DargLine=-Xmx256m'`; ghi rõ điều kiện máy, không nhận lỗi hạ tầng là kết quả nghiệp vụ.

## Admin

Tại `admin/`:

```powershell
node --version
npm --version
npm ci
npm run build
npm run test:destinations
npm run test:security
node --experimental-vm-modules --test tests/*.test.mjs
```

Không có script `npm test` hiện hành. Lệnh wildcard chạy toàn bộ file test, gồm fixture hợp đồng ngoài các script chuyên biệt. Có thể bỏ `npm ci` nếu node_modules đang khớp lockfile. Không tự nâng dependency để chạy kiểm thử tài liệu.

## Mobile

Tại `mobile/`:

```powershell
flutter --version
flutter devices
flutter pub get
flutter analyze
flutter test
```

Nếu dependency đã được resolve có thể dùng `--no-pub`; máy thiếu tài nguyên có thể chạy `flutter test --no-pub --concurrency=1`. Không dùng widget test thay nghiệm thu Android native. iOS/Flutter web chỉ được công bố hỗ trợ khi có bằng chứng riêng.

## Kiểm tra UI với dữ liệu riêng

Tại `backend/`, dùng lại biến tài khoản test ở trên, chọn cổng không xung đột và cấp CORS cho các UI thử:

```powershell
$env:CORS_ALLOWED_ORIGINS = 'http://127.0.0.1:18081,http://localhost:18081,http://127.0.0.1:18082,http://localhost:18082'
mvn spring-boot:run '-Dspring-boot.run.profiles=test' '-Dspring-boot.run.arguments=--server.port=18080'
```

Vì profile cấu hình datasource nằm trong test resources, khi chạy server thủ công phải cấp đầy đủ biến datasource như ví dụ trên. SafetyConfig trong main code vẫn kiểm tra tên DB khi profile test được bật. Kiểm tra URL/port/database trong log trước thao tác UI. Không triển khai profile test lên public.

Tại `admin/`, trong terminal khác:

```powershell
$env:VITE_API_BASE_URL = 'http://localhost:18080/api/v1'
npm run dev -- --host 127.0.0.1 --port 18082
```

Với Android đã kết nối USB, chạy từ `mobile/` và đảm bảo `adb` có trong PATH:

```powershell
adb devices
adb reverse tcp:18080 tcp:18080
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:18080/api/v1
```

Nếu chỉ kiểm tra Flutter web, có thể dùng `flutter run -d web-server --web-hostname=127.0.0.1 --web-port=18081 --dart-define=API_BASE_URL=http://localhost:18080/api/v1`; kết quả này không phải nghiệm thu native hay bằng chứng công bố hỗ trợ web.

Ghi từng bước đăng ký, hồ sơ, tìm/lưu điểm, tạo/sửa/lưu/mở lại chuyến, share/thu hồi, copy/xóa, review/kiểm duyệt/audit theo [QA-02](../planning/completion-plan.md). Kiểm tra hai tài khoản không lẫn cache, mạng lỗi không mất bản sửa, chữ lớn và bàn phím thật. Tách rõ API fixture, DB test thật và thiết bị thật trong báo cáo.

Kết thúc bằng Ctrl+C và đóng terminal cấu hình test; nếu dùng reverse, chạy `adb reverse --remove tcp:18080`. Không xóa dữ liệu hoặc dừng dịch vụ của người dùng ngoài phạm vi kiểm tra.
