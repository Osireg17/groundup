# Auth Tests Failing Only in CI

That's a classic "works on my machine" problem — and auth tests failing only in CI usually points to a handful of common culprits.

Here are the most likely causes to investigate:

## 1. Environment Variables / Secrets

CI environments often have different (or missing) env vars. Check:
- Are your auth-related env vars (JWT secrets, OAuth credentials, API keys) actually set in your CI environment?
- Are the values correct and not expired?
- Is there a `.env` file being used locally that doesn't exist in CI?

## 2. Timing / Race Conditions

CI machines can be slower or have different concurrency characteristics:
- Are your tests making real async calls or relying on timers?
- Is there a token expiry check that passes locally but fails because CI is slower?
- Are tests running in parallel in CI but sequentially locally?

## 3. Database / State Isolation

- Is the test database being seeded correctly in CI before auth tests run?
- Are there leftover sessions or tokens from a previous test run that don't get cleaned up?
- Does your CI pipeline reset state between runs?

## 4. Clock Skew / Timezone

JWT and session tokens are time-sensitive:
- Is your CI server in a different timezone?
- Are you using `Date.now()` or `new Date()` in a way that behaves differently across environments?

## 5. Dependencies / Node Modules

- Are your lockfile versions being respected in CI? (`npm ci` vs `npm install`)
- Is there a native module (like `bcrypt`) that compiled differently on the CI machine's OS/architecture?

---

**To help narrow it down, can you share:**

1. The actual error message from the CI logs (not just "failing" — the stack trace matters)
2. What kind of auth you're using (JWT, sessions, OAuth, etc.)
3. What CI platform you're on (GitHub Actions, CircleCI, etc.)
4. Whether the tests were ever passing in CI, or if this is a new failure

The error message alone will usually cut the list above in half.
