# FoodBridge

> **Share More. Waste Less. Bridge the Need.**

FoodBridge is a real-time food and clothing donation and redistribution platform designed to connect donors, verified NGOs, community volunteers, and administrators to reduce waste and get essential resources to those who need them most.

---

## 🌟 Key Features

- **Multi-Role Experience:** Dedicated interfaces and workflows for **Donors**, **NGOs**, **Volunteers**, and **Administrators**.
- **Dual Donation Streams:**
  - **Surplus Food:** Time-sensitive recovery with strict collection deadlines, storage requirements, allergen warnings, and preparation disclosures.
  - **Wearable Clothing:** Structured listing with categories, sizing, and cleanliness confirmations.
- **Traceable Chain of Custody:** Real-time lifecycle tracking (`available` $\rightarrow$ `requested` $\rightarrow$ `accepted` $\rightarrow$ `assigned_for_pickup` $\rightarrow$ `picked_up` $\rightarrow$ `delivered_to_ngo` $\rightarrow$ `distributed` $\rightarrow$ `completed`).
- **Two-Tier Privacy Protection:** Public feeds display approximate locality zones; precise street addresses are revealed only to assigned volunteers and accepted NGOs.
- **Atomic Concurrency Control:** Prevents double-claiming of donations and race conditions in volunteer task assignment.
- **NGO Verification Engine:** Administrative vetting of non-profit legal certificates before donation claims can occur.
- **Human-First Safety:** AI is strictly advisory; food safety is governed by donor declarations and mandatory NGO physical inspection.
- **Inclusive Design:** Multi-language support (English, Hindi, Marathi) and WCAG 2.1 Level AA accessibility.

---

## 🛠️ Technology Stack

- **Frontend:** Flutter SDK (3.47.8+) / Dart (3.13.7+)
- **Architecture:** Clean Architecture with Feature-First modular structure
- **Backend:** Supabase (PostgreSQL with Row Level Security, Auth, Realtime WebSockets, Storage)
- **AI Services (Phased):** Python & FastAPI (isolated microservice for advisory matching and category recommendations)

---

## 📚 Project Documentation

The project follows a rigorous 12-phase Software Development Life Cycle (SDLC):

| Document | Purpose |
| :--- | :--- |
| [requirement_analysis.md](file:///d:/ys/docs/requirement_analysis.md) | Problem analysis, solution architecture, scope management, MoSCoW framework |
| [functional_requirements.md](file:///d:/ys/docs/functional_requirements.md) | Granular functional specifications (FR-AUTH, FR-DON, FR-NGO, FR-VOL, FR-DIST, FR-ADM) |
| [non_functional_requirements.md](file:///d:/ys/docs/non_functional_requirements.md) | Performance, security, privacy, accessibility (WCAG AA), localization |
| [user_roles.md](file:///d:/ys/docs/user_roles.md) | Stakeholder profiles, CRUD permissions matrix, state transition authority |
| [user_stories.md](file:///d:/ys/docs/user_stories.md) | User stories across 7 epics with Fibonacci story points |
| [acceptance_criteria.md](file:///d:/ys/docs/acceptance_criteria.md) | Testable Gherkin (*Given-When-Then*) acceptance scenarios |
| [risk_register.md](file:///d:/ys/docs/risk_register.md) | 10 key technical, safety, operational risks and mitigation plans |
| [empathy_maps.md](file:///d:/ys/docs/empathy_maps.md) | Detailed stakeholder empathy maps (Donor, NGO, Volunteer, Admin) |
| [user_personas.md](file:///d:/ys/docs/user_personas.md) | In-depth user personas and archetypes (Ramesh, Priya, Sunita, Rahul, Vikram) |
| [user_journeys.md](file:///d:/ys/docs/user_journeys.md) | End-to-end journey maps with emotional curves and moments of truth |
| [problem_statements_hmw.md](file:///d:/ys/docs/problem_statements_hmw.md) | POV problem statements and 16 "How Might We" innovation challenges |
| [feature_ideation.md](file:///d:/ys/docs/feature_ideation.md) | Impact vs. Feasibility evaluation matrix and prioritized feature roadmap |
| [wireframes.md](file:///d:/ys/docs/wireframes.md) | Low-fidelity wireframe schematics and "Rider Mode" layouts |
| [usability_testing_scenarios.md](file:///d:/ys/docs/usability_testing_scenarios.md) | Usability testing protocols, metrics, and simulation scenarios |
| [design_system.md](file:///d:/ys/docs/design_system.md) | Premium design system, color tokens, typography, grid, light/dark themes |
| [components_specification.md](file:///d:/ys/docs/components_specification.md) | Reusable UI components: buttons, fields, cards, multi-modal status chips, modals |
| [screen_specifications.md](file:///d:/ys/docs/screen_specifications.md) | Complete specifications for all 27 required screens across 5 modules |
| [accessibility_localization_guidelines.md](file:///d:/ys/docs/accessibility_localization_guidelines.md) | WCAG 2.1 AA accessibility, touch targets, and English/Hindi/Marathi i18n |
| [system_architecture.md](file:///d:/ys/docs/system_architecture.md) | Clean Architecture layer specs, feature-first structure & sequence flows |
| [database_schema.md](file:///d:/ys/docs/database_schema.md) | Production PostgreSQL DDL across all 12 tables, custom ENUMs, check constraints |
| [database_security_rls.md](file:///d:/ys/docs/database_security_rls.md) | Supabase Row Level Security (RLS) policies & atomic concurrency stored procedures |
| [erd_diagram.md](file:///d:/ys/docs/erd_diagram.md) | Complete Mermaid Entity-Relationship Diagram and integrity rules |
| [architecture.md](file:///d:/ys/docs/architecture.md) | System architecture, ER diagrams, data flow |
| [design.md](file:///d:/ys/docs/design.md) | UI/UX guidelines, color system, typography, screen specifications |
| [phases.md](file:///d:/ys/docs/phases.md) | 12-phase development roadmap and delivery strategy |
| [progress.md](file:///d:/ys/docs/progress.md) | Real-time progress and milestone completion tracker |
| [decisions.md](file:///d:/ys/docs/decisions.md) | Architectural Decision Records (ADRs) |
| [known_issues.md](file:///d:/ys/docs/known_issues.md) | Active issues and technical debt register |
| [rules.md](file:///d:/ys/docs/rules.md) | Platform safety, privacy, and business policies |
| [memory.md](file:///d:/ys/docs/memory.md) | Unified project context and memory log |
| [ai_service_architecture.md](file:///d:/ys/docs/ai_service_architecture.md) | Decoupled Python FastAPI AI microservice architecture |
| [installation_guide.md](file:///d:/ys/docs/installation_guide.md) | Step-by-step installation instructions for mobile and servers |
| [deployment_guide.md](file:///d:/ys/docs/deployment_guide.md) | Production hardening, release builds, and pilot rollout |
| [environment_setup.md](file:///d:/ys/docs/environment_setup.md) | Environment configuration variables, secrets, and SDK prerequisites |
| [troubleshooting.md](file:///d:/ys/docs/troubleshooting.md) | Operational and developer issue diagnosis and resolutions |
| [user_manual.md](file:///d:/ys/docs/user_manual.md) | Complete operational handbook for Donors, NGOs, Volunteers, and Admins |
| [maintenance_policy.md](file:///d:/ys/docs/maintenance_policy.md) | Telemetry, disaster recovery, incident management, and feature lifecycle |
| [testing/](file:///d:/ys/docs/testing/) | Comprehensive test strategy, test cases, security, a11y, performance, and QA reports |

---

## 🚀 Development Roadmap

1. **Phase 1: Requirement Analysis** *(Completed)*
2. **Phase 2: Design Thinking & Empathy Mapping** *(Completed)*
3. **Phase 3: Premium UI/UX Design System** *(Completed)*
4. **Phase 4: System Architecture & Database Design** *(Completed)*
5. **Phase 5: Flutter Project Foundation Setup** *(Completed)*
6. **Phase 6: Authentication & Role Management** *(Completed)*
7. **Phase 7: Donor & NGO Modules** *(Completed)*
8. **Phase 8: Volunteer Module & Custody Handover** *(Completed)*
9. **Phase 9: Real-Time Notifications & Admin Module** *(Completed)*
10. **Phase 10: AI Integration Service (FastAPI)** *(Completed)*
11. **Phase 11: Testing & Quality Assurance (119 Tests)** *(Completed)*
12. **Phase 12: Deployment & Production Documentation** *(Completed)*

