# Tài khoản, hồ sơ và dữ liệu cá nhân

Đã triển khai hồ sơ du lịch theo tài khoản, quản lý phiên, đặt lại mật khẩu và xóa dữ liệu cá nhân. Luồng gửi thư đã được kiểm tra bằng máy chủ email local; chưa có bằng chứng thư đến hộp thư thật.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Backend, mobile; hồi quy phiên admin |
| Công việc liên quan | Mốc 4: USER-01, AUTH-01–03 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Hồ sơ và phiên đăng nhập

Mobile lưu hồ sơ khách du lịch qua GET/PUT `/api/v1/auth/profile`. Server trả cùng hồ sơ khi đăng nhập trên thiết bị khác. Tùy chọn gồm ngôn ngữ ưu tiên, ngân sách, nhịp độ, phương tiện và mã danh mục. Gửi `defaultBudgetVnd: null` để bỏ ngân sách mặc định. Danh mục cũ hoặc đã ẩn được báo để người dùng bỏ chọn. Ngôn ngữ lưu trong hồ sơ; phần Việt/Anh toàn giao diện được trình bày ở [báo cáo trải nghiệm](../experience/localization-and-accessibility.md).

Mobile chỉ giữ hồ sơ đã tải trong bộ nhớ của phiên. Đăng xuất hoặc 401 của phiên hiện tại xóa token và trạng thái riêng. Khởi động lại kiểm tra token với server trước khi khôi phục phiên. Các khóa `pref_*` cũ không được đọc để gán cho tài khoản. Cài đặt cảnh báo thời tiết trên thiết bị có khóa theo ID người dùng. JWT mới gắn ID tài khoản và phiên bản xác thực. JWT đã phát hành trước thay đổi này thiếu ID nên người dùng cần đăng nhập lại.

## Đặt lại mật khẩu

- `POST /api/v1/auth/forgot-password` nhận email và trả 202 với cùng thông báo cho email hợp lệ, không tồn tại hoặc không đủ điều kiện. Hàng đợi xử lý email ngoài request. Mỗi tài khoản có khoảng chờ 60 giây giữa các lần cấp mã.
- `POST /api/v1/auth/reset-password` nhận mã cùng mật khẩu mới. Mã ngẫu nhiên 256 bit hết hạn sau 20 phút. Database chỉ giữ SHA-256 của mã. Khóa hàng theo tài khoản và token để đổi mật khẩu và thu hồi tất cả mã còn lại trong một transaction. Đổi mật khẩu tăng phiên bản xác thực để vô hiệu hóa JWT cũ.
- Mobile cho phép gửi yêu cầu, dán mã từ email, nhập lại mật khẩu mới và quay về đăng nhập. Khi dịch vụ chưa cấu hình hoặc hàng đợi đầy, API báo 503.

Backend dùng Resend HTTP API qua JDK HttpClient. Cấu hình các biến môi trường sau cho tiến trình backend. [Tài liệu API gửi email](https://resend.com/docs/api-reference/emails/send-email)

| Biến | Giá trị |
| --- | --- |
| `APP_RESET_EMAIL_API_KEY` | API key gửi thư |
| `APP_RESET_EMAIL_FROM` | Địa chỉ gửi đã xác minh |
| `APP_RESET_EMAIL_ENDPOINT` | Mặc định là Resend. Bài test dùng máy chủ HTTP loopback để nhận thư thử |

Để nghiệm thu kênh thật, tạo một tài khoản thử có hộp thư được phép nhận, yêu cầu mã từ mobile, kiểm tra thư đến, đổi mật khẩu và đăng nhập lại. Kiểm tra mật khẩu cũ, mã cũ và phiên trên thiết bị thứ hai đều bị từ chối. Máy chủ nhận thư local đã được dùng trong kiểm thử tích hợp. Hộp thư thật vẫn chờ cấu hình người gửi và địa chỉ thử nghiệm.

## Xóa tài khoản

Mobile yêu cầu mật khẩu hiện tại và xác nhận xóa. `POST /api/v1/auth/account/delete` xác minh cùng tài khoản đang đăng nhập. Backend bảo vệ quản trị viên hoạt động cuối cùng và xóa theo chính sách FK trong cùng transaction. Hồ sơ, lịch trình và các ngày/hoạt động/ràng buộc, yêu thích, đánh giá và mã reset bị xóa theo cascade. Link chia sẻ trở thành 404. Audit giữ sự kiện nghiệp vụ, xóa tên và liên kết actor của tài khoản đã xóa, không ghi mật khẩu hoặc mã. Mobile xóa phiên và cài đặt cục bộ của tài khoản sau khi server xác nhận.

## Bằng chứng tại lần triển khai

Bộ hồi quy đạt 44 test backend, 21 test Flutter và 6 test bảo mật admin. Flutter analyze sạch và admin build đạt.

Bộ kiểm thử tích hợp bao phủ hồ sơ ở lần đăng nhập khác, ngân sách NULL, email phản hồi đồng nhất, mã hash và hết hạn, hai lần reset đồng thời, thu hồi JWT, xác thực lại, cascade, link chia sẻ, đăng ký lại cùng email và bảo vệ admin cuối. Backend chạy trên MySQL 9.2 cô lập với Flyway V1–V8. Chưa có kiểm thử gửi thư đến hộp thư thật hoặc thao tác trên thiết bị vật lý.

## Việc còn cần kiểm chứng

- Gửi email tới hộp thư thật, đổi mật khẩu và xác nhận mã cũ/phiên cũ bị từ chối.
- Kiểm tra toàn luồng trên Android, gồm đăng nhập tài khoản khác, khởi động lại và xóa dữ liệu liên quan.
- Không dùng số test trong báo cáo này làm số test mới nhất. Xem [trạng thái yêu cầu](../../planning/requirements-status.md) để theo dõi nghiệm thu.

Quay lại [mục lục báo cáo](../README.md).
