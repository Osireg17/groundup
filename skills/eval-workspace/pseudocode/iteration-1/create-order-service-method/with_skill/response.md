Here is the pseudocode written directly into `src/services/OrderService.ts`:

```ts
// Purpose: validate ownership and create a new order from a user's cart, then clear the cart | Ref: src/services/UserService.ts
// In:    userId (string, non-empty UUID), cartId (string, non-empty UUID)
// Out:   Order — the newly created order record with its assigned id and line items
// Edges: user does not exist → signal not found | cart does not belong to userId → signal forbidden | cart is empty → signal bad input | order creation fails → signal internal error

async function createOrder(userId: string, cartId: string): Promise<Order> {
    // given: userId (string, non-empty UUID), cartId (string, non-empty UUID)
    // expect: a persisted Order record containing the items from the cart; the cart is empty after this returns
    //
    // 1. GET the user record for this userId
    //    IF no user record exists, signal that the resource was not found
    //
    // 2. GET the cart record for this cartId
    //    IF the cart's owner is not this userId, signal that the operation is forbidden
    //
    // 3. DETERMINE whether the cart contains at least one item
    //    IF the cart is empty, signal that the input is invalid
    //
    // 4. STORE a new order record containing the userId and the line items from the cart
    //    IF the record cannot be persisted, signal an internal error
    //
    // 5. CLEAR all items from the cart so it is empty
    //
    // 6. RETURN the newly created order record
}
```

Implement this. Come back when you've written tests.
