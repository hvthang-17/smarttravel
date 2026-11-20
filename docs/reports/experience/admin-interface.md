# Giao diện quản trị: thiết kế và kiểm chứng

Báo cáo này gộp hai đợt cải tiến: khung giao diện và nội dung từng trang. Thiết kế đổi bố cục/chữ/màu/focus, giữ API, quyền và logic nghiệp vụ.

| Thông tin | Nội dung |
| --- | --- |
| Phạm vi | Khung admin, bảy trang nghiệp vụ và form |
| Công việc liên quan | Cải tiến UI sau Mốc 13 |
| Tính chất báo cáo | Biên tập lại ngày 16/11/2026 từ các kết quả đã ghi nhận; không chạy kiểm thử mới |

## Định hướng chung

| Thành phần | Quyết định và mục đích |
| --- | --- |
| Điều hướng | Xanh biển sâu #073E51, tạo nhận diện gắn với Đà Nẵng và tách công cụ khỏi dữ liệu |
| Thao tác | Ocean Blue #0077B6; không thêm chỉ số/biểu đồ để trang trí |
| Nội dung | Nền #F3F7F9, bề mặt trắng, chữ #173442, viền #D5E2E8 |
| Chữ | Bahnschrift cho tiêu đề trên Windows, Segoe UI cho nội dung/dự phòng tiếng Việt; tabular numerals để so sánh số |
| Nhịp trang | Căn trái, ưu tiên bảng/bộ lọc; card dành cho dữ liệu cần nhận diện hoặc đọc sâu |
| Chuyển động | ENERGY 1 / RHYTHM 1 / MOTION 1; phản hồi thao tác, tôn trọng reduced motion |

## Khung giao diện

Sidebar biển sâu, vùng làm việc sáng, toolbar co giãn theo màn hình. Thống kê xuống hai cột ở màn nhỏ; bảng và vùng cuộn tách rõ. Trang xác thực ở đợt đầu giảm gradient/bóng trang trí, giữ ảnh và chức năng có sẵn. File admin-design.css chứa token/shell.

## Các trang nghiệp vụ

| Trang | Thay đổi chính |
| --- | --- |
| Tổng quan | Tách số liệu hiện tại với hoạt động theo kỳ; đưa bộ chọn kỳ cạnh tiêu đề, giữ định nghĩa chỉ số |
| Địa điểm | Tiêu đề/phân cấp/bảng/bộ lọc thống nhất; giữ các thao tác và form hiện có |
| Danh mục | Thẻ gọn hơn; có ảnh thì dùng ảnh, thiếu ảnh thì không tạo gradient trang trí; nhãn trạng thái dễ đọc |
| Người dùng | Thu gọn thống kê trên màn nhỏ; sửa ô tìm kiếm vượt khung, phân trang rõ hơn; giữ một nút thêm ở tiêu đề |
| Lịch trình | Bảng, khoảng cách hàng, trạng thái lưu và bộ lọc rõ hơn; vẫn chỉ đọc |
| Kiểm duyệt | Phân biệt điểm, ngày, trạng thái và lý do báo cáo; nội dung là trọng tâm, nút ẩn/hiện riêng |
| Nhật ký | Lọc có nhãn dễ hiểu, chi tiết trình bày dạng key/value; tên hành động/đối tượng hiển thị dễ đọc nhưng value gửi API giữ nguyên |

AdminPageHeader và admin-pages.css thống nhất tiêu đề, trạng thái, bảng/bộ lọc. operations.css và reviews.css giữ đặc điểm riêng của trang vận hành/kiểm duyệt. Form user/category có focus ban đầu, giữ Tab trong dialog và trả focus khi đóng; form địa điểm giữ cơ chế focus đã có. Lỗi tải danh mục không đồng thời hiển thị thông báo “chưa có danh mục”.

## Bằng chứng đã ghi nhận

| Kiểm tra | Kết quả và giới hạn |
| --- | --- |
| Build và test | Hai đợt ghi admin build đạt và 22 test; vẫn có cảnh báo chunk JS >500 kB. Không cộng thành 44 test |
| Desktop/màn nhỏ | Bảy trang ở 1440×1000 và 390×844 không tràn ngang toàn trang trong ca fixture; bảng vận hành cuộn trong khung riêng |
| Lỗi/rỗng | Kiểm tra cả bảy trang bằng API fixture; không ghi DB thật |
| Hợp đồng thao tác | Audit gửi UPDATE/DESTINATION khi chọn nhãn Việt; review gửi HIDDEN; dashboard gửi days=30 |
| Bàn phím | User form focus input, giữ Tab, Escape đóng và trả focus; category form giữ Tab; form địa điểm giữ focus/đóng khi chưa sửa |
| Locale/chữ lớn | Review ở locale Anh, zoom CSS 200% không tràn ngang toàn trang trong ca được kiểm tra |

Các đo tương phản: chữ điều hướng #D2E5EC/#073E51 đạt 8.89:1; xanh sâu/trắng 11.56:1; chữ phụ #486170/trắng 6.52:1; #176347/#EDF8F4 đạt 6.64:1; cảnh báo #8C5700/#FFF7E7 đạt 5.67:1; trắng/Ocean Blue 4.87:1. Đây là các cặp đã đo, không phải chứng nhận accessibility toàn bộ sản phẩm.

## Tình trạng ảnh đính kèm

Các báo cáo trước từng dẫn ảnh kiểm thử tại gốc repo và reports/evidence/admin-pages. Những file đó không có trong workspace khi biên tập tài liệu lần này; đã bỏ liên kết hỏng. Kết quả browser ở trên là ghi nhận của đợt trước, hiện không có ảnh kèm để người đọc đối chiếu. Không thay bằng ảnh thiết kế khác hoặc coi số liệu minh họa là dữ liệu vận hành.

## Giới hạn

Không có lần chạy build/test/browser mới trong lần biên tập. Fixture UI không thay E2E API/DB thật hoặc native Android. Đợt cải tiến bảy trang không sửa mobile/backend và không đổi chức năng trang đăng nhập. Tiến độ phát hành xem [trạng thái yêu cầu](../../planning/requirements-status.md).

Quay lại [mục lục báo cáo](../README.md).
