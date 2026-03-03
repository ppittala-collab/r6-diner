# Digital Maitre d' — Changelog & Project State

**Last Updated:** 2026-03-03

---

## Current Project State

**Phase:** Pre-build (Data model verified, no SFDX metadata files created yet)
**SFDX API Version:** 65.0
**Org Type:** Developer Edition scratch org

### What Exists

| Asset | Status | Notes |
|---|---|---|
| `sfdx-project.json` | Ready | API 65.0, default package directory `force-app` |
| `config/project-scratch-def.json` | Needs update | Missing features for Knowledge, Agentforce, Data Cloud |
| `package.xml` | Verified | 49 fields across 6 objects, aligned with PRD |
| `dev-assets/prd.txt` | Deployment-ready | v2.1, all fields have values, defaults, precision, char limits, formula syntax |
| Object metadata (XML) | Not created | No field/object definitions in `force-app/` yet |
| Apex classes | Not created | `ReservationManager.cls` specified in PRD |
| Flows | Not created | `Route_to_Human_Flow` specified in PRD |
| Agentforce config | Not created | Topics, actions, persona prompt all pending |
| Knowledge articles | Not created | Article types defined but no content |
| Test data scripts | Not created | Seed data for all objects pending |
| LWC components | Not created | None specified in current scope |

### Verified Field Inventory

#### Account (15 fields)

| Field | Type | Verified |
|---|---|---|
| `Cuisine_Type__c` | Picklist (10 values) | Yes — default: none (required) |
| `Vibe_Tags__c` | Multi-Picklist (8 values) | Yes — full value set defined |
| `Family_Friendly__c` | Checkbox | Yes — default: FALSE |
| `Safe_For_Allergies__c` | Multi-Picklist (2 values) | Yes — default: none |
| `Primary_Safety_Tag__c` | Picklist (3 values + None) | Yes — default: none |
| `Blackout_Dates__c` | Long Text Area (10000 chars) | Yes — JSON format specified |
| `Average_Turnover_Minutes__c` | Number (0 dp) | Yes — default: 90 |
| `Grace_Period_Mins__c` | Number (0 dp) | Yes — default: 15 |
| `Price_Tier__c` | Picklist (4 values) | Yes — default: $$ |
| `Last_Menu_Update__c` | DateTime | Yes |
| `Reliability_Score__c` | Number (0 dp) | Yes — range 1-5, default: 3 |
| `Data_Last_Verified__c` | DateTime | Yes |
| `Reliability_Reason__c` | Long Text Area (5000 chars) | Yes |
| `Inventory_Buffer_Type__c` | Percent (0 dp) | Yes — type resolved, range 0-100, default: 0 |
| `Logic_State__c` | Formula (Text) | Yes — formula fixed, AND() syntax |

#### Contact (10 fields)

| Field | Type | Verified |
|---|---|---|
| `Cuisine_Preference__c` | Picklist (10 values) | Yes — values explicitly listed, mirrors Account.Cuisine_Type__c |
| `Allergy_Shellfish__c` | Checkbox | Yes — default: FALSE |
| `Allergy_Nuts__c` | Checkbox | Yes — default: FALSE |
| `Family_Status__c` | Text (255 chars) | Yes |
| `Comm_Style__c` | Picklist (2 values) | Yes — default: Brief/Efficiency |
| `Membership_Level__c` | Picklist (3 values) | Yes — default: Silver, order corrected |
| `Trust_Tolerance__c` | Number (0 dp) | Yes — range 1-5, default: 3 |
| `Sentiment_Score__c` | Number (2 dp) | Yes — range -1.00 to 1.00, default: 0.00 |
| `Lifetime_No_Show_Count__c` | Number (0 dp) | Yes — default: 0, threshold >= 3 defined |
| `Churn_Risk__c` | Checkbox | Yes — default: FALSE |

#### Reservation__c (11 fields)

| Field | Type | Verified |
|---|---|---|
| `Status__c` | Picklist (5 values) | Yes — default: Confirmed |
| `Reservation_DateTime__c` | DateTime | Yes — required |
| `Is_Locked__c` | Formula (Checkbox) | Yes — description clarified (< 1hr), return type specified |
| `Assigned_Table_Slot__c` | Lookup → Restaurant_Slot__c | Yes |
| `Original_Reservation_Id__c` | Lookup → Reservation__c (self) | Yes |
| `Modification_Count__c` | Number (0 dp) | Yes — default: 0 |
| `Modification_History__c` | Long Text Area (10000 chars) | Yes |
| `AI_Summary__c` | Long Text Area (5000 chars) | Yes |
| `Contact__c` | Lookup → Contact | Yes — required |
| `Restaurant__c` | Lookup → Account | Yes — required |
| `Party_Size__c` | Number (0 dp) | Yes — min: 1, required |

#### Restaurant_Table__c (4 fields)

| Field | Type | Verified |
|---|---|---|
| `Restaurant__c` | Lookup → Account | Yes — required |
| `Capacity__c` | Number (0 dp) | Yes — min: 1, required |
| `Table_Type__c` | Picklist (4 values) | Yes — default: Standard |
| `ADA_Accessible__c` | Checkbox | Yes — default: FALSE |

#### Restaurant_Slot__c (3 fields)

| Field | Type | Verified |
|---|---|---|
| `Slot_Start_Time__c` | DateTime | Yes — required, increment source clarified |
| `Status__c` | Picklist (3 values) | Yes — default: Available |
| `Table__c` | Lookup → Restaurant_Table__c | Yes — required |

#### Knowledge__kav (6 fields)

| Field | Type | Verified |
|---|---|---|
| `Article_Type__c` | Picklist (3 values) | Yes — default: Policy |
| `Restaurant_Lookup__c` | Lookup → Account | Yes — optional (blank = global) |
| `Answer__c` | Rich Text Area (32000 chars) | Yes |
| `AI_Confidence_Score__c` | Number (2 dp) | Yes — range 0.00-1.00, default: 0.50, thresholds defined |
| `Policy_Effective_Date__c` | Date | Yes |
| `PII_Sensitivity__c` | Picklist (3 values) | Yes — default: Public, masking triggers defined |

---

## Change Log

### 2026-03-03 — PRD Verification & Reconciliation

#### Fields Removed (3)

| Field | Reason |
|---|---|
| `Account.Peak_Load_Window__c` | Not referenced in any FSM path. "Proactive yield management" has no defined trigger, action, or integration point. Moved to MVP+ backlog. |
| `Reservation__c.AI_Generated_Summary__c` | Duplicate of `AI_Summary__c`. Consolidated to single field. |
| `Knowledge__kav.Geo_Scope__c` | No corresponding `Contact` region field to match against. Incomplete design with no path integration. Moved to MVP+ backlog with prerequisite noted. |

#### Fields Added (7)

| Field | Reason |
|---|---|
| `Account.Average_Turnover_Minutes__c` | Was in package.xml but undocumented. Essential for slot generation cadence. Added to PRD. |
| `Account.Grace_Period_Mins__c` | Was in package.xml but undocumented. Needed for no-show flagging and lockout timing. Added to PRD. |
| `Account.Price_Tier__c` | Was in package.xml but undocumented. Enables budget-aware recommendations in Path 3. Added to PRD. |
| `Account.Last_Menu_Update__c` | Was in package.xml but undocumented. Drives RAG freshness checks in Path 4. Added to PRD. |
| `Reservation__c.Contact__c` | Relationship lookup was missing. Agent cannot retrieve a diner's reservations without it. |
| `Reservation__c.Restaurant__c` | Relationship lookup was missing. Reservation is orphaned without a restaurant link. |
| `Reservation__c.Party_Size__c` | PRD Apex action describes party-size vs Capacity validation, but no field existed to store the value. |
| `Restaurant_Table__c.Restaurant__c` | Relationship lookup was missing. Tables must be queryable per restaurant. |

#### Bugs Fixed (2)

| Issue | Resolution |
|---|---|
| `Logic_State__c` formula: DETERMINISTIC unreachable | PROBABILISTIC (`Score >= 3, freshness <= 1d`) was evaluated before DETERMINISTIC (`Score = 5, freshness <= 0.16d`). Since 5 >= 3 and 0.16d <= 1d, DETERMINISTIC could never match. Reordered evaluation: DETERMINISTIC now checked before PROBABILISTIC. |
| Confidence table: PROBABILISTIC too narrow | Description said "Score 3-4" but Score=5 with verification between 4hrs-24hrs correctly falls into PROBABILISTIC. Updated to "Score >= 3, excluding DETERMINISTIC". |

#### Config Fixes (1)

| Issue | Resolution |
|---|---|
| `package.xml` API version mismatch | Was `60.0`, mismatched with `sfdx-project.json` at `65.0`. Updated to `65.0`. |

---

### 2026-03-03 — Deployment Readiness Pass

All 49 fields across 6 objects audited for deployment completeness. Every picklist, checkbox, number, formula, and text field now has fully specified values.

#### Picklist Completions

| Field | Change |
|---|---|
| `Account.Cuisine_Type__c` | Marked as required at record creation |
| `Account.Vibe_Tags__c` | Replaced "e.g." with definitive 8-value set: `Romantic`, `Business-Quiet`, `Family-Friendly`, `Trendy`, `Casual`, `Upscale`, `Outdoor-Dining`, `Live-Music` |
| `Account.Primary_Safety_Tag__c` | Added explicit `--None--` option |
| `Account.Price_Tier__c` | Added default: `$$` |
| `Contact.Cuisine_Preference__c` | Listed all 10 values explicitly (was "Matches Account Cuisine Types") |
| `Contact.Comm_Style__c` | Added default: `Brief/Efficiency` |
| `Contact.Membership_Level__c` | Corrected order to `Silver`, `Gold`, `Platinum`; added default: `Silver` |
| `Reservation__c.Status__c` | Added default: `Confirmed` |
| `Restaurant_Table__c.Table_Type__c` | Added default: `Standard` |
| `Restaurant_Slot__c.Status__c` | Added default: `Available` |
| `Knowledge__kav.Article_Type__c` | Added default: `Policy` |
| `Knowledge__kav.PII_Sensitivity__c` | Added default: `Public`; documented masking trigger conditions |

#### Checkbox Defaults Added (6 fields)

All checkboxes now explicitly default to `FALSE`: `Family_Friendly__c`, `Allergy_Shellfish__c`, `Allergy_Nuts__c`, `Churn_Risk__c`, `ADA_Accessible__c`.

#### Number Field Precision & Defaults (10 fields)

| Field | Decimal Places | Default | Range/Min |
|---|---|---|---|
| `Average_Turnover_Minutes__c` | 0 | 90 | — |
| `Grace_Period_Mins__c` | 0 | 15 | — |
| `Reliability_Score__c` | 0 | 3 | 1–5 |
| `Trust_Tolerance__c` | 0 | 3 | 1–5 |
| `Sentiment_Score__c` | 2 | 0.00 | -1.00 to 1.00 |
| `Lifetime_No_Show_Count__c` | 0 | 0 | >= 3 blocks bookings |
| `Modification_Count__c` | 0 | 0 | > 3 triggers escalation |
| `Party_Size__c` | 0 | — | Min: 1 |
| `Capacity__c` | 0 | — | Min: 1 |
| `AI_Confidence_Score__c` | 2 | 0.50 | 0.00–1.00; >= 0.80 = Official, < 0.50 = Draft |

#### Text/Long Text Character Limits (6 fields)

| Field | Limit |
|---|---|
| `Family_Status__c` | 255 chars |
| `Blackout_Dates__c` | 10000 chars |
| `Reliability_Reason__c` | 5000 chars |
| `Modification_History__c` | 10000 chars |
| `AI_Summary__c` | 5000 chars |
| `Answer__c` | 32000 chars |

#### Type Ambiguity Resolved (1 field)

| Field | Change |
|---|---|
| `Inventory_Buffer_Type__c` | Was "Percent/Picklist" (ambiguous). Resolved to **Percent** with 0 decimal places, range 0–100, default 0 |

#### Formula Syntax Fixes (1 field)

| Field | Change |
|---|---|
| `Logic_State__c` | Replaced `&&` with Salesforce-standard `AND()` function syntax |

#### Required Fields Marked (8 fields)

`Reservation_DateTime__c`, `Contact__c`, `Restaurant__c`, `Party_Size__c` (on Reservation__c), `Restaurant__c`, `Capacity__c` (on Restaurant_Table__c), `Slot_Start_Time__c`, `Table__c` (on Restaurant_Slot__c).
