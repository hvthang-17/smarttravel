# SmartTravel — Design System Specification

> **Document Version:** 1.0  
> **Status:** Approved  
> **Reference Documents:** `tasks/prd-smarttravel.md`, `tasks/DESIGN-DIRECTION.md`  
> **Target Platforms:** Mobile Application (Flutter - iOS/Android) & Web Admin Dashboard (React + TypeScript)

---

## 1. Color Tokens

### Primary & Accent Palette

| Token Name | Color Value | Usage / Role |
| --- | --- | --- |
| `color-primary-base` | `#0077B6` | Da Nang Ocean Blue. Main brand color, primary headers, active tab indicators, key route lines |
| `color-primary-hover` | `#0096C7` | Interactive hover/pressed state for primary controls |
| `color-primary-active` | `#03045E` | Deep ocean blue for focused or selected states |
| `color-primary-surface` | `#EDF6F9` | Light tint background for active card highlights and selected chips |
| `color-secondary-base` | `#F77F00` | Sunlit Coral / Sand. Secondary accent for CTAs ("Tạo lịch trình"), callouts, map pins |
| `color-secondary-hover` | `#E76F51` | Interactive hover state for secondary actions |
| `color-secondary-surface` | `#FFF3E0` | Soft orange surface tint for highlighted alerts |
| `color-accent-sky` | `#0284C7` | Sky Blue for transport leg badges and secondary category tags |
| `color-accent-sky-surface` | `#F0F9FF` | Soft sky blue background tint |

### Neutral Base Palette

| Token Name | Color Value | Usage / Role |
| --- | --- | --- |
| `color-bg-canvas` | `#F8F9FA` | Off-white canvas background for mobile screen body and web workspace |
| `color-surface-card` | `#FFFFFF` | Pure white background for elevated cards, modals, and bottom sheets |
| `color-surface-subtle` | `#F1F5F9` | Container background for segmented tab controls and input fields |
| `color-border-subtle` | `#E2E8F0` | Default 1px card borders, section dividers, and structural outlines |
| `color-border-strong` | `#CBD5E1` | Focused input borders and active tab container outlines |
| `color-text-primary` | `#0F172A` | High contrast slate black for headlines, titles, and body text |
| `color-text-secondary` | `#475569` | Slate gray for subtitles, secondary labels, and descriptive text |
| `color-text-muted` | `#64748B` | Light slate for captions, travel leg distance units, and disabled text |

### Semantic System & Status Palette

| Token Name | Color Value | Surface Tint | Usage / Role |
| --- | --- | --- | --- |
| `color-success-base` | `#2A9D8F` | `#E6F4F1` | Healthy budget state, verified place status, saved notifications |
| `color-warning-base` | `#E9C46A` | `#FEF9E7` | Approaching budget limit (≥85%), unverified opening hours warning |
| `color-error-base` | `#E76F51` | `#FDF2F0` | Overbudget alert banner, missing required fields, blocked account state |
| `color-badge-estimate` | `#EDF2F7` | `#EDF2F7` | Background badge for "Ước tính" (Estimated) tag |

---

## 2. Typography

### Font Family
* **Primary System Font:** **Plus Jakarta Sans** (Fallback: **Inter**)
* **Characteristics:** Clean geometric sans-serif, optimized for mobile screens, high numerical clarity, complete support for Vietnamese tone diacritical marks (`ê`, `ơ`, `ư`, `ầ`, `ẵ`, `ố`).

### Type Hierarchy Specification

| Role | Font Size | Line Height | Weight | Letter Spacing | Usage |
| --- | --- | --- | --- | --- | --- |
| `type-display` | 28px (1.75rem) | 34px (1.2) | Bold (700) | -0.02em | Main screen headers, key onboarding steps |
| `type-heading-1` | 24px (1.5rem) | 30px (1.25) | Bold (700) | -0.01em | Destination detail titles, modal section titles |
| `type-heading-2` | 20px (1.25rem) | 26px (1.3) | SemiBold (600) | 0.00em | Day titles (`Ngày 1`), card section headers |
| `type-heading-3` | 18px (1.125rem) | 24px (1.33) | SemiBold (600) | 0.00em | Activity titles on timeline cards |
| `type-body-large` | 16px (1.0rem) | 24px (1.5) | Regular (400) / Medium (500) | 0.00em | Primary body text, wizard instruction text |
| `type-body-base` | 14px (0.875rem) | 20px (1.43) | Regular (400) / Medium (500) | 0.00em | Card details, notes, budget summaries |
| `type-caption` | 12px (0.75rem) | 16px (1.33) | Regular (400) / Medium (500) | 0.01em | Travel leg metrics (`15 phút • 4.2 km`), timestamps |
| `type-label` | 12px (0.75rem) | 16px (1.33) | SemiBold (600) | 0.02em | Category badges, filter chips, button labels |
| `type-micro-tag` | 11px (0.6875rem) | 14px (1.27) | Bold (700) | 0.05em (Uppercase) | `ƯỚC TÍNH` (Estimated) badge tags |

---

## 3. Spacing Scale

Based on a **4px geometric grid system**:

| Token Name | Pixel Value | Rem Value | Common Usage |
| --- | --- | --- | --- |
| `space-0.5` | 2px | 0.125rem | Micro offsets, border overlaps |
| `space-1` | 4px | 0.25rem | Badge internal padding, icon-to-text gap |
| `space-2` | 8px | 0.5rem | Compact item gap, chip padding, inline margins |
| `space-3` | 12px | 0.75rem | Standard card inner padding (compact), stack gap |
| `space-4` | 16px | 1.0rem | Standard mobile screen margin, activity card padding |
| `space-6` | 24px | 1.5rem | Section spacing, modal inner padding |
| `space-8` | 32px | 2.0rem | Large section dividers, header offset |
| `space-12` | 48px | 3.0rem | Hero section margin, empty state top spacing |
| `space-16` | 64px | 4.0rem | Major structural layout spacing |

---

## 4. Border Radius Scale

| Token Name | Value | Usage |
| --- | --- | --- |
| `radius-xs` | 4px | Status indicators, micro estimate tags |
| `radius-sm` | 6px | Category badges, inline code, small chips |
| `radius-md` | 10px | Action buttons, text inputs, filter pills |
| `radius-lg` | 16px | Activity cards, summary banners, dialog modals |
| `radius-xl` | 24px | Slide-up bottom sheet top corners |
| `radius-pill` | 9999px | Circle avatars, sequence nodes (`01`), segmented control indicators |

---

## 5. Shadows Scale

| Token Name | Value | Role / Usage |
| --- | --- | --- |
| `shadow-none` | `none` | Flat inline cards and default input fields |
| `shadow-xs` | `0px 1px 2px rgba(15, 23, 42, 0.04)` | Elevated filter chips, resting inputs |
| `shadow-sm` | `0px 2px 6px rgba(15, 23, 42, 0.06)` | Activity cards, elevated action buttons |
| `shadow-md` | `0px 4px 12px rgba(15, 23, 42, 0.08)` | Floating action buttons, sticky tab headers |
| `shadow-lg` | `0px 8px 24px rgba(15, 23, 42, 0.12)` | Slide-up bottom sheets, centered dialog modals |
| `shadow-focus-ring` | `0px 0px 0px 3px rgba(0, 119, 182, 0.25)` | Keyboard focus ring for input accessibility |

---

## 6. Grid and Layout Specifications

### Mobile Grid Layout (< 600px)
* **Layout Mode:** Single-column vertical stack.
* **Screen Edge Margin:** `16px` (`space-4`).
* **Column Gap:** `12px` (`space-3`).
* **Sticky Header Height:** `56px` persistent ribbon for day tabs and view toggle.

### Tablet Grid Layout (600px – 1023px)
* **Layout Mode:** 2-Column responsive grid.
* **Screen Edge Margin:** `24px` (`space-6`).
* **Grid Gutter:** `16px` (`space-4`).

### Desktop & Web Admin Layout (≥ 1024px)
* **Layout Mode:** Split-Pane Workspace.
  * **Left Sidebar (Timeline & Summary):** Fixed width `400px` (or 40% viewport width).
  * **Right Workspace (Interactive Map):** Fluid remaining width (60% viewport width).
* **Screen Edge Margin:** `32px` (`space-8`).
* **Grid Gutter:** `24px` (`space-6`).

---

## 7. Breakpoints

| Breakpoint Name | Viewport Width Range | Platform / Device Target |
| --- | --- | --- |
| `bp-xs` | 360px – 479px | Compact mobile phones (Android / iPhone SE) |
| `bp-sm` | 480px – 599px | Large mobile phones (iPhone Pro Max, Android Plus) |
| `bp-md` | 600px – 1023px | Mobile tablets (iPad, Galaxy Tab) / Foldables |
| `bp-lg` | 1024px – 1279px | Small desktop web / Laptop admin workspace |
| `bp-xl` | ≥ 1280px | Large desktop admin dashboard |


---

## 8. Buttons

### Button Variants

| Variant | Background Token | Text Color Token | Border Token | Min Height | Usage |
| --- | --- | --- | --- | --- | --- |
| **Primary** | `color-primary-base` | `#FFFFFF` | `none` | 44px | Main action per screen (`Tạo lịch trình`, `Lưu chuyến đi`) |
| **Secondary** | `color-secondary-base` | `#FFFFFF` | `none` | 44px | Secondary calls to action (`Thêm vào lịch trình`, `Thay thế điểm`) |
| **Outline / Ghost** | `#FFFFFF` (or transparent) | `color-primary-base` | `1px solid color-border-subtle` | 44px | Secondary actions, tab filters, cancel actions |
| **Destructive** | `color-error-base` | `#FFFFFF` | `none` | 44px | High-impact actions (`Xóa lịch trình`, `Khóa tài khoản`) |
| **Disabled** | `#E2E8F0` | `#94A3B8` | `none` | 44px | Inactive state before form completion |

### Button States Matrix

```
[ Default ]     → BG: Base Color | Text: High Contrast | Shadow: shadow-sm
[ Hover/Focus ] → BG: Hover Color | Shadow: shadow-md | Focus Ring: shadow-focus-ring
[ Active/Press] → BG: Active Color | Scale: 0.98
[ Disabled ]    → BG: #E2E8F0 | Text: #94A3B8 | Cursor: not-allowed | Shadow: none
```

---

## 9. Inputs

### Text Input Specification
* **Height:** `48px` (Mobile) / `44px` (Desktop Web).
* **Padding:** Left/Right `16px` (`space-4`), Top/Bottom `12px` (`space-3`).
* **Border Radius:** `radius-md` (10px).
* **Typography:** `type-body-large` (16px - avoids iOS auto-zoom on focus).

### Input States

| State | Background | Border Color | Text Color | Helper Text Color | Focus Ring |
| --- | --- | --- | --- | --- | --- |
| **Default** | `#FFFFFF` | `color-border-subtle` (`#E2E8F0`) | `color-text-primary` | `color-text-secondary` | None |
| **Hover** | `#FFFFFF` | `color-border-strong` (`#CBD5E1`) | `color-text-primary` | `color-text-secondary` | None |
| **Focus** | `#FFFFFF` | `color-primary-base` (`#0077B6`) | `color-text-primary` | `color-text-secondary` | `shadow-focus-ring` |
| **Error** | `#FDF2F0` | `color-error-base` (`#E76F51`) | `color-text-primary` | `color-error-base` | `0 0 0 3px rgba(231,111,81,0.25)` |
| **Disabled** | `#F1F5F9` | `#E2E8F0` | `color-text-muted` | `color-text-muted` | None |

---

## 10. Cards

### Card Archetypes

1. **Activity Timeline Card:**
   * **Container:** Surface `#FFFFFF`, Border 1px `#E2E8F0`, Radius `radius-lg` (16px), Shadow `shadow-sm`.
   * **Left Node Area:** Sequence number circle pill (`01`, `02`) filled with `#0077B6` + category icon.
   * **Center Info:** Destination photo thumbnail (64×64px), Title (16px SemiBold), stay duration tag (`1.5 giờ`), cost badge (`50.000 VNĐ`).
   * **Right Menu:** Overflow actions menu (`⋮`).
2. **Travel Leg Connector Badge:**
   * **Line:** Vertical dashed track (`2px dashed #CBD5E1`).
   * **Center Pill Badge:** Surface `#FFFFFF`, Border 1px `#CBD5E1`, Radius `radius-pill`, Padding `4px 12px`, Text `type-caption` (`🚗 15 phút • 4.2 km`).
3. **Daily Summary & Budget Health Card:**
   * **Container:** Surface `#FFFFFF`, Border 1px `#E2E8F0`, Radius `radius-lg` (16px), Padding `16px`.
   * **Budget Progress Bar:** Height 8px, Radius `radius-pill`, Background `#E2E8F0`, Fill Bar:
     * Green `#2A9D8F` (Normal)
     * Ochre `#E9C46A` (Warning ≥85%)
     * Coral `#E76F51` (Overbudget)

---

## 11. Badges

| Badge Type | Surface Color | Text / Icon Color | Font Spec | Usage |
| --- | --- | --- | --- | --- |
| **Sequence Badge** | `color-primary-base` | `#FFFFFF` | 13px Bold | Activity order (`01`, `02`, `03`) |
| **Category Tag** | `#F0F9FF` | `color-primary-base` | 12px SemiBold | Destination tags (`Văn hóa`, `Biển`, `Ẩm thực`) |
| **Estimate Tag** | `color-badge-estimate` | `color-text-muted` | 11px Bold Uppercase | `ƯỚC TÍNH` status tag |
| **Budget Safe Pill** | `#E6F4F1` | `color-success-base` | 12px SemiBold | `Trong ngân sách` |
| **Budget Over Limit** | `#FDF2F0` | `color-error-base` | 12px SemiBold | `Vượt ngân sách 150k` |

---

## 12. Tabs

### 1. Segmented Control Switcher (`[ 📋 Lịch trình | 🗺️ Bản đồ ]`)
* **Outer Container:** Background `#F1F5F9`, Radius `radius-pill`, Padding `4px`.
* **Active Floating Card:** Background `#FFFFFF`, Radius `radius-pill`, Shadow `shadow-xs`, Text `color-primary-base` Bold.
* **Inactive Tab:** Background transparent, Text `color-text-secondary` Medium.

### 2. Day Selector Ribbon Chips (`[ Ngày 1 ] [ Ngày 2 ] [ Ngày 3 ]`)
* **Active Chip:** Background `color-primary-base`, Text `#FFFFFF`, Shadow `shadow-sm`.
* **Inactive Chip:** Background `#FFFFFF`, Border 1px `#E2E8F0`, Text `color-text-primary`.

---

## 13. Navigation Components

### 1. Mobile Bottom Navigation Bar (4 Persistent Tabs)
* **Height:** `64px` + bottom safe area inset.
* **Surface:** Background `#FFFFFF`, Border Top 1px `#E2E8F0`, Shadow `shadow-md`.
* **Tabs:** 🔍 Khám phá | 🗺️ Tạo chuyến đi | 📁 Lịch trình | 👤 Hồ sơ.
* **Active Tab State:** Icon & label `color-primary-base` (`#0077B6`), top micro indicator pill.
* **Inactive Tab State:** Icon & label `color-text-muted` (`#64748B`).

### 2. Trip Setup Wizard Ribbon
* **Header Bar:** Step count indicator (`Bước 2 / 4`), top progress bar (height 4px, filled with `#0077B6`).
* **Navigation Actions:** Left top `Quay lại` (Back arrow), Sticky bottom `Tiếp tục` (Next CTA button).


---

## 14. Dialogs / Modals

### 1. Centered Confirmation Dialog
* **Backdrop:** Background `rgba(15, 23, 42, 0.5)` with `backdrop-filter: blur(4px)`.
* **Container:** Background `#FFFFFF`, Border Radius `radius-lg` (16px), Max Width `440px`, Padding `24px`.
* **Header:** Title `type-heading-1`, Close button top right (`✕`).
* **Footer Actions:** Dual button layout (Primary action right, Cancel ghost left).

### 2. Slide-Up Bottom Sheet (Mobile Place Preview & Edit Drawer)
* **Backdrop:** Background `rgba(15, 23, 42, 0.4)`.
* **Container:** Background `#FFFFFF`, Top Radius `radius-xl` (24px), Max Height `85vh`.
* **Top Handle:** Center grey drag pill (`40px × 4px`, color `#CBD5E1`, margin top `8px`).

---

## 15. Dropdowns

* **Container:** Surface `#FFFFFF`, Border 1px `#E2E8F0`, Radius `radius-md` (10px), Shadow `shadow-md`, Z-index `1000`.
* **Item Height:** Min `44px`.
* **Item States:**
  * **Default:** Background transparent, Text `color-text-primary`.
  * **Hover / Focus:** Background `#F0F9FF`, Text `color-primary-base`.
  * **Selected:** Background `#EDF6F9`, Text `color-primary-base` Bold, Checkmark right.

---

## 16. Toasts & Feedback Banners

| Toast Type | Surface Color | Border / Left Accent | Icon | Auto-Dismiss | Usage |
| --- | --- | --- | --- | --- | --- |
| **Success Toast** | `#FFFFFF` | 4px Left Border `#2A9D8F` | ✅ Checkmark | 3 seconds | `"Đã lưu lịch trình thành công!"` |
| **Warning Toast** | `#FEF9E7` | 4px Left Border `#E9C46A` | ⚠️ Alert triangle | 5 seconds | `"Ngân sách sắp vượt mức dự kiến"` |
| **Error / Network Toast** | `#FDF2F0` | 4px Left Border `#E76F51` | ❌ Octagon alert | Manual / 5s | `"Không thể kết nối máy chủ bản đồ"` |

---

## 17. Loading States

1. **Skeleton Card Loaders:**
   * Background `#E2E8F0`, Pulse animation duration 1.5s ease-in-out.
   * Shapes match Activity Card layout (64×64px photo box + 2 text lines).
2. **AI Itinerary Generator Modal Loading:**
   * Full-screen overlay with animated spinning compass / coastal breeze icon.
   * Animated text carousel changing every 2 seconds:
     * `"Đang phân tích sở thích và ngân sách..."`
     * `"Đang tối ưu hóa đường đi giữa các điểm..."`
     * `"Đang kiểm tra giờ mở cửa địa điểm..."`

---

## 18. Empty States

### Standard Empty State Template
* **Spot Illustration:** Minimalist 120×120px coastal/travel icon.
* **Title:** `type-heading-2` (`#0F172A`).
* **Description:** `type-body-base` (`#475569`), max width 280px.
* **Call To Action:** Primary button.

### Concrete Variant Implementations
* **Search No Results:** Text: `"Không tìm thấy địa điểm"` | CTA: `Xóa bộ lọc`.
* **My Trips Empty:** Text: `"Bạn chưa có lịch trình nào cho Đà Nẵng"` | CTA: `Tạo lịch trình trong 3 phút ✨`.
* **Empty Itinerary Day:** Text: `"Ngày này chưa có hoạt động nào"` | CTA: `+ Thêm địa điểm vào Ngày [X]`.

---

## 19. Error States

1. **Map Route Fallback Error Banner:**
   * Top sticky alert banner inside map view.
   * Surface `#FEF9E7`, Border 1px `#E9C46A`, Text `#0F172A`.
   * Icon `⚠️` + Text: `"Không thể tải tuyến đường chi tiết. Đang dùng khoảng cách đường chim bay (Ước tính)."`
2. **Overbudget Warning Card:**
   * Sticky top card on itinerary plan view.
   * Surface `#FDF2F0`, Border 1px `#E76F51`, Text `#0F172A`.
   * Details: `"Tổng chi phí ước tính vượt 250.000 VNĐ so với ngân sách đã cài đặt."`
   * Actions: `[ Bỏ điểm đắt nhất ]` `[ Tăng ngân sách ]`.


---

## 20. Accessibility Rules (WCAG AA Compliance)

1. **Color Contrast Ratios:**
   * Text Primary (`#0F172A`) against Surface (`#FFFFFF` / `#F8F9FA`): **14.2:1** (Passes AAA).
   * Text Secondary (`#475569`) against Surface (`#FFFFFF`): **7.1:1** (Passes AAA).
   * Primary Button Text (`#FFFFFF`) against Primary Base (`#0077B6`): **4.6:1** (Passes AA).
2. **Multi-Sensory Indicators:**
   * Status indicators and warnings MUST NOT rely solely on color. They MUST combine **Color + Icon + Text Label**.
3. **Screen Reader Semantics:**
   * Form controls have explicit `aria-label` or `<label>` binding.
   * Images include descriptive alt attributes (`alt="Ảnh Sơn Trà Đà Nẵng"`).
4. **Bilingual Text Expansion:**
   * Containers allow 20% width expansion for English translations without text truncation.
   * Full vertical room reserved for Vietnamese diacritics (`ê`, `ơ`, `ư`, `ầ`, `ẵ`, `ố`).

---

## 21. Touch Target Requirements

* **Minimum Interactive Bounding Box:** **44 × 44 dp** (or `44 × 44 px`).
* **Interactive Target Spacing:** Minimum `8px` (`space-2`) gap between touch targets to prevent mis-taps.
* **Map Pins:** Touch hitbox extended to `44 × 44 dp` even if visible pin graphic is 28×28px.
* **Inline Links:** Padding added around inline links to meet the 44px vertical height threshold.

---

## 22. Responsive Behavior Specifications

* **Fluid Container Scaling:** Width percentages used for layout panels; max-width caps applied on desktop (`max-width: 1280px`).
* **Drawer-to-Modal Transformation:**
  * Viewports `< 600px`: Slide-Up Bottom Sheet (from screen bottom).
  * Viewports `≥ 600px`: Centered Dialog Modal or Side Drawer Panel.
* **Split-Screen Master-Detail Layout (Desktop ≥ 1024px):**
  * Left side timeline list remains scrollable independently.
  * Right side interactive map stays sticky to screen viewport height.

---

## 23. Icon Rules

* **Icon Library Style:** Clean 2px stroke line icons (Feather / Lucide style).
* **Grid Sizing Standard:**
  * Small: `16 × 16 px` (Inline text badges, micro tags).
  * Medium: `20 × 20 px` (Standard button icons, input prefixes).
  * Large: `24 × 24 px` (Bottom navigation icons, header actions).
  * Hero Spot: `48 × 48 px` (Empty state graphics, success modals).
* **Category Icon Mapping:**
  * 🏖️ Beach / Coastal: `sun-umbrella`
  * 🏛️ Culture / Temple: `landmark`
  * 🍜 Local Food / Dining: `utensils`
  * 📸 Photo Spot / Check-in: `camera`
  * 🏨 Lodging / Hotel: `bed`
  * 🚗 Travel Leg Transport: `car` / `bus` / `navigation`

---

## 24. Image Rules

* **Aspect Ratios:**
  * Destination Header Photo: `16:9` aspect ratio.
  * Activity Card Thumbnail: `1:1` square (`64 × 64 px` or `80 × 80 px`).
  * Catalog Grid Card: `4:3` landscape ratio.
* **Legibility Overlay Gradient:**
  * When placing white title text over destination photos, apply a dark linear gradient scrim: `linear-gradient(180deg, rgba(15,23,42,0) 40%, rgba(15,23,42,0.75) 100%)`.
* **Fallback Image Placeholder:**
  * If destination photo fails to load, render a soft grey container with a centered beach/map placeholder icon (`#E2E8F0` surface).

---

## 25. Do / Don't Rules

### DO:
* **DO** use the `ƯỚC TÍNH` (Estimated) badge on cost and duration metrics to set clear user expectations.
* **DO** strictly adhere to the 44px minimum touch target box for all buttons, chips, and map pins.
* **DO** present travel legs explicitly between activity nodes (`🚗 15 phút • 4.2 km`).
* **DO** combine color, icons, and text labels for all status banners and warnings.
* **DO** preserve scroll position and selected day state when toggling between Timeline List and Map views.

### DON'T:
* **DON'T** use dark-mode neon purple or generic corporate SaaS blue gradients.
* **DON'T** rely on color alone to indicate budget warnings or system errors.
* **DON'T** hide travel leg distances or route times inside nested modal menus.
* **DON'T** hardcode fixed pixel widths for text containers that truncate Vietnamese tone marks or long English labels.
* **DON'T** block the full screen with modal popups when map API fallbacks occur.

---

## Summary Statement

This Design System specification provides a **complete, technology-independent token and component foundation** for SmartTravel. By strictly enforcing these tokens, layout rules, component states, and accessibility standards, the product team guarantees a consistent, trustworthy, and high-performance user experience across Flutter mobile applications and React administrative web interfaces.

