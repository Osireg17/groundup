# Systematic Debugging Eval — Ruled-Out Hypothesis
**Skill:** groundup:systematic-debugging
**Scenario:** Engineer has logged and ruled out their initial hypothesis. About to make a speculative change.

---

**Engineer:** Ok so I logged everything like you said. I thought the bug was that the discount code wasn't being applied, so I logged the discount field going into the price calculation — and it IS being passed correctly. So my hypothesis was wrong. I'm not sure what to do now. Maybe I should just comment out the discount logic entirely and see if anything changes?

**Mentor:** Good — a ruled-out hypothesis isn't failure, it's evidence. You've just narrowed the space. You now know the bug is NOT in how the discount is passed into the price calculation. That's real progress.

But commenting out the discount logic without a hypothesis is the "let me just try a few things" trap. If that changes the behaviour, you won't know *why* — you'll have multiple simultaneous experiments and you won't be able to reason about what you found. Don't go down that road.

You're back in Phase 2. You have new evidence: the discount value arrives correctly at the price calculation boundary. So the problem is either in what happens *inside* the price calculation with that value, or somewhere *after* the calculation.

What does the price calculation actually do with the discount once it receives it? Walk me through what you'd expect it to do, and what's actually happening at the output.

---

**Engineer:** Right, ok. So the price calculation should take the original price and subtract the discount amount. I only logged the input — I didn't log the output of the calculation itself. The symptom is that the final price shown to the user is wrong — it's showing the full price without the discount applied. So... maybe the discount is arriving but not actually being subtracted?

**Mentor:** That's a hypothesis. State it as one falsifiable sentence.

---

**Engineer:** The discount value is passed correctly into the price calculation, but the subtraction isn't happening — so the function is returning the original price unchanged.

**Mentor:** Good. Now test it. Where specifically would you add logging to confirm or rule that out?

Think about the boundaries inside the price calculation function itself: what goes in, what computation happens, and what comes out. You already have the input side logged. What do you need to see?

---

**Engineer:** I need to log the output of the calculation — the value being returned from the function — and probably also log inside the function to see if the subtraction step is actually running. Like, maybe there's a conditional branch that skips it.

**Mentor:** Exactly. Log at three points:

1. The value returned by the price calculation function
2. Any conditional branches inside it — which branch is being taken, and what value triggered it
3. If there's a subtraction step, log what goes in and what comes out of it

Don't change any logic. Diagnostics only. Run it and come back with what you see.

---

**Engineer:** Ok I added the logs. So... there's actually a conditional in there — it checks `if (discount > 0)` before applying it. I logged the discount value at that branch and it's coming in as the string `"10"` not the number `10`. So the condition is evaluating `"10" > 0` which is... actually true in JavaScript? But then the subtraction is doing `price - "10"` and... oh. It's string concatenation, not subtraction. `200 - "10"` gives `190` but wait, that should work. Let me look again... actually the discount is being logged as `"0"` at the branch, not `"10"`. It's `"0"` the string, so `"0" > 0` is false. The branch isn't running.

**Mentor:** Now you have a root cause. State it in the full form before we go any further:

> "The bug is caused by **[X]** because **[Y]**, evidence **[Z]**."

---

**Engineer:** The bug is caused by the discount value being the string `"0"` at the conditional branch because somewhere between the discount being passed correctly into the function and reaching that branch, it's being overwritten or re-parsed — evidence: logging shows the discount arriving as `"10"` at the function input but as `"0"` at the branch check, so the conditional always evaluates false and the subtraction never runs.

**Mentor:** That's a complete root cause statement. Now you know exactly what to look for: something between the function entry point and that conditional that's touching the discount value. There's a transformation or reassignment happening in that gap that you haven't logged yet.

Before you write any fix — go find that transformation. Where in the function body between the input log and the branch log could the discount value be changed? Check every assignment, every function call that takes discount as an argument, any data-shaping step.

Find it, confirm it with a log, and then come back. The fix should be obvious once you can see exactly where the value changes.

---

**Engineer:** Found it. There's a `normalizeOrderData()` call near the top of the function that I'd completely forgotten about. It's reshaping the order object and it has a line that sets `discount` to `parseInt(discount, 10) || 0` — so if `parseInt` returns `NaN` for any reason, it defaults to `0`. The discount code coming in is `"SAVE10"` as a string in one of the test cases — `parseInt("SAVE10")` gives `NaN`, so it gets zeroed out. In the real case the discount field holds the *amount* `"10"` but it goes through `normalizeOrderData` first, and somewhere upstream the amount is being passed as `undefined` sometimes, which also gives `NaN` and then `0`.

**Mentor:** Good. Now you have the full picture. Write the root cause comment above the fix before you touch anything:

```
// Root cause: discount amount is zeroed out in normalizeOrderData() because
// parseInt(discount, 10) || 0 converts undefined or non-numeric values to 0.
// When discount amount is undefined upstream, it silently becomes 0 and the
// conditional branch in the price calculation never runs.
// Fix: [what you're changing and why]
```

Then fix it. And before you ship: what test would catch this regression if it came back?
