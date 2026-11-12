# FoodBridge — Architectural Decision Records (ADR)

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 1 — Requirement Analysis  
**Status:** Active  

---

## ADR-001: Technology Stack Selection — Flutter & Supabase

### Context
FoodBridge requires a highly responsive, multi-role client capable of running on Android devices with seamless scalability to iOS and Web (for admin consoles), coupled with an event-driven backend supporting real-time subscriptions, secure relational data modeling, file storage, and strict row-level security.

### Decision
- **Frontend:** Flutter SDK (version 3.47.8+) with Dart 3.13.7+. Flutter provides a single codebase for high-performance reactive UI across mobile and responsive web.
- **Backend-as-a-Service:** Supabase (Managed PostgreSQL, Supabase Auth, Supabase Realtime, and Supabase Storage).
- **Architecture:** Clean Architecture with Feature-First modularization.

### Consequences
- **Positive:** Rapid development cycle; native PostgreSQL relational integrity; built-in Row Level Security (RLS) eliminates custom auth middleware complexity; out-of-the-box WebSocket channels.
- **Negative:** Dependent on Supabase connectivity; requires rigorous local SQLite/Hive caching for offline field scenarios.

---

## ADR-002: Two-Tier Location Privacy Architecture

### Context
Residential food and clothing donors face privacy and safety risks if their home address and contact details are publicly visible in open discovery feeds.

### Decision
Split all location data into two tiers:
1. `pickup_area_public`: Generalized neighborhood or pin code zone (e.g., "Bandra West, Zone 2") visible in open discovery feeds.
2. `pickup_location_private`: Detailed flat/building number, street address, and donor phone number locked at the database level. These are unlocked via Supabase RLS only to the verified NGO whose request is accepted and the specific volunteer assigned to the dispatch task.

### Consequences
- **Positive:** Protects donor privacy; prevents unauthorized visits; complies with data minimization principles.
- **Negative:** Volunteers cannot preview exact door-to-door transit time prior to accepting a task, only approximate route zones.

---

## ADR-003: Concurrency Control for Donation Allocation & Task Claiming

### Context
In high-demand urban areas, multiple NGOs may attempt to claim the same surplus food batch simultaneously, or multiple volunteers may attempt to claim the same dispatch task at the same instant.

### Decision
Implement server-side atomic locking in PostgreSQL using row-level transactions (`SELECT ... FOR UPDATE`) or atomic conditional update queries (`UPDATE assignments SET volunteer_id = :id, status = 'assigned' WHERE id = :taskId AND volunteer_id IS NULL`).

### Consequences
- **Positive:** Eliminates double-allocation and volunteer conflict. Guarantees zero duplicate pickups.
- **Negative:** Unsuccessful concurrent claimants receive a rejection response and must refresh their feed.

---

## ADR-004: Strict Demarcation of AI Capabilities & Food Safety Non-Certification

### Context
AI image recognition could be utilized to suggest donation categories. However, computer vision cannot determine bacterial safety, pathogen contamination, or true chemical freshness of prepared meals.

### Decision
1. AI is hosted in a decoupled Python/FastAPI microservice, phased into Phase 10.
2. AI features are purely advisory: broad category recommendation and rule-based NGO matching scores.
3. AI is explicitly barred by system design and UI disclaimers from certifying food freshness or safety.
4. Donors must provide explicit preparation disclosures, and receiving NGOs retain mandatory physical inspection rights.

### Consequences
- **Positive:** Eliminates dangerous health liability; ensures human accountability.
- **Negative:** Requires manual confirmation steps by donors and NGOs.



---

## ADR-005: Design System Tokenization, Multi-Modal Status & Devanagari Typography

### Context
FoodBridge requires an accessible UI accommodating diverse user groups: commercial donors working under time pressure, volunteers navigating streets in bright daylight, and community NGO staff. Colors alone must not be the sole conveyor of status, and multi-language support (Hindi and Marathi) demands proper font stack engineering.

### Decision
1. Implement a standardized design token system adhering to WCAG 2.1 AA standards:
   - Primary: `#218C5A`, Deep Green: `#145A3A`, Warm Cream: `#FFF8ED`, Charcoal: `#263238`, Muted Grey: `#667085`, Warning Orange: `#E69A36`, Error Red: `#C83D3D`.
2. Multi-Modal Status: Every lifecycle status chip pairs color tint, an explicit icon, and a plain-language text label.
3. Ergonomic Touch Targets: Minimum $48 \times 48\text{ dp}$ for all interactives; $56\text{ dp}$ for high-priority volunteer "Rider Mode" buttons with haptic feedback.
4. Typography: Inter font family for Latin characters, paired with Noto Sans Devanagari for Hindi and Marathi scripts with a $1.35$ line-height multiplier.

### Consequences
- **Positive:** Fully accessible to visually impaired and color-blind users; crystal-clear legibility in bright sunlight; prevents clipping of Devanagari vowel signs.
- **Negative:** Requires slightly larger vertical padding and dedicated localized font bundling.


---

## ADR-006: Clean Architecture & Supabase RLS Relational Schema Strategy

### Context
FoodBridge requires a scalable, maintainable mobile architecture adhering to SOLID principles, paired with a resilient, relational database model capable of enforcing role permissions, atomic quantity claims, and strict two-tier address privacy at the engine level rather than relying on client-side code.

### Decision
1. **Frontend Architecture:** Clean Architecture with Feature-First modularization (`lib/core/`, `lib/data/`, `lib/features/<feature>/{presentation,domain,data}`).
2. **Relational Model:** 12 normalized PostgreSQL tables with strict foreign key constraints, check constraints (e.g., non-negative quantities, mandatory safety declarations), and custom enumeration types.
3. **Database Security (RLS):** All 12 tables have Row Level Security enabled. Private donor address details are decrypted exclusively through a security-definer function (`get_donation_pickup_details`) accessible only to the donor, accepted NGO, and assigned volunteer.
4. **Atomic Concurrency Control:** Enforce critical state transitions and claims using atomic PostgreSQL stored procedures (`claim_donation_atomic` with `SELECT ... FOR UPDATE` row locks, and `accept_assignment_atomic`).

### Consequences
- **Positive:** Complete isolation of concerns; client-side tampering is impossible because permissions and concurrency are enforced in PostgreSQL; zero duplicate volunteer dispatches; zero race-condition over-allocations.
- **Negative:** Requires running database migration scripts and stored function definitions during initial backend setup.
