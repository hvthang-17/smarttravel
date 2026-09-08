# SmartTravel

MVP giao diện web cho ứng dụng gợi ý lộ trình du lịch cá nhân hóa.

## Chạy dự án

```bash
npm install
npm run dev
```

Mở địa chỉ Vite hiển thị trong terminal. Kiểm tra bản production bằng:

```bash
npm run build
npm run preview
```

## Hiện có

- Form nhập điểm đến, số ngày và sở thích.
- Bộ lọc địa điểm theo nhóm trải nghiệm.
- Gợi ý lịch trình mẫu và cuộn tới kết quả sau khi tạo.
- Thiết kế responsive cho desktop và mobile.
- Dữ liệu mẫu tập trung tại Đà Nẵng trong `src/data.ts`.

Đây là lớp giao diện MVP; bước tiếp theo có thể thay dữ liệu mẫu bằng API bản đồ, cơ sở dữ liệu địa điểm và dịch vụ tối ưu tuyến đường.
