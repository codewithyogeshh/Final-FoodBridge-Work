# FoodBridge — Feature Ideation & Solution Prioritization

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 2 — Design Thinking & Empathy Mapping  
**Status:** Completed  
**Methodological Note:** Feature concepts were brainstormed against the 16 "How Might We" challenges, then evaluated on a $2 \times 2$ Impact vs. Feasibility matrix to identify high-leverage innovations for the FoodBridge MVP and subsequent phases.

---

## 1. Feature Brainstorming & Concept Catalog

| Ref ID | Problem Addressed | Proposed Feature Concept | Mechanism & User Experience |
| :--- | :--- | :--- | :--- |
| **FEAT-01** | HMW-DON-01 (Speed) | **"Flash Donation" 3-Step Wizard** | Pre-populated category templates, smart sliders for box counts, automatic GPS area lookup, and camera fast-capture. |
| **FEAT-02** | HMW-DON-03 (Privacy) | **Two-Tier Geofenced Address Vault** | Public feed displays neighborhood radius (e.g., "Andheri West, Zone 2"). Exact door number and phone number are decrypted via RLS only upon task lock. |
| **FEAT-03** | HMW-DON-02 (Safety) | **Standardized Handling & Expiry Badge** | Visual temperature chips (`Hot Holding`, `Refrigerated`, `Ambient`), required prep timestamps, and prominent countdown clocks. |
| **FEAT-04** | HMW-DON-04 (Impact) | **Digital CSR Impact Certificate** | Automatic calculation of kilograms rescued, meals equivalent, and carbon offset, downloadable as a PDF certificate. |
| **FEAT-05** | HMW-NGO-02 (No Double Claims) | **Atomic Concurrency Reservation Lock** | Database-level row locking (`SELECT ... FOR UPDATE`) reserving available quantity atomically during claim submission. |
| **FEAT-06** | HMW-NGO-03 (Rejection Right)| **Zero-Penalty Doorstep Quality Rejection**| One-touch "Decline Delivery" option at physical handover with non-punitive reason tags (`temperature_abused`, `unpleasant_odour`, `soiled`). |
| **FEAT-07** | HMW-NGO-04 (Privacy-Preserving Reporting)| **Aggregate Distribution Logger** | One-screen distribution logger capturing bulk meal/clothing counts without demanding beneficiary names or photos. |
| **FEAT-08** | HMW-VOL-01 (Field Usability) | **"Rider Mode" High-Contrast UI** | Minimum $48 \times 48\text{ dp}$ buttons, high-contrast palette (`#218C5A` and `#FFFFFF`), prominent status pills, and large tap areas for gloves. |
| **FEAT-09** | HMW-VOL-02 (Exclusivity) | **Single-Volunteer Atomic Claim Lock** | Conditional SQL update locking the task exclusively to the first volunteer who taps "Accept", eliminating duplicate dispatch. |
| **FEAT-10** | HMW-VOL-03 (Cargo Feasibility)| **Vehicle & Cargo Sizing Badge** | Visual cargo tags (`Motorcycle-friendly: \le 10 kg`, `Car/Van Required`) displayed prominently before task acceptance. |
| **FEAT-11** | HMW-VOL-04 (Emergency Release)| **One-Touch Emergency Task Surrender** | Instant "Cannot Complete Task" trigger (e.g., vehicle puncture) that immediately reverts the task to `open` for nearby volunteers. |
| **FEAT-12** | HMW-ADM-01 (Rapid Vetting) | **Split-Screen Verification Console** | Web portal displaying applicant NGO data side-by-side with high-resolution PDF certificate viewer and national registry checklist. |
| **FEAT-13** | HMW-ADM-02 (Auditability) | **Immutable Ledger Timeline** | Complete chronological audit log of every actor, timestamp, previous status, and new status for 100% dispute resolution. |
| **FEAT-14** | HMW-RT-01 (Live Sync) | **WebSocket Live State Sync** | Supabase Realtime subscriptions updating active donation and task cards dynamically without requiring manual pull-to-refresh. |

---

## 2. Impact vs. Feasibility Evaluation Matrix

Evaluation Scale:
- **Impact (1 to 5):** Transformative value for user trust, safety, and operational speed.
- **Feasibility (1 to 5):** Technical simplicity and alignment with Flutter + Supabase architecture (5 = High Feasibility / Low Complexity).

```
High Impact ▲
            │  [FEAT-05] Atomic Concurrency Lock      [FEAT-01] Flash Donation Wizard
            │  [FEAT-09] Single-Volunteer Task Lock   [FEAT-02] Two-Tier Address Vault
            │  [FEAT-03] Expiry Countdown Badges      [FEAT-08] "Rider Mode" Touch Targets
            │  [FEAT-06] Handover Rejection Right     [FEAT-14] WebSocket Live Sync
            │  [FEAT-07] Aggregate Distribution Log   [FEAT-10] Vehicle Sizing Badges
            │  [FEAT-12] Admin Verification Console   [FEAT-11] Emergency Task Surrender
            │  ─────────────────────────────────────────────────────────────────────────
            │  [FEAT-13] Immutable Audit Trail        [FEAT-04] Digital Impact Certificate
            │  [AI-Matching] (Deferred Phase 10)      [Complex Route TSP] (Out of Scope)
            │
            └──────────────────────────────────────────────────────────────────────────►
            Low Feasibility / High Effort                   High Feasibility / Low Effort
```

---

## 3. Prioritized Feature Roadmap

### 3.1 Priority 1: Core MVP Architecture (Phases 5 – 9)
1. **FEAT-01: Flash Donation Wizard:** Streamlined multi-step food and clothing creation.
2. **FEAT-02: Two-Tier Geofenced Address Vault:** RLS-enforced location privacy.
3. **FEAT-03: Expiry Countdown Badges & Declarations:** Perishable food safety cutoff.
4. **FEAT-05: Atomic Concurrency Reservation Lock:** PostgreSQL race-condition protection.
5. **FEAT-06: Zero-Penalty Doorstep Rejection:** Safeguarding NGO recipients.
6. **FEAT-07: Aggregate Distribution Logger:** Dignity-preserving community reporting.
7. **FEAT-08: "Rider Mode" Ergonomic UI:** Large touch targets and high-contrast styling for volunteers.
8. **FEAT-09: Single-Volunteer Task Lock:** Eliminates duplicate volunteer claims.
9. **FEAT-10: Vehicle Cargo Sizing Badges:** Motorcycle vs. Car weight indicators.
10. **FEAT-11: One-Touch Emergency Surrender:** Re-dispatch protection for perishable food.
11. **FEAT-12: Admin Verification Console:** NGO credential vetting interface.
12. **FEAT-13: Immutable Audit Trail:** Complete lifecycle traceability.
13. **FEAT-14: WebSocket Live State Sync:** Realtime dashboard refresh.

### 3.2 Priority 2: Delight & Expansion Features (Phases 10 – 12)
1. **FEAT-04: Digital Impact Certificate:** PDF generation celebrating donor milestones.
2. **AI Advisory Recommendation:** Proximity and capacity matching scores (FastAPI microservice).
3. **AI Category Suggestions:** Advisory image tagger with mandatory human confirmation.

### 3.3 Out of Scope / Deprioritized
- Payment gateways, digital wallets, or cash handling.
- Continuous background GPS tracking of volunteers (invasive to battery and privacy).
- Automated AI certification of food freshness or safety.

