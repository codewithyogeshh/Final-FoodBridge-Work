# FoodBridge — Requirement Traceability Matrix (RTM)

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 1 — Requirement Analysis  
**Status:** Completed  
**Deliverable Location:** `docs/analysis/requirement_traceability_matrix.md`  

---

## 1. Overview & Traceability Structure

The Requirement Traceability Matrix (RTM) establishes bidirectional traceability ensuring that every requirement defined in `docs/prd.md` is mapped to an Agile User Story, implemented via an Architectural Feature, and validated through a testable Acceptance Criterion.

---

## 2. Full Traceability Matrix

| PRD Requirement Ref & Description | User Story ID | Functional Feature | Acceptance Test (Gherkin) |
| :--- | :--- | :--- | :--- |
| **FR-01:** Secure user registration & sign-in | `US-AUTH-01` | Supabase Auth Integration & Session Manager | `AC-AUTH-01` (Multi-Role Registration) |
| **FR-02:** Role-specific permissions (RBAC) | `US-AUTH-01` | PostgreSQL Row Level Security (RLS) & Role Routing | `AC-AUTH-01` (Admin Signup Block) |
| **FR-03:** NGO administrator verification gating | `US-AUTH-02` | Split-Screen Admin Verification Queue & Status Guard | `AC-AUTH-02` (NGO Verification Gating) |
| **FR-04:** Profile updates & account management | `US-AUTH-03` | User Profile Controller & Vehicle Availability Config | `AC-AUTH-03` (Volunteer Availability) |
| **FR-05:** Food & clothing donation posting | `US-DON-01`, `US-DON-02` | Flash Donation Wizard (Multi-step Form) | `AC-DON-01`, `AC-DON-02` (Donation Creation) |
| **FR-06:** Common attributes, photos, pickup area | `US-DON-01`, `US-DON-03` | Two-Tier Location Vault & Supabase Image Storage | `AC-DON-03` (Two-Tier Privacy Protection) |
| **FR-07:** Food prep time, storage & deadline | `US-DON-01` | Perishable Food Attributes & Expiry Engine | `AC-DON-01` (Deadline & Declaration) |
| **FR-08:** Edit or cancel active donation | `US-DON-04` | Donation Status State Machine (Cancellation Guard) | `AC-DON-04` (Edit & Cancellation) |
| **FR-09:** Real-time active status display | `US-DON-01`, `US-NGO-01` | Multi-Modal Status Chips & Progress Indicators | `AC-RT-01` (Status Synchronization) |
| **FR-10:** Status change history & audit trail | `US-ADM-03` | Immutable `audit_logs` Trigger & Event Timeline | `AC-ADM-03` (Audit Log Review) |
| **FR-11:** NGO discovery feed & multi-facet filters | `US-NGO-01` | Indexed Geo-Filter Discovery Feed | `AC-NGO-01` (Filter & Discovery) |
| **FR-12:** NGO claim request submission | `US-NGO-02`, `US-NGO-03` | Claim Modal & Transport Mode Selector | `AC-NGO-02` (Claim Request) |
| **FR-13:** Prevent conflicting/over-allocation | `US-NGO-02` | Atomic Concurrency Lock (`claim_donation_atomic`) | `AC-NGO-02` (Atomic Concurrency Lock) |
| **FR-14:** Request status updates & right of refusal| `US-NGO-04` | Doorstep Quality Rejection Dialog & Incident Flag | `AC-NGO-04` (Physical Quality Rejection) |
| **FR-15:** Volunteer open task feed | `US-VOL-01` | High-Contrast "Rider Mode" Task Feed | `AC-VOL-01` (Task Discovery) |
| **FR-16:** Single-volunteer assignment lock | `US-VOL-01` | Atomic Task Lock (`accept_assignment_atomic`) | `AC-VOL-01` (Single-Volunteer Lock) |
| **FR-17:** Pickup & handover confirmation | `US-VOL-03`, `US-DIST-01` | One-Touch Action Buttons ($56\text{ dp}$ with Haptic) | `AC-VOL-03`, `AC-DIST-01` (Pickup/Handover) |
| **FR-18:** Address privacy restricted to assigned | `US-VOL-02` | Security Definer RPC `get_donation_pickup_details` | `AC-VOL-02` (Address Decryption) |
| **FR-19:** Real-time event notifications | `US-RT-01` | In-App Notification Center & Push Triggers | `AC-RT-01` (Status Notifications) |
| **FR-20:** User activity timeline | `US-RT-01` | Consolidated Event Timeline Component | `AC-RT-01` (Timeline View) |
| **FR-21:** WebSocket dynamic feed refresh | `US-RT-02` | Supabase Realtime Channels (`postgres_changes`) | `AC-RT-02` (WebSocket Live Sync) |
| **FR-22:** Administrator verification queue | `US-ADM-01` | Split-Screen Admin Document Reviewer | `AC-ADM-01` (Admin Review Queue) |
| **FR-23:** Moderation & account suspension | `US-ADM-02` | Dispute Console & Account Suspension Actions | `AC-ADM-02` (Account Moderation) |
| **FR-24:** Platform oversight & aggregate metrics | `US-ADM-02` | Real-Time Platform Dashboard & Metric Stream | `AC-ADM-02` (Global Oversight) |
| **FR-25:** Sensitive administrative audit logging | `US-ADM-03` | Immutable System Audit Ledger | `AC-ADM-03` (Audit Log Review) |
| **FR-26:** Advisory NGO matching | `US-AI-01` | Python/FastAPI Proximity & Capacity Scorer | `AC-AI-01` (Advisory Matching) |
| **FR-27:** Advisory image classification | `US-AI-02` | Python/FastAPI Computer Vision Category Tagger | `AC-AI-02` (Image Suggestion) |
| **FR-28:** Historical demand analytics | `US-AI-03` | Aggregated Time-Series Demand Forecasting | `AC-AI-03` (Demand Summary) |
| **FR-29:** Approved documentation FAQ chatbot | `US-AI-04` | Retrieval-Augmented FAQ Assistant | `AC-AI-04` (Help Assistant) |
| **FR-30:** AI non-certification of food safety | `US-AI-05` | Mandatory Disclaimers & Manual Fallback Guards | `AC-AI-05` (AI Safety Restriction) |
| **PRD §5.5:** Beneficiary dignity & privacy | `US-DIST-02` | Zero Beneficiary Accounts & Aggregate Reporting | `AC-DIST-02` (PII Prohibition) |
| **PRD §9:** Automated deadline expiration | `US-SYS-01` | Scheduled Database Expiry Cron / Background Worker | `AC-SYS-01` (Automated Expiry) |

