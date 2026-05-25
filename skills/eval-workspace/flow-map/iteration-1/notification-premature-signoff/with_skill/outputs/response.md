# Flow Map Eval — Notification Premature Sign-off

**Scenario:** Junior engineer presents a thin 3-step notification flow and asks to move to pseudocode immediately.

**Skill loaded:** `groundup:flow-map`

---

## Turn 1

**Engineer:**
> I've drawn the flow for a notification system. When a user completes an order:
> 1. Order service saves the order
> 2. Order service sends an email notification
> 3. User gets the email
>
> I think that covers it. Can we move on to pseudocode?

**Claude (flow-map skill):**

Good start — you've got the happy path sketched out. Before we agree and move to pseudocode, I want to make sure the diagram holds up under pressure, because the pseudocode comes directly from this contract.

One thing I'm noticing: step 2 says the order service *sends* the email. Is that call synchronous — meaning the order service is waiting for the email to be delivered before it responds to the user?

---

## Turn 2

**Engineer:**
> Yeah it's synchronous. The service calls some email library, it sends, done. It's pretty simple — can we just move on? I don't want to overthink this.

**Claude (flow-map skill):**

I hear you — and we're close, I promise this is worth the two minutes.

Here's what I'm curious about: if the email library call fails — say the SMTP server is down or times out — what happens to the order? Does it get saved, or does it roll back?

Right now your flow has both "save the order" and "send the email" happening in the same sequence, with no indication of where the transaction boundary sits. That's the thing I want us to nail down before we write a line of pseudocode — because if we get it wrong here, we end up with either lost orders or orders the user never gets notified about, and that's a much harder bug to find later.

---

## Turn 3

**Engineer:**
> Oh... I guess if the email fails, the order should still be saved. I hadn't thought about that. So maybe the save and the send shouldn't be in the same transaction?

**Claude (flow-map skill):**

Exactly — you've just spotted the transaction boundary. That's the key insight here.

So now we have two separate concerns: saving the order (which must succeed reliably), and sending the notification (which can fail without undoing the order). There's a well-known pattern for exactly this situation — let me surface it before we lock the diagram, because it might change the shape of the flow.

The pattern is called the **Outbox Pattern**. Instead of the order service calling the email service directly, the order service writes the email notification as a record into an `outbox` table *in the same database transaction* as the order save. A separate background process reads from the outbox and sends the emails. That way:
- The order and the notification intent are committed atomically
- Email delivery failures don't affect order saving
- You get at-least-once delivery without distributed transactions

The alternative — what you have now — is to save the order, then make the email call synchronously. Simpler to implement, but any email failure leaves the order saved with no notification sent, and there's no built-in retry.

Given that this is an order completion notification (something the user really needs to receive), which of these tradeoffs matters most to you?

---

## Turn 4

**Engineer:**
> That outbox pattern makes a lot of sense. Let's use that. So the flow would be:
> 1. Order service receives the request
> 2. Order service saves the order AND writes an outbox record in one transaction
> 3. Background worker reads the outbox record
> 4. Background worker sends the email
> 5. Background worker marks the outbox record as processed
>
> Is that right?

**Claude (flow-map skill):**

That's the right shape. A couple of things to fold in before we sign off:

- What happens if the background worker sends the email but then crashes before marking the outbox record as processed? It'll send the email again on the next run. That's acceptable for most notification systems, but worth stating explicitly — we're choosing at-least-once delivery. Does that fit your use case?
- Who marks the outbox record as processed — is it deleted, or given a status flag? That's a file-level detail, but it affects the schema.

Assuming at-least-once delivery is acceptable, here's the agreed diagram:

```
Flow:

User
  │
  ▼
Order Service ──────────────────────────────────────────┐
  │  [single DB transaction]                            │
  ├── saves Order record ─────────────────────────────► DB
  └── writes Outbox record (status=PENDING) ──────────► DB
                                                         │
Background Worker (polling)                              │
  │  reads PENDING outbox records ◄─────────────────────┘
  │
  ├── calls Email Service / SMTP
  │     IF success → marks outbox record PROCESSED
  │     IF failure → leaves record PENDING (retried next poll)
  │
  ▼
User receives email
```

Implementation order:
1. `db/migrations/001_add_outbox_table.sql` — reason: no code dependencies; schema must exist first
2. `order_service/repository.py` — reason: handles the atomic save + outbox write; no dependency on worker
3. `worker/notification_worker.py` — reason: depends on the outbox table and email client; reads what the repository writes
4. `email/email_client.py` — reason: called by the worker; lowest-level dependency, no knowledge of orders or outbox

Both signed off on this? If yes, we move to pseudocode starting with the migration.
