# FoodBridge — User Personas & Archetype Specifications (Design Thinking Stage 2)

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 2 — Design Thinking & User Research  
**Status:** Completed  
**Deliverable Location:** `docs/design-thinking/personas.md`  

---

## ⚠️ Research Methodology & Assumptions

The following five personas are **modelled archetypes** formulated from real-world operations in commercial catering, non-profit community shelters, urban volunteer courier logistics, and digital platform administration. All demographic data and personal vignettes are explicitly designated as *Simulated Design Personas*.

---

## 1. Persona 1: Commercial Food Donor

```
┌────────────────────────────────────────────────────────────────────────┐
│ RAMESH SHARMA — 44 Years Old | Mumbai, India                           │
│ Role: General Manager, Royal Feast Banquet Hall & Catering             │
│ Tech Familiarity: Moderate (WhatsApp, Android Phone, Restaurant POS)   │
│ Accessibility Need: High contrast, large text, low cognitive load      │
│ Operational Context: Fast-paced, noisy kitchen during late-night close │
└────────────────────────────────────────────────────────────────────────┘
```

### Goals & Motivations
- Rescue wholesome surplus cooked food (curries, rice, breads) after large weddings and banquets.
- Complete donation posting in **under 90 seconds** without complicated menus or delays.
- Ensure verified pickup happens before kitchen staff lock up and depart (around 11:30 PM).
- Protect business reputation through clear food safety disclaimers and verified NGO partnerships.

### Frustrations & Pain Points
- **Severe Time Scarcity:** Staff cannot wait around after a 12-hour shift for late volunteers.
- **Unreliable Ad-Hoc Groups:** Burned by past experiences where informal WhatsApp groups promised pickup but never showed up.
- **Fear of Legal Backlash:** Anxious about legal liability if food spoils after leaving his premises.

### Key Behavioral Traits
- Highly pragmatic; uses quick-select options and defaults rather than typing custom prose.
- Delegates physical handover to the kitchen supervisor at the rear loading dock.
- Values digital CSR impact receipts to show banquet owners and corporate clients.

---

## 2. Persona 2: Sustainable Clothing & Household Donor

```
┌────────────────────────────────────────────────────────────────────────┐
│ PRIYA KULKARNI — 36 Years Old | Pune, India                            │
│ Role: IT Consultant & Sustainable Living Advocate                      │
│ Tech Familiarity: High (iOS/Android Native, E-commerce, Mobile Banking)│
│ Accessibility Need: Intuitive UI, transparent privacy indicators       │
│ Operational Context: Busy urban apartment, seasonal wardrobe cleanouts │
└────────────────────────────────────────────────────────────────────────┘
```

### Goals & Motivations
- Donate clean, wearable adult clothing, winter coats, and children's school wear to authentic charities.
- Understand exact clothing condition and hygiene standards before packaging.
- Protect personal home privacy: strictly prevent public exposure of her residential address or phone number.

### Frustrations & Pain Points
- **Privacy Intrusion:** Uncomfortable having her phone number or exact apartment door number posted on public boards.
- **Dumping Ground Stigma:** Upset by charitable groups that take donated clothes only to discard or resell them.
- **Ambiguity:** Unclear guidelines on whether items should be boxed, bagged, or folded.

### Key Behavioral Traits
- Meticulous; washes and folds clothes before donation.
- Takes clear photographs to showcase item quality.
- Appreciates confirmation notifications when items are handed out to families.

---

## 3. Persona 3: NGO Operations Coordinator

```
┌────────────────────────────────────────────────────────────────────────┐
│ SUNITA DESHMUKH — 51 Years Old | Thane / Navi Mumbai, India            │
│ Role: Shelter Director, Annapoorna Welfare Trust                       │
│ Tech Familiarity: Moderate (Basic Android Smartphone, Spreadsheets)    │
│ Accessibility Need: Scalable typography, high contrast, simple flows   │
│ Operational Context: High-stress night shelter feeding 120+ residents  │
└────────────────────────────────────────────────────────────────────────┘
```

### Goals & Motivations
- Secure predictable supplies of wholesome cooked food to nourish 120 destitute shelter residents nightly.
- Reduce shelter monthly food purchasing costs by up to 35% through surplus recovery.
- Obtain volunteer delivery assistance because the shelter does not own a dedicated delivery vehicle.
- Maintain rigorous food safety inspection standards to protect vulnerable elderly and child residents.

### Frustrations & Pain Points
- **Food Spoilage Anxiety:** Deeply fearful of receiving compromised or cold food that causes foodborne illness.
- **Race Condition Losses:** Spotting a donation online, only to find another charity took it 5 minutes earlier.
- **Administrative Fatigue:** Hates tedious software requiring complex reporting when she has hungry people to feed.

### Key Behavioral Traits
- Performs mandatory sensory inspection (temperature, aroma, visual) upon delivery.
- Values atomic reservation locks that guarantee claimed food will arrive.
- Prefers quick aggregate metric entry ("120 meals served") over invasive beneficiary forms.

---

## 4. Persona 4: Community Field Volunteer (Special Logistics Focus)

```
┌────────────────────────────────────────────────────────────────────────┐
│ RAHUL PATIL — 22 Years Old | Mumbai Suburbs, India                     │
│ Role: Final-Year Engineering Student & Civic Volunteer                 │
│ Tech Familiarity: Very High (Mobile Native, Navigation Apps, Gig Apps) │
│ Vehicle: 125cc Two-Wheeler (Motorcycle) with rear luggage rack         │
│ Accessibility Need: "Rider Mode" (56dp buttons), haptics, glove-taps   │
│ Operational Context: Operating outdoors in traffic, rain, and glare   │
└────────────────────────────────────────────────────────────────────────┘
```

### Goals & Motivations
- Spend 1–2 flexible evening hours performing high-impact community food and clothing rescue dispatches.
- Scan open tasks on a feed and claim one instantly with an exclusive single-volunteer lock.
- Access precise GPS navigation coordinates and donor phone numbers with a single tap.
- Complete the entire cycle (pickup $\rightarrow$ transit $\rightarrow$ handover) without typing text on the road.

### Frustrations & Pain Points
- **Tiny Buttons & Dense Menus:** Trying to tap small icons while wearing motorcycle gloves or stopped at traffic lights.
- **Phantom Tasks:** Arriving at a donor location only to discover another volunteer already took the items.
- **Unrealistic Cargo Loads:** Accepting a task only to discover the donor has 80 kg of crates impossible to transport on a bike.
- **Dead-End Communication:** Standing outside locked apartment gates unable to contact the donor.

### Key Behavioral Traits
- Mounts phone on motorcycle handlebars; relies on voice navigation and one-touch status buttons.
- Values clear vehicle suitability badges (`🛵 Two-Wheeler Friendly` vs. `🚗 Four-Wheeler Required`).
- Demands a quick emergency release button if he gets a flat tire or mechanical breakdown.

---

## 5. Persona 5: Platform Administrator

```
┌────────────────────────────────────────────────────────────────────────┐
│ VIKRAMADITYA SEN — 38 Years Old | Pune / Remote                        │
│ Role: Head of Community Trust & Safety, FoodBridge Foundation          │
│ Tech Familiarity: Expert (Web Consoles, Relational Databases, Metrics) │
│ Accessibility Need: Dense desktop data views, keyboard shortcuts       │
│ Operational Context: Multi-monitor operations workstation              │
└────────────────────────────────────────────────────────────────────────┘
```

### Goals & Motivations
- Rigorously review and verify applicant NGO registration certificates within 24 hours of filing.
- Monitor active redistribution flows in real time to detect geographic bottlenecks or stalled rescues.
- Swiftly investigate and resolve disputes (food quality complaints, unpunctual volunteers, or no-shows).
- Maintain an indisputable, immutable audit trail for legal compliance and trust.

### Frustrations & Pain Points
- **Fraudulent Impersonators:** Fake charities attempting to access free surplus food for commercial resale.
- **Disjointed Verification:** Having to switch between PDF document viewers and government tax portals.
- **He-Said-She-Said Disputes:** Lack of objective timestamp data when donors and couriers disagree on timing.

### Key Behavioral Traits
- Thorough and methodical; relies on split-screen verification tools.
- Monitors live system telemetry and acts immediately on stalled tasks near collection deadlines.
- Enforces strict zero-tolerance policies against privacy breaches or unhygienic practices.

