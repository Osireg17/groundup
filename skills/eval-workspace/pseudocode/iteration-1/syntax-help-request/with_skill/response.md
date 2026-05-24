The pseudocode goes directly into the file. Since `src/repositories/UserRepository.ts` doesn't exist yet, I'm creating it with the pseudocode in place.

```ts
// src/repositories/UserRepository.ts

// Purpose: retrieve a single user record by their email address | Ref: (greenfield — no prior example)
// In:    email (string, non-empty, must be a valid email format)
// Out:   User — the full user record matching that email
// Edges: empty or malformed email → signal bad input | no matching record → signal not found

async function findByEmail(email: string): Promise<User> {
    // given: email (string, non-empty, valid email format)
    // expect: the User record whose email column matches the given address
    //
    // 1. DETERMINE whether the email value is present and well-formed
    //    IF not, signal that the input is invalid
    //
    // 2. GET the user record whose email matches the given address
    //
    // 3. IF no matching record exists, signal that the resource was not found
    //
    // 4. RETURN the user record
}
```

On async/await — you asked, so here is one targeted example. No real codebase exists yet, so here is a minimal analogue that mirrors exactly what you're about to write:

```ts
async function fetchSomething(id: string): Promise<Item> {
    const result = await db.query('SELECT * FROM items WHERE id = $1', [id]);
    return result.rows[0];
}
```

`async` marks the function as asynchronous — it always returns a `Promise`. `await` pauses execution inside that function until the promise resolves, then gives you the resolved value directly. Without `await`, you get the `Promise` object itself, not the data inside it.

Now apply it yourself.

Implement this. Come back when you've written tests.
