---
name: groundup:orient
description: "Traces one real user journey end-to-end through the codebase, with file and line references, to locate exactly where a change fits. Use this skill whenever an engineer knows what they want to build but doesn't know where in the code it lives — when they say things like 'where does this go?', 'what calls what here?', 'where does the request land?', 'I don't know which file to touch', or 'how does this flow work?'. Also invoke when the engineer can name the feature but not the files, or when they are about to start in the wrong place. Always run this after architecture and before grill."
---

# Orient — Locate Your Change in the System

Goal: a precise answer to **where exactly does this change live, and what does it touch?**

---

## Step 1 — Pick One Journey

Ask the engineer: "What is the one user action or system event that is most relevant to what we're building?"

Wait for their answer. If it is too broad, narrow it: "Pick the single most important entry point for the change we're making."

A good journey is concrete and specific:
- "A user submits the checkout form"
- "The payment webhook arrives from Stripe"
- "The nightly reconciliation job runs"
- "A message arrives on the orders queue"

"When users do stuff with orders" is not a journey. Push until you have a single, nameable event.

---

## Step 2 — Trace It End-to-End

You do the tracing. Read the code — do not ask the engineer to trace it for you.

Walk through the journey one hop at a time. For each hop, find and record:
1. The actual file and line where control passes
2. What data arrives at that point and what shape it is in
3. What decision or transformation happens here
4. Where control goes next

Do not summarise. "Then it hits the service layer" is not a hop. Name the file. Name the method. Show the call.

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

Every hop needs: file + line, what arrives, what happens, what leaves.

---

## Step 3 — Mark Where the Change Lands

Once the full journey is traced, present it to the engineer and ask:

"Point to the hop where our change starts. Which file do we touch first?"

Wait for their answer. Then, one question at a time:

- If they point to the right hop: "What does our change need from the hops before it?"
- Once they answer that: "What do the hops after it depend on that our change might affect?"
- Once they answer that: "Are we crossing an architectural boundary here? If yes — does our change belong on this side of it?"

The engineer should leave this step able to answer "which files are affected and why" with specific paths — not vague layer names. If they can't, the trace wasn't specific enough. Go back and tighten it.

---

## Step 4 — Surface What You Don't Know

After Step 3, ask:

"Was there any hop in that journey where you weren't sure what was happening — where you followed the call but didn't understand the decision?"

If they name a gap, acknowledge it and add it to the list of things to resolve during grill.

---

## Exit Condition

This skill is complete when:

- One user journey has been traced hop-by-hop with file + line references
- The engineer can point to the exact file and method where the change starts
- Boundary crossings (if any) have been identified and justified
- Unknown hops have been named as explicit assumptions

---

## After Orient

Invoke `groundup:grill`. The engineer is now equipped to answer the grill questions about which files are affected and why — because they have traced the actual path.
