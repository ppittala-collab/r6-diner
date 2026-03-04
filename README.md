# R6 Diner — Digital Maitre d' Agent

An Agentforce-powered restaurant reservation system built on Salesforce. The agent uses a Finite State Machine (FSM) with calibrated confidence logic to handle reservations, personalized recommendations, human escalation, and knowledge retrieval across a network of restaurants.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Agentforce Agent                         │
│                  "Digital Maitre d'"                        │
├──────────┬──────────┬──────────────┬────────────────────────┤
│  Path 1  │  Path 2  │   Path 3     │        Path 4          │
│ Transact │ Escalate │  Concierge   │     RAG/Knowledge      │
│ Modify/  │ Human    │  Recommend   │     FAQ/Menu/Policy    │
│ Cancel   │ Handoff  │  + Upsell    │                        │
├──────────┴──────────┴──────────────┴────────────────────────┤
│           Calibrated Confidence Engine                      │
│   Logic_State__c: DETERMINISTIC | PROBABILISTIC |           │
│                   DEGRADED | SPECULATIVE | STALE            │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

- **Salesforce CLI (sf)** v2.x+ — [Install guide](https://developer.salesforce.com/tools/salesforcecli)
- **A Salesforce org** with:
  - Salesforce Knowledge enabled (Setup > Knowledge Settings)
  - At least one Knowledge article type (the default `FAQ__kav` or `Knowledge__kav`)
- **Node.js** 18+ (for linting/formatting tooling, optional)

Verify your CLI installation:

```bash
sf version
```

## Project Structure

```
r6_diner_agent/
├── force-app/main/default/
│   ├── classes/                    # Apex classes
│   │   └── ReservationManager.cls  # Path 1: Transactional modify/cancel
│   ├── objects/                    # Custom objects & fields
│   │   ├── Account/fields/        # 15 custom fields (restaurant metadata)
│   │   ├── Contact/fields/        # 10 custom fields (diner profile)
│   │   ├── Reservation__c/        # Object + 11 fields (transaction record)
│   │   ├── Restaurant_Table__c/   # Object + 4 fields (physical asset)
│   │   ├── Restaurant_Slot__c/    # Object + 3 fields (temporal inventory)
│   │   └── FAQ__kav/fields/       # 6 custom fields (RAG content)
│   ├── permissionsets/
│   │   └── R6_Diner_Admin.permissionset-meta.xml
│   └── settings/
│       └── Knowledge.settings-meta.xml
├── manifest/
│   └── package.xml                # Deployment manifest (49 fields, 3 objects, 1 class, 1 permset)
├── scripts/apex/
│   └── masterSetup.apex           # One-time seed data script (v3.0)
├── dev-assets/
│   ├── prd.txt                    # Product Requirements Document (v2.1)
│   ├── changelog.md               # Full change history
│   └── mvp-plus-backlog.md        # Deferred features backlog
└── sfdx-project.json              # API version 65.0
```

## Setup Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/ppittala-collab/r6-diner.git
cd r6-diner/r6_diner_agent
```

### Step 2: Authenticate to Your Org

```bash
sf org login web --alias my-r6-org --set-default
```

This opens a browser window. Log in with your Salesforce credentials.

### Step 3: Enable Knowledge (if not already enabled)

Salesforce Knowledge must be active before deploying Knowledge fields. Check Setup > Knowledge Settings in your org. If it's not enabled, the deployment will handle it via `Knowledge.settings-meta.xml`.

### Step 4: Identify Your Knowledge Article Type

This is the most common deployment issue. Different orgs use different Knowledge article type API names.

Run this query against your org to find yours:

```bash
sf data query \
  --query "SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE '%kav%' LIMIT 10" \
  --target-org my-r6-org \
  --use-tooling-api
```

**If your org returns `FAQ__kav`:** The repo is already configured — proceed to Step 5.

**If your org returns `Knowledge__kav`:** Update `manifest/package.xml` to replace all `FAQ__kav` references with `Knowledge__kav`:

```bash
# On macOS
sed -i '' 's/FAQ__kav/Knowledge__kav/g' manifest/package.xml
```

Then rename the metadata directory:

```bash
mv force-app/main/default/objects/FAQ__kav force-app/main/default/objects/Knowledge__kav
```

Also update `masterSetup.apex` — replace all `FAQ__kav` with `Knowledge__kav` throughout the script.

**If your org returns something else** (e.g., `Custom_Article__kav`): Apply the same substitution with your article type name.

### Step 5: Deploy Metadata

```bash
sf project deploy start \
  --manifest manifest/package.xml \
  --target-org my-r6-org
```

Expected result: **54/54 components Succeeded** (49 fields, 3 custom objects, 1 Apex class, 1 permission set).

**Troubleshooting — Common deployment errors:**

| Error | Cause | Fix |
|---|---|---|
| `Entity 'FAQ__kav' not found` | Knowledge not enabled, or article type name differs | See Step 3 and Step 4 |
| `Must specify a non-empty label for the CustomObject` | A Knowledge article type listed under `CustomObject` in package.xml | Remove the `__kav` entry from the `<name>CustomObject</name>` section |
| Deployment "Succeeded" but 0 fields visible in Apex | `rollbackOnError=true` silently rolled back all components due to one failure | Check the deploy report: `sf project deploy report --job-id <ID>` |

### Step 6: Assign the Permission Set

The `R6_Diner_Admin` permission set grants Field Level Security (FLS) for all custom fields. Without it, fields exist in the org but are invisible to your user and to Apex.

```bash
sf org assign permset \
  --name R6_Diner_Admin \
  --target-org my-r6-org
```

Assign to any additional users who need access:

```bash
sf org assign permset \
  --name R6_Diner_Admin \
  --target-org my-r6-org \
  --on-behalf-of user@example.com
```

### Step 7: Seed Test Data

The seed script creates a complete test ecosystem: 10 restaurants, 32 tables, 256 time slots, 10 diners, 5 reservations, 14 Knowledge articles, and 10 menus.

```bash
sf apex run \
  --file scripts/apex/masterSetup.apex \
  --target-org my-r6-org
```

**Important:** This is a one-time script. Running it again will create duplicate records. If you need to re-seed, delete the existing data first:

```bash
# Delete in dependency order (children before parents)
sf apex run --target-org my-r6-org -f /dev/stdin <<'EOF'
delete [SELECT Id FROM Reservation__c];
delete [SELECT Id FROM Restaurant_Slot__c];
delete [SELECT Id FROM Restaurant_Table__c];
delete [SELECT Id FROM Account WHERE Cuisine_Type__c != null];
delete [SELECT Id FROM Contact WHERE Cuisine_Preference__c != null];
EOF
```

Knowledge articles require separate cleanup through the Knowledge UI or by unpublishing and deleting via Apex.

### Step 8: Verify

Run these queries to confirm everything is in place:

```bash
# Accounts with formula field
sf data query \
  --query "SELECT Name, Logic_State__c, Reliability_Score__c FROM Account WHERE Cuisine_Type__c != null" \
  --target-org my-r6-org

# Contacts
sf data query \
  --query "SELECT FirstName, LastName, Membership_Level__c FROM Contact WHERE Cuisine_Preference__c != null" \
  --target-org my-r6-org

# Reservations with lock gate
sf data query \
  --query "SELECT Status__c, Party_Size__c, Is_Locked__c FROM Reservation__c" \
  --target-org my-r6-org

# Record counts
sf data query --query "SELECT COUNT(Id) FROM Restaurant_Table__c" --target-org my-r6-org
sf data query --query "SELECT COUNT(Id) FROM Restaurant_Slot__c" --target-org my-r6-org
```

Expected counts: 10 Accounts, 10 Contacts, 32 Tables, 256 Slots, 5 Reservations.

## Data Model

### Objects and Relationships

```
Account (Restaurant)
  ├── Restaurant_Table__c (1:M via Restaurant__c)
  │     └── Restaurant_Slot__c (1:M via Table__c)
  ├── Reservation__c (1:M via Restaurant__c)
  │     ├── Contact__c → Contact (Diner)
  │     ├── Assigned_Table_Slot__c → Restaurant_Slot__c
  │     └── Original_Reservation_Id__c → Reservation__c (self-ref audit)
  └── FAQ__kav (1:M via Restaurant_Lookup__c)

Contact (Diner)
  └── Reservation__c (1:M via Contact__c)
```

### Calibrated Confidence States

The `Account.Logic_State__c` formula field drives agent behavior:

| State | Condition | Agent Behavior |
|---|---|---|
| **DETERMINISTIC** | Score=5, verified < 4 hrs | Full auto-commit, authoritative tone |
| **PROBABILISTIC** | Score >= 3, verified <= 24 hrs | Auto-commit, cautious tone with timestamps |
| **DEGRADED** | Score=5, verified > 24 hrs | Commit with disclaimer |
| **SPECULATIVE** | Score 1-2 | Creates as `Pending_Staff_Approval` |
| **STALE** | Any score, verified > 7 days | Human handoff only (Path 2) |

## Seed Data Summary

The `masterSetup.apex` script creates test data covering all FSM paths:

| Category | Records | Test Coverage |
|---|---|---|
| Restaurants | 10 | All 5 Logic States, all Price Tiers, all Cuisine Types |
| Tables | 32 | Window, Booth, Standard, Patio; ADA mix |
| Slots | 256 | Today + next week; 4 slots per table per day |
| Diners | 10 | Silver/Gold/Platinum; allergy combos; churn risk; no-show history |
| Reservations | 5 | Locked, modifiable, pending approval, escalation trigger, VIP |
| Knowledge | 14 | Policy, Parking; PII Public/Internal/Restricted; confidence 0.35-1.00 |
| Menus | 10 | 4 detailed + 6 generic; allergen tags throughout |

## What's Next (Not Yet Built)

These components are referenced in the PRD but not yet implemented:

- **Route_to_Human_Flow** — Flow for Path 2 escalation routing to `Tier_2_Human_Concierge` queue
- **Agentforce Topics & Actions** — Agent configuration connecting the FSM paths
- **System Persona Prompt** — Flex Template embedding the Calibrated Confidence table
- **Data Cloud integration** — Unified Profile ingestion, Vector Search Index
- **Einstein Trust Layer config** — PII masking rules based on `PII_Sensitivity__c`

See `dev-assets/mvp-plus-backlog.md` for the full deferred features list.

## API Version

All metadata targets Salesforce API **v65.0**.

## License

Internal project — not licensed for external distribution.
