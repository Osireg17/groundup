# Stripe Webhook Handler — Ticket Breakdown

Based on what we agreed in the grill, here are the tickets in dependency order. Each ticket is scoped to one file, one responsibility.

---

## Ticket 1 — Repository: `findByStripePaymentId` and `updateStatus`

**File:** `src/repositories/OrderRepository.ts`

**Why first:** Everything above depends on the repository. No business logic here — just data access. Implement this before the service layer touches it.

**Scope:**
- Add `findByStripePaymentId(stripePaymentId: string): Promise<Order | null>` — looks up an order by the Stripe payment intent ID
- Add `updateStatus(orderId: string, status: OrderStatus): Promise<void>` — updates the order status by internal order ID

**Acceptance criteria:**
- Returns `null` (not throw) when no order is found for that payment ID
- DB errors propagate — do not swallow them
- Tests cover: order found, order not found, DB failure on each method

---

## Ticket 2 — Service: `updateStatus` method

**File:** `src/services/OrderService.ts`

**Why second:** Sits on top of the repository. Contains the idempotency logic — this is where duplicate event handling lives.

**Scope:**
- Add `updateStatus(stripePaymentIntentId: string, newStatus: OrderStatus, stripeEventId: string): Promise<void>`
- Look up the order by `stripePaymentIntentId`
- If order not found: log and return (do not throw — Stripe must get a 200)
- If order status is already the target status (idempotency check using the event ID or current status): log and return
- Otherwise: call repository `updateStatus`
- DB failure: let it propagate (caller maps to 500)

**Acceptance criteria:**
- Idempotent: calling twice with the same event produces no second DB write
- Order not found: logs a warning, returns without throwing
- DB failure: propagates to the controller
- Tests cover: happy path, duplicate event, order not found, DB failure

---

## Ticket 3 — Middleware: Stripe signature validation

**File:** `src/middleware/webhookSignature.ts`

**Why third:** Pseudocode is already in this file. Implement what's there. The controller depends on this middleware being correct before wiring it in.

**Scope:**
- Validate the `stripe-signature` header using `stripe.webhooks.constructEvent`
- Attach the parsed `Stripe.Event` to `res.locals` (or `req` — match whatever pattern the codebase uses)
- On invalid/missing signature: respond 400, do not call `next()`
- On valid: call `next()`

**Acceptance criteria:**
- Invalid signature → 400, request stops
- Missing header → 400, request stops
- Valid signature → event attached, `next()` called
- Raw body is used (not parsed JSON) — confirm Express is configured with `express.raw()` on the webhook route
- Tests cover: valid, invalid signature, missing header

---

## Ticket 4 — Controller: `StripeWebhookController`

**File:** `src/webhooks/StripeWebhookController.ts` (create)

**Why last:** Depends on the middleware (event already validated and parsed) and the service (business logic already implemented). Pure orchestration — read the event, route to the right handler, respond.

**Scope:**
- Single POST handler: reads `Stripe.Event` from `res.locals` (set by middleware)
- Switch on `event.type`:
  - `payment_intent.succeeded` → call `OrderService.updateStatus` with `paid`
  - `payment_intent.payment_failed` → call `OrderService.updateStatus` with `failed`
  - Anything else → log the event type, respond 200 (do not fail Stripe)
- On `OrderService` success → 200
- On `OrderService` throwing (DB failure) → 500

**Acceptance criteria:**
- Unknown event type: logs and returns 200
- Known event type, order not found: OrderService handles it — controller gets 200 back
- DB failure: controller responds 500
- No business logic in the controller — just routing and response codes
- Tests cover: each handled event type, unknown type, DB failure path

---

## Suggested order of work

```
Ticket 1 (Repository) → Ticket 2 (Service) → Ticket 3 (Middleware) → Ticket 4 (Controller)
```

Tickets 1 and 3 have no dependency on each other — they can be worked in parallel if there are two people. Ticket 2 blocks on 1. Ticket 4 blocks on all three.

---

## Notes

- The idempotency check in Ticket 2 is the most complex piece. Before implementing, be clear on your answer: are you deduplicating on `stripeEventId` stored in the DB, or on the order's current status? These have different failure modes. We should agree on this before you write a line.
- Make sure the webhook route is registered with `express.raw()` middleware, not `express.json()`. Stripe signature validation will fail on a parsed body. Check the Express route registration before Ticket 3 goes to review.
