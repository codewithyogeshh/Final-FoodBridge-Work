# FoodBridge — Stakeholder Empathy Maps (Design Thinking Stage 1)

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** SDLC Phase 2 — Design Thinking & User Research  
**Status:** Completed  
**Deliverable Location:** `docs/design-thinking/empathy_maps.md`  

---

## ⚠️ Methodological Transparency & Research Assumptions Notice

> **IMPORTANT DECLARATION:**  
> The empathy maps documented below represent **modelled research hypotheses and stakeholder behavioral simulations** synthesized from published food recovery studies, NGO operational benchmarks, and urban logistics workflows.  
> **No actual user interviews or field usability tests have been conducted yet.**  
> Prior to full commercial pilot deployment, the engineering team recommends conducting structured semi-structured interviews with at least 5 commercial restaurant managers, 3 registered NGO coordinators, and 8 active field volunteers to validate or refine these modelled assumptions.

---

## 1. Empathy Map: The Food & Clothing Donor

*Covers: Restaurants, Hotels, Event Caterers, Supermarket Retailers, and Individual Household Donors.*

```
┌──────────────────────────────────────┬──────────────────────────────────────┐
│ WHAT THEY THINK                      │ WHAT THEY FEEL                       │
│ • "It breaks my heart to throw away  │ • Guilty when kitchen staff toss     │
│   good food we spent hours cooking." │   fresh, untouched food into bins.   │
│ • "If someone falls ill from this,   │ • Rushed and anxious as nightly      │
│   will our brand be legally liable?" │   kitchen closing hours approach.    │
│ • "I don't have 15 minutes to fill   │ • Protective of business reputation  │
│   out tedious bureaucratic forms."   │   and residential privacy.           │
│ • "Are these clothes actually going  │ • Skeptical whether informal apps    │
│   to poor families or being resold?" │   actually send real collectors.     │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ WHAT THEY SEE                        │ WHAT THEY HEAR                       │
│ • Kitchen staff eager to clean up,   │ • Staff saying: "Chef, no NGO is     │
│   shut the shutters, and go home.    │   answering; should we just dump it?"│
│ • Bags of clean clothes sitting for  │ • News stories highlighting urban    │
│   months in household closets.       │   hunger alongside food waste.       │
│ • Garbage bins overflowing behind    │ • Management asking for CSR impact   │
│   commercial food streets.           │   metrics to show stakeholders.      │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ WHAT THEY SAY AND DO                 │ PAINS & FRUSTRATIONS                 │
│ • Packages surplus food in foil packs│ • Fear of legal liability or public  │
│   or plastic containers late at night│   backlash if food is mistreated.    │
│ • Calls local contacts or posts on   │ • Unreliable volunteer pickups where │
│   WhatsApp groups with spotty replies│   no one shows up after a promise.   │
│ • Discards food if no one arrives    │ • Spam calls when private telephone  │
│   within 45–60 minutes.              │   numbers are leaked on open groups. │
│ • Demands quick, frictionless flows. │ • Cumbersome multi-page forms.       │
├──────────────────────────────────────┴──────────────────────────────────────┤
│ GAINS & VALUE SOUGHT                                                        │
│ • Rapid listing creation in under 90 seconds with smart category defaults.  │
│ • Vetted NGO verification badges that provide immediate trust.              │
│ • Automatic collection countdown ensuring pickup before doors lock.         │
│ • Digital CSR Impact Certificate acknowledging kilograms of food saved.     │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Empathy Map: The NGO Operations Coordinator

*Covers: Charitable Night Shelters, Community Soup Kitchens, Orphanages, and Clothing Banks.*

```
┌──────────────────────────────────────┬──────────────────────────────────────┐
│ WHAT THEY THINK                      │ WHAT THEY FEEL                       │
│ • "Can we trust this food? If it was │ • Overwhelmed by daily demand to     │
│   left at room temperature, it's bad"│   feed 100+ destitute residents.    │
│ • "Our kitchen budget is strained;   │ • Constantly anxious about potential │
│   free donations keep our doors open"│   foodborne illnesses in children.   │
│ • "We have no van or fuel to collect │ • Frustrated when unannounced bulk   │
│   goods across town right now."      │   donations arrive at midnight.      │
│ • "People treat us like a trash dump │ • Relieved and grateful when fresh,  │
│   for unwashed, torn rags."          │   hygienic meals arrive on time.     │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ WHAT THEY SEE                        │ WHAT THEY HEAR                       │
│ • Long lines of hungry community     │ • Shelter cooks asking: "Do we have  │
│   members waiting for evening dinner.│   enough rice and dal for tonight?"  │
│ • Piles of unusable, soiled garments │ • Donors demanding immediate pickup  │
│   cluttering shelter storage space.  │   without providing transport.       │
│ • Overworked volunteers trying to    │ • Community complaints when dinner   │
│   coordinate pickups by mobile phone.│   is served late.                    │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ WHAT THEY SAY AND DO                 │ PAINS & FRUSTRATIONS                 │
│ • Inspects incoming food visually and│ • Receiving spoiled or cold food     │
│   smells containers before serving.  │   that must be thrown away.          │
│ • Logs distribution counts in manual │ • Being beaten to donations by other │
│   paper registers or spreadsheets.   │   groups due to race conditions.     │
│ • Turns down distant donations due   │ • Severe lack of delivery drivers    │
│   to lack of transportation.         │   and transport vehicles.            │
│ • Demands dignified handling of aid. │ • Complex software eating into care. │
├──────────────────────────────────────┴──────────────────────────────────────┤
│ GAINS & VALUE SOUGHT                                                        │
│ • Geo-filtered discovery feed showing items within realistic shelter radius. │
│ • Guaranteed atomic claim locks eliminating double-claiming conflicts.      │
│ • Integrated option to request platform volunteer delivery assistance.      │
│ • Absolute right of refusal at physical handover without platform penalties. │
│ • Simple aggregate distribution logging with zero beneficiary PII burden.   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Empathy Map: The Community Volunteer (Special Logistics Focus)

*Covers: Student Volunteers, Youth, Two-Wheeler / Motorcycle Couriers, and Field Coordinators.*

```
┌──────────────────────────────────────┬──────────────────────────────────────┐
│ WHAT THEY THINK                      │ WHAT THEY FEEL                       │
│ • "I want to help tonight, but I     │ • Passionate and motivated to make a │
│   cannot afford to waste fuel."      │   tangible civic difference.         │
│ • "Is this cargo too heavy to carry  │ • Stressed by bad traffic, dark      │
│   safely on my motorcycle?"          │   alleys, and unlocatable gates.     │
│ • "What if I arrive and the food has │ • Vulnerable when interacting with   │
│   already been taken by someone else?│   impatient gate security guards.    │
│ • "I need large buttons; I can't type│ • Proud and deeply fulfilled when    │
│   long messages while driving."      │   handing hot food to shelter staff. │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ WHAT THEY SEE                        │ WHAT THEY HEAR                       │
│ • Dense urban traffic, rain, and     │ • Honking horns and noisy traffic    │
│   bright sunlight on phone screens.  │   making phone calls hard to hear.   │
│ • Confusing apartment gate numbers   │ • Donors saying: "Hurry up, our rear │
│   and poorly lit service alleys.     │   service entrance is closing."      │
│ • Fragile containers of hot gravy    │ • Friends asking how they find time  │
│   that could spill during transit.   │   to volunteer between classes.      │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ WHAT THEY SAY AND DO                 │ PAINS & FRUSTRATIONS                 │
│ • Checks app while seated on bike or │ • Arriving at a donor only to find   │
│   during brief traffic stops.        │   another volunteer took the food.   │
│ • Operates phone with one hand or    │ • Accepting a task only to discover  │
│   while wearing riding gloves.       │   it requires a four-wheeler van.    │
│ • Drives cautiously to prevent food  │ • Missing donor contact numbers or   │
│   containers from tipping over.      │   vague pickup instructions.         │
│ • Seeks instant status confirmation. │ • Vehicle breakdowns with no fallback│
├──────────────────────────────────────┴──────────────────────────────────────┤
│ GAINS & VALUE SOUGHT                                                        │
│ • Exclusive single-volunteer atomic claim lock (zero phantom tasks).        │
│ • "Rider Mode" UI: Minimum 56dp high-contrast action buttons with haptics.  │
│ • Upfront vehicle compatibility badges (🛵 Two-Wheeler vs. 🚗 Car/Van).     │
│ • Decrypted door address and one-tap donor dialer unlocked upon task claim.  │
│ • One-touch emergency surrender releasing task to nearby volunteers.        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Empathy Map: The Platform Administrator

*Covers: Compliance Officers, NGO Accreditation Vetting Staff, and Incident Moderators.*

```
┌──────────────────────────────────────┬──────────────────────────────────────┐
│ WHAT THEY THINK                      │ WHAT THEY FEEL                       │
│ • "If a fraudulent entity resells    │ • Highly vigilant and protective of  │
│   donated food, platform trust dies."│   community reputation.              │
│ • "I need to verify NGO registration │ • Accountable for legal compliance,  │
│   proofs without juggling 5 tabs."   │   user safety, and data privacy.     │
│ • "Every status mutation must have an│ • Frustrated by blurry, incomplete,  │
│   indisputable, immutable audit log."│   or expired NGO tax filings.        │
│ • "We must never certify food safety │ • Gratified when monthly analytics   │
│   or take unwarranted liability."    │   show thousands of meals rescued.   │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ WHAT THEY SEE                        │ WHAT THEY HEAR                       │
│ • A growing queue of pending NGO     │ • Donors asking: "Are these shelters │
│   accreditation applications.        │   legitimate and legally compliant?" │
│ • Live telemetry of active donations,│ • Occasional dispute reports about   │
│   dispatches, and transit times.     │   unpunctual volunteers or no-shows. │
│ • Incident tickets regarding damaged │ • Executives asking for verified CSR │
│   boxes or temperature complaints.   │   impact figures for reports.        │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ WHAT THEY SAY AND DO                 │ PAINS & FRUSTRATIONS                 │
│ • Cross-references submitted 80G/12A │ • Falsified or forged certificates   │
│   IDs against government registries. │   attempting to exploit free aid.    │
│ • Suspends abusive accounts and logs │ • Lack of factual data during donor- │
│   justification notes.               │   volunteer handover disputes.       │
│ • Monitors real-time bottlenecks     │ • Risk of private donor addresses    │
│   where food is nearing expiration.  │   being leaked publicly.             │
├──────────────────────────────────────┴──────────────────────────────────────┤
│ GAINS & VALUE SOUGHT                                                        │
│ • Dedicated split-screen verification console with embedded PDF previewer.  │
│ • Immutable chronological audit ledger capturing actor ID and state diffs.  │
│ • Global oversight dashboards with real-time operational health indicators. │
│ • Quick moderation toggles with mandatory audit note enforcement.           │
└─────────────────────────────────────────────────────────────────────────────┘
```

