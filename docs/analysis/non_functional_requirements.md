# FoodBridge — Non-Functional Requirements (NFR) Specification

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 1 — Requirement Analysis  
**Status:** Completed  
**Deliverable Location:** `docs/analysis/non_functional_requirements.md`  

---

## 1. Overview & Quality Engineering Goals

This document extracts and defines the non-functional benchmarks, architectural constraints, and quality attributes governing FoodBridge. Each requirement has a unique identifier and is prioritized using the **MoSCoW** framework.

---

## 2. Performance & Responsiveness (NFR-PERF)

| ID | Priority | Metric / Target | Implementation Strategy |
| :--- | :---: | :--- | :--- |
| **NFR-PERF-01** | **[MUST]** | Local screen render latency $< 100\text{ ms}$. | Const constructors, repainting isolation, lazy-loaded lists (`ListView.builder`). |
| **NFR-PERF-02** | **[MUST]** | API query response time (P95) $< 350\text{ ms}$. | Optimized PostgREST queries, B-tree indexes on foreign keys and active statuses. |
| **NFR-PERF-03** | **[SHOULD]**| Realtime WebSocket propagation $< 1000\text{ ms}$. | Supabase Realtime persistent WebSocket connection with lightweight JSON payloads. |
| **NFR-PERF-04** | **[MUST]** | Image upload completion $< 3.0\text{ s}$ on 4G. | Client-side compression downsampling to max $1920 \times 1080$, JPEG 80% quality. |
| **NFR-PERF-05** | **[SHOULD]**| Mobile cold start $< 2.0\text{ s}$, warm start $< 0.8\text{ s}$. | Deferred initialization of non-essential SDKs; splash screen asset pre-caching. |
| **NFR-PERF-06** | **[MUST]** | Mobile RAM consumption $< 180\text{ MB}$. | Image cache buffer clearing upon route navigation; proactive stream controller disposal. |

---

## 3. Security & Access Control (NFR-SEC)

| ID | Priority | Requirement Specification | Standard / Enforcement |
| :--- | :---: | :--- | :--- |
| **NFR-SEC-01** | **[MUST]** | Cryptographic session tokens and secure credential storage. | Supabase Auth issuing RS256 JWTs; stored securely on mobile via `flutter_secure_storage`. |
| **NFR-SEC-02** | **[MUST]** | Zero-trust client policy: Never trust client-side role claims. | Enforced at the database engine level via Supabase PostgreSQL Row Level Security (RLS). |
| **NFR-SEC-03** | **[MUST]** | TLS 1.3 encryption across all communication endpoints (REST, WebSockets, Storage). | Enforced HTTPS / WSS communication; strict SSL certificate verification. |
| **NFR-SEC-04** | **[MUST]** | High-grade encryption at rest for sensitive profile credentials. | AES-256 encryption at rest in PostgreSQL database. |
| **NFR-SEC-05** | **[MUST]** | Scoped, private storage access for sensitive NGO verification proofs. | Private Supabase Storage bucket; public read access completely disabled. |
| **NFR-SEC-06** | **[MUST]** | Concurrency safety: Prevent race conditions and double-allocation. | Atomic PostgreSQL transactions with `SELECT ... FOR UPDATE` and conditional update queries. |
| **NFR-SEC-07** | **[MUST]** | Immunity against SQL and script injection. | Parameterized queries natively enforced by PostgREST and Supabase client library. |

---

## 4. Privacy & Dignity Protection (NFR-PRIV)

| ID | Priority | Requirement Specification | Compliance Detail |
| :--- | :---: | :--- | :--- |
| **NFR-PRIV-01** | **[MUST]** | Two-tier location privacy geofencing. | Public discovery feeds display approximate locality. Exact street address locked behind RLS. |
| **NFR-PRIV-02** | **[MUST]** | Beneficiary dignity & zero surveillance. | Beneficiaries never register accounts. Distribution records capture strictly aggregate counts. |
| **NFR-PRIV-03** | **[MUST]** | Prohibition of beneficiary PII. | The database schema strictly prohibits storing beneficiary names, phone numbers, or photos. |
| **NFR-PRIV-04** | **[SHOULD]**| User data erasure & account deactivation. | Administrative workflow to anonymize donation records while preserving aggregate historical metrics. |

---

## 5. Accessibility Standards (NFR-A11Y)

| ID | Priority | Requirement Specification | Compliance Detail |
| :--- | :---: | :--- | :--- |
| **NFR-A11Y-01** | **[MUST]** | Adherence to WCAG 2.1 Level AA accessibility standards. | Audited color contrast ratios, screen-reader labels, and scalable typography. |
| **NFR-A11Y-02** | **[MUST]** | Minimum contrast ratios: $\ge 4.5:1$ for normal text, $\ge 3.0:1$ for large text. | Tested against `#218C5A` primary green, `#263238` charcoal, and `#FFF8ED` cream background. |
| **NFR-A11Y-03** | **[MUST]** | Minimum physical touch target of **$48 \times 48\text{ dp}$**. | Enforced on all buttons, chips, form inputs, and navigation icons; $56\text{ dp}$ for "Rider Mode". |
| **NFR-A11Y-04** | **[MUST]** | Complete screen reader semantic descriptions. | Flutter `Semantics` widgets and tooltips on all icon buttons and status chips. |
| **NFR-A11Y-05** | **[MUST]** | Dynamic text scaling up to **$2.0\times$** without clipping or overflow. | Responsive wrapping layouts; zero fixed container heights wrapping variable text spans. |
| **NFR-A11Y-06** | **[MUST]** | Multi-modal state feedback: Never communicate state by color alone. | Every state chip pairs color tint with an explicit semantic icon and text label. |

---

## 6. Internationalization & Localization (NFR-I18N)

| ID | Priority | Requirement Specification | Implementation Detail |
| :--- | :---: | :--- | :--- |
| **NFR-I18N-01** | **[MUST]** | Support three core languages: **English (`en`)**, **Hindi (`hi`)**, and **Marathi (`mr`)**. | Implemented using standard Flutter `.arb` resource bundles and `flutter_localizations`. |
| **NFR-I18N-02** | **[MUST]** | Dynamic locale switching from Profile / Settings without restarting the app. | Localized state provider instantly refreshing active UI tree. |
| **NFR-I18N-03** | **[MUST]** | Proper Devanagari script typography rendering. | Noto Sans Devanagari font with a $1.35$ line-height multiplier to prevent matra vowel clipping. |
| **NFR-I18N-04** | **[MUST]** | Standardized SI units with localized abbreviations. | Quantities expressed in standard kilograms (`kg`), liters (`L`), portions, and pieces (`pcs`). |

---

## 7. Reliability, Maintainability & Architecture (NFR-REL / NFR-MAINT)

| ID | Priority | Requirement Specification | Implementation Detail |
| :--- | :---: | :--- | :--- |
| **NFR-REL-01** | **[MUST]** | Target service uptime of $99.9\%$ for core donation workflows. | Managed Supabase infrastructure with automated daily database backups. |
| **NFR-REL-02** | **[MUST]** | Offline input preservation. | In-flight donation form inputs cached locally in device memory to prevent loss on network drop. |
| **NFR-REL-03** | **[MUST]** | Idempotent mutations for network retries. | Client-generated idempotency tokens preventing duplicate database inserts upon repeated taps. |
| **NFR-MAINT-01**| **[MUST]** | Clean Architecture with Feature-First modularization. | Strict boundary separation: `core/`, `data/`, and `features/<feature>/{presentation,domain,data}`. |
| **NFR-MAINT-02**| **[MUST]** | Effective Dart compliance and zero static analysis warnings. | Zero errors or warnings under `flutter analyze` with strict typing enabled. |
| **NFR-MAINT-03**| **[MUST]** | Decoupled AI architecture. | AI microservice hosted separately in FastAPI; outages in AI service never block core donation flows. |

