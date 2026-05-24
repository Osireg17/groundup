Before I write the pseudocode, let me address the sequencing here.

You asked for pseudocode AND a syntax explanation in the same request. Per our process, those are two separate gates — pseudocode first, then syntax help only if you get stuck on a specific step during implementation. If I front-load the async/await explanation now, you'll implement from the explanation rather than from your own reasoning about the pseudocode. That's not the goal.

So: pseudocode first. Come back with a specific step you're stuck on, and I'll show you one targeted example — no more.

---

Here is the pseudocode for `findByEmail`:

```ts
// Purpose: retrieve a single user record by their email address | Ref: src/repositories/UserRepository.ts
// In:    email (string, non-empty, must be a valid email format)
// Out:   User — the full user record matching that email
// Edges: empty or missing email → signal invalid input
//        no matching record → signal not found
//        database unreachable → let the error propagate to the caller

async findByEmail(email: string): Promise<User> {
    // given: email (string, non-empty, valid format)
    // expect: User record whose email field matches exactly
    //
    // 1. VALIDATE that email is non-empty and well-formed
    //    IF invalid, signal that the input is malformed
    //
    // 2. QUERY the data store for a user whose email matches the given value
    //    (exact match, case-insensitive)
    //
    // 3. IF no record is found, signal that the resource does not exist
    //
    // 4. RETURN the matched User record
}
```

Implement this. Come back when you've written tests.

---

One thing to think about before you implement: step 2 says "case-insensitive" — how does your data store handle that? Is it the database's job, the query's job, or this function's job? There's no right answer yet, but you should have an opinion before you write the query.
