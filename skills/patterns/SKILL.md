---
name: patterns
description: "Surfaces known industry patterns before the engineer commits to an approach — during flow-map discussion and before pseudocode for each file. Never as hindsight in code review."
when_to_use: "Use during flow-map before the diagram is agreed (does any step map to a known pattern?), and before writing pseudocode for each file (does this function have a known best practice?). Use when the engineer is about to implement something that has a standard solution — batching, outbox, retry, guard clauses, N+1, etc."
---

# Patterns — Contextual Teaching

Surface patterns at the moment they matter: **before the engineer commits to an approach**, not after they've implemented something you could have told them about earlier.

Engineers should always be striving for best practice. Discovering a pattern in code review is late. Discovering it during flow discussion or before pseudocode means they can apply it intentionally from the start.

---

## When to Invoke This Skill

### Trigger 1 — During Flow Map

Before agreeing on the final flow diagram: does any step in this flow map to a known industry pattern?

Look for:
- "writes to DB and then calls another service / emits an event" → outbox pattern
- "calls multiple downstream services before responding" → fan-out, consider async
- "processes items one at a time in a loop" → batching
- "retries on failure" → retry with backoff, circuit breaker
- "needs to handle the same request twice safely" → idempotency
- "updates shared state from multiple services" → optimistic vs pessimistic locking
- "soft-deletes records" → soft delete pattern, audit log

Teach the pattern **before the diagram is agreed**. The engineer should know the established approach before they lock in a design that ignores it.

### Trigger 2 — Before Pseudocode for Each File

Before writing pseudocode for a specific function: does this function have a well-known best practice?

Look for:
- "fetches related records in a loop" → N+1 query problem, batched fetching
- "inserts records one at a time" → batch inserts
- "multiple nested if/else conditions" → guard clauses / early return
- "checks a condition then performs action on an object" → tell-don't-ask
- "long parameter list" → parameter object, builder pattern
- "reads from cache, falls back to DB" → cache-aside / read-through
- "streams large datasets" → streaming vs buffering

Name it before pseudocode is written so the engineer applies it deliberately.

---

## Teaching Format

For every pattern, follow this sequence. Do not skip steps.

### 1. Name it
> "This is the **outbox pattern**."

### 2. Explain when it applies
> "Used when you need to atomically write to your database and reliably publish an event. Without it, you can write to the DB and then fail before publishing — or publish and then fail before writing — leaving the two systems inconsistent."

### 3. Show the tradeoff
> "It guarantees delivery and consistency, but adds operational complexity: you need a background worker polling the outbox table and a mechanism to ensure events are processed exactly once (or at least once with idempotent consumers)."

### 4. Ask if they've seen it
> "Have you seen this pattern before? Can you think of anywhere else in this codebase where the same problem exists?"

### 5. Let them apply it
Do NOT rewrite their pseudocode or code. Explain the pattern. The engineer applies it themselves.

---

## Patterns Reference

See `docs/patterns-library.md` for the full and growing reference. Seed categories:

### Resilience
- **Outbox pattern** — atomic DB write + reliable event publishing
- **Retry with exponential backoff** — retry transient failures without thundering herd
- **Circuit breaker** — fail fast when a downstream dependency is unavailable
- **Idempotency keys** — safe retries when operations must not be duplicated

### Performance
- **Batch writes** — insert/update records in bulk, not one at a time
- **Read-through cache / cache-aside** — serve reads from cache, populate from DB on miss
- **N+1 query elimination** — fetch related records in one query, not N separate ones
- **Streaming vs buffering** — process large datasets without loading everything into memory

### Readability
- **Guard clauses / early return** — handle failure cases at the top, happy path reads straight down
- **Tell-don't-ask** — tell objects what to do rather than asking for data and deciding outside
- **Naming that encodes intent** — `findActiveUsersByRegion` vs `getUsers`; names that make comments unnecessary
- **Method extraction** — pull complex conditionals or repeated logic into named methods

### Distributed Systems
- **Outbox / transactional messaging** — see Resilience above
- **Saga pattern** — coordinate transactions across services without distributed locks
- **Event-driven vs request-response** — async events decouple producers from consumers; sync calls create temporal coupling
- **Eventual consistency** — understand what it means before designing around it

### Data Integrity
- **Optimistic locking** — detect concurrent updates with a version field; retry on conflict
- **Pessimistic locking** — lock the row for the duration of the transaction; use when conflicts are frequent
- **Soft deletes** — mark records as deleted rather than removing them; audit log follows naturally
- **Audit log pattern** — record who changed what and when; append-only

---

## What Not To Do

- Do not lecture. One pattern per trigger, maximum. If multiple apply, pick the most important one for this context.
- Do not rewrite their code. Explain the pattern; they apply it.
- Do not teach a pattern they already know well — ask first: "Are you familiar with X?" and calibrate based on the answer.
- Do not teach a pattern that doesn't apply to what they're actually building right now. Relevance is what makes it stick.
