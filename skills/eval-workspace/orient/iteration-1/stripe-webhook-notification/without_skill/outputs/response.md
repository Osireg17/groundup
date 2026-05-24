**Where the webhook lands**

In a Node.js/TypeScript Express layered monolith, Stripe webhooks land in a dedicated webhooks controller:

```
src/
  controllers/
    webhooks.controller.ts    ← webhook arrives here
  services/
    payment.service.ts
    mailer.service.ts         ← email sending lives here
  repositories/
    order.repository.ts
  routes/
    webhooks.routes.ts        ← registers POST /webhooks/stripe
```

The route is registered as:
```ts
router.post('/webhooks/stripe', express.raw({ type: 'application/json' }), WebhooksController.handleStripe);
```

Note `express.raw()` — Stripe requires the raw body for signature verification. This route must NOT use `express.json()`.

**Files to touch**

1. `src/controllers/webhooks.controller.ts` — add a case for `payment_intent.succeeded`, delegate to `PaymentService.handlePaymentSucceeded`
2. `src/services/payment.service.ts` — add `handlePaymentSucceeded`: look up the order, update status, call the mailer
3. `src/services/mailer.service.ts` — add `sendPaymentConfirmation`: render template and dispatch via email provider

**Key edge cases to handle**
- Signature verification must happen before any processing — skip it and anyone can trigger emails via a fake POST
- Idempotency — Stripe can deliver the same event more than once; check `event.id` before sending to avoid duplicate emails
- Raw body — if `express.json()` is global, the webhook route must be explicitly excluded; this is the most common cause of signature verification failures
- Correct event type — `payment_intent.succeeded` vs `checkout.session.completed` depends on which Stripe integration is in use
