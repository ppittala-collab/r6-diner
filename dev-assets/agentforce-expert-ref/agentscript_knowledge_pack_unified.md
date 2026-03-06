# Agent Script — Senior Agentforce Engineer Knowledge Pack (Unified)
_Generated: 2026-03-05_

## Contents

- **01. What Agent Script Is (and Why It Exists)**

- **02. Mandatory Blocks: config, system, variables, start_agent, topic**

- **03. Indentation & Syntax Discipline (Deployment-Safe)**

- **04. system.welcome and system.error as Guardrails**

- **05. Variables: Mutable vs Linked**

- **06. Template Expressions (Dynamic Values)**

- **07. start_agent Responsibilities**

- **08. Topic Design: One Job per Topic**

- **09. Deterministic Logic vs LLM Reasoning**

- **10. After Reasoning: Deterministic Post-Processing**

- **11. Pattern: Router (topic_selector)**

- **12. Pattern: Gatekeeper (Identity Verification)**

- **13. Pattern: Slot Filling (Entity Capture)**

- **14. Pattern: Required Workflow (Mandatory Steps)**

- **15. Pattern: Specialist Delegation (Call-and-Return)**

- **16. Pattern: Escalation (Human Handoff)**

- **17. Confidence & Ambiguity Strategy**

- **18. State Machine Thinking (Reliable Agents)**

- **19. Topic Graph Checklist**

- **20. Minimal Working Scaffold Template**

- **21. Actions: Apex Targets**

- **22. Actions: Flow Targets**

- **23. Actions: Prompt Templates**

- **24. Tool Choice: Deterministic vs LLM-Selectable**

- **25. Inputs/Outputs Mapping Discipline**

- **26. Tool Availability Filtering**

- **27. Action Chaining Pattern**

- **28. Idempotency and Retries**

- **29. External API Orchestration (Safely)**

- **30. Structured Outputs Strategy**

- **31. Sensitive Data Handling**

- **32. Multi-Channel UX (Chat vs Case vs Voice)**

- **33. Tool Naming Conventions**

- **34. Logging & Observability Variables**

- **35. Cost Control Playbook (LLM Call Budget)**

- **36. Testing Plan: Happy Paths**

- **37. Testing Plan: Missing Slots**

- **38. Testing Plan: Tool Failures**

- **39. Testing Plan: Ambiguity & Low Confidence**

- **40. Debugging Checklist (Common Failures)**

- **41. Evaluation Metrics: Reliability**

- **42. Evaluation Metrics: Latency & Cost**

- **43. Hallucination Prevention Playbook**

- **44. Regression Testing Workflow**

- **45. Versioning & Release Discipline**

- **46. Incident Playbook for Agents**

- **47. Prompt Hygiene (Reasoning Instructions)**

- **48. Clarifier UX Patterns (Fast Clarification)**

- **49. Safety Patterns**

- **50. Acceptance Checklist (Ship-Ready Agent)**

- **51. Template: Restaurant Assistant (Menu + Reservations)**

- **52. Template: Support Agent (Case Creation)**

- **53. Template: IT Helpdesk (Reset + Access Requests)**

- **54. Template: Sales Assistant (Opportunity Notes)**

- **55. Template: Knowledge Q&A (Hallucination-Resistant)**

- **56. Template: Multi-Step Booking (Strict Workflow)**

- **57. Advanced Pattern: Two-Phase Planning**

- **58. Advanced Pattern: Tool Budget & Tool Policy**

- **59. Advanced Pattern: Fallback Router**

- **60. Appendix: Fill-In Sections for Your Org**

        # What Agent Script Is (and Why It Exists)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Agent Script is a block-structured orchestration language for building reliable enterprise agents.
    It is designed to combine:
    - deterministic logic (routing, validations, mandatory steps),
    - LLM reasoning (interpretation, summarization, decision among allowed tools),
    - tool execution (Apex, Flows, Prompt Templates, APIs).

    **Core principle:** never let the LLM “decide” business rules; enforce those with deterministic logic.



---


        # Mandatory Blocks: config, system, variables, start_agent, topic

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Most agents should have:
    - `config` (identity + runtime settings)
    - `system` (global messages; **welcome** and **error** required)
    - `variables` (mutable + linked variables)
    - `start_agent` (entrypoint + initial routing)
    - multiple `topic` blocks (small, single-purpose units)

    Design heuristic: keep `topic_selector` small and push logic into specialist topics.



---


        # Indentation & Syntax Discipline (Deployment-Safe)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    **Rule:** Be consistent with indentation and block structure.
    - Use the indentation convention required by your org/tooling (some deployments are strict).
    - Keep nested blocks aligned and predictable.

    **Quality gate:** run a simple pre-commit formatter (even a whitespace check) to prevent broken deploys.



---


        # system.welcome and system.error as Guardrails

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    `system.welcome` sets user expectations and can introduce capabilities/limits.
    `system.error` is the global fallback when tools fail or parsing breaks.

    Best practice:
    - welcome: short, capability-scoped
    - error: apologetic + next step (retry, rephrase, escalate)



---


        # Variables: Mutable vs Linked

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    **Mutable variables** store conversational state (slots and intermediate outputs).
    **Linked variables** reference Salesforce context (e.g., user identity, record context).

    Suggested naming:
    - mutable: `reservation_date`, `party_size`, `intent`, `confidence`
    - linked: `context_user_id`, `context_contact_id`, `context_record_id`

    Store tool outputs into variables explicitly so downstream topics are deterministic.



---


        # Template Expressions (Dynamic Values)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Use template expressions to inject variables into messages and instructions.

    Pattern:
    - Keep messages user-friendly; avoid dumping raw JSON outputs.
    - Use templates for personalization and confirmations.

    Example idea:
    - “Okay {!@variables.name}, I can book a table for {!@variables.party_size}.”



---


        # start_agent Responsibilities

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    `start_agent` runs on every user message (including the first).
    Common responsibilities:
    - initialize missing variables
    - run “gatekeeper” checks (identity, eligibility)
    - route to topic_selector (or a required workflow)

    Anti-pattern: doing too much in `start_agent`. Keep it minimal.



---


        # Topic Design: One Job per Topic

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    A topic should do exactly one thing:
    - Menu lookup
    - Reservation booking
    - Policy Q&A
    - Directory search
    - Escalation

    Benefits:
    - easier debugging
    - reusable specialist topics
    - predictable behavior and lower token cost



---


        # Deterministic Logic vs LLM Reasoning

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    **Deterministic logic**: validations, required steps, routing, final confirmations
    **LLM reasoning**: interpret intent/entities, choose among allowed tools, draft a response

    Golden rule:
    - If the user must do X before Y, enforce it deterministically via conditions + transitions.



---


        # After Reasoning: Deterministic Post-Processing

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Use `after_reasoning` for:
    - final tool calls after the LLM produces a plan
    - consistent cleanup (reset temp vars)
    - structured logging variables

    Keep it deterministic and safe.



---


        # Pattern: Router (topic_selector)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Router pattern:
    - `topic_selector` receives the user request
    - chooses a specialist topic
    - transitions to it

    Keep routing decisions simple:
    - a small set of top-level intents
    - a fallback topic for “unknown”



---


        # Pattern: Gatekeeper (Identity Verification)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Gatekeeper pattern:
    - In `start_agent`, check `is_verified`
    - If not verified, transition to `identity_verification`
    - Only after verification do you allow sensitive topics/tools

    This should be deterministic, not LLM-driven.



---


        # Pattern: Slot Filling (Entity Capture)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Slot filling minimizes back-and-forth:
    - extract date/time/party size/name from user text
    - ask only for missing required slots

    Good slot design:
    - explicit required slots per workflow
    - quick, single-question prompts



---


        # Pattern: Required Workflow (Mandatory Steps)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    When a step is mandatory (e.g., verifying identity, collecting date+party size),
    enforce it with deterministic transitions and guards.

    Avoid relying on tool availability filtering alone to enforce required steps.



---


        # Pattern: Specialist Delegation (Call-and-Return)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Use delegation when you want a topic to consult another topic and return.

    Example:
    - reservation_agent delegates to policy_checker to validate constraints
    - then returns to reservation_agent to proceed



---


        # Pattern: Escalation (Human Handoff)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Always include an escalation topic:
    - user asks for something disallowed
    - tool failures
    - low confidence or repeated misunderstanding

    Escalation UX:
    - apologize
    - summarize what you understood
    - ask user’s preferred handoff method (if applicable)



---


        # Confidence & Ambiguity Strategy

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Use a consistent ambiguity strategy:
    - detect low confidence intent/entity extraction
    - ask one clarifying question
    - offer 2–4 options, not an open-ended “what do you mean?”

    Track:
    - `clarification_count`
    - after 2 clarifications → escalate



---


        # State Machine Thinking (Reliable Agents)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Model your agent as a state machine:
    - states = topics
    - transitions = edges
    - guards = conditions
    - actions = tools

    Benefits:
    - easier validation
    - fewer loops
    - better observability



---


        # Topic Graph Checklist

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Before coding:
    - list top intents
    - map intents → topics
    - define required slots
    - define required workflow edges
    - define escalation triggers

    Keep the graph under ~10 topics unless you truly need more.



---


        # Minimal Working Scaffold Template

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Scaffold should include:
    - start_agent → topic_selector
    - one Q&A topic
    - one tool-calling topic
    - escalation topic
    - TODO placeholders for org-specific targets

    Use this as your default “just generate” response.



---


        # Actions: Apex Targets

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Apex actions call server-side logic.

    Target format (conceptual):
    - apex://Namespace.ClassName

    Best practices:
    - small, deterministic Apex methods
    - validate inputs in Apex too
    - return typed outputs when possible



---


        # Actions: Flow Targets

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Flow actions invoke declarative workflows.

    Target format (conceptual):
    - flow://ApiNameOfFlow

    Best practices:
    - use Flow for orchestration across objects
    - keep agent-specific validation in Agent Script
    - surface Flow errors cleanly



---


        # Actions: Prompt Templates

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Use Prompt Templates for:
    - summarization
    - rewriting / tone
    - structured extraction (if your stack supports it)

    Avoid using prompts for deterministic validations.



---


        # Tool Choice: Deterministic vs LLM-Selectable

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Decide whether an action should be:
    - deterministic (always run for this topic), or
    - an LLM tool (optional; used when helpful)

    Default: deterministic for required steps; tool for optional fetches.



---


        # Inputs/Outputs Mapping Discipline

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Always map:
    - inputs from variables
    - outputs into variables

    Never rely on “implicit” tool outputs.
    Keep output schemas stable to reduce downstream parsing.



---


        # Tool Availability Filtering

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Use availability filtering to hide tools unless conditions are met.

    Use cases:
    - user is verified
    - required slots are present
    - org configuration supports a feature

    Do NOT use availability filtering as the only enforcement of a required workflow.



---


        # Action Chaining Pattern

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    When you need multiple lookups:
    - run an initial tool to fetch record context
    - then run a secondary tool for computed results
    - then respond to the user

    Keep chains short and include timeouts/retries in the backend where appropriate.



---


        # Idempotency and Retries

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    For create/update actions:
    - design idempotent operations when possible
    - avoid double-creating records on retries
    - store a `last_action_id` or `last_request_hash` variable if needed



---


        # External API Orchestration (Safely)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    If your agent calls external APIs:
    - validate inputs before calling
    - sanitize outputs before showing users
    - timebox calls
    - provide graceful fallback and escalation



---


        # Structured Outputs Strategy

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Prefer tools returning structured outputs:
    - status
    - message
    - data object
    - error object

    Map to variables:
    - `tool_status`
    - `tool_error_code`
    - `tool_payload`



---


        # Sensitive Data Handling

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Never:
    - expose raw IDs unless user expects them
    - show internal error traces
    - reveal restricted fields

    Always:
    - summarize safely
    - require verification before sensitive access



---


        # Multi-Channel UX (Chat vs Case vs Voice)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    If the same agent is used across channels:
    - keep responses short
    - avoid huge lists
    - include confirmation prompts where needed
    - maintain consistent tone



---


        # Tool Naming Conventions

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Use tool/action names that are:
    - verb-first: `lookup_menu_items`, `create_reservation`, `get_policy_answer`
    - consistent across topics
    - easily discoverable by the LLM



---


        # Logging & Observability Variables

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Track:
    - `intent`
    - `confidence`
    - `selected_topic`
    - `tool_calls` (count)
    - `last_error`
    - `clarification_count`

    This helps debugging and evaluation.



---


        # Cost Control Playbook (LLM Call Budget)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Techniques:
    - route early using lightweight logic
    - keep topics small
    - avoid repeated re-asking
    - prefer deterministic transitions
    - do retrieval/tools only when needed



---


        # Testing Plan: Happy Paths

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    For each top intent:
    - provide one happy-path test
    - include a tool success output
    - verify variables updated correctly



---


        # Testing Plan: Missing Slots

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Test missing slot scenarios:
    - no date
    - no party size
    - ambiguous restaurant name
    - incomplete user identity

    Validate the agent asks exactly one question at a time.



---


        # Testing Plan: Tool Failures

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Simulate:
    - Apex exception
    - Flow fault
    - API timeout

    Expected:
    - safe error message
    - retry suggestion (optional)
    - escalation after repeated failure



---


        # Testing Plan: Ambiguity & Low Confidence

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Provide utterances that are:
    - vague (“help me”)
    - multi-intent (“book and tell me menu”)
    - conflicting entities

    Validate:
    - clarifying question
    - or deterministic prioritization rules



---


        # Debugging Checklist (Common Failures)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Common issues:
    - indentation / parsing failures
    - missing topic references
    - tool target typos
    - input/output mapping mismatch
    - loops due to missing state updates

    Fix by:
    - validate topic graph
    - validate variable schema
    - add logging variables



---


        # Evaluation Metrics: Reliability

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Reliability metrics:
    - task success rate
    - tool success rate
    - escalation rate
    - “repeat question” rate

    Add a “golden set” of test utterances for regression.



---


        # Evaluation Metrics: Latency & Cost

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Latency drivers:
    - number of LLM calls
    - number of tool calls
    - large prompts

    Track:
    - turns per resolution
    - average tools per turn
    - average token usage (if available)



---


        # Hallucination Prevention Playbook

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Prevention tactics:
    - deterministic routing and validation
    - strict tool schemas
    - “don’t invent” instruction
    - fallback to knowledge Q&A for policy answers
    - always escalate when uncertain



---


        # Regression Testing Workflow

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Create:
    - a test sheet of utterances + expected topic + expected actions
    - rerun tests after every prompt/tool change
    - track drift in routing decisions



---


        # Versioning & Release Discipline

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Best practices:
    - version your agent scripts in git
    - tag releases with change notes
    - keep a changelog of tool schema changes
    - use feature flags for high-risk tools



---


        # Incident Playbook for Agents

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    When an agent fails in production:
    - capture conversation snippet
    - capture variables and chosen topic
    - check tool logs
    - reproduce with a test harness
    - add a regression test case



---


        # Prompt Hygiene (Reasoning Instructions)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Keep reasoning instructions:
    - short
    - specific
    - structured (bullets)
    - tool-aware (“use tool X only when…”)

    Avoid:
    - long policy essays
    - conflicting instructions



---


        # Clarifier UX Patterns (Fast Clarification)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Good clarifier:
    - one question
    - offers options
    - confirms what’s already known

    Example:
    - “Do you mean Sushi Zen (Capitol Hill) or Sushi Zen (Bellevue)?”



---


        # Safety Patterns

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Always include:
    - escalation
    - safe refusal for disallowed requests
    - sensitive data checks
    - minimal exposure of internal details



---


        # Acceptance Checklist (Ship-Ready Agent)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Ship-ready checklist:
    - all required topics exist
    - escalation works
    - tool schemas stable
    - slot filling works
    - tests passing
    - clear system.welcome and system.error



---


        # Template: Restaurant Assistant (Menu + Reservations)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Include topics:
    - topic_selector
    - menu_lookup
    - reservation_booking
    - policy_qa
    - directory_search
    - escalation

    Required slots for reservations:
    - date, time, party_size, name/contact



---


        # Template: Support Agent (Case Creation)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Include topics:
    - classify_issue
    - gather_details
    - create_case (Flow/Apex)
    - case_status
    - escalation

    Required slots:
    - subject, description, severity, contact



---


        # Template: IT Helpdesk (Reset + Access Requests)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Include:
    - identity_verification
    - request_type_router
    - reset_password
    - access_request
    - escalation

    Always gate sensitive operations behind verification.



---


        # Template: Sales Assistant (Opportunity Notes)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Include:
    - record_context_loader (linked vars)
    - summarize_opportunity (prompt template)
    - next_steps_generator (prompt template)
    - update_crm_action (Flow/Apex)
    - escalation



---


        # Template: Knowledge Q&A (Hallucination-Resistant)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Include:
    - retrieval_topic (tools: search + fetch)
    - answer_topic (cite from retrieval outputs)
    - fallback_clarifier
    - escalation

    Never fabricate policies. If retrieval is empty → escalate or ask for more detail.



---


        # Template: Multi-Step Booking (Strict Workflow)

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Workflow:
    - collect slots
    - validate slots
    - confirm with user
    - execute booking tool
    - present confirmation

    Make validation deterministic; LLM only helps interpret user text.



---


        # Advanced Pattern: Two-Phase Planning

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Phase 1 (LLM):
    - interpret and propose plan (no tool calls)
    Phase 2 (Deterministic):
    - execute required tools in order

    Benefits:
    - predictable execution
    - easier debugging



---


        # Advanced Pattern: Tool Budget & Tool Policy

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Set a tool budget per turn (e.g., max 2 tool calls).
    If budget exceeded:
    - summarize what’s known
    - ask user to confirm
    - or escalate

    Keeps latency/cost under control.



---


        # Advanced Pattern: Fallback Router

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    When topic_selector can’t decide:
    - route to a generic clarifier topic
    - ask a single question with options
    - then transition deterministically



---


        # Appendix: Fill-In Sections for Your Org

        _Pack:_ Agent Script — Senior Agentforce Engineer Knowledge Base
        _Generated:_ 2026-03-05


    Replace TODOs with your org specifics:
    - available Apex classes (targets)
    - available Flows (API names)
    - objects/fields allowed
    - data access constraints
    - escalation mechanism (case, queue, live agent, etc.)

    Keep this appendix updated as your org evolves.



---



# AgentScript Technical Reference

# Agent Script Fundamentals (Blocks, Messages, Variables)

## What Agent Script is
Agent Script is a block-structured language used to build reliable agent workflows by combining:
- text instructions for conversational behavior, and
- programmatic constructs (expressions, conditions, transitions, variables).

## Core blocks you'll use in almost every agent

### `config`
Defines agent identity and runtime settings.
- `developer_name`: API name, max 80 chars, starts with a letter, alphanumeric/underscore only, no trailing underscore or consecutive underscores.
- `default_agent_user`: API name or ID of default user used to run the agent (required for service agents; ignored for employee agents).

**Tip:** Keep config minimal; don't put business logic here.

### `system`
Global agent instructions and messages.
- `welcome` and `error` messages are required.
- Multiline messages use `|`.
- You can inject dynamic values using template expressions like `{!@variables.userPreferredName}`.

### `start_agent`
Entry point for every request (including the first request).
Typically used to:
- initialize variables
- perform topic classification (route to the right topic)

### `topic`
Encapsulates one “unit” of conversational work (menu lookup, reservation booking, FAQ/policy, etc).
A topic commonly includes:
- deterministic logic (conditions, transitions, variable sets)
- a reasoning section (LLM prompt instructions)
- optional actions/tools
- optional `after_reasoning` to run things after a topic exits

## Variables & template expressions
- Use variables to store state between turns and across topic transitions.
- Use template expressions `{! ... }` to inject variable values into user-facing messages and prompts.

## Minimal agent skeleton (illustrative)

```ascript
config:
  developer_name: My_Agent
  default_agent_user: User_Alias_or_Id

system:
  welcome: "Hi {!@variables.userPreferredName}! How can I help?"
  error: "Sorry—something went wrong. Please try again."

variables:
  userPreferredName: string

start_agent:
  topic: topic_selector

topic topic_selector:
  instructions: |
    Decide which topic best handles the user request.


Article 1: Syntax & Structural Rules
The 3-Space Rule: All nested blocks (under topics, reasoning, actions) must use exactly three spaces. Standard 2 or 4-space tabs will cause deployment errors.

Variable Types: * mutable: Use for data collected during the chat (e.g., case_reason).

linked: Use for context passed from Salesforce (e.g., $User.ContactId).

The System Block: Must explicitly define welcome and error messages. These are the fallback strings for the entire agent session.

Article 2: Action Integration (Apex & Flow)
Targeting: * Apex: target: "apex://Namespace.ClassName"

Flow: target: "flow://ApiNameOfFlow"

Input/Output Mapping: Every action must explicitly map variables.

Example: inputs: { recordId: @variables.id }

Action Chaining: You can execute multiple run commands in a single reasoning block to perform complex lookups before the LLM speaks to the user.

Article 3: Agentforce Patterns & Recipes
Pattern: The Gatekeeper (Identity Verification)

Used to protect sensitive topics. The start_agent block checks a is_verified boolean. If false, it redirects all intents to the identity_verification topic.

Pattern: The Router (Topic Classification)

The start_agent block acts as a traffic controller. It uses natural language descriptions in each topic to decide where to send the user via @utils.transition.

Pattern: Slot Filling

Using @utils.setVariables within the reasoning to extract entities (dates, names, numbers) directly from the user's last utterance without needing multiple "Question/Answer" nodes.

What this achieves:
Higher Accuracy: The GPT will now say, "I see you want to create a case. What fields (Subject, Description, etc.) should I include in the Flow call?"

Context Awareness: By having the "Patterns" in its knowledge base, it won't just write code; it will follow Salesforce-recommended design patterns.


---



# Custom GPT System Prompt

# Custom GPT System Prompt — Agent Script Builder (Ready to Paste)

You are **AgentScript Architect**, a senior Salesforce Agentforce engineer specializing in **Agent Script** authoring, debugging, and refactoring.

## Mission
Given:
- **requirements** (what the agent must do),
- **configuration** (org context, available actions/flows/apex/prompt templates, objects/fields),
- **constraints** (guardrails, allowed data, tone, performance/cost limits),
you will produce **correct, production-ready Agent Script**.

You must **follow the Knowledge Base files** attached to this GPT as the source of truth for Agent Script syntax, block semantics, flow of control, actions/tools, and recommended patterns. If the Knowledge Base is missing a needed detail, say so and propose the safest assumption.

## Non-negotiable rules
1. **Never invent org-specific names.** If an object/field/action/flow/apex class/prompt template isn't provided, you must:
   - either ask for the minimum missing detail (max 5 questions), OR
   - generate a placeholder with an explicit TODO marker and a clearly named stub.
2. **Always separate deterministic logic from LLM reasoning.**
   - Put hard business rules in programmatic logic (conditions, variable setting, deterministic transitions).
   - Use LLM reasoning only for interpretation, summarization, or choosing among **allowed** tools.
3. **Always include guardrails:**
   - safe error message (system.error),
   - escalation path,
   - input validation where needed.
4. **Output must be copy/paste ready.**
   - Produce one complete `.ascript` script with all referenced topics/actions/variables.
   - Keep it concise and well commented.
5. **Determinism preference.** When in doubt, prefer:
   - conditional transitions for required steps,
   - `available when` only to *filter* tool choices (not enforce workflows).

## Required output format
Return exactly these sections in this order:

### A) Assumptions (only if needed)
Bullet list of any assumptions or TODO placeholders.

### B) Topic graph
A compact text diagram like:
start_agent -> topic_selector -> {menu_qa, reservation_flow, policy_qa, escalation}

### C) Agent Script
A single code block containing the full Agent Script.

### D) Test checklist
5–12 bullets describing how to validate the script in Agent Builder (happy paths + failure modes).

## How to interpret a user request
- First, extract: intents, entities, required data, actions needed, constraints.
- Then map intents to topics.
- Decide which actions should be:
  - **topic.actions** (deterministic / always-run),
  - **reasoning.actions/tools** (LLM can choose).
- Add transitions and variable updates.
- Ensure error handling + escalation.

## Style & tone
- Be direct, engineering-first.
- Use short, specific reasoning instructions (avoid long prompt prose).
- Prefer small, focused topics.

## If the user asks “just generate” without details
Generate a scaffold agent with:
- start_agent topic_selector,
- one example Q&A topic,
- one example action/tool topic,
- one escalation topic,
- TODO placeholders for org-specific actions and objects.


---

