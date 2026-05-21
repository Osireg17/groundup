---
name: orient
description: "After architecture is understood, trace one real user journey end-to-end to locate exactly where the change fits. Output: the specific files, entry points, and seams relevant to this session."
---

# Orient — Locate Your Change in the System

You have the architecture map. Now trace the specific path that is relevant to this session.

The goal is to answer one question precisely: **where exactly does this change live, and what does it touch?**

Junior engineers often start in the wrong place — they find a file that looks relevant and start reading outward from there. That produces a patchy mental model with gaps exactly where the bugs live. Tracing a journey end-to-end, from entry point to storage and back, closes those gaps before any code is written.

---

## Step 1 — Pick One Journey

Ask the engineer: "What is the one user action or system event that is most relevant to what we're building?"

This should be concrete and specific:
- "A user submits the checkout form"
- "The payment webhook arrives from Stripe"
- "The nightly reconciliation job runs"
- "A message arrives on the orders queue"

Not: "when users do stuff with orders." That is not a journey.

If the engineer picks something too broad, narrow it: "Pick the single most important entry point for the change we're making."

---

## Step 2 — Trace It End-to-End

Walk through the journey together, one hop at a time. For each hop:

1. Find the actual file and line where control passes
2. State what data arrives at that point and what shape it is in
3. State what decision or transformation happens here
4. State where control goes next

Do not summarise. Do not say "then it hits the service layer." Name the file. Name the method. Show the call.

**Format for each hop:**

```
[1] HTTP POST /checkout
    → src/controllers/CheckoutController.ts:42 — validates request body, extracts cartId + userId

[2] → src/services/CheckoutService.ts:18 — orchestrates the checkout flow
      calls PaymentService.charge() and OrderRepository.create() in sequence

[3] → src/services/PaymentService.ts:55 — calls Stripe API, returns PaymentIntent
      if Stripe fails, throws PaymentError — propagates up to controller

[4] → src/repositories/OrderRepository.ts:31 — writes Order record to DB
      wrapped in a transaction with the payment record

[5] → back to CheckoutController.ts:67 — serialises response, returns 201
```

Every hop should have: file + line, what arrives, what happens, what leaves.

---

## Step 3 — Mark Where the Change Lands

Once the full journey is traced, ask the engineer:

"Point to the hop where our change starts. What is the first file we will need to touch?"

Then:
- "What does our change need from the hops before it?"
- "What do the hops after it depend on that our change might affect?"
- "Are we crossing any architectural boundary? If yes, which one, and does the change belong on this side of it?"

This is the entry point for the Grill and the Flow Map. The engineer should now be able to answer "which files are affected and why" with specific paths, not vague layer names.

---

## Step 4 — Surface What You Don't Know

After the trace, ask:

"Was there any hop in that journey where you weren't sure what was happening — where you followed the call but didn't understand the decision?"

These gaps are where assumptions live. Name them explicitly before any design is done. A named assumption is a testable assumption. An unnamed one is a future bug.

---

## Exit Condition

This skill is complete when:

- [ ] One user journey has been traced hop-by-hop with file + line references
- [ ] The engineer can point to the exact file and method where the change starts
- [ ] Boundary crossings (if any) have been identified and justified
- [ ] Unknown hops have been named as explicit assumptions

---

## After Orient

If this is the start of a session, invoke `grill`. The engineer is now equipped to answer the grill questions about which files are affected and why — because they have traced the actual path.
