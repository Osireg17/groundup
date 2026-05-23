CI-only failures are one of the trickier categories of bugs because the environment difference is doing the hiding. Let me help you think through this systematically.

The most common culprits for auth tests failing only in CI are:

**Environment variables / secrets**
CI environments often have different env var names, missing values, or secrets injected differently than your local `.env` file. Check that all the env vars your auth tests depend on (JWT secrets, OAuth client IDs, database URLs) are actually set in your CI config.

**Timing and async issues**
CI machines are often slower or have different CPU scheduling. If your tests have hardcoded timeouts, token expiry windows, or race conditions that happen to pass locally due to timing, CI will expose them.

**Database / service state**
Are your auth tests hitting a real database or external service? CI might be starting the DB fresh each run, or services might not be fully ready when the tests start. Look for connection errors or "table does not exist" style failures in the full output.

**Token expiry / clock skew**
If you're generating JWTs with short expiry times in tests, and CI is slower, the token might expire between generation and verification.

**Shared state between tests**
If tests are running in a different order in CI (parallel execution, different seed), a test that modifies auth state (user sessions, tokens) might be leaving things dirty for the next test.

**To diagnose this:**
1. Get the full error output from CI — not just "failed" but the actual assertion error and stack trace
2. Check if it's the same test every time or different tests
3. Look at your CI logs for anything before the test failure — DB connection issues, missing env vars, service startup errors
4. Try reproducing locally with `NODE_ENV=test` or whatever your CI sets, and with any env vars your CI uses

What does the actual error message say? That'll narrow this down significantly.
