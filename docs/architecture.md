# FoodBridge --- System Architecture

**Project:** FoodBridge: Real-Time Food and Cloth Donation &
Redistribution Platform\
**Version:** 1.0\
**Status:** Proposed architecture; validate deployment choices before
implementation

## 1. Architecture goals

The architecture must support four roles (donor, NGO, volunteer and
administrator), two donation categories (food and clothing), a traceable
donation lifecycle, realtime status updates, secure data access and
optional AI assistance.

The design favours a modular monolith for the first release: one primary
application backend and database, with a separately deployable AI
service only when needed. This avoids unnecessary microservice
complexity during a college project while preserving clear module
boundaries.

## 2. Recommended technology stack

  -----------------------------------------------------------------------
  Layer                   Recommended technology  Responsibility
  ----------------------- ----------------------- -----------------------
  Mobile frontend         Flutter / Dart          Android-first
                                                  application; iOS can
                                                  follow

  Admin web interface     Flutter Web or a        Verification and
                          separate web frontend   platform management

  Authentication          Supabase Auth           Sign-in, sessions and
                                                  identity

  Primary database        Supabase PostgreSQL     Users, donations,
                                                  requests, tasks and
                                                  audit data

  Realtime                Supabase Realtime       Live status and listing
                                                  updates

  File storage            Supabase Storage        Donation photos and
                                                  verification documents

  Server-side logic       PostgreSQL functions /  Trusted transitions and
                          Edge Functions          notification
                                                  orchestration

  AI service              Python + FastAPI        Matching,
                                                  classification
                                                  suggestions and
                                                  forecasting

  Maps                    A selected maps         Map display, geocoding
                          provider                and navigation

  Push notifications      Firebase Cloud          Device notifications
                          Messaging or an         
                          equivalent provider     

  Source control          Git + GitHub            Version control and
                                                  team collaboration
  -----------------------------------------------------------------------

Do not put privileged database keys, AI provider keys or other secrets
in the Flutter application. Use server-side secrets and least-privilege
access.

## 3. High-level architecture

``` mermaid
flowchart TB
    subgraph Clients
      D[Donor Flutter App]
      N[NGO Flutter App]
      V[Volunteer Flutter App]
      A[Admin Web Dashboard]
    end

    subgraph Platform["FoodBridge Platform"]
      AUTH[Supabase Auth]
      API[Trusted Server Logic / Edge Functions]
      DB[(PostgreSQL Database)]
      RT[Realtime Updates]
      STORE[Supabase Storage]
      NOTIFY[Push Notification Service]
    end

    subgraph AI["Optional AI Service"]
      FAST[Python FastAPI]
      MATCH[NGO Matching]
      CLASS[Image Category Suggestions]
      FORECAST[Demand Analytics]
      BOT[Help Chatbot]
    end

    MAPS[Maps Provider]

    D --> AUTH
    N --> AUTH
    V --> AUTH
    A --> AUTH
    D --> API
    N --> API
    V --> API
    A --> API
    API --> DB
    API --> STORE
    DB --> RT
    API --> NOTIFY
    API --> FAST
    FAST --> MATCH
    FAST --> CLASS
    FAST --> FORECAST
    FAST --> BOT
    D --> MAPS
    N --> MAPS
    V --> MAPS
```

## 4. Application modules

### 4.1 Identity and access module

-   Registration, login, logout and session refresh.
-   User profile and role.
-   NGO verification state.
-   Role and ownership checks on every protected operation.
-   Account suspension and deactivation.

A role stored in a user-editable profile must not be trusted as the only
security control. Role changes and privileged claims must be performed
by trusted server-side logic.

### 4.2 Donation management module

Responsible for creating and maintaining food and clothing listings.

Common fields: - Donor ID - Donation type - Title and description -
Quantity and unit - Image references - Pickup area/address
(restricted) - Available-from and collection-deadline timestamps -
Status - Created and updated timestamps

Food-specific fields: - Food category - Preparation/packing time where
relevant - Storage/handling information - Allergen or ingredient notes
where supplied - Collection deadline - Donor declaration

Clothing-specific fields: - Item category - Quantity - Size range where
relevant - Condition - Cleanliness/packing notes

### 4.3 NGO discovery and request module

-   Filter donations by type, service area, availability and quantity.
-   Display only information needed before a request.
-   Submit requests with requested quantity and notes.
-   Enforce quantity limits and prevent over-allocation.
-   Record request decisions and reasons.

### 4.4 Volunteer task module

-   Create a task after an allocation requires collection.
-   Assign a volunteer using a transaction or trusted server function.
-   Expose precise addresses only to authorised task participants.
-   Record pickup, transit and handover events.
-   Handle cancellation and reassignment safely.

### 4.5 Notification module

Events may include: - New donation in an NGO's service area. - NGO
request submitted. - Request accepted or rejected. - Volunteer
assignment. - Pickup deadline approaching. - Pickup confirmed. -
Delivery/handover confirmed. - Donation cancelled or expired.

Notifications are an aid, not the source of truth. The database status
remains authoritative.

### 4.6 Administration and audit module

-   NGO verification queue.
-   User and donation moderation.
-   Complaint and incident handling.
-   Audit log for sensitive actions.
-   Aggregate metrics and exportable reports.

## 5. Proposed database model

The following is a logical schema. Column types and constraints should
be refined in SQL migrations.

### `profiles`

-   `id` UUID, primary key and linked to auth user
-   `display_name`
-   `phone`
-   `role` (`donor`, `ngo`, `volunteer`, `admin`)
-   `account_status`
-   `created_at`, `updated_at`

### `donor_profiles`

-   `user_id` primary/foreign key
-   `donor_type`
-   `organisation_name` (nullable)
-   `default_pickup_area`

### `ngos`

-   `id` UUID
-   `owner_user_id`
-   `name`
-   `description`
-   `service_areas`
-   `capacity_notes`
-   `verification_status`
-   `verification_document_paths`
-   `created_at`, `updated_at`

### `volunteer_profiles`

-   `user_id`
-   `availability`
-   `service_area`
-   `verification_status`
-   `active_task_limit`

### `donations`

-   `id` UUID
-   `donor_id`
-   `donation_type` (`food`, `clothing`)
-   `title`, `description`
-   `quantity`, `unit`
-   `photo_paths`
-   `pickup_location_private`
-   `pickup_area_public`
-   `available_from`, `collection_deadline`
-   `status`
-   `created_at`, `updated_at`

### `food_details`

-   `donation_id` primary/foreign key
-   `food_category`
-   `prepared_or_packed_at`
-   `storage_instructions`
-   `allergen_notes`
-   `donor_safety_declaration`

### `clothing_details`

-   `donation_id` primary/foreign key
-   `item_category`
-   `size_range`
-   `condition`
-   `cleanliness_declaration`

### `donation_requests`

-   `id`
-   `donation_id`
-   `ngo_id`
-   `requested_quantity`
-   `message`
-   `status`
-   `decision_note`
-   `created_at`, `updated_at`

### `assignments`

-   `id`
-   `donation_request_id`
-   `volunteer_id`
-   `pickup_window`
-   `status`
-   `pickup_confirmed_at`
-   `handover_confirmed_at`
-   `created_at`, `updated_at`

### `distribution_records`

-   `id`
-   `donation_id`
-   `ngo_id`
-   `quantity_received`
-   `quantity_distributed`
-   `unit`
-   `distribution_date`
-   `confirmation_notes`

### `notifications`

-   `id`
-   `recipient_user_id`
-   `event_type`
-   `payload`
-   `read_at`
-   `created_at`

### `audit_logs`

-   `id`
-   `actor_user_id`
-   `entity_type`
-   `entity_id`
-   `action`
-   `old_value` / `new_value` (carefully filtered)
-   `created_at`

### Relationships

``` mermaid
erDiagram
  PROFILES ||--o| DONOR_PROFILES : has
  PROFILES ||--o| VOLUNTEER_PROFILES : has
  PROFILES ||--o{ DONATIONS : creates
  PROFILES ||--o{ NGOS : manages
  DONATIONS ||--o| FOOD_DETAILS : has
  DONATIONS ||--o| CLOTHING_DETAILS : has
  DONATIONS ||--o{ DONATION_REQUESTS : receives
  NGOS ||--o{ DONATION_REQUESTS : submits
  DONATION_REQUESTS ||--o{ ASSIGNMENTS : creates
  PROFILES ||--o{ ASSIGNMENTS : volunteers
  DONATIONS ||--o{ DISTRIBUTION_RECORDS : records
```

## 6. Donation workflow and state machine

``` mermaid
stateDiagram-v2
  [*] --> draft
  draft --> available
  available --> requested
  requested --> accepted
  requested --> available: all requests rejected/withdrawn
  accepted --> assigned_for_pickup
  accepted --> delivered_to_ngo: NGO collects directly
  assigned_for_pickup --> picked_up
  picked_up --> delivered_to_ngo
  delivered_to_ngo --> distributed
  distributed --> completed
  available --> cancelled
  requested --> cancelled
  accepted --> cancelled: authorised cancellation
  available --> expired: deadline passed
  expired --> [*]
  cancelled --> [*]
  completed --> [*]
```

Implement transitions in trusted server-side code or database functions.
Use transactions and constraints to prevent two NGOs from claiming the
same remaining quantity. Keep a status-event history rather than
overwriting the only record of what happened.

## 7. Realtime and event flow

1.  A donor creates a donation through a validated operation.
2.  The database commits the donation and its initial status.
3.  Realtime subscribers receive permitted changes.
4.  A server-side event handler identifies relevant recipients.
5.  Push notifications are sent where enabled.
6.  The recipient opens the app and fetches the authoritative current
    record.

Use idempotency keys or equivalent safeguards for retryable operations
so a poor network connection does not create duplicate donations or
requests.

## 8. AI service architecture

The AI service is optional and must not block core donation workflows.

### NGO matching

Inputs: donation type, public service area, quantity, collection
deadline, NGO service areas and declared capacity.

Output: ranked recommendations with simple reasons, such as "serves this
area" or "capacity matches quantity". The NGO or donor makes the actual
decision.

### Image category suggestions

A model may suggest a broad category from an image. The user confirms or
corrects the suggestion. Do not infer food freshness, safety, allergens
or suitability from the image.

### Demand analytics

Use aggregated historical requests and distribution records to identify
patterns. Display uncertainty and avoid presenting a forecast as a
guarantee.

### Chatbot

Use approved product documentation and help content. It should not
provide medical, legal or food-safety certification.

## 9. Security, privacy and data protection

-   Enable Row Level Security (RLS) on all user-accessible tables.
-   Create policies for role, ownership, NGO verification and assignment
    participation.
-   Keep exact addresses private until a legitimate request or task
    requires them.
-   Do not expose beneficiary names, phone numbers or sensitive
    circumstances in public listings.
-   Restrict verification document access to authorised reviewers.
-   Validate uploads, file size and content type.
-   Rate-limit sensitive actions and protect against spam.
-   Keep service-role keys and provider secrets on the server only.
-   Record administrative and status-changing actions.
-   Define retention and deletion rules for personal data.
-   Test policies using accounts from every role, including unauthorised
    users.

## 10. Deployment environments

-   **Development:** local Flutter app, Supabase development project and
    test data.
-   **Staging:** production-like configuration with test users and test
    notifications.
-   **Production/pilot:** restricted launch with verified organisations,
    backups, monitoring and incident contacts.

Use separate environment variables and secrets for each environment. Do
not use real beneficiary data in development.

## 11. Architecture decisions to confirm

-   Whether the first release includes a web admin panel.
-   Exact map and push-notification providers.
-   Whether an NGO can collect directly without a volunteer.
-   Whether a donation can be split among multiple NGOs.
-   Data retention and verification document policy.
-   AI model/provider and hosting arrangement.
-   Pilot scale and expected concurrent users.
