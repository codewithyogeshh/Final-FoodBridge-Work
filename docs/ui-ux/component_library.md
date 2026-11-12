# FoodBridge UI Component Library

This document outlines the standardized atomic and composite components implemented in the FoodBridge application design system.

---

## 1. Action Components

### 1.1 `FBButton`
The primary interactive touch component with integrated accessibility and loading states.

- **Variants:**
  - `primary`: Background `#218C5A`, Text `#FFFFFF`
  - `secondary`: Background `Transparent`, Border `1.5px #218C5A`, Text `#218C5A`
  - `danger`: Background `#C83D3D`, Text `#FFFFFF`
  - `ghost`: Background `Transparent`, Text `#218C5A`
  - `rider`: Height `56dp`, Full-width, Bold 16sp label, Haptic feedback trigger on tap.
- **Properties:**
  ```dart
  final String label;
  final VoidCallback? onPressed;
  final FBButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height; // Default: 48dp, Rider: 56dp
  ```
- **Accessibility:** Enforces minimum 48dp tap target (56dp in Rider Mode), uses `Semantics(button: true)`.

---

## 2. Input Components

### 2.1 `FBTextField`
Standard form input field supporting error handling, prefixes, suffixes, and accessibility labels.

- **Properties:**
  ```dart
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  ```
- **Visuals:** 1px border (`#E4E7EC`), rounded corners (`10dp`), focused border (`2px #218C5A`). Clear error message rendered below in `#C83D3D`.

---

## 3. Feedback & State Components

### 3.1 `FBStatusChip`
Multi-state pill chip representing the 12 donation lifecycle stages.

- **Implementation Rule:** Never relies on color alone; every chip renders a distinct status icon alongside clear text.
- **States:**
  - `listed`: Icon `Icons.check_circle_outline`, Text "Available"
  - `claimed`: Icon `Icons.lock_clock`, Text "Claimed by NGO"
  - `assigned`: Icon `Icons.two_wheeler`, Text "Volunteer Assigned"
  - `pickedUp`: Icon `Icons.local_shipping`, Text "In Transit"
  - `delivered`: Icon `Icons.task_alt`, Text "Delivered"
  - `cancelled`: Icon `Icons.cancel_outlined`, Text "Cancelled"
  - `expired`: Icon `Icons.timer_off_outlined`, Text "Expired"

### 3.2 `FBEmptyState`
Standard empty state visual illustration with clear guidance and action CTA.

- **Properties:**
  ```dart
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  ```

### 3.3 `FBLoadingIndicator`
- Circular progress spinner with brand tint (`#218C5A`).
- Skeleton shimmer placeholder (`FBSkeletonLoader`) for feed item loading.

### 3.4 `FBErrorView`
Full-screen error view with retry action button and connection error diagnostics.

---

## 4. Card & Container Components

### 4.1 `DonationFeedCard`
- Used across NGO Explore and Donor Listings.
- Displays category icon (Food bowl vs Clothing hanger), title, quantity badge, distance/locality, and urgency countdown badge.
- Responsive layout adapting from single-column mobile to multi-column tablet/web.

### 4.2 `RiderDispatchCard`
- High-contrast card with 2px brand border.
- Features unlocked donor street address, one-touch phone dial action, and the 56dp "Confirm Physical Pickup" / "Confirm Handover" action.
