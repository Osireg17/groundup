---
name: groundup:pseudocode
description: "Claude writes problem-domain pseudocode directly into the target file so the engineer has to think about how to translate it, not just transcribe it. Use this skill whenever it's time to write pseudocode for a function — after the flow is agreed and patterns surfaced, before the engineer touches any implementation code. Invoke when the engineer says things like 'ok where do we start?', 'what do I implement first?', 'write the pseudocode for X', or when the per-file loop reaches step (b). Always run per-file in dependency order. Never write pseudocode before the flow map is signed off."
---

# Pseudocode

Comments exist to capture what code cannot express. Ousterhout distinguishes two kinds:

- **Higher-level** — abstract intuition: what this achieves and why it exists. Helps the reader understand intent without reading the body.
- **Lower-level** — precision: units, boundary conditions, null behaviour, side effects. Fills in what names and types cannot.

A method's doc comment is its interface contract. It must give the caller everything they need to invoke it correctly — without reading the implementation. If someone has to open the body to understand how to call the function, the comment has failed.

The contract goes **above** the function as a doc comment. The body contains only `// TODO: Implement`. The engineer must translate the contract into code themselves — that decision-making is where the skill gets built.

---

## What NOT to do

```
BAD — steps inside the body; tab completion writes it for them:
async function getUser(...) {
    // 1. call userRepo.findById(userId) → User
    //    if null, throw NotFound("user not found")
    // 2. strip passwordHash and internalFlags
    // 3. RETURN sanitised record
}

GOOD — contract above the function; engineer must translate:
/**
 * Fetch the display record for the given user.
 * ...
 */
async function getUser(...) {
    // TODO: Implement
}
```

---

## Template

```text
/**
 * <Higher-level: what this function achieves and why it exists. The business
 * rule or invariant it enforces. Abstract enough that a caller understands
 * the contract without reading the implementation.>
 *
 * <Rationale if non-obvious: why this design, what constraint drove it,
 * what would break if someone ignored it.>
 *
 * Preconditions:
 * - <what must be true before this is called>
 *
 * Constraints:
 * - <param precision: units, boundary conditions, null behaviour>
 * - <output guarantee the caller depends on>
 *
 * Side effects:
 * - <mutations, writes, external calls — anything invisible in the return value>
 *
 * Signals:
 * - <condition> → <error type>
 *
 * Docs: <link to specific framework/library doc section — omit if pure domain logic>
 */
function_signature {
    // TODO: Implement
}
```

Omit any section that doesn't apply — don't write `Side effects: none`.

**On the `Docs:` line:** include it whenever the function uses a specific framework mechanism or library API. Point to the specific section, not the homepage. The engineer reads the linked doc before implementing — this is where framework knowledge gets built, not in the grill.

---

## Filled Example

```ts
/**
 * Fetch the display record for the given user.
 *
 * Only admin and owner roles may access user records. The result must never
 * include passwordHash or internalFlags — these fields must not leave the
 * service layer, regardless of what the database returns.
 *
 * Preconditions:
 * - Caller must have an active session (request must be authenticated)
 *
 * Constraints:
 * - userId must be a non-empty, well-formed UUID
 * - Returned record omits passwordHash and internalFlags
 *
 * Signals:
 * - Malformed userId → InvalidInput
 * - Requesting user lacks admin or owner role → Forbidden
 * - No record found for this userId → NotFound
 */
async function getUser(userId: string, requestingUser: User): Promise<UserRecord> {
    // TODO: Implement
}
```

---

## Syntax Help Rule

Default: no syntax examples.

If the engineer asks about a specific construct: find a real example in the codebase first. If none exists, fabricate a minimal analogue. Show that one thing only, then hand back immediately.

> "Here's how this project handles that construct: [example]. Now apply it yourself."

---

## Code Review — Cite Patterns and Docs

When reviewing an implementation after pseudocode exists, pair each finding with a reference:

- If flagging a pattern mismatch: name the pattern and point to where it's applied in this codebase, or link the canonical description.
- If flagging a framework misuse: link the relevant doc section. "The Spring `@Transactional` docs explain the propagation modes — the behaviour here is different from what you probably intended."
- If flagging a style issue: explain the *why*, not just the *what*. "This should be extracted into its own method because [reason] — see how `src/services/OrderService.ts:42` handles the same concern."

Don't just name the problem. Point to where the right answer lives.

---

## After Writing

State clearly: "Implement this. Come back when you've written tests."

Do not offer to help implement. Do not pre-answer questions the engineer hasn't asked yet. Wait for them to attempt the implementation and bring back questions.
