We haven't agreed on the files or how the flow works yet. The grill isn't complete, so creating tickets now would give us a breakdown built on assumptions — and assumptions in tickets become bugs in production.

Before we can break this into tickets, we need all four of these agreed:

- **Approach** — what the notification system does end-to-end (who triggers a notification, what types exist, what gets delivered where)
- **Files** — which files are being created or modified, and why each one
- **Flow** — how data moves from trigger to delivery (what queues, what consumers, what external calls)
- **Edge cases** — what happens when the queue is down, when a notification fails to send, when a recipient doesn't exist

Let's finish the grill first. Here's where I want you to think it through:

Walk me through the notification lifecycle in your own words — from the moment something triggers a notification to the moment it reaches the end user. What does each step look like, and what system is responsible for it?
