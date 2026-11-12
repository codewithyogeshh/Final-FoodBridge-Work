# FoodBridge — User Personas & Archetype Profiles

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 2 — Design Thinking & Empathy Mapping  
**Status:** Completed  
**Methodological Note:** These personas represent archetypes synthesized from real-world food rescue workflows, NGO field operations, and volunteer logistics. All demographic details and behavioral habits represent *Modelled Hypotheses & Personas* to guide design decisions.

---

## 1. Persona: Ramesh Sharma (Commercial Food Donor)

```
┌────────────────────────────────────────────────────────────────────────┐
│ RAMESH SHARMA — 44 Years Old | Mumbai, India                           │
│ Role: General Manager, Royal Feast Banquet Hall & Catering             │
│ Tech Literacy: Moderate (WhatsApp, Android Phone, Point-of-Sale Apps) │
│ Environment: High-stress, fast-paced commercial banquet kitchen        │
└────────────────────────────────────────────────────────────────────────┘
```

### Bio & Background
Ramesh has managed banquet and wedding catering operations for over 15 years. His facility frequently hosts 300–800 guest events. At the conclusion of events (around 10:30 PM to midnight), there is routinely 20 to 60 kg of fresh, untouched prepared food (curries, dal, rice, breads, desserts). Ramesh despises waste but kitchen staff are eager to close, clean, and go home by 11:30 PM.

### Goals
- Ensure surplus banquet food reaches hungry people rather than municipal garbage dumps.
- Complete the donation posting in **under 2 minutes** without lengthy forms.
- Guarantee that a verified volunteer arrives before his kitchen shutters close.
- Safeguard the restaurant's reputation with clear food safety disclaimers.

### Pain Points & Anxieties
- **Time Pressure:** Cannot afford back-and-forth phone negotiations during late-night kitchen closing.
- **Unreliable Volunteers:** Previous experiences with informal groups where no one showed up after promise.
- **Legal Liability Fear:** Worried someone might get sick if food is mistreated after handover, risking his business.

### Design Requirements for Ramesh
- Extremely streamlined 3-step donation form with smart defaults (e.g., standard box units, quick category chips).
- Mandatory collection countdown timer visible to both donor and applicant NGOs.
- Automatic volunteer arrival notification so staff can have packages ready at the rear service entrance.

---

## 2. Persona: Priya Kulkarni (Household & Clothing Donor)

```
┌────────────────────────────────────────────────────────────────────────┐
│ PRIYA KULKARNI — 36 Years Old | Pune, India                            │
│ Role: IT Consultant & Sustainable Living Advocate                      │
│ Tech Literacy: High (iOS & Android, E-commerce, Digital Banking)       │
│ Environment: Busy urban apartment, conscious consumer                  │
└────────────────────────────────────────────────────────────────────────┘
```

### Bio & Background
Priya lives with her spouse and two growing children. Every six months during festive seasons or wardrobe transitions, she gathers bags of gently used, high-quality children’s clothes, school winter wear, and unused packaged groceries. She wants these items to directly benefit orphanages or women's shelters rather than sitting forgotten in closets.

### Goals
- Donate wearable garments and dry groceries to vetted, authentic organizations.
- Know the exact guidelines for cleanliness, condition, and sizes before donating.
- Keep her private residential address hidden from public bulletin boards.

### Pain Points & Anxieties
- **Privacy Intrusion:** Uncomfortable having her phone number or exact apartment door number posted publicly.
- **Ambiguity:** Frustrated by organizations that take clothes only to discard them or leave them outdoors.

### Design Requirements for Priya
- Two-tier privacy shielding: only approximate neighborhood displayed until an NGO/volunteer is officially confirmed.
- Clear condition chips (`Like New`, `Good Condition`) and cleanliness confirmation checkboxes.
- Digital impact feedback notifying her when her donation is successfully distributed.

---

## 3. Persona: Sunita Deshmukh (NGO Operations Manager)

```
┌────────────────────────────────────────────────────────────────────────┐
│ SUNITA DESHMUKH — 51 Years Old | Thane / Navi Mumbai, India            │
│ Role: Shelter Director, Annapoorna Welfare Trust                       │
│ Tech Literacy: Moderate (Basic Android Smartphone, Spreadsheets)       │
│ Environment: Busy night shelter feeding 120+ destitute individuals     │
└────────────────────────────────────────────────────────────────────────┘
```

### Bio & Background
Sunita has run a destitute community night shelter and day care for over 12 years. Her organization operates on shoestring budgets funded by modest private donors. Feeding 120 people every day requires considerable expenditure. Reliable surplus food donations reduce their operating groceries bill by up to 35%, allowing funds to be directed towards healthcare and education.

### Goals
- Find reliable, wholesome food donations within a 5–10 km radius of her shelter.
- Know dietary details (vegetarian/non-vegetarian, spice level, preparation time) before claiming.
- Secure volunteer delivery assistance because the shelter does not have a dedicated van.

### Pain Points & Anxieties
- **Food Spoilage Risk:** Terrified of serving compromised food to vulnerable elderly residents or children.
- **Race Condition Frustration:** Seeing a donation online, calling to claim it, only to hear another group already took it.
- **Administrative Burden:** Hates tedious software requiring complex reporting when she has people to feed.

### Design Requirements for Sunita
- Clear verification badge unlocking instant, atomic claim capabilities.
- Proximity-based discovery feed with prominent dietary indicators and collection countdowns.
- Right of physical refusal at handover with simple drop-down reason logging.
- Simplified distribution logging (summary counts: e.g., "120 meals served") with zero PII demands.

---

## 4. Persona: Rahul Patil (Community Volunteer — Special Logistics Focus)

```
┌────────────────────────────────────────────────────────────────────────┐
│ RAHUL PATIL — 22 Years Old | Mumbai Suburbs, India                     │
│ Role: Final-Year Engineering Student & Active Civic Volunteer          │
│ Tech Literacy: Very High (Tech Native, Maps, Social Apps, Gig Delivery)│
│ Vehicle: 125cc Two-Wheeler (Motorcycle) with rear luggage box          │
└────────────────────────────────────────────────────────────────────────┘
```

### Bio & Background
Rahul is an energetic college student who volunteers 6 to 8 hours a week between classes and evenings. He travels on his motorcycle across his suburb. He wants to help bridge the last-mile collection gap by picking up food from banquet halls and delivering it directly to Sunita's shelter. He has a smartphone mounted on his motorcycle handlebar.

### Goals
- Quickly scan open tasks on a map/feed during his free evenings (6:00 PM – 10:00 PM).
- Claim an assignment with a single tap, knowing the task is locked exclusively to him.
- Access clear navigation coordinates and the donor’s phone number with one tap.
- Complete the entire cycle (pickup $\rightarrow$ transit $\rightarrow$ handover) with minimal app friction.

### Pain Points & Anxieties
- **Small Screens / Tiny Buttons:** Trying to tap tiny buttons while wearing riding gloves or stopped at a red light in bright sunlight.
- **Wasted Trips & Phantom Tasks:** Arriving at a donor’s kitchen only to discover someone else collected the food 10 minutes earlier.
- **Impossible Cargo Loads:** Accepting a task only to discover the donor has 100 kg of heavy crates that cannot fit on a motorcycle.
- **Unresponsive Contacts:** Standing outside a residential gate unable to contact the donor because the phone number is missing.

### Design Requirements for Rahul
- **Large Action Targets ($\ge 48\text{ dp}$)** with high contrast (`#218C5A` primary green against white/cream).
- Cargo feasibility indicators (e.g., "Motorcycle Friendly: $\le 10\text{ kg}$" vs. "Four-Wheeler / Van Required").
- Atomic single-volunteer lock: once tapped, the task is immediately locked to him.
- Emergency release toggle if his bike gets a flat tire, allowing instant re-dispatch before food spoils.

---

## 5. Persona: Vikramaditya "Vikram" Sen (Platform Administrator)

```
┌────────────────────────────────────────────────────────────────────────┐
│ VIKRAMADITYA SEN — 38 Years Old | Pune / Remote                        │
│ Role: Head of Operations & Community Trust, FoodBridge Foundation      │
│ Tech Literacy: Expert (Web Admin Portals, Analytics, PostgreSQL Tools) │
│ Environment: Multi-monitor operations workstation                      │
└────────────────────────────────────────────────────────────────────────┘
```

### Bio & Background
Vikram oversees community compliance, NGO verification, and incident management. He is accountable for ensuring that every organization on FoodBridge is a genuine legal entity and that fraudulent or exploitative actors are swiftly barred.

### Goals
- Review and verify new NGO registration credentials within 24 hours of submission.
- Monitor active redistribution flows across pilot districts in real time.
- Rapidly investigate and arbitrate any dispute (e.g., food safety complaint or volunteer no-show).
- Ensure full auditability across all lifecycle transitions.

### Pain Points & Anxieties
- Unclear or falsified NGO registration certificates that slip through verification.
- Lack of audit visibility if a dispute arises regarding who modified a donation record.

### Design Requirements for Vikram
- Dedicated admin portal featuring split-screen document viewer for comparing submitted certificates with official registries.
- Instant suspension and account flagging controls with mandatory reason logging.
- Real-time audit logs table tracking actor, timestamp, and state transitions.

