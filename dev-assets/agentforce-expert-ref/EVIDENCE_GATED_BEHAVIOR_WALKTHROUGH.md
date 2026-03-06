# Evidence-Gated Path 4 — Behavior Walkthrough

**Score convention:** All scores are integers 0–100. Thresholds: classifier <55 → ambiguous; answerable ≥80 → answer; 55–79 → clarify; <55 → escalate (unless usable followup).

---

## Example 1: Weak Grounding → answerable_score_int=62 → ambiguous_question

### Scenario

**User:** "What's the dress code at Zen?"

**Context:** Grounding has "Sushi Zen" but the retrieved passage does NOT contain dress code info (retrieval returned only menu-related text). Weak evidence.

### Flow

1. **Intent_Classifier** (topic_selector)
   - Output: `route: ROUTE_POLICY`, `restaurant_hint: Sushi Zen`, `confidence_score_int: 78`
   - RouteConfidenceScore = 78 (≥ 55) → proceed to restaurant_information

2. **restaurant_information** (ROUTE_POLICY)
   - get_restaurant("Sushi Zen") → CurrentRestaurantName, CurrentLogicState
   - invoke_policy_qa with knowledge_articles (no dress code snippet)

3. **Restaurant_Policy_QA**
   - **Evidence gate:** Cannot extract any snippet that answers the dress code question.
   - Output (JSON):
     ```json
     {
       "answer_text": "",
       "answerable_score_int": 62,
       "should_clarify": true,
       "followup_question": "I don't have dress code details for Sushi Zen in my current information. Would you like me to connect you with the restaurant directly to confirm?",
       "evidence_used": []
     }
     ```

4. **Agent Script routing**
   - score = 62 → in clarify band (55–79)
   - **OriginalUserMessage = UserMessage** (preserve "What's the dress code at Zen?")
   - **FollowupQuestion =** followup_question from QA
   - **go_to_ambiguous_question** (do NOT overwrite UserMessage)

5. **Ambiguous_Clarifier**
   - Inputs: user_message=OriginalUserMessage, followup_question, comm_style (from ContactContext)
   - May refine or emit the followup. Diner receives a clarifying question instead of a fabricated answer.

---

## Example 2: Very Weak Grounding → answerable_score_int=40 → escalation

### Scenario

**User:** "What's the dress code at Zen?"

**Context:** Same as above, but the template determines it cannot formulate a useful followup — question is too underspecified and no grounding helps.

### Flow

1. **Intent_Classifier** → proceed (same as Example 1)

2. **Restaurant_Policy_QA**
   - **Evidence gate:** No evidence. No usable clarifying path.
   - Output (JSON):
     ```json
     {
       "answer_text": "",
       "answerable_score_int": 40,
       "should_clarify": false,
       "followup_question": "",
       "evidence_used": []
     }
     ```

3. **Agent Script routing**
   - score = 40 → below 55
   - followup_question is empty → **not usable**
   - **EscalationReason** set → **go escalation**
   - Escalation_Handler produces handoff message.

**Alternative:** If the template instead outputs `SYSTEM_FLAG_ESCALATE` (exactly, nothing else), the agent routes directly to escalation without parsing JSON.

---

## Example 3: Strong Evidence → answerable_score_int=92 → send answer

**User:** "What's the dress code at Sushi Zen?"

**Restaurant_Policy_QA:**
```json
{
  "answer_text": "At Sushi Zen, the dress code is smart casual. No shorts at dinner.",
  "answerable_score_int": 92,
  "should_clarify": false,
  "followup_question": "",
  "evidence_used": ["Sushi Zen — Smart casual, no shorts at dinner."]
}
```

**Agent Script:** score = 92 ≥ 80 → **send answer_text to diner**

---

## Thresholds (0–100 Integer Scores)

| Condition | Action |
|-----------|--------|
| RouteConfidenceScore < 55 | set OriginalUserMessage=UserMessage, go_to_ambiguous_question |
| RestaurantHint = NONE for POLICY/MENU | go_to_ambiguous_question |
| SYSTEM_FLAG_ESCALATE from any QA | escalation |
| should_clarify = true | set OriginalUserMessage, FollowupQuestion; go ambiguous_question |
| answerable_score_int ≥ 80 | send answer_text |
| answerable_score_int 55–79 | set OriginalUserMessage, FollowupQuestion; go ambiguous_question |
| answerable_score_int < 55 AND no usable followup | escalation |
| answerable_score_int < 55 AND usable followup | go ambiguous_question |
