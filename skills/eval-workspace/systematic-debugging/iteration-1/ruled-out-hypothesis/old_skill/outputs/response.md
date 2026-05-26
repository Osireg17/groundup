# Systematic Debugging Eval — Ruled-Out Hypothesis
## Skill: old_skill (iteration-1 snapshot)

---

**Engineer:** Ok so I logged everything like you said. I thought the bug was that the discount code wasn't being applied, so I logged the discount field going into the price calculation — and it IS being passed correctly. So my hypothesis was wrong. I'm not sure what to do now. Maybe I should just comment out the discount logic entirely and see if anything changes?

**Mentor:** Good — ruling out a hypothesis is real progress. You now know the discount is arriving correctly at the price calculation. That's a fact you didn't have before.

But commenting out the discount logic is a speculative change. You'd be running two experiments at once — removing logic *and* observing the effect — without knowing what you're looking for. That's the "let me just try a few things" trap. If something changes, you won't know why.

Before you touch any code: what is the actual symptom you're seeing? The wrong final price — but exactly how wrong? Is the discount being ignored, applied twice, applied to the wrong line item?

---

**Engineer:** Right, so the symptom is that the discount is supposed to knock 10% off the total, but the customer is being charged the full price. No error, no exception — just the wrong number coming out.

**Mentor:** OK, so the discount arrives correctly at the price calculation, but the output is the full price. That tells you the bug lives *inside* the price calculation — the discount goes in but doesn't affect the number that comes out.

You said you logged the discount field going *into* the price calculation. Did you also log the calculated price coming *out* of it? And the price at the point it's actually charged to the customer?

---

**Engineer:** I logged the input but not the output of the calculation, no. I can add that. But actually — wait. There's a method called `applyDiscount` that's called inside the price calculation. I assumed it was working. Should I be looking in there?

**Mentor:** That's a sharper instinct — follow it. You've confirmed the discount arrives at the price calculation. You haven't confirmed `applyDiscount` is actually being called, or what it's returning.

Before you look inside it: what would you need to log to confirm or rule out that `applyDiscount` is either not being called, or being called but returning the wrong value? Think about the boundary — what goes in, what should come out.

---

**Engineer:** I guess I'd log: that `applyDiscount` was called, what the price and discount were when it was called, and what it returned. Then I'd compare that return value to the final price the customer sees.

**Mentor:** Exactly right. Log at the entry and exit of `applyDiscount` — inputs and output. That's the boundary. Run it and tell me what you see.

One more thing to check while you're in there: is there any conditional inside `applyDiscount` that might cause it to skip the discount under certain conditions? A feature flag, a minimum order threshold, a check on the discount type? Log which branch is taken if there's a conditional.

---

**Engineer:** Ok I added the logs. So `applyDiscount` IS being called, the inputs look right — price is correct, discount rate is 0.1. But the return value is the same as the input price. It's returning the full price, not the discounted price. I think I found it — there's a line in there: `discountedPrice = price - (price * discountRate)` but then it returns `price` instead of `discountedPrice`. It's computing the right number and then throwing it away.

**Mentor:** There it is. Now state the root cause in one sentence before you touch anything:

"The bug is caused by **[X]** because **[Y]**, evidence **[Z]**."

Fill that in. Make it specific.

---

**Engineer:** The bug is caused by `applyDiscount` returning the original `price` instead of `discountedPrice` because the variable assignment is correct but the return statement references the wrong variable, evidence: logs show the correct discounted value is computed but the return value equals the input price.

**Mentor:** That's a complete root cause statement. That's exactly what you need before touching the fix.

The fix is small — one line. Make it, run your tests, and before you ship: write a test that would have caught this. A test that asserts `applyDiscount(100, 0.1)` returns `90`, not `100`. That test should have existed already. It's the regression guard that makes sure this doesn't come back silently.

When you've fixed it and the test is green, add this above the fix as a comment:

```
// Root cause: applyDiscount returned `price` instead of `discountedPrice` — correct
// value was computed but the wrong variable was referenced in the return statement.
// Fix: return discountedPrice.
```

The next engineer who touches this will thank you.
