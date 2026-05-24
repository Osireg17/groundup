Here is the pseudocode for `src/middleware/webhookSignature.ts`:

```ts
// Purpose: verify that an incoming webhook request genuinely originated from Stripe
//          by recomputing the expected signature and comparing it to the one Stripe sent
// In:    req (Express Request — must carry the raw body buffer, not a parsed object)
//        res (Express Response)
//        next (Express NextFunction)
//        secret (string, non-empty — the webhook signing secret from the Stripe dashboard)
// Out:   void — either calls next() to continue the chain, or ends the response
// Edges: raw body absent → signal bad request | Stripe-Signature header absent → signal bad request
//        signature mismatch → signal unauthorised | valid signature → pass control to next handler

export function validateStripeSignature(secret: string) {
    return (req: Request, res: Response, next: NextFunction): void => {
        // given: req with raw body attached, secret (non-empty string)
        // expect: next() called when signature is valid; 400/401 sent and chain stopped otherwise
        //
        // 1. READ the raw body that was attached to the request before JSON parsing
        //    IF no raw body is present, signal that the request is malformed
        //
        // 2. READ the value of the Stripe-Signature header from the request
        //    IF the header is absent or empty, signal that the request is malformed
        //
        // 3. EXTRACT the timestamp and the signature value(s) from the Stripe-Signature header
        //    (the header is a comma-separated list of key=value pairs; t= is the timestamp, v1= is the signature)
        //    IF the timestamp or the v1 signature field cannot be found, signal that the request is malformed
        //
        // 4. COMPUTE the signed payload string by joining the timestamp, a literal dot, and the raw body
        //
        // 5. COMPUTE the HMAC-SHA256 digest of the signed payload using the secret as the key
        //    STORE the result as a hex-encoded string
        //
        // 6. DETERMINE whether the computed digest matches any of the v1 signatures extracted in step 3
        //    use a constant-time comparison to prevent timing attacks
        //    IF no match is found, signal that the request is unauthorised
        //
        // 7. CALL next() to pass control to the next middleware or route handler
    };
}
```

A few things to be aware of before you implement:

**Raw body requirement.** Express parses the body before middleware runs. By the time this function executes, `req.body` is already a parsed object — the original bytes are gone. You need to configure the Express body-parser to preserve the raw buffer and attach it to `req` before this middleware runs. How you attach it and what property name you use is a decision you need to make — it will affect what step 1 reads from.

**Constant-time comparison (step 6).** A naive `===` string comparison leaks timing information — an attacker can measure response time to guess the signature byte by byte. Node's `crypto` module has a function designed for this exact problem. Look it up before you implement step 6.

**Stripe-Signature header format.** The header looks like this: `t=1492774577,v1=5257a869e7ecebeda32affa62cdca3fa51cad7e77a05bd346197e1531bcd5db,v1=...`. There can be more than one `v1=` entry — Stripe sends multiple when rolling secrets. Step 3 and step 6 must handle that.

Implement this. Come back when you've written tests.
