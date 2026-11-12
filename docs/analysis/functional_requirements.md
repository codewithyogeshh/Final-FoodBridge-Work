# FoodBridge — Functional Requirements Specification (PRD Extraction)

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 1 — Requirement Analysis  
**Status:** Completed  
**Deliverable Location:** `docs/analysis/functional_requirements.md`  

---

## 1. Overview & Classification Schema

This document extracts and formalizes every functional requirement specified in `docs/prd.md` (FR-01 through FR-30), decomposing each into granular system specifications with unique IDs, MoSCoW prioritization, and actor assignments.

---

## 2. Authentication & Profile Management (FR-01 to FR-04)

| PRD Ref | Granular ID | Priority | Requirement Specification | Primary Actor |
| :--- | :--- | :---: | :--- | :--- |
| **FR-01** | `FR-AUTH-01` | **[MUST]** | The system shall support secure user registration and sign-in using email and password with cryptographic hashing. | All Roles |
| **FR-01** | `FR-AUTH-02` | **[MUST]** | The system shall securely persist authentication sessions in device encrypted storage (`FlutterSecureStorage`) across app restarts. | All Roles |
| **FR-01** | `FR-AUTH-03` | **[MUST]** | The system shall provide a secure password reset workflow via verified email tokens. | All Roles |
| **FR-02** | `FR-AUTH-04` | **[MUST]** | The system shall enforce role-based access control (RBAC) across four roles: `donor`, `ngo`, `volunteer`, and `admin`. Direct public registration as `admin` shall be strictly blocked. | System / RLS |
| **FR-03** | `FR-AUTH-05` | **[MUST]** | The system shall require newly registered NGO accounts to submit organizational registration proofs (e.g., 12A/80G/Darpan ID) and enter a `pending_verification` state. | NGO |
| **FR-03** | `FR-AUTH-06` | **[MUST]** | The system shall restrict unverified NGOs from claiming donations until administrator verification is granted. | System / RLS |
| **FR-04** | `FR-AUTH-07` | **[MUST]** | Users shall be permitted to update non-privileged profile attributes (display name, phone number, operational vehicle, language) while role tampering is prevented. | All Roles |
| **FR-04** | `FR-AUTH-08` | **[SHOULD]**| The system shall support user account deactivation and data privacy erasure requests. | All Roles |

---

## 3. Donation Creation & Management (FR-05 to FR-10)

| PRD Ref | Granular ID | Priority | Requirement Specification | Primary Actor |
| :--- | :--- | :---: | :--- | :--- |
| **FR-05** | `FR-DON-01` | **[MUST]** | The system shall allow authenticated donors to create listings classified as either `food` or `clothing`. | Donor |
| **FR-06** | `FR-DON-02` | **[MUST]** | Every listing shall require title, description, numeric quantity, standard unit of measure, and pickup availability window. | Donor |
| **FR-06** | `FR-DON-03` | **[MUST]** | The system shall enforce a two-tier location privacy model: `pickup_area_public` (approximate zone for discovery) and `pickup_location_private` (exact door address). | Donor / RLS |
| **FR-06** | `FR-DON-04` | **[MUST]** | The system shall support client-side image compression and upload of up to 5 photos per listing to private Supabase Storage buckets. | Donor |
| **FR-07** | `FR-DON-F01` | **[MUST]** | For food listings, the system shall require selection of category (`cooked_meals`, `packaged_groceries`, `fresh_produce`, `bakery_dairy`, `beverages`). | Donor |
| **FR-07** | `FR-DON-F02` | **[MUST]** | The system shall mandate a strict `collection_deadline` timestamp (at least 30 mins in the future) after which food cannot be collected. | Donor / System |
| **FR-07** | `FR-DON-F03` | **[MUST]** | The system shall capture preparation/packaging timestamp, holding conditions (`hot_holding`, `refrigerated`, `ambient`), and allergen notes. | Donor |
| **FR-07** | `FR-DON-F04` | **[MUST]** | Food donors must accept a mandatory food safety declaration certifying hygienic preparation before publishing. | Donor |
| **FR-05** | `FR-DON-C01` | **[MUST]** | For clothing listings, the system shall require garment category, size range, condition rating (`new`, `like_new`, `good`), and a mandatory cleanliness certification. | Donor |
| **FR-08** | `FR-DON-05` | **[MUST]** | Donors shall be permitted to edit or cancel listings in `draft` or `available` status; cancellations on accepted items shall require reason logging. | Donor |
| **FR-09** | `FR-DON-06` | **[MUST]** | The system shall display the active lifecycle status of every donation on donor, NGO, and volunteer dashboards. | All Roles |
| **FR-10** | `FR-DON-07` | **[MUST]** | The system shall retain an immutable chronological history of all status transitions for every donation. | System / Audit |

---

## 4. NGO Discovery & Request Allocation (FR-11 to FR-14)

| PRD Ref | Granular ID | Priority | Requirement Specification | Primary Actor |
| :--- | :--- | :---: | :--- | :--- |
| **FR-11** | `FR-NGO-01` | **[MUST]** | Verified NGOs shall be provided a searchable discovery feed filtered by donation type, proximity/zone, quantity, and collection deadline. | Verified NGO |
| **FR-12** | `FR-NGO-02` | **[MUST]** | An NGO shall be able to submit a claim request specifying requested quantity, beneficiary meal estimate, and coordination note. | Verified NGO |
| **FR-12** | `FR-NGO-03` | **[MUST]** | NGOs shall specify whether they will collect directly using their own transport or request volunteer delivery dispatch. | Verified NGO |
| **FR-13** | `FR-NGO-04` | **[MUST]** | The system shall execute atomic row-level locking (`SELECT ... FOR UPDATE`) during claim submission to prevent over-allocation or duplicate claims. | Database Engine |
| **FR-13** | `FR-NGO-05` | **[MUST]** | Partial allocation shall be supported, decrementing `available_quantity` until 0, at which point status transitions to `requested`. | Database Engine |
| **FR-14** | `FR-NGO-06` | **[MUST]** | The system shall allow an NGO to withdraw a pending request, instantly returning reserved quantities to the available inventory pool. | Verified NGO |
| **FR-14** | `FR-NGO-07` | **[MUST]** | The receiving NGO shall possess the unconditional right of refusal at physical handover if items fail visual or temperature inspection. | Verified NGO |

---

## 5. Volunteer Coordination & Task Dispatch (FR-15 to FR-18)

| PRD Ref | Granular ID | Priority | Requirement Specification | Primary Actor |
| :--- | :--- | :---: | :--- | :--- |
| **FR-15** | `FR-VOL-01` | **[MUST]** | When an accepted allocation requires volunteer transport, the system shall create an open dispatch task in `assignments`. | System |
| **FR-15** | `FR-VOL-02` | **[MUST]** | Active volunteers shall see open dispatch tasks displaying approximate route, cargo volume, weight, and deadline countdown. | Volunteer |
| **FR-16** | `FR-VOL-03` | **[MUST]** | The system shall enforce atomic single-volunteer task claiming, guaranteeing that exactly one volunteer owns an active assignment. | Database Engine |
| **FR-16** | `FR-VOL-04` | **[MUST]** | The system shall enforce an active task limit (max 2 concurrent tasks per volunteer) to prevent dispatch hoarding. | System |
| **FR-17** | `FR-VOL-05` | **[MUST]** | The system shall provide large, high-contrast action buttons ($\ge 48\text{ dp}$, $56\text{ dp}$ "Rider Mode") for one-touch pickup and handover confirmation. | Volunteer |
| **FR-17** | `FR-VOL-06` | **[MUST]** | The system shall provide an emergency task surrender option, instantly returning the task to `open` status if a volunteer experiences a vehicle breakdown. | Volunteer |
| **FR-18** | `FR-VOL-07` | **[MUST]** | The system shall unlock `pickup_location_private` and donor telephone number exclusively to the volunteer assigned to the task. | System / RLS |

---

## 6. Notifications, Handover & Distribution (FR-19 to FR-21)

| PRD Ref | Granular ID | Priority | Requirement Specification | Primary Actor |
| :--- | :--- | :---: | :--- | :--- |
| **FR-19** | `FR-NOTIF-01`| **[MUST]** | The system shall generate in-app notifications for donors, NGOs, and volunteers upon every critical state change. | System |
| **FR-20** | `FR-NOTIF-02`| **[MUST]** | Users shall be able to view a chronological event timeline of their active donations, requests, and dispatch tasks. | All Roles |
| **FR-21** | `FR-NOTIF-03`| **[SHOULD]**| The client application shall subscribe to Supabase Realtime channels to refresh active feeds dynamically via WebSockets. | System / Client |
| **PRD §6** | `FR-DIST-01` | **[MUST]** | Receiving NGOs shall record a `distribution_record` detailing quantity received, quantity distributed, and aggregate community meals/clothing counts. | Verified NGO |
| **PRD §6** | `FR-DIST-02` | **[MUST]** | The system shall strictly prohibit the collection or storage of personal beneficiary names, photos, or private addresses. | System / Database |

---

## 7. Administration, Moderation & Audit (FR-22 to FR-25)

| PRD Ref | Granular ID | Priority | Requirement Specification | Primary Actor |
| :--- | :--- | :---: | :--- | :--- |
| **FR-22** | `FR-ADM-01` | **[MUST]** | Administrators shall be provided an NGO verification queue with split-screen document preview to approve or reject credentials. | Administrator |
| **FR-23** | `FR-ADM-02` | **[MUST]** | Administrators shall be able to suspend abusive or non-compliant user accounts, with mandatory reason logging. | Administrator |
| **FR-24** | `FR-ADM-03` | **[MUST]** | Administrators shall have global read-only visibility into all active donations, requests, and volunteer dispatch tasks. | Administrator |
| **FR-24** | `FR-ADM-04` | **[SHOULD]**| The system shall calculate aggregate platform metrics: total kg rescued, meals served, garments redistributed, and turnaround time. | Administrator |
| **FR-25** | `FR-ADM-05` | **[MUST]** | The system shall maintain an immutable `audit_logs` table capturing all security-sensitive and lifecycle-modifying actions. | System / Audit |

---

## 8. AI-Assisted Advisory Capabilities (FR-26 to FR-30)

*Phased into Phase 10 as an optional decoupled microservice.*

| PRD Ref | Granular ID | Priority | Requirement Specification | Primary Actor |
| :--- | :--- | :---: | :--- | :--- |
| **FR-26** | `FR-AI-01` | **[COULD]** | The system may calculate advisory NGO matching scores based on category, service area, and capacity. | System / NGO |
| **FR-27** | `FR-AI-02` | **[COULD]** | The system may provide image classification suggestions for food/clothing categories from donor photos. | System / Donor |
| **FR-28** | `FR-AI-03` | **[COULD]** | The system may aggregate historical distribution trends to project community demand patterns. | System / Admin |
| **FR-29** | `FR-AI-04` | **[COULD]** | The system may provide an in-app FAQ assistant powered by verified product documentation. | All Roles |
| **FR-30** | `FR-AI-05` | **[MUST]** | AI recommendations shall remain strictly advisory; AI is legally and technically prohibited from certifying food safety or freshness. | System / AI |

