# Systematic Debugging Eval — Intermittent Checkout Price Bug

**Skill:** groundup:systematic-debugging (iteration-1 snapshot)
**Scenario:** Intermittent wrong total price at checkout (~1 in 20 occurrences)

---

**Engineer:** I have a weird bug — sometimes the total price shown at checkout is wrong. It's not always wrong, just occasionally. Maybe 1 in 20 times. I have no idea what's causing it and I can't reproduce it reliably. I'm thinking the pricing logic might have a race condition somewhere but I'm not sure where to look.

**Mentor:** Before we look anywhere — let's build the evidence base first. "Sometimes wrong" and a race condition guess aren't enough to start debugging. We need to observe first.

A few questions to ground this:

- What does "wrong" mean exactly? Is the total too high, too low, or inconsistent on the same order? And by how much — a fixed amount, a percentage, or seemingly random?
- When did you first notice this? Did anything change recently — a deploy, a config update, a data migration?
- Do you have logs or error messages from any of the times it happened in production?

Start there. What do you actually know about what happened?

---

**Engineer:** The total is always too low when it's wrong — sometimes it looks like a discount is being applied when it shouldn't be, or like one of the line items is missing from the sum. I first noticed it about a week ago. We did deploy a new discount engine around then. As for logs — I haven't looked at them yet. I was going to add some logs and see what happens.

**Mentor:** Good — "too low, discount applied incorrectly or line item missing" is much more specific than "wrong". That's useful.

Before you add any logs, hold on. Adding logs without a hypothesis produces noise — you'll have a wall of output and no idea what to look for. The skill here is knowing what question you're trying to answer before you instrument anything.

You mentioned a new discount engine was deployed around the time this started. That's a significant piece of information.

One question: what would you have to believe is true about the discount engine for it to cause a total that's too low — either through a discount being applied when it shouldn't, or a line item disappearing from the sum?

State your best guess, even if you're not sure. A hypothesis doesn't have to be correct — it has to be specific enough to test.

---

**Engineer:** Okay... I guess my hypothesis would be that the discount engine is sometimes applying a discount to orders that don't qualify for one? Like maybe there's a bug in the eligibility check. But I'm not sure how that would cause a line item to go missing.

**Mentor:** That's a reasonable starting hypothesis. Let's make it falsifiable.

"The discount engine sometimes applies a discount to ineligible orders" — what would have to be true for that to be the case? Think about the eligibility check: what inputs does it take, and what could make it return the wrong result intermittently?

And on the line item disappearing — you said "or a line item is missing from the sum." Those are two different failure modes. A spurious discount and a missing line item don't obviously share a root cause. Before you instrument anything, which of those two do you think is more likely? Is there a way to tell from the evidence you already have which one is actually happening?

---

**Engineer:** Hmm. I guess I don't really know which one it is — I've only seen the final wrong total, not broken it down. Maybe I should look at logs to see if the line items are being passed correctly? Or check if a discount is being applied in the order record?

**Mentor:** Yes — but "look at logs to see" is still fishing without bait. Let's be precise.

You have two candidate failure modes:
1. A spurious discount is applied (total reduced by discount amount that shouldn't be there)
2. A line item is dropped before the sum (total reduced by the value of one item)

These are distinguishable without new logs — if the wrong orders are persisted in your database, you can check the order record right now: does it show a discount applied? Does the line item count match what the customer put in the cart?

Before you write a single line of diagnostic code: go look at one of the bad orders in your database. Check two things — the discount field on the order, and the count of line items. That will tell you which failure mode you're actually dealing with.

What does a bad order look like in the database?

---

**Engineer:** Oh — okay, I can do that. I pulled up one of the orders a customer complained about. The line items are all there — all three items the customer added. But there's a discount applied: `discount_code: "SUMMER10"`, `discount_amount: 12.50`. The customer says they never entered a discount code.

**Mentor:** Now we're getting somewhere. That's real evidence.

So the line item hypothesis is ruled out. The discount hypothesis survives: a discount is being applied to orders where the customer did not enter a code.

Now tighten the hypothesis. You know the discount code is `SUMMER10`. That's not a random value — it's a real code in your system. So the question is: how does `SUMMER10` end up on an order where the customer never typed it?

Think about the lifecycle of a discount code in your checkout flow: where does a discount code get attached to an order? Is it user-entered only, or are there other code paths that can apply a discount — promotions, referral links, session carry-over from a previous order?

What do you know about how `SUMMER10` gets onto an order in the normal case?

---

**Engineer:** So normally the customer types a code into the discount field, we validate it against the discount engine, and if it's valid we apply it. But now that I think about it... we do have a feature where if a user has used a code before and it's still active, we pre-fill the discount field for them. That was part of the discount engine deploy. Could that be causing it?

**Mentor:** That's a much stronger hypothesis now. Let's state it formally.

Complete this sentence:

"The bug is caused by **[X]** because **[Y]**, evidence **[Z]**."

Take a shot at it based on what you now know. You don't have to be 100% certain — but it has to be specific enough that someone else could read it and know exactly where to look in the code.

---

**Engineer:** Okay: "The bug is caused by the pre-fill feature in the new discount engine because it is applying a previously-used discount code to a new order without the customer confirming it, evidence: bad orders in the database show a `SUMMER10` discount applied with no user action, and this started after the discount engine deploy that added the pre-fill feature."

**Mentor:** That's a complete root cause statement. That's the standard.

Now you can instrument — but you know exactly what you're looking for. You want to confirm that the pre-fill path is attaching the discount to the order without a user confirmation step.

Where in the code does the pre-fill logic run? Find that code path and add logging at two boundaries:
1. When the pre-fill decision is made — log the user ID, the code being pre-filled, and what triggered it
2. When the discount is attached to the order — log whether it came from user input or from the pre-fill path

Run that in staging or against a test account. You want to see the pre-fill path execute and the discount attach without any user-entered code.

Once you've confirmed that's the path — then we talk about the fix. Not before.

What does the pre-fill code look like? And does it distinguish between "user entered this" and "we pre-filled this" anywhere?

---

**Engineer:** I found it. The pre-fill sets the discount code in the cart session object, and then the checkout submission just reads whatever is in the session — it doesn't check whether the code came from user input or from pre-fill. So if the pre-fill runs and the user doesn't remove the code, it gets applied silently. I think the fix is to either require explicit confirmation before applying a pre-filled code, or not apply a code to the final order unless the user actively submitted it.

**Mentor:** Good. You found the mechanism.

Before you decide on the fix, one more question: the bug is 1 in 20. If the pre-fill always runs for users with a prior active code, why doesn't it affect every eligible order?

That gap matters. If you don't understand why it's intermittent, you don't fully understand the root cause — and your fix might not cover all the cases.

What conditions would cause the pre-fill to run for some sessions but not others?
