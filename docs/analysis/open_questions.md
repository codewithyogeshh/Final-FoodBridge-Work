# FoodBridge — Open Questions, Ambiguity Analysis & Recommended Decisions

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 1 — Requirement Analysis  
**Status:** Completed  
**Purpose:** Identify incomplete, conflicting, or ambiguous requirements in the PRD, document working assumptions, and recommend the safest practical options.

---

## 1. Requirement Ambiguity & Conflict Analysis

### 1.1 Item 1: Request Allocation Authority — Donor Approval vs. Instant NGO Claim
- **PRD Ambiguity:** PRD Section 6 Journey A (Step 6) states: *"An NGO requests the donation; the donor or platform workflow confirms one request."* Meanwhile, PRD Section 13 lists as an open decision: *"Whether donors or NGOs confirm the final allocation."*
- **Conflict / Risk:** If a donor posts 50 kg of hot food late at night and goes to sleep, waiting for the donor to manually approve an NGO's request creates a fatal delay. The food will spoil before collection is approved. Conversely, for non-urgent clothing donations, a donor may prefer selecting which charity receives the items.
- **Recommended Safest Option:**
  - **For Perishable Cooked Food (`food_category = 'cooked_meals'`):** Implement **Verified NGO Instant Claim**. A verified NGO in the service area can immediately reserve available quantity without waiting for donor approval. The donor receives an instant notification: *"Claimed by [NGO Name] — Volunteer dispatch initiated"*.
  - **For Non-Perishable Food & Clothing:** Donor can toggle *"Require My Approval"* if desired, with an automatic fallback: if not approved within 6 hours, the request auto-confirms or reverts to prevent inventory deadlock.

---

### 1.2 Item 2: Direct NGO Collection vs. Mandatory Volunteer Assignment
- **PRD Ambiguity:** PRD Section 6 Step 7 states: *"A pickup task is created and assigned to an eligible volunteer if volunteer delivery is needed."* Architecture Section 11 asks: *"Whether an NGO can collect directly without a volunteer."*
- **Operational Reality:** Many established NGOs operate their own vans, auto-rickshaws, or collection staff. Forcing every transaction to wait for an independent platform volunteer would paralyze direct collections.
- **Recommended Safest Option:**
  - At the time of claim submission, the verified NGO must select:
    1. **"Self-Collection by NGO Staff / Van"**: No volunteer task is created. The donation transitions directly to `accepted`, unlocking the pickup address to the NGO coordinator. Handover occurs directly between donor and NGO staff.
    2. **"Request Platform Volunteer Delivery"**: Generates an open dispatch task in `assignments` for community volunteers.

---

### 1.3 Item 3: Partial Allocation / Splitting a Single Donation
- **PRD Ambiguity:** Architecture Section 11 asks: *"Whether a donation can be split among multiple NGOs."*
- **Operational Reality:** If a hotel donates 100 kg of rice and curry, a small shelter with 30 beds can only absorb 25 kg. Disallowing partial claims would mean large donations remain uncollected, or smaller shelters are excluded.
- **Recommended Safest Option:**
  - Support **Partial Quantity Allocation**.
  - The donation maintains `initial_quantity` and `available_quantity`.
  - When NGO A claims 25 kg out of 100 kg, `available_quantity` becomes 75 kg.
  - The listing remains in status `available` for other NGOs until `available_quantity = 0`, at which point it transitions to `requested`.
  - Each approved claim spawns its own distinct `donation_request` and linked `assignment`.

---

### 1.4 Item 4: Volunteer Fleet Model — Open Community vs. NGO-Managed
- **PRD Ambiguity:** PRD Section 13 asks: *"Whether volunteers are platform members or NGO-managed."*
- **Risk Assessment:** Community volunteers provide crowdsourced flexibility, but unvetted volunteers present liability and reliability concerns.
- **Recommended Safest Option (Hybrid Phased Model):**
  - **MVP (Phases 5–9):** Platform-registered community volunteers who verify their phone number, accept the Volunteer Safety Charter, and are bounded by an active task limit (max 2 concurrent tasks) and atomic task reservation locks.
  - **Future Extension:** Allow NGOs to designate "Affiliated Volunteer" badges to prioritize their own trusted field workers for specific pickups.

---

### 1.5 Item 5: Beneficiary Interaction Boundaries
- **PRD Ambiguity:** PRD Section 5.5 states: *"The first release may serve them through NGOs rather than requiring every beneficiary to create an account. Protect their identity and personal information."*
- **Ethical & Data Privacy Mandate:** Forcing impoverished recipients to register smartphones would exclude the most vulnerable and violate privacy principles.
- **Recommended Safest Option:**
  - **Zero Beneficiary Accounts in MVP.**
  - Beneficiaries are served exclusively through registered NGOs.
  - Distribution records capture strictly aggregate data (e.g., *"120 meals served"*, *"45 winter jackets distributed"*) with zero personal identifiers (no names, no photos, no phone numbers).

---

### 1.6 Item 6: Geographic Pilot & Operating Hours
- **PRD Ambiguity:** PRD Section 13: *"Pilot geography and operating hours to be confirmed."*
- **Recommended Safest Option:**
  - **Pilot Service Area:** Mumbai Metropolitan Region (Western Suburbs: Andheri to Borivali, and Thane) as the primary baseline geography.
  - **Operating Hours:** 24/7 platform availability, with automated curfew warnings for food donations created past 11:30 PM requiring collection by 12:30 AM.

---

## 2. Summary of Recommended Decisions

| Topic | Ambiguity | Working Assumption / Recommended Decision | Safety / Technical Rationale |
| :--- | :--- | :--- | :--- |
| **Claim Approval** | Donor vs. NGO instant | Instant claim for perishable cooked food; optional donor review for clothing. | Prevents perishable food spoilage due to delayed donor response. |
| **Logistics Mode** | Volunteer vs. Direct | NGO selects "Self-Collection" or "Volunteer Needed" at claim time. | Prevents unnecessary volunteer dispatch when NGO has own vehicle. |
| **Donation Splitting** | Single vs. Multi-claim | Allow partial quantity claims decrementing `available_quantity`. | Maximizes resource utilization; accommodates shelters of varying size. |
| **Volunteer Model** | Open vs. NGO-managed | Open community volunteers with verified phone & active task limit $\le 2$. | Provides maximum crowdsourced transport availability. |
| **Beneficiary Data** | User account vs. Proxy | Strictly indirect proxy; aggregate counts only; zero beneficiary PII. | Preserves human dignity and satisfies strict privacy compliance. |
| **Food Expiry Cutoff**| Open deadline vs. Strict | Mandatory `collection_deadline` at least 30 mins in future; auto-expire. | Guarantees expired food drops off feeds immediately. |

