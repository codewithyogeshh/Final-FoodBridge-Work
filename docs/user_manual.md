# FoodBridge User Manual & Operational Handbook
**SDLC Phase 12: Deployment & Maintenance**

---

## 1. Introduction

**FoodBridge** (*"Share More. Waste Less. Bridge the Need."*) is a community-centered platform connecting surplus food and clothing donors, verified NGO shelters, and volunteer couriers to eliminate avoidable waste and deliver relief with dignity and safety.

---

## 2. Donor Handbook

### 2.1. Account Setup
- Select the **Donor** role during registration.
- Choose your donor category: **Individual / Household**, **Restaurant / Cafe**, **Caterer / Banquet Hall**, or **Supermarket / Retailer**.
- Specify your primary service area (e.g., *Swargate, Pune*).

### 2.2. Publishing a Food Donation
1. From the Donor Dashboard, tap **Donate Food**.
2. **Food Details:** Enter food title, description, category (*Cooked Meals*, *Raw Produce*, *Packaged Dry Rations*, *Bakery*), and quantity with measurement units (*meals*, *kg*, *boxes*).
3. **Safety & Storage:** Specify whether the food is **Pure Veg**, disclose known allergens, and select storage requirements (**Ambient**, **Chilled**, or **Hot**).
4. **Pickup Window:** Set preparation time and collection deadline (at least 2 hours in the future).
5. **Hygiene Charter:** Read and accept the mandatory FoodBridge FSSAI Hygiene Charter.
6. Tap **Preview Donation** $\to$ **Publish Listing**.

### 2.3. Publishing a Clothing Donation
1. Tap **Donate Clothes** from the dashboard.
2. Select clothing category (*Kids Wear*, *Adult Daily Wear*, *Winter Wear*, *Blankets & Bedding*).
3. Specify quantity, target size, and condition grade (**Brand New**, **Like New**, or **Good**).
4. Affirm the **Cleanliness Declaration** (garments washed, dry, and neatly packed).
5. Tap **Publish Listing**.

### 2.4. Handover to Volunteer
- When a volunteer arrives, verify their assigned name on your dashboard card.
- Disclose your **4-digit Pickup OTP** displayed on your listing card.
- Hand over cargo only after the volunteer enters the code into their app.

---

## 3. NGO & Shelter Handbook

### 3.1. Verification & Trust Requirements
- NGOs must provide their **Registration Number**, **NGO Darpan ID**, and upload a valid **12A / 80G Tax Exemption Certificate**.
- Accounts remain in **Pending Verification** until approved by an administrator.

### 3.2. Claiming Donations
1. Open the **Available Feed** on the NGO Portal.
2. Filter by category, dietary preference (*Pure Veg*), or distance.
3. Open donation details and tap **Claim Donation**.
4. Enter your required quantity (partial claims are supported to prevent over-supply).
5. The system performs an atomic lock to guarantee no over-allocation.

### 3.3. Receiving Delivery
- When the courier arrives at your shelter, verify the package condition and temperature.
- Read your **4-digit Receipt OTP** from the incoming deliveries card to the courier.

### 3.4. Logging Distribution Records
- After distributing meals or clothing to beneficiaries, tap **Log Distribution**.
- Record the headcount served (e.g. *120 children*) and distribution notes.
- *Zero Beneficiary PII:* The system collects aggregate headcounts only, preserving community dignity and privacy.

---

## 4. Volunteer Courier Handbook

### 4.1. Active Duty Mode
- Toggle your **Duty Status** to **Online** to view nearby rescue tasks.

### 4.2. Task Discovery & Acceptance
- Review pickup area, shelter destination, cargo type, and handling advisory.
- Tap **Accept Dispatch Mission**.
- *2-Task Concurrency Limit:* You may hold at most 2 active tasks simultaneously.

### 4.3. Navigation & Dual-OTP Verification
1. Follow turn-by-turn route navigation to the donor location.
2. Meet the donor and enter their **4-digit Pickup OTP** to unlock physical custody.
3. Adhere to the safe handling advisory (insulated hot-bag for hot food; ice cooler for chilled dairy).
4. Navigate to the shelter and enter the manager's **4-digit Receipt OTP** to complete the mission.

### 4.4. Emergency Task Release
- In the event of a bike breakdown, puncture, or emergency, tap the **Emergency Release** button on the mission card. The task is instantly returned to the community dispatch pool.

---

## 5. Administrator Handbook

### 5.1. NGO Verification Queue
- Inspect pending applications, verify Darpan IDs on the government portal, preview 12A/80G documents, and tap **Approve** or **Reject** with reason.

### 5.2. Community Moderation & User Management
- Review community complaints regarding hygiene, packaging, or delays.
- Record investigation and resolution notes.
- Suspend offending accounts with mandatory justification. All administrative actions write directly to the tamper-evident audit log.

