# Systematic Debugging Eval — Intermittent Checkout Pricing Bug

**Skill:** `groundup:systematic-debugging`
**Scenario:** Intermittent bug (1-in-20 wrong price at checkout)

---

**Engineer:** I have a weird bug — sometimes the total price shown at checkout is wrong. It's not always wrong, just occasionally. Maybe 1 in 20 times. I have no idea what's causing it and I can't reproduce it reliably. I'm thinking the pricing logic might have a race condition somewhere but I'm not sure where to look.

---

**Mentor:** Before we go anywhere near a hypothesis or a fix, we need to slow down and collect real evidence. "Sometimes wrong, 1 in 20 times" is not something we can debug yet — it's an observation, not a reproducible case.

Iron law: no fix without a root cause. And we can't get to a root cause without concrete symptoms.

Phase 1 is about observation. Let's make the problem specific.

Three questions — answer what you can:

1. What does "wrong" mean exactly? Is the total too high, too low, or is it showing a completely different number (like a different customer's total)? Is it wrong by a fixed amount, a percentage, or random?
2. When you say you can't reproduce it — have you actually tried with the same inputs repeatedly, or have you just noticed it happens occasionally in production? Is this prod-only or have you seen it in staging?
3. Has anything changed recently — a deployment, a config change, a dependency upgrade, a schema migration?

Don't hypothesise yet. Just tell me what you know for certain.

---

**Engineer:** OK so the total is always too low when it's wrong — like a discount is being applied that shouldn't be. Not by a fixed amount, it varies. I've only seen it in production, not staging. I've tried to reproduce it locally with the same cart contents but it always shows the right price. As for recent changes, we did deploy a new discount engine about two weeks ago that handles coupon codes and loyalty points simultaneously.

---

**Mentor:** Good — that's much more specific. "Total is too low, as if a discount was applied that shouldn't be" is a real symptom. And the deployment two weeks ago is a strong lead.

But we're still in Phase 1. You said you tried reproducing it locally with the same cart contents — but did you reproduce the exact conditions, or just the cart? "Same items, same prices" isn't the same as "same user session, same loyalty points balance, same active coupons, same concurrent requests."

The fact that it only appears in production is a signal. Think about what's different between your local environment and production:

- Is there only one instance of the app running locally vs. multiple in prod?
- Is the loyalty points balance read from the database in real time, or is it cached anywhere?
- When a user has both a coupon code and loyalty points, do the two discount paths run independently?

Answer those, and then tell me: do you have any logs from production when the wrong total appeared? Even a timestamp you could search around?

---

**Engineer:** Oh — there are multiple app instances in prod, just one locally. I hadn't thought about that. Loyalty points are cached in Redis with a 5-minute TTL. And yes, looking at the new discount engine code, the coupon path and the loyalty points path do run independently — they each call `calculateDiscount()` and then the results are summed. I do have a timestamp from one of the incidents, about 3 days ago.

---

**Mentor:** Now we're getting somewhere. Redis cache + multiple instances + two independent discount paths running and being summed — that's a very different picture from "race condition in the pricing logic."

Before you form a hypothesis, I want you to pull those production logs around that timestamp. Look for:

- The request that produced the wrong total — what userId, what cart, what coupon, what loyalty points balance was read from Redis at that moment
- Whether there were any Redis cache invalidation events or writes happening around the same time (e.g., a loyalty points redemption or accrual)
- Whether the request hit the same app instance for both the coupon path and the loyalty points path, or different ones

Don't hypothesise yet. Pull the logs and tell me what you actually see. What value was returned for loyalty points in that bad request? What was the correct balance at that time?

The gate for Phase 1 is: you have a specific, reproducible case with exact symptoms. Right now you have the symptom and a timestamp. Go find the values.

---

**Engineer:** OK I dug into the logs. For that bad request: the user had 500 loyalty points, which should give a £5 discount. They also had a valid coupon for 10% off. The correct total should have been £40.50 — £45 cart, minus 10%, minus £5. But the total shown was £36.00. That's a £9 discount applied, not £9.50 — wait, actually that's £9 off not £9.50. Hmm. But also, I see in the logs that the loyalty points path returned a £9 discount, not £5. At the same time there was a loyalty points accrual event writing to Redis for the same user — they earned 400 new points from a previous order completing. So Redis was being written while the checkout was reading.

---

**Mentor:** Stop there — that's Phase 1 complete. You have a specific case: wrong loyalty points value read from Redis during a concurrent write. Now we move to Phase 2.

You can see what happened in the logs. State it as a hypothesis — one sentence, falsifiable.

What do you think caused the loyalty points path to return £9 instead of £5? Be specific about the mechanism, not just "something went wrong with Redis." What would have to be true about how the cache write and cache read interact for that wrong value to appear?

Don't just describe what you saw. Explain *why* it happened. What's the mechanism?

---

**Engineer:** OK... I think the loyalty points accrual (writing 900 points = 500 old + 400 new) was written to Redis partway through the checkout request. The checkout read 900 points instead of 500, so it calculated a £9 discount instead of a £5 one. The race is between the accrual write and the checkout read hitting Redis at the same time.

---

**Mentor:** That's a solid hypothesis. Let's make it precise so it's testable:

"The checkout reads the loyalty points balance from Redis after a concurrent accrual has already written the new balance, so it applies a discount based on the post-accrual total rather than the balance at checkout start. Evidence: the logged Redis value during the bad request (900 points) matches the post-accrual balance, not the pre-checkout balance (500 points)."

Is that what you mean? If yes, say it back to me in your own words — I want to make sure you own the statement, not just agree with mine.

Then answer these: what would tell you this hypothesis is *wrong*? And is the logged value (900 points = £9 discount) consistent with the total shown (£36.00)?

---

**Engineer:** Yes, that's exactly what I mean. My hypothesis: the checkout reads the loyalty points balance from Redis mid-request, after an accrual event has already updated the cache with the new higher balance, causing it to apply a larger discount than the user had earned at the time they started checkout. What would prove me wrong: if I found a bad request where the logged Redis value matched the user's *correct* balance at checkout time — that would mean it's not a stale-read problem but something else. And yes the maths checks out — £45 cart, 10% coupon = £40.50, then £9 loyalty discount = £31.50... wait that's not £36. Hmm.

---

**Mentor:** Good catch. Don't gloss over that — the maths doesn't add up and that matters. If your hypothesis is correct, the total should be £31.50, not £36.00. The discrepancy means either your hypothesis is incomplete, or one of the values you pulled from the logs isn't what you think it is.

This is what Phase 3 is for — you need to instrument the discount calculation to see exactly what values are being used at each step, not just the loyalty points value in isolation.

Before you add any instrumentation, answer this: where in the call chain does the total get computed? Walk me through it — from "user clicks checkout" to "total is displayed." I want to know every handoff where a value could be different from what you expect. Specifically:

- Where is the coupon discount calculated relative to the loyalty discount?
- Are they applied to the same base price, or does one apply to the result of the other?
- Is the final sum done in one place, or could the two paths write to a shared variable?

Find that in the code and show me. Don't assume — read it.

---

**Engineer:** I looked at the code. The coupon path applies 10% to the cart total and stores the result in a shared `discountTotal` variable. The loyalty path then *also* reads `discountTotal`, adds the loyalty discount to it, and writes it back. They're not summed at the end — they each mutate the same variable. And they run concurrently via `Promise.all()`.

---

**Mentor:** There it is. That's the actual root cause — and it's not a Redis timing issue, it's a classic read-modify-write race on a shared variable with concurrent writers.

`Promise.all()` runs both paths at the same time. Both read `discountTotal`, both add their discount, both write back. One write overwrites the other. Depending on which resolves last, you lose one of the discounts — or in some cases get a partial sum. The Redis timing was a red herring: the logged loyalty points value being wrong was a separate observation from the actual mechanism causing the wrong total.

Now complete the root cause statement. Fill this in yourself:

> "The bug is caused by **[X]** because **[Y]**, evidence **[Z]**."

Use what you found in the code and the logs. Be specific — name the variable, name the function, name the concurrency mechanism. Once you have that statement written, we can talk about Phase 3 instrumentation to confirm it before you touch a single line of production logic.

---

**Engineer:** OK: "The bug is caused by a read-modify-write race on the shared `discountTotal` variable in the discount engine because both the coupon path and loyalty points path run concurrently via `Promise.all()` and each reads, modifies, and writes back to the same variable without any synchronisation — whichever resolves last overwrites the other's contribution. Evidence: both paths are invoked with `Promise.all()` in `discountEngine.js`, both call `discountTotal +=` on the same outer-scope variable, and the incorrect totals observed in production are consistent with one discount being dropped entirely."

---

**Mentor:** That's a correct, specific root cause statement. Phase 3 confirmed. Now we can talk about a fix.

But before you write anything — one question, because this matters for how you fix it:

The two discount paths currently run concurrently and mutate shared state. There are at least two ways to fix that. Think about what they are and what the tradeoff is between them. I'm not going to name them for you.

What options do you see, and what does each one change about the behaviour of the system? Consider: does the order of discount application matter? Does it affect the final total?

Answer that first. Then we go to Phase 4.
