# SmartTravel — Visual & UX Design Direction Document

> **Document Version:** 1.0  
> **Status:** Approved  
> **Product Reference:** `tasks/prd-smarttravel.md`  
> **Target Platform:** Mobile App (Flutter for iOS/Android) & Web Admin Dashboard (React + TypeScript)

---

## 1. Product Design Philosophy

SmartTravel is designed around the core concept of **"Coastal Breeze & Urban Pulse" (Làn Gió Biển & Nhịp Sống Đô Thị Đà Nẵng)**. It bridges the natural coastal tranquility of Da Nang (My Khe beach, Son Tra peninsula) with its modern urban vibrancy (Dragon Bridge, Marble Mountains, night markets).

The fundamental design philosophy rests on three core pillars:
* **Speed to Value:** Delivering a complete, tailored day-by-day travel plan in under 3 minutes with minimal user friction.
* **Spatial & Financial Realism:** Eliminating "fantasy itineraries" by grounding plans in real-world map routes, accurate travel times, opening hours, and transparent budget calculations.
* **Tactile Confidence:** Providing explicit visual feedback, clear labels, dual timeline/map views, and simple editing mechanisms so users feel in total control of their trip.

---

## 2. Target Users & Design Personas

### P1 — Minh (Domestic Independent Traveler)
* **Demographics & Device:** 24 years old, Android user, traveling for a 2-day weekend with friends.
* **Behavior & Needs:** Budget-conscious, prioritizes street food, beaches, and scenic photo spots.
* **Design Implication:** Demands high-speed wizard inputs, instant budget tracking, minimal steps, and quick visual scanning of activity cards.

### P2 — Emma (International First-Time Traveler)
* **Demographics & Device:** 31 years old, iPhone user, 4-day trip with her partner.
* **Behavior & Needs:** Requires English UI, clear geographic context, map polylines, balanced daily pacing (culture, food, relaxation), and price estimations converted into understandable VND units.
* **Design Implication:** Requires flawless bilingual layout adaptability, explicit travel legs between destinations, and spatial clarity via map markers.

### P3 — Lan (Content Administrator)
* **Demographics & Device:** Project team administrator using a desktop browser.
* **Behavior & Needs:** Curates destination data, verifies prices and operating hours, manages user account statuses.
* **Design Implication:** Prefers dense data tables, fast inline actions, robust filtering, clear status toggles, and multi-column editing drawers.

---

## 3. Design Principles

1. **Effortless Speed (< 3 Minute Goal):** Keep inputs simple. Use sensible defaults based on user preferences to eliminate unnecessary wizard steps.
2. **Honest Realism:** Never hide limitations. Distinguish verified costs from estimates. Alert users immediately if budget thresholds are exceeded or map APIs revert to straight-line distance.
3. **Dual-Mode Harmony:** Allow instant, zero-friction switching between **Chronological Timeline View** and **Interactive Map View** while preserving the current active day and selected item.
4. **Progressive Disclosure:** Present high-level daily totals (cost, distance, duration) upfront, allowing users to drill down into activity details or route legs on demand.
5. **Universal Accessibility:** Ensure full support for Vietnamese tone marks and English text scaling, high-contrast text, 44px touch targets, and colorblind-safe budget alerts.

---

## 4. Visual Personality

* **Modern:** Clean typography, subtle elevation shadows, rounded geometry (12px–16px card radiuses).
* **Clean & Spacious:** Generous white space, uncluttered card layouts, clear structural dividers.
* **Travel-Oriented:** Inspired by Da Nang's natural elements — sea blues, sunlit sand tones, and tropical warmth.
* **Friendly & Approachable:** Soft rounded corners, warm neutral canvases, welcoming empty states.
* **Practical & Trustworthy:** No gimmicky dark-mode neon glows or generic purple AI gradients. Solid data presentation, legible metric badges, and clear currency labels.

---

## 5. Design Style

SmartTravel follows a **Light-First, Card-Based Tactile Design System**:
* **Canvas:** Warm off-white background (`#F8F9FA`) to reduce screen glare during outdoor travel.
* **Surfaces:** Elevated white cards (`#FFFFFF`) with subtle 1px neutral borders (`#E2E8F0`) and soft ambient drop shadows (`0px 2px 8px rgba(15, 23, 42, 0.06)`).
* **Corner Radius Scale:**
  * Small Badges & Chips: `6px` – `8px`
  * Action Buttons & Form Controls: `10px` – `12px`
  * Content Cards & Bottom Sheets: `16px` – `20px`
* **Node Elements:** Timeline sequence markers use solid filled circular badges connected by vertical dashed track lines.


---

## 6. Color Direction

### Palette Architecture & Tokens

| Token Name | Hex Code | Role / Usage |
| --- | --- | --- |
| `color-primary` | `#0077B6` | Primary brand accent: headers, active tabs, main action buttons, active route lines |
| `color-primary-hover` | `#0096C7` | Interactive hover/pressed state for primary controls |
| `color-secondary` | `#F77F00` | Secondary accent: primary CTAs ("Tạo lịch trình"), callouts, primary map pins |
| `color-secondary-hover` | `#E76F51` | Interactive state for secondary actions |
| `color-bg-canvas` | `#F8F9FA` | App workspace background |
| `color-surface-card` | `#FFFFFF` | Card & modal background |
| `color-border-subtle` | `#E2E8F0` | Card borders, dividers, subtle outlines |
| `color-text-primary` | `#0F172A` | High contrast body text, headlines, main titles |
| `color-text-secondary` | `#475569` | Subtitles, secondary descriptions, metadata |
| `color-text-muted` | `#64748B` | Captions, travel leg units, disabled labels |

### Semantic Status Palette (Budget & Systems)

| Token Name | Hex Code | Usage |
| --- | --- | --- |
| `color-status-success` | `#2A9D8F` | Budget within limit, verified data, saved status |
| `color-status-warning` | `#E9C46A` | Approaching budget threshold (≥ 85%), missing opening hours alert |
| `color-status-danger` | `#E76F51` | Overbudget alert, missing required fields, blocked account status |
| `color-badge-estimate` | `#EDF2F7` | Background badge for "Ước tính" (Estimated) tag |

---

## 7. Typography Direction

### Typeface Choice
* **Primary Typeface:** **Plus Jakarta Sans** (Alternative: **Inter**)
* **Rationale:** Exceptional legibility on mobile viewports, geometric aesthetic, complete support for Vietnamese tone diacritics (`ê`, `ơ`, `ư`, `ầ`, `ẵ`, `ố`), and strong numerical alignment for prices and times.

### Type Scale & Hierarchy

| Level | Size | Weight | Line Height | Usage |
| --- | --- | --- | --- | --- |
| **Display Header** | 24px – 28px | Bold (700) | 1.2 | Screen titles, wizard key steps |
| **Section Title** | 18px – 20px | SemiBold (600) | 1.3 | Day titles, card titles, sheet headers |
| **Card Subtitle** | 15px – 16px | Medium (500) | 1.4 | Place names, key metrics |
| **Body Regular** | 14px | Regular (400) | 1.5 | Place descriptions, notes, general text |
| **Caption / Label** | 12px – 13px | Medium (500) | 1.4 | Category tags, travel leg pills, status badges |
| **Micro Tag** | 11px | Bold (700) | 1.2 | Uppercase estimate tags (`ƯỚC TÍNH`) |

---

## 8. Layout Philosophy

### Mobile Layout Principles (360px – 430px Viewports)
* **Single-Column Stack:** Clean vertical rhythm with 16px edge padding.
* **Sticky Control Ribbons:** Day selector tabs and Plan/Map view switcher remain pinned near the top during scroll.
* **Bottom Sheet Drawers:** Detail previews and quick edit controls rise from the bottom to preserve map context.

### Responsive / Tablet / Desktop Principles (768px+ & Admin Web)
* **Dual-Pane Workspace (Itinerary View):**
  * **Left Panel (40% width, min 380px):** Chronological Timeline, Daily Summary, Edit & Reorder controls.
  * **Right Panel (60% width):** Sticky interactive map displaying active markers and route polylines.
* **Admin Web Grid:** Fixed left collapsible sidebar (240px wide), top breadcrumb bar (64px high), and multi-column responsive data table workspace.

---

## 9. Navigation Philosophy

### Mobile App Navigation Structure
1. **Persistent Bottom Navigation Bar (4 Primary Tabs):**
   * 🔍 **Khám phá (Explore):** Search, filters, category cards, place details.
   * 🗺️ **Tạo chuyến đi (Plan):** Trip creation wizard & recommendation generator.
   * 📁 **Lịch trình (My Trips):** Active, saved, and past itineraries.
   * 👤 **Hồ sơ (Profile):** Preferences, language switcher (VI/EN), account details.
2. **Trip Wizard Progression:**
   * Top step progress bar (Step 1 of 4).
   * Explicit `Quay lại` (Back) button at top left; `Tiếp tục` (Next) sticky button at bottom right.
3. **Itinerary Navigation:**
   * Top Day Selector Chips (`Ngày 1`, `Ngày 2`, `Ngày 3`, `+ Thêm ngày`).
   * Segmented View Control: `[ 📋 Lịch trình | 🗺️ Bản đồ ]`.

### Admin Web Dashboard Navigation
* Left vertical collapsible navigation sidebar with active indicator pill.
* Top bar breadcrumbs (e.g. `Admin / Địa điểm / Chỉnh sửa #104`).

---

## 10. Component Philosophy

### Key UI Components Architecture

1. **Timeline Activity Card:**
   * Left: Sequence number circle (`01`, `02`) + category icon badge.
   * Center: Destination photo thumbnail, title, operating hours badge, stay duration tag (`1.5 giờ`), estimated price (`50.000 VNĐ`).
   * Right: Action overflow menu button (`⋮`) for edit, swap, or delete.
2. **Travel Leg Connector Badge:**
   * Visual vertical dashed track line connecting card nodes.
   * Center Pill Badge: `🚗 15 phút • 4.2 km` with light grey outline.
3. **Budget Health Meter:**
   * Visual progress bar comparing estimated trip total to user's max budget threshold.
   * Dynamic states:
     * **Green:** Within budget.
     * **Yellow:** Approaching limit (85% to 99%).
     * **Coral Red + Alert Banner:** Exceeded budget (includes amount over limit).
4. **Segmented Control Switcher:**
   * Pill-style toggle container (`#F1F5F9`) with active white floating indicator card.
5. **Slide-Up Bottom Sheet:**
   * Drag handle pill at top, destination cover image, place title, category pill, opening hours, estimated cost, and dual CTA buttons (`Thêm vào lịch trình` / `Xem chi tiết`).

---

## 11. Image and Illustration Direction

* **Destination Imagery:**
  * High-resolution, real photos of Da Nang destinations.
  * Aspect Ratios: 16:9 for detail headers; 1:1 or 4:3 for list thumbnails.
  * Subtle gradient overlay at bottom of images to guarantee text legibility when text overlays photo headers.
* **Iconography:**
  * Clean, consistent 2px stroke line icons (Feather / Lucide style).
  * Explicit icons for travel categories: 🏖️ Beach, 🏛️ Culture, 🍜 Food, 📸 Instagram check-in, 🏨 Hotel, 🚗 Transport.
* **Empty State Illustrations:**
  * Minimalist, soft-colored spot illustrations incorporating beach, map, and travel motifs in `#EDF6F9` and `#0077B6` accents.

---

## 12. Interaction Principles

* **Direct Feedback:** Tap actions on buttons, chips, and cards provide immediate visual press state response (scale 0.98 or subtle shade shift).
* **Tactile Editing:** Activities can be reordered using simple Up/Down arrow buttons (for accessible tapping) or drag handles.
* **Single-Tap View Switching:** Switching between Timeline List and Map View must occur instantly without resetting scroll position or reloading page data.
* **Recalculation Transparency:** Modifying an activity (adding, deleting, or swapping) triggers a brief highlight effect on the daily summary bar as totals update.

---

## 13. Motion Principles

* **Transition Durations:**
  * Micro-interactions (Button presses, chip toggles): `150ms ease-out`
  * Tab & View Transitions: `250ms ease-in-out`
  * Bottom Sheet Slide & Modal Popups: `300ms cubic-bezier(0.16, 1, 0.3, 1)`
* **Functional Animations:**
  * **Budget Meter Fill:** Smooth width transition when budget total changes.
  * **Reorder Slide:** Timeline cards smoothly slide into their new vertical position when moved.
* **Reduced Motion:** If system `prefers-reduced-motion` is active, disable all spatial slide transitions and replace with simple opacity fades.

---

## 14. Responsive Principles

* **Breakpoints:**
  * Mobile: `< 600px` (Default single-column stack).
  * Tablet: `600px – 1023px` (Adaptive 2-column card grid or stack with bottom drawer).
  * Desktop / Web: `≥ 1024px` (Dual-pane side-by-side timeline and sticky map view).
* **Fluid Geometry:** Use flexible container padding (`16px` on mobile, `24px` on tablet, `32px` on desktop) rather than fixed pixel widths.

---

## 15. Accessibility Principles (WCAG AA Standard)

1. **Text Contrast:** Body text (`#0F172A`) against background (`#FFFFFF` / `#F8F9FA`) maintains a contrast ratio ≥ 7:1. Secondary text (`#475569`) maintains ≥ 4.5:1.
2. **Touch Targets:** Every interactive element (buttons, chips, markers, pagination) has a minimum touchable dimension of **44×44 dp**.
3. **Multi-Sensory Signaling:** Budget alerts never rely solely on color. Overbudget notifications always combine **Coral Red background + Warning Icon (⚠️) + Text Message ("Vượt ngân sách 150.000đ")**.
4. **Screen Reader Support:** All icons include descriptive aria labels/alt text (`alt="Bắt đầu ngày 1"`, `aria-label="Đổi thứ tự lên trên"`).
5. **Font & Diacritic Scaling:** Text layout containers accommodate up to 200% text scaling without clipping or overlapping Vietnamese diacritic marks.


---

## 16. Empty States

* **Search / Filter No Results:**
  * *Illustration:* Soft camera/map spot graphic.
  * *Text:* "Không tìm thấy địa điểm phù hợp"
  * *Action CTA:* Button `Xóa bộ lọc` (Clear filters).
* **No Saved Itineraries:**
  * *Illustration:* Empty luggage / map illustration.
  * *Text:* "Bạn chưa có lịch trình nào cho Đà Nẵng"
  * *Action CTA:* Primary button `Tạo lịch trình trong 3 phút ✨`.
* **Empty Day in Itinerary:**
  * *Text:* "Ngày này chưa có hoạt động nào"
  * *Action CTA:* Secondary outline button `+ Thêm địa điểm vào Ngày [X]`.

---

## 17. Loading States

* **Skeleton Loading:**
  * Gray pulsing skeletal cards (`#E2E8F0`) matching the exact shape of timeline activity cards while loading destination lists or saved trips.
* **AI Recommendation Loading Screen:**
  * Dedicated full-screen modal during itinerary generation.
  * Features an animated compass/map icon accompanied by dynamic progress messages:
    * `"Đang phân tích sở thích và ngân sách..."`
    * `"Đang tối ưu hóa tuyến đường di chuyển..."`
    * `"Đang kiểm tra giờ mở cửa các điểm đến..."`
* **Map Loading:**
  * Map container displays a centered spinner over a soft map grid texture until tiles and markers render.

---

## 18. Error States

1. **Map API Failure / Quota Fallback:**
   * *Banner Display:* Non-blocking top notification banner on the map view.
   * *Message:* "Không thể tải tuyến đường chi tiết. Đang hiển thị khoảng cách ước tính đường chim bay."
   * *Fallback UI:* Polyline routes hidden; distances show `~3.5 km (Ước tính)` tag.
2. **Budget Overrun Warning:**
   * *Banner Display:* Sticky summary card at top of itinerary.
   * *Message:* "Lịch trình vượt ngân sách dự kiến 250.000 VNĐ."
   * *Suggested Actions:* Buttons `Bỏ điểm đắt nhất`, `Tăng ngân sách`, hoặc `Đổi sở thích`.
3. **Network Connection Lost:**
   * *Toast Banner:* "Mất kết nối Internet. Đang xem dữ liệu lịch trình đã lưu gần nhất."

---

## 19. Success States

* **Itinerary Generated & Saved:**
  * Bottom toast notification: `"Lịch trình Đà Nẵng đã được tạo và lưu thành công!"` with checkmark icon.
* **Activity Swap / Addition Complete:**
  * Brief green flash highlight on updated activity card and daily summary total.
* **Profile Settings Updated:**
  * Micro-toast banner at top of profile: `"Đã cập nhật sở thích du lịch thành công."`

---

## 20. Do / Don't Rules

### DO:
* **DO** always display the `Ước tính` (Estimated) badge on cost and duration values to build trust.
* **DO** maintain 44px minimum touch targets for all mobile controls and map pin hitboxes.
* **DO** provide explicit travel leg badges (`🚗 15 phút • 4.2 km`) between activity nodes.
* **DO** combine icons, text, and color for all status alerts and budget warnings.
* **DO** preserve scroll and active day context when toggling between Timeline List and Map views.

### DON'T:
* **DON'T** use dark-mode neon purple or generic blue AI gradients that look like corporate SaaS tools.
* **DON'T** hide travel leg distances or route times inside deep hidden menus.
* **DON'T** rely on color alone to signify overbudget states.
* **DON'T** block the entire screen with modal alerts when map routing fallback occurs.
* **DON'T** truncate long destination names without providing full view on tap.

---

## Summary Statement

This Design Direction document establishes a **technology-independent, user-centric visual and UX foundation** for SmartTravel. By adhering strictly to these principles, the design team and developers will build a cohesive, modern, and trustworthy product that empowers travelers to plan realistic, delightful trips to Da Nang in under 3 minutes.

