# FoodBridge — Acceptance Criteria Specification (Gherkin Scenarios)

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 1 — Requirement Analysis  
**Status:** Completed  
**Deliverable Location:** `docs/analysis/acceptance_criteria.md`  

---

## 1. Overview & Testable Scenarios

This document specifies the formal testable acceptance criteria for FoodBridge using standard **Gherkin syntax** (`Given`, `When`, `Then`, `And`), directly mapping user stories to QA test cases.

---

## 2. Authentication, Roles & Verification Scenarios

### AC-AUTH-01: Multi-Role Registration & Prevention of Public Admin Signup
```gherkin
Scenario: Successful registration as a Donor
  Given an unauthenticated visitor is on the registration screen
  When they enter a valid email "donor@example.com" and password "P@ssw0rd123"
  And they select the role "donor"
  And they submit the form
  Then a user record is created in Supabase Auth
  And a profile record is created in "profiles" with role="donor"
  And a specialized profile is created in "donor_profiles"
  And the user is redirected to the Donor Home Dashboard.

Scenario: Attempted direct signup as Administrator
  Given an unauthenticated visitor attempts registration via API or app
  When the payload requests role="admin"
  Then the database RLS policy or registration trigger rejects the mutation with 403 Forbidden
  And no administrator profile is created.
```

### AC-AUTH-02: NGO Verification Gating
```gherkin
Scenario: Unverified NGO cannot request donations
  Given an NGO user has registered and their status is "pending_review"
  When they navigate to the donation discovery feed
  Then they can view available donation cards with approximate locality
  But the "Request Donation" button is disabled with an alert "Verification Required"
  And any direct mutation to insert into "donation_requests" is blocked by RLS.

Scenario: Admin verifies an NGO
  Given an administrator is logged into the Admin Console
  And an applicant NGO has submitted certificate "cert_80g.pdf"
  When the administrator reviews the document and clicks "Approve Verification"
  Then the NGO's verification_status is updated to "verified" in "ngos" table
  And an entry is logged in "audit_logs" capturing the admin's actor ID
  And the NGO representative receives an in-app notification "Your organization is verified!"
  And the NGO can now submit donation requests.
```

---

## 3. Donation Creation & Privacy Scenarios

### AC-DON-01: Food Donation Creation with Expiry & Safety Declaration
```gherkin
Scenario: Donor successfully publishes a surplus food donation
  Given an authenticated donor is on the "Donate Food" screen
  When they enter title "35 kg Surplus Banquet Curries & Rice"
  And select category "cooked_meals"
  And specify quantity 35 and unit "kg"
  And enter prepared time "Today, 20:30"
  And select storage requirement "hot_holding"
  And set collection deadline "Today, 23:45" (at least 30 minutes in future)
  And declare allergen notes "Contains Dairy and Nuts"
  And provide approximate locality "Andheri West, Zone 2"
  And provide private door address "Service Gate 3, Link Road" and phone "9876543210"
  And tick the mandatory declaration "I certify this food was prepared hygienically"
  And submit the listing
  Then the donation is inserted into "donations" with status="available"
  And food details are persisted in "food_details"
  And the listing appears in the public discovery feed with exact address hidden
  And a real-time event "donation:new" is broadcast.

Scenario: Donor attempts to post food with an invalid collection deadline
  Given a donor is filling the "Donate Food" form
  When they enter a collection deadline that is less than 30 minutes from current time
  Then client-side validation displays an error "Collection deadline must be at least 30 minutes in the future"
  And form submission remains disabled.
```

### AC-DON-02: Clothing Donation Creation with Condition Standards
```gherkin
Scenario: Donor posts clean wearable clothing
  Given an authenticated donor is on the "Donate Clothes" screen
  When they select category "winterwear_blankets"
  And select condition "gently_used_like_new"
  And specify quantity 15 and unit "pieces"
  And upload 2 photographs showing the items
  And tick "I confirm all items are clean, washed, and dry"
  And submit the listing
  Then the donation is created with status="available"
  And clothing metadata is persisted in "clothing_details".
```

### AC-DON-03: Two-Tier Location Privacy Protection
```gherkin
Scenario: Public feed and unassigned users see only approximate locality
  Given an active donation exists with:
    pickup_area_public = "Koramangala, 5th Block"
    pickup_location_private = "House #14, 8th Main Road, Link Lane"
  When an NGO or unassigned volunteer views the donation details
  Then the app displays "Pickup Area: Koramangala, 5th Block"
  And the exact door address and donor phone number are not returned in the API response
  And the UI displays "Exact door address revealed upon task assignment".
```

---

## 4. NGO Discovery, Claims & Concurrency Scenarios

### AC-NGO-02: Atomic Quantity Reservation & Race Condition Prevention
```gherkin
Scenario: Multiple NGOs request remaining quantity simultaneously
  Given an active food donation exists with available_quantity = 30 "kg" and status="available"
  When NGO "A" and NGO "B" simultaneously submit claim requests for 30 "kg"
  Then the database transaction locks the donation row using "SELECT ... FOR UPDATE"
  And NGO "A"'s request is successfully inserted with status="pending"
  And the remaining available_quantity becomes 0
  And the donation status transitions to "requested"
  And NGO "B"'s transaction fails gracefully with message "Requested quantity is no longer available"
  And no duplicate allocation occurs.
```

### AC-NGO-04: Physical Inspection & Right of Refusal at Handover
```gherkin
Scenario: NGO rejects compromised food at physical delivery
  Given an assignment arrives at the NGO shelter with status "delivered_to_ngo"
  When the NGO staff member inspects the food and detects spoilage or tepid temperature
  And the NGO taps "Reject Delivery"
  And selects reason "food_safety_failure" with notes "Food was cold and sour"
  Then the donation status transitions to "rejected"
  And an incident report is generated for administrator review
  And the items are quarantined for safe disposal without penalizing the NGO.
```

---

## 5. Volunteer Task Coordination Scenarios

### AC-VOL-01: Atomic Single-Volunteer Task Assignment Lock
```gherkin
Scenario: Volunteer accepts an open dispatch task
  Given an assignment exists in "assignments" with status="open"
  When Volunteer "V1" views the task and taps "Accept Task"
  Then the database sets volunteer_id="V1" and status="assigned" conditionally where volunteer_id IS NULL
  And the task card transitions to "My Active Task"
  And if Volunteer "V2" taps "Accept Task" at the same instant, V2 receives message "This task has already been claimed"
  And V2's active assignments count remains unchanged.
```

### AC-VOL-02: Private Address Disclosure Post-Assignment
```gherkin
Scenario: Assigned volunteer unlocks exact pickup address
  Given Volunteer "V1" is assigned to task "T-101"
  When Volunteer "V1" opens the task details screen
  Then the private address "House #14, 8th Main Road, Link Lane" and donor phone "9876543210" are decrypted and displayed
  And one-touch actions "Call Donor" and "Open Maps" become active.
```

### AC-VOL-04: Emergency Task Surrender
```gherkin
Scenario: Volunteer vehicle breakdown during task
  Given Volunteer "V1" has accepted task "T-101" but encounters a flat tire before pickup
  When they tap "Report Issue / Emergency Surrender"
  And confirm "Surrender Task for Immediate Re-dispatch"
  Then the assignment status reverts to "open" and volunteer_id is reset to NULL
  And nearby active volunteers receive an urgent re-dispatch alert
  And Volunteer "V1"'s active task count is decremented without penalty.
```

---

## 6. Distribution Recording Scenarios

### AC-DIST-02: NGO Distribution Record Logging Without PII
```gherkin
Scenario: NGO records distribution completion
  Given a donation has status="delivered_to_ngo"
  When the NGO staff member opens the distribution form
  And enters quantity_distributed = 35 "kg"
  And enters summary "90 hot meals served at Shelter Hall to local residents"
  And leaves individual recipient names blank (prohibited by system)
  And submits the record
  Then a new record is created in "distribution_records"
  And the donation status transitions to "completed"
  And the donor receives an Impact Summary receipt.
```

### AC-SYS-01: Automated Donation Expiry
```gherkin
Scenario: Food donation passes collection deadline without acceptance
  Given an active food donation with collection_deadline="14:00"
  When system clock reaches "14:01" and status is still "available" or "requested" (unconfirmed)
  Then the automated background worker or DB cron updates status="expired"
  And the item is removed from the active NGO discovery feed
  And the donor receives an alert "Your food donation expired before collection could be arranged".
```

