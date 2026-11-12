# FoodBridge --- Business Rules, Safety Rules and Platform Policies

**Version:** 1.0\
**Purpose:** Define consistent, safe and auditable behaviour for donors,
NGOs, volunteers and administrators.

## 1. Core principles

1.  Protect the dignity, privacy and safety of people receiving support.
2.  Make donation status and responsibility clear.
3.  Prevent duplicate claims and misleading listings.
4.  Prefer timely redistribution while respecting safe handling and
    collection limits.
5.  Use verification and audit trails for trust.
6.  Keep AI advisory; humans remain responsible for important decisions.
7.  Do not publish personal or sensitive information unnecessarily.

## 2. Account and role rules

-   Every account must have one active primary role in the first
    release.
-   Users must not be able to grant themselves an administrator role.
-   NGO accounts must be verified by an authorised administrator before
    they can claim restricted donations.
-   A suspended account cannot create donations, request donations or
    accept tasks.
-   Users must provide accurate contact information needed for
    coordination.
-   Role changes must be handled through an authorised process and
    logged.
-   Shared accounts should be discouraged because they weaken
    accountability.

## 3. Donor rules

-   Donors must provide truthful descriptions and quantities.
-   Donors must not list items they do not have permission to donate.
-   Donors must specify a realistic collection window and pickup
    location.
-   Donors must update or withdraw a listing if availability changes.
-   Donors must not mark a donation as handed over unless the handover
    actually occurred.
-   Donors should respond to coordination requests within the stated
    time window.
-   Repeated false, unsafe or misleading listings may result in
    moderation.

## 4. Food donation rules

Food safety is a critical operational responsibility. FoodBridge is a
coordination platform and does not certify food safety.

Each food listing should collect, where applicable: - Food category and
description. - Quantity and unit. - Preparation or packing date/time. -
Storage and handling conditions. - Collection deadline. -
Ingredient/allergen information if known and relevant. - Donor
declaration that the information is accurate.

Operational rules: - Do not publish a food donation without a collection
deadline. - Do not show expired or withdrawn food as available. - Do not
encourage collection or distribution after a stated safe-use deadline. -
The donor must package and store food responsibly before pickup. - The
receiving NGO must inspect the food at handover and may refuse it if its
condition, handling history or information is uncertain. - If
temperature control is required, the donor and recipient must arrange
suitable handling. - Food with uncertain history, contamination concerns
or unsuitable condition must not be distributed. - Record rejection and
reason where practical. - Follow applicable local food-safety laws and
guidance. Obtain qualified local advice before operating a live
programme.

**AI restriction:** An image classifier must never declare food safe,
fresh, uncontaminated or suitable for consumption. A photograph cannot
reliably establish these facts.

## 5. Clothing donation rules

-   Donated clothing should be clean, dry and usable.
-   Donors must describe condition accurately.
-   Torn, heavily soiled, damp, mouldy or otherwise unsuitable items
    should not be listed as usable donations.
-   Sizes and categories should be provided where useful.
-   NGOs may reject items that do not meet their acceptance criteria.
-   Clothing should be sorted and stored in a hygienic manner.
-   The platform should allow NGOs to record received, accepted,
    rejected and distributed quantities.

## 6. NGO rules

-   NGOs must submit truthful organisation and contact information.
-   Verification documents must be reviewed only by authorised
    administrators.
-   NGOs must state their service areas and realistic capacity.
-   NGOs must request only quantities they can collect, store and
    distribute.
-   NGOs must not claim donations they cannot reasonably handle.
-   NGOs must confirm actual receipt and record distribution honestly.
-   NGOs should not publish beneficiary identities or photographs
    without appropriate consent.
-   NGOs must report safety concerns, incidents, suspected fraud or lost
    donations.

## 7. Volunteer rules

-   Volunteers must provide accurate contact and availability
    information.
-   Volunteers should accept only tasks they can reasonably complete.
-   Pickup and drop-off details are private and must not be shared
    beyond the task.
-   Volunteers must update task status honestly.
-   Volunteers must not open, consume, sell or redirect donations.
-   Volunteers must follow safe transport and handling instructions.
-   If a pickup cannot be completed, the volunteer must report the issue
    promptly.
-   The NGO or authorised coordinator confirms final receipt.
-   The platform should provide a way to report unsafe or inappropriate
    situations.

## 8. Allocation and request rules

-   A donation can receive multiple requests, but allocation must not
    exceed available quantity.
-   The allocation decision must follow the configured workflow: donor
    approval, NGO acceptance or an authorised coordinator.
-   The system must use a database transaction or equivalent concurrency
    control to prevent over-allocation.
-   A request must include the requesting NGO, requested quantity and
    timestamp.
-   The platform should show request status clearly.
-   Rejected or withdrawn requests must release any reserved quantity.
-   If partial allocation is supported, the remaining quantity must stay
    accurate.
-   No user may manipulate request ordering or allocation records
    without authorisation.

## 9. Volunteer assignment rules

-   Only eligible, active volunteers can accept tasks.
-   A task must have no more than one active volunteer unless explicitly
    configured as a team task.
-   A volunteer should not exceed their active task limit.
-   Precise location details should be revealed only after assignment
    and only to authorised participants.
-   Reassignment must close or cancel the previous assignment cleanly.
-   A task cannot be marked completed until required pickup and handover
    confirmations are present.

## 10. Status transition rules

Allowed transitions must be enforced server-side. Suggested donation
lifecycle:

`draft → available → requested → accepted → assigned_for_pickup → picked_up → delivered_to_ngo → distributed → completed`

Alternative valid paths may include direct NGO collection
(`accepted → delivered_to_ngo`). Cancellation, rejection and expiry are
separate terminal or recovery paths.

-   A completed donation cannot be reopened through ordinary user
    actions.
-   An expired donation cannot be claimed.
-   A cancelled donation cannot continue through an active pickup task.
-   Every important transition records actor, timestamp and relevant
    note.
-   Users may only perform transitions allowed for their role.
-   Notifications must be generated after a successful database commit,
    not before.

## 11. Privacy and data access rules

-   Public donation listings should show an approximate area, not a
    donor's exact home address.
-   Exact pickup/drop-off information is visible only to authorised
    parties at the appropriate workflow stage.
-   Beneficiary personal information should not be required for the core
    platform unless there is a clearly justified operational need.
-   Never expose beneficiary lists publicly.
-   Verification documents must be stored in private storage with
    restricted access.
-   Do not include private data in AI prompts unless necessary,
    authorised and protected.
-   Do not use beneficiary data for advertising or unrelated profiling.
-   Provide a process for correcting or deleting account data where
    legally and operationally appropriate.
-   Keep access logs for sensitive administrative operations.

## 12. AI usage rules

AI features may: - Suggest donation categories from a photo. - Rank
potentially suitable NGOs. - Summarise aggregate donation demand. -
Answer common questions using approved help content.

AI features must not: - Certify food safety or freshness. - Decide that
a person deserves or does not deserve help. - Automatically verify an
NGO or volunteer. - Reject a donation without a human-review path. -
Reveal private data. - Invent stock, availability, locations or
beneficiary information.

Show that a recommendation is AI-generated and allow users to correct
it. Monitor errors and provide a non-AI fallback.

## 13. Fraud, abuse and moderation

Potential abuse indicators: - Repeated false listings. - Duplicate
accounts or suspicious request patterns. - Misrepresented quantities. -
Repeated no-shows. - Requests to pay unofficial fees. - Attempts to
obtain private beneficiary or donor information. - Inappropriate or
threatening communication.

Provide report, review, warning, suspension and appeal processes. Do not
automatically accuse a user based only on an AI score.

## 14. Admin responsibilities

Administrators may: - Verify or reject NGO applications with a reason. -
Review reports and complaints. - Restrict accounts under a documented
policy. - Correct clearly erroneous records through an auditable
process. - View aggregate impact reports.

Administrators must not: - Browse private information without a
legitimate operational reason. - Change completed donation records
silently. - disclose verification documents or personal data. - use
platform data for unrelated purposes.

## 15. Incident handling

For food-safety concerns, lost donations, harassment, suspected fraud or
privacy incidents: 1. Provide an in-app report mechanism. 2. Record the
report securely. 3. Notify the designated administrator or NGO
coordinator. 4. Pause the affected donation/task where necessary. 5.
Restrict access to relevant records. 6. Document the review and
resolution. 7. Escalate to appropriate local authorities or qualified
professionals when required.

## 16. Policy disclaimer

These are proposed product rules, not legal advice. Before a real-world
launch, the project team and operating partners must review applicable
food-safety, privacy, child-safeguarding, volunteer, transport,
insurance and NGO compliance requirements in the operating region.
