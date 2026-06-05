---
name: groundup:ask-well
description: "Structures a question before it is asked — mid-session or externally. Five fields: trying to, tried, expected, actually, stuck on. A well-formed question is 50% of the answer."
when_to_use: "Use when the engineer is stuck and about to ask a question without having reasoned through it. Use when the engineer says 'I don't know what to do', 'can you just tell me', or is about to paste a wall of code with no context. Fires both mid-session and for external questions (Stack Overflow, colleagues, GitHub issues)."
---

# Ask Well — Structure the Question Before You Ask It

---

## The Rule

Before any question is asked, the engineer must be able to fill in all four fields:

```
Trying to:   <what you are attempting to achieve>
Tried:       <what you have already attempted, and what happened>
Expected:    <what you thought would happen>
Actually:    <what actually happened>
Stuck on:    <the specific thing you do not understand or cannot get past>
```

If any field is blank, that is the next question.

---

## The Five Fields

Work through these one at a time if the engineer is struggling to fill them in.

---

**Trying to:**

"What are you trying to achieve? Not how — what is the outcome you want?"

This should be one sentence about the goal, not the implementation. Bad: "I'm trying to call `userService.findById`." Good: "I'm trying to fetch the current user's profile and return it in the API response."

If the engineer cannot state the goal in one sentence, they may not have understood the task clearly enough. That is itself the problem to solve first.

---

**Tried:**

"What have you already attempted? What happened when you tried it?"

This field has two parts: what was tried, and what the result was. "I tried X and it didn't work" is not enough. "I tried X and got error Y / got result Z instead of W" is.

If the engineer has not tried anything yet:
- "What is the first thing you would try? Try it. Come back with what happened."

Asking before trying is a pattern that creates dependency. The skill of attempting something — even a wrong thing — and then reading what the system tells you back is more valuable than the answer to any individual question.

---

**Expected:**

"What did you think would happen when you tried that?"

This surfaces the assumption. If the engineer expected X and got Y, the gap between X and Y is where the misunderstanding lives. Often, stating the expectation reveals that it was never grounded in anything — it was a guess.

If the engineer says "I didn't know what to expect" — that is worth exploring:
- "What did the documentation / the function signature / the test say it should return?"
- "What does the similar function elsewhere in the codebase do?"

---

**Actually:**

"What actually happened? Be specific — exact error message, exact return value, exact behaviour."

"It didn't work" is not an answer. "It returned null instead of the user object" is. "It threw `TypeError: Cannot read properties of undefined (reading 'id')` on line 42" is.

If the engineer does not have the exact output: "Go run it and copy the exact output. Don't paraphrase it."

---

**Stuck on:**

"What specifically do you not understand or cannot get past?"

This is the most important field and the one most often left vague. "I'm just stuck" is not specific enough. The stuck point should be one of:

- A concept: "I don't understand why [X] behaves this way"
- A gap: "I don't know where to find [Y]"
- A decision: "I don't know which of [A] or [B] to use and why it matters"
- A blocker: "I've tried [X] and [Y] and both produce the same wrong result — I've run out of things to test"

If the engineer cannot name the stuck point specifically, ask:
- "Is it that you don't know what to try next, or that you've tried things and they all fail in the same way?"
- "Is it a knowledge gap (you don't know how something works) or an implementation gap (you know how it should work but can't make it work)?"

---

## After the Five Fields Are Filled

Synthesise the five fields into a single prose paragraph and read it back to the engineer. Do not list the fields — weave them into natural sentences. The goal is a question that reads the way a sharp engineer would actually write it: goal first, what was tried and what happened, the gap between expected and actual, and the specific stuck point.

**Format:** one clear, concise paragraph. Two or three sentences is usually enough. Never use the field labels (Trying to / Tried / Expected / Actually / Stuck on) in the read-back.

> "So your question is: [prose paragraph]. Does that capture it?"

**Example:**
> "So your question is: I'm trying to fetch the current user's profile via `userService.findById`, but it's returning null even though the user exists in the database. I called it with a valid `userId` and expected the user object back, but got null. I don't understand why — I can't tell if it's a query issue, a missing DB record, or something wrong with how I'm passing the ID. Does that capture it?"

Then ask: **"Having said all of that — do you already have a hypothesis about what the answer might be?"**

A significant proportion of the time, filling in the five fields produces the answer without needing to ask anyone. The act of articulating the problem precisely forces the brain to organise what it knows — and the gap often becomes obvious.

If the engineer now has a hypothesis: "Test it. Come back with what you find."

If they still need to ask: the question is now precise enough to get a useful answer.

---

## Mid-Session vs External

This skill fires in two contexts. The approach is the same — the framing is different.

**Mid-session** (asking Claude or a senior engineer during a pairing session):
> Frame it as: "I want to make sure I've thought this through before asking. Let me walk you through what I know and where I'm stuck."

The point is not to avoid asking — it is to demonstrate that you have engaged with the problem before handing it off. Senior engineers respect this. It also means the answer you get is targeted, not a generic explanation of something you already know.

**External** (Stack Overflow, GitHub issues, Slack, asking a colleague):
> The five-field format maps directly to a good Stack Overflow question or a Slack message that gets answered quickly. A question with all five fields filled in is the difference between "can you look at this?" and "here's exactly what I need."

Vague questions in public forums get closed or ignored. Precise questions get fast, specific answers — and often become a permanent reference for others with the same problem.

---

## Junior Traps

| What the engineer does | What to ask instead |
|---|---|
| "It's not working" | "What specifically is it doing instead of what you expected?" |
| Asks before trying anything | "What's the first thing you'd try? Go try it." |
| Pastes a wall of code with no context | "What is the one line or section you think the problem is in?" |
| "How do I do X?" with no context | "What have you found so far? What does the documentation say?" |
| Asks the same question twice after getting an answer | "What did the answer tell you? What did you try from it?" |
| "I don't know where to start" | "What do you know for certain? Start from there." |
