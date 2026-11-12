# FoodBridge — Usability Testing Scenarios & Evaluation Protocol

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 2 — Design Thinking & Empathy Mapping  
**Status:** Completed  
**Methodological Transparency Notice:** In strict accordance with the master project instructions, the usability protocols and scenarios described herein are **Modelled Testing Frameworks & Planned Simulation Protocols**. No actual live user testing or field interviews have been conducted prior to this phase. These test scenarios are designed to be executed during the pilot testing phase.

---

## 1. Usability Testing Framework & Objectives

The primary objective of the FoodBridge usability testing protocol is to identify interaction friction, cognitive overload, layout confusion, and safety declaration clarity across our key stakeholder personas.

### Evaluation Metrics
1. **Task Completion Rate (TCR):** Percentage of participants who complete the scenario without facilitator intervention (Benchmark: $\ge 90\%$).
2. **Time on Task (ToT):** Duration in seconds from scenario initiation to confirmation (Benchmark: $\le 90\text{ s}$ for donation creation; $\le 30\text{ s}$ for volunteer task claim).
3. **Single Ease Question (SEQ):** Post-task 7-point rating scale ($1 = \text{Very Difficult}, 7 = \text{Very Easy}$; Benchmark: $\ge 6.0$).
4. **Error & Navigation Misstep Frequency:** Number of unintended taps, invalid field entries, or back-button recovery loops.
5. **System Usability Scale (SUS):** 10-item standard usability questionnaire administered at the conclusion of testing (Target Score: $\ge 80$).

---

## 2. Test Scenario 1: Late-Night Surplus Food Posting (Commercial Donor)

### Participant Archetype
Commercial kitchen manager, caterer, or banquet hall staff member.

### Scenario Briefing Given to Participant
> *"It is 10:45 PM. Your banquet event has just finished, and you have approximately 35 kilograms of wholesome, hot cooked curries and rice packed in crates. Your kitchen will be locked in 45 minutes. Open the FoodBridge app and list this donation so that a nearby shelter can collect it safely before 11:30 PM."*

### Task Steps Evaluated
1. Locate and tap "Donate Surplus Food".
2. Select category "Cooked Meals" and input quantity (35 kg / ~90 portions).
3. Enter preparation time (8:30 PM) and select storage condition ("Hot Holding").
4. Specify collection deadline (11:30 PM / 45 minutes from now).
5. Declare known allergens ("Dairy", "Nuts").
6. Verify approximate public zone vs. private loading dock address.
7. Tick the mandatory food hygiene certification declaration and tap "Publish".

### Observational Checklist & Success Criteria
- [ ] Did the participant understand the distinction between public pickup zone and private address?
- [ ] Was the mandatory food safety declaration read or glanced at?
- [ ] Did the user finish the posting flow in $\le 90\text{ seconds}$?
- [ ] Did the user express hesitation regarding liability?

---

## 3. Test Scenario 2: Urgent Donation Discovery & Claim (NGO Coordinator)

### Participant Archetype
Shelter director, food bank coordinator, or community kitchen operations lead.

### Scenario Briefing Given to Participant
> *"You run a night shelter with 100 residents and dinner supplies are running low. Open FoodBridge, locate available cooked meals within an 8 km radius, and claim 35 kg of meals while requesting volunteer delivery assistance."*

### Task Steps Evaluated
1. Open the "Explore" discovery feed.
2. Apply filter chips: "Food", "Within 8 km", and "Cooked Meals".
3. Evaluate the banquet listing: portion count, holding condition, and collection countdown timer.
4. Tap "Request Donation".
5. Enter requested quantity (35 kg).
6. Select logistics option: "We request a FoodBridge Volunteer for delivery".
7. Confirm claim and observe atomic reservation confirmation.

### Observational Checklist & Success Criteria
- [ ] Did the participant immediately spot the remaining expiry countdown?
- [ ] Did the user understand that claiming locks the quantity immediately?
- [ ] Was the volunteer delivery request option clear and intuitive?
- [ ] Did the participant complete the claim in $\le 45\text{ seconds}$?

---

## 4. Test Scenario 3: Two-Wheeler Task Claim & Doorstep Handover (Volunteer)

### Participant Archetype
College student or gig volunteer operating a motorcycle or scooter in urban traffic.

### Scenario Briefing Given to Participant
> *"You are on your motorcycle with 90 minutes of free time. Open FoodBridge to find a nearby task. Evaluate the cargo load to ensure it is suitable for your two-wheeler, accept the task, navigate to the pickup gate, confirm pickup, and then confirm delivery at the shelter."*

### Task Steps Evaluated
1. Open the Volunteer Task Feed.
2. Filter/inspect task cards for the "Two-Wheeler Compatible" badge.
3. Tap the large "Accept Task" action button ($\ge 48\text{ dp}$).
4. Observe the instant unlocking of the donor's private gate instructions and telephone number.
5. Tap "Call Donor" to simulate gate entry coordination.
6. Tap the prominent "Confirm Pickup" button upon simulated cargo loading.
7. Navigate to destination shelter and tap "Confirm Handover".

### Observational Checklist & Success Criteria
- [ ] Were the action buttons easily tappable without accidental mis-taps (simulating one-handed/gloved use)?
- [ ] Did the volunteer feel confident that the task was exclusively locked to them?
- [ ] Did the user notice the emergency surrender button in case of a flat tire?
- [ ] Total interaction time for each status transition $\le 5\text{ seconds}$?

---

## 5. Test Scenario 4: Doorstep Quality Rejection Workflow (Safety Protocol)

### Participant Archetype
Receiving NGO inspector and delivering volunteer.

### Scenario Briefing Given to Participant
> *"A volunteer has arrived at your shelter with a food donation. Upon inspecting the containers, you notice the food has developed an off-odor and is tepid. Exercise your right of refusal and reject the delivery safely in the app."*

### Task Steps Evaluated
1. Open active incoming dispatch card on NGO app.
2. Select "Reject Delivery" at handover step.
3. Select rejection reason tag: "Food Safety Failure (Off-Odor / Tepid Temp)".
4. Add brief mandatory incident notes.
5. Confirm rejection and verify both NGO and volunteer screens display safety disposal instructions.

### Observational Checklist & Success Criteria
- [ ] Was the rejection option easy to find without feeling punitive?
- [ ] Did the user understand that rejection does not penalize the NGO or the volunteer?
- [ ] Were the safety disposal guidelines clear?

---

## 6. Post-Testing Debrief & Qualitative Questions

1. *"At any point did you feel that private personal information (like your home address or telephone number) was exposed to the public?"*
2. *"How confident were you that the food status and countdown timers were accurate and live?"*
3. *"For volunteers: Was the interface clear enough to use while stopped at a traffic light?"*
4. *"What is the single biggest barrier that would stop you from using FoodBridge weekly in real life?"*

