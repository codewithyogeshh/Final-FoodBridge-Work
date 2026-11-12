# FoodBridge Screen Specifications

This document defines the layout specifications, UI states, validation rules, and responsive behaviors for all core FoodBridge screens.

---

## 1. Shared Screens

### 1.1 Splash Screen (`/`)
- **Layout:** Centered brand logo (Gradient Leaf-Bridge emblem), Tagline: *"Share More. Waste Less. Bridge the Need."*, Minimal circular spinner.
- **Timing:** 1500ms duration.
- **States:**
  - Token valid: Redirect to respective role dashboard (`/donor`, `/ngo`, `/volunteer`, `/admin`).
  - Token absent: Redirect to `/onboarding`.

### 1.2 Onboarding Screen (`/onboarding`)
- **Layout:** Welcome hero banner, 3 high-contrast role selection cards:
  1. *I Want to Donate (Food / Clothes)*
  2. *We are an NGO / Shelter*
  3. *I Want to Volunteer as a Rider*
- **Actions:** Tapping card passes role parameter to `/register?role=<key>`. Bottom bar has "Already have an account? Sign In" routing to `/login`.

### 1.3 Login Screen (`/login`)
- **Layout:** Brand header, Email and Password fields, Quick Demo Role selector chips, "Forgot Password?" link, "Sign In" button, and Register link.
- **Validation:** Valid RFC-5322 email format; Password minimum 6 characters.

### 1.4 Registration Screen (`/register`)
- **Layout:** Role selector tab group, Full Name, Email, Phone Number, Password, Role-specific fields (Organization Legal Name & Darpan ID for NGOs), and Mandatory Safety Charter Checkbox.
- **Validation:** Real-time form validation; NGO Darpan ID format validation (`MH/YYYY/XXXXXXX`).

### 1.5 Profile & Settings (`/profile`)
- **Layout:** User avatar, role verification badge, profile details, "Switch Active Role View" card, Dark Mode / Night Rider Mode toggle, and Language selector (`English`, `हिंदी`, `मराठी`).

### 1.6 Notifications Screen (`/notifications`)
- **Layout:** Chronological list of push & in-app alerts (Donation claimed, volunteer assigned, dispatch updates, verification status change).

---

## 2. Donor Screens

### 2.1 Donor Dashboard (`/donor`)
- **Layout:** Welcome header with business/donor name, Quick action cards: "Donate Food" & "Donate Clothes", "My Active Listings" feed with countdown timer, and Community Impact Counters (Meals Rescued, Clothes Shared, CO₂ Prevented).
- **Floating Action:** Persistent 56dp FAB `+ New Donation`.

### 2.2 Create Donation Screen (`/create-donation`)
- **Layout:**
  - Segmented toggle: `Food Surplus` vs. `Clothing`.
  - Item Title, Description, Quantity and Unit.
  - Food Mode: Pure Vegetarian toggle, Storage condition (`Ambient`, `Hot-Holding >63°C`, `Chilled <5°C`), Allergen notes, and FSSAI Hygiene declaration checkbox.
  - Clothing Mode: Category chips (`Winter`, `Kids`, `Blankets`, `Adults`), Condition grade (`Brand New`, `Like New`, `Wearable`), and Washed/Clean checkbox.
  - Mandatory Collection Deadline picker (Date + Time).
  - Pickup Address input with location landmarks.

### 2.3 Donation Details Screen (`/donation-detail/:id`)
- **Layout:** Status chip, countdown urgency pill, title, quantity, packaging details, dietary/condition specs, mandatory collection deadline, stakeholder participant cards (Donor, Claiming NGO, Assigned Volunteer), and contextual action buttons.

---

## 3. NGO Screens

### 3.1 NGO Dashboard / Explore (`/ngo`)
- **Layout:** Verified Shelter banner (with Darpan ID verification badge), Category filter pills (`All`, `Surplus Food 🍛`, `Clothing 👕`, `Expiring Soon ⏳`), Available donations near shelter feed, and "Our Active Claims" list.
- **Actions:** Tapping card opens details; "Claim Donation" button triggers claim modal sheet with collection commitment.

---

## 4. Volunteer Screens ("Rider Mode")

### 4.1 Volunteer Dashboard (`/volunteer`)
- **Layout:**
  - Online/Offline toggle switch with status indicator.
  - Active vehicle badge: "Motorcycle Dispatcher".
  - Active Dispatch Card (Highlighted with 2px brand border): Unlocks private donor address, phone dialer button, and primary 56dp action button.
  - Open Task Feed: Displays route endpoints, cargo weight, vehicle capability tag, and countdown.
- **1-Touch Transitions:**
  - `Assigned` ➔ **CONFIRM PHYSICAL PICKUP** (transitions to `pickedUp`).
  - `In Transit` ➔ **CONFIRM HANDOVER TO NGO** (transitions to `delivered`).

---

## 5. Admin Screens

### 5.1 Admin Console (`/admin`)
- **Layout:** Key metrics bar (Pending NGOs, Active Listings, Total Rescued Meals, Clothes Distributed), Pending NGO Verification Queue (with PDF certificate preview, Approve and Reject actions), and Real-time System Audit Stream.
