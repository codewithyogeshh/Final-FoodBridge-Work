# FoodBridge — User Stories & Agile Backlog

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 1 — Requirement Analysis  
**Status:** Completed  

---

## 1. Overview & Story Hierarchy

User stories are structured around core user personas across the complete redistribution lifecycle. Each story follows the standard Agile template:
> **"As a [user role], I want to [perform an action], so that [achieve a specific business value or goal]."**

Every story includes:
- **Story ID:** Unique identifier grouped by Epic.
- **Priority:** MoSCoW classification (**Must**, **Should**, **Could**).
- **Story Points (SP):** Fibonacci complexity rating ($1, 2, 3, 5, 8$).
- **Cross-Reference:** Linked functional requirements and acceptance criteria.

---

## 2. Epic 1: Onboarding, Authentication & Profile Governance

### US-AUTH-01: Multi-Role Account Registration
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a new platform visitor (donor, NGO staff, or volunteer), I want to create an account using my email and password while selecting my primary operational role, so that I gain access to role-tailored features.*
- **Cross-Ref:** FR-AUTH-01, FR-AUTH-02 | AC-AUTH-01

### US-AUTH-02: NGO Legal Verification Submission
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an NGO representative, I want to submit my official organization registration number and upload certificate documents, so that the administration can verify our non-profit legitimacy.*
- **Cross-Ref:** FR-AUTH-06, FR-AUTH-07 | AC-AUTH-02

### US-AUTH-03: Volunteer Availability Profile
- **Priority:** **[SHOULD]** | **Points:** 2 SP
- **Story:** *As a community volunteer, I want to define my preferred working hours, service neighborhood, and vehicle type in my profile, so that I receive relevant task notifications.*
- **Cross-Ref:** FR-AUTH-08 | AC-AUTH-03

### US-AUTH-04: Secure Multi-Language Session Management
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As an authenticated user, I want my session to remain secure across app restarts and easily toggle between English, Hindi, and Marathi, so that I can use the app seamlessly in my native language.*
- **Cross-Ref:** FR-AUTH-03, NFR-I18N-01 | AC-AUTH-04

---

## 3. Epic 2: Donation Creation & Management

### US-DON-01: Publish Cooked Food Donation with Expiry Limits
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As a restaurant manager or event caterer, I want to post a surplus cooked food donation specifying quantity, packaging time, storage condition, allergens, and an absolute collection deadline, so that a nearby NGO can rescue it before it degrades.*
- **Cross-Ref:** FR-DON-F01 to F06 | AC-DON-01

### US-DON-02: Publish Clothing Donation with Condition & Cleanliness
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As an individual donor, I want to list clean wearable clothes with categories, sizes, condition ratings, and photographs, so that community welfare organizations can direct them to families in need.*
- **Cross-Ref:** FR-DON-C01 to C04 | AC-DON-02

### US-DON-03: Two-Tier Location Protection for Donors
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a residential donor, I want my exact home address to remain hidden from the public feed and only revealed to a verified volunteer after task acceptance, so that my personal privacy and safety are protected.*
- **Cross-Ref:** FR-DON-03, NFR-PRIV-01 | AC-DON-03

### US-DON-04: Edit or Withdraw Active Donation
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a donor, I want to edit details or cancel an active donation before it is claimed or accepted, so that I can adjust for changing availability.*
- **Cross-Ref:** FR-DON-06 | AC-DON-04

---

## 4. Epic 3: NGO Discovery & Request Allocation

### US-NGO-01: Filter & Discover Donations
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an NGO logistics coordinator, I want to view a real-time list of available food and clothing donations filtered by category, proximity, and urgency, so that I can quickly spot items suitable for our shelter.*
- **Cross-Ref:** FR-NGO-01, FR-NGO-02 | AC-NGO-01

### US-NGO-02: Submit Claim Request with Atomic Reservation
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an NGO coordinator, I want to claim a specific quantity of an available donation, so that the items are locked for our beneficiaries without risk of duplicate claiming.*
- **Cross-Ref:** FR-NGO-04, FR-NGO-05 | AC-NGO-02

### US-NGO-03: Choose Direct Pickup or Volunteer Request
- **Priority:** **[MUST]** | **Points:** 2 SP
- **Story:** *As an NGO coordinator, I want to specify whether our NGO van will collect the donation or if we need a platform volunteer, so that logistics can be planned efficiently.*
- **Cross-Ref:** FR-NGO-08 | AC-NGO-03

### US-NGO-04: Physical Inspection & Rejection Right
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As an NGO receiver, I want to formally reject a food or clothing delivery at handover if it fails physical quality inspection, so that unsafe items never reach our beneficiaries.*
- **Cross-Ref:** FR-NGO-09 | AC-NGO-04

---

## 5. Epic 4: Volunteer Coordination & Task Dispatch

### US-VOL-01: Discover & Accept Open Dispatch Task
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an active volunteer, I want to see open pickup tasks in my area and accept one with a single tap, so that I can contribute to transport without administrative delay.*
- **Cross-Ref:** FR-VOL-01 to FR-VOL-04 | AC-VOL-01

### US-VOL-02: Access Donor Details Post-Acceptance
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As an assigned volunteer, I want to view the donor's exact pickup address, gate instructions, and telephone number once I accept a task, so that I can navigate to the pickup location smoothly.*
- **Cross-Ref:** FR-VOL-05 | AC-VOL-02

### US-VOL-03: One-Tap Pickup Confirmation
- **Priority:** **[MUST]** | **Points:** 2 SP
- **Story:** *As a volunteer collecting goods from a donor, I want to tap "Confirm Pickup", so that the donor and the NGO immediately know the items are in transit.*
- **Cross-Ref:** FR-VOL-07 | AC-VOL-03

### US-VOL-04: Report Field Issues & Emergency Cancellation
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a volunteer encountering traffic breakdown or unlocatable address, I want to report an issue or surrender the task, so that the donation can be re-routed before the food expires.*
- **Cross-Ref:** FR-VOL-08, FR-VOL-09 | AC-VOL-04

---

## 6. Epic 5: Handover, Distribution & Traceability

### US-DIST-01: Volunteer Handover Confirmation
- **Priority:** **[MUST]** | **Points:** 2 SP
- **Story:** *As a volunteer arriving at the NGO facility, I want to record successful delivery, so that my task is completed and the NGO can confirm receipt.*
- **Cross-Ref:** FR-DIST-01 | AC-DIST-01

### US-DIST-02: NGO Distribution Record Logging
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an NGO staff member, I want to record the quantity distributed, distribution date, and aggregate meal/clothing metrics without recording private beneficiary names, so that the entire donation lifecycle is closed transparently.*
- **Cross-Ref:** FR-DIST-02, FR-DIST-03, FR-DIST-06 | AC-DIST-02

### US-DIST-03: Donor Impact Receipt
- **Priority:** **[SHOULD]** | **Points:** 2 SP
- **Story:** *As a donor, I want to see an impact summary of my completed donation (meals served, waste diverted), so that I feel fulfilled and motivated to donate again.*
- **Cross-Ref:** FR-DIST-05 | AC-DIST-03

---

## 7. Epic 6: Governance, Moderation & Audit Logging

### US-ADM-01: NGO Verification Queue
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As a platform administrator, I want to review submitted NGO registration documents in a dedicated dashboard and approve or reject them with feedback, so that only authentic non-profits access donations.*
- **Cross-Ref:** FR-ADM-01, FR-ADM-02 | AC-ADM-01

### US-ADM-02: Global Platform Monitoring & Moderation
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As an administrator, I want to monitor active donations, track incident reports, and suspend abusive accounts, so that platform integrity and community trust are upheld.*
- **Cross-Ref:** FR-ADM-03 to FR-ADM-05 | AC-ADM-02

### US-ADM-03: Immutable Audit Log Review
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a compliance auditor or admin, I want to view an immutable ledger of all critical status changes, actor IDs, and timestamps, so that every step in the chain of custody is traceable.*
- **Cross-Ref:** FR-ADM-06 | AC-ADM-03

---

## 8. Epic 7: Real-Time Communication & Notifications

### US-RT-01: Instant Notification on Status Changes
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a donor, NGO, or volunteer, I want to receive immediate in-app notifications whenever the status of my donation or task changes, so that I can take timely action.*
- **Cross-Ref:** FR-RT-01 to FR-RT-05 | AC-RT-01

### US-RT-02: Realtime Live Dashboard Synchronization
- **Priority:** **[SHOULD]** | **Points:** 3 SP
- **Story:** *As an active user viewing feeds or status cards, I want screen data to update live via WebSockets without manual pull-to-refresh, so that I always see the latest availability.*
- **Cross-Ref:** FR-RT-01 | AC-RT-02

