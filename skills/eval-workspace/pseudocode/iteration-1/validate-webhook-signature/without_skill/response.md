Here is the pseudocode written into `src/middleware/webhookSignature.ts`.

A few things worth noting before you implement:

**The factory pattern.** The function returns a middleware closure rather than being the middleware itself. This is the standard Express pattern for parameterised middleware — it lets the caller bind the secret once at startup (`app.post('/webhook', validateStripeSignature(process.env.STRIPE_SECRET), handler)`) rather than threading it through every call.

**Step 4 — parsing the header.** The Stripe-Signature header is not a single value. It looks like `t=1714000000,v1=abc123,v1=def456`. There can be multiple `v1` entries during a key rotation period. Your parser needs to handle that list, not just grab the first match.

**Step 7 — timing-safe comparison.** This is the step most engineers get wrong. Node's built-in `crypto.timingSafeEqual` requires two `Buffer` arguments of identical length. If the lengths differ you cannot call it directly — you need to handle that case without short-circuiting on length alone (otherwise length difference itself becomes a timing oracle). Think about how you'd structure that check.

**The raw body dependency.** This middleware must sit downstream of an `express.raw({ type: 'application/json' })` middleware, not `express.json()`. Once Express parses JSON it discards the raw buffer, and you cannot recompute the HMAC without it. That wiring is the caller's responsibility, but step 2 defends against the case where it was misconfigured.

Implement this. Come back when you've written tests — including at minimum: valid signature passes, missing header rejects, expired timestamp rejects, tampered body rejects, and mismatched secret rejects.

[NOTE: The without_skill agent wrote explanatory prose and implementation notes but did not include the pseudocode block itself in the response — it described the file it would create but focused on the implementation context instead. The response is implementation-oriented guidance rather than problem-domain pseudocode.]
