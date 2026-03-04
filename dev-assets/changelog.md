# Digital Maitre d' — Changelog & Project State

**Last Updated:** 2026-03-03

---

## Current Project State

**Phase:** Data model deployed + seed data loaded — Apex, Flows, and Agentforce config pending
**SFDX API Version:** 65.0
**Target Org:** `r6pitt1` / `ppitt@sls.com` / `orgfarm-e87794c034.my.salesforce.com`
**Git:** Initialized, initial commit on `main`, remote at `github.com/ppittala-collab/r6-diner`

### What Exists

| Asset | Status | Notes |
|---|---|---|
| `sfdx-project.json` | Ready | API 65.0, default package directory `force-app` |
| `config/project-scratch-def.json` | Needs update | Missing features for Agentforce, Data Cloud |
| `manifest/package.xml` | Verified | 49 fields, 3 custom objects, 1 permission set; `FAQ__kav` (org article type) |
| `dev-assets/prd.txt` | Deployment-ready | v2.1, all fields fully specified |
| `dev-assets/changelog.md` | Active | This file |
| `dev-assets/mvp-plus-backlog.md` | Active | Deferred items organized by priority |
| Object metadata (XML) | Deployed | 49 field-meta.xml + 3 object-meta.xml + 1 settings file |
| Permission set | Deployed | `R6_Diner_Admin` — full FLS for all custom fields + object CRUD |
| Knowledge settings | Deployed | `force-app/main/default/settings/Knowledge.settings-meta.xml` |
| Seed data script | Executed | `scripts/apex/masterSetup.apex` v3.0 — all records seeded in r6pitt1 |
| Apex classes | Deployed | `ReservationManager.cls` — Path 1 Transactional (Modify/Cancel) |
| Flows | Not created | `Route_to_Human_Flow` specified in PRD |
| Agentforce config | Not created | Topics, actions, persona prompt all pending |
| Knowledge articles | Seeded | 14 FAQ__kav articles (10 Policy, 2 Parking, 2 Internal/Restricted PII) published |
| Menu content | Seeded | 10 ContentVersion files with allergen-enriched menus |
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

---

### 2026-03-03 — SFDX Metadata Creation & Org Deployment

Generated all SFDX source-format metadata XML files and deployed to the `r6pitt1` org.

#### Files Created (56 total)

| Category | Files | Details |
|---|---|---|
| Custom object definitions | 3 | `Reservation__c` (AutoNumber RES-{00000}), `Restaurant_Table__c` (Text name), `Restaurant_Slot__c` (AutoNumber SLOT-{00000}) |
| Account fields | 15 | All field-meta.xml under `force-app/main/default/objects/Account/fields/` |
| Contact fields | 10 | All field-meta.xml under `force-app/main/default/objects/Contact/fields/` |
| Reservation__c fields | 11 | Includes lookups to Contact, Account, Restaurant_Slot__c, and self-referential |
| Restaurant_Table__c fields | 4 | Includes lookup to Account |
| Restaurant_Slot__c fields | 3 | Includes lookup to Restaurant_Table__c |
| Knowledge__kav fields | 6 | Canonical PRD reference (not deployed — see FAQ__kav below) |
| FAQ__kav fields | 6 | Copy of Knowledge__kav fields targeting org's actual article type |
| Knowledge settings | 1 | `Knowledge.settings-meta.xml` enabling Knowledge in org |

#### Project Structure Changes

| Change | Details |
|---|---|
| `package.xml` moved | From `force-app/main/default/objects/package.xml` to `manifest/package.xml` (standard SFDX location) |
| Git initialized | Repo on `main` branch, remote added at `github.com/ppittala-collab/r6-diner` |
| Initial commit | 24 files, 974 insertions — all scaffold + PRD + tracking docs |

#### Deployment Results — `r6pitt1` org

| Attempt | Components | Result | Notes |
|---|---|---|---|
| Deploy 1 (all source) | 47/53 | Partial | 6 Knowledge__kav fields failed — `Knowledge__kav` entity not found |
| Deploy 2 (Knowledge settings) | 1/1 | Success | Enabled Knowledge in org |
| Deploy 3 (Knowledge__kav fields) | 0/6 | Failed | Org uses Classic Knowledge article type `FAQ__kav`, not `Knowledge__kav` |
| Deploy 4 (FAQ__kav fields) | 6/6 | Success | All fields deployed to `FAQ__kav` |
| **Final state** | **53/53** | **All deployed** | |

#### Knowledge Article Type Note

The `r6pitt1` org has a Classic Knowledge article type `FAQ__kav` (API name `FAQ`). Lightning Knowledge was enabled but the pre-existing article type retained its API name. The PRD references `Knowledge__kav`; the source tree contains both directories:
- `force-app/main/default/objects/Knowledge__kav/` — canonical PRD reference
- `force-app/main/default/objects/FAQ__kav/` — org-specific copy used for deployment

---

### 2026-03-03 — Seed Data Script v3.0 (masterSetup.apex)

Complete rewrite of `scripts/apex/masterSetup.apex` from v2.1 to v3.0. Every field in the PRD is now populated with test-relevant data, and all 4 FSM paths have dedicated test scenarios.

#### Accounts (10) — Enriched

| Change | Details |
|---|---|
| `Blackout_Dates__c` added | Le Petit Bistro and Steak & Stone now have blackout dates (holidays) |
| `Last_Menu_Update__c` added | All 10 restaurants — was missing entirely |
| `Safe_For_Allergies__c` enriched | Le Petit Bistro=Shellfish-free, Pasta Palace=Nut-free, Sushi Zen=Nut-free, Vibe Vegan=Nut-free;Shellfish-free |
| `Primary_Safety_Tag__c` expanded | Added HACCP Compliant to Steak & Stone (all 3 PRD values now used) |
| Missing fields filled | `Grace_Period_Mins__c`, `Reliability_Reason__c`, `Inventory_Buffer_Type__c` populated on all 10 |

#### Tables (32) — Fixed and expanded

| Change | Details |
|---|---|
| **Name field added** | Was missing — would have caused insert failure (Name is required Text field) |
| Extended to all restaurants | Was 3 restaurants (9 tables), now all 10 (30 base + 2 Patio) |
| Patio type added | Vibe Vegan and Taco Tequila — all 4 Table_Type picklist values now used |

#### Slots (256) — Doubled

| Change | Details |
|---|---|
| Future date coverage | Now generates today + next week slots (was today only) |
| All restaurants covered | Was only 3 restaurants, now all 10 have bookable inventory |

#### Contacts (10) — Enriched profiles

| Change | Details |
|---|---|
| James Whitfield (new) | Platinum + Leisurely/Concierge + positive sentiment — concierge upsell testing |
| Priya Kapoor (new) | `Lifetime_No_Show_Count__c=4` — booking block threshold (>= 3) testing |
| 5 varied diners (new) | Replaced 7 generic TestUser contacts with 5 named diners with diverse profiles |
| All Contact fields populated | Every named diner has cuisine preference, comm style, membership, trust tolerance, sentiment |

#### Reservations (5) — Full path coverage

| # | Test Scenario | Was in v2.1? |
|---|---|---|
| 0 | Locked gate (Is_Locked=TRUE, 45 min away) | Yes |
| 1 | Modifiable + DEGRADED state (Assigned_Table_Slot now set) | Yes — fixed missing slot |
| 2 | Pending Staff Approval at SPECULATIVE restaurant | **New** |
| 3 | Modification_Count=4 escalation trigger | **New** |
| 4 | Platinum VIP at DETERMINISTIC restaurant | **New** |

#### Knowledge (14 articles) — Full type and PII coverage

| Change | Details |
|---|---|
| Policy content rewritten | Rich HTML with allergen notices, dress codes, amenities, membership perks |
| Varying confidence scores | Forgotten Fondue=0.35 (Draft), Burger Joint=0.60, rest=0.95 (Official) |
| Parking articles (new, 2) | Le Petit Bistro and Steak & Stone |
| Internal PII article (new) | VIP handling procedures — Einstein Trust Layer test |
| Restricted PII article (new) | Emergency allergy protocols — highest PII tier test |
| Stale policy (Forgotten Fondue) | `Policy_Effective_Date__c` set to 180 days ago |

#### Menus (10 ContentVersions) — Allergen-enriched

| Change | Details |
|---|---|
| 4 detailed menus | Le Petit Bistro, Pasta Palace, Sushi Zen, Vibe Vegan — realistic items with allergen tags |
| Allergen tags | `[NUT-FREE]`, `[SHELLFISH-FREE]`, `Contains: Dairy, Gluten` throughout |
| Format changed | `.txt` extension (was `.pdf` but content was plain text) |

---

### 2026-03-03 — Full Metadata Redeployment & Data Seeding

Previous deployment had `rollbackOnError=true` and the single `FAQ__kav` CustomObject error rolled back all 48 other components. This session resolved multiple deployment blockers.

#### Deployment Fixes

| Issue | Root Cause | Fix |
|---|---|---|
| `package.xml` referenced `Knowledge__kav` | Org uses Classic Knowledge article type `FAQ__kav` | Changed all `Knowledge__kav` references to `FAQ__kav` in package.xml |
| `FAQ__kav` in `CustomObject` type caused rollback | Knowledge article types can't be deployed as CustomObject (already managed by Knowledge settings) | Removed `FAQ__kav` from CustomObject members |
| `Account` and `Contact` in `CustomObject` type | Standard objects — harmless warnings but unnecessary | Removed from CustomObject members |
| Fields deployed but invisible to Apex | Field Level Security (FLS) not granted to user profile | Created `R6_Diner_Admin` PermissionSet |
| Required fields in PermissionSet caused errors | Required/master-detail fields can't have FLS in permission sets | Removed 8 required fields from PermissionSet |
| Formula fields (`Logic_State__c`, `Is_Locked__c`) not queryable | Formula fields need `readable=true` in PermissionSet | Added formula fields with `editable=false`, `readable=true` |

#### Deployment Result — Deploy ID: `0Afaj00000W8mzVCAR`

53/53 components deployed: 49 custom fields, 3 custom objects, 1 permission set (all Succeeded).

#### Seed Data Execution — `masterSetup.apex` v3.0

| Object | Records | Status |
|---|---|---|
| Account (restaurants) | 10 | Inserted |
| Restaurant_Table__c | 32 | Inserted |
| Restaurant_Slot__c | 256 | Inserted |
| Contact (diners) | 10 | Inserted |
| Reservation__c | 5 | Inserted |
| FAQ__kav (articles) | 14 | Inserted + Published |
| ContentVersion (menus) | 10 | Inserted |

#### Logic_State__c Formula Verification

All 5 calibrated confidence states confirmed working:

| Logic State | Restaurant | Score | Verified |
|---|---|---|---|
| DETERMINISTIC | Le Petit Bistro, Curry House, Steak & Stone | 5 | < 4 hrs ago |
| PROBABILISTIC | Pasta Palace, Vibe Vegan, Taco Tequila, Dim Sum Garden | 3–4 | < 24 hrs ago |
| DEGRADED | Sushi Zen | 5 | 2 days ago |
| SPECULATIVE | The Burger Joint | 2 | 2 hrs ago |
| STALE | Forgotten Fondue | 4 | 10 days ago |

#### Is_Locked__c Formula Verification

| Reservation | Is_Locked | Why |
|---|---|---|
| Sofia @ Le Petit Bistro (45 min out) | TRUE | Reservation_DateTime - NOW() < 1 hr |
| All others | FALSE | > 1 hr from now |

#### New Artifact: R6_Diner_Admin PermissionSet

`force-app/main/default/permissionsets/R6_Diner_Admin.permissionset-meta.xml`

Grants full CRUD on `Reservation__c`, `Restaurant_Table__c`, `Restaurant_Slot__c` and read/edit FLS on all non-required, non-formula custom fields. Formula fields are read-only. Required fields excluded (auto-visible).

---

### 2026-03-03 — ReservationManager.cls (Path 1: Transactional)

First Apex class deployed: `force-app/main/default/classes/ReservationManager.cls`

#### What It Does

`@InvocableMethod` named **Modify Reservation Slot** — the Agentforce-callable action for Path 1 (Transactional Modify/Cancel). Accepts a `reservationId` and `newStartTime`, performs an atomic slot swap with full audit trail.

#### Gates Implemented

| Gate | Field | Threshold | Response Code |
|---|---|---|---|
| 1-Hour Lockout | `Is_Locked__c` (formula) | `TRUE` | `MODIFICATION_DENIED` |
| Modification Loop | `Modification_Count__c` | >= 3 | `ESCALATION_REQUIRED` |

#### Slot Matching Logic

Queries `Restaurant_Slot__c` where:
- `Slot_Start_Time__c` matches requested time
- `Table__r.Restaurant__c` matches original restaurant
- `Table__r.Capacity__c >= Party_Size__c` (closest fit via ASC sort)
- `Status__c = 'Available'`

#### Atomic Swap Sequence

1. Release old slot (`Status__c = 'Available'`)
2. Reserve new slot (`Status__c = 'Reserved'`)
3. Cancel old reservation (`Status__c = 'Cancelled'`)
4. Insert new reservation linked via `Original_Reservation_Id__c`

#### Fix Applied

Removed inline `//` comment from SOQL `ORDER BY` clause (would have caused compilation failure).

#### Deploy: `0Afaj00000W8jAQCAZ` — 54/54 Succeeded
