# FoodBridge — Agile User Stories Catalog

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 1 — Requirement Analysis  
**Status:** Completed  
**Deliverable Location:** `docs/analysis/user_stories.md`  

---

## 1. Overview & Formatting Rules

Every story strictly adheres to the requested Agile template:
> **"As a [user], I want [action], so that [benefit]."**

Each story includes:
- **Story ID:** Grouped by functional epic.
- **Priority:** MoSCoW classification (**Must**, **Should**, **Could**).
- **Story Points (SP):** Fibonacci complexity score ($1, 2, 3, 5, 8$).
- **Traceability Links:** Cross-referenced with PRD, functional requirements, and acceptance criteria.

---

## 2. Epic 1: Identity, Authentication & Profile Governance

### US-AUTH-01: Multi-Role Secure Registration
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a new visitor, I want to create an account using my email and password while selecting my primary role (Donor, NGO, Volunteer), so that I gain access to features tailored to my operational responsibilities.*
- **Traceability:** PRD FR-01, FR-02 | FR-AUTH-01, FR-AUTH-04 | AC-AUTH-01

### US-AUTH-02: NGO Accreditation Submission
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an NGO representative, I want to submit our government registration number and upload our tax exemption certificate, so that administrators can verify our charitable legitimacy before we claim donations.*
- **Traceability:** PRD FR-03 | FR-AUTH-05, FR-AUTH-06 | AC-AUTH-02

### US-AUTH-03: Volunteer Operational Availability Setup
- **Priority:** **[SHOULD]** | **Points:** 2 SP
- **Story:** *As a community volunteer, I want to configure my vehicle type (two-wheeler, car, van) and operational zones in my profile, so that I receive dispatch task notifications that match my transport capabilities.*
- **Traceability:** PRD FR-04 | FR-AUTH-07 | AC-AUTH-03

### US-AUTH-04: Language & Locale Preference Selection
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As an active user, I want to switch my application language between English, Hindi, and Marathi at any time, so that I can use the platform comfortably in my primary language.*
- **Traceability:** PRD NFR | NFR-I18N-01, NFR-I18N-02 | AC-AUTH-04

---

## 3. Epic 2: Donation Creation & Management

### US-DON-01: Publish Cooked Food Donation with Expiry Limits
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As a commercial caterer or restaurant manager, I want to post surplus cooked meals with preparation time, holding conditions, allergen notes, and an absolute collection deadline, so that nearby verified shelters can rescue it before it degrades.*
- **Traceability:** PRD FR-05, FR-06, FR-07 | FR-DON-01, FR-DON-F01..F04 | AC-DON-01

### US-DON-02: Publish Clean Wearable Clothing Donation
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a household donor, I want to list clean wearable clothes specifying category, sizing, condition, and cleanliness confirmation, so that community welfare organizations can distribute them to families in need.*
- **Traceability:** PRD FR-05, FR-06 | FR-DON-C01 | AC-DON-02

### US-DON-03: Two-Tier Location Privacy Protection
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a residential donor, I want my exact home address to remain hidden from public feeds and revealed only to an assigned volunteer upon task acceptance, so that my personal safety and privacy are protected.*
- **Traceability:** PRD FR-06, FR-18 | FR-DON-03, NFR-PRIV-01 | AC-DON-03

### US-DON-04: Edit or Withdraw Active Donation
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a donor, I want to modify details or cancel an active donation while it is still in draft or available status, so that I can adjust for changing kitchen situations.*
- **Traceability:** PRD FR-08 | FR-DON-05 | AC-DON-04

---

## 4. Epic 3: NGO Discovery & Request Allocation

### US-NGO-01: Filter & Discover Available Donations
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an NGO logistics coordinator, I want to view a real-time list of available food and clothing donations filtered by category, proximity, and remaining collection time, so that I can quickly claim resources needed for our shelter.*
- **Traceability:** PRD FR-11 | FR-NGO-01 | AC-NGO-01

### US-NGO-02: Atomic Quantity Claim Submission
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an NGO coordinator, I want to submit a claim request for a specific quantity with atomic reservation locking, so that the items are reserved for our shelter without the risk of double-claiming by other organizations.*
- **Traceability:** PRD FR-12, FR-13 | FR-NGO-02, FR-NGO-04 | AC-NGO-02

### US-NGO-03: Direct Collection vs. Volunteer Request Selection
- **Priority:** **[MUST]** | **Points:** 2 SP
- **Story:** *As an NGO coordinator, I want to specify whether our own staff van will pick up the donation or if we require platform volunteer delivery, so that logistics can be planned efficiently.*
- **Traceability:** PRD FR-12 | FR-NGO-03 | AC-NGO-03

### US-NGO-04: Right of Physical Refusal at Handover
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As an NGO receiving staff member, I want to physically inspect incoming food and formally reject deliveries that fail temperature or quality standards, so that compromised items are never distributed to shelter residents.*
- **Traceability:** PRD FR-14 | FR-NGO-07 | AC-NGO-04

---

## 5. Epic 4: Volunteer Coordination & Task Dispatch

### US-VOL-01: Discover & Accept Open Dispatch Task
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an active volunteer, I want to see open pickup tasks in my area with cargo weight and vehicle compatibility tags and claim one with an exclusive lock, so that I know the task is guaranteed to be mine.*
- **Traceability:** PRD FR-15, FR-16 | FR-VOL-01..03 | AC-VOL-01

### US-VOL-02: Doorstep Navigation & Donor Coordination
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As an assigned volunteer, I want to view the donor's exact door address, gate instructions, and telephone number once I accept a task, so that I can navigate to the pickup location without friction.*
- **Traceability:** PRD FR-18 | FR-VOL-07 | AC-VOL-02

### US-VOL-03: Ergonomic One-Touch Pickup Confirmation
- **Priority:** **[MUST]** | **Points:** 2 SP
- **Story:** *As a volunteer collecting goods from a donor, I want to tap a large high-contrast "Confirm Pickup" button on my phone, so that all parties are immediately notified that the food is in transit.*
- **Traceability:** PRD FR-17 | FR-VOL-05 | AC-VOL-03

### US-VOL-04: Emergency Task Surrender
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a volunteer who experiences a vehicle puncture or field emergency, I want to surrender my active task with one tap, so that it is instantly released back to open status for nearby volunteers before the food spoils.*
- **Traceability:** PRD FR-17 | FR-VOL-06 | AC-VOL-04

---

## 6. Epic 5: Handover, Distribution & Traceability

### US-DIST-01: Delivery Handover Confirmation
- **Priority:** **[MUST]** | **Points:** 2 SP
- **Story:** *As a volunteer arriving at the shelter destination, I want to record delivery handover in the app, so that my dispatch task is completed and the NGO can confirm receipt.*
- **Traceability:** PRD FR-17 | FR-VOL-05 | AC-DIST-01

### US-DIST-02: NGO Aggregate Distribution Logging
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As an NGO staff member, I want to log the total quantity distributed and estimated meals served without entering beneficiary personal details, so that the full donation lifecycle is closed transparently and ethically.*
- **Traceability:** PRD FR-10 | FR-DIST-01, FR-DIST-02 | AC-DIST-02

---

## 7. Epic 6: Governance, Moderation & Audit

### US-ADM-01: NGO Verification Queue Review
- **Priority:** **[MUST]** | **Points:** 5 SP
- **Story:** *As a platform administrator, I want to review submitted NGO registration certificates in a split-screen viewer and approve or reject them with audit notes, so that only authentic charities can claim donations.*
- **Traceability:** PRD FR-22 | FR-ADM-01 | AC-ADM-01

### US-ADM-02: Global Platform Monitoring & Account Moderation
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As an administrator, I want to monitor live donations, arbitrate reported incidents, and suspend abusive users, so that platform safety and community trust are preserved.*
- **Traceability:** PRD FR-23, FR-24 | FR-ADM-02, FR-ADM-03 | AC-ADM-02

### US-ADM-03: Immutable Audit Trail Review
- **Priority:** **[MUST]** | **Points:** 3 SP
- **Story:** *As a compliance auditor or admin, I want to inspect a complete chronological audit log of all status transitions and administrative actions, so that every step in the chain of custody is indisputable.*
- **Traceability:** PRD FR-25 | FR-ADM-05 | AC-ADM-03

