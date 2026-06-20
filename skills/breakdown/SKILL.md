---
name: groundup:breakdown
description: "Turns the agreed implementation plan into small, ordered, implementable tickets that the engineer works through one at a time. Invoke immediately after grill exits — once the approach, files, flow, and edge cases are all agreed. Also invoke when the engineer asks 'ok what do I build first?', 'break this into tasks', 'what's the plan?', or 'where do I start?' after the design discussion is complete. Writes .groundup/tickets.md and gets sign-off before the first ticket begins. The per-ticket loop (patterns → pseudocode → implement → tests → review → reflect) replaces the per-file loop — tickets are the unit of work."
---

# Breakdown — Plan the Work Before Building It

Turn the agreed design into tickets the engineer can pick up one at a time. The goal is a plan that removes ambiguity about what to build next, in what order, and what done looks like for each piece.

---

## Step 1 — Confirm You Have Everything

Before creating tickets, verify the grill produced all four of these:

- **Approach** — what we're building and why
- **Files** — which files are being created or modified, and why each one
- **Flow** — how data moves through the change
- **Edge cases** — the failure modes and boundary conditions that must be handled

If any are missing, the grill is not complete. Do not create tickets yet — say: "We haven't agreed on [missing piece] yet. Let's finish that first." Then return to grill.

---

## Step 2 — Create the Tickets

Break the work into tickets. Each ticket is a unit the engineer can complete in one sitting — typically 2–4 hours, touching 1–3 files.

**Ordering rule:** dependency order, not convenience order. Foundational code first, entry points last. The engineer should never be blocked on a ticket because a dependency isn't done yet.

**Typical ordering heuristic:**
1. Data layer (repositories, DB schemas, migrations) — no dependencies on other new code
2. Domain / service layer — depends on repositories
3. Integration / adapters (third-party clients, event publishers) — depends on services
4. Entry points (controllers, queue consumers, CLI handlers) — depends on everything below

**Rules for each ticket:**
- Title is verb-first: "Add", "Implement", "Create", "Update", "Wire up" — never a noun phrase
- Goal is one sentence: what the ticket achieves when it is fully done
- Files are specific paths, not layer names — `src/services/OrderService.ts`, not "the service layer"
- If a ticket would touch more than 3 files, split it
- Acceptance criteria come from the edge cases agreed in grill — not invented here. If an edge case has no ticket that covers it, it has no test. That's a bug in the plan.

**Ticket format:**

```
## Ticket N: [Verb-first title]

**Goal**: [One sentence — what this achieves]
**Files**:
- `path/to/file.ts` — create / modify
**Depends on**: Ticket X, Ticket Y — or "none"
**Acceptance criteria**:
- [ ] [Specific behaviour that must work]
- [ ] [Edge case from grill — must be covered by a test]
```

---

## Step 3 — Append to the Decision Log

Read `session_name` and `log_target` from `.groundup/session-state.json`. Resolve the log path using the same rule as grill (obsidian or local). The file already exists from grill — append to it:

```markdown

---

## Ticket Breakdown

Created: <ISO 8601 date>

### Ordering Rationale

<one paragraph: why the tickets are ordered this way — what the dependencies are, what must exist before what>

### Tickets

<for each ticket: one line with the title and the one-sentence goal>
- Ticket 1: <title> — <goal>
- Ticket 2: <title> — <goal>
```

---

## Step 4 — Write `.groundup/tickets.md`

Create `.groundup/` if it doesn't exist. Write the file:

```
# Tickets — [brief descriptor]

Created: [ISO 8601 date]

## What We're Building

[2–3 sentences: the agreed approach and why the tickets are ordered this way]

---

[Ticket 1 in full format]

---

[Ticket 2 in full format]

---
```

---

## Step 5 — Present and Get Sign-Off

Present the breakdown to the engineer:

> "Here's how I've broken this into [N] tickets. We start with [Ticket 1 title] because [reason — no dependencies / others depend on it]. [Briefly note the ordering logic.] Does this feel right — anything you'd split, combine, or reorder?"

This is a genuine question. The engineer may know something about the codebase or the task that changes the right order. If they suggest a change, update the file and confirm the revision before starting.

Once they confirm, say: "Good. Let's start with Ticket 1." Then proceed to Step 6.

---

## Step 6 — Update Session State and Begin

Update `.groundup/session-state.json` — add `current_ticket` and `tickets_file` to what's already there:

```json
{
  "phase": "per_ticket_loop",
  "current_ticket": 1,
  "tickets_file": ".groundup/tickets.md"
}
```

Begin Ticket 1 immediately. For each ticket, the loop is:

1. **Patterns** — invoke `groundup:patterns`. Does this ticket's work map to a known industry pattern? Surface it before pseudocode is written.
2. **Pseudocode** — invoke `groundup:pseudocode` for each file in the ticket, in dependency order within the ticket. Pseudocode before any implementation.
3. **Implement** — engineer implements. Syntax help only if explicitly asked.
4. **Tests** — engineer writes tests. Acceptance criteria from the ticket must be covered.
5. **Review** — per-file code review. Do not start until tests exist.
6. **Reflect** — invoke `groundup:growth-review`. One targeted reflection question.

**When a ticket is complete:**

Mark it done in `.groundup/tickets.md` — add `**Status: done**` under the ticket heading and check off the acceptance criteria that passed.

Update session state: increment `current_ticket`.

Say: "Ticket [N] is done. [Brief note on what was built.] Moving to Ticket [N+1]: [title]." Then begin the next ticket's loop.

**When all tickets are done:**

Set `phase` to `"final_review"` in session state.

Say: "All tickets are complete. Let's run a final review across the full changeset before opening a PR." Then run `/code-review` across all changed files.
