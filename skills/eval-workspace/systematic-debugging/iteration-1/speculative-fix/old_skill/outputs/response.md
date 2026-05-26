# Systematic Debugging Eval — Speculative Fix Scenario

**Skill version:** iteration-1 skill-snapshot
**Scenario:** Engineer proposes swallowing a 500 error without identifying root cause

---

**Engineer:** I'm getting a 500 error when users try to submit an order. I think it's probably a database timeout issue — I'm going to wrap the whole `createOrder` function in a try-catch and swallow the error so the user at least gets a success response. That should fix it right?

**Mentor:** Stop there. You've proposed a fix before stating a root cause. That's a speculative fix — and swallowing errors is one of the most dangerous things you can do in a production system. If you tell the user the order succeeded but it didn't, you now have silent data corruption. That's worse than a 500.

Before we talk about any fix, you need to complete this sentence:

> "The bug is caused by **[X]** because **[Y]**, evidence **[Z]**."

Let's start at the beginning. Have you actually looked at the error? What does the stack trace say, exactly?

---

**Engineer:** I haven't really looked at the full stack trace, I just saw a 500 in the logs. The error message just says "Internal Server Error" in the UI. I assumed it was a timeout because the DB has been slow lately.

**Mentor:** "The DB has been slow lately" is not evidence — it's a feeling. "Internal Server Error" is what the UI shows; it tells you nothing about what actually went wrong on the server.

You don't have a hypothesis yet. You have a guess shaped like one. The difference: a hypothesis is falsifiable. "It's a database timeout" — what would prove that wrong?

Before we go any further: go find the actual server-side logs for one of these failed requests. Stack trace, exception type, line number. That's Phase 1 — you need a reproducible case with real evidence before forming any hypothesis.

What does the server log say for a failing request?

---

**Engineer:** Okay I looked. Here's the stack trace:

```
NullPointerException at OrderService.createOrder(OrderService.java:84)
  at ProductInventoryChecker.checkStock(ProductInventoryChecker.java:31)
  at OrderService.createOrder(OrderService.java:78)
```

Line 84 in `createOrder` is where we call `item.getDiscount().getValue()`. The discount field is optional.

**Mentor:** Now we're making progress. You have real evidence.

Look at what you just told me: line 84 calls `item.getDiscount().getValue()`, and the `discount` field is optional. You have a `NullPointerException`. What does that tell you?

Try completing the root cause sentence now:

> "The bug is caused by **[X]** because **[Y]**, evidence **[Z]**."

Don't move to a fix until you can write that sentence. What's your attempt?

---

**Engineer:** Okay... "The bug is caused by a NullPointerException in `createOrder` because the code calls `getDiscount().getValue()` without checking if `discount` is null, evidence: `NullPointerException` at `OrderService.java:84` in the stack trace."

**Mentor:** That's a complete root cause statement. Notice how different this is from "probably a database timeout."

Now notice what the correct fix looks like: a null check before accessing `discount`, not a try-catch that swallows the exception. If you'd gone with your original plan, you would have hidden this bug — orders for discounted items would silently fail, the user would think they succeeded, and you'd have no data and no paper trail.

Before you write the fix, one question: are there other places in `createOrder` or nearby code that access optional fields without null checks? This pattern — assuming optional fields are always present — tends to repeat. Worth a quick scan before you touch anything.

What do you find?

---

**Engineer:** Yeah, actually there's also `item.getShippingOverride().getRate()` on line 91. Same pattern — `shippingOverride` is also optional. I would have missed that.

**Mentor:** Good catch. That's exactly why you read the root cause before writing the fix — the fix for the symptom you saw would have left a second landmine in place.

Now you're ready to fix both. Before you write the code, one more thing: what tests should exist to catch this regression if it comes back? Think about the edge cases: what are the different states these optional fields can be in, and which combinations do you need to cover?

Write the test cases out first, then implement the null checks. Come back when both are done.

And when you commit, add this above the fix:

```java
// Root cause: NullPointerException in createOrder because optional fields
//             (discount, shippingOverride) were accessed without null checks.
// Fix: Added null checks before accessing optional field values.
```

That comment is for the next engineer who touches this code. Make their life easier.

---

**Engineer:** That makes sense. I'll write the tests first then fix both null checks. Thanks.

**Mentor:** Good. One last thing to take away from this session: the moment you caught yourself saying "I'll just swallow the error so the user sees a success" — that instinct is a warning sign. Hiding errors doesn't fix them. It defers them into a form that's much harder to debug: silent failures with corrupted state and no trace. A 500 is honest. A fake success is a lie that compounds.

Root cause first. Always.
