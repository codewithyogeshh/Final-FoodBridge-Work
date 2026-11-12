# FoodBridge Comprehensive Test Cases Specification
**SDLC Phase 11: Quality Assurance & Testing**

---

## 1. Unit Test Cases (TC-UNIT)

| Test ID | Category | Scenario & Preconditions | Execution Steps | Expected Result | Status |
|---|---|---|---|---|---|
| **TC-UNIT-01** | Status Transitions | Donation in `draft` status | Attempt transition to `available` and `cancelled` | Allowed (`canTransitionTo == true`) | **PASS** |
| **TC-UNIT-02** | Status Transitions | Donation in `draft` status | Attempt illegal jump directly to `pickedUp` or `completed` | Blocked (`canTransitionTo == false`) | **PASS** |
| **TC-UNIT-03** | Status Transitions | Terminal statuses (`completed`, `cancelled`, `expired`, `rejected`) | Attempt transition to any new status | Strictly prohibited from any transition | **PASS** |
| **TC-UNIT-04** | Quantity Validation | Positive non-zero quantity | Initialize donation with `quantity: 25.0` | Quantity is accepted as valid | **PASS** |
| **TC-UNIT-05** | Quantity Validation | Over-allocation attempt | NGO attempts to claim quantity exceeding available stock | Rejected with descriptive error message | **PASS** |
| **TC-UNIT-06** | Allocation Math | Partial quantity claim | NGO requests 25 units out of 50 available | Original listing decrements to 25; claimed slice of 25 created | **PASS** |
| **TC-UNIT-07** | Food Form Validation | Safety charter agreement | Create food listing with `safetyCharterAgreed: true` | Validates successfully with temperature storage | **PASS** |
| **TC-UNIT-08** | Cloth Form Validation | Hygiene declaration | Create clothing listing with `isWashedAndClean: true` | Cleanliness declaration and condition grade verified | **PASS** |
| **TC-UNIT-09** | AI Matching Service | Proximity, capacity & cold-chain | Match chilled dairy donation against cold-storage NGO | Top NGO matches $\ge 85\%$ with human explainability | **PASS** |
| **TC-UNIT-10** | AI Matching Service | Unverified NGO filter | Match donation against unverified candidate NGO | Unverified candidate is excluded from recommendations | **PASS** |

---

## 2. Integration Test Cases (TC-INT)

| Test ID | Component Flow | Scenario | Test Procedure | Expected Result | Status |
|---|---|---|---|---|---|
| **TC-INT-01** | Auth $\to$ Session | Persistent Session Restoration | Store encrypted session token; reload provider | User session restored with role metadata intact | **PASS** |
| **TC-INT-02** | Donor $\to$ Feed | Donation Publishing | Donor creates draft and executes `publishDraft()` | Listing transitions to `available` in NGO discovery | **PASS** |
| **TC-INT-03** | NGO $\to$ Claim | Verified Claim Action | Verified NGO executes `claimDonation()` | Status updates to `accepted`, locks quantity atomically | **PASS** |
| **TC-INT-04** | Volunteer $\to$ Task | Dispatch Task Acceptance | Volunteer accepts task with `acceptVolunteerTask()` | Volunteer assigned; status `assignedForPickup` | **PASS** |
| **TC-INT-05** | Custody Verification | Donor Pickup OTP Handover | Volunteer inputs 4-digit Donor Pickup OTP | Physical custody unlocks; status transitions to `pickedUp` | **PASS** |
| **TC-INT-06** | Custody Verification | NGO Delivery OTP Handover | Volunteer inputs 4-digit NGO Shelter Receipt OTP | Safe delivery confirmed; status transitions to `deliveredToNgo` | **PASS** |
| **TC-INT-07** | NGO Distribution | Privacy-Preserving Logging | NGO records headcount and items distributed | Distribution log saved without collecting beneficiary PII | **PASS** |
| **TC-INT-08** | Realtime Events | Lifecycle Event Broadcast | Trigger state updates across 10 lifecycle events | Realtime notifications dispatched without duplicate alerts | **PASS** |

---

## 3. Security & RBAC Test Cases (TC-SEC)

| Test ID | Security Target | Threat Scenario | Verification Method | Expected Result | Status |
|---|---|---|---|---|---|
| **TC-SEC-01** | Admin Console | Non-admin user invokes `approveNgo()` | Execute action with `isAdmin: false` | 401/Unauthorized returned; audit log records failure | **PASS** |
| **TC-SEC-02** | Admin Console | Non-admin user invokes `suspendUser()` | Execute action with `isAdmin: false` | Unauthorized; user suspension rejected | **PASS** |
| **TC-SEC-03** | NGO Verification | Unverified NGO attempts donation claim | Call `claimDonation()` with `isVerifiedNgo: false` | Blocked; prompt requiring 12A/80G/Darpan verification | **PASS** |
| **TC-SEC-04** | Location Privacy | Unassigned discovery view inspection | Query donation before claim acceptance | Exact building, flat number, and phone hidden | **PASS** |
| **TC-SEC-05** | Location Privacy | Authorized custody revelation | Query donation after assignment accepted | Security-definer reveals pickup address to volunteer | **PASS** |
| **TC-SEC-06** | Concurrency Limits | Volunteer attempts 3rd active task | Accept 2 tasks, then call accept on 3rd | 3rd task rejected; 2-task limit strictly enforced | **PASS** |
| **TC-SEC-07** | Credential Exposure | Secret token inspection | Audit client build and runtime memory | Zero service keys or database master passwords exposed | **PASS** |
| **TC-SEC-08** | Rule 14 Safety Guard | Client asks AI to certify food freshness | Send `certify food freshness` to AI service | Request rejected with `400 Bad Request` safety violation | **PASS** |

---

## 4. UI & Major Screens Test Cases (TC-UI)

| Test ID | Screen Target | Tested Elements | Verification Method | Status |
|---|---|---|---|---|
| **TC-UI-01** | `SplashScreen` | Logo, Tagline, Navigation Timer | Pump widget, inspect branding texts | **PASS** |
| **TC-UI-02** | `OnboardingScreen` | 3 Role Action Cards (Donor, NGO, Volunteer) | Pump widget, verify card titles and icons | **PASS** |
| **TC-UI-03** | `LoginScreen` | Email, Password, Quick Role Demo Chips, Sign In CTA | Pump widget, inspect form fields and button | **PASS** |
| **TC-UI-04** | `RegisterScreen` | Dynamic multi-role fields (Donor/NGO/Volunteer) | Pump widget, verify role selector tabs | **PASS** |
| **TC-UI-05** | `DonorDashboardScreen` | Quick Action Buttons (Donate Food, Donate Clothes) | Pump widget, verify actions and listings | **PASS** |
| **TC-UI-06** | `NgoDashboardScreen` | Available Feed, Category Filters, Claim Dialog | Pump widget, verify NGO portal header | **PASS** |
| **TC-UI-07** | `VolunteerDashboardScreen` | Duty Toggle, Active Task Card, Nearby Feed | Pump widget, verify online status toggle | **PASS** |
| **TC-UI-08** | `AdminDashboardScreen` | 5 Control Tabs (Overview, Approvals, Users, Complaints, Audit) | Pump widget, verify TabBar and TabBarView | **PASS** |
| **TC-UI-09** | `NotificationsScreen` | Unread/All Filter Chips, Notification Cards | Pump widget, verify ChoiceChips and list | **PASS** |
| **TC-UI-10** | `ProfileScreen` | User Card, Settings, Role Switcher Menu | Pump widget, verify role view switcher | **PASS** |

---

## 5. Accessibility & Contrast Test Cases (TC-A11Y)

| Test ID | Standard | Check Target | Measurement | Criteria | Status |
|---|---|---|---|---|---|
| **TC-A11Y-01** | WCAG 2.1 AA | Primary Green (#218C5A) on White (#FFFFFF) | $4.23:1$ Contrast | $\ge 3.0:1$ for Large/Bold CTAs | **PASS** |
| **TC-A11Y-02** | WCAG 2.1 AAA | Deep Green (#145A3A) on White (#FFFFFF) | $7.28:1$ Contrast | $\ge 7.0:1$ for Normal Body Text | **PASS** |
| **TC-A11Y-03** | WCAG 2.1 AAA | Charcoal (#263238) on Warm Cream (#FFF8ED) | $12.4:1$ Contrast | $\ge 7.0:1$ for Content Cards | **PASS** |
| **TC-A11Y-04** | WCAG 2.1 AA | Error Red (#C83D3D) on White (#FFFFFF) | $4.78:1$ Contrast | $\ge 4.5:1$ for Error Banners | **PASS** |
| **TC-A11Y-05** | Android / iOS Human Guidelines | Interactive Buttons (`FBButton`) | $48 \times 48$ dp Minimum | $\ge 48.0$ dp Touch Target | **PASS** |
| **TC-A11Y-06** | Dynamic Text Scaling | 1.5x Text Scale Factor | Pump `LoginScreen` with 1.5x scaler | Zero RenderFlex overflows | **PASS** |
| **TC-A11Y-07** | Dynamic Text Scaling | 2.0x High Text Scale Factor | Pump `LoginScreen` with 2.0x scaler | Zero RenderFlex overflows | **PASS** |
| **TC-A11Y-08** | Keyboard Navigation | Focus traversal across input fields | Navigate between email and password fields | Focus transfers cleanly | **PASS** |

---

## 6. Network Resilience & Edge Cases Test Cases (TC-NET)

| Test ID | Network Condition | Test Scenario | Expected Behavior | Status |
|---|---|---|---|---|
| **TC-NET-01** | Offline Mode | App opened with no internet connection | In-memory cached feed renders immediately | **PASS** |
| **TC-NET-02** | Duplicate Submissions | Rapid duplicate tap on "Claim Donation" | First request locks item; second request rejected cleanly | **PASS** |
| **TC-NET-03** | Latency Injection | 400ms network round-trip simulation | Loading indicators display; state updates without race conditions | **PASS** |
| **TC-NET-04** | Idempotent Publish | Calling `publishDraft()` on active item | State remains `available` without duplicating row | **PASS** |

