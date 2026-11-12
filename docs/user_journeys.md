# FoodBridge — User Journey Maps & Service Blueprint

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 2 — Design Thinking & Empathy Mapping  
**Status:** Completed  
**Methodological Note:** These journey maps outline the step-by-step user interactions, emotional states, touchpoints, and opportunities across our four core stakeholder personas. All journey assumptions represent *Modelled Hypotheses* to be verified during field pilots.

---

## 1. Journey A: Commercial Food Donor (Ramesh Sharma)

**Scenario:** Post-banquet late-night surplus food rescue (35 kg mixed cooked food, 10:45 PM).

| Stage | Actions Taken | Touchpoints | Emotional State | Friction / Pain Point | Moment of Truth / Opportunity |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **1. Trigger & Awareness** | Banquet concludes; chef informs Ramesh that 35 kg of good food remains unserved. | Kitchen floor, commercial food warmers. | Stressed, guilty seeing food waste. | Kitchen staff want to close up immediately and leave. | Immediate reminder that FoodBridge allows rapid 90-second donation posting. |
| **2. Listing Creation** | Opens FoodBridge app; taps "Donate Food"; selects Cooked Meals, enters quantity (35 kg / ~90 boxes). | FoodBridge Mobile App (Donor Form). | Focused, seeking speed. | Typing detailed descriptions on mobile while standing in a busy kitchen. | Smart defaults, quick-select chips (`Cooked Meals`, `Hot Holding`), and photo capture. |
| **3. Safety & Deadline Declaration** | Sets pickup deadline (11:45 PM / 1 hour limit); ticks mandatory hygiene declaration. | Expiry & Declaration UI widget. | Cautious regarding liability. | Hesitation about legal liability if food spoils after pickup. | Clear disclaimer: FoodBridge facilitates connection; receiving NGO verifies food at handover. |
| **4. Location & Publishing** | Approximate locality set automatically via GPS; enters kitchen rear gate pickup instructions. | Location picker & form submission. | Anticipation & hope. | Anxiety that no one will respond before 11:30 PM closing. | Immediate visual countdown timer and instant broadcast to verified local NGOs. |
| **5. Claim Notification** | Receives push alert at 11:02 PM: "Annapoorna Shelter claimed your donation! Volunteer assigned." | In-App Real-Time Alert. | **Relief & Joy (Peak)** | Worry if the volunteer will find the service entrance. | Donor phone number revealed only to the assigned volunteer; one-tap call button active. |
| **6. Physical Handover** | Volunteer Rahul arrives at 11:25 PM with motorcycle luggage; Ramesh hands over boxes; volunteer taps "Confirm Pickup". | Kitchen loading bay; Volunteer app. | Relaxed, accomplished. | Verifying that the volunteer is genuine. | Volunteer profile shows photo, name, and verified badge on donor screen. |
| **7. Completion & Impact** | Closes kitchen on time; receives notification next morning: "90 meals served at Annapoorna Shelter." | Mobile Notification & Impact Card. | **Pride & Loyalty** | None. | Downloadable digital Certificate of Impact for the restaurant's CSR records. |

---

## 2. Journey B: NGO Operations Coordinator (Sunita Deshmukh)

**Scenario:** Discovering, claiming, receiving, and distributing evening dinner for 120 shelter residents.

| Stage | Actions Taken | Touchpoints | Emotional State | Friction / Pain Point | Moment of Truth / Opportunity |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **1. Need Assessment** | Shelter has 120 residents; dinner supplies are low; budget is constrained. | Shelter kitchen, paper inventory. | Anxious, burdened by resource scarcity. | High cost of daily commercial grocery purchases. | Opening FoodBridge to check nearby surplus availability. |
| **2. Discovery & Filtering** | Opens Explore Feed; filters by "Food", $\le 8\text{ km}$, and vegetarian cooked meals. | NGO Discovery Feed, filter chips. | Hopeful, scanning listings. | Sifting through expired or distant listings on other platforms. | Clean cards showing category, distance, portion count, and remaining expiry time. |
| **3. Atomic Reservation** | Spots Ramesh's 35 kg banquet listing; taps "Request Donation" with quantity = 35 kg; selects "Requires Volunteer". | Donation Detail Screen, Claim Button. | Focused, eager to secure. | Fear that another NGO will claim the batch mid-submission. | Atomic database lock: instant reservation confirmation with zero double-allocation risk. |
| **4. Dispatch Coordination** | App confirms request accepted; monitors live status as Volunteer Rahul is assigned. | Realtime Task Tracker. | Reassured, awaiting delivery. | Wondering when the volunteer will arrive at the shelter. | Real-time status badge: `Open` $\rightarrow$ `Assigned` $\rightarrow$ `Picked Up` $\rightarrow$ `In Transit`. |
| **5. Physical Inspection & Handover** | Volunteer arrives at 11:45 PM; Sunita inspects food temperature and aroma; confirms good condition. | Shelter entrance gate; physical food containers. | Critical, vigilant for safety. | Fear of receiving unhygienic or spoiled food. | Unconditional right of physical refusal with built-in rejection logging. |
| **6. Handover Confirmation** | Sunita taps "Confirm Receipt" on her app; volunteer task completed. | NGO Mobile Dashboard. | **Relief & Gratitude** | Keeping tracking simple for tired staff. | One-touch receipt confirmation. |
| **7. Distribution Record** | Shelter serves hot dinner to residents; next morning Sunita inputs "90 meals served". | Distribution Record Form. | **Deep Fulfillment** | Privacy concerns regarding recording beneficiary details. | Strictly aggregate entry (no beneficiary personal names or photos required). |

---

## 3. Journey C: Community Volunteer (Rahul Patil — Special Logistics Focus)

**Scenario:** Evening field pickup on a two-wheeler, navigation, physical verification, and shelter handover.

| Stage | Actions Taken | Touchpoints | Emotional State | Friction / Pain Point | Moment of Truth / Opportunity |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **1. Opportunity Scan** | Finishing evening study session at 11:00 PM; opens FoodBridge to see if any local rescue tasks need transport. | Volunteer Dashboard on Android phone. | Eager to contribute. | Cluttered apps with tiny text while sitting on a motorcycle. | High-contrast, clean task list showing route zone, weight, and vehicle compatibility. |
| **2. Task Evaluation** | Inspects task card: "Banquet Hall to Annapoorna Shelter | 4.2 km | 35 kg packed in 3 crates | Vehicle: 2-Wheeler / Car". | Task Summary Card. | Analytical, checking feasibility. | Is 35 kg too heavy for a motorcycle? | Clear volume/cargo tags: "Car or 2-Wheeler with carrier recommended". |
| **3. Atomic Acceptance** | Taps large green "Accept Task" button ($\ge 48\text{ dp}$). | One-Touch Action Button. | **Energized, Committed** | Frustration if another volunteer claims it at the same moment. | Atomic assignment lock: screen turns green with "Task Confirmed — You Own This Dispatch". |
| **4. Navigation & Pickup** | Private address unlocked; taps "Navigate" (opens Google Maps); arrives at rear kitchen gate; meets Ramesh. | Map Integration & One-Touch Phone Call. | Confident, navigating traffic. | Gate security blocking entry; difficult to reach donor. | Direct "Call Donor" button and precise gate entry notes provided in-app. |
| **5. Physical Collection Confirmation** | Receives sealed food crates; loads onto motorcycle luggage carrier; taps "Confirm Pickup". | Volunteer App (Large Action Button). | Focused, careful handling. | Operating phone while wearing riding gloves. | Giant, high-contrast action button that triggers haptic feedback. |
| **6. Transit & Delivery** | Rides 4.2 km to Annapoorna Shelter; arrives at 11:45 PM; unloads crates at kitchen door. | Motorcycle transit; Shelter gate. | Cautious with cargo. | Traffic delays causing food to get cold. | In-transit countdown timer keeping volunteer mindful of safe collection window. |
| **7. Handover Confirmation** | Meets Sunita; assists in checking boxes; taps "Confirm Handover". | Mobile App Handover Screen. | **High Pride & Camaraderie** | Waiting for slow verification. | Immediate screen transition: "Delivery Completed! You just helped feed 90 people tonight." |

---

## 4. Journey D: Platform Administrator (Vikramaditya Sen)

**Scenario:** Daily trust review, NGO accreditation vetting, and real-time operations oversight.

| Stage | Actions Taken | Touchpoints | Emotional State | Friction / Pain Point | Moment of Truth / Opportunity |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **1. Morning Queue Check** | Logs into Web Admin Console; opens "Pending NGO Verifications" tab (3 submissions awaiting review). | Admin Web Portal (Desktop browser). | Methodical, vigilant. | Switching between PDF files and government registry websites. | Integrated split-screen PDF previewer with direct verification checklist. |
| **2. Document Examination** | Inspects "Annapoorna Welfare Trust" registration certificate (12A/80G); validates Darpan ID against national portal. | Split-Screen Document Reviewer. | Thorough, analytical. | Detecting forged or expired NGO credentials. | Clear document zoom, certificate validity date extraction, and verification guidelines. |
| **3. Decision & Approval** | Taps "Approve NGO"; enters audit note: "Verified against State Darpan Registry #MH/2021/0042". | Approval Dialog & Reason Input. | Satisfied, expanding network. | Missing audit trail if questions arise later. | Immutable audit log automatically generated with admin ID, timestamp, and action. |
| **4. Operational Monitoring** | Reviews real-time dashboard: 14 active donations, 8 in transit, 0 stalled tasks, 1 incident report. | Live Metric Stream & Realtime Map. | In control, observant. | Identifying bottleneck regions where food expires before pickup. | Dynamic alert flags when a task remains unassigned within 45 minutes of deadline. |
| **5. Incident Arbitration** | Reviews minor dispute: donor reported volunteer was 20 minutes late; checks transit logs and resolves cleanly. | Incident Moderation Console. | Objective, fair. | He-said-she-said arguments without data. | Complete timestamp trail (`accepted_at`, `pickup_at`, `delivered_at`) provides objective facts. |

