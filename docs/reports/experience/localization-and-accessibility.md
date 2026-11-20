# Việt/Anh, xử lý lỗi và khả năng tiếp cận

Đã bổ sung tài nguyên dịch dùng chung, language theo hồ sơ và bảo vệ bản sửa khi thao tác lỗi. Mốc UX chưa đóng nghiệm thu vì thiếu Android native và E2E đầy đủ; không công bố iOS/Flutter web từ widget test.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Mobile và admin |
| Công việc liên quan | Mốc 13: UX-01–03 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Ngôn ngữ

- Mobile dùng `AppLanguage` và tài nguyên `mobile/assets/translations/en.json`; Material cũng nhận locale Việt/Anh qua dependency SDK `flutter_localizations`.
- Ngôn ngữ của tài khoản lấy từ traveler profile. Mobile giữ luồng GET/PUT hồ sơ hiện có; admin bổ sung bộ chọn và PUT `/auth/profile`. Chỉ đổi giao diện sau khi server xác nhận; login/refresh nhận lại ngôn ngữ của hồ sơ. Lựa chọn của khách chưa đăng nhập chỉ có hiệu lực trong phiên giao diện.
- Admin dùng chung tài nguyên dịch với mobile, không cần dependency dịch bên thứ ba. Dữ liệu tên/mô tả địa điểm và category ưu tiên bản Anh khi có, nếu thiếu giữ tiếng Việt. Giá trị form và mã gửi API không đổi theo nhãn hiển thị.
- Nội dung người dùng được giữ nguyên. Thông điệp từ server hoặc nội dung chưa có trong tài nguyên dịch giữ nguyên để không mất ý nghĩa; cần rà tiếp các thông báo động trong E2E trước khi nghiệm thu đầy đủ UX-01.
- Category không xác định hiển thị nhãn chung thay vì dùng mã kỹ thuật như tên. Form admin vẫn hiển thị code ở trường quản trị code theo hợp đồng catalog.

## Dữ liệu khi thao tác lỗi

- Màn sửa chuyến hỏi trước khi bỏ thay đổi chưa lưu, gồm nút đóng và thao tác back. Lưu thất bại giữ bản sửa và snapshot; vẫn giữ cách xử lý 409 trước đó. Thành công chỉ đóng sau khi server trả kết quả.
- Form địa điểm admin giữ nội dung khi lỗi; đóng, Escape và bấm ngoài hỏi xác nhận nếu đã sửa. Reload/đóng tab có cảnh báo của trình duyệt. Bản sửa nằm trong bộ nhớ của form, không phải cơ chế phục hồi sau khi ứng dụng bị hệ điều hành kết thúc.
- Đổi ngôn ngữ không remount form để tránh mất dữ liệu đang nhập. Request admin có thời hạn 20 giây; lỗi mạng/timeout nêu cách thử lại. Không tự gửi lại request ghi. Retry wizard tiếp tục sử dụng generation key theo hợp đồng TRIP.
- Các luồng tìm kiếm/favorites, chia sẻ, đánh giá và thời tiết tiếp tục dùng loading/empty/error/retry và cache đã triển khai; hồi quy được kiểm tra bằng các bộ test hiện có, chưa thay thế E2E native.

## Bố cục và khả năng tiếp cận

- Giữ thiết kế Ocean Blue hiện có; chỉ đổi màu CTA cam và màu trạng thái để chữ trắng rõ hơn. Độ tương phản chữ trắng với Ocean Blue là 4.87:1, với cam mới là 5.23:1, đo bằng script contrast của dự án. Đây là kết quả cho các cặp màu này, không phải chứng nhận toàn ứng dụng.
- Thanh thao tác lịch trình cho xuống hàng thay vì ép chung một hàng; bộ chọn ngày có chiều cao tối thiểu 48. Kiểm thử ở chiều rộng 320 và chữ 200% cho hai ngôn ngữ không phát sinh overflow ở thanh thao tác.
- Admin bổ sung tên truy cập và autocomplete cho form xác thực; nút hiện mật khẩu tối thiểu 44×44. Giữ focus hiển thị và focus trap của form địa điểm.
- Quyết định thiết kế: giữ font, phân cấp và cấu trúc cũ để không thay đổi thói quen thao tác; dùng xuống hàng cho nhãn dài để giữ đầy đủ nội dung. ENERGY 1 / RHYTHM 1 / MOTION 1, không thêm hiệu ứng.

## Bằng chứng kiểm tra

| Kiểm tra | Kết quả và giới hạn |
| --- | --- |
| Flutter analyze | Không lỗi/cảnh báo ở lần kiểm tra cuối; xem kết quả chạy trong phiên thực hiện |
| Flutter test | 40 test, gồm đổi ngôn ngữ giữ input, fallback, chữ 200% và bảo vệ bản sửa sau lỗi lưu |
| Admin build | Qua TypeScript và Vite; có cảnh báo chunk JS lớn hơn 500 kB |
| Admin tests | 22 test, gồm timeout không tự gửi lại request ghi, giữ session và ngôn ngữ login/refresh |
| Browser trang xác thực | Đã chuyển Việt/Anh, nhập dữ liệu rồi đổi ngôn ngữ, kiểm tra Tab/focus và mô phỏng mất mạng. Không mất email khi lỗi, không tạo phiên giả |
| Browser màn nhỏ | 390×844, zoom CSS 200%: login/register không tràn ngang; Tab từ họ tên sang email; nút hiện mật khẩu đo 44×44 CSS px trước zoom |
| Browser form địa điểm | API fixture riêng có tài khoản/danh mục thử: đổi ngôn ngữ giữ tên đang nhập, category dùng nameEn, Escape hỏi bỏ sửa, hủy giữ dữ liệu, Shift+Tab không thoát dialog. Reload nhận ngôn ngữ fixture đã lưu. Không dùng fixture làm bằng chứng ghi DB thật |
| Android native | Chưa nghiệm thu: `adb devices` không có thiết bị, `emulator -list-avds` không có AVD |
| iOS / Flutter web | Chưa kiểm tra; không công bố hỗ trợ dựa trên lần chạy này |

## Trạng thái nghiệm thu

Mốc 13 chưa đóng nghiệm thu. Phần mã và hồi quy tự động đã thực hiện; còn cần kiểm tra trực tiếp Android với bàn phím thật, chữ lớn, talkback/focus, các trạng thái mạng và chuỗi tạo/sửa/lưu/mở lại chuyến. Admin cần bổ sung E2E với API/DB thật cho việc lưu hồ sơ và các form quản trị, cùng rà các thông báo động Việt/Anh. Không dùng widget test hoặc browser fixture thay các bằng chứng đó.

## Đọc tiếp

Ảnh hưởng tới giao diện quản trị được tổng hợp trong [thiết kế admin](admin-interface.md#các-trang-nghiệp-vụ). Các con số ở bảng kiểm tra là bằng chứng trước lần biên tập tài liệu, không có test/UI mới trong lần này.

Quay lại [mục lục báo cáo](../README.md).
