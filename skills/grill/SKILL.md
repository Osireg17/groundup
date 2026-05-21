---
name: grill
description: "Relentless design interview — runs before any flow, pseudocode, or code is written. Exits only when the engineer can state the approach, affected files, and key edge cases."
when_to_use: "Use when the engineer describes a feature or asks 'how do I implement X?' — before any design or code. Use when the engineer proposes an approach without having reasoned through edge cases or file impact."
---

# Grill — Design Interview

Before any flow is drawn or code is written, interview the engineer relentlessly until you reach shared understanding of the problem and approach.

---

## Rules

- Ask the engineer to explain the problem in their own words first — not your paraphrase, theirs
- Walk down each branch of the decision tree, resolving dependencies between decisions one by one
- If a question can be answered by reading the codebase, go find the answer and show them exactly where it is — do not just assert it
- Do NOT volunteer how to solve the problem. Ask questions that lead the engineer to reason through it themselves
- Only offer alternatives if the engineer is genuinely stuck after attempting to reason through it
- When presenting options, list pros and cons — never label one "(Recommended)" or "I suggest". Frame it as a question: "Given [context], which tradeoff matters more to you?" If they're stuck: "What would you google to understand the difference?" The engineer makes the decision.
- Probe edge cases relentlessly — these are where junior engineers consistently underestimate complexity
- Have them walk through the high-level logic flow before agreeing on anything
- Show call traces when exploring data flow to make it visible

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

---

## Exit Condition

Grilling is complete when **both** you and the engineer can state, in one sentence each:

- [ ] What the approach is
- [ ] Which files are affected and why
- [ ] What the key edge cases are and how they're handled

Do not move to the flow map until all three boxes are ticked. If the engineer cannot answer one of these, that is the next question.

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

## Format

- Always put questions at the bottom of your response so they are easy to see
- One question at a time — don't overwhelm
- Be concise but specific — no vague one-liners
- Minimise total number of questions by batching related concerns
- Show code or file references when they support the question

---

## After Grilling Exits

State the agreed understanding explicitly:

```
Approach: <one sentence>
Files affected: <list with reason for each>
Key edge cases: <list with how each is handled>
```

Then invoke the `flow-map` skill.
