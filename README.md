# SmartTravel

Ứng dụng mobile gợi ý lộ trình du lịch tại Đà Nẵng.

## Cấu trúc

- `backend/`: Java 21 + Spring Boot REST API, MySQL và Flyway.
- `mobile/`: Flutter + Dart cho Android/iOS.
- `admin/`: React + TypeScript/Vite cho trang quản trị.
- `tasks/`: tài liệu PRD.

## Khởi chạy nhanh

1. Sao chép `.env.example` thành `.env` nếu cần thay đổi cấu hình.
2. Khởi động database: `docker compose up -d mysql`.
3. Chạy backend: `cd backend` rồi `mvn spring-boot:run`.
4. Chạy mobile: `cd mobile`, `flutter pub get`, rồi `flutter run`.
5. Chạy admin: `cd admin`, `npm install`, rồi `npm run dev`.

Health check backend: `GET http://localhost:8080/api/v1/health`.
