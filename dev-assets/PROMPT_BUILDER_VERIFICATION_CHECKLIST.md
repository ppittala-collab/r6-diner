# Prompt Builder Verification Checklist

Use this checklist to ensure your Salesforce Prompt Builder configuration matches the source files. **Operational risk:** If templates exist twice in Prompt Builder, the wrong variant may be active.

---

## Pre-Deploy: Confirm Correct Variant

Before deploying, verify you are using the **Restaurant Lib (file-based)** versions, NOT any older FAQ__kav variants.

| Template | ✅ Correct Version | ❌ Wrong Version (do not use) |
|----------|-------------------|------------------------------|
| **Restaurant_Policy_QA** | Uses `knowledge_articles` from Restaurant Lib; no Article_Type__c, PII_Sensitivity__c, FAQ__kav | References Article_Type__c, Restaurant_Lookup__c, PII_Sensitivity__c, FAQ__kav |
| **Escalation_Handler** | `contact_summary` Optional; no `is_authenticated` input; "ASSUMPTION: User is authenticated (Lightning)" | Has `is_authenticated` required; auth gate; routes to auth_required |
| **Ambiguous_Clarifier** | Has `restaurant_directory_grounding` required input; "orchestrator provides grounding"; no FAQ__kav | Mentions FAQ__kav; "Use Data Library retrieval"; contradicts "Do NOT invoke retrieval" |

---

## Input Lists (Copy/Paste for Sanity Check)

Paste these into Prompt Builder and compare. If any input is missing or mismatched, fix before deploy.

### 1. Intent_Classifier
| Input | Type | Required |
|-------|------|----------|
| user_message | String | Yes |
| contact_summary | String | No |
| conversation_context | String | No |

**Outputs to parse:** ROUTE, RESTAURANT_HINT, CONFIDENCE, ACKNOWLEDGMENT

---

### 2. Restaurant_Policy_QA
| Input | Type | Required |
|-------|------|----------|
| restaurant_name | String | Yes |
| user_question | String | Yes |
| logic_state | String | Yes |
| knowledge_articles | String | Yes |
| comm_style | String | No |
| trust_gap | String | No |
| membership_level | String | No |
| first_name | String | No |

**Source for knowledge_articles:** Restaurant Lib grounding (r6_restaurant_directory.txt, r6_membership_and_policies.txt, r6_allergen_safety_guide.txt)

---

### 3. Menu_Retrieval_QA
| Input | Type | Required |
|-------|------|----------|
| restaurant_name | String | Yes |
| user_question | String | Yes |
| logic_state | String | Yes |
| menu_items | String | Yes |
| allergy_shellfish | String | No |
| allergy_nuts | String | No |
| comm_style | String | No |
| trust_gap | String | No |
| membership_level | String | No |

**Note:** allergy_shellfish, allergy_nuts, trust_gap = string `"true"`/`"false"`

---

### 4. Restaurant_Directory_QA
| Input | Type | Required |
|-------|------|----------|
| user_question | String | Yes |
| restaurant_data | String | Yes |
| comm_style | String | No |
| membership_level | String | No |
| contact_summary | String | No |

**Source for restaurant_data:** Restaurant Lib (r6_restaurant_directory.txt, etc.)

---

### 5. Escalation_Handler
| Input | Type | Required |
|-------|------|----------|
| escalation_trigger | String | Yes |
| routing_priority | String | Yes |
| routing_flags | String | Yes |
| contact_summary | String | **No** (Optional) |
| conversation_summary | String | Yes |
| restaurant_name | String | No |
| logic_state | String | No |
| reservation_summary | String | No |
| comm_style | String | No |

**Must NOT have:** `is_authenticated` input

---

### 6. Ambiguous_Clarifier
| Input | Type | Required |
|-------|------|----------|
| user_message | String | Yes |
| restaurant_directory_grounding | String | Yes |
| comm_style | String | No |

**Source for restaurant_directory_grounding:** Restaurant Lib (r6_restaurant_directory.txt)

**Must NOT mention:** FAQ__kav

---

## Runtime "Missing Input" Check

If you get "missing input" failures at runtime:

1. **Policy QA:** Ensure `knowledge_articles` is mapped from Restaurant Lib retrieval (not left blank).
2. **Directory QA:** Ensure `restaurant_data` is mapped from Restaurant Lib retrieval.
3. **Ambiguous Clarifier:** Ensure `restaurant_directory_grounding` is mapped from Restaurant Lib retrieval.
4. **Escalation Handler:** Ensure `conversation_summary` is populated (required). `contact_summary` can be empty (Optional).
