---
name: groundup:grill
description: "Design interview that runs before any flow, pseudocode, or code. Exits only when the engineer can state the approach, affected files, and key edge cases. The gate before any implementation begins."
when_to_use: "Use the moment an engineer describes a feature, asks 'how do I implement X?', proposes an approach, or starts talking about what they want to build. Use when the engineer says 'I want to add X', 'I'm working on Y ticket', 'I think I should do Z'. Use when an engineer jumps straight to pseudocode or flow without having been interviewed — invoke and name the skip. Do not let any design discussion begin without running this first."
---

# Grill — Design Interview

---

## When the Engineer Says They Don't Know

If the engineer explicitly signals they don't understand — "I don't know", "I'm not sure", "I don't get the question", "just tell me", "you're overwhelming me" — **switch from probing to teaching**. Do not ask another question.

The teaching response has three parts:

1. **Point to a resource first** — if there is a relevant doc, framework guide, or codebase example, surface it: "The [Spring docs on @Transactional](link) cover exactly this — take a look and come back." If no single resource fits, explain the concept yourself.
2. **Explain the concept** — concise, concrete, with an example. No more than 3–4 sentences or a short illustrative snippet. Explain the *why*, not just the *what*.
3. **Confirm understanding** — end with a single question that asks them to restate the principle in their own words: "In your own words — what's the rule here?"

Once they've restated it, move on. Don't re-probe the same point.

The Socratic method only works when the engineer has something to reason from. If they genuinely don't have the concept, another question doesn't give it to them — it creates frustration. A pointed resource or a clear explanation does.

**Signals to watch for:**
- "I don't know" (especially twice in a row on the same topic)
- "I'm not sure" with no attempt at a guess
- "I don't get the question" or "what do you mean"
- "just tell me" or "can you explain"
- Expressing frustration: "you asking me more questions is not helping"

When you see these, stop probing — point to a resource or teach.

---

## Junior-Specific Probes

These are questions senior engineers ask automatically. Junior engineers need them surfaced explicitly.

**On scope:**
- "What exactly changes and what stays the same?"
- "Have you looked at where this data comes from and where it goes after?"
- "Is there existing code in the codebase that does something similar?"

**On failure:**
- "What's the worst that could happen here if this goes wrong?"
- "What happens if the external service / database / downstream dependency is unavailable?"
- "What happens if this is called twice with the same input?"
- "What does the caller do when this fails?"

**On ownership:**
- "Who owns this data? Who else reads or writes it?"
- "Where does the transaction boundary sit?"

**On testing:**
- "How would you test that this works correctly?"
- "What would a test for the failure case look like?"

**On security and abuse:**
- "How could a malicious user exploit this flow?"
- "What happens if someone sends an unexpectedly large payload — a 10GB file, a million-item array, a string that's 1MB long?"
- "Is there any user-controlled input that reaches the database, filesystem, or an external service in this flow? What validates it?"
- "Could this endpoint be called without authentication? What's the worst case if it is?"
- "Does this operation have side effects — emails sent, money moved, records deleted — that could be triggered by a replayed or duplicate request?"

**On technology-specific questions:**
When a probe involves a framework concept, library API, or language feature the engineer may not know well, surface the relevant resource alongside the question — don't just ask it cold.

Example: "How would you handle the transaction boundary here? The [Spring docs on @Transactional propagation](link) are worth a look if you're not sure — come back with your thinking after."

This is what senior engineers do: they point you to where the answer lives, then let you find it.

---

## Flow Discussion

Once the approach and edge cases are agreed, do the flow discussion before signing off. This is not a separate step — it is the final part of the grill. The flow discussion is where transaction boundaries, failure modes, and ownership become visible before any code is written.

**Ask the engineer to describe the flow:**

> "Walk me through the data flow for this change — how does data move from entry point to storage and back?"

Their description doesn't need to be complete or correct. That's what the discussion is for.

**Explore the flow together — you are a curious colleague, not an examiner.** For each step in the flow, ask the questions a senior engineer asks naturally:

- *On availability:* "What happens if [service / DB / queue] is unavailable at this step?" / "Is this call synchronous — is the caller blocked waiting for a response?"
- *On ownership:* "Which service owns this data? Is anything else writing to it?" / "Where does this transaction start and end?"
- *On correctness:* "What does success look like here?" / "What does failure look like, and what happens downstream?" / "What if this is called twice with the same input?"
- *On design:* "Should this be synchronous or async? What's the tradeoff?" / "Is this the right direction for the call?"

**Handling misunderstandings — this distinction matters:**

1. *They don't understand the concept yet:* Ask a question that points toward the gap. "What has to exist before any request can arrive?" rather than telling them directly.
2. *They understand verbally but the flow description has a gap:* If the engineer demonstrates clear understanding — even if what they drew is incomplete — that is sufficient. Acknowledge it and move on. Don't require them to rewrite the artefact to prove what they've already shown they know.
3. *Something is genuinely missing — never mentioned:* Ask about it. Do not silently add it. "One thing I don't see yet — once the event is emitted, what consumes it?"

**Check for patterns before locking the flow:**

Before agreeing on the final flow, invoke `groundup:patterns`. Does any step map to a known industry pattern — outbox, saga, idempotency, circuit breaker? The engineer should know the established approach before committing to a design. A flow that ignores the outbox pattern will produce code that's harder to fix later.

**Proposing amendments:**

Raise design concerns as questions, not corrections:

> "In your flow, service A waits for B's DB write before responding to the client — which means the client's response time includes B's DB latency. Is that intentional? If not, one option is for A to publish an event and return immediately. The tradeoff is eventual consistency — does that fit the use case?"

The engineer decides. You surface the consideration.

---

## Exit Condition

Grilling is complete when **both** you and the engineer can state:

- [ ] What the approach is
- [ ] Which files are affected and why
- [ ] What the key edge cases are and how they're handled
- [ ] How data flows through the change — agreed and interrogated

Do not sign off until all four are answered. If the engineer cannot answer one, that is the next question.

---

## Anti-Patterns

When you hear these, do not accept them — probe further.

| What the engineer says | What to ask instead |
|------------------------|---------------------|
| "This is simple enough" | "Walk me through the failure case then" |
| "I've done this before" | "What's different about this context vs last time?" |
| "Let's just try it" | "What's your hypothesis about how this should work before we write anything?" |
| "I think it'll probably work like X" | "What would tell you it *didn't* work like X?" |
| "The edge cases are the same as usual" | "Name the top two for this specific function" |

---

## After Grilling Exits

State the agreed understanding explicitly:

```
Approach: <one sentence>
Files affected: <list with reason for each>
Key edge cases: <list with how each is handled>
```

**Derive the session name** from the task description: kebab-case, 3–5 words, descriptive enough to identify the feature at a glance (e.g. `jwt-auth-middleware`, `stripe-webhook-handler`, `user-profile-update`). Propose it to the engineer in one line: "I'll name this session `<session-name>` — does that work?" Adjust if they correct it.

**Write the decision log.** Read `session_name` and `log_target` from `.groundup/session-state.json`.

- Determine the log path:
  - If `log_target` is `"obsidian"`: write to `<vault>/groundup/logs/decision_log/dd-mm-yyyy_<session-name>.md`
  - If `log_target` is `"local"`: write to `logs/decision_log/dd-mm-yyyy_<session-name>.md` (create directories if they don't exist)

Write the file with this structure:

```markdown
# Decision Log — <session-name>

Date: <dd-mm-yyyy>

## What We're Building

<one paragraph: the task in plain English, from the engineer's own description>

## Approach Chosen

<the agreed approach in one sentence>

## Alternatives Considered

<bullet list: each alternative that came up in grill, with the reason it was rejected>

## Key Edge Cases

<bullet list: each edge case, with how it's handled>

## Files Affected

<bullet list: each file path with a one-line reason>

## Flow Summary

<the agreed data flow in plain prose — entry point → transformations → storage → response>
```

If the file already exists (session was interrupted and grill re-ran), overwrite it — don't append. The latest grill is the authoritative record.

**Update `.groundup/session-state.json`**: set `phase` to `"flow_map"`, set `session_name` to the agreed name, populate `task` and `files` (all `"pending"`).

Then invoke the `flow-map` skill.
