Good news — this is a well-scoped change. Here's how the jobs layer typically works in a Node.js/TypeScript monolith, and where your flag logic would live.

**Typical jobs layer structure**

```
src/
  jobs/
    scheduler.ts              ← registers all cron jobs
    ReconciliationJob.ts      ← the job you'd touch
  services/
    ReconciliationService.ts  ← business logic per order
  repositories/
    OrderRepository.ts        ← DB access
```

The reconciliation job usually looks like this:

```ts
// ReconciliationJob.ts
class ReconciliationJob {
  async run() {
    const orders = await orderRepository.findUnreconciled();
    for (const order of orders) {
      await reconciliationService.reconcile(order);
    }
  }
}
```

**Where your flag goes**

The cleanest place for the flagging logic is inside `ReconciliationService.reconcile()`, after the reconciliation check runs. You'd add something like:

```ts
if (order.total > 1000) {
  order.flaggedForReview = true;
  // or: await flagRepository.create({ orderId: order.id, reason: 'over_threshold' })
}
```

**What you'll need to figure out**

1. Does an `Order` model have a `flaggedForReview` boolean, or do you need a separate `flags` table?
2. Should flagged orders still be marked as `reconciled`, or does the flag change their status?
3. Is $1000 hardcoded or should it come from config?

I'd start by reading `ReconciliationService.ts` to see how the existing status assignments work, then model your flag logic the same way. Want me to sketch out the implementation?
