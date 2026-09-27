# SmartTravel — Kế hoạch tạo giao diện Mobile với Stitch (từng giai đoạn)

> **Mục đích:** Hướng dẫn từng bước sử dụng **Stitch** (v0.dev / bolt.new hoặc tương tự) để gen giao diện mobile cho SmartTravel, kết hợp **antislop + antislop-ui** để kiểm tra chất lượng từng trang trước khi sang trang tiếp.
>
> **Tài liệu tham chiếu:**
> - `tasks/prd-smarttravel.md` — yêu cầu sản phẩm
> - `tasks/DESIGN-DIRECTION.md` — hướng thiết kế
> - `tasks/DESIGN-SYSTEM.md` — design system tokens & components

---

## Cách đọc tài liệu này

Mỗi giai đoạn bao gồm:
1. **Trang cần tạo** — mô tả chính xác màn hình
2. **Prompt cho Stitch** — câu lệnh copy-paste vào Stitch để gen giao diện
3. **Checklist antislop** — danh sách kiểm tra bắt buộc sau khi Stitch gen xong

> **Quan trọng:** Hoàn thành checklist antislop cho mỗi giai đoạn TRƯỚC KHI chuyển sang giai đoạn tiếp theo.

---

## Quy trình antislop cho mỗi trang

Sau khi Stitch gen ra giao diện, copy code vào project và nhắn Cline:

```
/antislop
```

Khi antislop hỏi "during the work, or after it is done?", trả lời: **after it is done** (vì Stitch đã gen xong, giờ cần review).

Quy trình chi tiết:
1. **Paste code** từ Stitch vào đúng file trong project
2. **Khai báo Design Read**:
   ```
   Design Read: Mobile travel itinerary app for independent travelers,
   in a Coastal Breeze warm-neutral style,
   Dial: ENERGY 2 / RHYTHM 2 / MOTION 1
   ```
3. **Chạy Delivery Gate (4 blocks)** + **UI Skill Checklist** từ antislop-ui
4. **Đọc báo cáo PASS/FAIL** — sửa hết FAIL trước khi chuyển giai đoạn

---

## Giai đoạn 0: Thiết lập chung

### Prompt nền tảng (dùng lại cho MỌI giai đoạn)

Paste đoạn dưới đây vào đầu mỗi prompt Stitch như phần context chung (gọi tắt là **[BASE CONTEXT]**):

```
Bối cảnh dự án:
SmartTravel là ứng dụng mobile giúp khách du lịch tạo lịch trình Đà Nẵng theo ngày.
Nền tảng: Flutter mobile app (thiết kế cho phone 360px-430px).
Ngôn ngữ giao diện: Tiếng Việt (mặc định).

Design System:
- Font: Plus Jakarta Sans (fallback: Inter)
- Primary color: #0077B6 (Ocean Blue)
- Secondary/CTA color: #F77F00 (Sunset Coral)
- Background canvas: #F8F9FA
- Card surface: #FFFFFF
- Text primary: #0F172A
- Text secondary: #475569
- Text muted: #64748B
---

## Giai đoạn 1: Splash Screen & Onboarding

### Trang: Splash + 2-3 màn Onboarding giới thiệu app

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo giao diện mobile cho SmartTravel gồm:

1. Splash Screen:
   - Nền trắng #F8F9FA
   - Logo text "SmartTravel" ở giữa màn hình, font 28px Bold, màu #0077B6
   - Tagline nhỏ bên dưới: "Lên lịch trình Đà Nẵng trong 3 phút" font 14px #475569
   - Không có nút, chỉ là màn hình chờ

2. Onboarding (2 màn hình slide):
   Màn 1:
   - Illustration placeholder tối giản (icon bản đồ + pin, 120x120px, màu #0077B6 trên nền #EDF6F9)
   - Title: "Khám phá Đà Nẵng theo cách của bạn" (20px SemiBold #0F172A)
   - Mô tả: "Nhập sở thích, ngân sách và số ngày. Hệ thống tạo lịch trình phù hợp ngay lập tức." (14px Regular #475569, max width 280px, text-align center)
   - 2 dot indicator ở dưới (dot active #0077B6, dot inactive #E2E8F0)
   - Nút "Tiếp tục" sticky bottom (full-width, height 48px, bg #0077B6, text white, radius 10px)

   Màn 2:
   - Illustration placeholder (icon lịch trình timeline, 120x120px)
   - Title: "Chi phí minh bạch, tuyến đường thực tế"
   - Mô tả: "Xem ước tính chi phí theo ngày, quãng đường di chuyển và thời gian giữa các điểm trên bản đồ."
   - Nút "Bắt đầu ngay" (full-width, height 48px, bg #F77F00, text white, radius 10px)

Layout: single column, padding 16px, center-aligned content.
Không dùng gradient, glassmorphism hoặc animation phức tạp.
```

### Checklist antislop sau khi gen:
- [ ] Không có gradient xanh-tím hoặc glow trang trí?
- [ ] Không có em dash trong text?
- [ ] Nút bấm >= 44px chiều cao?
- [ ] Text contrast đạt WCAG AA (text #0F172A trên #F8F9FA)?
- [ ] Illustration là placeholder rõ ràng, không phải ảnh AI fabricated?
- [ ] Copy không chứa buzzword ("AI Powered", "Seamless", "Revolutionary")?

---

## Giai đoạn 2: Đăng ký & Đăng nhập

### Trang: Sign Up + Sign In (2 màn hình)

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo 2 màn hình mobile cho SmartTravel:

1. Màn Đăng ký (Sign Up):
   - Header: Text "Tạo tài khoản" (24px Bold #0F172A), subtitle "Bắt đầu lên kế hoạch chuyến đi Đà Nẵng" (14px #475569)
   - Form fields (mỗi field height 48px, border 1px #E2E8F0, radius 10px, padding 16px):
     + Email (placeholder: "email@example.com")
     + Mật khẩu (placeholder: "Tối thiểu 8 ký tự", có toggle icon hiện/ẩn)
     + Xác nhận mật khẩu
   - Nút "Đăng ký" (full-width, height 48px, bg #0077B6, text white 16px SemiBold, radius 10px)
   - Divider text: "hoặc" (12px #64748B, line #E2E8F0)
   - Link dưới cùng: "Đã có tài khoản? Đăng nhập" (14px, "Đăng nhập" màu #0077B6)

   Error state cho email field:
   - Border đổi thành #E76F51
   - Background nhẹ #FDF2F0
   - Helper text bên dưới: "Email không hợp lệ" (12px #E76F51)

2. Màn Đăng nhập (Sign In):
   - Header: "Đăng nhập" (24px Bold), subtitle "Chào mừng trở lại!"
   - Form: Email + Mật khẩu (cùng style trên)
   - Link "Quên mật khẩu?" (14px #0077B6, căn phải)
   - Nút "Đăng nhập" (full-width, bg #0077B6)
   - Link: "Chưa có tài khoản? Đăng ký"

Layout: padding 16px, khoảng cách giữa fields 12px, nút sticky bottom.
Focus state: border #0077B6 + shadow 0 0 0 3px rgba(0,119,182,0.25).
Không fake data, không avatar giả, không testimonial.
---

## Giai đoạn 3: Bottom Navigation + Trang chủ Khám phá

### Trang: Home / Explore screen với Bottom Nav Bar

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo màn hình Trang chủ / Khám phá cho SmartTravel mobile:

Bottom Navigation Bar (cố định dưới cùng):
- Height 64px, bg #FFFFFF, border-top 1px #E2E8F0, shadow 0px -2px 8px rgba(15,23,42,0.06)
- 4 tab: Khám phá (icon search, active), Tạo chuyến đi (icon map-pin), Lịch trình (icon folder), Hồ sơ (icon user)
- Active tab: icon + label màu #0077B6, có micro dot indicator trên icon
- Inactive tab: icon + label màu #64748B
- Label font: 11px Medium

Nội dung trang Khám phá:
- Top: Greeting "Xin chào!" (14px #475569) + tên user "Minh" (20px Bold #0F172A)
- Search bar: height 48px, bg #F1F5F9, border 1px #E2E8F0, radius 10px, icon search bên trái, placeholder "Tìm địa điểm tại Đà Nẵng..." (14px #64748B)

- Category filter chips (scroll ngang):
  + Chip items: "Tất cả", "Biển", "Văn hóa", "Ẩm thực", "Check-in", "Thiên nhiên"
  + Active chip: bg #0077B6, text white, radius 6px
  + Inactive chip: bg #FFFFFF, border 1px #E2E8F0, text #0F172A, radius 6px
  + Min height 36px, padding 8px 16px

- Section header: "Điểm đến nổi bật" (18px SemiBold #0F172A) + "Xem tất cả" link (#0077B6 14px)

- Destination card grid (2 columns, gap 12px):
  + Card: bg #FFFFFF, border 1px #E2E8F0, radius 16px, shadow 0px 2px 6px rgba(15,23,42,0.06)
  + Ảnh placeholder: ratio 4:3, bg #E2E8F0 với icon camera placeholder
  + Tên điểm: "Bán đảo Sơn Trà" (15px Medium #0F172A)
  + Category badge: "Thiên nhiên" (11px SemiBold #0077B6, bg #F0F9FF, radius 6px, padding 2px 8px)
  + Giá: "Miễn phí" hoặc "50.000 VNĐ" (12px Medium #475569)
  + Nút heart yêu thích: icon outline, 24x24px, touch target 44x44px

Padding: 16px, khoảng cách section 24px.
Dùng dữ liệu mẫu thật cho Đà Nẵng: Bán đảo Sơn Trà, Cầu Rồng, Bà Nà Hills, Bãi biển Mỹ Khê, Chùa Linh Ứng, Chợ Hàn.
```

### Checklist antislop sau khi gen:
- [ ] Bottom nav có đúng 4 tab, active state rõ ràng (không dùng glow)?
- [ ] Destination cards không đồng nhất hoàn toàn (có variation về giá/category)?
- [ ] Category chips: chỉ 1 chip active tại 1 thời điểm?
- [ ] Dữ liệu là tên địa điểm thật Đà Nẵng, không fabricated?
- [ ] Touch target icon heart >= 44px?
- [ ] Không có gradient xanh-tím trên search bar?
- [ ] Layout single-column flow, padding 16px nhất quán?

---

## Giai đoạn 4: Chi tiết điểm đến

### Trang: Destination Detail screen

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo màn hình Chi tiết điểm đến cho SmartTravel mobile:

Header image area:
- Ảnh placeholder full-width, height 240px, bg #E2E8F0
- Gradient overlay bottom: linear-gradient(180deg, rgba(15,23,42,0) 40%, rgba(15,23,42,0.75) 100%)
- Back button top-left: icon arrow-left, circle bg rgba(255,255,255,0.9), 40x40px
- Heart button top-right: icon heart outline, circle bg rgba(255,255,255,0.9), 40x40px

Content area (bg #F8F9FA, padding 16px):
- Title: "Bán đảo Sơn Trà" (24px Bold #0F172A)
- Category badge: "Thiên nhiên" (12px SemiBold, bg #F0F9FF, text #0077B6, radius 6px)
- Info row (3 items ngang, 12px Medium #475569, icon 16px):
  + 🕐 "06:00 - 18:00"
  + 💰 "Miễn phí"
  + 📍 "12 km từ trung tâm"

- Section "Mô tả" (16px SemiBold #0F172A):
  + Body text (14px Regular #475569, line-height 20px):
    "Bán đảo Sơn Trà nằm cách trung tâm Đà Nẵng khoảng 10km về phía đông bắc. Nơi đây có hệ sinh thái đa dạng với voọc chà vá chân nâu và nhiều bãi biển hoang sơ."

- Section "Thông tin chi tiết":
---

## Giai đoạn 5: Trip Creation Wizard (4 bước)

### Trang: Wizard Step 1/4 đến Step 4/4

### Prompt cho Stitch — Bước 1 & 2:

```
[BASE CONTEXT]

Tạo 2 màn hình Wizard tạo chuyến đi cho SmartTravel mobile:

Cấu trúc chung mỗi bước:
- Top bar: Back arrow trái, text "Bước X / 4" giữa (14px Medium #475569)
- Progress bar: height 4px, full-width, bg #E2E8F0, filled portion bg #0077B6
- Sticky bottom: Nút "Tiếp tục" (full-width, height 48px, bg #0077B6, text white, radius 10px)
  + Bước 1: disabled state (bg #E2E8F0, text #94A3B8) cho đến khi chọn ngày

Bước 1/4 - Thời gian chuyến đi:
- Title: "Bạn đi Đà Nẵng mấy ngày?" (20px SemiBold #0F172A)
- Subtitle: "Chọn số ngày cho chuyến đi" (14px #475569)
- Option cards (chọn 1, vertical stack, gap 12px):
  + Card: bg #FFFFFF, border 1px #E2E8F0, radius 16px, padding 16px, height auto
  + Selected card: border 2px #0077B6, bg #EDF6F9
  + Nội dung card: icon calendar (20px) + "2 ngày 1 đêm" (16px Medium #0F172A) + "Phù hợp đi cuối tuần" (12px #64748B)
  + Các option: "1 ngày", "2 ngày 1 đêm", "3 ngày 2 đêm", "4 ngày 3 đêm", "5-7 ngày"

Bước 2/4 - Ngân sách & nhóm:
- Title: "Ngân sách và số người" (20px SemiBold)
- Field "Ngân sách tổng" (input, height 48px, border #E2E8F0, radius 10px):
  + Prefix icon 💰, suffix text "VNĐ" (14px #64748B)
  + Placeholder: "Ví dụ: 3.000.000"
- Field "Số người" (stepper control):
  + Label "Số người đi cùng" (14px #475569)
  + Stepper: nút [-] [số] [+], giá trị mặc định "2", min 1 max 10
  + Nút [-][+]: circle 40px, border 1px #E2E8F0, icon 20px, touch target 44px

Padding 16px. Không gradient, không glow.
```

### Prompt cho Stitch — Bước 3 & 4:

```
[BASE CONTEXT]

Tiếp tục Wizard tạo chuyến đi SmartTravel (bước 3 và 4):

Cấu trúc chung giống giai đoạn trước (top bar "Bước X/4", progress bar, sticky nút bottom).

Bước 3/4 - Sở thích & cường độ:
- Title: "Bạn thích trải nghiệm gì?" (20px SemiBold)
- Multi-select chips (wrap, gap 8px):
  + Items: "Biển", "Văn hóa", "Ẩm thực", "Check-in", "Thiên nhiên", "Mua sắm", "Giải trí"
  + Unselected: bg #FFFFFF, border 1px #E2E8F0, text #0F172A, radius 6px, padding 8px 16px
  + Selected: bg #0077B6, border none, text white
  + Min height 36px

- Section "Nhịp độ tham quan" (16px SemiBold, margin-top 24px):
  + 2 radio-style option cards (gap 12px):
    - "Thư thả" + subtitle "2-3 điểm mỗi ngày, nhiều thời gian nghỉ" + icon sun
    - "Năng động" + subtitle "4-5 điểm mỗi ngày, tận dụng tối đa" + icon zap
  + Card style: bg white, border 1px #E2E8F0, radius 16px, padding 16px
  + Selected: border 2px #0077B6, bg #EDF6F9

Bước 4/4 - Nơi ở & ràng buộc:
- Title: "Thông tin bổ sung" (20px SemiBold)
- Field "Nơi lưu trú / Điểm xuất phát":
  + Input text, placeholder "Ví dụ: Khách sạn Novotel Đà Nẵng"
  + Helper text: "Hệ thống sẽ tối ưu tuyến đường từ nơi bạn ở" (12px #64748B)
- Field "Điểm muốn đến (không bắt buộc)":
  + Chip input area, placeholder "Tìm và thêm điểm bắt buộc..."
- Field "Phương tiện di chuyển" (single select chips):
  + "Xe máy", "Ô tô", "Taxi/Grab", "Đi bộ kết hợp"

- Sticky bottom: Nút "Tạo lịch trình" (bg #F77F00, text white, height 52px, radius 10px, font 16px SemiBold)

Padding 16px. Không animation phức tạp.
```

### Checklist antislop (cả 4 bước):
- [ ] Progress bar cập nhật chính xác (25%, 50%, 75%, 100%)?
- [ ] Option cards có rõ ràng selected vs unselected (border + bg thay đổi)?
- [ ] Nút "Tiếp tục" disabled khi chưa chọn gì ở bước 1?
- [ ] Stepper [-][+] có touch target >= 44px?
- [ ] Multi-select chips cho phép chọn nhiều (khác với radio)?
- [ ] Không có buzzword "AI Powered" hay "Seamless"?
- [ ] Text CTA cuối cùng cụ thể ("Tạo lịch trình"), không generic ("Get Started")?
- [ ] Dữ liệu placeholder thật (tên khách sạn Đà Nẵng thật)?

---

## Giai đoạn 6: AI Loading Screen (Đang tạo lịch trình)

### Trang: Loading overlay khi hệ thống đang sinh lịch trình

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo màn hình Loading tạo lịch trình cho SmartTravel mobile:

Full-screen overlay, bg #F8F9FA:
- Center: Icon compass placeholder (48x48px, màu #0077B6, viền #EDF6F9)
- Animated text carousel (thay đổi mỗi 2 giây, fade transition 250ms):
  + Dòng 1: "Đang phân tích sở thích và ngân sách..."
  + Dòng 2: "Đang tối ưu tuyến đường di chuyển..."
  + Dòng 3: "Đang kiểm tra giờ mở cửa các điểm đến..."
  + Font: 16px Medium #0F172A, text-align center, max-width 280px

- Progress bar ngang bên dưới text:
  + Height 4px, bg #E2E8F0, filled #0077B6, animate width từ 0% đến 90%
  + Radius pill (9999px)

---

## Giai đoạn 7: Kết quả lịch trình (Timeline Plan View)

### Trang: Generated Itinerary — Danh sách hoạt động theo ngày

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo màn hình Kết quả lịch trình (Plan View) cho SmartTravel mobile:

Top bar:
- Back arrow trái
- Title: "Đà Nẵng 3N2Đ" (18px SemiBold #0F172A)
- Icon bookmark (save) phải, 24px

Day Selector Ribbon (scroll ngang, sticky top):
- Chips: "Ngày 1", "Ngày 2", "Ngày 3"
- Active chip: bg #0077B6, text white, shadow 0px 2px 6px rgba(0,119,182,0.15)
- Inactive chip: bg #FFFFFF, border 1px #E2E8F0, text #0F172A
- Chip padding 8px 20px, radius 9999px, height 36px

Segmented View Switcher (dưới day chips):
- Container: bg #F1F5F9, radius 9999px, padding 4px
- 2 tabs: "Lịch trình" (active, icon list), "Bản đồ" (icon map)
- Active tab: bg #FFFFFF, shadow 0px 1px 2px rgba(15,23,42,0.04), text #0077B6 SemiBold
- Inactive tab: bg transparent, text #475569

Daily Summary Card (bg #FFFFFF, border 1px #E2E8F0, radius 16px, padding 12px 16px):
- 3 metrics ngang:
  + "Chi phí: 850.000 VNĐ" (14px Medium, icon wallet, badge "Ước tính" nhỏ)
  + "Quãng đường: 28 km" (14px Medium, icon navigation)
  + "Thời gian: 1h 45p" (14px Medium, icon clock)
- Budget health bar: height 6px, bg #E2E8F0, filled 65% #2A9D8F, radius pill

Timeline Activity List (vertical stack):
Card hoạt động 1:
- Left: Circle sequence badge "01" (bg #0077B6, text white, 28px diameter, font 13px Bold)
- Card content: bg #FFFFFF, border 1px #E2E8F0, radius 16px, padding 12px
  + Row 1: Ảnh thumbnail 64x64px (radius 10px, placeholder bg #E2E8F0) | Bên phải:
    - Title: "Bãi biển Mỹ Khê" (15px Medium #0F172A)
    - Category badge: "Biển" (11px, bg #F0F9FF, text #0077B6, radius 6px)
    - "08:00 - 10:00 · 2 giờ" (12px #64748B)
  + Row 2: "Chi phí: Miễn phí" (12px #475569)
  + Menu overflow: icon vertical dots top-right, touch target 44px

Travel Leg Connector (giữa card 1 và card 2):
- Vertical dashed line: 2px dashed #CBD5E1, height 32px
- Center pill badge: bg #FFFFFF, border 1px #CBD5E1, radius 9999px, padding 4px 12px
  + Text: "15 phút · 4.2 km" (12px Medium #64748B, icon car)

Card hoạt động 2:
- Sequence "02", Title: "Chùa Linh Ứng", Category: "Văn hóa"
- "10:15 - 11:45 · 1.5 giờ", "Chi phí: Miễn phí"

Card hoạt động 3:
- Sequence "03", Title: "Chợ Hàn", Category: "Ẩm thực"
- "12:00 - 13:00 · 1 giờ", "Chi phí: 150.000 VNĐ (Ước tính)"

Sticky bottom (bg #FFFFFF, border-top 1px #E2E8F0, padding 12px 16px):
- 2 nút: "Chỉnh sửa" (outline #0077B6, 48%) + "Lưu lịch trình" (bg #0077B6, white, 48%)

Dùng dữ liệu mẫu thật Đà Nẵng. Giá gắn "Ước tính" khi không chắc chắn.
```

### Checklist antislop:
- [ ] Sequence badges (01, 02, 03) rõ ràng, không glow?
- [ ] Travel leg connector hiển thị khoảng cách + thời gian thực?
- [ ] Badge "Ước tính" xuất hiện cạnh chi phí không chắc chắn?
- [ ] Budget health bar dùng đúng màu (#2A9D8F cho safe)?
- [ ] Cards KHÔNG đồng nhất 100% (giá khác nhau, category khác nhau)?
- [ ] Day chips chỉ 1 active, scroll ngang khi nhiều ngày?
- [ ] Menu overflow có touch target >= 44px?
- [ ] Dữ liệu là địa điểm thật Đà Nẵng?

---

## Giai đoạn 8: Bản đồ lịch trình (Map View)

### Trang: Itinerary Map View + Bottom Sheet preview

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo màn hình Bản đồ lịch trình cho SmartTravel mobile:

Giữ nguyên top bar + Day Selector + Segmented Switcher từ giai đoạn 7,
nhưng tab "Bản đồ" đang active.

Map area (chiếm phần lớn viewport):
- Map placeholder: bg #E8F4E8 (xanh lá nhạt gợi bản đồ), full-width
- 3 numbered markers trên map:
  + Marker style: circle 32px, bg #0077B6, text white Bold "1", "2", "3"
  + Shadow nhẹ 0px 2px 4px rgba(0,0,0,0.15)
- Polyline connecting markers: dashed line 3px #0077B6 opacity 0.6

Bottom Sheet (slide-up, peek state):
- Container: bg #FFFFFF, top radius 24px, shadow 0px -4px 12px rgba(15,23,42,0.08)
- Drag handle: center bar 40x4px, bg #CBD5E1, margin-top 8px
- Peek content (height ~140px):
  + Thumbnail ảnh 80x80px (radius 10px) bên trái
  + Bên phải:
    - Title: "Bãi biển Mỹ Khê" (16px SemiBold #0F172A)
    - Badge: "Biển" (11px, bg #F0F9FF, text #0077B6)
    - "08:00 - 10:00 · Miễn phí" (12px #475569)
  + 2 nút nhỏ ngang:
---

## Giai đoạn 9: Lịch trình đã lưu (My Trips)

### Trang: Danh sách lịch trình đã lưu + Empty State

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo màn hình "Lịch trình của tôi" cho SmartTravel mobile:

Dùng Bottom Nav với tab "Lịch trình" đang active (icon folder, màu #0077B6).

Top section:
- Title: "Lịch trình của tôi" (24px Bold #0F172A)
- Subtitle: "3 chuyến đi đã lưu" (14px #475569)

Trip cards (vertical stack, gap 12px):
Card 1:
- bg #FFFFFF, border 1px #E2E8F0, radius 16px, padding 16px
- Row 1: Title "Đà Nẵng 3N2Đ" (16px SemiBold #0F172A) + Status pill "Sắp tới" (11px SemiBold, bg #E6F4F1, text #2A9D8F, radius 9999px)
- Row 2: "15/07 - 17/07/2025 · 2 người" (12px #64748B)
- Row 3: "Tổng: 2.450.000 VNĐ (Ước tính)" (13px Medium #475569)
- Row 4: 3 icon actions ngang: Đổi tên (edit icon), Sao chép (copy icon), Xóa (trash icon, #E76F51)
  + Mỗi icon 20px, touch target 44x44px

Card 2:
- Title: "Cuối tuần Đà Nẵng" + Status "Nháp" (bg #FEF9E7, text #E9C46A)
- "20/08 - 21/08/2025 · 4 người"

Card 3:
- Title: "Đà Nẵng tháng 3" + Status "Đã đi" (bg #F1F5F9, text #64748B)
- "10/03 - 13/03/2025 · 2 người"

---

EMPTY STATE (khi chưa có lịch trình, tạo thêm 1 variant):
- Illustration placeholder: icon luggage/map đơn giản (120x120px, #0077B6 trên #EDF6F9)
- Title: "Bạn chưa có lịch trình nào" (18px SemiBold #0F172A)
- Description: "Tạo chuyến đi Đà Nẵng đầu tiên của bạn chỉ trong 3 phút" (14px #475569, max-width 260px, center)
- CTA: "Tạo lịch trình ngay" (bg #F77F00, text white, height 48px, radius 10px, full-width max 280px)

Padding 16px.
```

### Checklist antislop:
- [ ] 3 status pills có màu khác nhau (Sắp tới=green, Nháp=yellow, Đã đi=gray)?
- [ ] Badge "Ước tính" gắn với tổng chi phí?
- [ ] Empty state có illustration + title + description + CTA (đủ 4 phần)?
- [ ] Empty state CTA cụ thể ("Tạo lịch trình ngay"), không generic ("Get Started")?
- [ ] Icon actions (edit, copy, trash) có touch target >= 44px?
- [ ] Trash icon dùng màu #E76F51 để báo hiệu destructive?

---

## Giai đoạn 10: Hồ sơ & Sở thích

### Trang: Profile & Travel Preferences screen

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo màn hình Hồ sơ và Sở thích cho SmartTravel mobile:

Bottom Nav tab "Hồ sơ" active (icon user, #0077B6).

Profile header:
- Avatar circle placeholder 72px (bg #EDF6F9, icon user 32px #0077B6)
---

## Giai đoạn 11: Budget Detail & Overbudget Warning

### Trang: Chi tiết ngân sách + Cảnh báo vượt mức

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo màn hình Chi tiết ngân sách cho SmartTravel mobile:

Top bar: Back arrow + "Chi tiết ngân sách" (18px SemiBold)

Budget Overview Card (bg #FFFFFF, radius 16px, padding 16px):
- Title: "Ngân sách chuyến đi" (16px SemiBold)
- Big number: "2.450.000 / 3.000.000 VNĐ" (24px Bold #0F172A)
- Budget bar: height 8px, bg #E2E8F0, filled 82% #2A9D8F, radius pill
- Status text: "Còn lại: 550.000 VNĐ" (14px #2A9D8F)
- Badge: "Ước tính" (11px Bold, bg #EDF2F7, text #64748B)

Breakdown by category (list):
- Row: icon 🏛️ "Tham quan" → "350.000 VNĐ" (14px) → bar mini width 15%
- Row: icon 🍜 "Ăn uống" → "900.000 VNĐ" → bar 37%
- Row: icon 🚗 "Di chuyển" → "400.000 VNĐ" → bar 16%
- Row: icon 🏨 "Lưu trú" → "800.000 VNĐ" → bar 32%
Mỗi row: padding 12px, bg #FFFFFF, border-bottom 1px #E2E8F0
Bar mini: height 4px, radius pill, color #0077B6

Breakdown by day (accordion):
- "Ngày 1: 950.000 VNĐ" → expand to show items list
- "Ngày 2: 850.000 VNĐ"
- "Ngày 3: 650.000 VNĐ"

---

OVERBUDGET VARIANT (tạo thêm 1 version):
- Budget bar filled 115% → overflow visual, color #E76F51
- Status text: "Vượt ngân sách: 250.000 VNĐ" (14px Bold #E76F51)
- Warning card (bg #FDF2F0, border 1px #E76F51, radius 16px, padding 16px):
  + Icon ⚠️ + Title: "Lịch trình vượt ngân sách dự kiến" (14px SemiBold #0F172A)
  + Description: "Tổng chi phí ước tính vượt 250.000 VNĐ so với ngân sách đã cài đặt." (13px #475569)
  + 2 action buttons:
    - "Bỏ điểm đắt nhất" (outline #E76F51, height 40px, radius 10px)
    - "Tăng ngân sách" (outline #0077B6, height 40px, radius 10px)

Mọi giá trị đều gắn label "Ước tính" ở vị trí phù hợp.
```

### Checklist antislop:
- [ ] Budget bar đổi màu theo trạng thái (green safe, coral overbudget)?
- [ ] Overbudget warning dùng color + icon + text (multi-sensory)?
- [ ] Action buttons cụ thể ("Bỏ điểm đắt nhất"), không generic ("Fix")?
- [ ] Label "Ước tính" hiện ở mỗi nơi có giá trị ước tính?
- [ ] Category breakdown bars có tỷ lệ chính xác so với tổng?
- [ ] Không có fake statistics hoặc "99.9% Accurate"?

---

## Giai đoạn 12: Chỉnh sửa lịch trình (Edit Mode)

### Trang: Itinerary Edit Mode với reorder + swap + delete

### Prompt cho Stitch:

```
[BASE CONTEXT]

Tạo màn hình Chỉnh sửa lịch trình cho SmartTravel mobile:

Top bar: "Chỉnh sửa Ngày 1" (18px SemiBold) + nút "Xong" phải (14px #0077B6)

Editable Timeline (vertical stack, gap 8px):
Card hoạt động 1 (edit mode):
- bg #FFFFFF, border 2px dashed #0077B6, radius 16px, padding 12px
- Left: Drag handle icon (6 dots, #CBD5E1, 20px)
- Center: Sequence "01" + "Bãi biển Mỹ Khê" (15px Medium)
- Right controls stack:
  + Up arrow button (circle 36px, border 1px #E2E8F0, icon arrow-up, disabled cho first item: opacity 0.3)
  + Down arrow button (circle 36px, border 1px #E2E8F0, icon arrow-down)
  + Delete button (circle 36px, bg #FDF2F0, icon trash #E76F51)
  + Mỗi button touch target >= 44px (padding mở rộng)

Card hoạt động 2:
- "02" + "Chùa Linh Ứng"
- Up và Down arrows cả hai enabled

Card hoạt động 3:
- "03" + "Chợ Hàn"
- Down arrow disabled (last item)

"+ Thêm hoạt động" button (dashed outline, full-width):
- Border 2px dashed #CBD5E1, radius 16px, height 56px
- Icon + text "Thêm địa điểm vào Ngày 1" (14px #64748B)
- Center aligned

Delete confirmation dialog:
- Backdrop rgba(15,23,42,0.5) + blur 4px
- Card center: bg #FFFFFF, radius 16px, padding 24px, max-width 320px
- Title: "Xóa hoạt động?" (18px SemiBold)
- Description: "Bạn có chắc muốn xóa 'Chợ Hàn' khỏi lịch trình Ngày 1?" (14px #475569)
- 2 buttons: "Hủy" (ghost, #475569) + "Xóa" (bg #E76F51, white)

Không auto-reorder phức tạp, chỉ Up/Down button + drag handle.
```

### Checklist antislop:
- [ ] Up arrow disabled ở item đầu, Down disabled ở item cuối?
- [ ] Delete button dùng màu warning (bg #FDF2F0, icon #E76F51)?
- [ ] Delete confirmation dialog có backdrop blur thật?
- [ ] "Thêm hoạt động" dùng dashed border (visual cue "chưa có")?
- [ ] Drag handle icon nhỏ gọn, không glow?
- [ ] Dialog copy cụ thể (ghi tên hoạt động bị xóa)?

---

## Bảng tổng kết thứ tự thực hiện các màn hình

| Giai đoạn | Màn hình | Độ phức tạp | Phụ thuộc |
| --- | --- | --- | --- |
| 1 | Splash + Onboarding (2 màn) | Thấp | Không |
| 2 | Đăng ký & Đăng nhập (2 màn) | Thấp | Không |
| 3 | Trang chủ / Khám phá + Bottom Nav | Trung bình | GĐ 0 |
| 4 | Chi tiết điểm đến | Trung bình | GĐ 3 |
| 5 | Wizard tạo chuyến đi (4 bước) | Cao | GĐ 3 |
| 6 | AI Loading Screen | Thấp | GĐ 5 |
| 7 | Kết quả lịch trình (Timeline View) | Cao | GĐ 5, 6 |
| 8 | Bản đồ lịch trình (Map View) | Trung bình | GĐ 7 |
| 9 | Lịch trình đã lưu (My Trips + Empty State) | Trung bình | GĐ 3 |
| 10 | Hồ sơ & Sở thích | Trung bình | GĐ 3 |
| 11 | Chi tiết ngân sách + Cảnh báo | Trung bình | GĐ 7 |
| 12 | Chỉnh sửa lịch trình (Edit Mode) | Cao | GĐ 7 |

---

## Hướng dẫn kết hợp antislop khi triển khai

Khi bạn gen từng trang bằng Stitch và copy code vào dự án:

1. **Gợi ý lệnh antislop**: Trong Cline, chỉ cần gõ `/antislop` hoặc yêu cầu:
   > *"Hãy kiểm tra file [tên-file] theo Delivery Gate của antislop và antislop-ui."*

2. **Cấu trúc báo cáo mong đợi từ antislop**:
   - **PASS**: Các quy tắc đạt yêu cầu (ví dụ: color token chuẩn `#0077B6`, không có gradient tím, touch target >= 44px).
   - **FAIL**: Các điểm vi phạm (ví dụ: thiếu badge "Ước tính", dùng em dash, hoặc button height < 44px).
   - **Sửa ngay**: Sửa triệt để các mục FAIL trước khi chuyển sang giai đoạn kế tiếp.

- Tên: "Minh Nguyễn" (20px SemiBold #0F172A)
- Email: "minh.nguyen@email.com" (14px #475569)
- Nút "Chỉnh sửa hồ sơ" nhỏ (outline #0077B6, 12px, height 32px, radius 10px)

Settings sections (card group, bg #FFFFFF, border 1px #E2E8F0, radius 16px):

Section "Sở thích du lịch":
- Row: "Sở thích" → chips mini "Biển, Ẩm thực, Check-in" (bg #F0F9FF, text #0077B6)
- Row: "Nhịp độ" → "Thư thả (2-3 điểm/ngày)" (14px #0F172A)
- Row: "Ngân sách mặc định" → "3.000.000 VNĐ" (14px #0F172A)
- Row: "Phương tiện" → "Xe máy" (14px #0F172A)
- Mỗi row: padding 16px, border-bottom 1px #E2E8F0, icon chevron-right phải (16px #CBD5E1)

Section "Cài đặt":
- Row: "Ngôn ngữ" → toggle "Tiếng Việt / English" (segmented control nhỏ, active #0077B6)
- Row: "Thông báo" → toggle switch on/off

Section "Tài khoản":
- Row: "Đổi mật khẩu" → chevron
- Row: "Xóa tài khoản" → text #E76F51, icon trash
- Row: "Đăng xuất" → text #E76F51, icon log-out

Padding 16px, gap giữa sections 16px. Card radius 16px.
Không fake avatar photo, dùng placeholder icon.
```

### Checklist antislop:
- [ ] Avatar là placeholder icon, không phải ảnh người giả/AI?
- [ ] Row items có chevron-right chỉ khi tappable?
- [ ] Language toggle hoạt động (không dead control)?
- [ ] "Xóa tài khoản" và "Đăng xuất" dùng màu #E76F51 (destructive)?
- [ ] Preference values hiển thị dữ liệu thật (không "John Doe")?
- [ ] Mỗi row đủ tall cho 44px touch target?

    - "Xem chi tiết" (outline #0077B6, height 36px, radius 10px)
    - "Thay thế" (outline #E76F51, height 36px, radius 10px)

Khi map marker không load (fallback):
- Banner top: bg #FEF9E7, border 1px #E9C46A, radius 10px, padding 12px
- Icon warning + Text: "Đang dùng khoảng cách ước tính đường chim bay" (13px #0F172A)

Không dùng Google Maps thật, chỉ placeholder map.
```

### Checklist antislop:
- [ ] Map markers đánh số rõ ràng (1, 2, 3)?
- [ ] Bottom sheet có drag handle, không auto-expand toàn màn hình?
- [ ] Fallback banner hiển thị khi map lỗi (có mẫu)?
- [ ] Polyline nối các marker theo thứ tự?
- [ ] Nút "Thay thế" dùng màu warning (#E76F51), không destructive?
- [ ] Banner fallback dùng color + icon + text (multi-sensory)?

- Subtitle: "Thường mất dưới 10 giây" (12px #64748B, margin-top 16px)

Không dùng spinner phức tạp, gradient, hoặc animation liên tục vô hạn.
Animation phải dừng khi kết quả sẵn sàng (không loop vĩnh viễn).
```

### Checklist antislop:
- [ ] Animation có mục đích UX (thông báo tiến trình), không phải trang trí?
- [ ] Không có endless pulse/bounce loop?
- [ ] Text carousel thay đổi nội dung (không static), nhưng dừng khi xong?
- [ ] Không có glow, orb, gradient trang trí?
- [ ] Progress bar có endpoint rõ ràng?

  + Info card (bg #FFFFFF, border 1px #E2E8F0, radius 16px, padding 16px):
    | Label (12px #64748B) | Value (14px Medium #0F172A) |
    | Thời gian tham quan | 2 - 3 giờ (Ước tính) |
    | Chi phí ước tính | Miễn phí |
    | Loại hình | Thiên nhiên, Ngắm cảnh |
    | Phù hợp | Cặp đôi, Nhóm bạn, Gia đình |
  + Badge "Ước tính" nhỏ cạnh thời gian: bg #EDF2F7, text #64748B, 11px Bold

- Sticky bottom bar (bg #FFFFFF, border-top 1px #E2E8F0, padding 12px 16px):
  + 2 nút ngang:
    - "Xem trên bản đồ" (outline: border 1px #0077B6, text #0077B6, height 48px, radius 10px, width 48%)
    - "Thêm vào lịch trình" (bg #F77F00, text white, height 48px, radius 10px, width 48%)

Không dùng glassmorphism. Thông tin là dữ liệu mẫu thật.
```

### Checklist antislop sau khi gen:
- [ ] Badge "Ước tính" hiển thị cạnh thời gian tham quan?
- [ ] Gradient overlay trên ảnh phục vụ legibility (không trang trí)?
- [ ] Dữ liệu mô tả là nội dung thật về Sơn Trà, không AI fabricated?
- [ ] Back button và heart button có touch target >= 40px?
- [ ] Sticky bottom bar không che nội dung khi scroll?
- [ ] Info card có border subtle, không shadow quá nặng?

```

### Checklist antislop sau khi gen:
- [ ] Form fields có đủ 3 state: default, focus, error?
- [ ] Placeholder text thật ("email@example.com"), không phải "johndoe@example.com"?
- [ ] Không có icon sparkle/magic/robot trang trí?
- [ ] Password toggle icon có mục đích rõ ràng?
- [ ] Nút disabled state: bg #E2E8F0, text #94A3B8?
- [ ] Tất cả link đều có destination rõ ràng hoặc ghi TODO?

- Border subtle: #E2E8F0
- Success: #2A9D8F, Warning: #E9C46A, Error: #E76F51
- Border radius: buttons 10px, cards 16px, badges 6px, pills 9999px
- Shadows: cards 0px 2px 6px rgba(15,23,42,0.06)
- Min touch target: 44x44px
- Spacing base: 4px grid (8, 12, 16, 24, 32px)

Phong cách thiết kế:
- Light-first, card-based, warm off-white canvas
- Modern, clean, travel-oriented, friendly
- KHÔNG dùng dark mode, gradient xanh-tím, glassmorphism tràn lan
- KHÔNG dùng em dash (—) trong text
- Mọi giá tiền/thời gian ước tính đều gắn badge "Ước tính"
- Cỡ chữ body: 14-16px, heading: 18-28px
```
