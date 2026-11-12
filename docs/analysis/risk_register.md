# FoodBridge — Risk Register & Mitigation Strategy

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 1 — Requirement Analysis  
**Status:** Completed  
**Deliverable Location:** `docs/analysis/risk_register.md`  

---

## 1. Risk Evaluation Framework

All identified risks are quantified using a $5 \times 5$ Risk Severity Matrix:
$$\text{Risk Score} = \text{Probability (1–5)} \times \text{Impact (1–5)}$$

- **Critical ($16 - 25$):** Non-negotiable architectural controls required prior to coding.
- **High ($10 - 15$):** Proactive mitigation plans and automated safeguards.
- **Medium ($5 - 9$):** Managed via validation logic and UI constraints.
- **Low ($1 - 4$):** Accepted with periodic review.

---

## 2. Risk Matrix & Log

| Risk ID | Category | Risk Description | P | I | Score | Level | Primary Mitigation Strategy | Fallback / Contingency | Owner |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- | :--- | :--- |
| **RSK-01** | **Safety / Legal** | Donated cooked food spoils in transit or causes foodborne illness. | 3 | 5 | **15** | **High** | Mandatory preparation timestamp, holding conditions, strict collection deadlines; explicit donor declarations; NGO physical inspection rights; AI strictly barred from certifying food safety. | Immediate doorstep rejection workflow; automated admin incident alert; partner insurance compliance. | Lead Architect |
| **RSK-02** | **Technical** | Race conditions & concurrent over-allocation: Multiple NGOs claim the same surplus batch simultaneously. | 4 | 4 | **16** | **Critical** | Database-level concurrency control via atomic PostgreSQL transactions (`claim_donation_atomic` using `SELECT ... FOR UPDATE`). | Rollback failed transaction; return immediate user feedback: "Quantity just claimed by another organization". | Backend Engineer |
| **RSK-03** | **Security / Privacy** | Exposure of donor residential address or phone number on public feeds. | 2 | 5 | **10** | **High** | Two-tier location architecture enforced via Supabase Row Level Security (RLS) and security-definer function `get_donation_pickup_details()`. | Immediate session revocation, access token refresh, and privacy incident log. | Security Lead |
| **RSK-04** | **Privacy** | Dignity violation or privacy leak of vulnerable community recipients. | 2 | 4 | **8** | **Medium** | Beneficiaries never register accounts. Distribution records prohibit storing individual personal identifiers (names, photos, IDs), capturing only aggregate counts. | Database schema check constraints rejecting personal identity fields. | Data Protection Officer |
| **RSK-05** | **Operational** | Volunteer no-show or pickup abandonment: Volunteer accepts task but fails to arrive before food expires. | 4 | 4 | **16** | **Critical** | Automated countdown timer; volunteer active task limit (max 2); push reminders 45 mins before deadline; one-touch emergency task release button. | Automatic task reversion to `open` status for urgent re-dispatch if unconfirmed 30 minutes before deadline. | Operations Lead |
| **RSK-06** | **Technical** | Intermittent or weak 3G/4G network connectivity during field pickup in dense urban areas. | 4 | 3 | **12** | **High** | Optimistic UI updates with client-side caching; idempotent API request tokens to prevent duplicate commits on network retries. | Offline queuing with automatic background synchronization when connectivity resumes. | Flutter Mobile Lead |
| **RSK-07** | **Fraud / Abuse** | Fraudulent organization registers to collect free donations for commercial resale. | 2 | 5 | **10** | **High** | Mandatory legal verification (registration certificates, 80G/12A/tax IDs); manual administrator verification queue before claim privileges are unlocked. | Immediate administrative account suspension, blacklisting of registration credentials, and legal notification. | Platform Administrator |
| **RSK-08** | **Quality** | Donors dump stained, torn, unwashed clothing, overburdening NGO sorting capacity. | 4 | 2 | **8** | **Medium** | Strict condition standards during posting (`new_with_tags`, `gently_used`, `good_wearable`); required photos; mandatory cleanliness confirmation checkbox. | Receiving NGO has formal right to reject unsuitable clothing items upon delivery. | Product Lead |
| **RSK-09** | **Technical** | Supabase Realtime WebSocket drops or fails to deliver state changes to mobile clients. | 3 | 3 | **9** | **Medium** | Automatic WebSocket reconnect handler in Flutter client; fallback to intelligent polling (every 15–30s) when WebSocket is disconnected. | Manual pull-to-refresh available on all list screens. | Frontend Lead |
| **RSK-10** | **AI Safety** | Flawed AI image classification misidentifies allergens or declares spoiled food "safe". | 3 | 4 | **12** | **High** | AI service decoupled in FastAPI; advisory only; image category suggestion requires mandatory human confirmation; AI strictly barred from evaluating food safety or edibility. | Disclaimers on all AI suggestions; manual dropdown always remains the authoritative source. | AI Engineer |

