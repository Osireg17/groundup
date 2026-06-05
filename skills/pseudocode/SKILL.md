---
name: groundup:pseudocode
description: "Claude writes problem-domain pseudocode directly into the target file so the engineer has to think about how to translate it, not just transcribe it. Use this skill whenever it's time to write pseudocode for a function — after the flow is agreed and patterns surfaced, before the engineer touches any implementation code. Invoke when the engineer says things like 'ok where do we start?', 'what do I implement first?', 'write the pseudocode for X', or when the per-file loop reaches step (b). Always run per-file in dependency order. Never write pseudocode before the flow map is signed off."
---

# Pseudocode

**Standard: Dr. Dalbey's PDL.** Each step describes *what* to achieve using structured English keywords.

**Allowed keywords:**
- Control: `IF`, `THEN`, `ELSE`, `ENDIF`, `WHILE`, `ENDWHILE`, `FOR EACH`, `REPEAT UNTIL`, `CASE`, `OF`, `ENDCASE`
- Action: `GET`, `COMPUTE`, `DETERMINE`, `CALL`, `RETURN`, `STORE`, `DISPLAY`, `READ`

**Steps describe what to achieve, in problem-domain language:**
- "DETERMINE whether the user holds the required permission" ✓
- "call permissions.check(userId, role)" ✗ — this is code, not pseudocode

---

## Concrete Contrast

```
BAD — too code-like, engineer just transcribes:
  3. call userRepo.findById(userId) → User
     if null, throw NotFound("user not found")

GOOD — problem-domain, engineer must translate:
  3. GET the user record for this userId
     IF no user record exists, signal that the resource was not found
```

The engineer has to decide: which method? What does "signal" map to — an exception? A Result type? An error response? That decision is where the skill gets built.

---

## Template

```
// Purpose: <what this function achieves in one sentence> | Ref: <path/to/similar/file:line>
// In:    <param> (<type, constraints>)
// Out:   <what is returned and its shape>
// Edges: <condition> → <signal raised> | <condition> → <signal raised>
// Docs:  <framework or library doc link relevant to the main mechanism used — omit if none>

function_signature {
    // given: <inputs with constraints>
    // expect: <output — what it looks like when correct>
    //
    // 1. <problem-domain step>
    //    IF <condition>, signal <error type with context>
    //
    // 2. <problem-domain step>
    //    sub-detail indented here
    //
    // n. RETURN <what>
}
```

**On the `Docs:` line:** include it whenever the function will use a specific framework mechanism or library API that has official documentation. Point to the specific section, not the homepage. If the function is purely domain logic with no framework dependency, omit the line. The engineer reads the linked doc before implementing — this is where the framework knowledge gets built, not in the grill.

---

## Filled Example

```ts
// Purpose: fetch a user record for display, stripping sensitive fields | Ref: src/services/postService.ts:42
// In:    userId (string, non-empty UUID), requestingUser (User, with role)
// Out:   UserRecord — all fields except passwordHash and internalFlags
// Edges: invalid userId → signal bad input | insufficient role → signal forbidden | no record → signal not found
// Docs:  (none — pure domain logic, no framework dependency)

async function getUser(userId: string, requestingUser: User): Promise<UserRecord> {
    // given: userId (string, non-empty UUID), requestingUser (User, with role)
    // expect: UserRecord with passwordHash and internalFlags stripped
    //
    // 1. DETERMINE whether userId is a well-formed, non-empty identifier
    //    IF not, signal that the input is invalid
    //
    // 2. DETERMINE whether requestingUser holds a role that permits reading user records
    //    IF not, signal that the operation is forbidden
    //
    // 3. GET the user record for this userId
    //    IF no record exists, signal that the resource was not found
    //
    // 4. REMOVE the sensitive fields from the record (passwordHash, internalFlags)
    //
    // 5. RETURN the sanitised record
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
