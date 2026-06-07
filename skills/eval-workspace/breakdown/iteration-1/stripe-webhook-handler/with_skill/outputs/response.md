# Breakdown Response — Stripe Webhook Handler

---

## Response to Engineer

Here's how I've broken this into 4 tickets. We start with **Ticket 1 (OrderRepository)** because it has no dependencies on any other new code — everything else builds on top of it. Repository first, then service, then middleware, then controller (the entry point that wires it all together). Does this feel right — anything you'd split, combine, or reorder?

---

## tickets.md content

```markdown
# Tickets — Stripe Webhook Handler

Created: 2026-06-07

## What We're Building

We're adding a Stripe webhook handler to an Express/TypeScript app that validates the Stripe signature, identifies the event type, and updates order status in the DB. Tickets are ordered data-layer-first: the repository has no new dependencies, the service depends on the repository, the middleware is standalone, and the controller (entry point) depends on all three.

---

## Ticket 1: Add findByStripePaymentId and updateStatus to OrderRepository

**Goal**: Extend the repository with the two DB access methods the service layer needs to look up and update orders by Stripe payment ID.
**Files**:
- `src/repositories/OrderRepository.ts` — modify
**Depends on**: none
**Acceptance criteria**:
- [ ] `findByStripePaymentId(stripePaymentId)` returns the matching order or null when no record exists
- [ ] `updateStatus(orderId, status)` persists the new status and returns the updated order
- [ ] Both methods are covered by unit tests (happy path + not-found / DB error cases)

---

## Ticket 2: Add updateStatus to OrderService

**Goal**: Add the service-layer method that fetches an order by Stripe payment ID and updates its status, enforcing the idempotency and not-found rules agreed in the grill.
**Files**:
- `src/services/OrderService.ts` — modify
**Depends on**: Ticket 1
**Acceptance criteria**:
- [ ] If the order is already in the target status (duplicate event), the method returns without performing a DB write — idempotent
- [ ] If no order is found for the given Stripe payment ID, the method logs and returns without throwing — Stripe must receive a 200
- [ ] If the DB write fails, the error is allowed to propagate so the caller can return a 500
- [ ] All three branches are covered by unit tests

---

## Ticket 3: Implement webhookSignature middleware

**Goal**: Complete the existing pseudocode in the middleware file so that requests with an invalid or missing Stripe signature are rejected with a 400 before reaching the controller.
**Files**:
- `src/middleware/webhookSignature.ts` — modify (pseudocode already present)
**Depends on**: none
**Acceptance criteria**:
- [ ] Valid signature — request passes through to `next()`
- [ ] Missing or invalid signature — responds 400, does not call `next()`
- [ ] Raw body is preserved for Stripe signature verification (not the parsed JSON body)
- [ ] Both branches are covered by unit tests using a mocked Stripe SDK

---

## Ticket 4: Create StripeWebhookController

**Goal**: Wire up the HTTP entry point that applies the signature middleware, routes the Stripe event to the correct handler, and returns the appropriate status code for every outcome.
**Files**:
- `src/webhooks/StripeWebhookController.ts` — create
**Depends on**: Ticket 2, Ticket 3
**Acceptance criteria**:
- [ ] `payment_intent.succeeded` event calls `OrderService.updateStatus` and returns 200
- [ ] Unknown event type is logged and returns 200 (Stripe must not retry)
- [ ] Invalid signature returns 400 (handled by middleware, but covered by integration test)
- [ ] DB failure (propagated from service) returns 500
- [ ] Duplicate event (idempotent service call) returns 200 without error
- [ ] All branches covered by integration tests with mocked service and middleware
```

---

## Session State (for .groundup/session-state.json)

```json
{
  "phase": "per_ticket_loop",
  "current_ticket": 1,
  "tickets_file": ".groundup/tickets.md"
}
```
