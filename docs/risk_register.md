# FoodBridge — Comprehensive Risk Register & Mitigation Strategy

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 1 — Requirement Analysis  
**Status:** Completed  

---

## 1. Risk Evaluation Methodology

Risks are evaluated using a standard $5 \times 5$ Risk Severity Matrix:
$$\text{Severity Score} = \text{Probability (1–5)} \times \text{Impact (1–5)}$$

- **Critical ($16 - 25$):** Immediate architectural mitigation required before implementation.
- **High ($10 - 15$):** Detailed mitigation plan and active monitoring needed.
- **Medium ($5 - 9$):** Managed via standard development controls and error handling.
- **Low ($1 - 4$):** Accepted with periodic review.

---

## 2. Risk Matrix & Log

| Risk ID | Category | Risk Description | P (1-5) | I (1-5) | Score | Level | Primary Mitigation Strategy | Contingency Plan | Owner |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- | :--- | :--- |
| **RSK-01** | **Safety / Legal** | Donated cooked food spoils or causes foodborne illness among community recipients. | 3 | 5 | **15** | **High** | Mandatory preparation timestamp, storage conditions, and strict collection deadline; explicit donor declarations; mandatory physical inspection by NGO at handover; AI strictly forbidden from certifying food freshness. | Immediate rejection workflow, batch quarantine, automatic admin incident ticket, partner insurance/good samaritan legal compliance. | Lead Architect / Product Owner |
| **RSK-02** | **Technical** | Race conditions & concurrent over-allocation: Multiple NGOs claim the same surplus quantity simultaneously. | 4 | 4 | **16** | **Critical** | Database-level concurrency control using atomic PostgreSQL transactions with `SELECT ... FOR UPDATE` and quantity check constraints. | Rollback failed transaction; return immediate user feedback: "Quantity just claimed by another organization". | Backend Engineer |
| **RSK-03** | **Security / Privacy** | Exposure of donor private residential address or phone number in public feeds. | 2 | 5 | **10** | **High** | Two-tier location architecture enforced at the database level via Supabase Row Level Security (RLS). Public feed only returns approximate locality. Exact address visible only to assigned volunteer and accepted NGO. | Immediate revoking of compromised sessions, audit log investigation, and privacy patch. | Security / Backend Lead |
| **RSK-04** | **Privacy** | Dignity violation or privacy leak of vulnerable community beneficiaries. | 2 | 4 | **8** | **Medium** | Beneficiaries never register or login to the app. Distribution records prohibit individual personal identifiers (names, photos, IDs), collecting only aggregate metrics. | Sanitize distribution records at the schema constraint level. | Data Protection Officer |
| **RSK-05** | **Operational** | Volunteer no-show or pickup abandonment: Volunteer accepts task but fails to collect before food expires. | 4 | 4 | **16** | **Critical** | Automated countdown timer on accepted tasks; volunteer active task limit (max 2); push reminders 45 mins before deadline; one-touch emergency task release button. | Automatic task reversion to `open` status for urgent re-dispatch if unconfirmed 30 minutes before deadline. | Operations / Volunteer Lead |
| **RSK-06** | **Technical** | Intermittent or weak 3G/4G network connectivity during field pickup in basement/dense areas. | 4 | 3 | **12** | **High** | Optimistic UI updates with client-side SQLite/Hive caching; idempotent API request tokens to prevent duplicate commits on network retries. | Offline queuing with automatic background synchronization when connectivity resumes. | Flutter Mobile Lead |
| **RSK-07** | **Fraud / Abuse** | Fraudulent NGO creates account to collect free donations for commercial resale. | 2 | 5 | **10** | **High** | Mandatory legal verification (registration certificates, 80G/12A/tax IDs); manual administrator verification queue before claim privileges are unlocked. | Immediate administrative account suspension, blacklisting of registration credentials, and legal notification. | Platform Administrator |
| **RSK-08** | **Quality** | Donors dump stained, torn, unwashed clothing, overburdening NGO sorting capacity. | 4 | 2 | **8** | **Medium** | Strict condition standards during posting (`new_with_tags`, `gently_used`, `good_wearable`); required photos; mandatory cleanliness confirmation checkbox. | Receiving NGO has formal right to reject unsuitable clothing items upon delivery. | Product / NGO Lead |
| **RSK-09** | **Technical** | Supabase Realtime WebSocket drops or fails to deliver state changes to mobile clients. | 3 | 3 | **9** | **Medium** | Automatic WebSocket reconnect handler in Flutter client; fallback to intelligent polling (every 15–30s) when WebSocket is disconnected. | Manual pull-to-refresh available on all list screens. | Frontend Lead |
| **RSK-10** | **AI Safety** | Flawed AI image classification misidentifies allergens or declares spoiled food "safe". | 3 | 4 | **12** | **High** | AI service decoupled in FastAPI; advisory only; image category suggestion requires mandatory human confirmation; AI strictly barred from evaluating food safety or edibility. | Disclaimers on all AI suggestions; manual dropdown always remains the authoritative source. | AI Engineer |

---

## 3. Risk Monitoring & Review Schedule

- **Sprint Planning / Phase Transitions:** Re-evaluate active risks against implemented architectural controls.
- **Incident Triggers:** Any reported food safety incident, data exposure, or allocation failure triggers an emergency review within 24 hours.
- **Audit Trails:** Immutable logging in `audit_logs` records all lifecycle transitions and administrative approvals to support post-incident analysis.

