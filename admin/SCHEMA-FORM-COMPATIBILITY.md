# Form địa điểm và schema mới

Cập nhật CAT/AUD (16/11/2026): [báo cáo](../docs/reports/features/catalog-and-discovery.md#quản-trị-catalog) bổ sung form danh mục, gỡ metadata thành NULL, upload/giới hạn ảnh, giữ danh mục ẩn hiện tại và DELETE thành ẩn có thể khôi phục. Build và 19 test admin đạt; đã kiểm tra với backend/database riêng. Những mô tả policy cũ bên dưới là lịch sử.

Cập nhật 16/11/2026. Phạm vi: form thêm địa điểm, form sửa dùng chung và request bật/tắt trạng thái. Không thay backend, migration hoặc dữ liệu phát triển.

## Hành vi

- Thêm nameEn, descriptionEn, visitDurationMinutes. Thời lượng gợi ý theo danh mục: BEACH 90, FOOD 60, CULTURE 90, CHECKIN 45, CAFE 60, NIGHTLIFE 120 phút; người quản trị có thể sửa. Đổi danh mục không ghi đè thời lượng tùy chỉnh.
- Chỉ chọn danh mục ACTIVE trong phạm vi, không có HOTEL. Không tạo tên danh mục dự phòng khi API không trả danh mục; hiển thị trạng thái và khóa nút tạo. Danh mục của bản ghi sửa không còn khả dụng phải được chọn lại rõ ràng, không tự chuyển sang danh mục đầu tiên.
- Lịch tuần gửi openingSchedule với schema_version=1, timezone=Asia/Ho_Chi_Minh và đủ khóa ngày 1–7. Có chưa rõ, đóng cửa, mở cả ngày hoặc nhiều ca; sao chép T2 sang cả tuần, thêm/xóa ca. Kiểm tra ca chồng lấn, mốc 24:00, thời gian qua đêm cần tách hai ngày.
- Giá và thống kê Google để trống khi chưa biết, không tự đổi thành 0. Giá bằng 0 là miễn phí. Payload dùng googleRating/googleReviewCount, điểm 1–5 với tối đa một số thập phân; số lượt nguyên không âm. Không nhập appRating/appReviewCount vì backend tổng hợp từ review nội bộ.
- Giá tối thiểu không lớn hơn giá tối đa; đơn vị mỗi người/lần ghé. Kiểm tra tên, tọa độ, độ dài các trường và số nguyên theo DTO/schema. Tọa độ ban đầu để trống, tránh vô tình lưu tọa độ trung tâm thành vị trí thực tế.
- Request PUT bật/tắt trạng thái giữ openingSchedule, bản dịch và visitDurationMinutes để không xóa các trường mới.
- Có nhãn liên kết input, lỗi được thông báo và nhận focus, giữ focus trong dialog, Escape đóng khi không lưu, trạng thái đang lưu chống gửi lặp.

## Kiểm chứng

- npm run build: đạt sau thay đổi cuối.
- npm run test:destinations: 8/8 đạt (Node 24.19.0, không thêm thư viện).
- npm run test:security: 6/6 đạt.
- Trình duyệt với API giả lập: chặn ca chồng lấn/giá đảo ngược, khôi phục form sửa và xác nhận payload không còn giờ tự do/rating mặc định 0.
- Trình duyệt với backend thật: Vite 18183, backend 18084, MySQL riêng 13316/smarttravel_test. Tạo thành công trả 201, GET lại giữ hai ca/ngày, Chủ nhật đóng cửa, bản dịch/thời lượng; giá/rating chưa biết là NULL. Sau sửa và bật/tắt, GET xác nhận các trường vẫn được giữ. Bản ghi kiểm thử id=299 chỉ nằm trong database riêng.
- Kiểm tra màn hình 390×844: modal/body rộng 358px, scrollWidth=clientWidth; ảnh chụp kiểm tra trực quan. Tab/Shift+Tab quay vòng trong dialog, Escape đóng, thêm/xóa ca và các trạng thái ngày có thao tác thật.
- Các server kiểm thử đã dừng, thông tin đăng nhập và route kiểm thử đã xóa khỏi browser. Không kiểm thử upload ảnh/geocoding bên ngoài trong công việc này; giữ luồng hiện hữu.

## Delivery gate cho phần form đã chỉnh

- Hard Gate PASS: build và 14 test đạt; thao tác lưu qua backend thật thành công; không tràn ngang ở 390px; không tạo asset hoặc dữ liệu quảng cáo. Tương phản các cặp màu chữ mới đạt 7.24:1, 5.93:1 và 7.60:1 qua contrast-check.py.
- Purpose Gate PASS: giữ bố cục quản trị và bảng màu Ocean Blue của dự án; nền section phân nhóm dữ liệu nhập, màu nhấn dành cho thao tác, màu đỏ dành cho lỗi. Không thêm hiệu ứng/trang trí hoặc hệ icon mới.
- Liveliness PASS: kế thừa hướng form quản trị SmartTravel, ENERGY 1 / RHYTHM 2 / MOTION 1; ưu tiên tiêu đề và nút tạo, khoảng cách tách nhóm dữ liệu, giữ ngôn ngữ tiếng Việt và nhấn xanh cho thao tác. Không đổi hướng thiết kế toàn ứng dụng.
- Craftsmanship PASS: trạng thái rỗng/đang lưu/lỗi, bàn phím và màn hình nhỏ đã kiểm tra; payload bám DTO/schema; kết quả kiểm chứng ghi rõ database cô lập thay vì nhận là dữ liệu vận hành.

Giới hạn kiểm chứng backend thật: MySQL cục bộ 9.2, chưa chạy lại trên MySQL 8.4. Người dùng cần tải lại admin để nhận bundle mới. Các số liệu seed, review nội bộ và dịch vụ ảnh không được sửa trong lần đồng bộ form này.
