# SmartTravel — UI/UX Assets & Screenshots Directory

Thư mục này được tổ chức thành 2 phân hệ chính (**Admin** và **User App**) để lưu trữ ảnh chụp màn hình (screenshots), ảnh stitched ghép màn hình và các tài sản thiết kế UI/UX theo chuẩn hệ thống.

---

## Cấu trúc Thư mục Chi tiết

```text
ui-ux/
├── README.md                                 # Tài liệu cấu trúc & Hướng dẫn
├── screenshots/                              # Ảnh chụp tổng hợp & stitched showcase
│   ├── admin/                                # Screenshots ghép màn hình Admin
│   └── user/                                 # Screenshots ghép màn hình User App
│
├── admin/                                    # GIAO DIỆN HỆ THỐNG SMARTTRAVEL ADMIN
│   ├── 01-dashboard/                         # 1. Tổng quan Dashboard
│   ├── 02-destinations/                      # 2. Quản lý Địa điểm Đà Nẵng (List & Drawer Form)
│   ├── 03-categories/                        # 3. Quản lý Danh mục
│   ├── 04-users/                             # 4. Quản lý Người dùng & Khóa tài khoản
│   └── 05-audit-logs/                        # 5. Nhật ký Audit Hệ thống & JSON Diff Drawer
│
└── user/                                     # GIAO DIỆN NGHỆ CỤC NGUYÊN BẢN DU KHÁCH (USER APP)
    ├── 01-splash-onboarding/                 # 1. Màn hình Chào mừng (Splash & Onboarding)
    ├── 02-login-register-forgot-password/    # 2. Đăng nhập, Đăng ký & Quên mật khẩu
    ├── 03-home-discover/                     # 3. Trang chủ / Khám phá địa điểm Đà Nẵng
    ├── 04-trip-wizard-4steps/                # 4. Wizard Tạo chuyến đi AI (4 bước)
    ├── 05-timeline-result/                   # 5. Kết quả lịch trình AI (Timeline View)
    ├── 06-my-trips/                          # 6. Danh sách lịch trình đã lưu (My Trips)
    ├── 07-trip-details/                      # 7. Chi tiết lịch trình & Bản đồ lộ trình
    ├── 08-profile-preferences/               # 8. Hồ sơ cá nhân & Thẻ sở thích (Profile & Preferences)
    ├── 09-budget-detail/                     # 9. Chi tiết phân bổ ngân sách chuyến đi (Budget Detail)
    └── 10-edit-itinerary/                    # 10. Chỉnh sửa & Sắp xếp lại lịch trình (Edit Mode)
```

---

## Chuẩn Nhận diện Visual Identity

- **Coastal Breeze Admin (Admin System):**
  - Colors: `#0077B6` (Primary Blue), `#F77F00` (Sunlit Accent), `#EDF6F9` (Surface), `#2A9D8F` (Active), `#E76F51` (Locked)
  - Fonts: `Plus Jakarta Sans` + `JetBrains Mono`

- **SmartTravel Mobile App (User App):**
  - Light & Clean UX, card-based components, 100% SVG Vector Icons, chuẩn phản hồi haptic & micro-interactions.

