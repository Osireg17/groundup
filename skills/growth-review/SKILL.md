---
name: groundup:growth-review
description: "After per-file code review passes, ask one targeted session-specific reflection question. Builds instinct, not just knowledge. Never gives the answer."
when_to_use: "Use after per-file code review passes and tests exist. One question per file, drawn from what specifically happened in this session — not generic. Do not use during the review itself."
---

# Growth Review — Reflection

After per-file code review passes, take a moment to acknowledge what went well before asking the reflection question. Then ask one targeted question drawn from what happened in *this specific session*. Not generic. Not a quiz. A question that builds the instinct for next time.

---

## The Rule

**Step 1 — Acknowledge what went well.** Before asking anything, name one thing the engineer did well in this file. Be specific: "You caught the null check before the service call — that's exactly the kind of defensive instinct that prevents production bugs." This is not filler; it tells them what to keep doing.

**Step 2 — Ask the growth question.** One question, drawn from what actually happened in this session.

**Step 3 — Wait.** Do not give the answer.

If the engineer asks "what's the answer?", respond:

> "Work through it — what's your intuition? You don't need to be right, I want to know your reasoning."

After they answer, you can discuss. The answer comes from them first.

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

## One Question Per File

One question per per-file review. Do not stack them. If multiple things happened, pick the one with the highest learning value for this engineer at this point in time.

---

## Write to Learning Log

After the reflection exchange (question asked + engineer has responded), append an entry to the session learning log.

Read `session_name` and `log_target` from `.groundup/session-state.json`. Resolve the path:
- `"obsidian"`: `<vault>/groundup/logs/learning_log/dd-mm-yyyy_<session-name>.md`
- `"local"`: `logs/learning_log/dd-mm-yyyy_<session-name>.md`

Create the file if it doesn't exist. Append (never overwrite):

```markdown
## <current file path> — <ISO 8601 timestamp>

**Trap observed:** <trap name, or "none">
**Evidence:** <one sentence — what the engineer did that revealed the trap, or "n/a">

**Win observed:** <skill or instinct name, or "none">
**Evidence:** <one sentence — what the engineer did well, or "n/a">

**Growth question asked:** "<the exact question asked>"
**Engineer's reasoning quality:** <not attempted | partial | reasoned through it | strong — could explain it to someone else>

**Summary:** <one sentence capturing the key takeaway from this file — something the engineer could read back in a week and recognise>
```

**Rules:**
- Always write an entry — even when nothing notable happened (record "none" for trap and win)
- Append only — never rewrite or delete existing entries
- Be specific in evidence fields: "engineer skipped hypothesising and went straight to changing the code" is useful; "engineer made an error" is not
- The **Summary** line is the one they'll actually read when they look back — make it specific to what happened, not generic

---

## After Growth Review

Update `.groundup/session-state.json`: mark the current file's status as `"done"`.

If more files remain in the implementation order, update `current_file` to the next file and invoke `patterns` for it.

If all files are `done`, set `phase` to `"final_review"` and tell the engineer: "All files are complete. Let's run a final review across the full changeset before opening a PR."
