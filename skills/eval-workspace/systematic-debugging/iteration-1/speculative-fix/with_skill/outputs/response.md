# Systematic Debugging Eval — Speculative Fix Scenario (with_skill)

**Scenario:** Engineer proposes swallowing a 500 error with a try-catch instead of finding the root cause.

---

**Engineer:** I'm getting a 500 error when users try to submit an order. I think it's probably a database timeout issue — I'm going to wrap the whole `createOrder` function in a try-catch and swallow the error so the user at least gets a success response. That should fix it right?

**Mentor:** Stop — this is a speculative fix, and it's a dangerous one. Swallowing an error and telling the user "success" when the order wasn't actually created isn't a fix. It's a lie to the user and a silent data loss bug waiting to compound.

Iron law: no fix without root cause. You don't know yet whether this is a timeout, a constraint violation, a null value, or something else entirely. A try-catch won't change what's broken — it'll just hide it.

Let's go through this properly. Phase 1 is observation — we collect evidence before we form any hypothesis.

Can you reproduce this consistently? What are the exact steps to trigger the 500?

---

**Engineer:** Yeah it happens pretty much every time someone tries to submit. I just see a 500 in the browser. I haven't looked at the server logs yet.

**Mentor:** Right — the browser telling you "500" is the least informative signal you can get. That's the HTTP status code the server sent, nothing more. The actual error is in the server logs.

Before we go any further: go pull the server logs for one of these failed submissions. What I need you to bring back is the exact error message and the full stack trace — not a paraphrase, the actual text.

That's your next step. Come back when you have the stack trace.

---

**Engineer:** Okay I found it. Here's the stack trace:

```
ERROR 2026-05-26T14:32:01 — Unhandled exception in POST /orders
IntegrityError: null value in column "user_id" violates not-null constraint
  at createOrder (orders/service.py:84)
  at OrdersController.submit (orders/controller.py:31)
```

**Mentor:** Good. That changes everything — this is not a timeout. This is an `IntegrityError` with a very specific message: `null value in column "user_id" violates not-null constraint`. The database is rejecting the insert because `user_id` is null when it shouldn't be.

Now you have enough to form a hypothesis. Phase 2: what do you think is causing `user_id` to be null by the time it reaches `createOrder`? Where do you think the value is being lost?

---

**Engineer:** Hmm. Maybe the user isn't logged in? Or maybe the session isn't being read correctly? I'm not sure — could be either.

**Mentor:** "Could be either" is two hypotheses, not one. You can't test both at the same time — that's one of the junior traps: running multiple simultaneous experiments means you won't know which one fixed it.

Pick one and reason it through. Look at line 84 in `orders/service.py` and line 31 in `orders/controller.py`. What does the code actually do at those points? Does it read `user_id` from the session? Does it validate that the session exists before passing it downstream?

What does the code say, not what do you think it might say?

---

**Engineer:** Okay I looked. In `controller.py` line 31 it does `user_id = request.session.get("user_id")` and then passes it to `createOrder`. And in `service.py` line 84 it does `db.insert(order, user_id=user_id)`. There's no null check anywhere. But wait — I also just noticed that a deploy went out yesterday that changed the session key from `"userId"` to `"user_id"`. Some users might still have old sessions.

**Mentor:** Now you have a real hypothesis. State it as one sentence in the format: "The bug is caused by X because Y, evidence Z."

---

**Engineer:** The bug is caused by `request.session.get("user_id")` returning None because old sessions stored the value under the key `"userId"` (before yesterday's deploy), so users with existing sessions get a null `user_id` passed to the database insert, evidence: the `IntegrityError` on `user_id` not-null constraint, the code reading from `"user_id"`, and the deploy log showing the session key was renamed yesterday.

**Mentor:** That's a solid root cause statement. Now we're in Phase 3 — confirm it before you write any fix.

Add a log at the top of `createOrder` to print the raw session dict and the value of `user_id` as it arrives. What we want to see is: does a user with an old session have `"userId"` in their session but not `"user_id"`? That confirms the hypothesis with concrete evidence rather than inference.

What would you log, and where exactly would you put it?

---

**Engineer:** I'd add something at the top of `createOrder` in `service.py`:

```python
logger.debug("createOrder called, user_id=%s, session_keys=%s", user_id, list(request.session.keys()))
```

And also in the controller before the call:

```python
logger.debug("submit: raw session=%s", dict(request.session))
```

**Mentor:** Good instinct — you're logging at the service boundary (entry to `createOrder`) and at the controller handoff. That's exactly where the data crosses a boundary.

Run it with an affected user session and bring back what the logs show. If you see `session_keys` containing `"userId"` but not `"user_id"`, your hypothesis is confirmed. If `user_id` is null and the session has neither key, you've ruled it out and the bug is upstream of the session read.

Come back with the log output.

---

**Engineer:** Logs show `user_id=None, session_keys=['userId', 'cart', 'csrf_token']`. The old key is there. Hypothesis confirmed.

**Mentor:** Confirmed. Now you can write a fix — but only now, because you know exactly what broke and why.

Your fix options are roughly: read from both keys during a migration window, force a session re-login, or backfill existing sessions. Those have different tradeoffs — but that's a separate discussion.

Whatever fix you write, put this comment above it:

```python
# Root cause: request.session.get("user_id") returns None for users with sessions
# created before the deploy on 2026-05-25, which renamed the key from "userId" to "user_id".
# Fix: fall back to "userId" during migration window, remove fallback after sessions expire.
```

And before you ship: what test would catch this regression if the session key was ever renamed again?

---

**Engineer:** I'd write a test that calls the order submission endpoint with a session that has `"userId"` set but not `"user_id"`, and assert we get a 400 or the order is still created — depending on how we handle it.

**Mentor:** Exactly right. That test is the regression guard. Write it, make sure it passes with your fix, and then ship.

Notice what we didn't do: we didn't swallow the error with a try-catch. If we had, users would have seen "success", no order would have been created, and you'd have silent data loss in production with no way to know which orders were dropped. The error was the signal. The signal told you where to look.

That's Phase 4 done once your tests pass. Good debugging.
