---
name: groundup:start
description: "Session bootstrap for the groundup mentor plugin. Routes the engineer into the correct flow — implementing a ticket, debugging a bug, or scoping a new project — with minimum token load. Also handles resume when a session was interrupted. Use this skill whenever a groundup session is starting or restarting: when the engineer says 'let's start', 'I want to build X', 'I have a bug', 'I'm scoping a new project', or after /clear when context has been lost. Invoke even if the engineer doesn't explicitly say 'start' — if they're clearly kicking off work, this is the right entry point."
when_to_use: "Use at the start of any groundup session, or after /clear to re-establish context. Invoke when the engineer says 'let's start', 'I want to build X', 'I have a bug', or 'I'm scoping a new project'."
---

# Start — Route to the Right Flow

This skill does one job: route the engineer into the correct flow for today's work, as quickly as possible and with no wasted context. The three paths — implement, debug, scope — have almost no overlap in what they need. Loading codebase context before a debugging session wastes tokens; skipping it before an implementation session means guiding without knowing the terrain. This skill makes the call.

---

## Step 1 — Check for a Session in Progress

Before asking anything, check whether `.groundup/session-state.json` exists in the current working directory and read it.

If it exists and `phase` is not `"complete"`:

> "You have a session in progress: **[task from state]**.
> You left off at **[phase in plain English — see translations below]**. Resume from here, or start something new?"

Phase plain-English translations:
- `grill` → "the design interview (we hadn't agreed on the approach yet)"
- `flow_map` → "drawing the data flow"
- `per_file_loop` → "the per-file implementation loop — you were working on `[current_file]`"
- `final_review` → "the final code review before opening a PR"
- `debugging` → "debugging"
- `scoping` → "scoping the project (scope.md may already be partially written)"

**Stop here and wait for the engineer's answer.** Do not continue until they explicitly say resume or start fresh. The choice must be real — do not auto-resume.

If they want to **resume**: read the state fully, orient to the current phase and file, and continue from exactly that point. Do not restart grill or flow-map if they are recorded as complete — trust the state.

If the phase is `"complete"` or the file doesn't exist: proceed to Step 2.

---

## Step 2 — Determine the Mode

Read the engineer's message for intent. If it clearly signals one of the three modes, confirm it rather than asking cold — this saves a turn and feels more natural. If intent is ambiguous, ask the full question.

**When to infer:**

- Signals scope: "I'm thinking about building", "I want to scope", "evaluating whether to build", "new project", "not sure where to start" with no existing codebase mentioned → confirm: *"It sounds like you're scoping out a new project — is that right, or are you jumping into implementation?"*
- Signals debug: "I have a bug", "getting an error", "something is broken", "failing test", "why is X not working" → confirm: *"Looks like you're debugging — shall we start there, or is there something else going on?"*
- Signals implement: "I want to build X", "working on the Y ticket", "implementing Z", "let's add X feature" → confirm: *"Sounds like you're implementing — let me get familiar with the codebase first, then we'll dig in."*

**When to ask the full question** (intent is ambiguous or mixed):

> "Which of these describes what you're working on today?
>
> 1. Implementing a new ticket or feature
> 2. Debugging a bug
> 3. Scoping a new project (no codebase yet, or evaluating whether to build something)"

Don't pre-explain the flows. One short confirm or one short question — then route.

---

## Step 3 — Route

### Option 1: Implement

**Gate 1 of 4 — Write session state (do this before anything else):**

Create `.groundup/` if it doesn't exist. Write `.groundup/session-state.json`:

```json
{
  "mode": "implement",
  "task": null,
  "phase": "grill",
  "current_file": null,
  "files": [],
  "skipped_gates": [],
  "flow_diagram": null,
  "scope_file": null,
  "updated_at": "<ISO 8601 now>"
}
```

Do not proceed to Gate 2 until the file is written.

---

**Gate 2 of 4 — Read or build the codebase map:**

Check whether `.groundup/codebase-map.md` exists.

**If it exists — read and surface:**

Read the file silently. Then say:

> "I've read my codebase map from [date in the map]. [2–3 sentences: what kind of system it is, the main layers, one distinctive thing about how it's structured.] Anything out of date before we start?"

Wait one turn for their answer. Incorporate any corrections, then proceed to Gate 3.

**If it does not exist — explore and write:**

Read the codebase deeply before asking the engineer anything. Do not ask them to explain the system to you — go find the answers yourself. This is your job: become the expert so you can guide like one.

*What to explore:*

- **Entry points**: where does the system start? HTTP controllers, queue consumers, CLI entrypoints, scheduled jobs — find them all with file paths
- **Directory structure**: what lives where, what the layout reveals about intent
- **Domain concepts**: the central entities, models, or business concepts — where defined, where used
- **Layers and boundaries**: the named layers (controllers, services, repositories, domain, infrastructure), the dependency direction, any clear seams between them
- **Data access**: how the system reads and writes data, what patterns it uses (repository, active record, raw queries)
- **Testing structure**: where tests live, what patterns they use (unit, integration, mocks, real DB), what's well-covered, what looks sparse
- **Patterns in use**: design patterns that appear consistently (dependency injection, factory, observer, outbox, saga, etc.)
- **External dependencies**: third-party APIs or services the system calls out to, how those calls are structured
- **Downstream consumers**: who calls into this system, if identifiable from the code
- **Passive observations**: note any code smells, missing coverage, or inconsistencies as you read — record them at the bottom of the map file under "Passive Observations". Do not surface these during the session.

*Write `.groundup/codebase-map.md` using this structure:*

```
# Codebase Map

Generated: [ISO 8601 timestamp]

## System Overview

[2–3 sentences: what kind of system, what domain, what it does]

[ASCII art diagram of the main layers or services.
 Use plain characters only: +, -, |, v, ^, >, <
 No Mermaid. Must render in any terminal or editor.]

Example — layered monolith:

    +---------------------+
    |   HTTP Controllers  |
    +---------------------+
              |
              v
    +---------------------+
    |    Service Layer    |
    +---------------------+
              |
              v
    +---------------------+
    |    Repositories     |
    +---------------------+
              |
              v
    +---------------------+
    |      Database       |
    +---------------------+

Example — distributed:

    +-------------+         +---------------+
    | API Gateway | ------> | Auth Service  |
    +-------------+         +---------------+
          |
          v
    +-------------+         +---------------+
    | Order Svc   | ------> | Payment Svc   |
    +-------------+         +---------------+
          |                        |
          v                        v
    +-------------+         +---------------+
    |  Orders DB  |         |  Payments DB  |
    +-------------+         +---------------+
          |
          v (publishes)
    +-------------+         +---------------+
    | Event Queue | ------> |  Notify Svc   |
    +-------------+         +---------------+

## Entry Points

- [file:line] — [what arrives here and from where]

## Domain Concepts

- [Entity name] — [what it represents | file:line where defined]

## Layers and Boundaries

[How the system is layered. Dependency direction. Any clear seams or abstractions between layers.]

## Data Access

[How reads and writes happen. What patterns are used. What the data store is.]

## Testing Structure

- Test location: [where test files live]
- Patterns: [unit / integration / mocks / real DB / test containers]
- Coverage: [what is well-tested, what appears sparse or untested]

## Patterns in Use

- [Pattern name]: [where applied — file:line for a concrete example]

## External Dependencies

- [Service or API]: [what it's used for | file:line for the integration point]

## Key Files Reference

- [path]: [what it does and why it matters]

---

## Passive Observations

*Internal reference only. Do not surface during the session.*

### Code Smells

- [observation with file reference]

### Missing Test Coverage

- [area or file with sparse or absent tests]

### Inconsistencies

- [structural, naming, or pattern inconsistency observed]
```

After writing the file, say:

> "I've mapped the codebase. [3–4 sentences: what kind of system, how it's layered, what the testing approach looks like, one distinctive structural thing.] Tell me what you're working on."

Do not share the Passive Observations. Proceed to Gate 3.

---

**Gate 3 of 4 — Ask the engineer to describe the ticket:**

Ask: "Describe the ticket or feature in your own words. What are you building?"

Wait for their answer before proceeding.

---

**Gate 4 of 4 — Route based on the engineer's familiarity:**

Claude already knows the codebase from Gate 2. The question now is whether the *engineer* knows where their change lands.

- If the engineer can name the specific files they'll touch → invoke `groundup:grill` directly.
- If the engineer can't name the files, isn't sure where to start, or is new to this codebase → invoke `groundup:orient`, then `groundup:grill`.

Note: `groundup:architecture` is no longer needed as an automatic prerequisite here — Claude already has architectural context from the codebase map. Architecture remains available as a standalone skill for sessions where you want to interrogate the engineer on *why* the system is shaped the way it is, not just where to find things.

---

### Option 2: Debug

**Gate 1 of 2 — Write session state (first action, no exceptions):**

Create `.groundup/` if it doesn't exist. Write `.groundup/session-state.json`:

```json
{
  "mode": "debug",
  "task": null,
  "phase": "debugging",
  "current_file": null,
  "files": [],
  "skipped_gates": [],
  "flow_diagram": null,
  "scope_file": null,
  "updated_at": "<ISO 8601 now>"
}
```

**Gate 2 of 2 — Invoke `groundup:read-the-error`.**

Do not build or read the codebase map. When debugging, the engineer already knows what's broken — getting to the error fast is more valuable than orientation, and the debugging flow provides context as it needs it.

---

### Option 3: Scope

Write `.groundup/session-state.json` immediately:

```json
{
  "mode": "scope",
  "task": null,
  "phase": "scoping",
  "current_file": null,
  "files": [],
  "skipped_gates": [],
  "flow_diagram": null,
  "scope_file": ".groundup/scope.md",
  "updated_at": "<ISO 8601 now>"
}
```

Then say: "Let me read the scoping guide." Read `SCOPING.md` (in this same directory). Run the scoping flow from that file inline — no other skill is invoked.

The scoping flow is self-contained because there's no codebase to explore yet. Everything the engineer knows lives in their head. The job is to make that knowledge explicit, structured, and complete enough to drive the first real implementation session.

---

## Token Economy

- **Implement (map exists):** `start` reads map → `orient` (if needed) → `grill`. Fast path — map was paid for in a prior session.
- **Implement (no map):** `start` explores codebase → writes map → `orient` (if needed) → `grill`. One-time exploration cost, paid once per codebase.
- **Debug:** `start` → `read-the-error`. Two loads. Codebase map adds no value here.
- **Scope:** `start` + reads `SCOPING.md`. One skill load plus one file read. No codebase to explore.
