# FoodBridge — User Roles, Beneficiary Protections & Permissions Matrix

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 1 — Requirement Analysis  
**Status:** Completed  
**Deliverable Location:** `docs/analysis/user_roles.md`  

---

## 1. Stakeholder Architecture

FoodBridge governs interactions between four authenticated platform roles, while enforcing strict privacy and dignity boundaries for the non-registered community beneficiaries:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        FOODBRIDGE PLATFORM CORE                        │
└───────┬───────────────────┬───────────────────┬────────────────┬───────┘
        │                   │                   │                │
        ▼                   ▼                   ▼                ▼
 ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ ┌──────────────┐
 │    DONOR     │    │     NGO      │    │  VOLUNTEER   │ │    ADMIN     │
 │ (Commercial  │    │  (Shelter /  │    │ (Field Task  │ │ (Vetting &   │
 │ & Household) │    │  Food Bank)  │    │  Fulfillment)│ │ Governance)  │
 └──────────────┘    └──────┬───────┘    └──────────────┘ └──────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │ BENEFICIARY  │ (Dignity-Protected Proxy:
                     │  (Recipient) │  Zero accounts, Zero PII)
                     └──────────────┘
```

---

## 2. Comprehensive Role Profiles

### 2.1 The Donor
- **Sub-types:** Restaurants, banquet halls, hotels, corporate cafeterias, caterers, grocery supermarkets, and individual households.
- **Primary Needs:** Rapid listing in under 90 seconds, clear food handling declarations, two-tier address privacy, and confidence that donations reach authentic non-profits.
- **Authority:** Full CRUD over own listings; right to cancel listings prior to pickup.

### 2.2 The NGO (Non-Governmental Organization)
- **Sub-types:** Registered charitable trusts, night shelters, orphanages, elder care homes, community soup kitchens, and clothing banks.
- **Primary Needs:** Real-time discovery of nearby available food/clothing, atomic quantity claims, choice between direct van pickup or volunteer delivery, and the right of physical refusal at handover.
- **Authority:** Access to discovery feeds upon administrator verification; submit claims; confirm receipt; log distribution metrics.

### 2.3 The Community Volunteer
- **Sub-types:** College students, community youth, gig workers, and civic-minded citizens operating motorcycles, two-wheelers, cars, or walking.
- **Primary Needs:** Clear task feed filtered by vehicle cargo capacity, exclusive single-volunteer task lock, decrypted donor door address post-acceptance, and high-contrast "Rider Mode" buttons.
- **Authority:** Discover open tasks; claim tasks within active limit (max 2); update pickup and handover progress; report field emergencies.

### 2.4 The Administrator
- **Sub-types:** Operations leads, trust and safety officers, system verifiers.
- **Primary Needs:** Dedicated verification console for vetting applicant NGO legal credentials (12A/80G/Darpan certificates), global flow monitoring, incident dispute arbitration, and immutable audit log review.
- **Authority:** Full administrative control over verifications, account standing, and global moderation. Public registration as admin is strictly prohibited.

---

## 3. Beneficiary Interactions & Privacy Framework

### 3.1 Dignity-Protected Indirect Proxy Model
Beneficiaries are the ultimate recipients of rescued food and clothing. FoodBridge adopts a strict architectural policy:
1. **Zero Mandatory Accounts:** Beneficiaries are never required or requested to create accounts, download apps, or present digital identifiers to receive aid.
2. **Zero Surveillance & Zero PII:** The platform database strictly prohibits the storage of beneficiary personal data:
   - No recipient names.
   - No facial photographs of recipients in distribution records.
   - No personal residential addresses or phone numbers.
3. **Aggregate Distribution Reporting:** Receiving NGOs record strictly quantitative community metrics:
   - Number of meals served (e.g., *"120 hot meals distributed at Shelter Hall"*).
   - Quantity of clothing items handed out (e.g., *"45 jackets distributed to local families"*).

---

## 4. Entity CRUD & Data Access Permissions Matrix

| Table / Resource | Donor | Verified NGO | Unverified NGO | Volunteer | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`profiles` (Own)** | `CRUD` | `CRUD` | `CRUD` | `CRUD` | `CRUD` |
| **`profiles` (Others)** | `None` | `Read Public` | `Read Public` | `Read Public` | `CRUD` |
| **`donor_profiles`** | `CRUD (Own)` | `None` | `None` | `None` | `Read All` |
| **`ngos`** | `Read Verified`| `CRUD (Own)` | `CRUD (Own)` | `Read Verified`| `CRUD All` |
| **`volunteer_profiles`**| `None` | `None` | `None` | `CRUD (Own)` | `Read All` |
| **`donations` (Own)** | `CRUD` | `None` | `None` | `None` | `Read/Moderate` |
| **`donations` (Feed)** | `Read Own` | `Read Available`| `Read Preview` | `Read Assigned`| `Read All` |
| **`donation_requests`** | `Read/Approve` | `CRUD (Own)` | `Blocked` | `Read Assigned`| `CRUD All` |
| **`assignments`** | `Read Own` | `Read Own` | `None` | `Read/Accept/Update`| `CRUD All` |
| **`distribution_records`**| `Read Summary`| `CRUD (Own)` | `Blocked` | `None` | `Read All` |
| **`notifications`** | `Read/Update Own`| `Read/Update Own`| `Read/Update Own`| `Read/Update Own`| `Read/Update Own`|
| **`audit_logs`** | `None` | `None` | `None` | `None` | `Read All` |

---

## 5. Two-Tier Data Visibility & Boundary Enforcement

| Data Field / Attribute | Public Discovery Feed | Unverified NGO | Verified NGO | Assigned Volunteer | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Listing Title, Category & Quantity | Yes | Yes | Yes | Yes | Yes |
| Approximate Area / Locality (`pickup_area_public`) | Yes | Yes | Yes | Yes | Yes |
| Collection Expiry Countdown | Yes | Yes | Yes | Yes | Yes |
| Donation Photographs | Yes | Yes | Yes | Yes | Yes |
| **Exact Door Address (`pickup_location_private`)** | **Hidden** | **Hidden** | **Hidden** | **Unlocked Upon Task Lock** | **Visible** |
| **Donor Contact Phone Number** | **Hidden** | **Hidden** | **Hidden** | **Unlocked Upon Task Lock** | **Visible** |
| NGO Registration Proof (PDF) | **Hidden** | **Hidden** | **Hidden (Own Only)** | **Hidden** | **Visible** |
| Beneficiary Aggregate Meal Counts | Yes | Yes | Yes | Yes | Yes |
| **Beneficiary Personal Identifiers** | **PROHIBITED** | **PROHIBITED** | **PROHIBITED** | **PROHIBITED** | **PROHIBITED** |

