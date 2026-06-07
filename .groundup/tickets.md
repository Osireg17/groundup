# Tickets — JWT Authentication Middleware

Created: 2026-06-07

## What We're Building

A JWT authentication middleware for an Express API. The middleware extracts a Bearer token from the Authorization header, verifies it using the app secret, and attaches the decoded user payload to `req.user`. Protected routes apply the middleware; unprotected routes do not. Tickets are ordered so that foundational types are in place before middleware is written, and middleware is complete before routes are wired.

---

## Ticket 1: Augment Express Request type to include user field

**Goal**: Extend Express's `Request` type so that `req.user` is available throughout the codebase without TypeScript errors.
**Files**:
- `src/types/express.d.ts` — create
**Depends on**: none
**Acceptance criteria**:
- [ ] `req.user` is accessible on Express `Request` objects without a TypeScript compiler error
- [ ] The `user` field is typed appropriately (e.g. a `User` or decoded JWT payload shape) and is optional (`user?`) since unauthenticated requests won't have it

---

## Ticket 2: Implement JWT auth middleware

**Goal**: Create the middleware function that verifies the Bearer token and attaches the decoded user to the request, or returns a 401 with a specific error message for each failure mode.
**Files**:
- `src/middleware/auth.ts` — create
**Depends on**: Ticket 1
**Acceptance criteria**:
- [ ] Missing Authorization header → responds 401 with `{ message: 'No token' }`
- [ ] Malformed token (present but not a valid JWT) → responds 401 with `{ message: 'Invalid token' }`
- [ ] Expired token → responds 401 with `{ message: 'Token expired' }`
- [ ] Valid token → `req.user` is set to the decoded payload and `next()` is called
- [ ] All four cases are covered by tests

---

## Ticket 3: Apply auth middleware to protected routes

**Goal**: Wire the middleware into the router so that protected routes require a valid JWT and unprotected routes are unaffected.
**Files**:
- `src/routes/index.ts` — modify
**Depends on**: Ticket 1, Ticket 2
**Acceptance criteria**:
- [ ] All routes that require authentication have the auth middleware applied
- [ ] Public routes (e.g. login, registration) do not have the middleware applied
- [ ] An integration test confirms a request to a protected route without a token receives a 401
- [ ] An integration test confirms a request to a protected route with a valid token is allowed through
