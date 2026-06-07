# Breakdown Response — JWT Auth Middleware

---

## Response to Engineer

Here's how I've broken this into 3 tickets. We start with **Ticket 1 (Augment Request type)** because it has no runtime dependencies — it's a type declaration that both the middleware and the route wiring depend on. Middleware second, because the route wiring can't safely apply auth without it. Route wiring last, because it depends on both. Does this feel right — anything you'd split, combine, or reorder?

---

## tickets.md content

```markdown
# Tickets — JWT Auth Middleware

Created: 2026-06-07

## What We're Building

We're adding JWT authentication to an Express API via a middleware function that extracts a Bearer token, verifies it against the app secret, and attaches the decoded user to `req.user`. Tickets are ordered dependency-first: the type augmentation has no dependencies (middleware and routes both need it), the middleware is self-contained once the type exists, and the route wiring is the entry point that depends on both.

---

## Ticket 1: Augment Express Request with user field

**Goal**: Extend the Express `Request` type so `req.user` is recognised by TypeScript throughout the app — middleware and route handlers both depend on this declaration existing first.
**Files**:
- `src/types/express.d.ts` — create
**Depends on**: none
**Acceptance criteria**:
- [ ] `req.user` is accessible on the Express `Request` type without a TypeScript error
- [ ] The `user` field is typed to match the shape of the JWT payload (at minimum: `id` and any other fields the token carries)
- [ ] The augmentation does not widen or break any existing properties on `Request`
- [ ] Covered by a TypeScript compilation check (tsc --noEmit) — no type errors introduced

---

## Ticket 2: Implement authenticate middleware

**Goal**: Implement the middleware that validates the Bearer token and attaches the decoded user to `req.user`, or rejects the request with the correct 401 response for every failure mode agreed in the grill.
**Files**:
- `src/middleware/auth.ts` — create
**Depends on**: Ticket 1
**Acceptance criteria**:
- [ ] Missing `Authorization` header → 401 with body `{ error: 'No token' }`, `next()` not called
- [ ] Malformed token (not a valid JWT, wrong format) → 401 with body `{ error: 'Invalid token' }`, `next()` not called
- [ ] Expired token → 401 with body `{ error: 'Token expired' }`, `next()` not called
- [ ] Valid token → `req.user` set to decoded payload, `next()` called, no response sent
- [ ] All four branches covered by unit tests with a real or mocked JWT verify call

---

## Ticket 3: Apply authenticate middleware to protected routes

**Goal**: Wire the authenticate middleware onto every protected route in the router so unauthenticated requests are rejected before reaching any handler.
**Files**:
- `src/routes/index.ts` — modify
**Depends on**: Ticket 1, Ticket 2
**Acceptance criteria**:
- [ ] All routes that require authentication have the `authenticate` middleware applied
- [ ] Public routes (if any) are unaffected and still reachable without a token
- [ ] An integration test confirms a protected route returns 401 without a valid token and 200 (or appropriate status) with one
- [ ] No duplicate middleware application (e.g. applied at both router level and individual route)
```

---

## Session State (for .groundup/session-state.json)

```json
{
  "phase": "per_ticket_loop",
  "current_ticket": 1,
  "tickets_file": ".groundup/tickets.md"
}
```
