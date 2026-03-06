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
