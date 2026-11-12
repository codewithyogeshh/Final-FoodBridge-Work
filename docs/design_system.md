# FoodBridge — Design System & Visual Specification

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 3 — Premium UI/UX Design System  
**Status:** Completed  

---

## 1. Brand Essence & Visual Language

FoodBridge represents a fusion of **compassion, reliability, dignity, and real-time operational efficiency**. 
- **Modern & Clean:** Generous whitespace, clear visual hierarchy, and uncluttered layouts designed for fast scanning.
- **Trustworthy & Professional:** High-contrast, standardized typography, verified badges, and crisp UI components that build institutional and donor confidence.
- **Human-Centered & Dignified:** Warm, welcoming surfaces that avoid shame-based imagery or sensationalism.
- **Accessible & Ergonomic:** Ergonomic controls, clear focus states, and large touch targets tailored for users on the move (especially volunteers on two-wheelers).

---

## 2. Color Palette & Semantic Token Architecture

The FoodBridge color system is built on an earthy, hopeful palette with rigorous WCAG 2.1 Level AA contrast compliance:

```
┌────────────────────────────────────────────────────────────────────────┐
│  PRIMARY PALETTE                                                       │
│  [ Primary Green: #218C5A ]   [ Deep Green: #145A3A ]                  │
│  [ Warm Cream:    #FFF8ED ]   [ Charcoal:   #263238 ]                  │
│                                                                        │
│  SUPPORTING & FEEDBACK PALETTE                                         │
│  [ Muted Grey:    #667085 ]   [ Warning Orange: #E69A36 ]              │
│  [ Error Red:     #C83D3D ]   [ Pure White:     #FFFFFF ]              │
└────────────────────────────────────────────────────────────────────────┘
```

### 2.1 Complete Color Token Specifications

| Token Name | Hex Code | Semantic Role | Contrast vs. Background |
| :--- | :---: | :--- | :--- |
| `primary` | `#218C5A` | Brand identity, primary action buttons, key highlights, positive state chips. | $4.62:1$ vs. Warm Cream / White |
| `primaryDark` | `#145A3A` | Page headers, prominent app bar titles, high-emphasis text, pressed states. | $9.85:1$ vs. Warm Cream / White |
| `surfaceCream` | `#FFF8ED` | Default application background for light theme; warm, welcoming, low glare. | Base Surface |
| `textCharcoal` | `#263238` | Primary body text, headings, input text, high-priority labels. | $13.2:1$ vs. Warm Cream |
| `textMuted` | `#667085` | Secondary text, timestamps, captions, field placeholder text. | $4.8:1$ vs. Warm Cream / White |
| `accentOrange` | `#E69A36` | Time-sensitive countdown warnings, expiry alerts, pending verification states.| $3.2:1$ (Used with dark text/icons)|
| `errorRed` | `#C83D3D` | Destructive actions, cancellation banners, food safety rejection alerts. | $4.75:1$ vs. White |
| `surfaceWhite` | `#FFFFFF` | Card surfaces, modal sheets, elevated input containers, dialogs. | Elevated Surface |

---

## 3. Light & Dark Theme Definitions

### 3.1 Light Theme Specification (Default)
- **Scaffold Background:** `surfaceCream` (`#FFF8ED`)
- **Card / Sheet Surface:** `surfaceWhite` (`#FFFFFF`) with 1px border (`#E4E7EC`)
- **Primary Header Text:** `primaryDark` (`#145A3A`)
- **Primary Body Text:** `textCharcoal` (`#263238`)
- **Secondary / Helper Text:** `textMuted` (`#667085`)
- **App Bar Background:** `surfaceWhite` (`#FFFFFF`) or `primaryDark` (`#145A3A`)
- **Bottom Navigation Surface:** `surfaceWhite` (`#FFFFFF`) with active item `#218C5A` and inactive `#667085`
- **Divider / Outline:** `#E4E7EC`

### 3.2 Dark Theme Specification (Night Operations & Rider Mode)
- **Scaffold Background:** `#12181B` (Deep Blue-Black Charcoal)
- **Card / Sheet Surface:** `#1E262B` (Elevated Slate Surface)
- **Card Outline:** `#2C373E` (Subtle boundary)
- **Primary Accent:** `#2BB374` (Lighter Emerald Green for dark mode contrast)
- **Primary Header Text:** `#FFFFFF` (High emphasis)
- **Primary Body Text:** `#E0E6EB` (Off-white readable body)
- **Secondary / Helper Text:** `#9AA5B1` (Muted silver)
- **Warning Accent:** `#F5A623` (Warm Amber)
- **Error Accent:** `#E55353` (Vibrant Coral Red)
- **Bottom Navigation Surface:** `#1A2227`

---

## 4. Typography Scale (Inter Font Family)

The typography scale utilizes **Inter** (licensed under SIL Open Font License), optimized for high legibility on mobile screens at small sizes.

| Style Role | Font Weight | Size (sp/pt) | Line Height (sp/pt) | Letter Spacing | Usage |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Display Large** | Bold (700) | 32 | 40 | -0.5px | Hero impact counters, splash screen |
| **Display Medium**| Bold (700) | 28 | 36 | -0.25px | Major section titles |
| **Headline 1** | SemiBold (600)| 24 | 32 | 0.0px | Screen titles, modal headers |
| **Headline 2** | SemiBold (600)| 20 | 28 | 0.0px | Section headers, card titles |
| **Title Medium** | Medium (500) | 16 | 24 | 0.15px | Subheaders, input labels, tab text |
| **Body Large** | Regular (400) | 16 | 24 | 0.5px | Primary prose, form descriptions |
| **Body Medium** | Regular (400) | 14 | 20 | 0.25px | Secondary card text, list items |
| **Label Large** | SemiBold (600)| 14 | 20 | 0.1px | Button text, chip labels |
| **Label Small** | Medium (500) | 11 | 16 | 0.5px | Timestamps, badge text, captions |

---

## 5. Spacing Grid, Elevation & Border Radii

### 5.1 4-Point Base Spacing Grid
All paddings, margins, and layout gaps adhere strictly to multiples of $4\text{ dp}$:
- `space-4`: $4\text{ dp}$ (Tight internal element gaps)
- `space-8`: $8\text{ dp}$ (Gap between icon and label, chip padding)
- `space-12`: $12\text{ dp}$ (Card interior padding, stack gaps)
- `space-16`: $16\text{ dp}$ (Standard horizontal screen margin, input field padding)
- `space-20`: $20\text{ dp}$ (Section separation)
- `space-24`: $24\text{ dp}$ (Major component group spacing)
- `space-32`: $32\text{ dp}$ (Form section breaks, modal tops)
- `space-48`: $48\text{ dp}$ (Top/Bottom hero padding, empty-state margins)

### 5.2 Border Radii
- **Small (`radius-8`):** $8\text{ dp}$ — Input fields, alert banners, mini chips.
- **Medium (`radius-12`):** $12\text{ dp}$ — Standard cards, task cards, modal containers.
- **Large (`radius-16`):** $16\text{ dp}$ — Elevated sheets, hero cards.
- **Pill (`radius-full`):** $999\text{ dp}$ — Status chips, circular action buttons, category tags.

### 5.3 Elevation & Shadows
- **Elevation 0:** Flat surface (`#FFFFFF` on `#FFF8ED`) with 1px border `#E4E7EC`. (Default for cards).
- **Elevation 1 (Low):** `offset: (0, 2), blur: 4, spread: 0, color: rgba(38, 50, 56, 0.06)` — Active cards, buttons.
- **Elevation 2 (Medium):** `offset: (0, 4), blur: 12, spread: 0, color: rgba(38, 50, 56, 0.10)` — Modals, bottom navigation bar.
- **Elevation 3 (High):** `offset: (0, 8), blur: 24, spread: 0, color: rgba(38, 50, 56, 0.15)` — Floating action sheets, notification toasts.

---

## 6. Iconography & Visual Asset Standards

- **Icon Set:** Clean, geometric line icons from **Lucide Icons** / Material Symbols.
- **Stroke Width:** Standard $2.0\text{ px}$ regular stroke; $1.5\text{ px}$ for mini decorative icons.
- **Standard Icon Bounding Boxes:**
  - Mini / Inline: $16 \times 16\text{ dp}$
  - Standard Action: $24 \times 24\text{ dp}$
  - Hero / Illustration: $48 \times 48\text{ dp}$ or $64 \times 64\text{ dp}$
- **Illustrations:**
  - Minimalist vector style using unDraw / custom SVGs.
  - Palette alignment: Primary Green (`#218C5A`), Deep Green (`#145A3A`), and Warm Cream accents.
  - Ethical mandate: Avoid depictions of destitute individuals in degrading or pitiable situations; emphasize community solidarity, food packaging, and logistics coordination.

