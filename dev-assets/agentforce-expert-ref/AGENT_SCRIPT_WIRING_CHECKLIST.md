# Agent Script Wiring Checklist (Agent Builder UI)

Use this checklist when configuring the R6 Diner agent in Agent Builder. The agent script defines topics and actions; the UI must wire variables, grounding, and input/output mappings.

---

## A) GLOBAL / KNOWLEDGE

1. **Agent Builder → Knowledge tab:**
   - Assign Data Library: **Restaurant Lib** (file-based Data Library grounding)
   - Enable citations (script sets `knowledge.citations_enabled = True`)

---

## B) VARIABLES

2. **Ensure inbound message is stored into:**
   - `@variables.UserMessage` (current diner utterance)

3. **Provide conversation context/summaries:**
   - Map conversation turn summary → `@variables.ConversationContext` (optional)
   - Map escalation-required summary → `@variables.ConversationSummary` (required by Escalation_Handler)

4. **Build ContactContext (for Policy/Menu QA — 5-input limit):**
   - Before invoking Policy or Menu QA, build JSON: `{"trust_gap":"true|false","allergy_shellfish":"true|false","allergy_nuts":"true|false","comm_style":"...","membership_level":"...","first_name":"..."}` from ContactSummary + TrustGap + AllergyShellfish + AllergyNuts.

---

## C) NATIVE GET RECORD ACTIONS

5. **Action "Get Diner Profile" (Contact):**
   - Input `recordId` = `@variables.ContactId`
   - Output fields must be assembled into JSON string:
     - Map into `@variables.ContactSummary`
     - If ContactId is null, set ContactSummary = `'{}'` (either in flow/UI guard or via default)
   - **Allergy flags (for Menu QA):** Map `Allergy_Shellfish__c` → `@variables.AllergyShellfish`, `Allergy_Nuts__c` → `@variables.AllergyNuts` (as `'true'`/`'false'` strings). If native Get Record does not support multiple outputs, use a Flow wrapper that returns these.

6. **Action "Get Restaurant" (Account):**
   - Input lookup uses `@variables.RestaurantHint` (or a resolved name from ambiguous flow)
   - Map outputs:
     - Account.Id → `@variables.CurrentRestaurantId`
     - Account.Name → `@variables.CurrentRestaurantName`
     - Account.Logic_State__c → `@variables.CurrentLogicState`
   - **TrustGap:** Compute in Apex (EvaluateHardGates or another Apex) and set `@variables.TrustGap` to `'true'`/`'false'`. Do NOT compute TrustGap in LLM.

---

## D) APEX ACTIONS

7. **Evaluate Hard Gates (Apex EvaluateHardGates):**
   - Input: `contactSummary` = `@variables.ContactSummary`
   - Outputs:
     - `trustGap` → `@variables.TrustGap` (string `'true'`/`'false'`)
     - `hardGate` → use to set `@variables.EscalationReason`
     - `gateMessage` → `@variables.GateMessage` (TODO(UI): send to diner before transitioning to escalation; separate from Acknowledgment)

8. **Query Menu Items (Apex QueryMenuItems):**
   - Inputs:
     - `restaurantName` = `@variables.CurrentRestaurantName`
     - `restaurantId` = `@variables.CurrentRestaurantId`
     - plus filter params (availableOnly, veganOnly, chefPicksOnly, category, excludeAllergen)
   - Output:
     - `menuData` JSON → map to `@variables.MenuItems` (and to Menu_Retrieval_QA input `menu_items`)

9. **Determine Escalation Priority (Apex DetermineEscalationPriority):**
   - Inputs:
     - `contactSummary` = `@variables.ContactSummary`
     - `escalationTrigger` = `@variables.EscalationReason`
   - Outputs:
     - `priority` → `@variables.EscalationPriority`
     - `flags` → `@variables.EscalationFlags`

---

## E) DATA LIBRARY GROUNDING (Restaurant Lib)

10. **Provide grounding text strings to the following variables** (via Knowledge/Data Library retrieval outputs in UI):
   - Restaurant_Policy_QA input `knowledge_articles` → `@variables.KnowledgeArticles`
   - Restaurant_Directory_QA input `restaurant_data` → `@variables.RestaurantData`
   - Ambiguous_Clarifier input `restaurant_directory_grounding` → `@variables.RestaurantDirectoryGrounding`

---

## F) PROMPT TEMPLATE INPUT MAPPINGS

11. **Intent_Classifier (JSON output):**
    - `user_message` → `@variables.UserMessage`
    - `contact_summary` → `@variables.ContactSummary`
    - `conversation_context` → `@variables.ConversationContext`
    - Parse JSON: route → Route, restaurant_hint → RestaurantHint, acknowledgment → Acknowledgment, route_probs → RouteProbs, confidence_score → RouteConfidenceScore, confidence_label → RouteConfidenceLabel
    - If RouteConfidenceScore < 0.55 → transition to ambiguous_question (do not proceed)

12. **Restaurant_Policy_QA (evidence-gated JSON or SYSTEM_FLAG_ESCALATE):**
    - `restaurant_name` → `@variables.CurrentRestaurantName`
    - `user_question` → `@variables.UserMessage`
    - `logic_state` → `@variables.CurrentLogicState`
    - `knowledge_articles` → `@variables.KnowledgeArticles`
    - `contact_context` → `@variables.ContactContext` (JSON: trust_gap, comm_style, membership_level, first_name)
    - Parse JSON: answerable_score → PolicyAnswerableScore, should_clarify → ShouldClarify, followup_question → FollowupQuestion, answer_text → QAAnswerText, evidence_used → EvidenceUsed. Or detect SYSTEM_FLAG_ESCALATE.

13. **Menu_Retrieval_QA (evidence-gated JSON or SYSTEM_FLAG_ESCALATE):**
    - `restaurant_name` → `@variables.CurrentRestaurantName`
    - `user_question` → `@variables.UserMessage`
    - `logic_state` → `@variables.CurrentLogicState`
    - `menu_items` → `@variables.MenuItems`
    - `contact_context` → `@variables.ContactContext` (JSON: allergy_shellfish, allergy_nuts, comm_style, trust_gap, membership_level)
    - Parse JSON: answerable_score → MenuAnswerableScore, should_clarify → ShouldClarify, followup_question → FollowupQuestion, answer_text → QAAnswerText, evidence_used → EvidenceUsed. Or detect SYSTEM_FLAG_ESCALATE.

14. **Restaurant_Directory_QA (evidence-gated JSON or SYSTEM_FLAG_ESCALATE):**
    - `user_question` → `@variables.UserMessage`
    - `restaurant_data` → `@variables.RestaurantData`
    - `contact_summary` → `@variables.ContactSummary`
    - Parse JSON: answerable_score → DirectoryAnswerableScore, should_clarify → ShouldClarify, followup_question → FollowupQuestion, answer_text → QAAnswerText, evidence_used → EvidenceUsed. Or detect SYSTEM_FLAG_ESCALATE.

15. **Escalation_Handler:**
    - `escalation_trigger` → `@variables.EscalationReason`
    - `routing_priority` → `@variables.EscalationPriority`
    - `routing_flags` → `@variables.EscalationFlags`
    - `contact_summary` → `@variables.ContactSummary`
    - `conversation_summary` → `@variables.ConversationSummary`
    - `restaurant_name` → `@variables.CurrentRestaurantName` (optional)
    - `logic_state` → `@variables.CurrentLogicState` (optional)
    - `reservation_summary` → `@variables.ReservationSummary` (optional)
    - **Output:** Map single-text template output → `@variables.EscalationOutput` (key may be `output`, `text`, or `result` depending on org).
    - **Optional parsing:** If desired, parse EscalationOutput sections (`--- AI_SUMMARY ---`, `--- DINER_MESSAGE ---`) into EscalationAISummary and EscalationDinerMessage. For MVP, send whole EscalationOutput to diner (or extract DINER_MESSAGE only to avoid exposing AI_SUMMARY).

16. **Ambiguous_Clarifier (JSON output):**
    - `user_message` → `@variables.UserMessage`
    - `restaurant_directory_grounding` → `@variables.RestaurantDirectoryGrounding`
    - `comm_style` → map from Contact (optional)
    - `followup_question` → `@variables.FollowupQuestion` (when routed from Policy/Menu/Directory due to should_clarify or low answerable_score)
    - Parse JSON: clarifying_question → send to diner

---

## G) CRITICAL UI GUARDRAILS (Must-Do Before Production)

These two steps are **not executable from reasoning text** — they must be implemented as real flow elements in Agent Builder.

### 18. RestaurantHint guard (Topic: restaurant_information)

**Problem:** Reasoning says "If Route in (ROUTE_POLICY, ROUTE_MENU) AND RestaurantHint == 'NONE' → go_to_ambiguous_question" — but prose is not executable. Without a real decision, the router can still call `Get_Restaurant` with `'NONE'`.

**Fix in Agent Builder:**
- Add a **Decision/Condition** step **before** `get_restaurant`:
  - **Condition:** `Route` in (ROUTE_POLICY, ROUTE_MENU) **and** `RestaurantHint` == `'NONE'`
  - **If true:** Transition to `ambiguous_question`
  - **If false:** Continue to `get_restaurant`

**Where:** In the `restaurant_information` topic flow, on the POLICY and MENU branches.

---

### 19. GateMessage send step (Topic: topic_selector)

**Problem:** When `hardGate != NONE`, diners must see the gate explanation before escalation. The script sets `GateMessage` but cannot "send" it — that requires a UI step.

**Fix in Agent Builder:**
- After `evaluate_hard_gates`, when `hardGate != NONE`:
  - Add a **Send Message** step that sends `@variables.GateMessage` to the diner.
  - Then transition to `escalation`.

**Where:** In the `topic_selector` flow, on the hard-gate branch (before `go_to_escalation`).

---

## H) AUTHENTICATION

20. **No auth topic exists** (Lightning-auth assumed). Do not configure `auth_required`.

---

## I) OPTIONAL POLISH (Nice-to-Have)

- **Allergy strings:** Ensure `AllergyShellfish` and `AllergyNuts` are normalized to lowercase `'true'`/`'false'` (same pattern as TrustGap).
- **Personalization:** Pass `comm_style`, `membership_level`, `first_name` to Policy QA and Directory QA for consistent persona.
- **Hard-gate behavior:** Current design escalates when hardGate != NONE. Some orgs prefer gate-only (show message, no handoff) — confirm desired behavior.
