---
name: groundup:pseudocode
description: "Claude writes problem-domain pseudocode directly into the target file. Engineer translates it to code. Steps describe what to achieve, not how to write it."
when_to_use: "Use after flow is agreed and patterns surfaced, before the engineer writes any implementation. Use per-file, in dependency order. Never write pseudocode until the flow map is signed off."
---

# Pseudocode

You write the pseudocode. The engineer writes the code.

The pseudocode goes directly into the file at the correct location (or into the new file if it doesn't exist yet), in the dependency order determined by the flow map.

---

## The Critical Rule — Abstraction Level

Pseudocode must be written at the **problem-domain level**, not the implementation level. If it looks like code in another language, rewrite it. The engineer must have to *think* about how to translate it.

**Standard: Dr. Dalbey's PDL.** Each step describes *what* to achieve using structured English keywords.

**Allowed keywords:**
- Control: `IF`, `THEN`, `ELSE`, `ENDIF`, `WHILE`, `ENDWHILE`, `FOR EACH`, `REPEAT UNTIL`, `CASE`, `OF`, `ENDCASE`
- Action: `GET`, `COMPUTE`, `DETERMINE`, `CALL`, `RETURN`, `STORE`, `DISPLAY`, `READ`

**Steps describe what to achieve, in problem-domain language:**
- "Determine whether the user holds the required permission" ✓
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
// Edges: <condition> → <signal/error raised> | <condition> → <signal/error raised>

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

---

## Before Writing — Edge Case Check

Before writing the pseudocode, verify: are all edge cases from the flow-map discussion represented in the `Edges:` header?

If not, add them. The `Edges:` header is the contract for test coverage — if it's in `Edges:`, there must be a test for it.

---

## Syntax Help Rule

Default: no syntax examples.

If the engineer asks about a specific construct: show **one targeted example** from the codebase (find it first — don't fabricate if a real one exists). If no real example exists, fabricate a minimal analogue. Show that one thing only, then hand back immediately.

> "Here's how this project handles that construct: [example]. Now apply it yourself."

---

## After Writing

Update `.groundup/session-state.json`: set the current file's status to `"pseudocode_written"`.

State clearly: "Implement this. Come back when you've written tests."

Do not offer to help implement. Do not pre-answer questions the engineer hasn't asked yet. Wait for them to attempt the implementation and bring back questions.

---

## Comment Syntax by File Type

Match the comment syntax to the file extension:
- `.ts`, `.js`, `.java`, `.go`, `.cs`, `.cpp` → `//`
- `.py`, `.rb`, `.sh` → `#`
- `.html`, `.xml` → `<!-- -->`
- `.sql` → `--`
