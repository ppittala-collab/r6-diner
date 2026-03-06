# TODO Implementation Guide — Agent Script & Prompt Templates

**Status:** Prompt templates deployed successfully (6 templates).  
**Last deploy:** `sf project deploy start --source-dir force-app/main/default/genAiPromptTemplates`

---

## 1. Prompt Template Publishing

**Done:** All 6 GenAI Prompt Templates are deployed to the org. The metadata `status: Published` in each `templateVersions` block means they are active.

**If you need to re-publish after edits:**
```bash
sf project deploy start --source-dir force-app/main/default/genAiPromptTemplates --wait 10
```

**Verify in org:** Setup → Prompt Builder → confirm Intent_Classifier, Restaurant_Policy_QA, Menu_Retrieval_QA, Restaurant_Directory_QA, Escalation_Handler, Ambiguous_Clarifier appear and show your latest content.

---

## 2. Strongest Implementation Approaches for TODO Tasks

### Tier 1: Agent Builder UI (Preferred Where Supported)

Agent Builder maps prompt template outputs to variables. Use the UI when the platform supports it.

| TODO | Location | Strongest Approach |
|-----|----------|---------------------|
| **Parse Intent_Classifier JSON** | topic_selector → classify_intent outputs | **Agent Builder:** Configure the Prompt Template action's output mappings. Map `route` → Route, `restaurant_hint` → RestaurantHint, `confidence_score_int` → RouteConfidenceScore, `confidence_label` → RouteConfidenceLabel. If the platform supports JSON-path extraction (e.g., `output.route`), use it. |
| **Parse Policy/Menu/Directory QA JSON** | restaurant_information → invoke_*_qa outputs | **Agent Builder:** Same pattern. Map `answerable_score_int` → PolicyAnswerableScore, `should_clarify` → ShouldClarify, `followup_question` → FollowupQuestion, `answer_text` → QAAnswerText. |
| **Parse Ambiguous_Clarifier JSON** | ambiguous_question → clarify_question outputs | **Agent Builder:** Map `clarifying_question` → a variable, then use a "Send Message" action to send it to the diner. |
| **Parse EscalationOutput** | escalation → prepare_handoff outputs | **Agent Builder:** If you need DINER_MESSAGE vs AI_SUMMARY split, add a parsing step (see Tier 2). Otherwise, send whole EscalationOutput. |
| **Send GateMessage / DINER_MESSAGE / clarifying_question** | Multiple topics | **Agent Builder:** Use the built-in "Send Message to User" or equivalent action, wired to the variable holding the message. |

---

### Tier 2: Apex Wrapper Actions (Most Robust for Complex Logic)

When JSON parsing, threshold checks, or multi-step logic are not cleanly supported by the UI, use Apex.

| TODO | Strongest Approach |
|-----|---------------------|
| **Build ContactSummary at first step** | **DONE: Apex `Build_Contact_Summary`** — Input: ContactId. Output: ContactSummary, ContactContext, CommStyle, AllergyShellfish, AllergyNuts. Defaults when guest. Called in topic_selector STEP 1. |
| **Merge TrustGap into ContactContext** | **DONE: Apex `Build_Contact_Context`** — Input: ContactSummary, TrustGap, AllergyShellfish, AllergyNuts. Output: ContactContext. Called in restaurant_information before Policy/Menu QA. |
| **Get diner history for escalation/transactional** | **DONE: Apex `Get_Diner_History`** — Input: ContactId. Output: reservationSummary (JSON array of recent reservations). Called in escalation topic before prepare_handoff. |
| **Map Restaurant Lib grounding → KnowledgeArticles / RestaurantData** | **Apex action `RetrieveRestaurantGrounding`:** Input: restaurant name (or "ALL" for directory). Output: KnowledgeArticles or RestaurantData string. Uses Data Library / Connect API to retrieve grounding. Agent Script passes the output to the QA templates. |
| **Map Restaurant Lib → RestaurantDirectoryGrounding** | **Same or separate Apex:** Retrieve directory grounding for Ambiguous_Clarifier. Output: RestaurantDirectoryGrounding. |
| **Map Get Record (Account) → CurrentRestaurantId, etc.** | **Extend Get_Restaurant Apex:** Return structured outputs (CurrentRestaurantId, CurrentRestaurantName, CurrentLogicState) instead of raw Account. |

---

### Tier 3: Prompt Template Changes (When Logic Belongs in the LLM)

| TODO | Strongest Approach |
|-----|---------------------|
| **SYSTEM_FLAG_ESCALATE detection** | **Prompt templates:** Already output `SYSTEM_FLAG_ESCALATE` exactly when escalating. **Agent Script / Apex:** Before parsing JSON, check if the raw output equals `SYSTEM_FLAG_ESCALATE` (trim, case-sensitive). If yes, route to escalation; else parse JSON. Implement this in an Apex wrapper that calls the template and returns a structured result (e.g., `{isEscalation: true}` or `{isEscalation: false, json: {...}}`). |
| **Threshold comparisons (score < 55, 55–79, >= 80)** | **Agent Script / Apex:** Store scores as strings (e.g., `"82"`). Use Apex to parse to integer and return a routing decision (e.g., `route: "answer" | "clarify" | "escalate"`). Alternatively, if Agent Builder supports conditional transitions on numeric variables, use that. |
| **Usable followup_question check (score < 55)** | **Apex helper:** Input: followup_question string. Output: boolean `isUsable` (e.g., non-empty, length > 10, not just "I don't know"). Call before deciding escalate vs ambiguous. |

---

### Tier 4: Agent Script–Only (Minimal Changes)

| TODO | Approach |
|-----|----------|
| **comm_style for Ambiguous_Clarifier** | Ensure ContactContext is built (Tier 2) and CommStyle is extracted. Pass `@variables.CommStyle` to Ambiguous_Clarifier. Already wired in the script. |
| **OriginalUserMessage preservation** | Already in script: set `OriginalUserMessage=UserMessage` before `go_to_ambiguous_question`. No further change. |
| **Transition logic** | The reasoning instructions already describe the flow. Agent Builder will use these to drive transitions. Ensure conditions reference the correct variables (RouteConfidenceScore, PolicyAnswerableScore, etc.). |

---

## 3. Recommended Implementation Order

1. **ContactContext + CommStyle** — Apex `BuildContactContext` (or extend Get_Diner_Profile). Unblocks Policy/Menu QA and Ambiguous_Clarifier.
2. **Restaurant grounding** — Apex `RetrieveRestaurantGrounding` for KnowledgeArticles, RestaurantData, RestaurantDirectoryGrounding.
3. **Output mappings** — Agent Builder UI for all prompt template actions. Map JSON fields to variables.
4. **SYSTEM_FLAG_ESCALATE** — Apex wrapper or pre-parse check before JSON parse.
5. **Send Message actions** — Agent Builder: wire GateMessage, QAAnswerText, clarifying_question, EscalationDinerMessage to the send-message action.

---

## 4. Summary: Where to Implement Each TODO

| TODO | Best Place |
|-----|------------|
| Parse Intent_Classifier JSON | Agent Builder output mappings |
| Parse Policy/Menu/Directory QA JSON | Agent Builder output mappings |
| Parse Ambiguous_Clarifier JSON | Agent Builder output mappings |
| Build ContactContext, extract CommStyle | Apex: BuildContactContext or extend Get_Diner_Profile |
| Map Get Record → ContactSummary | Apex: extend Get_Diner_Profile |
| Map Restaurant Lib → KnowledgeArticles/Data | Apex: RetrieveRestaurantGrounding |
| Map Get Record (Account) → CurrentRestaurantId, etc. | Apex: extend Get_Restaurant |
| Send GateMessage / DINER_MESSAGE / clarifying_question | Agent Builder: Send Message action |
| SYSTEM_FLAG_ESCALATE detection | Apex wrapper or pre-parse in Agent Script |
| Threshold comparisons (55, 80) | Apex helper or Agent Builder conditions |
