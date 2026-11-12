# FoodBridge — Functional Requirements Specification

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 1 — Requirement Analysis  
**Status:** Completed  

---

## 1. Overview & Classification Schema

This document specifies the complete functional capabilities of the FoodBridge system. Each requirement is assigned a unique identifier and categorized according to the **MoSCoW** prioritization framework:
- **[MUST]:** Core MVP requirement essential for system integrity and safety.
- **[SHOULD]:** High-priority feature expected for a robust production release.
- **[COULD]:** Valuable enhancement incorporated if resources allow.
- **[WON'T]:** Excluded from the current scope.

---

## 2. Module 1: Identity, Authentication & Profile Management (FR-AUTH)

| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-AUTH-01** | **[MUST]** | The system shall support secure registration via email and password with cryptographic credential verification. | All Roles |
| **FR-AUTH-02** | **[MUST]** | The system shall enforce role selection during registration (`donor`, `ngo`, `volunteer`). Direct public registration as `admin` shall be strictly forbidden. | All Roles |
| **FR-AUTH-03** | **[MUST]** | The system shall persist authenticated sessions securely on the client device using encrypted storage and support secure logout. | All Roles |
| **FR-AUTH-04** | **[MUST]** | The system shall provide a secure password reset workflow via verified email magic links or OTP tokens. | All Roles |
| **FR-AUTH-05** | **[MUST]** | The system shall maintain distinct profile entities linked to the primary authentication identity (`donor_profiles`, `ngos`, `volunteer_profiles`). | System |
| **FR-AUTH-06** | **[MUST]** | The system shall require NGOs to submit organizational legal details (registration number, contact person, operational address, proof of incorporation/tax exemption certificate). | NGO |
| **FR-AUTH-07** | **[MUST]** | The system shall mark new NGO accounts as `pending_verification`. Unverified NGOs shall be restricted from claiming donations until administrator approval. | System / Admin |
| **FR-AUTH-08** | **[SHOULD]** | The system shall allow volunteers to specify their operational availability (e.g., weekdays, weekends, evening hours) and preferred transportation mode (walk, two-wheeler, four-wheeler). | Volunteer |
| **FR-AUTH-09** | **[MUST]** | The system shall allow users to edit non-critical profile fields (display name, phone number, vehicle type) while restricting role tampering via Row Level Security (RLS). | All Roles |
| **FR-AUTH-10** | **[SHOULD]** | The system shall support user account deactivation or deletion requests in compliance with personal data privacy guidelines. | All Roles |

---

## 3. Module 2: Donation Creation & Management (FR-DON)

### 3.1 Common Donation Attributes
| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-DON-01** | **[MUST]** | The system shall allow authenticated donors to create donation listings categorized as either `food` or `clothing`. | Donor |
| **FR-DON-02** | **[MUST]** | The system shall record title, detailed description, quantity, standard unit of measurement, and pickup window for every listing. | Donor |
| **FR-DON-03** | **[MUST]** | The system shall capture two tiers of location data: `pickup_area_public` (approximate neighborhood/pin code visible in public feeds) and `pickup_location_private` (exact address and contact phone number). | Donor |
| **FR-DON-04** | **[MUST]** | The system shall permit donors to upload up to 5 clear photographs per donation listing. | Donor |
| **FR-DON-05** | **[MUST]** | The system shall enforce image compression and validation (JPEG, PNG, WebP; max 5 MB per file) before upload to Supabase Storage. | Client / Storage |
| **FR-DON-06** | **[MUST]** | The system shall allow donors to edit or cancel a donation if its status is `draft` or `available`. If requests exist or are accepted, cancellation shall require explicit reason logging. | Donor |
| **FR-DON-07** | **[MUST]** | The system shall provide donors with a real-time tracking dashboard showing the active state of all their listings. | Donor |

### 3.2 Food-Specific Attributes (FR-DON-F)
| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-DON-F01**| **[MUST]** | The system shall require donors to select a food category (`cooked_meals`, `packaged_groceries`, `fresh_produce`, `bakery_dairy`, `beverages`). | Donor |
| **FR-DON-F02**| **[MUST]** | The system shall mandate a strict `collection_deadline` timestamp after which the food cannot be collected or distributed safely. | Donor |
| **FR-DON-F03**| **[MUST]** | The system shall require food donors to record preparation or packaging date/time. | Donor |
| **FR-DON-F04**| **[MUST]** | The system shall mandate storage and handling requirements (`ambient`, `refrigerated`, `frozen`, `hot_holding`). | Donor |
| **FR-DON-F05**| **[MUST]** | The system shall require disclosure of known major allergens (e.g., dairy, nuts, gluten, soy) or explicit declaration of "None Known". | Donor |
| **FR-DON-F06**| **[MUST]** | The system shall require the donor to accept a mandatory food safety declaration stating that food was prepared and held under clean, hygienic conditions. | Donor |

### 3.3 Clothing-Specific Attributes (FR-DON-C)
| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-DON-C01**| **[MUST]** | The system shall require clothing category selection (`menswear`, `womenswear`, `children_infant`, `winterwear_blankets`, `footwear`, `mixed_linens`). | Donor |
| **FR-DON-C02**| **[MUST]** | The system shall require condition classification (`new_with_tags`, `gently_used_like_new`, `good_wearable`). Torn, stained, or soiled items shall be prohibited by policy. | Donor |
| **FR-DON-C03**| **[MUST]** | The system shall capture sizing metadata (`S`, `M`, `L`, `XL`, `Free Size`, `Age Bracket` for children). | Donor |
| **FR-DON-C04**| **[MUST]** | The system shall require donors to certify that all clothing items are washed, clean, and completely dry prior to pickup. | Donor |

---

## 4. Module 3: NGO Discovery & Request Allocation (FR-NGO)

| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-NGO-01** | **[MUST]** | The system shall provide verified NGOs with a searchable discovery feed of all `available` food and clothing donations. | NGO |
| **FR-NGO-02** | **[MUST]** | The system shall enable multi-facet filtering by donation type (`food`/`clothing`), subcategory, distance/neighborhood, and urgency/deadline. | NGO |
| **FR-NGO-03** | **[MUST]** | The system shall prevent unverified NGOs from viewing restricted donation details or submitting claim requests. | System / RLS |
| **FR-NGO-04** | **[MUST]** | The system shall allow an NGO to submit a claim request specifying requested quantity, intended beneficiaries, and coordination note. | NGO |
| **FR-NGO-05** | **[MUST]** | The system shall enforce atomic database reservation locking to guarantee that multiple simultaneous requests cannot over-allocate available quantity. | Database Engine |
| **FR-NGO-06** | **[MUST]** | The system shall allow an NGO to withdraw a pending request prior to acceptance, instantly returning reserved quantities to the available pool. | NGO |
| **FR-NGO-07** | **[MUST]** | The system shall allow the donor (or automated allocation logic) to accept an incoming NGO request, transitioning donation state to `accepted`. | Donor / System |
| **FR-NGO-08** | **[MUST]** | The system shall allow NGOs to choose whether they will collect the donation directly or require platform volunteer dispatch. | NGO |
| **FR-NGO-09** | **[MUST]** | The system shall empower receiving NGOs with the unconditional right to reject a donation at physical handover if items fail visual inspection or hygiene standards, recording rejection reason. | NGO |

---

## 5. Module 4: Volunteer Coordination & Task Dispatch (FR-VOL)

| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-VOL-01** | **[MUST]** | When an accepted donation requires volunteer delivery, the system shall automatically create an unassigned dispatch task in status `open`. | System |
| **FR-VOL-02** | **[MUST]** | The system shall present active, eligible volunteers with a feed of open pickup tasks in their declared operational zone. | Volunteer |
| **FR-VOL-03** | **[MUST]** | The open task card shall display only high-level details: donation type, quantity, approximate pickup neighborhood, drop-off NGO name/neighborhood, and collection deadline window. | System |
| **FR-VOL-04** | **[MUST]** | The system shall enforce a strict single-volunteer assignment lock via an atomic database transaction. Race conditions between two volunteers accepting the same task simultaneously shall be resolved safely. | Database Engine |
| **FR-VOL-05** | **[MUST]** | Upon task assignment, the system shall unlock the donor's exact pickup address (`pickup_location_private`) and contact phone number exclusively to the assigned volunteer. | System / RLS |
| **FR-VOL-06** | **[MUST]** | The system shall limit each volunteer to a configurable maximum of active concurrent tasks (default: 2) to prevent logistics bottlenecks. | System |
| **FR-VOL-07** | **[MUST]** | The system shall provide an intuitive one-touch pickup confirmation interface for the volunteer upon physical collection from the donor, transitioning status to `picked_up`. | Volunteer |
| **FR-VOL-08** | **[MUST]** | The system shall allow volunteers to report transit delays, vehicle breakdowns, or unlocatable pickup addresses, alerting both the donor and the recipient NGO. | Volunteer |
| **FR-VOL-09** | **[MUST]** | The system shall allow a volunteer to surrender an accepted task due to emergency prior to pickup, reverting the task to `open` for reassignment without penalties if reported promptly. | Volunteer |

---

## 6. Module 5: Handover, Distribution & Traceability (FR-DIST)

| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-DIST-01**| **[MUST]** | Upon arrival at the NGO premises, the volunteer shall mark the handover as completed, transitioning status to `delivered_to_ngo`. | Volunteer |
| **FR-DIST-02**| **[MUST]** | The receiving NGO staff member shall confirm physical receipt and inspect the items against the stated quantity and quality standards. | NGO |
| **FR-DIST-03**| **[MUST]** | The system shall require the NGO to create an official `distribution_record` detailing quantity received, quantity distributed to community members, distribution date, and beneficiary demographic summary (e.g., number of meals served, families clothed). | NGO |
| **FR-DIST-04**| **[MUST]** | Once the distribution record is submitted, the system shall transition the overall donation lifecycle to `completed`. | System |
| **FR-DIST-05**| **[SHOULD]**| The system shall generate a digital Certificate of Impact / Donation Acknowledgment for the donor, summarizing carbon and food waste diverted. | System / Donor |
| **FR-DIST-06**| **[MUST]** | The system shall prohibit the entry of personally identifiable data of individual recipients/beneficiaries into the distribution records. | NGO / System |

---

## 7. Module 6: Realtime Engine & Notifications (FR-RT)

| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-RT-01** | **[SHOULD]** | The system shall leverage Supabase Realtime WebSocket channels to broadcast donation status updates to connected clients without manual polling. | System |
| **FR-RT-02** | **[MUST]** | The system shall persist in-app notifications in the `notifications` table for every critical lifecycle transition. | System |
| **FR-RT-03** | **[MUST]** | Donors shall receive notifications when: their donation is requested by an NGO, a volunteer is assigned, pickup is confirmed, and handover is completed. | Donor |
| **FR-RT-04** | **[MUST]** | NGOs shall receive notifications when: a new donation matching their registered category/service area is published, their request is accepted, pickup occurs, and a volunteer arrives. | NGO |
| **FR-RT-05** | **[MUST]** | Volunteers shall receive notifications when: a new task becomes available in their area, and when a task assignment deadline is approaching. | Volunteer |
| **FR-RT-06** | **[SHOULD]** | The system shall support push notifications (via Firebase Cloud Messaging or platform-native channels) for high-urgency perishable food pickups. | System |
| **FR-RT-07** | **[SHOULD]** | Users shall be able to configure notification preferences (e.g., mute clothing notifications, enable instant food alerts). | All Roles |

---

## 8. Module 7: Admin Verification, Moderation & Audit (FR-ADM)

| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-ADM-01** | **[MUST]** | The system shall provide an administrative verification console displaying pending NGO registration applications and uploaded legal credentials. | Admin |
| **FR-ADM-02** | **[MUST]** | Administrators shall be able to approve, reject, or request additional documentation from applicant NGOs, with mandatory audit reason logging. | Admin |
| **FR-ADM-03** | **[MUST]** | The system shall provide administrators with global oversight of all active donations, requests, and volunteer tasks. | Admin |
| **FR-ADM-04** | **[MUST]** | The system shall provide a dispute and incident management interface to process reports regarding spoiled food, no-shows, or inappropriate behavior. | Admin |
| **FR-ADM-05** | **[MUST]** | Administrators shall possess the authority to suspend or deactivate compromised, abusive, or non-compliant user accounts. | Admin |
| **FR-ADM-06** | **[MUST]** | The system shall maintain an immutable `audit_logs` ledger capturing all security-sensitive and lifecycle-modifying events (actor ID, timestamp, entity ID, previous state, new state). | System |
| **FR-ADM-07** | **[SHOULD]** | The system shall generate aggregated platform impact analytics: total kilograms of food saved, meals equivalent, items of clothing redistributed, and average collection turnaround time. | Admin |

---

## 9. Module 8: AI-Assisted Advisory Capabilities (FR-AI)

*Note: Scheduled for Phase 10 as an isolated, optional service.*

| ID | Priority | Requirement Description | Actor |
| :--- | :--- | :--- | :--- |
| **FR-AI-01** | **[COULD]** | The system may provide rule-based and predictive NGO matching scores based on geographic distance, declared capacity, and historical fulfillment velocity. | System / Donor |
| **FR-AI-02** | **[COULD]** | The system may provide advisory image classification to suggest broad food/clothing categories from donor-uploaded photographs. | Donor |
| **FR-AI-03** | **[MUST]** | All AI recommendations shall require explicit human review and confirmation before submission. Manual selection shall always remain fully available. | Donor / NGO |
| **FR-AI-04** | **[MUST]** | The system shall strictly prohibit any AI service or model from issuing statements or certifications regarding food safety, bacterial freshness, or edibility. | System |
| **FR-AI-05** | **[COULD]** | The system may provide an in-app FAQ assistant powered by approved documentation to help donors and volunteers navigate platform procedures. | All Roles |

