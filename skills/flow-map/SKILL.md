---
name: flow-map
description: "Engineer draws the data flow. Claude and engineer discuss it together. Only when both agree does Claude produce the canonical diagram and ordered file list."
---

# Flow Map — Data Flow Discussion

The engineer draws the flow. You and the engineer interrogate it together. Neither side writes code until both can sign off on the agreed diagram.

This is the contract. The pseudocode comes from the contract.

---

## Why This Matters for Junior Engineers

Data flow through a system — especially microservices — is the hardest thing to see when you're learning. It's easy to understand what a single function does. It's much harder to understand:

- Where data enters the system and what shape it arrives in
- Which service owns what
- Where the transaction boundary sits
- What happens when one piece fails
- Which calls are synchronous vs asynchronous and why

Drawing the flow before writing a line of code makes all of this visible. Bugs that would have taken hours to debug are caught here, in a diagram, in minutes.

---

## Engineer's Job

Ask the engineer to describe the flow in ASCII or prose — whatever comes naturally:

> "Request comes in → service A validates → calls service B → B writes to DB → emits event → consumer updates read model"

This is their starting point. It does not need to be correct. That's what the discussion is for.

---

## Your Job — Interrogate the Flow

For every step in the flow, ask the questions a senior engineer asks automatically:

**On availability:**
- "What happens if [service / DB / queue] is unavailable at step N?"
- "Is this call synchronous? Does the caller block waiting for the response?"

**On ownership:**
- "Which service owns this data? Who else writes to it?"
- "Where does this transaction start and end?"

**On correctness:**
- "What does 'success' look like here? What does the caller receive back?"
- "What does 'failure' look like? What happens downstream when it fails?"
- "Can this be called more than once with the same input? What happens if it is?"

**On design:**
- "Is this the right direction for this call? Could service B call A instead of A calling B?"
- "Should this be synchronous or asynchronous? What's the tradeoff?"

---

## Check for Patterns During This Step

Before agreeing on the final diagram, check: does any step in this flow map to a well-known industry pattern?

If yes, **invoke `patterns` before locking the diagram**. The engineer should know the established approach before committing to a design. A flow diagram that ignores the outbox pattern or uses synchronous calls where async is the right model will produce code that is harder to fix later.

---

## Proposing Amendments

If something in the flow is wrong or suboptimal, propose an amendment with an explanation — not just a correction:

> "In your diagram, service A synchronously calls service B and waits for the DB write to complete before responding to the client. That means the client's request time includes B's DB latency. Consider: should A publish an event and return immediately, with B processing asynchronously? The tradeoff is eventual consistency — does that work for this use case?"

The engineer decides. You explain the options.

---

## The Contract

When both of you agree on the flow:

1. Produce the canonical Mermaid diagram (flowchart TD)
2. List the affected files in **dependency order** — the order in which they will be implemented
3. State the order explicitly: "We'll start with X because it has no dependencies on the other files. Then Y, then Z."

This ordered file list is the implementation plan. Do not deviate from it unless new information changes the dependencies.

**Output format:**
```
Flow:
[ASCII diagram]

Implementation order:
1. path/to/file-a.ts   — reason: no dependencies, others depend on it
2. path/to/file-b.ts   — reason: depends on file-a
3. path/to/file-c.ts   — reason: depends on file-b, entry point
```

---

## After the Flow Is Agreed

Invoke the `pseudocode` skill for the first file in the implementation order.
