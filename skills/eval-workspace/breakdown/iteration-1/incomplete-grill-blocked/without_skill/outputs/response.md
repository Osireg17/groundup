# Response: Notification System Ticket Breakdown

Before we break this into tickets, I need to stop us here — we're not ready.

You've said you know it'll use a queue, but you haven't agreed on the flow or the files yet. Tickets written without that agreement will be wrong. They'll describe work that either overlaps, misses edge cases, or gets invalidated once the design solidifies. That's waste.

Tickets are a output of design, not a substitute for it.

Here's what we need to nail down first:

**The three things missing right now:**

1. **What triggers a notification?** — Is it an event from another service? A direct API call? A scheduled job? This determines the entry point and what the queue producer looks like.

2. **What does "notification" mean?** — Email, push, SMS, in-app? All of them? Each channel has different delivery guarantees and failure modes.

3. **What does the queue actually buy us?** — Decoupling? Rate limiting? Retry on failure? The answer changes what the consumer needs to handle.

Without these, any ticket I write for you is me guessing at the design. You'd be implementing my guess, not a reasoned solution.

**What I want you to do:**

Walk me through the flow in plain English — not code, not tickets. Start from: "something happens in the system, and a notification needs to go out." Tell me what that something is, what decides a notification is warranted, and what the notification actually does.

Once we've agreed on that end-to-end flow, the tickets will write themselves — because we'll know exactly what each piece is responsible for, what its inputs and outputs are, and what can go wrong.

So: what triggers a notification in this system?
