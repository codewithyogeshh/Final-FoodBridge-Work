# FoodBridge — Low-Fidelity Wireframes & Screen Layout Schematics

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 2 — Design Thinking & Empathy Mapping  
**Status:** Completed  
**Methodological Note:** These wireframe schematics represent structural information hierarchies and visual interaction layouts. All components adhere to the design guidelines: $\ge 48\text{ dp}$ touch targets, high-contrast indicators, and plain-language status labels.

---

## 1. Shared Foundation Screens

### WF-01: Onboarding & Role Selection Screen
```
┌────────────────────────────────────────────────────────┐
│ [Logo] FoodBridge                                      │
│ "Share More. Waste Less. Bridge the Need."             │
├────────────────────────────────────────────────────────┤
│                                                        │
│  [ Illustration: Hand connecting food & clothing ]     │
│                                                        │
│  Choose how you want to participate:                   │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ [Icon: Heart/Food]  I WANT TO DONATE             │  │
│  │ Commercial kitchens, caterers & individuals      │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ [Icon: Building/Hands]  WE ARE AN NGO / SHELTER  │  │
│  │ Verified non-profits & community kitchens        │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ [Icon: Two-Wheeler]  I WANT TO VOLUNTEER         │  │
│  │ Transport & deliver food/clothes in my area      │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  Already have an account? [ Sign In Link ]             │
│                                                        │
│  Language: [ English ▼ ] (Hindi | Marathi)            │
└────────────────────────────────────────────────────────┘
```

### WF-02: Sign In / Registration Screen
```
┌────────────────────────────────────────────────────────┐
│ ← Back                                   FoodBridge    │
├────────────────────────────────────────────────────────┤
│  Create Your Donor Account                             │
│  Join hundreds of food heroes in your city             │
│                                                        │
│  Full Name / Organization                              │
│  [ Ramesh Sharma / Royal Feast Banquet              ]  │
│                                                        │
│  Email Address                                         │
│  [ ramesh.catering@example.com                      ]  │
│                                                        │
│  Mobile Number (For pickup coordination)               │
│  [ +91  98765 43210                                 ]  │
│                                                        │
│  Password (min 8 characters)                           │
│  [ ••••••••••••••••                                 ]  │
│                                                        │
│  Primary Operating Locality                            │
│  [ Andheri West, Mumbai                             ]  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ [ REGISTER AS DONOR — Min 48dp Touch Target ]    │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  By registering, you agree to the FoodBridge Safety    │
│  and Privacy Charter.                                  │
└────────────────────────────────────────────────────────┘
```

---

## 2. Donor Screens

### WF-03: Donor Home Dashboard
```
┌────────────────────────────────────────────────────────┐
│ FoodBridge                   [Bell: 2] [Profile Avatar]│
│ Hello, Ramesh (Royal Feast)                            │
├────────────────────────────────────────────────────────┤
│  CREATE A NEW DONATION                                 │
│  ┌─────────────────────────┬─────────────────────────┐ │
│  │ [Icon: Hot Meal]        │ [Icon: Garment]         │ │
│  │ DONATE SURPLUS FOOD     │ DONATE CLOTHES          │ │
│  │ Cooked, Groceries, Breads│ Wearable, clean items  │ │
│  │ (Tap to start)          │ (Tap to start)          │ │
│  └─────────────────────────┴─────────────────────────┘ │
│                                                        │
│  ACTIVE DONATIONS (1)                                  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 🍛 35 kg Mixed Curry & Biryani Boxes             │  │
│  │ Status: [🔵 REQUESTED BY ANNAPOORNA SHELTER]      │  │
│  │ Collection Deadline: 11:45 PM (42 mins left) ⏳  │  │
│  │ Volunteer: Rahul P. (Assigned — In Transit 🛵)    │  │
│  │ [ VIEW DETAILS / TIMELINE ]                       │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  YOUR IMPACT THIS MONTH                                │
│  ┌──────────────────┬──────────────────┬─────────────┐ │
│  │ 180 kg Food      │ 450 Meals        │ 240 kg CO2  │ │
│  │ Rescued          │ Served           │ Diverted    │ │
│  └──────────────────┴──────────────────┴─────────────┘ │
├────────────────────────────────────────────────────────┤
│ [Home]         [My Donations]        [Impact] [Profile]│
└────────────────────────────────────────────────────────┘
```

### WF-04: Create Food Donation (Form Layout)
```
┌────────────────────────────────────────────────────────┐
│ ← Back              Donate Food           Step 1 of 3  │
├────────────────────────────────────────────────────────┤
│  Donation Title                                        │
│  [ 35 kg Surplus Banquet Curries & Rice             ]  │
│                                                        │
│  Food Category                                         │
│  (•) Cooked Meals  ( ) Packaged Dry  ( ) Fresh Produce │
│                                                        │
│  Quantity & Measuring Unit                             │
│  [ 35               ]   Unit: [ Kilograms (kg) ▼ ]    │
│  Approximate Meal Count: ~90 Portions                  │
│                                                        │
│  Preparation Timestamp                                 │
│  [ Today, 20:30 (8:30 PM)                           ]  │
│                                                        │
│  Safe Collection Deadline (Mandatory)                  │
│  [ Today, 23:45 (11:45 PM) — In 1 hr 15 mins       ]  │
│                                                        │
│  Storage & Holding Condition                           │
│  [🔥 Hot Holding (>63°C)] [❄️ Refrigerated] [Ambient]   │
│                                                        │
│  Known Allergens                                       │
│  [X] Dairy  [X] Nuts  [ ] Gluten  [ ] None Known       │
│                                                        │
│  Two-Tier Pickup Location                              │
│  Public Zone: [ Andheri West, Zone 2                ]  │
│  Private Gate Address (Hidden until volunteer assigned)│
│  [ Service Gate 3, Royal Feast Hall, Link Road      ]  │
│                                                        │
│  [X] Mandatory Declaration: I certify this food was   │
│      prepared hygienically and stored responsibly.     │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ [ PUBLISH DONATION NOW — 48dp ]                  │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

---

## 3. NGO Screens

### WF-05: NGO Discovery Feed
```
┌────────────────────────────────────────────────────────┐
│ FoodBridge NGO               [Filter] [Search] [Profile]│
│ Annapoorna Welfare Trust (Verified ✓)                  │
├────────────────────────────────────────────────────────┤
│  FILTERS: [All Types ▼] [Within 8 km ▼] [Urgent ⏳]     │
├────────────────────────────────────────────────────────┤
│  AVAILABLE DONATIONS NEAR YOU                          │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 🍛 Cooked Meals — 35 kg (~90 Meals)              │  │
│  │ Royal Feast Banquet | Andheri West (~3.8 km away)│  │
│  │ Storage: Hot Holding | Veg & Non-Veg separated   │  │
│  │ ⏳ EXPIRES IN: 52 Minutes (Deadline: 11:45 PM)    │  │
│  │                                                  │  │
│  │ [ REQUEST THIS DONATION — Full 35 kg ]           │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 👕 Children & Adult Winter Wear — 25 Pieces      │  │
│  │ Clean & Washed Sweaters | Bandra West (6.2 km)   │  │
│  │ Condition: Like New / Gently Used                │  │
│  │ ⏳ Pickup Window: Next 48 Hours                   │  │
│  │                                                  │  │
│  │ [ REQUEST THIS DONATION ]                        │  │
│  └──────────────────────────────────────────────────┘  │
├────────────────────────────────────────────────────────┤
│ [Explore]       [My Requests]       [Records] [Profile]│
└────────────────────────────────────────────────────────┘
```

### WF-06: NGO Request & Logistics Selection Modal
```
┌────────────────────────────────────────────────────────┐
│  Request Surplus Food Donation                         │
│  35 kg Cooked Banquet Meals (~90 Portions)             │
├────────────────────────────────────────────────────────┤
│  Requested Quantity:                                   │
│  [ 35           ] kg (Remaining Available: 35 kg)      │
│                                                        │
│  Logistics Options:                                    │
│  ( ) We will collect directly using our own transport  │
│  (•) We request a FoodBridge Volunteer for delivery    │
│                                                        │
│  Shelter Delivery Address:                             │
│  Annapoorna Night Shelter, Gate 2, Station Road        │
│                                                        │
│  Special Handling Note for Volunteer:                  │
│  [ Please bring into kitchen loading dock directly  ]  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ [ CONFIRM CLAIM REQUEST — Locks Quantity ]       │  │
│  └──────────────────────────────────────────────────┘  │
│  [ Cancel ]                                            │
└────────────────────────────────────────────────────────┘
```

---

## 4. Volunteer Screens (Special Logistics Focus)

### WF-07: Volunteer Available Tasks Feed ("Rider Mode")
```
┌────────────────────────────────────────────────────────┐
│ FoodBridge Volunteer                [Status: Online 🟢]│
│ Rahul Patil | Motorcycle Rider (125cc)                 │
├────────────────────────────────────────────────────────┤
│  ACTIVE TASKS: 0 / Max 2                               │
├────────────────────────────────────────────────────────┤
│  OPEN PICKUP TASKS NEAR YOU                            │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 🛵 TWO-WHEELER COMPATIBLE (~12 kg per bag / 3 pk)│  │
│  │ 🍛 35 kg Hot Meals (Banquet to Annapoorna)       │  │
│  │ Route: Andheri West ──► Thane West (4.2 km total)│  │
│  │ Pickup Window: NOW until 11:30 PM (35 mins left) │  │
│  │ NGO: Annapoorna Shelter                          │  │
│  │                                                  │  │
│  │ ┌──────────────────────────────────────────────┐ │  │
│  │ │ [ ⚡ ACCEPT TASK — EXCLUSIVE CLAIM ]         │ │  │
│  │ └──────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 🚗 FOUR-WHEELER / VAN REQUIRED (Heavy Load: 80kg)│  │
│  │ 📦 4 Large Crates of Apples & Bread              │  │
│  │ Route: Dadar Market ──► Sion Care Home           │  │
│  │ [ Task details — requires larger vehicle ]       │  │
│  └──────────────────────────────────────────────────┘  │
├────────────────────────────────────────────────────────┤
│ [Tasks]              [Active Delivery]        [History]│
└────────────────────────────────────────────────────────┘
```

### WF-08: Active Volunteer Task Execution Screen
```
┌────────────────────────────────────────────────────────┐
│ ← Emergency Surrender Task          DISPATCH #FB-804   │
├────────────────────────────────────────────────────────┤
│  STATUS: [ 🟡 ASSIGNED — PROCEED TO PICKUP ]           │
│  Deadline Countdown: 32 mins remaining ⏳              │
│                                                        │
│  PICKUP LOCATION (Unlocked):                           │
│  Royal Feast Banquet Hall                              │
│  Rear Service Gate 3, Link Road, Andheri West          │
│  Donor Contact: Ramesh Sharma                          │
│                                                        │
│  ┌─────────────────────────┬─────────────────────────┐ │
│  │ [ 📞 CALL DONOR ]       │ [ 🗺️ OPEN MAPS ]        │ │
│  └─────────────────────────┴─────────────────────────┘ │
│                                                        │
│  CARGO DETAILS:                                        │
│  3 insulated crates | 35 kg hot curry & rice           │
│                                                        │
│  DESTINATION NGO:                                      │
│  Annapoorna Night Shelter, Station Road, Thane         │
│                                                        │
│  ════════════════════════════════════════════════════  │
│  PHYSICAL VERIFICATION STEP 1:                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ [  CONFIRM PHYSICAL PICKUP (Haptic Tap)  ]       │  │
│  │ (Tap only after items are loaded onto vehicle)   │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  [ ⚠️ Report Issue / Vehicle Breakdown ]               │
└────────────────────────────────────────────────────────┘
```

### WF-09: Handover & Receipt Confirmation Screen
```
┌────────────────────────────────────────────────────────┐
│ DISPATCH #FB-804                     Status: At Shelter│
├────────────────────────────────────────────────────────┤
│  STATUS: [ 🟢 AT DESTINATION — HANDOVER ]              │
│                                                        │
│  Destination: Annapoorna Night Shelter                 │
│  Receiver: Sunita Deshmukh (Director)                  │
│                                                        │
│  PHYSICAL INSPECTION CHECKLIST:                        │
│  [✓] All 3 crates delivered intact                     │
│  [✓] Food checked for aroma & temperature by receiver  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ [  CONFIRM HANDOVER TO NGO (Complete)  ]         │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  Or if food condition is compromised:                  │
│  [ ❌ Receiver Rejects Food (Inspection Failure) ]     │
└────────────────────────────────────────────────────────┘
```

---

## 5. Administrator Screen

### WF-10: Admin Split-Screen Verification Console
```
┌────────────────────────────────────────────────────────────────────────┐
│ FoodBridge Admin Console                 [Pending: 4] [Audit] [Logout] │
├───────────────────────────────────┬────────────────────────────────────┤
│ APPLICANT NGO DETAILS             │ SUBMITTED REGISTRATION PROOFS      │
│ Organization: Annapoorna Trust    │ Document: 12A_80G_Cert.pdf         │
│ Reg No: MH/2021/004281            │ ┌────────────────────────────────┐ │
│ Contact: Sunita Deshmukh          │ │ [PDF PREVIEWER]                │ │
│ Phone: +91 98200 11223            │ │ Government of India            │ │
│ Operational Radius: 12 km         │ │ Income Tax Exemption 80G       │ │
│ Shelter Capacity: 150 Beds        │ │ Valid Through: 2028            │ │
│ Submitted: Today at 09:15 AM      │ └────────────────────────────────┘ │
│                                   │                                    │
│ Verification Checklist:           │ Reason / Audit Note:               │
│ [X] Registration ID valid         │ [ Verified against State portal  ] │
│ [X] Service address confirmed     │                                    │
│                                   │ ┌────────────────────────────────┐ │
│                                   │ │ [ APPROVE NGO VERIFICATION ]   │ │
│                                   │ └────────────────────────────────┘ │
│                                   │ [ Reject with Feedback ]           │
└───────────────────────────────────┴────────────────────────────────────┘
```

