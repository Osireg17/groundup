# Eval: auth-flow-failure-modes — Old Skill (Snapshot)

**Skill version:** iteration-1 snapshot  
**Task:** Probe failure modes in a junior engineer's login flow  
**Date:** 2026-05-25

---

## Simulated Dialogue

---

### Turn 1

**Engineer:**

> "Here's my flow for a user authentication endpoint:
> 1. Request arrives at /login with email and password
> 2. Look up user by email in the database
> 3. Check password matches
> 4. Return JWT token
>
> Looks good to me, what do you think?"

---

**Claude (flow-map skill):**

Good start — you've got the happy path down. Before we agree on this as the contract, let's stress-test it together.

Step 2: you look up the user by email. What happens if no user with that email exists in the database?

---

### Turn 2

**Engineer:**

> "Oh right — I'd return a 404 or maybe a 401 saying user not found."

---

**Claude (flow-map skill):**

There's an important security consideration here. If you return a distinct error for "user not found" versus "wrong password", what does that tell an attacker who's probing your system?

Think about it from the attacker's perspective: they can now enumerate which email addresses are registered just by reading the error codes. The standard practice is to return the same generic message — "invalid credentials" — regardless of whether the email doesn't exist or the password is wrong.

That brings me to step 3. What happens if the password check fails? And what's the mechanism you're planning to use — are you comparing the raw passwords, or is there something else going on?

---

### Turn 3

**Engineer:**

> "Good point on the error message, I'll use the same message. For the password, I'd hash the input and compare it to the stored hash. If they don't match, return the 401. I think that covers it?"

---

**Claude (flow-map skill):**

Hashing is right. Two more things to stress before we lock this in.

First, the database call at step 2 — what happens if the database is unavailable when the request comes in? Your flow currently goes straight from "look up user" to "check password" with no branch for a DB failure. Does the caller get a 500? Is that logged? Is there a timeout?

Second, think about step 4: you return a JWT token on success. Who issues the token — does your login handler call out to a separate token service, or does it generate the JWT itself? And once the token is issued, where does it go — do you store anything server-side, or is this fully stateless?

---

### Turn 4

**Engineer:**

> "The DB failing would be a 500, yeah, I'll make sure that's caught. For the token — I'd generate it in the handler itself using a library, sign it with a secret key, and return it. Nothing stored server-side, fully stateless. Is there anything else?"

---

**Claude (flow-map skill):**

Almost there. One more edge case before we agree on the diagram: what happens if the exact same login request is fired twice simultaneously — two requests for the same email at the same instant? Your flow is stateless and read-only up until the token is generated, so there's no race condition risk here. That's a good property to be aware of.

The last gap I want to name: there's nothing in your flow about rate limiting or account lockout. What happens if an attacker fires this endpoint 10,000 times with different passwords? That's outside the scope of this handler in most architectures — usually handled at a gateway or middleware layer — but it should be acknowledged in the design so whoever owns that layer knows it's their responsibility.

Agreed on the flow with those additions? Here's what we'd lock in:

```
Flow:
[Client] --POST /login {email, password}--> [AuthHandler]
    |
    |--> [DB] look up user by email
    |       |-- user not found --> return 401 "invalid credentials"
    |       |-- DB unavailable --> return 500, log error
    |       |-- found --> continue
    |
    |--> hash input password, compare to stored hash
    |       |-- mismatch --> return 401 "invalid credentials"
    |       |-- match --> continue
    |
    |--> generate signed JWT (stateless, secret key)
    |
    |--> return 200 {token}

Cross-cutting: rate limiting / lockout handled at gateway layer (not in handler)
```

Implementation order:
1. `src/auth/passwordUtils.ts`   — reason: no dependencies, hashing logic used by handler
2. `src/auth/tokenUtils.ts`      — reason: no dependencies, JWT generation used by handler
3. `src/auth/loginHandler.ts`    — reason: depends on passwordUtils and tokenUtils, entry point for the endpoint

Does this match your understanding? If yes, we're signed off and I'll move to pseudocode for `passwordUtils.ts`.
