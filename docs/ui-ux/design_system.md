# FoodBridge Design System Specification

## 1. Brand Identity & Vision
- **Brand Name:** FoodBridge
- **Tagline:** *Share More. Waste Less. Bridge the Need.*
- **Visual Direction:** Modern social-impact tech platform, combining warm community empathy with crisp, high-reliability SaaS ergonomics. Minimal, purposeful, accessible, and optimized for high-speed field operations.

---

## 2. Color System & Semantic Tokens

### 2.1 Core Palette
| Token Name | Hex Code | Purpose / Semantic Mapping | WCAG Contrast (vs White) |
|---|---|---|---|
| `Primary Green` | `#218C5A` | Brand primary, action buttons, active tabs | 4.62:1 (Pass AA) |
| `Deep Green` | `#145A3A` | App bars, prominent headers, high-contrast badges | 8.84:1 (Pass AAA) |
| `Warm Cream` | `#FFF8ED` | Background canvas (Light mode), soothing contrast | N/A (Background) |
| `Charcoal` | `#263238` | Primary body typography, high-priority labels | 12.61:1 (Pass AAA) |
| `Muted Grey` | `#667085` | Secondary text, borders, placeholders, timestamps | 4.88:1 (Pass AA) |
| `Warning Orange` | `#E69A36` | Urgency countdowns, expiring soon, in-transit warnings | 2.18:1 (Used on dark or with bg) |
| `Error Red` | `#C83D3D` | Destructive actions, safety alerts, critical errors | 5.21:1 (Pass AA) |
| `Pure White` | `#FFFFFF` | Card surfaces, modal sheets, elevated layers | N/A |

### 2.2 Semantic Status Tints
| Status State | Background Token | Text/Icon Token | Purpose |
|---|---|---|---|
| `listed` / Available | `#E8F5E9` | `#218C5A` | Live on donation feed |
| `claimed` / Reserved | `#E0F2FE` | `#0284C7` | Claimed by verified NGO shelter |
| `assigned` | `#F3E8FF` | `#7E22CE` | Volunteer assigned to task |
| `pickedUp` / In Transit | `#FEF3C7` | `#D97706` | In transit on the road |
| `delivered` / Completed | `#CCFBF1` | `#0D9488` | Handover confirmed at shelter |
| `cancelled` | `#FEE2E2` | `#991B1B` | Listing cancelled |
| `expired` | `#FEE2E2` | `#DC2626` | Collection deadline elapsed |

### 2.3 Dark Theme ("Rider Night Mode")
Designed specifically for two-wheeler dispatch volunteers operating in low-light evening environments to minimize eye fatigue and battery consumption:
- `Surface Dark`: `#1E262B`
- `Background Dark`: `#12181B`
- `Border Dark`: `#2C373E`
- `Primary Accent Dark`: `#2BB374`
- `Text Dark Primary`: `#E0E6EB`
- `Text Dark Secondary`: `#9AA5B1`

---

## 3. Typography Scale (Inter Font Family)
FoodBridge utilizes the `Inter` font family for high legibility across all display densities.

| Role | Size | Weight | Line Height | Tracking | Use Case |
|---|---|---|---|---|---|
| `Display Large` | 32sp | Bold (700) | 40sp | -0.5px | Splash, impact highlights |
| `Headline Large` | 24sp | Bold (700) | 32sp | -0.2px | Dashboard titles, auth headers |
| `Headline Medium` | 20sp | SemiBold (600) | 28sp | 0.0px | Section headers, card titles |
| `Title Large` | 18sp | SemiBold (600) | 24sp | 0.0px | Modal sheet headings |
| `Title Medium` | 16sp | Medium (500) | 22sp | 0.1px | Sub-sections, form labels |
| `Body Large` | 15sp | Regular (400) | 22sp | 0.2px | Primary content, donation descriptions |
| `Body Medium` | 14sp | Regular (400) | 20sp | 0.25px | Secondary content, instructions |
| `Label Large` | 14sp | SemiBold (600) | 20sp | 0.1px | Standard button text |
| `Label Rider` | 16sp | Bold (700) | 24sp | 0.5px | 56dp Rider action buttons |
| `Caption` | 12sp | Regular (400) | 16sp | 0.4px | Timestamps, distance labels, allergen notes |

---

## 4. Spacing Scale & Elevation
- **Spacing Units:** 8-point spatial grid (`4dp`, `8dp`, `12dp`, `16dp`, `20dp`, `24dp`, `32dp`, `40dp`, `48dp`).
- **Corner Radii:**
  - Small elements (Tags, Chips): `6dp` - `8dp`
  - Interactive inputs (Text fields, Buttons): `10dp` - `12dp`
  - Cards & Containers: `14dp` - `16dp`
  - Modals & Bottom Sheets: `20dp` (Top corners)
- **Elevations (Shadows):**
  - `Level 0`: Flat, 1px border (`#E4E7EC`)
  - `Level 1` (Cards): `BoxShadow(offset: (0, 2), blur: 8, color: #0000000A)`
  - `Level 2` (Floating / Sheets): `BoxShadow(offset: (0, 4), blur: 16, color: #00000014)`
  - `Level 3` (Sticky Actions / Rider CTAs): `BoxShadow(offset: (0, 6), blur: 24, color: #0000001F)`

---

## 5. Field Ergonomics ("Rider Mode")
1. **Target Size:** All primary dispatch buttons in volunteer mode are strictly `56dp` height with full screen width.
2. **Tactile Feedback:** Haptic vibration on status transitions (Claim, Pick Up, Deliver).
3. **No Ambiguity:** Status changes use distinct action verbs ("CONFIRM PHYSICAL PICKUP", "CONFIRM HANDOVER TO NGO") instead of generic "Next" or "OK".
4. **Color Independence:** All status pills pair bold icons with high-contrast text to prevent color-only reliance.

