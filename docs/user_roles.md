# FoodBridge — User Roles & Permissions Matrix

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 1 — Requirement Analysis  
**Status:** Completed  

---

## 1. Stakeholder Archetypes & Role Descriptions

FoodBridge operates a four-tier primary user ecosystem, supplemented by indirect beneficiary protections.

```
       ┌─────────────────────────────────────────────────────────────┐
       │                     FoodBridge Platform                     │
       └──────┬───────────────────┬───────────────────┬──────────────┘
              │                   │                   │
              ▼                   ▼                   ▼
      ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
      │    DONOR     │    │     NGO      │    │  VOLUNTEER   │
      │  (Publishes) │    │  (Claims &   │    │  (Transports │
      │              │    │  Distributes)│    │  & Verifies) │
      └──────┬───────┘    └──────┬───────┘    └──────────────┘
             │                   │
             │                   ▼
             │            ┌──────────────┐
             │            │ BENEFICIARY  │ (Dignity-Protected Proxy:
             │            │  (Receives)  │  No login account required)
             │            └──────────────┘
             ▼
      ┌──────────────┐
      │    ADMIN     │ (Vets NGOs, Moderates
      │  (Governs)   │  Incidents & Monitors)
      └──────────────┘
```

### 1.1 Donor
- **Archetype Profiles:**
  - *Commercial Food Donors:* Restaurants, banquet halls, caterers, corporate cafeterias, bakeries, grocery supermarkets.
  - *Individual / Household Donors:* Citizens with surplus packaged food, festive excess, or clean wearable clothing.
- **Motivations:** Reduce waste, fulfill CSR/environmental mandates, support local underprivileged communities with zero friction.
- **Key Responsibilities:** Accurate descriptions, honest food preparation and storage disclosures, prompt packaging, realistic pickup deadlines.

### 1.2 Non-Governmental Organization (NGO)
- **Archetype Profiles:**
  - Registered charities, community food banks, night shelters, orphanages, elder care facilities, disaster relief squads, clothing donation banks.
- **Motivations:** Source reliable supplies of food and clothing to serve destitute individuals, minimize operational purchasing costs.
- **Key Responsibilities:** Timely submission of legal credentials, accurate capacity declarations, rapid claim-to-distribution turnaround, dignified physical handover, physical quality inspection, and distribution record logging.

### 1.3 Volunteer
- **Archetype Profiles:**
  - College students, community youth, retired citizens, gig-economy workers willing to commit flexible time for civic service.
  - Independent field logistics handlers.
- **Motivations:** Community service, civic contribution, social impact, skill development.
- **Key Responsibilities:** Rapid response to task alerts, careful handling during transit (hygiene, temperature awareness), accurate one-touch status updates, escalation of field issues.

### 1.4 Platform Administrator (Admin)
- **Archetype Profiles:**
  - Dedicated operations managers, trust and safety officers, system verifiers.
- **Motivations:** Maintain network safety, protect legal compliance, ensure food safety compliance, eliminate fraudulent actors.
- **Key Responsibilities:** Rigorous vetting of NGO registration documents, dispute resolution, reviewing audit logs, system monitoring.

### 1.5 Beneficiary (Protected Proxy)
- **Status:** **Indirect Stakeholder.**
- **Architectural Policy:** Beneficiaries do not create digital accounts or download mobile apps. They are served directly through verified NGO distribution programs. Their personal identifiers (names, home addresses, phone numbers, face photos) are explicitly shielded from digital storage to safeguard personal dignity and privacy.

---

## 2. Comprehensive Entity CRUD & Action Matrix

| Entity | Donor | Verified NGO | Unverified NGO | Volunteer | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Profile (Own)** | `CRUD` | `CRUD` | `CRUD` | `CRUD` | `CRUD` |
| **Profile (Others)** | `None` | `Read Public` | `Read Public` | `Read Public` | `CRUD` |
| **NGO Documents** | `None` | `Create/Read (Own)` | `Create/Read (Own)` | `None` | `Read/Review All` |
| **Donations (Own)** | `CRUD` | `None` | `None` | `None` | `Read/Moderate` |
| **Donations (Feed)** | `Read (Own)` | `Read (Available)` | `Read (Public Preview)` | `Read (Assigned)` | `Read (All)` |
| **Donation Requests** | `Read/Approve` | `Create/Read (Own)` | `Blocked` | `Read (Assigned)` | `Read/Moderate All` |
| **Assignments / Tasks**| `Read (Own)` | `Read (Own)` | `None` | `Read/Accept/Update` | `CRUD / Reassign` |
| **Distribution Records**| `Read Summary`| `Create/Read (Own)` | `Blocked` | `None` | `Read/Audit All` |
| **In-App Notifications**| `Read (Own)` | `Read (Own)` | `Read (Own)` | `Read (Own)` | `Read (All)` |
| **Audit Logs** | `None` | `None` | `None` | `None` | `Read All` |

*Legend: `CRUD` = Create, Read, Update, Delete (as permitted by workflow); `None` = Access Denied via RLS.*

---

## 3. State Transition Authority Matrix

The donation lifecycle consists of strict status states. The table below enforces which role possesses the cryptographic authority to execute each transition:

| Transition (`From` $\rightarrow$ `To`) | Authorized Role | Triggering Action / Condition |
| :--- | :--- | :--- |
| `[None]` $\rightarrow$ `draft` | **Donor** | Donor saves an unfinished listing locally or to profile. |
| `draft` $\rightarrow$ `available` | **Donor** | Donor submits complete form with declarations. |
| `available` $\rightarrow$ `requested` | **Verified NGO** | Verified NGO submits a claim request with quantity. |
| `requested` $\rightarrow$ `accepted` | **Donor / System** | Donor approves the NGO request (or auto-allocates). |
| `requested` $\rightarrow$ `available` | **NGO / Donor** | Request withdrawn by NGO or declined by Donor. |
| `accepted` $\rightarrow$ `assigned_for_pickup` | **Volunteer** | Volunteer accepts the dispatch task. |
| `accepted` $\rightarrow$ `delivered_to_ngo` | **NGO** | Direct NGO collection (bypassing volunteer). |
| `assigned_for_pickup` $\rightarrow$ `picked_up` | **Volunteer** | Volunteer physically receives goods from donor. |
| `picked_up` $\rightarrow$ `delivered_to_ngo` | **Volunteer** | Volunteer hands goods over at NGO facility. |
| `delivered_to_ngo` $\rightarrow$ `distributed` | **NGO** | NGO begins or finishes distribution to beneficiaries. |
| `distributed` $\rightarrow$ `completed` | **NGO / System** | NGO logs `distribution_record`; task closed. |
| Any non-final $\rightarrow$ `cancelled` | **Donor / Admin** | Donor cancels before pickup; or Admin moderates. |
| `available` / `requested` $\rightarrow$ `expired` | **System (Automated)** | Current time exceeds `collection_deadline`. |
| `delivered_to_ngo` $\rightarrow$ `rejected` | **NGO** | Physical inspection failure (spoilage / hygiene). |

---

## 4. Two-Tier Data Privacy & Boundary Matrix

| Data Attribute | Public Feed Visibility | Unverified NGO | Verified NGO | Assigned Volunteer | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Donation Title & Category | Yes | Yes | Yes | Yes | Yes |
| Quantity & Unit | Yes | Yes | Yes | Yes | Yes |
| Approximate Locality / Zone | Yes | Yes | Yes | Yes | Yes |
| Collection Deadline | Yes | Yes | Yes | Yes | Yes |
| Item Photographs | Yes | Yes | Yes | Yes | Yes |
| **Exact Donor Street Address** | **Hidden** | **Hidden** | **Hidden** | **Visible upon Task Claim** | **Visible** |
| **Donor Contact Phone Number** | **Hidden** | **Hidden** | **Hidden** | **Visible upon Task Claim** | **Visible** |
| NGO Registration Proofs (PDF) | **Hidden** | **Hidden** | **Hidden (Own Only)** | **Hidden** | **Visible** |
| Beneficiary Aggregate Counts | Yes | Yes | Yes | Yes | Yes |
| **Beneficiary Direct Identifiers**| **PROHIBITED** | **PROHIBITED** | **PROHIBITED** | **PROHIBITED** | **PROHIBITED** |

---

## 5. Verification & Account Governance Workflows

### 5.1 NGO Onboarding & Vetting
1. **Registration:** NGO representative registers via standard auth, selecting the `ngo` role.
2. **Profile Submission:** NGO inputs organization name, government registration number (e.g., 12A / 80G / Darpan ID), designated service radius, and uploads PDF credentials.
3. **Pending State:** Account enters `pending_verification` state. Discovery feed only displays masked donation previews without the ability to submit claims.
4. **Admin Review:** Admin verifies document authenticity against official public registries.
5. **Decision:**
   - *Approved:* State set to `verified`. RLS policies immediately unlock request submission privileges.
   - *Rejected:* State set to `rejected` with mandatory reviewer feedback. NGO receives alert with option to re-upload.

### 5.2 Incident Moderation & Account Suspension
- **Reporting Triggers:** Unhygienic food delivery, unpunctual volunteer no-show, fraudulent claims, or inappropriate communication.
- **Admin Action:** Admin reviews immutable audit history and communication logs. Admin can issue a warning, temporarily suspend, or permanently ban the violating user ID.

