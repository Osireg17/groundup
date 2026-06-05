// Purpose: Verify that an incoming webhook request genuinely originates from Stripe
//          by validating the HMAC-SHA256 signature in the Stripe-Signature header.
// In:    req    (Express Request — must carry a raw body buffer, not a parsed JSON body)
//        res    (Express Response)
//        next   (Express NextFunction)
//        secret (string, non-empty — the webhook signing secret from the Stripe dashboard)
// Out:   calls next() if the signature is valid; responds 400 and stops the chain if not
// Edges: missing Stripe-Signature header            → reject 400, "No signature header"
//        raw body absent or not a Buffer            → reject 400, "Raw body required"
//        secret is empty or not provided            → reject 500, "Webhook secret not configured"
//        computed signature does not match header   → reject 400, "Signature mismatch"
//        timestamp in header is too old (> 5 min)  → reject 400, "Timestamp expired"

export function validateStripeSignature(secret: string) {
    // given: secret (string, non-empty)
    // expect: an Express middleware function (req, res, next)
    //
    // RETURN a middleware function that closes over `secret` and, when invoked:
    //
    //   1. VERIFY secret is non-empty
    //      IF not, signal a server configuration error (500) — do not leak the detail to the client
    //
    //   2. GET the raw body from req (typically attached by an express.raw() middleware upstream)
    //      IF the raw body is absent or is not a Buffer, signal a client error (400)
    //         "Raw body required — ensure express.raw() precedes this middleware"
    //
    //   3. GET the value of the "stripe-signature" header from req
    //      IF the header is missing, signal a client error (400) "No signature header"
    //
    //   4. PARSE the Stripe-Signature header into its component parts
    //      The header has the form: t=<timestamp>,v1=<signature>[,v1=<additional>...]
    //      EXTRACT the timestamp value (t=...)
    //      COLLECT all v1 signature values (there may be more than one during key rotation)
    //      IF the timestamp or at least one v1 value cannot be found, signal 400 "Malformed signature header"
    //
    //   5. DETERMINE whether the timestamp is within the acceptable tolerance window (5 minutes)
    //      COMPUTE the age of the request: current Unix time in seconds minus the parsed timestamp
    //      IF the age exceeds 300 seconds (positive or negative), signal 400 "Timestamp expired"
    //         This protects against replay attacks
    //
    //   6. COMPUTE the expected signature
    //      CONSTRUCT the signed payload string as: "<timestamp>.<raw body as utf-8 string>"
    //      COMPUTE an HMAC using SHA-256, keyed with `secret`, over that signed payload
    //      ENCODE the result as a lowercase hex string
    //
    //   7. DETERMINE whether any of the v1 signatures from step 4 match the expected signature
    //      USE a timing-safe byte comparison for every comparison — never use === on signature strings
    //         (timing-safe comparison prevents timing-oracle attacks that could reveal the secret)
    //      IF none of the collected v1 signatures match, signal 400 "Signature mismatch"
    //
    //   8. CALL next() — the request is authentic
}
