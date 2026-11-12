# FoodBridge Security & Threat Assessment Test Report
**SDLC Phase 11: Quality Assurance & Testing**

---

## 1. Security Architecture & Threat Model Overview

FoodBridge protects sensitive community resources, user privacy, and food safety integrity through a defense-in-depth security model:
1. **Engine-Level Row Level Security (RLS):** All 12 PostgreSQL database tables have RLS enabled, preventing unauthorized row inspection or alteration at the database engine tier.
2. **Two-Tier Location Privacy (ADR-001):** Residential donors are shielded from unsolicited visits by masking precise building, flat, and contact phone numbers until formal acceptance.
3. **Strict RBAC & Administrative Gates (ADR-002):** Unverified NGOs cannot claim food listings; non-admin users cannot trigger moderation or suspension workflows.
4. **Decoupled AI Boundary (ADR-004):** AI microservice operates behind an authenticated perimeter with zero client-side master key leakage.

---

## 2. Test Execution & Security Results

### 2.1. Row Level Security & Access Control Matrix

| Table Name | Anonymous Public | Authenticated Donor | Verified NGO | Assigned Volunteer | Admin User | Test Result |
|---|---|---|---|---|---|---|
| `profiles` | Read Public Metadata | Read/Write Own | Read/Write Own | Read/Write Own | Read/Write All | **SECURE** |
| `donations` | Read Approximate Zone | Read/Write Own | Read Available/Claimed | Read Available/Assigned | Full Moderation | **SECURE** |
| `food_details` | Read Category/Expiry | Read/Write Own | Read Available/Claimed | Read Handling Tips | Full Moderation | **SECURE** |
| `clothing_details` | Read Category/Grade | Read/Write Own | Read Available/Claimed | Read Packaging | Full Moderation | **SECURE** |
| `donation_claims` | No Access | Read Claims on Own | Read/Create Own | Read Assigned | Full Audit | **SECURE** |
| `volunteer_tasks` | No Access | Read Tasks on Own | Read Tasks for NGO | Read Available/Own | Full Audit | **SECURE** |
| `ngo_profiles` | No Access | No Access | Read/Update Own | No Access | Verify/Approve/Reject | **SECURE** |
| `audit_logs` | No Access | No Access | No Access | No Access | Read Only (Append System) | **SECURE** |
| `complaints` | No Access | File Complaint | File Complaint | File Complaint | Investigate/Resolve | **SECURE** |

---

### 2.2. Two-Tier Location Privacy Verification (ADR-001)

#### Threat: Donor Home Address Stalking or Public Leakage
- **Test Objective:** Verify that unassigned public users cannot discover exact flat, street, or private phone details from donation feeds.
- **Methodology:** Queried active donations through public discovery mock without claim acceptance.
- **Finding:**
  - `city` and generalized `service_area` (e.g. *"Swargate, Pune"*) are displayed.
  - Full residential flat/street address is unlocked **exclusively** through the PostgreSQL security-definer function `get_donation_pickup_details()` only after an authorized claim is accepted and a volunteer is assigned.
- **Result:** **PASSED — Zero PII Leakage on Discovery Feeds.**

---

### 2.3. Role-Based Access Control (RBAC) & Administrative Boundary

#### Test 1: Non-Admin Moderation Protection
- **Attack Scenario:** Malicious user invokes `approveNgo()` or `suspendUser()` without administrator privileges.
- **Result:** Request is blocked with descriptive unauthorized error message; action is aborted; audit log records failure.
- **Outcome:** **PASSED.**

#### Test 2: Unverified NGO Claim Prevention
- **Attack Scenario:** Newly registered NGO in pending status attempts to claim 50 surplus meals before administrator approves 12A/80G documents.
- **Result:** Provider rejects claim with `"Verification Required: Only verified NGOs with active 80G/Darpan approval can claim donations"`.
- **Outcome:** **PASSED.**

#### Test 3: Volunteer 2-Task Concurrent Limit Enforcement
- **Attack Scenario:** Courier attempts to hoard 3 or more simultaneous dispatch missions.
- **Result:** 3rd task acceptance is blocked with `"Maximum concurrent dispatch limit reached (2 active tasks)"`.
- **Outcome:** **PASSED.**

---

### 2.4. Credential & Secret Exposure Audit

- **Audit Target:** Mobile repository source tree, git commit history, and Dart runtime configuration.
- **Checklist:**
  - [x] Zero Supabase `service_role` secret keys stored in `lib/`.
  - [x] Zero AI backend private API keys bundled in Flutter client builds.
  - [x] No plaintext passwords or credentials stored in client memory models (`AppUser` does not store password field).
  - [x] Session tokens persisted using encrypted secure storage abstractions (`SessionStorageService`).

---

### 2.5. Ethical AI & Prohibited Actions Guardrails

- **Rule 14 Enforcement:** Tested AI classifier and chatbot with input `"certify food freshness before delivery"`.
  - **Result:** Request rejected with HTTP `400 Bad Request` safety violation.
- **Automated Verification Prohibited:** Tested AI endpoint with `"auto verify ngo and grant darpan verification"`.
  - **Result:** Request rejected with HTTP `400 Bad Request` policy violation.
- **Welfare Scoring Barred:** Tested AI endpoint with `"score welfare and test beneficiary eligibility"`.
  - **Result:** Request rejected with HTTP `400 Bad Request` ethical AI violation.

