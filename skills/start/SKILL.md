---
name: groundup:start
description: "Session bootstrap for the groundup mentor plugin. Routes the engineer into the correct flow — implementing a ticket, debugging a bug, or scoping a new project — with minimum token load. Also handles resume when a session was interrupted. Use this skill whenever a groundup session is starting or restarting: when the engineer says 'let's start', 'I want to build X', 'I have a bug', 'I'm scoping a new project', or after /clear when context has been lost. Invoke even if the engineer doesn't explicitly say 'start' — if they're clearly kicking off work, this is the right entry point."
when_to_use: "Use at the start of any groundup session, or after /clear to re-establish context. Invoke when the engineer says 'let's start', 'I want to build X', 'I have a bug', or 'I'm scoping a new project'."
---

# Start — Route to the Right Flow

This skill does one job: route the engineer into the correct flow for today's work, as quickly as possible and with no wasted context. The three paths — implement, debug, scope — have almost no overlap in what they need. Loading architecture context before a debugging session wastes tokens; skipping it before exploring an unfamiliar codebase wastes time. This skill makes the call.

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

First, read the engineer's message for intent. If it clearly signals one of the three modes, confirm it rather than asking cold — this saves a turn and feels more natural. If intent is ambiguous, ask the full question.

**When to infer:**

- Signals scope: "I'm thinking about building", "I want to scope", "evaluating whether to build", "new project", "not sure where to start" with no existing codebase mentioned → confirm: *"It sounds like you're scoping out a new project — is that right, or are you jumping into implementation?"*
- Signals debug: "I have a bug", "getting an error", "something is broken", "failing test", "why is X not working" → confirm: *"Looks like you're debugging — shall we start there, or is there something else going on?"* (A quick confirm here avoids routing into the wrong flow if the read is off.)
- Signals implement: "I want to build X", "working on the Y ticket", "implementing Z", "let's add X feature" → confirm: *"Sounds like you're implementing — jumping into that. [Continue with Step 3 implement routing.]"*

**When to ask the full question** (intent is ambiguous or mixed):

> "Which of these describes what you're working on today?
>
> 1. Implementing a new ticket or feature
> 2. Debugging a bug
> 3. Scoping a new project (no codebase yet, or evaluating whether to build something)"

Don't pre-explain the flows either way. One short confirm or one short question — then route.

---

## Step 3 — Route

### Option 1: Implement

**Gate 1 of 3 — Write session state (do this before saying anything else):**

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

**Gate 2 of 3 — Ask the engineer to describe the ticket:**

Ask: "Describe the ticket or feature in your own words. What are you building?"

Wait for their answer before proceeding to Gate 3.

**Gate 3 of 3 — Route based on familiarity:**

- If the engineer is new to this codebase, hasn't worked in it before, or can't name the affected files → invoke `groundup:architecture`, then `groundup:orient`, then `groundup:grill`.
- If the engineer knows the codebase but needs to locate their change → invoke `groundup:orient`, then `groundup:grill`.
- If the engineer can already name the specific files they'll touch with confidence → invoke `groundup:grill` directly.

When in doubt, run orient. It costs one skill load; missing it costs a wrong mental model.

---

### Option 2: Debug

**Gate 1 of 2 — Write session state (do this before saying anything else, before invoking any skill):**

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

Do not proceed to Gate 2 until the file is written. The state write is not optional — it is the first action.

**Gate 2 of 2 — Invoke `groundup:read-the-error`.**

Do not invoke architecture. Do not invoke orient. When debugging, the engineer already knows what's broken — loading codebase orientation context before they've even named the error type wastes the token budget that belongs to the debugging tools.

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

- **Implement (familiar codebase):** `start` → `orient` → `grill` — three skill loads before any code-level work.
- **Implement (unfamiliar):** `start` → `architecture` → `orient` → `grill` — four loads.
- **Debug:** `start` → `read-the-error` — two loads. Architecture and orient are irrelevant.
- **Scope:** `start` + reads `SCOPING.md` — one skill load plus one file read. No codebase to explore.
