---
name: groundup:systematic-debugging
description: "Guides engineers through a root-cause-first debugging process. Four phases — observe, hypothesise, test, verify — ensure the cause is named before any fix is written. Speculative fixes mask symptoms and compound technical debt; this skill prevents them."
when_to_use: "Use when the engineer reports a bug or is about to make a speculative change. Use when the engineer says 'it's broken', 'this is weird', 'let me just try X' without stating a hypothesis. Use when a fix is proposed without a named root cause."
---

# Systematic Debugging

**Iron law: No fix without root cause.**

---

## Four Phases

### Phase 1 — Observe

Collect evidence before forming any hypothesis. The goal is a *reproducible* case with *specific* symptoms.

Ask:
- "Can you reproduce this consistently? What are the exact steps?"
- "What does the error message or stack trace say exactly — not paraphrased?"
- "What changed recently? Deployments, config, data, dependencies?"
- "What does the behaviour look like vs what you expected?"

If the bug only appears in one environment: "What's different between environments? DB version, config, data volume, infra?"

**Gate:** The engineer can reproduce the bug with exact steps, and they have a specific error message or symptom — not "it sometimes fails."

### Phase 2 — Hypothesise

The engineer states a falsifiable hypothesis — one sentence.

Ask:
- "What do you think is causing this?"
- "What would have to be true for your hypothesis to be correct?"
- "What would tell you your hypothesis is *wrong*?"

Don't accept "I'm not sure." Ask: "If you had to guess, where would you look first? Why?"

If they still can't form a hypothesis, Phase 1 is incomplete — they haven't collected enough evidence yet. Send them back.

**Gate:** The engineer has a specific, testable hypothesis. "The issue is somewhere in the payment flow" is not a hypothesis. "The userId from the session is being passed as a string to a function that expects a number" is.

### Phase 3 — Test

Add diagnostic instrumentation at the right boundary. Do not change production logic yet.

Ask:
- "What would you add to confirm or rule out this hypothesis?"
- "Where in the call chain would you add logging to see what's actually happening?"
- "What value would confirm you're right? What value would tell you you're wrong?"

Guide toward logging at **service boundaries** — inputs and outputs at every handoff. This is where bugs hide.

Boundaries to instrument:
- Entry point: what arrived
- Before/after external calls: what was sent, what came back
- Before/after data transformations: what went in, what came out
- Conditional branches: which path was taken

After running with diagnostics: "Does the output confirm your hypothesis or rule it out?"

If ruled out: back to Phase 2 with new evidence. This is normal — a ruled-out hypothesis isn't failure, it's evidence. The previous round narrowed the space.

**Gate:** The hypothesis is confirmed by concrete evidence — logged output, not intuition. Once confirmed, complete the root cause statement before writing any fix:

> "The bug is caused by **[X]** because **[Y]**, evidence **[Z]**."

**Examples:**
- "The bug is caused by the payment service calling the inventory service synchronously because the response times out under load, evidence: `TimeoutException` stack traces in prod logs at peak traffic."
- "The bug is caused by a missing null check in `processOrder` because the discount field is optional but the code assumes it's always present, evidence: `NullPointerException` on line 47 when `order.discount` is undefined."

### Phase 4 — Verify

The fix works and doesn't break neighbours.

Before shipping:
- "Does the fix pass the tests you wrote?"
- "What test would catch this regression if the bug returned?"
- "Have you checked the edge cases from the pseudocode header?"

**Gate:** Tests pass, regression test exists, edge cases checked.

---

## Diagnostic Logging Patterns

Teach these in Phase 3. They surface bugs efficiently.

**Service boundary:**
```
Log: entering [function/endpoint], input=[value]
... work ...
Log: exiting [function/endpoint], output=[value]
```

**External call:**
```
Log: calling [service/DB], request=[what you're sending]
[call]
Log: [service/DB] responded, response=[what came back]
```

**Conditional:**
```
Log: condition=[value], taking [branch A / branch B]
```

---

## Common Patterns to Watch For

When you notice these, name them — naming them is how they become learnable. Frame it as observation, not accusation.

| Pattern | What to say |
|---------|-------------|
| "It's probably the library" | "Libraries are rarely the source — it's usually how they're called. Let's start with your code and work outward from there." |
| "It was working before" | "Let's prove that. What changed since it last worked — git log, deploys, data, config?" |
| "Let me just try a few things" | "If you change multiple things at once you won't know what fixed it. What's your one hypothesis right now?" |
| "I'll add some logs and see what happens" | "Logs without a hypothesis produce noise. What specifically are you trying to confirm before you add them?" |
| "I think I know what it is" | "Good — state it as a hypothesis and let's test it. What would confirm you're right?" |
| "The fix is obvious" | "The fix might be obvious, but do you know *why* it broke? Name the root cause before you write anything." |

---

## After Debugging Completes

Write the root cause as a comment above the fix:

```
// Root cause: [the root cause statement]
// Fix: [what was changed and why]
```

This is the most valuable comment in the codebase — it answers "why does this code look like this?" for the next engineer who touches it.
