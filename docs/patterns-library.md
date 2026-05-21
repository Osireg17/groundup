# Patterns Library

A growing reference of industry patterns, surfaced during groundup sessions. Each entry captures: what the pattern is, when it applies, the tradeoff, and a pointer to further reading.

This file grows organically. Add a pattern when it comes up in a real session and turns out to be a high-value teaching moment. Keep entries short — this is a quick reference, not a textbook.

---

## How to Add a Pattern

```markdown
### [Pattern Name]
**Category:** [Resilience | Performance | Readability | Distributed Systems | Data Integrity]
**In one line:** [what it does]
**Use when:** [the condition that makes this pattern relevant]
**Tradeoff:** [what you gain vs what it costs]
**Further reading:** [one link — official docs, Martin Fowler, or a well-regarded article]
```

---

## Resilience

### Outbox Pattern
**Category:** Resilience / Distributed Systems
**In one line:** Atomically write to your DB and reliably publish an event by writing the event to an "outbox" table in the same transaction, then polling and publishing separately.
**Use when:** You need to write to a database and publish an event or message, and you can't afford to lose either or have them go out of sync.
**Tradeoff:** Guarantees consistency and delivery at the cost of operational complexity — you need a poller/relay process and idempotent consumers.
**Further reading:** https://microservices.io/patterns/data/transactional-outbox.html

---

### Retry with Exponential Backoff
**Category:** Resilience
**In one line:** Retry failed calls with increasing wait times between attempts plus a random jitter.
**Use when:** Calling external services or resources that may fail transiently.
**Tradeoff:** Improves resilience against transient failures; can delay processing and mask persistent failures if max retries is too high.
**Further reading:** https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/

---

### Circuit Breaker
**Category:** Resilience
**In one line:** After N consecutive failures to a downstream service, stop calling it for a period and return a fast failure instead.
**Use when:** A downstream service is unreliable and you want to fail fast rather than letting failures cascade.
**Tradeoff:** Prevents cascade failures; requires careful threshold tuning — too sensitive and you trip the circuit on noise.
**Further reading:** https://martinfowler.com/bliki/CircuitBreaker.html

---

### Idempotency Keys
**Category:** Resilience
**In one line:** Accept a client-supplied key that uniquely identifies the request; if you've seen this key before, return the previous result instead of processing again.
**Use when:** Operations must not be executed more than once (payments, order creation) but the client may retry on network failure.
**Tradeoff:** Guarantees safe retries; requires storing and looking up keys, and defining an expiry policy.
**Further reading:** https://stripe.com/docs/idempotent-requests

---

## Performance

### Batch Writes
**Category:** Performance
**In one line:** Insert or update multiple records in a single DB statement instead of one per record.
**Use when:** You're inserting or updating records in a loop.
**Tradeoff:** Dramatically reduces DB round-trips and latency; makes error handling more complex (which record failed?).
**Further reading:** Search "bulk insert [your DB]" — most ORMs and DB clients support this natively.

---

### N+1 Query Elimination
**Category:** Performance
**In one line:** Fetch all related records in one query rather than one query per parent record.
**Use when:** You're iterating over a list and fetching related data for each item inside the loop.
**Tradeoff:** Reduces queries from N+1 to 2 (or 1 with a join); requires knowing the shape of the data you need upfront.
**Further reading:** https://www.sqlshack.com/what-is-n1-selects-problem-and-how-to-solve-it/

---

### Cache-Aside (Lazy Loading)
**Category:** Performance
**In one line:** Check the cache first; on a miss, load from the DB, store in cache, return the value.
**Use when:** Reads are frequent, data doesn't change often, and you can tolerate stale reads for a period.
**Tradeoff:** Reduces DB load significantly; cache invalidation is hard to get right — stale data is a real risk.
**Further reading:** https://docs.aws.amazon.com/whitepapers/latest/database-caching-strategies-using-redis/caching-patterns.html

---

### Streaming vs Buffering
**Category:** Performance
**In one line:** Process data as it arrives rather than loading it all into memory before starting.
**Use when:** Processing large datasets (files, DB result sets, API responses) where loading everything at once would exhaust memory.
**Tradeoff:** Lower memory footprint and faster time-to-first-result; code is more complex, harder to reason about.
**Further reading:** Search "streaming [your language]" — Node.js streams, Java InputStream, Python generators.

---

## Readability

### Guard Clauses / Early Return
**Category:** Readability
**In one line:** Handle error/edge cases at the top of the function and return early; leave the happy path reading straight down.
**Use when:** You have nested if/else chains that make the happy path hard to find.
**Tradeoff:** Dramatically improves readability; some style guides prefer a single return point — know your team's convention.
**Further reading:** https://deviq.com/design-patterns/guard-clause

---

### Tell, Don't Ask
**Category:** Readability
**In one line:** Tell an object to do something rather than asking for its data and making the decision outside.
**Use when:** You're pulling data out of an object, processing it externally, and putting it back — that logic probably belongs on the object.
**Tradeoff:** Better encapsulation and clearer responsibility; can feel unintuitive when you're used to procedural thinking.
**Further reading:** https://martinfowler.com/bliki/TellDontAsk.html

---

## Distributed Systems

### Saga Pattern
**Category:** Distributed Systems
**In one line:** Coordinate a multi-step transaction across services by defining a sequence of local transactions, each publishing an event for the next step; if one fails, compensating transactions undo the previous steps.
**Use when:** You need transactional behaviour across multiple services but can't use a distributed transaction.
**Tradeoff:** Achieves eventual consistency without distributed locks; significantly more complex to design and debug — especially the compensating transactions.
**Further reading:** https://microservices.io/patterns/data/saga.html

---

## Data Integrity

### Optimistic Locking
**Category:** Data Integrity
**In one line:** Include a version field on records; on update, check the version matches what you read — if not, someone else updated it first, retry.
**Use when:** Concurrent updates to the same record are possible but infrequent, and you'd rather retry than hold a lock.
**Tradeoff:** No blocking, high throughput; under high contention, retries add latency.
**Further reading:** https://martinfowler.com/eaaCatalog/optimisticOfflineLock.html

---

### Soft Deletes
**Category:** Data Integrity
**In one line:** Mark records as deleted with a flag and timestamp rather than removing them from the database.
**Use when:** You need an audit trail, the ability to recover deleted data, or referential integrity with soft-deleted records.
**Tradeoff:** Preserves history and allows recovery; queries must always filter out deleted records — easy to forget, easy to get wrong.
**Further reading:** Search "soft delete [your ORM]" — most ORMs have first-class support.
