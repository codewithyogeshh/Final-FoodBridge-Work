# FoodBridge — Problem Statements & Pain-Point Analysis (Design Thinking Stage 3A)

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 2 — Design Thinking & User Research  
**Status:** Completed  
**Deliverable Location:** `docs/design-thinking/problem_statements.md`  

---

## 1. Point of View (POV) Problem Statements

POV Framework:
$$\text{[User Profile]} \text{ needs a way to } \text{[User Need]} \text{ because } \text{[Surprising Insight / Root Cause]}.$$

### POV 1: Commercial Food Donor (Ramesh Sharma)
> **Ramesh, a busy banquet catering manager, needs a way to** post surplus cooked food for rescue in under 90 seconds without exposing his personal phone number or incurring legal liability, **because** his kitchen staff close late at night and cannot wait around for informal coordination or risk brand damage from spoiled food.

### POV 2: Household Clothing Donor (Priya Kulkarni)
> **Priya, a conscious urban apartment resident, needs a way to** donate wearable garments and pantry staples with guaranteed privacy and transparent condition criteria, **because** she feels unsafe having her exact apartment address visible on public bulletin boards and wants assurance that her clothes directly help impoverished families rather than being discarded or resold.

### POV 3: NGO Operations Coordinator (Sunita Deshmukh)
> **Sunita, a dedicated night shelter director, needs a way to** discover, reserve, and receive exact quantities of wholesome food with reliable transportation assistance, **because** her shelter operates on strict budgets without dedicated delivery vans, and she cannot risk serving compromised or unhygienic meals to vulnerable shelter residents.

### POV 4: Community Field Volunteer (Rahul Patil)
> **Rahul, a motorcycle-riding college student, needs a way to** evaluate and claim pickup tasks with one tap, access precise door-to-door directions, and verify handover seamlessly, **because** he is navigating busy streets, wearing gloves, and handling fragile food containers where any delay or confusion risks food spoilage.

### POV 5: Platform Administrator (Vikramaditya Sen)
> **Vikram, a trust and safety operations manager, needs a way to** rigorously vet NGO legal certificates and arbitrate logistics disputes in seconds, **because** fraudulent actors or food safety failures would completely destroy the community trust necessary for surplus resource redistribution.

---

## 2. Comprehensive Pain-Point & Root Cause Analysis

```
┌──────────────────────────────┬──────────────────────────────┬──────────────────────────────┐
│ SYMPTOM / OBSERVED PAIN      │ ROOT CAUSE                   │ SYSTEMIC IMPACT              │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│ 1. Good banquet food dumped  │ Ad-hoc coordination via      │ Hundreds of wholesome meals  │
│    into garbage bins nightly.│ phone calls takes too long.  │ lost; landfill methane.      │
│                              │                              │                              │
│ 2. Multiple volunteers arrive│ Race conditions & lack of    │ Wasted volunteer fuel; acute │
│    for the same donation.    │ centralized transaction lock.│ frustration and drop-off.    │
│                              │                              │                              │
│ 3. Donors hesitant to post   │ Public forums leak private   │ Donors abandon digital aid;  │
│    donations on group chats. │ home addresses & phone #s.   │ harassment & spam calls.     │
│                              │                              │                              │
│ 4. Shelters receive spoiled  │ Lack of clear collection     │ Food poisoning risks; shelter│
│    or unhygienic food.       │ deadlines & handling notes.  │ loses trust in donors.       │
│                              │                              │                              │
│ 5. Shelters overwhelmed by   │ Donors dump torn, dirty rags │ NGOs waste volunteer hours   │
│    unwearable clothing rags. │ due to vague guidelines.     │ hauling trash to dumpsters.  │
│                              │                              │                              │
│ 6. Volunteer drops task mid- │ Vehicle breakdown with no    │ Food sits on curb until it   │
│    transit; food expires.    │ emergency re-dispatch tool.  │ degrades beyond safe cutoff. │
│                              │                              │                              │
│ 7. Fake charities resell     │ Informal groups do not check │ Exploitation of free aid;    │
│    donated goods for profit. │ government registration IDs. │ donor cynicism and boycott.  │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
```

---

## 3. Core User Needs Synthesis

1. **For Donors:**
   - *Frictionless Speed:* Streamlined forms with smart defaults ($\le 90\text{ s}$).
   - *Safety & Clear Disclaimers:* Transparent declarations, food handling instructions, and legal indemnity.
   - *Two-Tier Privacy:* Masked public locality; exact address unlocked only to confirmed couriers.
2. **For NGOs:**
   - *Predictable Supply:* Proximity-filtered discovery feed with portion counts and countdown timers.
   - *Atomic Claim Exclusivity:* Zero double-claiming conflicts via database-level concurrency locks.
   - *Doorstep Quality Rejection:* Non-punitive right of physical refusal upon delivery.
3. **For Volunteers:**
   - *Ergonomic "Rider Mode":* High-contrast $\ge 56\text{ dp}$ buttons operable with one hand or gloves.
   - *Cargo Feasibility Upfront:* Clear vehicle compatibility tags (🛵 Two-Wheeler vs. 🚗 Car/Van).
   - *Emergency Re-dispatch:* One-touch surrender releasing tasks instantly if breakdowns occur.
4. **For Administrators:**
   - *Single-Pane Vetting:* Split-screen PDF credential viewer with checklist integration.
   - *Indisputable Traceability:* Immutable chronological audit logs capturing all state mutations.

