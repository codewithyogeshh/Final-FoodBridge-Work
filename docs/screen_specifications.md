# FoodBridge — Complete Screen Specifications Catalog

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 3 — Premium UI/UX Design System  
**Status:** Completed  

---

## 1. Overview & Architecture of Screens

The FoodBridge user interface comprises **27 distinct production screens** categorized into 5 logical clusters:
1. **Shared Foundation Screens (7 screens):** Authentication, profile, onboarding, and notification center.
2. **Donor Module Screens (6 screens):** Surplus food and clothing creation, tracking, and impact receipts.
3. **NGO Module Screens (6 screens):** Discovery feed, claim modals, direct collection tracking, and distribution logging.
4. **Volunteer Module Screens (6 screens):** Available task feeds ("Rider Mode"), address revelation, pickup confirmation, and handover.
5. **Admin Console Screens (6 screens):** NGO verification queue, global donation/task monitoring, moderation, and analytics.

---

## 2. Shared Foundation Screens

### SCR-SH-01: Splash Screen (`/splash`)
- **Purpose:** Brand recognition, session restoration, and initialization.
- **Visuals:** Warm Cream background (`#FFF8ED`), centered animated FoodBridge Logo with expanding green leaf/bridge motif (`#218C5A`), tagline *"Share More. Waste Less. Bridge the Need."*, circular progress indicator.
- **Interactions:** Checks local auth token in `FlutterSecureStorage`. If valid token exists, queries profile role and navigates to the respective role dashboard. If no session, redirects to `/onboarding`.
- **Localization Keys:** `splash_tagline`.

### SCR-SH-02: Onboarding & Role Selection (`/onboarding`)
- **Purpose:** Orient new users and direct them into role-specific onboarding.
- **Visuals:** Carousel of 3 illustrated slides explaining Food Rescue, Clothing Redistribution, and Community Impact. Role selection cards: "I want to Donate", "We are an NGO/Shelter", "I want to Volunteer". Language switcher in top right corner.
- **Accessibility:** Carousel slides announced by screen reader; touch targets $56\text{ dp}$ height.
- **Localization Keys:** `onboarding_title_1..3`, `role_donor_title`, `role_ngo_title`, `role_volunteer_title`.

### SCR-SH-03: Login Screen (`/login`)
- **Purpose:** Secure authentication for returning users across all roles.
- **Components:** `FBTextField` for Email, `FBTextField` with password visibility toggle, "Forgot Password?" link, `FBPrimaryButton` ("Sign In"), "Don't have an account? Register" link.
- **States:** Default, In-flight loading (button shows spinner), Error banner (invalid credentials).
- **Localization Keys:** `login_header`, `email_label`, `password_label`, `sign_in_btn`, `forgot_password_btn`.

### SCR-SH-04: Registration Screen (`/register`)
- **Purpose:** New account registration with role-tailored initial data capture.
- **Components:** Full Name / Organization input, Email, Phone number, Password, Role selector chip group (`donor`, `ngo`, `volunteer`), Terms and Safety Charter checkbox, `FBPrimaryButton` ("Create Account").
- **Rules:** Direct registration as `admin` is disallowed and absent from the UI.
- **Localization Keys:** `register_header`, `full_name_label`, `phone_label`, `create_account_btn`.

### SCR-SH-05: Forgot Password Screen (`/forgot-password`)
- **Purpose:** Self-service password recovery.
- **Components:** Email input field, explanatory caption, `FBPrimaryButton` ("Send Reset Link"), success confirmation card.
- **Localization Keys:** `forgot_password_title`, `reset_link_sent`.

### SCR-SH-06: User Profile & Settings (`/profile`)
- **Purpose:** Manage account details, operational preferences, and language selection.
- **Components:** Profile avatar, verified status badge, editable display name and phone number, role-specific section (e.g., NGO verification details, Volunteer vehicle type), Language Selector Dropdown (English, Hindi, Marathi), Dark Mode toggle, Logout button, Delete Account request link.
- **Localization Keys:** `profile_title`, `language_setting`, `dark_mode_setting`, `logout_btn`.

### SCR-SH-07: Notifications Center (`/notifications`)
- **Purpose:** Consolidated timeline of status alerts, task reminders, and claim notices.
- **Components:** Tabbed view ("All", "Unread"), notification item cards with event icon, timestamp, unread dot, tap action navigating to the specific donation or task record, "Mark all as read" button.
- **Localization Keys:** `notifications_title`, `mark_all_read`.

---

## 3. Donor Module Screens

### SCR-DON-01: Donor Dashboard (`/donor/dashboard`)
- **Components:** Welcome banner, quick action tiles ("Donate Food", "Donate Clothes"), Active Donations horizontal carousel with live status chips and expiry countdowns, Monthly Impact Metric cards (kg saved, meals served, carbon avoided).
- **Localization Keys:** `donor_welcome`, `donate_food_btn`, `donate_clothes_btn`, `active_donations_header`.

### SCR-DON-02: Create Food Donation (`/donor/create-food`)
- **Components:** Multi-step wizard:
  - Step 1: Title, Category chips (`Cooked Meals`, `Packaged Dry`, `Fresh Produce`, `Bakery/Dairy`).
  - Step 2: Quantity numeric input, Unit dropdown, Estimated portion count, Preparation timestamp, Storage chips (`Hot Holding`, `Refrigerated`, `Ambient`), Mandatory Collection Deadline picker, Allergen checkboxes.
  - Step 3: Photo upload tiles (up to 5), Approximate public locality, Private pickup address with gate/parking notes, Mandatory Food Hygiene Declaration checkbox, `FBPrimaryButton` ("Publish Donation").
- **Localization Keys:** `food_title_label`, `prep_time_label`, `expiry_deadline_label`, `hygiene_declaration_text`.

### SCR-DON-03: Create Clothing Donation (`/donor/create-clothing`)
- **Components:** Category selection (`Menswear`, `Womenswear`, `Children`, `Winterwear`, `Footwear`), Quantity and piece count, Size checkboxes, Condition chips (`New with tags`, `Like new`, `Good condition`), Cleanliness confirmation checkbox ("Items are washed and dry"), Photo upload tiles, Address fields, `FBPrimaryButton` ("Publish Donation").
- **Localization Keys:** `clothing_title_label`, `condition_label`, `cleanliness_cert_text`.

### SCR-DON-04: My Donations List (`/donor/donations`)
- **Components:** Segmented filter tabs (`Active`, `Past / Completed`), list of `FBDonationCard` items, pull-to-refresh, empty state with "Donate Now" CTA.
- **Localization Keys:** `my_donations_title`, `active_tab`, `completed_tab`.

### SCR-DON-05: Donation Details View (`/donor/donation/:id`)
- **Components:** Full-width image gallery with indicators, status timeline (`Available` $\rightarrow$ `Requested` $\rightarrow$ `Assigned` $\rightarrow$ `Picked Up` $\rightarrow$ `Delivered` $\rightarrow$ `Distributed`), Quantity and storage details, Assigned Volunteer card (shows volunteer photo, name, vehicle type once assigned), "Cancel Donation" button (active only if eligible).
- **Localization Keys:** `donation_details_title`, `cancel_donation_btn`.

### SCR-DON-06: Request Status & Allocation Screen (`/donor/requests/:id`)
- **Components:** List of incoming NGO claim requests for the donation, requesting NGO profile card with verification badge, requested quantity, proposed collection mode (Direct vs. Volunteer), Accept and Decline action buttons.
- **Localization Keys:** `incoming_requests_title`, `accept_request_btn`, `decline_request_btn`.

---

## 4. NGO Module Screens

### SCR-NGO-01: NGO Dashboard (`/ngo/dashboard`)
- **Components:** NGO Verification status banner (Verified ✓ vs. Pending ⏳), Urgent Needs summary, Incoming Deliveries tracking card with volunteer ETA, Quick filter shortcuts, Impact summary (Meals distributed this month).
- **Localization Keys:** `ngo_dashboard_title`, `incoming_deliveries_header`, `verification_status_banner`.

### SCR-NGO-02: Discover Donations Feed (`/ngo/discover`)
- **Components:** Search bar, Filter chips (Donation Type, Radius Slider, Urgency/Expiry), Feed of available donations with portion counts and countdown timers, One-tap "Claim" action button on each card.
- **Localization Keys:** `discover_feed_title`, `filter_type_label`, `filter_distance_label`.

### SCR-NGO-03: NGO Donation Details (`/ngo/donation/:id`)
- **Components:** Donation photos, food category, preparation and storage requirements, allergen warnings, approximate neighborhood, remaining expiry time, prominent "Request Donation" sticky button.
- **Localization Keys:** `claim_donation_btn`, `allergen_warning_title`, `storage_req_label`.

### SCR-NGO-04: Request Donation Modal / Screen (`/ngo/request/:id`)
- **Components:** `FBClaimBottomSheet` displaying requested quantity slider, radio selection ("Our NGO will collect directly" vs. "Request volunteer courier"), delivery address confirmation, coordinator note field, "Confirm Claim" button.
- **Localization Keys:** `confirm_claim_btn`, `direct_pickup_option`, `volunteer_needed_option`.

### SCR-NGO-05: Received Donations Queue (`/ngo/received`)
- **Components:** List of incoming dispatches (`In Transit`, `Arrived at Doorstep`), "Confirm Physical Receipt" button, "Decline / Inspection Failure" button.
- **Localization Keys:** `received_donations_title`, `confirm_receipt_btn`, `reject_delivery_btn`.

### SCR-NGO-06: Distribution Records & Logger (`/ngo/distribution`)
- **Components:** Form to record distribution: Quantity received vs. Quantity distributed, distribution date, summary note (e.g., "Served at community night shelter"), beneficiary meal/clothing counts, submit button. Strictly excludes beneficiary personal PII fields.
- **Localization Keys:** `log_distribution_title`, `quantity_distributed_label`, `beneficiary_summary_label`.

---

## 5. Volunteer Module Screens (Special Logistics Focus)

### SCR-VOL-01: Volunteer Dashboard (`/volunteer/dashboard`)
- **Components:** Availability toggle ("Available for pickups 🟢 / Offline ⚪"), Active assignment banner (if task ongoing), Today's completed tasks counter, "Rider Mode" feed shortcut.
- **Localization Keys:** `volunteer_dashboard_title`, `status_online`, `status_offline`.

### SCR-VOL-02: Available Tasks Feed (`/volunteer/tasks`)
- **Components:** High-contrast task cards, vehicle compatibility tags (🛵 Two-Wheeler vs. 🚗 Car/Van), Route summary (Zone A to Zone B, distance in km), Deadline countdown, Large $56\text{ dp}$ "Accept Task" button with atomic lock.
- **Localization Keys:** `available_tasks_title`, `accept_task_btn`, `vehicle_twowheeler_tag`.

### SCR-VOL-03: Task Details Screen (`/volunteer/task/:id`)
- **Components:** Prior to acceptance: approximate route, cargo volume, weight, time window. Post-acceptance: Exact donor address unlocked, door/gate entry code, Donor contact phone with one-tap dialer, "Open in Maps" navigation button, "Confirm Pickup" button.
- **Localization Keys:** `task_details_title`, `call_donor_btn`, `open_maps_btn`, `unlocked_address_label`.

### SCR-VOL-04: Pickup Confirmation Screen (`/volunteer/pickup-confirm/:id`)
- **Components:** Cargo verification checklist (3 crates checked, packaging sealed), Large green "Confirm Physical Collection" button with haptic feedback, "Report Issue" secondary link.
- **Localization Keys:** `pickup_confirm_title`, `confirm_pickup_btn`, `report_issue_btn`.

### SCR-VOL-05: Delivery & Handover Confirmation (`/volunteer/delivery-confirm/:id`)
- **Components:** Shelter destination address, recipient coordinator name and phone, inspection confirmation checklist, Large $56\text{ dp}$ "Confirm Delivery to NGO" button.
- **Localization Keys:** `handover_confirm_title`, `confirm_handover_btn`.

### SCR-VOL-06: Volunteer Task History (`/volunteer/history`)
- **Components:** Chronological list of completed deliveries, badges earned, total kilometers travelled, and estimated meals transported.
- **Localization Keys:** `task_history_title`, `total_trips_label`, `meals_transported_label`.

---

## 6. Administrator Module Screens

### SCR-ADM-01: Admin Dashboard (`/admin/dashboard`)
- **Components:** Real-time metrics overview (Pending NGO verifications count, active donations today, active dispatches, open incident tickets), System health indicators, Quick action cards.
- **Localization Keys:** `admin_dashboard_title`, `pending_verifications_count`, `active_dispatches_count`.

### SCR-ADM-02: NGO Verification Queue (`/admin/verifications`)
- **Components:** Split-screen layout (desktop web) or detail view (tablet/mobile):
  - Left pane: Applicant NGO list sorted by submission timestamp.
  - Right pane: Organization profile, registration number, address, and interactive PDF viewer displaying uploaded tax exemption certificates with "Approve Verification" and "Reject with Feedback" controls.
- **Localization Keys:** `verification_queue_title`, `approve_ngo_btn`, `reject_ngo_btn`.

### SCR-ADM-03: User Management Screen (`/admin/users`)
- **Components:** Searchable user directory with role filter chips (`Donor`, `NGO`, `Volunteer`), account status chips (`Active`, `Suspended`, `Pending`), User detail dialog with one-click suspend/reactivate controls and mandatory reason log.
- **Localization Keys:** `user_management_title`, `suspend_user_btn`, `reactivate_user_btn`.

### SCR-ADM-04: Donation Monitoring Screen (`/admin/donations`)
- **Components:** Live master list of all donations across the system with status pills, donor details, assigned NGO, and emergency cancel/moderate action button.
- **Localization Keys:** `donation_monitoring_title`, `moderate_donation_btn`.

### SCR-ADM-05: Task Monitoring Screen (`/admin/tasks`)
- **Components:** Global dispatch monitor showing open, in-transit, and stalled tasks, filter by service zone, manual re-assignment trigger for stalled food rescues.
- **Localization Keys:** `task_monitoring_title`, `reassign_task_btn`.

### SCR-ADM-06: Reports, Complaints & Audit Logs (`/admin/audit`)
- **Components:** Tab 1: Incident reports (food spoilage complaints, volunteer no-shows). Tab 2: Immutable chronological audit log table displaying timestamp, actor ID, entity ID, action type, and state diff. Export to CSV button.
- **Localization Keys:** `audit_logs_title`, `incident_reports_title`, `export_csv_btn`.

