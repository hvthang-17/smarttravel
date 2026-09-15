# SmartTravel — Design Direction

This is the visual contract for future Stitch generations. Use it with `tasks/UI-SPEC.md`. Preserve the approved Round 1 direction; do not add new product features, navigation destinations, visual styles, colours, fonts, or decorative patterns.

## 1. Brand and visual direction

SmartTravel is a calm, trustworthy, mobile-first Da Nang trip-planning utility. It should feel coastal, clear, practical and locally grounded—not like a generic AI assistant, booking marketplace, social app, or data dashboard.

- Prioritise decisions: create/continue a trip, understand estimated cost/time, and inspect the ordered daily plan.
- Use destination imagery as meaningful travel content, never as decorative wallpaper.
- Keep surfaces clean and light: pale sky-blue page background, white content surfaces, blue information/navigation, orange for the single primary action.
- Use subtle depth only. No glassmorphism, neon, immersive gradients, heavy shadows, floating blobs, or “AI magic” effects.

## 2. Colour tokens

Use semantic tokens only; do not introduce screen-specific colours.

| Token | Value | Usage |
| --- | --- | --- |
| `primary` | `#0EA5E9` | active navigation, links, information, selected day/filter states |
| `accent` | `#EA580C` | one primary CTA per context: create, save, or recalculate |
| `background` | `#F0F9FF` | app background |
| `surface` | `#FFFFFF` | cards, sheets, inputs, sticky action bars |
| `text` | `#0C4A6E` | primary text and headings |
| `text-muted` | `#475569` | metadata, supporting copy |
| `border` | `#BAE6FD` | inputs, selected/interactive boundaries, light dividers |
| `success`, `warning`, `error` | semantic tokens | status only; always pair colour with text/icon |

Use pale blue fills for selected controls and informational areas. Use orange only for the current primary CTA, not as repeated decoration. White passive cards should not receive universal pale-blue outlines.

## 3. Typography, spacing and sizing

- Headings: **Lora**, including Vietnamese glyph support. Use for page, section, destination, and itinerary titles.
- UI/body: **Raleway**, including Vietnamese glyph support. Base body is at least 16sp with line-height at least 1.5.
- Use a consistent scale: 12, 14, 16, 18, 24, 32. Avoid tiny labels or dense all-caps text.
- Use tabular figures for VND, duration, and distance when available.
- Spacing follows a 4/8dp scale: 16dp card padding, 24dp between sections, 32dp between major blocks.
- Card radius: 12dp. Input/control radius: 10dp. Keep shapes modest and consistent.
- All interactive targets are at least 48dp on Android and 44pt on iOS; visual icons may be smaller only within a compliant tap area.

## 4. Component rules

### Cards

- Use a white card for a cohesive content group: current draft, alert, saved place, destination result, itinerary activity, or summary.
- Passive cards use separation through white surface, spacing, and very subtle elevation—not a strong blue border.
- Do not nest cards without a clear hierarchy. An itinerary activity card may contain lightweight rows/chips, not more floating cards.
- Destination images keep a consistent fixed aspect ratio and rounded top corners where attached to a result/activity card.

### Buttons and CTA hierarchy

- One primary action per screen/state: orange filled button with clear text and optional consistent outline icon.
- Secondary actions are blue text or a white/very pale-blue outlined button. Destructive actions remain secondary and require confirmation.
- On Home: **Bắt đầu lập lịch trình** or **Tiếp tục lập kế hoạch** is primary.
- New/current itinerary draft: **Lưu lịch trình** is primary. Do not show a stale-data warning.
- Edited/stale itinerary: explain that totals are stale; **Tính lại lịch trình** becomes orange primary and **Lưu nháp/Lưu lịch trình** becomes secondary.
- Do not use share, booking, payment, weather, or generic AI-assistant CTAs.

### Inputs and chips

- Inputs have visible labels where needed, white surface, subtle border, clear focus state, and inline validation.
- Use chips for filters, category tags, day selection, and compact metadata. Selected chips use blue fill; unselected chips remain quiet.
- Chips must wrap or provide an explicit, operable overflow. Never crop labels at a viewport edge.

### Icons

- Use one coherent outline-vector system (Material Symbols/Cupertino-equivalent). No emoji or mixed icon families.
- Icons communicate a familiar action: map, search, filter, favourite, calendar, profile, edit, reorder, replace, delete, route, and estimate.
- Icon-only controls require an accessible label. Keep stroke weight, size, and circular containers consistent.

## 5. Layout and navigation

### Traveller mobile navigation

Persistent bottom navigation has exactly five labelled items: **Trang chủ, Khám phá, Tạo chuyến đi, Chuyến đi, Cá nhân**. The central Create Trip action is visually prominent but does not obscure content.

- Respect safe areas and reserve content space above the bottom bar/sticky CTA bar.
- Use one-column mobile layouts. On tablet, increase gutters and optionally show itinerary list and map together within the same workspace.
- Keep Vietnamese UI fully Vietnamese when `VI` is selected; do not mix English labels. `EN` must likewise be fully English.

### Home and Explore

- Home order: primary CTA → active draft/upcoming trip → actionable estimate alert → short saved-place preview → Explore prompt.
- Explore order: search → active filters/count → destination results → load more. Opening a destination is the primary result action; Add to trip is contextual/secondary.
- Do not show an empty state while results are visible.

## 6. Itinerary patterns

- Itinerary is one workspace: daily plan, map, editing, recalculation, fallback and warnings are contextual states—not separate screens.
- Header order: draft/status and title → trip facts → budget summary → day selector → Plan/Map toggle → selected-day totals → activity timeline.
- Day selector: show the active day with a clear blue selected state. Visible day chips must never be clipped. If more days exist, show a clear continuation arrow/control; horizontal scrolling must be obvious and preserve the active day.
- Timeline uses numbered markers, ordered activity cards, and light travel-leg separators. Each item contains time, title, image when available, estimated cost/time, and concise rule-based rationale.
- State estimates plainly: **Ước tính** for distance, travel time, cost, and route-derived totals; include a calculation/update timestamp where presented.
- Use an actionable fallback/warning panel only when relevant. Never claim live traffic, real-time routing, weather, synchronisation, confidence scores, or guaranteed optimisation.
- Editing must be discoverable but calm: use a labelled **Chỉnh sửa** action and a clearly labelled reorder control with compliant tap areas. Do not duplicate dense action rows unnecessarily on every item.

## 7. States and interaction patterns

- Loading: skeletons preserve layout; button requests show progress and prevent duplicate submit.
- Empty: explain the situation and route to the existing relevant action (for example, Explore); do not create a separate page.
- Error: retain user input/current confirmed values, explain the issue, and offer Retry near the failure.
- Success: concise in-context confirmation; refresh only the affected content.
- Disabled: visually distinct, non-interactive, and paired with an explanation where needed.
- Feedback/motion: use subtle pressed feedback and short 200–300ms transitions. Respect reduced-motion settings.

## 8. Accessibility and responsive requirements

- Text contrast is at least 4.5:1; meaningful icon contrast is at least 3:1.
- Do not convey selection, error, budget state, or estimation by colour alone.
- Provide text alternatives for meaningful images and accessible names/state for icon controls.
- Support Dynamic Type without truncating essential labels. Never hide focused controls behind sticky UI, sheets, keyboard, or system bars.
- Do not rely on drag or swipe alone: provide visible alternatives for reordering and navigation.
- Test at small phone, phone landscape, tablet portrait, and tablet landscape. No unintentional horizontal page scrolling.

## 9. Do / Don't: anti-slop guardrails

**Do**

- Make the current planning decision visually dominant.
- Use Da Nang destination imagery and factual, estimated trip data.
- Keep hierarchy through spacing, type, and restrained colour.
- Use short explainable recommendation reasons such as interest match, estimated distance, or budget fit.
- Keep all status claims specific and evidence-based.

**Don't**

- Add weather, live conditions, real-time traffic/routing, live-sync claims, AI confidence scores, “optimised” guarantees, booking, reviews, sharing, social features, or chat.
- Add gradients beyond the approved very subtle optional treatment; do not add glass, blur decoration, neon, oversized hero imagery, or generic AI motifs.
- Turn every block into a card, apply blue borders to all cards, add heavy shadows, or increase radii arbitrarily.
- Use emoji as UI icons, mixed locales, clipped chips/tabs, tiny controls, placeholder-only labels, or hover/swipe-only actions.
- Create new pages for map, editing, fallback, history, or status feedback when the IA defines them as contextual states.

## 10. Stitch consistency checklist

Before generating any new SmartTravel screen, verify:

1. It belongs to an existing UI-SPEC workspace and uses the existing navigation.
2. It has one state-appropriate primary CTA and subordinate secondary actions.
3. Colours, fonts, radii, spacing, icon system, and estimate labels match this document.
4. Passive surfaces are quiet; borders indicate interaction, focus, or selection.
5. All controls fit and remain tappable on a small phone; no tab, chip, or label is clipped.
6. The screen contains no unsupported product claim or generic AI visual language.
