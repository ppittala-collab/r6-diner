# Agentforce Setup Checklist — Manual Steps

Everything below requires the Salesforce UI (Setup or Agent Builder). These steps cannot be automated via SFDX metadata deployment.

---

## Prerequisites (already done)

- [x] Metadata deployed (58 fields, 4 custom objects, 2 Apex classes, 1 permission set, 6 prompt templates)
- [x] Knowledge enabled, FAQ__kav article type active
- [x] Seed data loaded (MasterSetup.apex + seedMenuItems.apex)
- [x] R6_Diner_Admin permission set assigned
- [x] Apex classes deployed: `ReservationManager`, `QueryMenuItems`, `VerifyPasscode`, `GetAuthPasscodeMessage`, `DetermineEscalationPriority`, `EvaluateHardGates` (ResolveRestaurantName removed — uses Data Library instead)
- [x] Prompt templates deployed: `Intent_Classifier`, `Restaurant_Policy_QA`, `Menu_Retrieval_QA`, `Restaurant_Directory_QA`, `Escalation_Handler`, `Ambiguous_Clarifier` (Auth_Passcode_Prompt replaced by GetAuthPasscodeMessage Apex)

---

## Step 1: Enable Agentforce

**Where:** Setup → Agents → Agent Studio (or Setup → Einstein → Agentforce)

- [ ] Verify Agentforce is enabled in your org
- [ ] Verify Einstein Generative AI is turned on (Setup → Einstein → Einstein Setup)

---

## Step 2: Create the Agent

**Where:** Setup → Agents → New Agent

- [ ] **Label:** `R6 Diner Knowledge & FAQ Agent`
- [ ] **API Name:** `R6_Diner_Knowledge_Agent`
- [ ] **Description:** Path 4 agent handling restaurant information queries via Knowledge articles, structured Menu_Item__c data, and ContentVersion menus
- [ ] **Channel:** Messaging (or whichever channel you're using)

---

## Step 3: Configure System Instructions

**Where:** Agent Builder → your agent → System Instructions

- [ ] Paste the system instructions from `path4_knowledge_agent.agentScript` (system.instructions block)
- [ ] This sets the orchestrator identity, tone, calibrated confidence engine, safety rules, and hard gates
- [ ] **Key change:** The system prompt now says "You ORCHESTRATE — you do not answer questions directly." The detailed reasoning and formatting logic has moved to Prompt Templates.

---

## Step 4: Configure Prompt Templates

Prompt Templates contain ALL reasoning logic. The agent script is purely an orchestrator — it gathers data and delegates to the correct template. Every topic has a corresponding template.

**Architecture:**

```
Agent Script (Pure Orchestration)
     │
     ▼
┌─────────────────────────────────────────────────────────────────┐
│ Topic Selector                                                   │
│   └── Action: Evaluate Hard Gates (Apex) → if NONE, then        │
│   └── Prompt Template: Intent Classifier                         │
│         Classifies across all 4 FSM paths (gates done by Apex)   │
│         Returns: ROUTE + TRUST_GAP + FSM_STATE + RESTAURANT_HINT │
├──────────────────────┬──────────────────────────────────────────┤
│                      ▼                                           │
│ Restaurant Info (Router) ─┬── Prompt Template: Policy QA         │
│                           ├── Prompt Template: Menu QA           │
│                           └── Prompt Template: Directory QA      │
├──────────────────────────────────────────────────────────────────┤
│ Auth Required ───────────── Action: Get Auth Passcode Message     │
│                             (Apex — no LLM) Passcode gate         │
├──────────────────────────────────────────────────────────────────┤
│ Escalation ──────────────── Action: Determine Escalation Priority (Apex) │
│                             + Prompt: Escalation Handler         │
│                             Returns: AI_SUMMARY + DINER_MESSAGE   │
├──────────────────────────────────────────────────────────────────┤
│ Ambiguous ───────────────── Prompt: Ambiguous Clarifier                 │
│                             Uses Data Library retrieval (same as Policy/Menu/Directory) │
├──────────────────────────────────────────────────────────────────┤
│ Off Topic ──────────────── (no template — static guardrail)      │
└──────────────────────────────────────────────────────────────────┘
```

**Best practice stack:**

| Layer | Tool | What It Does |
|---|---|---|
| Data | Knowledge + Menu_Item__c + Data Library | Raw information |
| Retrieval | Apex Actions + Native Get Record + RAG | Fetching data |
| Reasoning | 6 Prompt Templates + Apex (gates, resolver) | Interpreting data + formatting responses |
| Orchestration | Agent Script Topics | Routing + transitions + variable management |

### 4a: Verify Prompt Template Deployment

**Where:** Setup → Prompt Builder

- [ ] Verify all 6 templates appear in Prompt Builder:
  - `Intent Classifier`
  - `Restaurant Policy QA`
  - `Menu Retrieval QA`
  - `Restaurant Directory QA`
  - `Escalation Handler`
  - `Ambiguous Clarifier`
- [ ] Auth gate uses Apex action `Get Auth Passcode Message` (not a prompt template)
- [ ] If not deployed via metadata, create them manually using the content from the `.genAiPromptTemplate-meta.xml` files in `force-app/main/default/genAiPromptTemplates/`

### 4b: Intent Classifier Template

**Where:** Setup → Prompt Builder → Intent Classifier

- [ ] **Type:** Flex Template
- [ ] **FSM Role:** Entry point — classifies intent across all 4 paths
- [ ] **Verify inputs are mapped:**

| Input | Type | Required | Source |
|---|---|---|---|
| `user_message` | String | Yes | Diner's current message |
| `contact_summary` | String | No | JSON from Get Diner Profile action |
| `conversation_context` | String | No | Prior turn summary |

- [ ] **What it returns:** ROUTE (8 possible values), HARD_GATE, TRUST_GAP, FSM_STATE, RESTAURANT_HINT, ACKNOWLEDGMENT
- [ ] **What it handles:** FSM path classification, hard gate checks (no-show block, sentiment, churn risk, trust mismatch), Path 1/3 stub routing

### 4c: Restaurant Policy QA Template

**Where:** Setup → Prompt Builder → Restaurant Policy QA

- [ ] **Type:** Flex Template
- [ ] **FSM State:** S5_Strict_RAG (Path 4)
- [ ] **Related Entity:** Account (optional)
- [ ] **Verify inputs are mapped:**

| Input | Type | Required | Source |
|---|---|---|---|
| `restaurant_name` | String | Yes | Account.Name from Get Restaurant |
| `user_question` | String | Yes | Diner's message |
| `logic_state` | String | Yes | Account.Logic_State__c |
| `knowledge_articles` | String | Yes | FAQ__kav content from Data Library RAG |
| `comm_style` | String | No | Contact.Comm_Style__c |
| `trust_gap` | String | No | true/false from orchestrator |
| `membership_level` | String | No | Contact.Membership_Level__c |

- [ ] **What it handles:** PII gate, confidence scoring, policy freshness, Logic_State calibration, trust gap disclosure
- [ ] **Transitions:** May return TRANSITION: ESCALATE (STALE, Internal PII)

### 4d: Menu Retrieval QA Template

**Where:** Setup → Prompt Builder → Menu Retrieval QA

- [ ] **Type:** Flex Template
- [ ] **FSM State:** S5_Strict_RAG (Path 4) with S2 safety gate crossover
- [ ] **Related Entity:** Account (optional)
- [ ] **Verify inputs are mapped:**

| Input | Type | Required | Source |
|---|---|---|---|
| `restaurant_name` | String | Yes | Account.Name |
| `user_question` | String | Yes | Diner's message |
| `logic_state` | String | Yes | Account.Logic_State__c |
| `menu_items` | String | Yes | JSON from QueryMenuItems Apex |
| `allergy_shellfish` | String | No | Contact.Allergy_Shellfish__c |
| `allergy_nuts` | String | No | Contact.Allergy_Nuts__c |
| `comm_style` | String | No | Contact.Comm_Style__c |
| `trust_gap` | String | No | true/false |
| `membership_level` | String | No | Contact.Membership_Level__c |

- [ ] **What it handles:** Allergen safety gate, inventory freshness, availability filtering, membership upsell, chef picks
- [ ] **Transitions:** May return TRANSITION: ESCALATE (allergen concern, STALE)

### 4e: Restaurant Directory QA Template

**Where:** Setup → Prompt Builder → Restaurant Directory QA

- [ ] **Type:** Flex Template
- [ ] **FSM State:** S5_Strict_RAG (Path 4)
- [ ] **Verify inputs are mapped:**

| Input | Type | Required | Source |
|---|---|---|---|
| `user_question` | String | Yes | Diner's message |
| `restaurant_data` | String | Yes | From Data Library grounding files |
| `comm_style` | String | No | Contact.Comm_Style__c |
| `membership_level` | String | No | Contact.Membership_Level__c |
| `contact_summary` | String | No | JSON for personalization |

- [ ] **What it handles:** Directory listing, cuisine/allergen/family filtering, profile-based personalization
- [ ] **Transitions:** May return TRANSITION: ROUTE_CONCIERGE or ESCALATE

### 4f: Get Auth Passcode Message Action (replaces Auth Passcode Prompt)

**Where:** Agent Builder → Actions → Register Apex Action

- [ ] **Action:** Register `GetAuthPasscodeMessage` Apex class (label: Get Auth Passcode Message)
- [ ] **Inputs:** `isGuest` (Boolean), `retryAfterFail` (Boolean), `commStyle` (String)
- [ ] **Returns:** `message` (String)
- [ ] **FSM Role:** Auth gate — deterministic passcode request message (no LLM call)

### 4g: Escalation Handler Template

**Where:** Setup → Prompt Builder → Escalation Handler

- [ ] **Type:** Flex Template
- [ ] **FSM State:** S3_Circuit_Breaker (Path 2) — only invoked when is_authenticated=true
- [ ] **Verify inputs are mapped:**

| Input | Type | Required | Source |
|---|---|---|---|
| `is_authenticated` | String | Yes | true (orchestrator only routes here when authenticated) |
| `escalation_trigger` | String | Yes | EscalationReason variable |
| `routing_priority` | String | Yes | From Determine Escalation Priority action (CRITICAL/VIP/HIGH/STANDARD) |
| `routing_flags` | String | Yes | From Determine Escalation Priority action (comma-separated flags) |
| `contact_summary` | String | Yes | JSON from Get Diner Profile |
| `conversation_summary` | String | Yes | Built by orchestrator |
| `restaurant_name` | String | No | Account.Name |
| `logic_state` | String | No | Account.Logic_State__c |
| `reservation_summary` | String | No | Reservation JSON if applicable |
| `comm_style` | String | No | Contact.Comm_Style__c |

- [ ] **What it returns:** AI_SUMMARY (→ AI_Summary__c), ROUTING (echoes priority/flags), DINER_MESSAGE
- [ ] **What it handles:** Context summarization, warm handoff message. Priority/flags come from Determine Escalation Priority Apex.

### 4h: Ambiguous Clarifier Template

**Where:** Setup → Prompt Builder → Ambiguous Clarifier

- [ ] **Type:** Flex Template
- [ ] **FSM Role:** Pre-classification disambiguation — uses Data Library retrieval (same as Policy/Menu/Directory)
- [ ] **Verify inputs are mapped:**

| Input | Type | Required | Source |
|---|---|---|---|
| `user_message` | String | Yes | Diner's unclear message |
| `comm_style` | String | No | Contact.Comm_Style__c |

- [ ] **What it returns:** ONE clarifying question
- [ ] **What it handles:** Restaurant resolution via Data Library grounding (r6_restaurant_directory.txt, FAQ__kav); info type clarification

### 4i: Register Apex Actions and Prompt Templates

**Apex Actions to register:**

| Apex Class | Action Label | Inputs | Returns |
|---|---|---|---|
| `VerifyPasscode` | Verify Passcode | contactId, passcodeProvided | isMatch, message |
| `GetAuthPasscodeMessage` | Get Auth Passcode Message | isGuest, retryAfterFail, commStyle | message |
| `DetermineEscalationPriority` | Determine Escalation Priority | contactSummary, escalationTrigger | priority, flags, queue |
| `EvaluateHardGates` | Evaluate Hard Gates | contactSummary | hardGate, gateMessage, trustGap |

**Register Prompt Templates as Agent Actions:**

**Where:** Agent Builder → your agent → Actions

- [ ] Click **New Action → Prompt Template** for each:

| Template | Action Label | Used By Topic |
|---|---|---|
| `Intent Classifier` | `Classify Intent` | topic_selector |
| `Restaurant Policy QA` | `Answer Policy Question` | restaurant_information |
| `Menu Retrieval QA` | `Answer Menu Question` | restaurant_information |
| `Restaurant Directory QA` | `Answer Directory Question` | restaurant_information |
| `Escalation Handler` | `Prepare Handoff` | escalation |
| `Ambiguous Clarifier` | `Clarify Question` | ambiguous_question |

- [ ] Map each template's input variables to the agent's context variables and action outputs

---

## Step 5: Create Agentforce Data Libraries

Agentforce Data Libraries ground the agent in your organization's data. You need **two** libraries: one Knowledge-based and one file-based.

### 5a: Knowledge-Based Data Library (FAQ__kav)

**Where:** Setup → Agentforce Data Library → New Library

- [ ] **Library Name:** `R6 Diner Knowledge Base`
- [ ] **Data Source:** Knowledge
- [ ] **Article Type:** Select `FAQ__kav`
- [ ] Click **Save** — Salesforce will automatically create the data stream, search index, and retriever
- [ ] Wait for the search index status to show as **Ready**

**Current article inventory (14 articles):**

| Type | Count | Content |
|---|---|---|
| Policy | 12 | Dress codes, cancellation rules, allergen info, family amenities, halal cert, wagyu, omakase |
| Parking | 2 | Le Petit Bistro valet + garage, Steak & Stone valet + underground |

PII distribution: 10 Public, 1 Internal (VIP handling — hidden from diners), 1 Restricted (emergency protocols — hidden and unacknowledged)

### 5b: File-Based Data Library (Supplementary Grounding)

**Where:** Setup → Agentforce Data Library → New Library

- [ ] **Library Name:** `R6 Diner Reference Guide`
- [ ] **Data Source:** Files
- [ ] Upload the three files from `dev-assets/data-library/`:
  - `r6_restaurant_directory.txt` — Complete directory of all 10 restaurants with Aliases (for semantic resolution), operational details, dress codes, vibes, pricing, allergen safety, parking
  - `r6_allergen_safety_guide.txt` (3.2 KB) — Nut-free/shellfish-free restaurant matrix, cross-reference protocol, and Menu_Item__c allergen tag guide
  - `r6_membership_and_policies.txt` (3.6 KB) — Platinum/Gold/Silver tier benefits, reservation policies, communication styles, escalation triggers, and PII sensitivity levels
- [ ] Click **Save** — wait for indexing to complete

**Why file-based in addition to Knowledge?** Knowledge articles cover restaurant-specific policies (one article per restaurant). The file-based library provides cross-cutting reference data: the allergen safety matrix across ALL restaurants, membership tier details, escalation trigger thresholds, and the confidence state reference table. This is information the agent needs but that doesn't belong in individual restaurant policy articles.

### 5c: Assign Data Libraries to the Agent

**Where:** Agent Builder → your agent → Knowledge tab

- [ ] Click the **Knowledge** tab
- [ ] Select `R6 Diner Knowledge Base` (the Knowledge-based library)
- [ ] Select `R6 Diner Reference Guide` (the file-based library)
- [ ] Enable **citations** (so the agent can cite which source it used)
- [ ] Click **Save**

**What this gives you:** The agent can now natively search FAQ__kav articles AND the supplementary grounding files — no custom Apex needed for Knowledge retrieval. The instructions in the topic reasoning block tell the agent *how* to use the results (PII gate, confidence thresholds, allergen cross-referencing, etc.).

---

## Step 6: Register Actions

### 6a: Get Restaurant (Native Record Lookup)

**Where:** Agent Builder → Actions → New Action → Get Record

- [ ] **Object:** Account
- [ ] **Label:** `Get Restaurant`
- [ ] **Description:** Look up a restaurant Account by name to get its Logic_State__c, Reliability_Score__c, and Data_Last_Verified__c for confidence calibration.
- [ ] **Lookup field:** Name
- [ ] **Fields to return:** Name, Logic_State__c, Reliability_Score__c, Data_Last_Verified__c, Cuisine_Type__c, Safe_For_Allergies__c, Price_Tier__c, Family_Friendly__c, Blackout_Dates__c

**Why native instead of Apex?** The Data Library grounding files already contain the full restaurant directory for answering "which restaurants are nut-free" or "how many restaurants do you have." This native action is only needed for live `Logic_State__c` lookups (it's a formula field that changes with time). A standard Get Record action handles this without custom code.

### 6b: Query Menu Items (Apex)

**Where:** Agent Builder → Actions → New Action → Apex

- [ ] **Apex Class:** `QueryMenuItems`
- [ ] **Method:** `queryMenuItems`
- [ ] **Label:** `Query Menu Items`
- [ ] **Description:** Search menu items for a specific restaurant with optional filters for availability, allergens, vegan, chef recommendations, and category.
- [ ] **Map inputs:**
  - `restaurantName` (String) — restaurant name to search
  - `restaurantId` (String, optional) — Account ID if already known
  - `availableOnly` (Boolean, optional) — only available items
  - `veganOnly` (Boolean, optional) — only vegan items
  - `chefPicksOnly` (Boolean, optional) — only chef recommendations
  - `category` (String, optional) — Starter, Main, Dessert, Drink, Side, Kids
  - `excludeAllergen` (String, optional) — Dairy, Gluten, Nuts, Shellfish, Eggs, Soy
- [ ] **Map outputs:**
  - `isSuccess` (Boolean)
  - `message` (String)
  - `totalCount` (Integer)
  - `menuData` (String — JSON array)

### 6c: Reservation Manager

**Where:** Agent Builder → Actions → New Action → Apex

- [ ] **Apex Class:** `ReservationManager`
- [ ] **Method:** `modifySlot`
- [ ] **Label:** `Modify Reservation`
- [ ] **Description:** Modify or cancel a reservation with 1-hour lockout enforcement, modification loop abuse check, slot availability verification, and atomic swap logic.
- [ ] **Map inputs:**
  - `reservationId` (String, required)
  - `newSlotId` (String, required for modify)
  - `action` (String, required) — 'modify' or 'cancel'
- [ ] **Map outputs:**
  - `isSuccess` (Boolean)
  - `message` (String)

---

## Step 7: Configure Diner Profile Lookup (Native)

Instead of a custom Apex action, use Agentforce's built-in record lookup for the Contact object.

**Where:** Agent Builder → Actions → New Action → Get Record

- [ ] **Object:** Contact
- [ ] **Record ID source:** Map to the `ContactId` variable (from MessagingEndUser.ContactId)
- [ ] **Fields to return:** FirstName, LastName, Cuisine_Preference__c, Allergy_Shellfish__c, Allergy_Nuts__c, Family_Status__c, Comm_Style__c, Membership_Level__c, Trust_Tolerance__c, Sentiment_Score__c, Lifetime_No_Show_Count__c, Churn_Risk__c
- [ ] **Label:** `Get Diner Profile`

---

## Step 8: Create Topics

Every topic delegates reasoning to a Prompt Template. The topic instructions are purely orchestration: gather context → invoke template → execute transitions.

### 8a: Topic Selector (Start Topic)

- [ ] **Label:** Topic Selector
- [ ] **Set as start topic:** Yes
- [ ] **Description:** Classify diner intent via Intent_Classifier template and route
- [ ] **Instructions:** Paste from agent script `start_agent topic_selector` → reasoning → instructions
- [ ] **Assign actions:**

| Action | Type | Purpose |
|---|---|---|
| `Get Diner Profile` | Native Get Record | Load Contact for hard gate checks |
| `Evaluate Hard Gates` | Apex | Check NO_SHOW, SENTIMENT, CHURN — skip classifier when gate triggers |
| `Classify Intent` | Prompt Template | Intent_Classifier — returns ROUTE + FSM_STATE (only when gate=NONE) |
| Transition to restaurant_information | Built-in | For ROUTE_POLICY, ROUTE_MENU, ROUTE_DIRECTORY |
| Transition to escalation | Built-in | For ROUTE_ESCALATION, ROUTE_TRANSACTIONAL |
| Transition to off_topic | Built-in | For ROUTE_OFF_TOPIC |
| Transition to ambiguous_question | Built-in | For ROUTE_AMBIGUOUS |

### 8b: Restaurant Information (Router Topic)

- [ ] **Label:** Restaurant Information
- [ ] **Description:** Gather context and delegate to Policy QA, Menu QA, or Directory QA template
- [ ] **Instructions:** Paste from agent script `topic restaurant_information` → reasoning → instructions
- [ ] **Assign actions:**

| Action | Type | Purpose |
|---|---|---|
| `Get Restaurant` | Native Get Record | Read Logic_State__c, compute TrustGap |
| `Query Menu Items` | Apex | Retrieve Menu_Item__c with filters |
| `Answer Policy Question` | Prompt Template | Policy/parking/dress code → S5_Strict_RAG |
| `Answer Menu Question` | Prompt Template | Menu/food/vegan → S5_Strict_RAG |
| `Answer Directory Question` | Prompt Template | Network-wide questions → S5_Strict_RAG |
| `Escalate to Human` | Built-in | STALE gate, template TRANSITION: ESCALATE |
| Transition to escalation | Built-in | Route to escalation topic |

**Data flow (policy question):**

```
Diner: "What's the dress code at Le Petit Bistro?"
  → Topic Selector: Intent_Classifier → ROUTE_POLICY, FSM_STATE=S5_Strict_RAG
  → Restaurant Info topic:
      1. Get Restaurant → Logic_State__c = DETERMINISTIC, TrustGap = false
      2. Knowledge RAG → retrieves FAQ__kav dress code article
      3. Invoke Policy QA template (restaurant_name, logic_state, knowledge_articles, comm_style, trust_gap, membership_level)
      4. Template responds with confidence-calibrated, PII-gated answer
```

**Data flow (menu question):**

```
Diner: "Any nut-free options at Sushi Zen?"
  → Topic Selector: Intent_Classifier → ROUTE_MENU, FSM_STATE=S5_Strict_RAG
  → Restaurant Info topic:
      1. Get Restaurant → Logic_State__c = DEGRADED, TrustGap = false
      2. QueryMenuItems(restaurantName="Sushi Zen", excludeAllergen="Nuts", availableOnly=true)
      3. Invoke Menu QA template (all inputs + allergy_nuts=true)
      4. Template responds with filtered menu + allergen warnings + freshness caveats
```

### 8c: Escalation

- [ ] **Label:** Escalation
- [ ] **FSM State:** S3_Circuit_Breaker (Path 2)
- [ ] **Description:** Generate AI summary via Escalation Handler template, route to human
- [ ] **Instructions:** Paste from agent script `topic escalation` → reasoning → instructions
- [ ] **Assign actions:**

| Action | Type | Purpose |
|---|---|---|
| `Get Restaurant` | Native Get Record | Context for AI summary |
| `Prepare Handoff` | Prompt Template | Escalation_Handler — returns AI_SUMMARY + ROUTING + MESSAGE |
| `Escalate to Human` | Built-in | Execute the handoff to queue |

### 8d: Off Topic

- [ ] **Label:** Off Topic
- [ ] **Description:** Redirect off-topic conversations with guardrails
- [ ] **Instructions:** Paste from agent script `topic off_topic` → reasoning → instructions
- [ ] **Actions:** Transition to restaurant_information (for misrouted directory questions)

### 8e: Ambiguous Question

- [ ] **Label:** Ambiguous Question
- [ ] **Description:** Disambiguate via Ambiguous_Clarifier — uses Data Library retrieval (same as Policy/Menu/Directory)
- [ ] **Instructions:** Paste from agent script `topic ambiguous_question` → reasoning → instructions
- [ ] **Assign actions:**

| Action | Type | Purpose |
|---|---|---|
| `Clarify Question` | Prompt Template | Ambiguous_Clarifier — uses Data Library grounding for restaurant resolution |
| Transition to topic_selector | Built-in | Re-classify after diner responds |

---

## Step 9: Configure Escalation Routing

**Where:** Setup → Omni-Channel → Queues (or Routing Configuration)

- [ ] Create a queue named `Tier_2_Human_Concierge` (if it doesn't exist)
- [ ] Assign appropriate support agents to this queue
- [ ] Configure the agent's escalation action to route to this queue

---

## Step 10: Set Up Variables

**Where:** Agent Builder → Variables

### Session Variables (linked to messaging context)

- [ ] `EndUserId` → linked to `MessagingSession.MessagingEndUserId`
- [ ] `RoutableId` → linked to `MessagingSession.Id`
- [ ] `ContactId` → linked to `MessagingEndUser.ContactId`
- [ ] `EndUserLanguage` → linked to `MessagingSession.EndUserLanguage`

### Mutable State Variables (set by orchestrator during conversation)

- [ ] `VerifiedCustomerId` → mutable string — set after identity verification
- [ ] `CurrentRestaurantId` → mutable string — Account Id of the restaurant being discussed
- [ ] `CurrentLogicState` → mutable string — cached Logic_State__c (DETERMINISTIC/PROBABILISTIC/DEGRADED/SPECULATIVE/STALE)
- [ ] `EscalationReason` → mutable string — why escalation was triggered (EXPLICIT_REQUEST/HIGH_RISK_KEYWORD/NEGATIVE_SENTIMENT/MODIFICATION_LOOP/TRUST_MISMATCH/STALE_DATA/NO_SHOW_BLOCK/CHURN_RISK)
- [ ] `TrustGap` → mutable string — "true" if Contact.Trust_Tolerance__c > Account.Reliability_Score__c

---

## Step 11: Test in Agent Builder

**Where:** Agent Builder → Test (Preview panel)

Test the full prompt-template routing flow. Verify each template is invoked correctly.

**Hard Gates (Evaluate Hard Gates — skip Intent_Classifier when gate triggers):**
- [ ] Set Contact Lifetime_No_Show_Count__c = 4 → NO_SHOW_BLOCK → gate message, escalate (or auth)
- [ ] Set Contact Sentiment_Score__c = -0.80 → NEGATIVE_SENTIMENT → gate message, escalate
- [ ] Set Contact Churn_Risk__c = true → CHURN_RISK → gate message, escalate

**Intent Classification (Topic Selector → Intent_Classifier template):**
- [ ] "What's the parking at Le Petit?" → ROUTE_POLICY, FSM_STATE=S5_Strict_RAG
- [ ] "Show me the menu at Sushi Zen" → ROUTE_MENU, FSM_STATE=S5_Strict_RAG
- [ ] "How many restaurants do you have?" → ROUTE_DIRECTORY, FSM_STATE=S5_Strict_RAG
- [ ] "I want to speak to a manager" → ROUTE_ESCALATION, FSM_STATE=S3_Circuit_Breaker
- [ ] "What's the weather?" → ROUTE_OFF_TOPIC
- [ ] "Tell me about pasta" → ROUTE_AMBIGUOUS (partial match → Pasta Palace?)

**Policy QA (Restaurant_Policy_QA template):**
- [ ] "What's the dress code at Steak & Stone?" → Get Restaurant (DETERMINISTIC) + Knowledge RAG → confident answer
- [ ] "Parking at Le Petit Bistro?" → Knowledge RAG (Parking article) → includes valet details

**Menu QA (Menu_Retrieval_QA template):**
- [ ] "What's on the menu at Le Petit Bistro?" → QueryMenuItems → formatted menu with prices/descriptions
- [ ] "Any nut-free options at Sushi Zen?" → QueryMenuItems(excludeAllergen=Nuts) + diner allergy cross-ref → allergen warnings
- [ ] "What are the chef's picks at Vibe Vegan?" → QueryMenuItems(chefPicksOnly=true) → Chef's Pick badges

**Directory QA (Restaurant_Directory_QA template):**
- [ ] "How many restaurants are available?" → Data Library → lists all 10
- [ ] "Which restaurants are nut-free?" → Data Library → filtered list with safety certifications

**Escalation (Escalation_Handler template):**
- [ ] "I need a manager" → EXPLICIT_REQUEST → AI_SUMMARY + warm handoff message
- [ ] Set test Contact Sentiment_Score__c to -0.80 → NEGATIVE_SENTIMENT → priority escalation

**Auth Passcode (Get Auth Passcode Message + VerifyPasscode action):**
- [ ] "I want to speak to a manager" → auth gate → action asks for passcode
- [ ] Provide passcode (First3 + 123456, e.g., Sof123456 for Sofia) → IsAuthenticated=true → escalation proceeds
- [ ] Provide wrong passcode → retry message; Guest (no Contact) → guest message

**Ambiguous (Ambiguous_Clarifier + Data Library):**
- [ ] "Tell me about sushi" → Data Library retrieval + Clarifier → "Do you mean Sushi Zen?"
- [ ] "Help me" → no context → "Are you looking for restaurant information, menu details, or something else?"

---

## Step 12: Activate the Agent

- [ ] Review all topics and actions are wired correctly
- [ ] Set the agent to **Active**
- [ ] Connect to your Messaging channel (if not already connected)

---

## Future Steps (not required for Path 4)

These are needed when you build the other FSM paths:

| Item | Path | Notes |
|---|---|---|
| Route_to_Human_Flow | Path 2 | Screen Flow for structured escalation with case creation |
| Reservation topics & actions | Path 1 | Wire ReservationManager.modifySlot as topic + action |
| Concierge recommendation topic | Path 3 | Uses grounding data + QueryMenuItems + diner profile for personalized suggestions |
| Data Cloud integration | All | Unified Profile, Vector Search Index |
| Einstein Trust Layer config | All | PII masking rules based on PII_Sensitivity__c |
