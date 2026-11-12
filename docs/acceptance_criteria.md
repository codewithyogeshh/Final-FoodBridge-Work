# FoodBridge — Acceptance Criteria Specification (Gherkin Scenarios)

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 1 — Requirement Analysis  
**Status:** Completed  

---

## 1. Overview

This document specifies the formal testable acceptance criteria for FoodBridge using the industry-standard **Gherkin syntax** (`Given`, `When`, `Then`, `And`). These scenarios form the foundational test matrix for automated widget tests, integration tests, and QA verification in later phases.

---

## 2. Authentication, Roles & Verification

### AC-AUTH-01: Multi-Role Registration & Prevention of Public Admin Signup
```gherkin
Scenario: Successful registration as a Donor
  Given an unauthenticated visitor is on the registration screen
  When they enter a valid email "donor@example.com" and a secure password "P@ssw0rd123"
  And they select the role "donor"
  And they submit the form
  Then a new user record is created in Supabase Auth
  And a linked record is created in "profiles" with role="donor"
  And a linked record is created in "donor_profiles"
  And the user is redirected to the Donor Home Dashboard.

Scenario: Attempted direct signup as Administrator
  Given an unauthenticated visitor is attempting to register via the public API or app
  When the payload requests role="admin"
  Then the database RLS policy or registration trigger rejects the request with code 403 Forbidden
  And no administrator profile is created.
```

### AC-AUTH-02: NGO Verification Gating
```gherkin
Scenario: Unverified NGO cannot request donations
  Given an NGO user has registered and their status is "pending_verification"
  When they navigate to the donation discovery feed
  Then they can view available donation cards with approximate locality
  But the "Request Donation" button is disabled with an alert "Verification Required"
  And any direct mutation to insert into "donation_requests" is blocked by RLS.

Scenario: Admin verifies an NGO
  Given an administrator is logged into the Admin Console
  And an NGO "Helping Hands" has submitted registration certificate "cert_80g.pdf"
  When the administrator reviews the document and clicks "Approve Verification"
  Then the NGO's "verification_status" is updated to "verified" in "ngos" table
  And an audit log entry is inserted into "audit_logs" capturing the admin's actor ID
  And the NGO representative receives an in-app notification "Your organization is verified!"
  And the NGO can now submit donation requests.
```

---

## 3. Donation Creation & Management

### AC-DON-01: Food Donation Creation with Expiry & Safety Declaration
```gherkin
Scenario: Donor successfully publishes a surplus food donation
  Given an authenticated donor is on the "Donate Food" screen
  When they enter title "50 Surplus Packed Biryani Boxes"
  And select category "cooked_meals"
  And specify quantity 50 and unit "boxes"
  And enter prepared time "Today, 18:00"
  And select storage requirement "hot_holding"
  And set collection deadline "Today, 22:30" (4.5 hours from now)
  And declare allergen notes "Contains Dairy and Nuts"
  And provide approximate locality "Andheri West, Zone 2"
  And provide private address "Flat 402, Sunshine Apts, Link Road" and phone "9876543210"
  And tick the mandatory declaration "I certify this food was prepared hygienically"
  And submit the listing
  Then the donation is inserted into "donations" with status="available"
  And food details are saved in "food_details"
  And the listing appears in the public discovery feed with exact address hidden
  And a real-time event "donation:created" is broadcast.

Scenario: Donor attempts to post food with an expired collection deadline
  Given a donor is filling the "Donate Food" form
  When they enter a collection deadline that is in the past or less than 30 minutes from current time
  Then client-side validation displays an error "Collection deadline must be at least 30 minutes in the future"
  And form submission is disabled.
```

### AC-DON-02: Clothing Donation Creation with Condition Standards
```gherkin
Scenario: Donor posts clean winter clothing
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
    pickup_location_private = "House #14, 8th Main Road, Behind Cafe Coffee Day"
  When an NGO or unassigned volunteer views the donation details
  Then the app displays "Pickup Area: Koramangala, 5th Block"
  And the exact street address and donor phone number are not returned in the API response
  And the UI displays "Exact address will be revealed upon task assignment".
```

---

## 4. NGO Discovery, Claims & Concurrency Control

### AC-NGO-01: Atomic Quantity Allocation & Race Condition Prevention
```gherkin
Scenario: Multiple NGOs request remaining quantity simultaneously
  Given an active food donation exists with quantity = 20 "boxes" and status="available"
  When NGO "A" and NGO "B" simultaneously submit claim requests for 20 "boxes"
  Then the database transaction locks the donation row using "SELECT ... FOR UPDATE"
  And NGO "A"'s request is successfully inserted with status="pending"
  And the remaining available quantity becomes 0
  And the donation status transitions to "requested"
  And NGO "B"'s transaction fails gracefully with error "Requested quantity is no longer available"
  And no duplicate allocation occurs.
```

### AC-NGO-02: Allocation Acceptance & Dispatch Task Creation
```gherkin
Scenario: Donor accepts NGO request requiring volunteer delivery
  Given a donation has an active request from NGO "Food For All"
  And the request specifies "Requires Volunteer Delivery"
  When the donor clicks "Accept Request"
  Then the donation status transitions to "accepted"
  And the request status is marked "approved"
  And a new record is created in "assignments" with status="open"
  And volunteers in that service zone receive a real-time dispatch alert.
```

---

## 5. Volunteer Task Coordination & Handover

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

### AC-VOL-02: Private Address Disclosure After Assignment
```gherkin
Scenario: Assigned volunteer unlocks exact pickup address
  Given Volunteer "V1" is assigned to task "T-101"
  When Volunteer "V1" opens the task details screen
  Then the private address "House #14, 8th Main Road, Behind Cafe Coffee Day" and donor phone "9876543210" are decrypted and displayed
  And one-touch actions "Call Donor" and "Navigate" are active.
```

### AC-VOL-03: Pickup & Handover Sequence
```gherkin
Scenario: Volunteer confirms physical collection
  Given Volunteer "V1" has arrived at the donor location
  When they tap "Confirm Pickup"
  Then the assignment status transitions to "picked_up"
  And the linked donation status transitions to "picked_up"
  And the donor and recipient NGO receive notifications "Items picked up by volunteer".

Scenario: Volunteer confirms delivery to NGO
  Given Volunteer "V1" arrives at the NGO facility
  When they tap "Confirm Handover"
  Then the assignment status transitions to "delivered_to_ngo"
  And the linked donation status transitions to "delivered_to_ngo"
  And the volunteer's active task counter is decremented.
```

---

## 6. Distribution Recording, Rejection & Expiry

### AC-DIST-01: NGO Physical Quality Rejection
```gherkin
Scenario: NGO rejects spoiled food at physical delivery
  Given an assignment arrives at the NGO with status "delivered_to_ngo"
  When the NGO inspector examines the food and identifies spoilage or off-odour
  And the NGO clicks "Reject Delivery"
  And selects reason "food_safety_failure" with notes "Food sour and cold"
  Then the donation status transitions to "rejected"
  And an incident report is automatically generated for administrator review
  And the items are marked for safe disposal.
```

### AC-DIST-02: NGO Distribution Record Logging Without PII
```gherkin
Scenario: NGO records distribution completion
  Given a donation has status="delivered_to_ngo"
  When the NGO staff member opens the distribution form
  And enters quantity_distributed = 50 "boxes"
  And enters summary "50 meals distributed at Shelter Hall to local residents"
  And leaves individual recipient names blank (prohibited by system)
  And submits the record
  Then a new record is created in "distribution_records"
  And the donation status transitions to "completed"
  And the donor receives an Impact Summary card.
```

### AC-SYS-01: Automated Donation Expiry
```gherkin
Scenario: Food donation passes collection deadline without acceptance
  Given an active food donation with collection_deadline="14:00"
  When system clock reaches "14:01" and status is still "available" or "requested" (unconfirmed)
  Then the automated expiry worker or DB cron updates status="expired"
  And the item is removed from the active NGO discovery feed
  And the donor receives an alert "Your food donation expired before collection could be arranged".
```

