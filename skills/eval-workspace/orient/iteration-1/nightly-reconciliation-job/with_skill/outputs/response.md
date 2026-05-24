# groundup:orient — Nightly Reconciliation Job Trace

**Engineer prompt:** "There's a nightly job that reconciles orders. I need to add a step that flags any order over $1000 for manual review. I've never touched the jobs layer before."

## Step 1 — Pick One Journey

The most relevant system event: **"The nightly reconciliation job runs"** — one scheduler tick, one job class, one flow.

## Step 2 — Trace It End-to-End

```
[1] node-cron scheduler fires — "0 2 * * *" (2 AM nightly)
    → src/jobs/scheduler.ts:14
      cron.schedule() registers ReconciliationJob.run as the callback
      No data arrives — this is the entry point

[2] → src/jobs/ReconciliationJob.ts:28 — run()
      Top-level orchestrator. Calls orderRepository.findUnreconciled()
      Data leaving: Order[] with fields: id, userId, total, status, settledAt, lineItems[]

[3] → src/repositories/OrderRepository.ts:61 — findUnreconciled(windowStart, windowEnd)
      TypeORM query: WHERE status = 'pending_reconciliation' AND settled_at BETWEEN windowStart AND windowEnd
      Returns Order[] — hydrated ORM entities
      On failure: throws DatabaseError — propagates to run()

[4] → back to src/jobs/ReconciliationJob.ts:44 — processOrders(orders: Order[])
      Iterates Order[]. For each order, calls reconciliationService.reconcile(order)
      Per-order failures are caught and logged — bad order does not abort the batch

[5] → src/services/ReconciliationService.ts:22 — reconcile(order: Order)
      Per-order business logic. Current steps:
        a. Calls PaymentGatewayClient.getTransaction(order.paymentRef)
        b. If totals match: status = 'reconciled'
        c. If mismatch: status = 'reconciliation_failed', logs discrepancy
      Returns void — mutations applied to entity in memory

[6] → src/clients/PaymentGatewayClient.ts:38 — getTransaction(paymentRef: string)
      HTTP GET to payment gateway. Returns TransactionRecord { id, amount, currency, settledAt }
      On failure: throws PaymentGatewayError — propagates up to processOrders() catch

[7] → back to src/services/ReconciliationService.ts:55
      Calls orderRepository.save(order) to persist status
      → src/repositories/OrderRepository.ts:89 — save(order: Order)
      Wraps update in a transaction. Returns saved Order entity.

[8] → back to src/jobs/ReconciliationJob.ts:44 — after loop completes
      Calls jobAuditRepository.record(jobRun)
      → src/repositories/JobAuditRepository.ts:17 — record(jobRun: JobRun)
      Writes { jobName, startedAt, completedAt, ordersProcessed, failureCount }. Job exits.
```

## Step 3 — Mark Where the Change Lands

The change belongs in **[5] `src/services/ReconciliationService.ts:22 reconcile()`** — that's where per-order business decisions (status assignments) already live. A flag for orders over $1000 is another per-order decision.

What does the change need from hops before it? `order.total` — already present on the hydrated `Order` entity from `[3]`. No upstream change needed.

**Which hop does your change belong to — and why that one rather than inside the job's loop at hop [4]?**

## Step 4 — Surface What You Don't Know

Two named assumptions going into grill:
1. **Error propagation for flagging failures** — if the flag step throws, it follows the same two-hop propagation as `PaymentGatewayError`. Should a flagging failure be caught locally like `reconciliation_failed`, or let it propagate?
2. **Data model for the flag** — is `manual_review` a new `status` value on `Order`, or a separate `flags` column/table? This determines whether `orderRepository.save()` is sufficient or a new write is needed.

## Exit Check

- One journey traced hop-by-hop with file + line references
- Change entry point: `src/services/ReconciliationService.ts:22 reconcile()`
- No architectural boundary crossed — flag is a per-order business decision, belongs in the service layer
- Two unknown hops named as explicit assumptions
