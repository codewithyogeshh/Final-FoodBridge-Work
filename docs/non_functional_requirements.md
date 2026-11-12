# FoodBridge — Non-Functional Requirements (NFR) Specification

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 1 — Requirement Analysis  
**Status:** Completed  

---

## 1. Overview & Quality Objectives

The Non-Functional Requirements (NFR) establish the architectural criteria, operational constraints, security boundaries, and user experience standards governing FoodBridge. Because the platform coordinates time-critical perishable food recovery and sensitive community resource distribution, reliability, security, accessibility, and zero-trust privacy are top design priorities.

---

## 2. Performance & Responsiveness (NFR-PERF)

| ID | Parameter | Target Metric | Architectural Strategy |
| :--- | :--- | :--- | :--- |
| **NFR-PERF-01** | Screen Render Latency | $< 100\text{ ms}$ for local navigation | Flutter const constructors, repainting isolation, lazy-loaded lists (`ListView.builder`). |
| **NFR-PERF-02** | API Response Time (P95) | $< 350\text{ ms}$ for standard queries | Indexed PostgreSQL foreign keys; Supabase PostgREST query optimization; minimal data payload. |
| **NFR-PERF-03** | Realtime Event Propagation | $< 1000\text{ ms}$ latency end-to-end | Supabase Realtime engine via persistent WebSocket connections; lightweight JSON event payloads. |
| **NFR-PERF-04** | Image Compression & Upload | $< 3\text{ seconds}$ on standard 4G | Client-side progressive image compression (downsampling to max 1920x1080, JPEG 80% quality) prior to transmission. |
| **NFR-PERF-05** | App Launch Time | Cold start $< 2.0\text{ s}$, Warm start $< 0.8\text{ s}$ | Deferred loading of non-critical SDKs; lean entrypoint (`main.dart`); splash screen asset caching. |
| **NFR-PERF-06** | Memory Footprint | Max RAM consumption $< 180\text{ MB}$ | Aggressive disposal of image cache buffers and active stream controllers upon route navigation. |

---

## 3. Security & Access Control (NFR-SEC)

| ID | Area | Specification | Implementation Standard |
| :--- | :--- | :--- | :--- |
| **NFR-SEC-01** | Authentication | Strong password hashing, cryptographic JWT issuance, refresh token rotation. | Supabase Auth with secure HTTP-only session cookies and Flutter Secure Storage (`flutter_secure_storage`). |
| **NFR-SEC-02** | Zero-Trust Client Policy | Never trust client-side role claims. Every query, mutation, and state transition enforced on server. | Supabase PostgreSQL Row Level Security (RLS) policies and PostgreSQL stored functions with `SECURITY DEFINER` where elevated privilege is verified. |
| **NFR-SEC-03** | Data in Transit | TLS 1.3 encryption across all communication endpoints (REST, WebSockets, Storage). | Strict HTTPS/WSS enforcement; SSL pinning candidate for production mobile builds. |
| **NFR-SEC-04** | Data at Rest | High-grade encryption for sensitive credentials and profile data. | AES-256 encryption at rest in Supabase PostgreSQL; mobile device secrets stored via Android Keystore / iOS Keychain. |
| **NFR-SEC-05** | Least Privilege Storage | Private storage buckets for NGO verification certificates and documents. | Scoped Supabase Storage access policies; public URLs disabled for confidential registration proofs. |
| **NFR-SEC-06** | Concurrency Safety | Prevent race conditions during simultaneous donation claims or volunteer task pickings. | Atomic PostgreSQL transactions (`SELECT ... FOR UPDATE` or conditional update constraints). |
| **NFR-SEC-07** | Protection against Injection | Zero possibility of SQL injection or script injection. | Parameterized queries natively enforced by PostgREST and Supabase Dart Client; client input sanitization. |

---

## 4. Privacy & Data Protection (NFR-PRIV)

| ID | Area | Specification | Compliance Detail |
| :--- | :--- | :--- | :--- |
| **NFR-PRIV-01** | Two-Tier Location Privacy | Protect physical safety of private donors. Public listing feeds must only disclose approximate area/locality (e.g., "Andheri West, Zone 4"). | Precise street address and donor phone number remain strictly locked behind RLS until a volunteer is officially assigned. |
| **NFR-PRIV-02** | Beneficiary Dignity | Direct individual recipients shall never be required to maintain platform accounts. | Eliminates digital barrier; protects vulnerable populations from digital surveillance. |
| **NFR-PRIV-03** | Distribution Privacy | Distribution records shall capture aggregate metrics (e.g., "120 meals served at Community Center B") without individual beneficiary names or photos. | Prevents stigmatization; satisfies strict data minimization principles. |
| **NFR-PRIV-04** | Data Retention & Deletion | Users have the right to request deletion of personal profile data. | Administrative workflow to anonymize donation records while preserving aggregate historical metrics. |

---

## 5. Accessibility & Human-Centered Design (NFR-A11Y)

| ID | Area | Specification | Benchmark |
| :--- | :--- | :--- | :--- |
| **NFR-A11Y-01** | Standard Compliance | Full adherence to Web Content Accessibility Guidelines. | **WCAG 2.1 Level AA** standards. |
| **NFR-A11Y-02** | Color Contrast Ratio | Text and essential UI controls must meet minimum contrast ratios against backgrounds. | Minimum $4.5:1$ for normal text; minimum $3.0:1$ for large text and interactive icons. Tested against `#218C5A` and `#145A3A`. |
| **NFR-A11Y-03** | Touch Target Sizing | All interactive touch elements (buttons, chips, form inputs, toggles) must be comfortably tappable. | Minimum physical bounding box of **$48 \times 48\text{ dp}$**. |
| **NFR-A11Y-04** | Screen Reader Support | All imagery, icon-only buttons, and state indicators must include semantic assistive descriptions. | Semantic labels on Flutter `IconButton`, `Semantics` widgets, and informative alternative text. |
| **NFR-A11Y-05** | Dynamic Text Scaling | Layouts must adapt seamlessly to user font scaling preferences without truncation or overflow. | Flutter `MediaQuery.textScaleFactorOf` handling; responsive auto-wrapping layouts; no hardcoded heights. |
| **NFR-A11Y-06** | Multi-Modal State Feedback | Never communicate status or errors by color alone. | Every state chip pairs color with an explicit semantic icon and text label (e.g., Red circle + Exclamation Icon + "Expired"). |

---

## 6. Internationalization & Localization (NFR-I18N)

| ID | Parameter | Specification |
| :--- | :--- | :--- |
| **NFR-I18N-01** | Supported Languages | **English (en)**, **Hindi (hi)**, **Marathi (mr)**. |
| **NFR-I18N-02** | Architecture | Flutter native localization using `flutter_localizations`, `intl`, and ARB (`.arb`) message resource bundles. |
| **NFR-I18N-03** | Dynamic Locale Switching | Users can change active language on the fly from Settings/Profile without restarting the application. |
| **NFR-I18N-04** | Number & Date Formatting | Standard localized date/time representations (e.g., 12-hour / 24-hour formats and local calendar formatting). |
| **NFR-I18N-05** | Metric System Standardization | Quantities displayed in standard SI units (Kilograms, Liters, Portions/Meals, Units/Pieces). |

---

## 7. Reliability, Availability & Fault Tolerance (NFR-REL)

| ID | Parameter | Specification |
| :--- | :--- | :--- |
| **NFR-REL-01** | Target Uptime | $99.9\%$ operational uptime for core donation and dispatch services. |
| **NFR-REL-02** | Offline Form Protection | In-flight donation form inputs are preserved in local device cache to prevent data loss on network drops. |
| **NFR-REL-03** | Graceful Degradation | If Supabase Realtime WebSocket drops, client automatically fails over to interval polling until reconnected. |
| **NFR-REL-04** | Idempotent Mutations | Network retry requests (e.g., repeating a pickup confirmation tap) use client-generated idempotency keys to prevent duplicate database writes. |
| **NFR-REL-05** | Comprehensive Error Handling | Informative, user-friendly error banners and offline indicators with clear retry actions instead of generic crashes. |

---

## 8. Scalability & Maintainability (NFR-MAINT)

| ID | Parameter | Specification |
| :--- | :--- | :--- |
| **NFR-MAINT-01**| Architecture Paradigm | **Clean Architecture** with strict layer separation: Domain (Entities, Use Cases), Data (Models, Repositories, Data Sources), Presentation (State, Widgets). |
| **NFR-MAINT-02**| Modularization | Feature-first folder structure (`features/donor`, `features/ngo`, `features/volunteer`, `features/admin`, etc.). |
| **NFR-MAINT-03**| Code Quality Standards | Adherence to Effective Dart guidelines; zero warnings under `flutter analyze`; strict typing enabled. |
| **NFR-MAINT-04**| Database Extensibility | Normalized PostgreSQL relational schema with foreign key cascading and database migration scripts. |
| **NFR-MAINT-05**| Decoupled AI Pipeline | AI service hosted as an isolated FastAPI microservice; failures in AI service never block core donation creation or claiming. |

