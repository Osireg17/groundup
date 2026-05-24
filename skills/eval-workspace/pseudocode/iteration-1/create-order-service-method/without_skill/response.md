Here is the pseudocode written directly into `src/services/OrderService.ts`:

```typescript
// Purpose: Validate ownership and create a new order from a cart, then clear the cart | Ref: src/services/UserService.ts
// Deps: userRepository — verify user existence
//       cartRepository — verify cart ownership and retrieve items
//       orderRepository — persist new order record
//       cartRepository — clear cart after order is created
//
// In:    userId (string, non-empty UUID)
//        cartId (string, non-empty UUID)
// Out:   Order — the newly created order record with id, userId, items, and status
// Edges: userId does not exist → signal NotFound("user")
//        cartId does not exist → signal NotFound("cart")
//        cart does not belong to userId → signal Forbidden("cart does not belong to this user")
//        cart is empty → signal BadRequest("cannot create order from empty cart")
//        order persistence fails → signal InternalError and do NOT clear cart

async function createOrder(userId: string, cartId: string): Promise<Order> {
    // given: userId (non-empty UUID), cartId (non-empty UUID)
    // expect: Order — persisted record with id, userId, items snapshot, and status "pending"
    //
    // 1. GET the user record for userId
    //    IF no user exists, signal NotFound for "user"
    //
    // 2. GET the cart record for cartId
    //    IF no cart exists, signal NotFound for "cart"
    //
    // 3. VERIFY the cart's owner matches userId
    //    IF it does not, signal Forbidden — this user does not own this cart
    //
    // 4. VERIFY the cart contains at least one item
    //    IF the cart is empty, signal BadRequest — an order requires items
    //
    // 5. CREATE a new order record using the userId and a snapshot of the cart's items
    //    Set the order status to "pending"
    //    IF persistence fails, signal InternalError — do NOT proceed to cart clearing
    //
    // 6. CLEAR all items from the cart, marking it as empty
    //
    // 7. RETURN the newly created Order record
}
```

Implement this. Come back when you've written tests.

The edge cases in the `Edges:` header are the minimum test surface — make sure each one has a test before we do the per-file review.
