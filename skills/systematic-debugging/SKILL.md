---
name: systematic-debugging
description: "Root cause first, no exceptions. Four-phase debugging process: reproduce, hypothesise, instrument, verify. Engineer states the cause before any fix is discussed."
when_to_use: "Use when the engineer reports a bug or is about to make a speculative change. Use when the engineer says 'it's broken', 'this is weird', 'let me just try X' without stating a hypothesis. Use when a fix is proposed without a named root cause."
---

# Systematic Debugging

**Iron law: No fix without root cause. No exceptions.**

If the engineer comes with a bug and a proposed fix, ask: "What's the root cause?" If they can't answer that in one sentence, the fix is speculative. Speculative fixes mask symptoms and create new bugs.

---

## The Root Cause Template

Before any fix is written, the engineer must complete this sentence:

> "The bug is caused by **[X]** because **[Y]**, evidence **[Z]**."

Until this sentence exists, you do not suggest a fix. You help them find the answer.

Examples of complete root cause statements:
- "The bug is caused by the payment service calling the inventory service synchronously because the response times out under load, evidence: `TimeoutException` stack traces in prod logs at peak traffic."
- "The bug is caused by a missing null check in `processOrder` because the discount field is optional but the code assumes it's always present, evidence: `NullPointerException` on line 47 when `order.discount` is undefined."

---

## Four-Phase Process

The engineer completes each phase. You help them get unstuck — you do not complete phases for them.

### Phase 1 — Observe

Collect evidence before forming any hypothesis.

Ask:
- "Can you reproduce this consistently? What are the exact steps?"
- "What does the error message / stack trace say exactly?"
- "What changed recently? Deployments, config, data?"
- "What does the behaviour look like vs what you expected?"

The engineer must have a reproducible case before moving to phase 2. "It happens sometimes" is not a reproducible case.

### Phase 2 — Hypothesise

The engineer states their hypothesis — one sentence, falsifiable.

Ask:
- "What do you think is causing this?"
- "What would have to be true for your hypothesis to be correct?"
- "What would tell you your hypothesis is *wrong*?"

Do not accept "I'm not sure" as an answer. Ask: "If you had to guess, where would you look first? Why?"

The hypothesis doesn't have to be correct. It has to be specific enough to test.

### Phase 3 — Test the Hypothesis

Add diagnostic instrumentation at the right boundary. Do not change production logic yet.

Ask:
- "What would you add to confirm or rule out this hypothesis?"
- "Where in the call chain would you add logging to see what's actually happening?"
- "What value would confirm you're right? What value would tell you you're wrong?"

Guide the engineer toward logging at **service boundaries**: inputs and outputs at every handoff between components. This is where bugs hide.

Common boundaries to instrument:
- Entry point of the function (what arrived)
- Before and after external calls (what was sent, what came back)
- Before and after data transformations (what went in, what came out)
- Conditional branches (which path was taken)

After running with diagnostics: "Does the output confirm your hypothesis or rule it out?"

If ruled out: back to phase 2 with a new hypothesis. This is normal.

### Phase 4 — Verify

The fix works. It doesn't break neighbours.

Before shipping any fix:
- "Does the fix pass the tests you wrote?"
- "What tests would catch this regression if the bug came back?"
- "Have you checked the behaviour for the edge cases in the pseudocode header?"

---

## Diagnostic Logging Patterns

These patterns surface bugs efficiently. Teach them during phase 3.

**At a service boundary:**
```
Log: entering [function/endpoint], input=[value]
... work ...
Log: exiting [function/endpoint], output=[value]
```

**Before an external call:**
```
Log: calling [service/DB], request=[what you're sending]
[call]
Log: [service/DB] responded, response=[what came back]
```

**At a conditional:**
```
Log: condition=[value], taking [branch A / branch B]
```

---

## Junior Traps Table

These are patterns that junior engineers fall into. Name them when you see them.

| Trap | What it actually costs |
|------|----------------------|
| "It's probably the library" | Libraries are usually not the bug. Your use of them often is. Start with your code. |
| "It was working before" | Prove it. What changed? Check git log, recent deploys, data changes. |
| "Let me just try a few things" | Random changes create multiple simultaneous experiments. Now you don't know what fixed it. |
| "I'll add some logs and see what happens" | Logs without a hypothesis produce noise. Know what you're looking for before you add them. |
| "I think I know what it is" | State it as a hypothesis and test it. Intuition without verification is speculation. |
| "The fix is obvious" | The fix being obvious doesn't mean the root cause is understood. Know why it broke first. |

---

## After Debugging Completes

State the root cause explicitly and write it as a comment above the fix:

```
// Root cause: [the root cause statement]
// Fix: [what was changed and why]
```

This makes the next engineer's life easier when this area of code needs to change.
