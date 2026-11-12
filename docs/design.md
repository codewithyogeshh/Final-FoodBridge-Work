# FoodBridge --- UI/UX Design Guidelines

**Version:** 1.0\
**Product:** FoodBridge mobile application and optional web admin panel

## 1. Design direction

FoodBridge should feel welcoming, trustworthy, practical and easy to
use. The interface should communicate community support without making
beneficiaries feel exposed or stigmatised.

Design for three priorities: 1. **Clarity:** users should understand
what action to take next. 2. **Trust:** verification, status and
handover information should be visible. 3. **Accessibility:** the
application should work for people with different abilities, devices and
levels of digital confidence.

## 2. Brand direction

### Name

**FoodBridge**

### Suggested tagline

**Share More. Waste Less. Bridge the Need.**

### Brand personality

-   Compassionate, not pity-focused.
-   Trustworthy, not overly corporate.
-   Modern, not complicated.
-   Community-centred and inclusive.

### Suggested colour palette

Use colours consistently and verify contrast before release.

  Token           Suggested value   Usage
  --------------- ----------------- ------------------------------------
  Primary green   `#218C5A`         Main actions and positive emphasis
  Deep green      `#145A3A`         Headers and strong text accents
  Warm cream      `#FFF8ED`         Soft background
  Charcoal        `#263238`         Main text
  Muted grey      `#667085`         Secondary text
  Orange          `#E69A36`         Time-sensitive notice
  Red             `#C83D3D`         Error or critical warning
  White           `#FFFFFF`         Cards and surfaces

Do not rely on colour alone to communicate state. Pair colour with text
and icons.

## 3. Typography and layout

-   Use a clear sans-serif typeface such as Inter or the platform's
    accessible system font.
-   Establish a consistent type scale for page titles, section headings,
    body text, labels and helper text.
-   Keep body text readable and avoid dense paragraphs on mobile.
-   Use consistent spacing, alignment and card padding.
-   Use responsive layouts for small and large screens.
-   Avoid placing important actions only in hidden gestures or hover
    states.

## 4. Navigation structure

### Suggested mobile navigation

-   **Home:** role-specific summary and next action.
-   **Explore:** available donations or tasks, depending on role.
-   **My Activity:** donations, requests or assignments.
-   **Notifications:** status changes and reminders.
-   **Profile:** account details, verification and settings.

The exact navigation may vary by role. Do not show users irrelevant
screens.

## 5. Role-specific screens

### 5.1 Donor

**Home dashboard** - Welcome message and donor status. - Primary
actions: Donate Food, Donate Clothes. - Active donations with status. -
Recent activity. - Short guidance on accepted donations.

**Create donation** - Step 1: choose food or clothing. - Step 2: enter
description, category and quantity. - Step 3: add type-specific
details. - Step 4: add photo and collection details. - Step 5: review
and publish.

Use clear labels and examples. For food, make collection deadline and
storage/handling information prominent.

**Donation detail** - Donation summary and photo. - Quantity and
availability. - Request status. - Assigned pickup details when
authorised. - Timeline and cancellation/edit options when valid.

### 5.2 NGO

**NGO dashboard** - Verification state. - Donations available in service
area. - Open requests. - Incoming pickups. - Distribution records and
aggregate impact.

**Explore donations** - Search and filters. - Donation cards showing
category, quantity, approximate area, deadline and current status. - Do
not show precise donor address before a legitimate allocation.

**Donation detail** - Full donation information needed for decision. -
Request quantity and note. - Clear accept/request outcome. - Food
handling information and rejection option.

**Distribution record** - Quantity received. - Quantity distributed. -
Distribution date. - Notes and optional evidence under the
organisation's policy.

### 5.3 Volunteer

**Volunteer dashboard** - Availability status. - Available pickup
tasks. - Active assignment. - Completed task count.

**Task detail** - Pickup and drop-off details only after assignment. -
Time window and handling instructions. - Contact option. -
Accept/decline action.

**Task progress** - Confirm pickup. - Mark in transit if used. - Confirm
handover. - Report an issue.

### 5.4 Admin

**Admin dashboard** - Pending NGO verifications. - Active donations and
tasks. - Reports requiring review. - Aggregate platform activity.

**Verification screen** - Organisation profile. - Submitted document
preview with restricted access. - Approve/reject controls. - Required
reason and audit record.

**Moderation screen** - User or donation report. - Relevant activity
history. - Review notes. - Action and appeal status.

## 6. Reusable UI components

-   Primary and secondary buttons.
-   Donation type selector.
-   Donation card.
-   Status chip with text label.
-   Quantity/unit input.
-   Date/time picker.
-   Image upload tile.
-   Location selector.
-   Filter chips.
-   Request summary.
-   Volunteer task card.
-   Timeline/event list.
-   Empty-state illustration and guidance.
-   Confirmation dialog.
-   Error, warning and success banners.

Every interactive component should have default, pressed, disabled,
loading, success and error states where relevant.

## 7. Status design

Use both a short text label and a visual indicator.

  Status                  Suggested label
  ----------------------- -------------------------------------
  `available`             Available
  `requested`             Request received
  `accepted`              Accepted
  `assigned_for_pickup`   Volunteer assigned
  `picked_up`             Picked up
  `delivered_to_ngo`      Delivered to NGO
  `distributed`           Distribution in progress / recorded
  `completed`             Completed
  `cancelled`             Cancelled
  `expired`               Expired
  `rejected`              Rejected

Use plain language rather than exposing raw database values.

## 8. Accessibility requirements

-   Provide semantic labels for screen readers.
-   Support dynamic text scaling.
-   Maintain sufficient text/background contrast.
-   Make touch targets comfortably large (aim for at least 44--48
    logical pixels where practical).
-   Do not communicate state through colour alone.
-   Provide clear focus indicators and logical keyboard navigation on
    web.
-   Avoid time-limited interactions where possible.
-   Use plain language and explain unfamiliar terms.
-   Support localisation, including Marathi and Hindi if included in the
    pilot.
-   Test with screen readers and users with varied accessibility needs.

## 9. Forms and validation

-   Mark required fields clearly.
-   Explain why a field is needed.
-   Validate values before submission and show actionable messages.
-   Preserve entered data if a network request fails.
-   Prevent repeated submissions while an operation is processing.
-   Confirm destructive actions such as cancellation.
-   Use appropriate units and prevent ambiguous quantity entry.
-   Make food collection deadlines easy to notice and edit.

## 10. Trust and safety UX

-   Show NGO verification status clearly.
-   Explain why certain details are hidden until a request is accepted.
-   Display food handling information without implying platform
    certification.
-   Provide a clear "Report a problem" action.
-   Ask for confirmation before publishing a donation.
-   Make rejection and cancellation reasons understandable.
-   Avoid public beneficiary photographs or stories without consent.
-   Do not use shame-based language or imagery.

## 11. Suggested screen inventory

### Shared

-   Splash / onboarding
-   Sign up / sign in
-   Role selection
-   Profile
-   Notifications
-   Help and support
-   Terms and privacy

### Donor

-   Donor home
-   Choose donation type
-   Food donation form
-   Clothing donation form
-   Preview donation
-   My donations
-   Donation details
-   Request details

### NGO

-   NGO onboarding
-   Verification status
-   NGO home
-   Explore donations
-   Donation details
-   My requests
-   Incoming collections
-   Distribution records

### Volunteer

-   Volunteer onboarding
-   Volunteer home
-   Available tasks
-   Task details
-   Active task
-   Task history

### Admin

-   Admin login
-   Overview
-   NGO verification queue
-   User management
-   Donation monitoring
-   Reports and complaints
-   Audit log
-   Analytics

## 12. Design acceptance checklist

-   A first-time donor can find the donation action quickly.
-   Food and clothing forms ask only relevant fields.
-   NGO users can distinguish available, requested and accepted
    donations.
-   Volunteers can understand their next task action.
-   Exact addresses are not exposed in public feeds.
-   Status is understandable without colour.
-   Forms work on narrow screens and with text scaling.
-   Empty, loading, offline and error states are designed.
-   Critical actions require confirmation where appropriate.
-   A basic usability test has been completed with representative users.
