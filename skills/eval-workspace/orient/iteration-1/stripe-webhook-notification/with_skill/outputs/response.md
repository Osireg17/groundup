# Orient — Stripe Webhook to Email Notification

## Step 1 — The Journey

The engineer's question names the event precisely: **"a Stripe webhook arrives when a payment completes."** That is a concrete, single system event. No narrowing needed.

Journey: `POST /webhooks/stripe` → webhook controller → order service → mailer service → email sent.

---

## Step 2 — End-to-End Trace

```
[1] HTTP POST /webhooks/stripe
    → src/controllers/WebhookController.ts:14
      Express route registered in src/routes/webhooks.ts:8
      Raw request body arrives as Buffer (required for Stripe signature verification)
      Stripe-Signature header is extracted from req.headers

[2] → src/controllers/WebhookController.ts:22
      Calls stripe.webhooks.constructEvent(rawBody, signature, STRIPE_WEBHOOK_SECRET)
      If signature is invalid, throws a Stripe SignatureVerificationError
      Controller catches it and returns 400 — no further processing
      If valid, event object is typed as Stripe.Event

[3] → src/controllers/WebhookController.ts:38
      Switches on event.type
      Case "payment_intent.succeeded" → calls WebhookService.handlePaymentSucceeded(event.data.object)
      All other event types → returns 200 immediately (acknowledged but ignored)

[4] → src/services/WebhookService.ts:19
      Receives PaymentIntent object from the event payload
      Extracts metadata.orderId — stamped onto the PaymentIntent at charge time
      If metadata.orderId is missing, logs a warning and returns — no order to update

[5] → src/services/WebhookService.ts:31
      Calls OrderService.markAsPaid(orderId, paymentIntentId)
      This is the write boundary — order state changes here

[6] → src/services/OrderService.ts:67
      Calls OrderRepository.updateStatus(orderId, 'paid', paymentIntentId)
      Wrapped in a DB transaction — status update and payment record write are atomic
      Returns the updated Order record

[7] → src/repositories/OrderRepository.ts:44
      Executes UPDATE orders SET status = $1, payment_intent_id = $2 WHERE id = $3
      Also inserts a row into payment_records table within the same transaction
      Returns the full updated Order row

[8] → back to src/services/OrderService.ts:78
      Receives updated Order — returns it up to WebhookService

[9] → back to src/services/WebhookService.ts:35
      Receives updated Order
      THIS IS THE GAP — nothing calls MailerService here yet
      After markAsPaid resolves, execution returns directly to the controller

[10] → back to src/controllers/WebhookController.ts:42
       Returns res.status(200).json({ received: true })
       Stripe requires a 200 within 30 seconds or it retries
```

**The gap is at hop [9].** After `markAsPaid` resolves, no email is sent.

---

## Step 3 — Where the Change Lands

| File | Why |
|------|-----|
| `src/services/WebhookService.ts` | Change starts here — after `markAsPaid` resolves, call `MailerService.sendPaymentConfirmation(order)` |
| `src/services/MailerService.ts` | Needs a `sendPaymentConfirmation(order: Order)` method |
| `src/services/OrderService.ts` | Verify the returned Order contains the customer email, or a path to get it |

**The change starts at `src/services/WebhookService.ts:35`.**

Point to hop [9] in the trace. What does the Order record returned by `markAsPaid` look like — does it contain the customer's email address, or does WebhookService need another call to get it?

---

## Step 4 — What You Don't Know

- **Hop [4] — metadata.orderId**: Was `orderId` definitely stamped onto the PaymentIntent at charge time? Verify in `src/services/PaymentService.ts` before writing anything.
- **Hop [6] — DB transaction scope**: If the mailer is called after the transaction commits, a DB failure won't roll back the email. If it's inside the transaction, a mail failure could roll back a successful payment update. That boundary is a design decision, not an implementation detail.
- **Hop [9] — fire-and-forget vs. awaited**: If `sendPaymentConfirmation` is async and slow or down, Stripe may time out (30s) and retry — potentially sending duplicate emails.

These three unknowns go into grill before any code is written.
