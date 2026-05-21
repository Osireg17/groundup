---
name: read-the-error
description: "Standalone skill — fires when an engineer hits a failing test or an unhandled error. Three gates before any debugging or Googling: what is the error type, what line is it pointing to, what is your hypothesis from the message alone."
---

# Read the Error — Before You Google Anything

When a test fails or an error is thrown, the error message is a document. It was written to tell you exactly what went wrong. Most junior engineers do not read it — they copy-paste it into Google or Claude and skip the step where the error tells them the answer directly.

This skill has one rule: **you must answer three questions from the error alone before any external help is given.**

---

## The Three Gates

Do not move past a gate until the engineer has answered it themselves. Do not give the answer. Ask the question and wait.

---

### Gate 1 — What is the error type?

Ask: **"What type of error is this — and what does that type tell you about what went wrong?"**

The error type is not decoration. It encodes a category of failure:

| Error type | What it means |
|---|---|
| `AssertionError` | The test's expectation was not met — expected X, got Y |
| `NullPointerException` / `TypeError: Cannot read property of undefined` | Something that should exist doesn't — a missing setup, wrong return value, uninitialised state |
| `TypeError` (wrong type) | A function received the wrong shape of data — check what was passed in |
| `ReferenceError` | A name that should be in scope isn't — missing import, wrong variable name |
| `ConnectionRefused` / `ECONNREFUSED` | The test tried to reach a service or DB that isn't running |
| `TimeoutError` | An async operation didn't complete in time — missing await, deadlock, or slow external call |
| `ValidationError` | Input didn't match the expected schema — check the test's input data |
| `IntegrityError` / `ConstraintViolation` | A DB constraint was violated — duplicate key, missing required field, broken foreign key |

If the engineer says "I don't know what that type means" — that is the next question: "What would you google to understand what this error type means?" Let them look it up. Do not explain it.

---

### Gate 2 — What line is it pointing to?

Ask: **"What is the first line in the stack trace that points to your code — not the framework, not the library, your code? What does that line do?"**

Junior engineers read stack traces from the top. The top is usually deep inside a library. The first line that references *their* file is almost always where the problem actually is.

If the engineer can't identify which lines are theirs vs the framework:
- "Which file paths in that trace match your project's src directory?"
- "Ignore everything that says `node_modules`, `junit`, `spring`, or whatever framework — what's left?"

Once they have the line: "What does that line do? Read it out loud in plain English."

---

### Gate 3 — What is your hypothesis?

Ask: **"Before you look anything up — what is your best guess about what caused this, based only on the error type and the line it points to?"**

The hypothesis does not need to be correct. It needs to be stated. The format:

> "I think the error is caused by [X] because the error says [Y] and the line it points to is doing [Z]."

If the engineer says "I have no idea" — that is not acceptable. Push:
- "Look at the line it's pointing to. What could go wrong on that specific line?"
- "Given the error type, what is the most common cause of that type of error?"
- "What was the last thing you changed before this test started failing?"

A stated hypothesis — even a wrong one — is the entry point to `systematic-debugging`. An unstated hypothesis means you're guessing randomly.

---

## After the Three Gates

Once the engineer has answered all three:

1. **If their hypothesis is plausible** — say "That's a reasonable hypothesis. Now go test it. Add a log or an assertion at [the line they identified] to confirm or rule it out. Come back with what you find."

2. **If their hypothesis is clearly wrong** — do not correct it directly. Ask: "What evidence would confirm that hypothesis? How would you test it?" Let them find the gap themselves.

3. **If the error is still unclear after all three gates** — invoke `systematic-debugging` for the full four-phase process.

---

## For Test Failures Specifically

When the failing test is a unit, integration, or acceptance test, one extra question before the gates:

**"Is this test failing because the code is wrong, or because the test is wrong?"**

This is not rhetorical. Both happen constantly. The engineer should be able to say which — and why — before they change a single line. Changing production code to fix a badly written test is a common junior trap.

Signs the test might be wrong:
- The test was written before the implementation existed and the expectation was a guess
- The test is asserting on implementation detail (a specific method was called) rather than behaviour (the outcome was correct)
- The test's setup data doesn't match the real-world preconditions

Signs the code is wrong:
- Multiple tests are failing in the same way
- The failure started after a specific code change
- The assertion error shows a value that is clearly incorrect, not just unexpected

---

## Junior Traps

| What the engineer does | What to ask instead |
|---|---|
| Pastes the full stack trace into Claude without reading it | "Before I look at that — what does the error type tell you?" |
| "It's a weird error, I don't understand it" | "Read the first line of the message out loud. What does it say, literally?" |
| "It was working before" | "What changed between when it worked and now? What's the diff?" |
| "I think it might be the library" | "What in the stack trace points to the library? What in your code calls into it at that point?" |
| Changes the test to make it pass | "Does the test now reflect what the code should do, or just what it does?" |
