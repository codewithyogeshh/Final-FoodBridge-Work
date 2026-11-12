# FoodBridge Accessibility & Localization Specification

## 1. Compliance Standard
FoodBridge is designed to adhere strictly to the **Web Content Accessibility Guidelines (WCAG) 2.1 Level AA** standards.

---

## 2. Touch Target Dimensions & Spatial Accessibility
- **Standard Touch Target:** Minimum `48 x 48 dp` for all interactive elements (buttons, icons, chips, and list tiles).
- **Rider Mode Field Targets:** `56 dp` height with full screen width for field-operation action buttons (`FBButton.rider`), ensuring error-free operation even when volunteers are wearing protective riding gloves.
- **Minimum Padding:** At least `8 dp` spacing between adjacent interactive elements to prevent accidental touches.

---

## 3. Contrast Ratios & Visual Perception
- **Normal Text Contrast:** Minimum `4.5:1` against adjacent background.
- **Large Text Contrast (>= 18sp Bold or 24sp Regular):** Minimum `3.0:1`.
- **UI Components & Graphical Objects:** Minimum `3.0:1` against adjacent colors.
- **No Color-Only Indicators:** Status chips and banners pair distinct vector icons with clear localized text labels:
  - Example: *Available* uses both Green tint AND `Icons.check_circle_outline`.
  - Example: *Expired* uses Red tint AND `Icons.timer_off_outlined`.

---

## 4. Screen-Reader Support (Semantics)
- All interactive controls wrap content in Flutter `Semantics` widgets:
  - Form fields include `Semantics(label: ..., hint: ...)`.
  - Buttons declare `Semantics(button: true, label: ...)`.
  - Status updates announce changes via `SemanticsService.announce(message, TextDirection.ltr)`.
- Image widgets include descriptive accessibility labels (or `excludeFromSemantics: true` for purely decorative illustrations).

---

## 5. Dynamic Type & Font Scaling
- The application supports system accessibility font scaling up to `1.5x` without layout truncation, container overflow, or text clipping.
- Scroll views (`ListView`, `SingleChildScrollView`) are utilized on all content pages to accommodate expanded text sizes gracefully.

---

## 6. Multi-Language Localization (i18n)

### Supported Languages
1. **English (`en`):** Default administrative and cross-regional language.
2. **Hindi (`hi`):** National language, prominent in North and Central India.
3. **Marathi (`mr`):** Local state language for Maharashtra operations (Pune, Mumbai, Nashik).

### Implementation Strategy
- Managed by `LocaleProvider` in `lib/core/localization/locale_provider.dart`.
- Seamless in-app switching from the Profile Screen without requiring an application restart.
- Cultural adaptations: Number formatting respects Indian numbering conventions (`1,00,000` format) via `intl` package.

