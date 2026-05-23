Welcome back! I can see from your session state that we were working on adding rate limiting to the auth endpoints to prevent brute-force attacks.

Here's where we left off:

**Task:** Add rate limiting to the auth endpoints

**Current phase:** Per-file implementation loop

**Files:**
- `src/middleware/rateLimiter.ts` — pseudocode has been written, ready for implementation
- `src/routes/auth.ts` — pending (needs the middleware applied once rateLimiter is done)

So the next step is for you to implement `src/middleware/rateLimiter.ts` based on the pseudocode that's already in the file. Once you've done that and written tests, we can review it and then move on to wiring it into `src/routes/auth.ts`.

Go ahead and open `src/middleware/rateLimiter.ts` — the pseudocode should be there to guide you. Let me know when you're ready to start implementing or if you have questions about anything in the pseudocode.
