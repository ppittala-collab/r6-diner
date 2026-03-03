# Digital Maitre d' — MVP+ Backlog

**Last Updated:** 2026-03-03

Items in this document are out of scope for the current MVP build. They are organized by theme and prioritized by impact. Each item includes the rationale for deferral and any prerequisites that must be in place first.

---

## Priority 1 — Deferred from PRD (Verified Out of Current Scope)

These were explicitly in the original PRD but removed during verification because they lacked complete integration points. They are the closest to production-ready and should be picked up first after MVP launch.

### 1.1 Yield Management — `Account.Peak_Load_Window__c`

**Original spec:** Text field (e.g., "Fri/Sat 7pm-9pm") for proactive yield management.

**Why deferred:** No FSM path, trigger, or action references this field. "Yield management" behavior was never defined — it's unclear whether it should affect slot pricing, availability messaging, or agent tone.

**MVP+ scope:**
- Define yield management behavior: what happens during peak windows?
  - Option A: Agent warns diners of high-demand periods and suggests alternatives
  - Option B: Inventory buffer increases automatically during peak windows
  - Option C: Premium pricing or deposit requirements kick in
- Add `Peak_Load_Window__c` (Text) to Account
- Wire into Path 1 (Transactional) and/or Path 3 (Concierge) with concrete transition logic
- Consider replacing free-text with a structured object (e.g., `Peak_Window__c` with Day, Start_Time, End_Time fields) for queryable scheduling

**Prerequisites:** MVP data model and Path 1/3 operational.

---

### 1.2 Region-Based Content Filtering — `Knowledge__kav.Geo_Scope__c` + `Contact.Region__c`

**Original spec:** Multi-Picklist on Knowledge articles restricting content by user region.

**Why deferred:** No `Contact.Region__c` field exists to match against. The filtering logic was never specified — it's a field with no counterpart and no path integration.

**MVP+ scope:**
- Add `Region__c` (Picklist) to Contact: e.g., `Northeast`, `Southeast`, `West Coast`, `Midwest`, `International`
- Restore `Geo_Scope__c` (Multi-Picklist) to Knowledge__kav with matching values
- Update Path 4 (Knowledge/RAG) retriever query to filter articles: `WHERE Geo_Scope__c INCLUDES :contactRegion`
- Define fallback: if no region-specific article exists, return the global version

**Prerequisites:** MVP Path 4 (Knowledge) operational. Contact field addition.

---

### 1.3 Multi-Summary Support — `AI_Generated_Summary__c`

**Original spec:** Listed alongside `AI_Summary__c` on Reservation__c, implying two summary fields.

**Why deferred:** Consolidated to `AI_Summary__c` since no distinct purpose was defined for a second summary field.

**MVP+ scope:**
- If the need arises for separate summaries (e.g., one LLM-generated, one agent-curated), re-introduce `AI_Generated_Summary__c` with clear ownership:
  - `AI_Summary__c`: Human-edited or agent-refined context for escalation handoff
  - `AI_Generated_Summary__c`: Raw LLM-generated conversation summary, immutable audit record
- Add comparison logic to detect drift between the two

**Prerequisites:** MVP Path 2 (Escalation) operational and human concierge feedback loop established.

---

## Priority 2 — Natural Extensions of MVP Paths

These features extend existing FSM paths with richer behavior. They require the MVP to be operational but are high-value enhancements.

### 2.1 Waitlist Management

**Scope:**
- New object: `Waitlist_Entry__c` with fields: `Contact__c`, `Restaurant__c`, `Desired_DateTime__c`, `Party_Size__c`, `Status__c` (Queued, Notified, Converted, Expired), `Priority__c`
- When Path 1 finds no available slots, offer to add the diner to the waitlist instead of a flat refusal
- Automated flow: when a `Restaurant_Slot__c` changes from Reserved to Available, scan waitlist and notify the top match
- Membership-aware priority: Platinum > Gold > Silver in queue ordering

**Prerequisites:** MVP Path 1 and slot management operational.

---

### 2.2 Notification Flows (Email / SMS)

**Scope:**
- Reservation confirmation notifications on successful booking
- Reminder notifications 24 hours and 2 hours before `Reservation_DateTime__c`
- Waitlist promotion notifications ("A table just opened up!")
- Cancellation confirmation with re-booking prompt
- Channel preference field on Contact: `Notification_Preference__c` (Picklist: `Email`, `SMS`, `Both`)
- Respect `Comm_Style__c`: Brief diners get short messages, Concierge diners get richer detail

**Prerequisites:** MVP reservations operational. SMS requires Salesforce Messaging or external integration.

---

### 2.3 Deposit & Cancellation Fee Handling

**Scope:**
- New fields on Account: `Requires_Deposit__c` (Checkbox), `Deposit_Amount__c` (Currency), `Cancellation_Fee__c` (Currency), `Free_Cancel_Window_Hrs__c` (Number)
- Path 1 modification: if cancellation is within fee window, inform diner of the fee before confirming
- Membership override: Platinum members get fee waivers (already implied by `Membership_Level__c` but logic not built)
- Integration point for payment processing (Stripe, Salesforce Payments, etc.)

**Prerequisites:** MVP Path 1 operational. Payment gateway integration.

---

### 2.4 Advanced Allergy Support

**Scope:**
- Replace individual checkbox fields (`Allergy_Shellfish__c`, `Allergy_Nuts__c`) with a flexible model:
  - New object: `Diner_Allergy__c` (junction between Contact and a new `Allergen__c` reference object)
  - Supports arbitrary allergens: Dairy, Gluten, Soy, Eggs, etc.
  - Severity field: `Severity__c` (Picklist: `Preference`, `Intolerance`, `Anaphylaxis`)
- Update Account: replace `Safe_For_Allergies__c` multi-picklist with `Restaurant_Allergen_Cert__c` junction object
- Path 3 safety gate updates to query junction objects instead of hardcoded checkboxes
- Anaphylaxis-level allergies trigger Path 2 escalation regardless of restaurant certification

**Prerequisites:** MVP Path 3 safety gate operational. Data migration plan for existing checkbox data.

---

### 2.5 Review & Rating Integration

**Scope:**
- New fields on Account: `Average_Rating__c` (Number), `Review_Count__c` (Number), `Rating_Source__c` (Text)
- Path 3 Concierge incorporates ratings into recommendation ranking
- Agent can cite ratings: "La Maison has a 4.7 rating from 230 reviews"
- Optional: ingest external review data (Google, Yelp) via Data Cloud or scheduled API sync

**Prerequisites:** MVP Path 3 operational. External API integration if ingesting third-party reviews.

---

## Priority 3 — Platform & Operational Enhancements

These improve the operational backbone but aren't user-facing agent features.

### 3.1 Automated Slot Generation (Batch Apex / Scheduled Flow)

**Scope:**
- Scheduled job that generates `Restaurant_Slot__c` records N days into the future
- Uses `Account.Average_Turnover_Minutes__c` for slot duration
- Respects `Account.Blackout_Dates__c` — skips blocked dates
- Configurable look-ahead window per restaurant
- Handles DST transitions and holiday schedules

**Prerequisites:** MVP data model deployed.

---

### 3.2 Analytics & Reporting Dashboard

**Scope:**
- Custom Report Types: Reservations by Restaurant, Escalation Rate by Path, Agent Confidence Distribution
- Key metrics: booking conversion rate, escalation rate, average modification count, no-show rate
- `Logic_State__c` distribution analysis: how often is each confidence tier used?
- Sentiment trend tracking per diner and per restaurant
- Churn risk early warning dashboard

**Prerequisites:** MVP operational with sufficient data volume.

---

### 3.3 External POS / Availability API Sync

**Scope:**
- Real-time or near-real-time sync with restaurant POS systems
- Auto-update `Data_Last_Verified__c` and `Reliability_Score__c` on successful sync
- Error handling: if sync fails, degrade `Logic_State__c` automatically
- Support for OpenTable, Resy, or custom POS APIs via Named Credentials

**Prerequisites:** MVP operational. Named Credential and External Service setup.

---

### 3.4 Multi-Language Agent Support

**Scope:**
- Detect diner language from conversation or Contact preference field
- Knowledge articles with language variants (Translation Workbench or multi-language knowledge)
- Agent persona prompt translated per language
- `Comm_Style__c` may need cultural adaptation beyond language

**Prerequisites:** MVP agent operational. Salesforce Translation Workbench enabled.

---

### 3.5 LWC Staff Dashboard

**Scope:**
- Real-time view of today's reservations per restaurant
- Pending approval queue for SPECULATIVE-state bookings (`Status__c = Pending_Staff_Approval`)
- One-click approve/reject with auto-notification to diner
- Escalated conversation viewer with `AI_Summary__c` display
- Table map visualization showing occupied/available slots

**Prerequisites:** MVP data model and reservations operational.

---

## Priority 4 — Future Vision

Long-horizon features that require significant platform investment.

### 4.1 Group / Multi-Table Bookings
Large party support spanning multiple tables with coordinated slot allocation.

### 4.2 Loyalty Program Engine
Points accrual, redemption, tier progression beyond static `Membership_Level__c`.

### 4.3 Dynamic Pricing
Time-of-day and demand-based pricing adjustments using `Peak_Load_Window__c` and booking velocity.

### 4.4 Voice Channel Support
Extend agent beyond chat to phone via Salesforce Voice or Amazon Connect integration.

### 4.5 Predictive No-Show Model
ML model using `Lifetime_No_Show_Count__c`, booking patterns, and weather data to predict no-shows and enable overbooking strategy.
