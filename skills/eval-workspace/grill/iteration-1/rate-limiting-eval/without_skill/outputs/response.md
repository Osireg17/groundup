Good thinking — Redis is a solid fit here. Before we go any further though, I want to probe the plan a bit, because there's a subtle but critical race condition hiding in your approach.

You said: increment the counter, then check it, then expire after 60 seconds. Here's the question: what happens if two requests arrive at exactly the same time, both read a counter of 0, both increment to 1, both check — and both pass?

That's a race condition. The increment and the expiry set need to be atomic. If you do them as two separate Redis commands, you can end up in a state where the key exists but has no TTL (if the process crashes between the two calls), meaning that user gets permanently rate-limited.

Redis has a way to handle this — do you know what it is?

---

Also, a few things I'd want you to think through before we agree on the design:

**1. What is the limit?**
You said "return 429 if over the limit" — but you haven't defined the limit. Is it per endpoint? Per user globally? Is it the same for all users, or do some users (e.g. paid tier, internal services) get a higher limit?

**2. Where does this middleware live?**
Is this applied globally to all routes, or selectively? If selectively — how does the calling code opt in? What's the existing middleware pattern in this codebase?

**3. What does the 429 response look like?**
The HTTP spec and RFC 6585 say you should include a `Retry-After` header. Are you planning to include that? If so, what value do you return — the TTL of the Redis key?

**4. What happens when Redis is down?**
This is the one engineers almost always miss. If your Redis connection fails, do you: (a) let all requests through (fail open), or (b) block all requests (fail closed)? Both are valid — but they have very different security and availability tradeoffs. Which behaviour is right for your use case?

---

Start with the race condition question — what Redis primitive would make the increment and expiry atomic?
