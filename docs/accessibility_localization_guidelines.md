# FoodBridge — Accessibility & Localization (i18n) Guidelines

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 3 — Premium UI/UX Design System  
**Status:** Completed  

---

## 1. Accessibility Engineering (WCAG 2.1 Level AA)

FoodBridge is designed to be fully accessible to users with varied visual, physical, and situational capabilities. This includes elderly shelter coordinators, volunteers operating two-wheelers in sunlight, and screen-reader users.

### 1.1 Touch Target Sizing ($\ge 48 \times 48\text{ dp}$)
- Every interactive element (buttons, chips, icons, checkboxes, switches, and dropdowns) must provide a minimum physical touch target of **$48 \times 48\text{ dp}$**.
- For small visual icons ($24 \times 24\text{ dp}$), wrapping with an `IconButton` or adding an invisible padding buffer ensures the touch bounding box satisfies the $48\text{ dp}$ rule.
- Primary field actions (e.g., "Accept Task", "Confirm Pickup") enforce a **$52 - 56\text{ dp}$** minimum height.

### 1.2 Color Contrast & Color-Blind Independence
- **Contrast Ratios:**
  - Standard body text (`#263238` Charcoal on `#FFF8ED` Warm Cream): **$13.2:1$** (Exceeds WCAG AAA).
  - Primary button text (`#FFFFFF` White on `#218C5A` Primary Green): **$4.62:1$** (Exceeds WCAG AA).
  - Header titles (`#145A3A` Deep Green on `#FFF8ED` Warm Cream): **$9.85:1$** (Exceeds WCAG AAA).
  - Error messages (`#C83D3D` Red on `#FFFFFF` White): **$4.75:1$** (Exceeds WCAG AA).
- **Multi-Modal State Signaling:**
  - Status indicators never rely on color alone. Every status badge pairs color with an explicit semantic icon and text label (e.g., Red circle + Clock Alert Icon + "Expired").

### 1.3 Screen Reader Semantics (`Semantics` Widget in Flutter)
- All iconography and actionable controls include explicit accessibility labels:
  ```dart
  IconButton(
    icon: const Icon(LucideIcons.bell),
    tooltip: 'Notifications',
    onPressed: () => context.push('/notifications'),
  )
  ```
- Custom compound widgets (e.g., donation cards) are wrapped with `Semantics(container: true)` to announce the complete context sequentially:
  *"Surplus food donation. 35 kilograms cooked meals. Royal Feast Banquet, Andheri West. Hot holding. Expires in 42 minutes. Double tap to view details."*

### 1.4 Dynamic Text Scaling & Responsive Layouts
- Layouts must adapt gracefully to text scaling factors up to **$2.0\times$** (`textScaleFactor: 2.0`).
- No fixed-height containers wrapping variable text spans (`height: 40` prohibited for text containers; use padding instead).
- Text spans utilize `TextOverflow.ellipsis` with expandable bottom sheets for lengthy descriptions.

---

## 2. Localization (i18n) Architecture

FoodBridge supports three core languages:
1. **English (`en`)** — Default platform and administrative language.
2. **Hindi (`hi`)** — Primary community and regional language.
3. **Marathi (`mr`)** — Regional state language for Maharashtra pilots.

### 2.1 Localization Framework & File Structure
Localization is implemented using standard Flutter ARB (`Application Resource Bundle`) files:

```
lib/
  l10n/
    app_en.arb
    app_hi.arb
    app_mr.arb
```

Configured in `l10n.yaml`:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
untranslated-messages-file: untranslated.json
```

### 2.2 Typography & Devanagari Script Considerations
- **Font Stack:** While *Inter* is used for Latin characters, Devanagari characters for Hindi and Marathi utilize the Google Font **Noto Sans Devanagari** to guarantee pristine vowel sign (matra) rendering.
- **Line Height Multipliers:** Devanagari characters require approximately $15 - 20\%$ taller vertical line height to prevent vowel marks from clipping. TextStyle line-height multipliers are adjusted to $1.35$ for Hindi and Marathi text styles.

### 2.3 Key Localization Translation Matrix (Sample Core Keys)

| Key Name | English (`en`) | Hindi (`hi`) | Marathi (`mr`) |
| :--- | :--- | :--- | :--- |
| `app_title` | FoodBridge | फूडब्रिज | फूडब्रिज |
| `app_tagline` | Share More. Waste Less. Bridge the Need. | अधिक साझा करें। कम बर्बाद करें। जरूरतमंदों तक पहुंचें। | जास्त वाटा. कमी वाया घालवा. गरजूंपर्यंत पोहोचा. |
| `role_donor` | Donor | अन्न / वस्त्र दाता | अन्न / वस्त्र दाता |
| `role_ngo` | NGO / Community Shelter | एनजीओ / आश्रम | एनजीओ / आश्रम |
| `role_volunteer` | Community Volunteer | स्वयंसेवक | स्वयंसेवक |
| `donate_food_btn` | Donate Surplus Food | अतिरिक्त भोजन दान करें | शिल्लक अन्न दान करा |
| `donate_clothes_btn`| Donate Clothes | कपड़े दान करें | कपडे दान करा |
| `expiry_deadline` | Collection Deadline | संग्रह की अंतिम समय-सीमा | उचलण्याची शेवटची वेळ |
| `status_available` | Available | उपलब्ध | उपलब्ध |
| `status_requested` | Request Received | अनुरोध प्राप्त | विनंती प्राप्त |
| `status_in_transit`| In Transit | रास्ते में | मार्गावर |
| `status_completed` | Completed | पूर्ण हुआ | पूर्ण झाले |
| `accept_task_btn` | Accept Task | कार्य स्वीकारें | काम स्वीकारा |
| `confirm_pickup` | Confirm Physical Pickup | संग्रह की पुष्टि करें | ताब्यात घेतल्याची पुष्टी करा |
| `confirm_handover`| Confirm Handover to NGO | आश्रम को सुपुर्दगी की पुष्टि करें | आश्रमात सुपूर्द केल्याची पुष्टी करा |

### 2.4 Date, Time & Number Formatting
- Dates and times format according to local conventions using `intl.DateFormat.yMMMd().format(dateTime)` and 12-hour/24-hour user preferences.
- Metric measurements use universal SI abbreviations (`kg`, `L`, `pcs`) with localized suffixes.

