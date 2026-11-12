# FoodBridge --- Project Memory and Decision Log

**Purpose:** A compact, maintained source of truth for the project's
agreed context, decisions, terminology and current progress. Update this
file whenever the team makes a meaningful decision.

## 1. Project identity

-   **Project name:** FoodBridge
-   **Full title:** FoodBridge: Real-Time Food and Cloth Donation &
    Redistribution Platform
-   **Project type:** Major / capstone software project
-   **Core domain:** Food donation, clothing donation and community
    resource redistribution
-   **Primary objective:** Reduce avoidable food wastage and improve
    access to food and essential clothing by connecting donors, NGOs and
    volunteers.

## 2. Problem being addressed

Surplus food and usable clothing may be available from restaurants,
hotels, caterers, events, retailers and individuals, while NGOs and
communities may need those resources. Coordination gaps make it
difficult to discover donations, allocate them, arrange collection and
verify distribution.

FoodBridge provides a shared workflow for: 1. Donors to publish
donations. 2. Verified NGOs to discover and request resources. 3.
Volunteers to coordinate pickup and delivery. 4. NGOs to confirm receipt
and distribution. 5. Administrators to verify users and monitor platform
activity.

## 3. Stakeholders and roles

  -----------------------------------------------------------------------
  Role                                Main responsibility
  ----------------------------------- -----------------------------------
  Donor                               Publish food or clothing donations

  NGO                                 Discover, request, receive and
                                      distribute donations

  Volunteer                           Accept and complete pickup/delivery
                                      tasks

  Admin                               Verify organisations, moderate and
                                      monitor

  Beneficiary                         Receive resources, generally
                                      through an NGO in the first release
  -----------------------------------------------------------------------

Beneficiaries should not need accounts in the first MVP unless a clear
operational requirement emerges.

## 4. Product vision and tagline

**Vision:** Connect donors, NGOs and volunteers through one transparent,
real-time platform so usable resources can reach people who need them
safely and efficiently.

**Suggested tagline:** "Share More. Waste Less. Bridge the Need."

## 5. Recommended initial technology

Current recommendation, pending explicit confirmation: - Flutter and
Dart for mobile. - Supabase Auth for authentication. - PostgreSQL for
structured data. - Supabase Realtime for status updates. - Supabase
Storage for images and documents. - Python and FastAPI for optional AI
services. - Maps provider for location display. - Push notification
provider for alerts. - Git and GitHub for collaboration.

Do not treat this recommendation as a confirmed final choice until the
project owner approves it.

## 6. Main functional modules

1.  Authentication and role-based profiles.
2.  Food donation management.
3.  Clothing donation management.
4.  NGO registration and verification.
5.  Donation discovery and request management.
6.  Volunteer assignment and task tracking.
7.  Realtime status updates and notifications.
8.  Admin moderation and audit logs.
9.  Impact analytics.
10. Optional AI-assisted matching, category suggestions, demand
    analytics and help chatbot.

## 7. Core donation lifecycle

`draft → available → requested → accepted → assigned_for_pickup → picked_up → delivered_to_ngo → distributed → completed`

Possible alternative: an NGO may collect directly after acceptance.
Cancellation, expiry and rejection paths must also be supported.

The database must prevent over-allocation and duplicate active
assignments.

## 8. AI direction

AI is intended to support---not replace---human decisions.

Potential features: - Recommend suitable NGOs based on donation type,
service area, capacity, quantity and urgency. - Suggest broad donation
categories from images, subject to user confirmation. - Analyse
aggregate historical demand. - Answer common product-use questions using
approved help content.

**Non-negotiable limitation:** AI must not certify food safety,
freshness, contamination status or suitability for consumption from a
photograph. Humans and partner organisations remain responsible for
verification and operational decisions.

## 9. Safety, privacy and trust principles

-   Verify NGOs before enabling restricted workflows.
-   Apply role-based access and database Row Level Security.
-   Keep precise addresses private until needed by authorised
    participants.
-   Protect beneficiary identity and sensitive information.
-   Collect only data needed for the service.
-   Keep audit history for important status changes.
-   Provide reporting and incident-handling paths.
-   Follow applicable local food-safety and privacy requirements before
    a live pilot.
-   Do not imply that FoodBridge itself certifies food or guarantees
    safety.

## 10. MVP definition

The first usable version should support: - User registration and sign-in
for donor, NGO and volunteer roles. - NGO verification by an
administrator. - Food and clothing donation creation. - Donation
discovery by verified NGOs. - NGO request and allocation. - Volunteer
pickup and handover tracking. - NGO receipt and distribution
confirmation. - Status history and basic notifications. - Tested role
permissions and privacy controls.

AI, complex route optimisation, payment features and large-scale
expansion are not prerequisites for the first MVP.

## 11. Current project decisions

  -----------------------------------------------------------------------
  Topic                   Current position        Decision state
  ----------------------- ----------------------- -----------------------
  Product name            FoodBridge              Proposed by project
                                                  owner

  Food + clothing         Both included           Core requirement

  Stakeholders            Donors, NGOs,           Core requirement
                          volunteers, admin       

  Real-time coordination  Required                Core requirement

  Flutter + Supabase      Recommended stack       Awaiting confirmation

  Web admin panel         Recommended             Awaiting confirmation

  AI features             Matching, category      Optional / phased
                          suggestions, demand     
                          analytics, chatbot      

  Pilot location          Not specified           Open

  Maps provider           Not selected            Open

  Push notification       Not selected            Open
  provider                                        

  NGO verification policy To be defined with      Open
                          partners                

  Food acceptance policy  Must follow local       Open
                          qualified guidance      
  -----------------------------------------------------------------------

## 12. Open questions to resolve

1.  Is the first deliverable an Android app only, or Android plus a web
    admin dashboard?
2.  Is Flutter + Supabase the approved technology stack?
3.  Which city or service area will be used for the pilot?
4.  Will donors approve NGO requests, or can verified NGOs claim
    donations automatically?
5.  Can a single donation be split among multiple NGOs?
6.  Can an NGO collect directly, or must a volunteer be assigned?
7.  What verification documents will NGOs provide?
8.  What food categories, handling fields and collection deadlines are
    required?
9.  What clothing condition standards will participating NGOs accept?
10. Which languages are required for the first release?

## 13. Progress tracker

Update the checkboxes as work is completed.

-   [x] Requirements approved (Phase 1 completed: requirement_analysis, functional_requirements, non_functional_requirements, user_roles, user_stories, acceptance_criteria, risk_register)
-   [x] User journeys and wireframes approved (Phase 2 completed: empathy_maps, user_personas, user_journeys, problem_statements_hmw, feature_ideation, wireframes, usability_testing_scenarios)
-   [x] Architecture approved (Phase 4 completed: system_architecture, database_schema, database_security_rls, erd_diagram, ADR-006)
-   [x] Flutter Foundation & Design System implemented (Phase 5 completed: theme, components, responsive/a11y helpers, assets)
-   [x] Supabase schema and migrations created (`20261112000000_create_foodbridge_schema.sql`)
-   [x] Authentication and role permissions completed (Phase 6 completed: AuthProvider, RouteGuard, SessionStorageService, Login/Register/Forgot)
-   [x] Donor workflows completed (Phase 7: create donation, edit/withdraw listing, dietary filters, my listings)
-   [x] NGO workflows completed (Phase 7: claims manager, partial & full quantity claim allocation, verification screen)
-   [x] Volunteer workflows completed (Phase 8: rider GPS map navigation, active task dispatch, OTP pickup & handover confirmation, 2-task limit)
-   [x] AI features evaluated and integrated where useful (AIService: smart route matching, safe handling advisories with Rule 14 disclaimer, community assistant)
-   [x] Admin workflows completed (Phase 9: moderation, verification approvals, platform analytics, realtime notification deduplication, audit logs)
-   [ ] Security and accessibility tests completed
-   [ ] Pilot partners confirmed
-   [ ] Controlled pilot completed
-   [ ] Deployment and documentation completed

## 14. Change log

  -----------------------------------------------------------------------
  Version                             Change
  ----------------------------------- -----------------------------------
  1.0                                 Initial project memory created from
                                      the FoodBridge concept and proposed
                                      solution

  1.1                                 Phase 1 Requirement Analysis completed.
                                      Generated comprehensive PRD extensions:
                                      requirement_analysis.md, functional_requirements.md,
                                      non_functional_requirements.md, user_roles.md,
                                      user_stories.md, acceptance_criteria.md,
                                      risk_register.md, decisions.md, progress.md,
                                      known_issues.md, and README.md.

  1.2                                 Phase 2 Design Thinking completed.
                                      Authored empathy_maps.md, user_personas.md,
                                      user_journeys.md, problem_statements_hmw.md,
                                      feature_ideation.md, wireframes.md, and
                                      usability_testing_scenarios.md.

  1.3                                 Phase 3 Premium UI/UX Design completed.
                                      Authored design_system.md,
                                      components_specification.md,
                                      screen_specifications.md (27 screens),
                                      accessibility_localization_guidelines.md,
                                      and recorded ADR-005.

  1.4                                 Phase 4 System Architecture & Database completed.
                                      Authored system_architecture.md,
                                      database_schema.md (12 tables DDL),
                                      database_security_rls.md (RLS & atomic functions),
                                      erd_diagram.md (Mermaid ERD),
                                      and recorded ADR-006.

  1.5                                 Phase 5 Flutter Foundation & Theme completed.
                                      Configured pubspec.yaml, analysis_options.yaml,
                                      AppTheme, AppColors, FBButton, FBTextField, FBCard,
                                      ResponsiveHelper, AccessibilityHelper.

  1.6                                 Phase 6 Authentication & Role Management finalized.
                                      Implemented full multi-role onboarding forms for Donor,
                                      NGO (with mandatory 12A/80G/Darpan verification document
                                      and pending status), and Volunteer (schedule & vehicle mode).
                                      Secured admin provisioning (public self-registration blocked).
                                      Added password visibility toggle, min 8 char validation,
                                      SessionStorageService persistent session restoration,
                                      and complete password reset flow (ForgotPasswordScreen &
                                      ResetPasswordScreen) with 31 passing tests.

  1.7                                 Phase 7 Donor & NGO Modules finalized.
                                      Implemented dedicated multi-step DonateFoodScreen (FSSAI
                                      pledge, temperature storage, allergens) and DonateClothesScreen
                                      (condition grade, size group, cleanliness declaration).
                                      Created DonationPreviewScreen with publish/draft actions.
                                      Built DistributionRecordsScreen for privacy-preserving
                                      aggregate beneficiary logging (headcount & community, zero PII).
                                      Enforced mandatory 80G/Darpan verification check on NGO claims,
                                      privacy-masked approximate location on discovery feeds,
                                      full 12-state lifecycle transitions, and 39 passing tests.

  1.8                                 Phase 8 Volunteer Rider Module & AI Services finalized.
                                      Implemented VolunteerTaskDetailSheet for interactive review &
                                      task acceptance with authorized pickup unlock. Built AIService
                                      providing smart route compatibility scoring (proximity & urgency),
                                      safe handling logistics advisories for hot, chilled, ambient & clothing
                                      (with mandatory Rule 14 disclaimer that AI never certifies food safety),
                                      and Community Assistant FAQ resolution. Enhanced VolunteerMissionScreen
                                      with turn-by-turn route navigation, Donor pickup & NGO delivery dual-OTP
                                      verification, structured issue reporting & task release, optional proof
                                      of handover, and offline warning states with 49 passing tests.

  1.9                                 Phase 9 Realtime System & Administration finalized.
                                      Implemented comprehensive Supabase Realtime event architecture
                                      with 10 distinct event types (new donation, NGO claim, accepted,
                                      rejected, volunteer assigned, pickup confirmed, delivery confirmed,
                                      donation completed, donation cancelled, collection deadline warning).
                                      Built NotificationProvider with deduplication fingerprints to prevent
                                      alert spam and customizable user preferences (push, email, deadline,
                                      nearby rescues, status changes). Created full 5-tab AdminDashboardScreen
                                      with live overview, NGO verification queue with document preview
                                      and approval/rejection audit trail, User Management with account
                                      suspension & reactivation, Community Complaint management with
                                      investigation & resolution notes, tamper-evident Audit Logging,
                                      and dynamic database-backed analytics (zero fabricated metrics).
                                      62 tests passing with zero errors and zero warnings.
  -----------------------------------------------------------------------

**Maintenance rule:** When a decision changes, update the relevant
section and add a dated entry to this change log. Do not silently treat
a recommendation or assumption as a confirmed decision.
