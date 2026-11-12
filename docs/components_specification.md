# FoodBridge — Reusable UI Components Specification

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 3 — Premium UI/UX Design System  
**Status:** Completed  

---

## 1. Button Component Suite

All buttons enforce a minimum physical touch target of **$48 \times 48\text{ dp}$** (WCAG AA). 

```
┌────────────────────────────────────────────────────────┐
│ [  PRIMARY ACTION BUTTON — Min Height 52dp  ]          │
│ [  SECONDARY OUTLINE BUTTON               ]          │
│ [ ⚠️ DESTRUCTIVE ACTION                    ]          │
│ [ ⚡ RIDER MODE BIG ACTION BUTTON (56dp)    ]          │
└────────────────────────────────────────────────────────┘
```

### 1.1 Primary Filled Button (`FBPrimaryButton`)
- **Default State:** Background `#218C5A`, Text `#FFFFFF` (Inter SemiBold 16sp), Border Radius $12\text{ dp}$, Height $52\text{ dp}$, Horizontal Padding $24\text{ dp}$.
- **Pressed State:** Background `#145A3A` (Deep Green), scale down to $0.98$.
- **Disabled State:** Background `#E4E7EC`, Text `#9AA5B1`, Elevation 0, no ripple.
- **Loading State:** Background `#218C5A`, Text hidden, centered circular white progress indicator ($20\text{ dp}$, stroke width $2.5\text{ dp}$).

### 1.2 Secondary Outlined Button (`FBSecondaryButton`)
- **Default State:** Background `transparent`, Border $1.5\text{ px}$ `#218C5A`, Text `#218C5A` (Inter SemiBold 16sp), Height $52\text{ dp}$.
- **Pressed State:** Background `rgba(33, 140, 90, 0.08)`, Border `#145A3A`.
- **Disabled State:** Border `#E4E7EC`, Text `#9AA5B1`.

### 1.3 "Rider Mode" Big Action Button (`FBRiderActionButton`)
*Specialized for field volunteers operating on the move.*
- **Dimensions:** Height **$56\text{ dp}$** (minimum), full width of screen minus $32\text{ dp}$ margins.
- **Visuals:** High-contrast vibrant `#218C5A` background with bold white icon and text (18sp bold).
- **Haptic Feedback:** Triggers heavy haptic click (`HapticFeedback.heavyImpact()`) on tap.
- **Elevation:** Elevation 2 with subtle shadow for high visibility in daylight glare.

### 1.4 Destructive Button (`FBDangerButton`)
- **Default State:** Background `#FFFFFF`, Border $1.5\text{ px}$ `#C83D3D`, Text `#C83D3D`.
- **Pressed State:** Background `rgba(200, 61, 61, 0.08)`.
- **Filled Variant:** Background `#C83D3D`, Text `#FFFFFF` for critical confirmations (e.g., "Confirm Food Rejection").

---

## 2. Form Input Components

### 2.1 Text Input Field (`FBTextField`)
- **Container:** Height $56\text{ dp}$, Background `#FFFFFF`, Border $1\text{ px}$ `#E4E7EC`, Border Radius $10\text{ dp}$, Horizontal Padding $16\text{ dp}$.
- **Focus State:** Border $2\text{ px}$ `#218C5A`, subtle green glow.
- **Error State:** Border $2\text{ px}$ `#C83D3D`, supporting red caption text below field.
- **Prefix / Suffix:** Supports leading icon (e.g., search or phone) and trailing clear/visibility toggle.

### 2.2 Quantity & Unit Counter (`FBQuantitySelector`)
- Combined widget featuring a numeric input field paired with a localized dropdown chip for measurement units (`kg`, `boxes`, `portions`, `pieces`, `liters`).
- Includes fast-increment/decrement buttons ($+$ and $-$) for rapid quantity adjustments without keyboard typing.

### 2.3 Image Upload Tile (`FBImageUploadTile`)
- **Empty State:** Dashed border ($1.5\text{ px}$ `#667085`), Warm Cream fill, centered camera icon, label "Add Photo (Max 5)".
- **Uploading State:** Displays thumbnail preview with semi-transparent overlay and circular progress percentage.
- **Uploaded State:** Full-bleed rounded thumbnail with top-right circular remove button (Red cross icon, $28 \times 28\text{ dp}$).

### 2.4 Mandatory Declaration Checkbox (`FBSafetyDeclarationTile`)
- Distinct container with Warm Cream background (`#FFF8ED`) and Deep Green outline (`#145A3A`).
- Large $24 \times 24\text{ dp}$ checkbox paired with explicit legal/safety declaration text.
- Must be actively ticked before form submission buttons become enabled.

---

## 3. Card Components

### 3.1 Donation Item Card (`FBDonationCard`)
```
┌────────────────────────────────────────────────────────┐
│ [Photo 96x96]  🍛 Cooked Meals — 35 kg (~90 Portions) │
│                Royal Feast Banquet | Andheri West      │
│                Storage: [🔥 Hot Holding]               │
│                                                        │
│ [⏳ EXPIRES IN: 42 MINS ]   [ Status: 🔵 Requested ]   │
│ ────────────────────────────────────────────────────── │
│ [ View Details / Request Donation Button ]             │
└────────────────────────────────────────────────────────┘
```
- **Dimensions:** Margin bottom $12\text{ dp}$, Padding $16\text{ dp}$, Border Radius $12\text{ dp}$, Background `#FFFFFF`.
- **Border:** $1\text{ px}$ solid `#E4E7EC` (Light theme) or `#2C373E` (Dark theme).
- **Semantic Components:** Thumbnail photo on left ($88 \times 88\text{ dp}$), category icon, title, quantity with meal portion conversion, approximate zone, and dynamic countdown chip.

### 3.2 Volunteer Task Card (`FBTaskCard`)
- Includes high-visibility **Vehicle Compatibility Badge** at top:
  - 🛵 `Two-Wheeler Compatible (≤ 12 kg)` (Green pill)
  - 🚗 `Four-Wheeler / Van Required (> 25 kg)` (Amber pill)
- Displays Route Summary: `Pickup Zone ──► Destination NGO` with total estimated road distance ($4.2\text{ km}$).
- Prominent deadline countdown with high-contrast text.

### 3.3 Impact Metric Card (`FBImpactCard`)
- Compact elevated card ($100 \times 90\text{ dp}$) displaying:
  - Top: Large numeric counter (Display Medium 24sp bold, `#218C5A`).
  - Middle: Metric unit (`kg Food`, `Meals`, `Garments`).
  - Bottom: Subtitle (`Rescued`, `Served`, `Donated`).

---

## 4. Status Chips & Visual Indicators

To guarantee accessibility for color-blind users, **status is never communicated by color alone**. Every chip pairs a background tint, text label, and unique icon:

| Status Token | Background Tint | Border / Icon Color | Icon Name | Plain-Language Label |
| :--- | :---: | :---: | :---: | :--- |
| `draft` | `#F2F4F7` | `#667085` | `edit-3` | Draft |
| `available` | `#E8F5E9` | `#218C5A` | `sparkles` | Available |
| `requested` | `#E0F2FE` | `#0284C7` | `hand` | Request Received |
| `accepted` | `#DCFCE7` | `#15803D` | `check-circle` | Accepted |
| `assigned_for_pickup`| `#F3E8FF` | `#7E22CE` | `bike` | Volunteer Assigned |
| `picked_up` | `#FEF3C7` | `#D97706` | `package-check`| Picked Up (In Transit) |
| `delivered_to_ngo` | `#CCFBF1` | `#0D9488` | `building-2` | Delivered to NGO |
| `distributed` | `#E0E7FF` | `#4338CA` | `heart-handshake`| Distribution Recorded |
| `completed` | `#D1FAE5` | `#047857` | `check-check` | Completed |
| `cancelled` | `#FEE2E2` | `#991B1B` | `ban` | Cancelled |
| `expired` | `#FEE2E2` | `#DC2626` | `clock-alert` | Expired |
| `rejected` | `#FFE4E6` | `#BE123C` | `alert-octagon`| Inspection Refusal |

---

## 5. Modals, Sheets & Dialogs

### 5.1 Bottom Sheet Claim Modal (`FBClaimBottomSheet`)
- Slides from bottom with backdrop blur (`rgba(38, 50, 56, 0.4)`).
- Top drag handle ($36 \times 4\text{ dp}$ rounded grey pill).
- Contains requested quantity slider/input, radio choice for "Self Collection" vs. "Volunteer Delivery Request", delivery notes input, and primary claim button.

### 5.2 Doorstep Quality Rejection Dialog (`FBRejectionDialog`)
- Modal dialog requiring NGO inspector to select from standardized refusal reasons:
  - `[ ] Food Safety Failure (Off-odor, sour, or spoiled)`
  - `[ ] Temperature Abuse (Hot food delivered cold / Melted frozen)`
  - `[ ] Packaging Breach (Broken seal, spilled, contaminated)`
  - `[ ] Unusable Clothing (Soiled, torn, damp)`
- Free-text incident observation field (mandatory, min 10 characters).
- Primary confirmation button: "Confirm Delivery Refusal" (`#C83D3D`).

### 5.3 Emergency Task Release Dialog (`FBSurrenderTaskDialog`)
- Used by volunteers experiencing breakdown or flat tire.
- Reassuring message: *"Surrendering releases this task immediately so another nearby volunteer can collect it before the food expires. You will not be penalized for verified emergencies."*

---

## 6. Feedback & System State Components

### 6.1 Shimmer Loading Skeleton (`FBSkeletonCard`)
- Pulsing animated gradient (`#E4E7EC` to `#F2F4F7`) mirroring the exact geometry of donation and task cards to prevent jarring layout shifts during data fetch.

### 6.2 Empty State Widget (`FBEmptyState`)
- Centered layout containing an original vector illustration ($140 \times 140\text{ dp}$), a clear headline (Headline 2), a reassuring explanatory caption (Body Medium), and an optional primary call-to-action button (e.g., "Create a Donation" or "Adjust Filter Radius").

### 6.3 Error Banner & Full-Screen Error State (`FBErrorView`)
- Compact in-line banner for network warnings (`#FEE2E2` background, Red alert icon, retry button).
- Full-screen recovery view for catastrophic network outages with friendly illustration and an explicit "Try Again" button.

