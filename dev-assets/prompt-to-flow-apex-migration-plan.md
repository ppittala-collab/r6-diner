# Prompt Templates → Flow/Apex Migration Plan

**Purpose:** Identify which prompt template actions can be implemented (or augmented) using Flows, Apex, or other deterministic logic — reducing LLM calls, cost, and latency where appropriate.

**Status:** Phase 1 + Phase 2 COMPLETED (2026-03-03).

---

## Current Architecture Summary

| Component | Type | Role |
|-----------|------|------|
| Intent_Classifier | Prompt Template | Classify intent, check hard gates, return ROUTE |
| Restaurant_Policy_QA | Prompt Template | Answer policy questions using FAQ__kav |
| Menu_Retrieval_QA | Prompt Template | Answer menu questions using Menu_Item__c |
| Restaurant_Directory_QA | Prompt Template | Answer directory questions using Data Library |
| Escalation_Handler | Prompt Template | AI summary, priority routing, handoff message |
| Ambiguous_Clarifier | Prompt Template | One clarifying question for unclear input |
| Auth_Passcode_Prompt | Prompt Template | Passcode request message (3 scenarios) |
| Get_Diner_Profile | Native Get Record | Load Contact |
| Get_Restaurant | Native Get Record | Load Account |
| Query_Menu_Items | Apex | Fetch Menu_Item__c with filters |
| Verify_Passcode | Apex | Verify Contact.Passcode__c |

---

## Migration Opportunities

### 1. Auth_Passcode_Prompt → Flow or Apex (High Value, Low Effort)

**Current:** LLM generates one of 3 messages based on `is_guest`, `retry_after_fail`, `comm_style`.

**Proposed:** Replace with deterministic logic — no LLM needed.

| Scenario | Output |
|----------|--------|
| is_guest = true | "Escalation is available to registered diners. Please log in to your account to connect with our team." |
| retry_after_fail = true | "That passcode doesn't match our records. Please try again, or say 'cancel' to return to your question." |
| else | "I'd be happy to connect you with our team. To verify your identity and prioritize your request, please provide your account passcode." |

**Implementation options:**
- **Apex:** `GetAuthPasscodeMessage.cls` — Invocable with inputs `is_guest`, `retry_after_fail`, `comm_style` → returns message string. Optionally shortens for Brief/Efficiency.
- **Flow:** Screen Flow or Auto-launched Flow with Decision elements → returns message. Agent invokes flow as action.

**Effort:** Low | **LLM savings:** 1 call per auth gate entry | **Recommendation:** Proceed

---

### 2. Intent Classifier — Hard Gates Only → Apex (Medium Value, Medium Effort)

**Current:** LLM classifies intent AND checks hard gates (NO_SHOW_BLOCK, NEGATIVE_SENTIMENT, CHURN_RISK, TRUST_MISMATCH).

**Proposed:** Split responsibilities:
- **Apex:** `EvaluateHardGates.cls` — Takes `contact_summary` (JSON) and optional `restaurant_reliability_score`. Returns: `hard_gate` (NONE | NO_SHOW_BLOCK | NEGATIVE_SENTIMENT | CHURN_RISK | TRUST_MISMATCH), `trust_gap` (boolean).
- **Orchestrator:** Call EvaluateHardGates first. If hard gate != NONE → skip Intent_Classifier, route directly to escalation. Else → call Intent_Classifier (without gate logic in prompt).

**Benefits:** Deterministic gates run first; LLM only used when no gate triggers. Reduces misclassification risk.

**Effort:** Medium | **LLM savings:** 1 call when gate triggers | **Recommendation:** Consider for Phase 2

---

### 3. Escalation_Handler — Priority Routing → Apex (Medium Value, Low Effort)

**Current:** LLM determines PRIORITY (CRITICAL/VIP/HIGH/STANDARD) and FLAGS from contact_summary + escalation_trigger.

**Proposed:** 
- **Apex:** `DetermineEscalationPriority.cls` — Takes `contact_summary`, `escalation_trigger`. Returns: `priority`, `flags` (comma-separated).
- **Escalation_Handler prompt:** Remove priority logic. Focus only on: (1) AI summary generation, (2) diner handoff message. Accept `priority` and `flags` as inputs from Apex.

**Benefits:** Priority routing is rule-based; no LLM needed for that. Prompt becomes simpler.

**Effort:** Low | **LLM savings:** None (still need summary + message) | **Recommendation:** Proceed — improves consistency

---

### 4. Ambiguous_Clarifier — Restaurant Fuzzy Match → Apex (Medium Value, Medium Effort)

**Current:** LLM has restaurant directory in prompt; does fuzzy matching (e.g., "sushi" → Sushi Zen).

**Proposed:**
- **Apex:** `ResolveRestaurantName.cls` — Takes `user_message`. Returns: `best_match` (restaurant name or null), `confidence` (high/medium/low), `suggested_question` (optional).
- **Flow:** If best_match with high confidence → skip LLM, return "Do you mean [restaurant]?" If low/medium or null → call Ambiguous_Clarifier for open-ended question.

**Benefits:** Simple partial matches (e.g., "sushi", "pasta") handled without LLM. Complex cases still use LLM.

**Effort:** Medium | **LLM savings:** ~30–50% of ambiguous cases | **Recommendation:** Consider for Phase 2

---

### 5. Restaurant_Directory_QA — Pre-filter by Allergen → Apex (Low Value, Low Effort)

**Current:** Data Library provides all restaurants; LLM filters by allergen safety in prompt.

**Proposed:** 
- **Apex:** `GetFilteredRestaurantDirectory.cls` — Takes `contact_summary`, `filter_type` (allergen_nuts, allergen_shellfish, family_friendly, etc.). Returns filtered JSON. Agent passes this to Directory QA template.

**Benefits:** Reduces token count to LLM; filtering is deterministic.

**Effort:** Low | **LLM savings:** Smaller context | **Recommendation:** Optional enhancement

---

### 6. Menu_Retrieval_QA — Allergen Pre-check → Apex (Low Value, Already Partially Done)

**Current:** QueryMenuItems already has `excludeAllergen` filter. LLM still does allergen warnings in response.

**Proposed:** QueryMenuItems could return `allergenWarnings` (list of items that contain diner's allergens but weren't excluded). LLM uses this for messaging. Minor enhancement.

**Effort:** Low | **Recommendation:** Optional

---

### 7. Off Topic — Static Response (Already Implemented)

**Current:** Agent script has static instructions; no prompt template. No change needed.

---

## Recommended Implementation Phases

| Phase | Items | Effort | Approval |
|-------|-------|--------|----------|
| **Phase 1** | Auth_Passcode_Prompt → Apex | Low | Pending |
| **Phase 1** | Escalation_Handler priority → Apex | Low | Pending |
| **Phase 2** | Intent hard gates → Apex | Medium | Pending |
| **Phase 2** | Ambiguous restaurant resolver → Apex | Medium | Pending |
| **Phase 3** | Directory pre-filter, Menu allergen enhancement | Low | Optional |

---

## Phase 1 Detail (Awaiting Approval)

### 1a. Create `GetAuthPasscodeMessage.cls`

```
Invocable inputs: is_guest (Boolean), retry_after_fail (Boolean), comm_style (String)
Output: message (String)
Logic: Decision tree → return appropriate message. If comm_style = 'Brief/Efficiency', optionally truncate.
```

**Agent change:** In `auth_required` topic, replace `request_passcode: @promptTemplate.Auth_Passcode_Prompt` with `request_passcode: @action.Get_Auth_Passcode_Message`.

### 1b. Create `DetermineEscalationPriority.cls`

```
Invocable inputs: contact_summary (String/JSON), escalation_trigger (String)
Output: priority (String), flags (String)
Logic: Rules from Escalation_Handler (CRITICAL, VIP, HIGH, STANDARD).
```

**Agent change:** In `escalation` topic, call DetermineEscalationPriority before prepare_handoff. Pass priority and flags into Escalation_Handler as fixed inputs. Simplify Escalation_Handler prompt to not compute priority.

---

## Out of Scope (Keep as Prompt Templates)

- **Intent_Classifier** (core routing) — LLM needed for natural language understanding
- **Restaurant_Policy_QA** — RAG + synthesis requires LLM
- **Menu_Retrieval_QA** — Formatting and tone require LLM
- **Restaurant_Directory_QA** — Synthesis and personalization require LLM
- **Escalation_Handler** (AI summary + diner message) — LLM needed
- **Ambiguous_Clarifier** (open-ended disambiguation) — LLM needed for CASE 2, 3, 4

---

## Approval Checklist

- [x] Approve Phase 1a (Auth Passcode → Apex) — DONE
- [x] Approve Phase 1b (Escalation Priority → Apex) — DONE
- [x] Phase 2a (Hard Gates → Apex) — DONE
- [x] Phase 2b (Restaurant Resolver) — REVERTED: Uses Data Library instead of Apex (same retrieval as Policy/Menu/Directory)
- [ ] Approve Phase 2 (Hard Gates, Restaurant Resolver) — or defer
- [ ] Approve Phase 3 (Directory/Menu enhancements) — or defer

**Next step:** Once approved, implement Phase 1 and update agent script + prompt templates accordingly.
