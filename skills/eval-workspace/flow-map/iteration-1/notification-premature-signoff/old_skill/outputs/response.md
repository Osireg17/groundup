# Flow Map Eval — Notification Premature Sign-off
## Skill: OLD (Snapshot)
## Scenario: Engineer tries to move to pseudocode before flow is interrogated

---

## Turn 1

**Engineer:**
> "I've drawn the flow for a notification system. When a user completes an order:
> 1. Order service saves the order
> 2. Order service sends an email notification
> 3. User gets the email
>
> I think that covers it. Can we move on to pseudocode?"

---

**Claude (flow-map skill):**

Good start — you've got the happy path down. Before we sign off and move to pseudocode, I want to make sure the flow is airtight, because anything we miss here becomes a bug later.

One question before we go further:

In step 2, the Order service sends the email directly — is that call synchronous? Meaning: does the order save wait for the email to be sent before it confirms success to the user?

---

## Turn 2

**Engineer:**
> "Yeah it's synchronous I think. The order gets saved, then we send the email, then we return success to the user. It's all in one go. Can we just get to pseudocode now? I understand the flow."

---

**Claude (flow-map skill):**

I hear you — let's be quick about it. But this one question is load-bearing.

If the email send fails (SMTP is down, the email provider rate-limits you), what happens to the order? Does it roll back? Does the user get an error saying "your order failed" even though the order was saved successfully?

Right now your flow has the order save and the email send coupled inside the same success path. That means a failure in the notification layer can appear to the user as an order failure — even if their order is safely in the database.

What do you think the right behaviour should be when the email fails?

---

## Turn 3

**Engineer:**
> "Oh... I hadn't thought about that. I guess the order should still go through even if the email fails? So maybe the email sending should be decoupled somehow?"

---

**Claude (flow-map skill):**

Exactly the right instinct. Now you're seeing the transaction boundary.

The order write and the notification are two separate concerns with different failure modes. There are two main ways to decouple them:

**Option A — Synchronous with error swallowing:**
Save the order, attempt the email, catch any email errors silently, return success regardless. Simple, but you get silent notification failures with no retry mechanism.

**Option B — Event-driven (async):**
Save the order, emit an `OrderCompleted` event to a queue, return success. A separate notification consumer picks up the event and sends the email independently, with its own retry logic. More moving parts, but the order flow is never blocked or failed by a notification outage.

The tradeoffs: Option A is simpler to build but gives you no guarantee the email was sent. Option B gives you resilience and retryability but introduces a queue, a consumer, and eventual delivery (the email may arrive seconds later, not instantly).

Given the system you're building — does it matter if the email is slightly delayed? And how important is it to you that every email is eventually sent even after a transient failure?

---

## Turn 4

**Engineer:**
> "The email doesn't need to be instant — a few seconds is fine. And yes, we definitely want every email delivered eventually. So Option B sounds right. Let's go with the event-driven approach."

---

**Claude (flow-map skill):**

Good decision, and good reasoning. You chose it for the right reasons.

Before I produce the contract diagram, one more check: in the event-driven model, what happens if the order saves successfully but the event fails to publish? You'd have a completed order with no notification ever queued. How do we handle that?

(This is the "dual write" problem — you're writing to two systems atomically, which is harder than it looks. The established pattern here is the **Outbox Pattern**. Worth knowing about before we lock the diagram.)

Once you've thought through that edge case, we can finalise the flow and I'll produce the Mermaid diagram and implementation order.

---

### Notes on skill behaviour observed:

- **Turn 1:** Skill did not hard-block on premature sign-off. It named what was missing ("make sure the flow is airtight") and asked a single focused question rather than lecturing.
- **Turn 2:** Engineer pushed back. Skill held the gate by making the risk concrete (email failure = apparent order failure) rather than citing a rule. One question only.
- **Turn 3:** Engineer's thinking shifted. Skill validated the direction, then presented options with pros/cons and no "(Recommended)" label — forced the engineer to reason through the tradeoff.
- **Turn 4:** Engineer made a reasoned decision. Skill accepted it, then surfaced the next unresolved edge case (dual write / Outbox Pattern) before signing off — consistent with the "Check for Patterns" step in the skill.

The skill did not produce a contract diagram because the flow was not yet fully agreed (dual-write edge case unresolved at end of simulation). This is correct behaviour.
