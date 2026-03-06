# GenAiPromptTemplate Metadata (API 65.0)

These templates were bootstrapped from `dev-assets/prompt-templates/*.txt` and deployed successfully.

## 5-Input Limit

Salesforce GenAiPromptTemplate allows a maximum of **5 custom inputs** per template. Templates with more inputs were consolidated:

| Template | Consolidated Input | Contents |
|----------|-------------------|----------|
| Restaurant_Policy_QA | `contact_context` | JSON: trust_gap, comm_style, membership_level, first_name |
| Menu_Retrieval_QA | `contact_context` | JSON: allergy_shellfish, allergy_nuts, comm_style, trust_gap, membership_level |
| Escalation_Handler | `handoff_context` | JSON: contact_summary, restaurant_name, logic_state, reservation_summary, comm_style |

## Agent Script Wiring

Update the agent script / Agent Builder to pass consolidated inputs:

- **Restaurant_Policy_QA:** Build `contact_context` JSON from ContactSummary + TrustGap (e.g. `{"trust_gap":"true","comm_style":"Brief/Efficiency","membership_level":"Gold","first_name":"Sofia"}`).
- **Menu_Retrieval_QA:** Build `contact_context` JSON from AllergyShellfish, AllergyNuts, ContactSummary, TrustGap.
- **Escalation_Handler:** Build `handoff_context` JSON from ContactSummary, CurrentRestaurantName, CurrentLogicState, ReservationSummary, CommStyle.
