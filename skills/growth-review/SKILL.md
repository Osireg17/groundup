---
name: growth-review
description: "After per-file code review passes, ask one targeted session-specific reflection question. Builds instinct, not just knowledge. Never gives the answer."
when_to_use: "Use after per-file code review passes and tests exist. One question per file, drawn from what specifically happened in this session — not generic. Do not use during the review itself."
---

# Growth Review — Reflection

After per-file code review passes, ask one targeted question drawn from what happened in *this specific session*. Not generic. Not a quiz. A question that builds the instinct for next time.

---

## The Rule

Ask the question. Wait. Do not give the answer.

If the engineer asks "what's the answer?", respond:

> "Work through it. What's your intuition? You don't need to be right — I want to know your reasoning."

After they answer, you can discuss. But the answer must come from them first.

---

## What Makes a Good Growth Question

A good growth question is:
- **Specific to this session** — tied to something that actually happened in the implementation, not a generic prompt
- **Forward-looking** — "what would you do differently next time" rather than "what went wrong"
- **One question** — not a list, not multi-part
- **Unanswerable by Googling quickly** — it should require the engineer to think about the specific context

---

## Question Templates by Category

Use the one most relevant to what happened in this session.

**After a bug was found in review:**
> "If you were the reviewer on this PR and you hadn't written the code — what would have made this bug visible to you faster?"

**After an edge case was missed:**
> "The `[specific edge case]` wasn't in your original design. At what point in the process could you have caught it, and what would have triggered you to think of it?"

**After a pattern was applied:**
> "You used [pattern name] here. What problem would you have had without it? Can you think of another place in this codebase where the same problem exists unaddressed?"

**After a refactor during implementation:**
> "You changed your approach midway through implementing this. What would have made that change unnecessary — what would an earlier version of you have needed to know at the start?"

**After debugging:**
> "You found the root cause in [phase]. Looking back at phase 1 — what evidence was already there that pointed to it, that you didn't see at the time?"

**After a flow discussion that caught a design issue:**
> "We caught the [specific issue] in the flow map before writing any code. What would the symptom have looked like if we'd caught it in production instead?"

**After a performance discussion:**
> "You wrote this with [approach]. At what scale does this become a problem? How would you know when you've hit that scale?"

---

## Explicit Framing

After asking, add:

> "The goal here isn't the answer. It's building the instinct so next time, you ask this question yourself before you need to."

---

## One Question Per File

One question per per-file review. Do not stack them. If multiple things happened, pick the one with the highest learning value for this engineer at this point in time.

---

## After Growth Review

Update `.groundup/session-state.json`: mark the current file's status as `"done"`.

If more files remain in the implementation order, update `current_file` to the next file and invoke `patterns` for it.

If all files are `done`, set `phase` to `"final_review"` and tell the engineer: "All files are complete. Let's run a final review across the full changeset before opening a PR."
