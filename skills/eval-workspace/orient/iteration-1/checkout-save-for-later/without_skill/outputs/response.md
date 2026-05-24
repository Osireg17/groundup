Good question. Before we touch anything, let's orient you in the codebase so you know exactly where your change lands.

Here's how a typical Node.js/TypeScript layered monolith for e-commerce is structured, and I'll trace the checkout flow through it so you can see what calls what:

**Fabricated Codebase Structure**

```
src/
  controllers/
    checkoutController.ts       ← HTTP layer: receives requests, calls service
    cartController.ts
    orderController.ts
  services/
    checkoutService.ts          ← Business logic: orchestrates cart → order
    cartService.ts
    orderService.ts
    savedItemsService.ts        ← (does not exist yet — you'd add this)
  repositories/
    cartRepository.ts           ← DB access for cart records
    orderRepository.ts
    savedItemsRepository.ts     ← (does not exist yet — you'd add this)
  models/
    Cart.ts
    Order.ts
    SavedItem.ts                ← (does not exist yet)
  routes/
    checkoutRoutes.ts           ← Mounts checkout controller on Express router
    cartRoutes.ts
  middleware/
    authMiddleware.ts
  db/
    index.ts                    ← DB connection (e.g. Prisma or TypeORM)
```

**Call Trace: Current Checkout Flow**

When a user submits their checkout:

```
POST /api/checkout
  → checkoutRoutes.ts           mounts the route
  → authMiddleware.ts           validates session/JWT
  → checkoutController.ts       parseBody, call service
    → checkoutService.ts        validate cart, apply discounts, create order
      → cartRepository.ts       fetch cart items for userId
      → orderRepository.ts      persist new order record
      → cartRepository.ts       clear cart after order created
```

**Where "Save for Later" Fits**

"Save for later" means moving an item from the active cart to a saved list — without checking it out. It's a cart mutation, not a checkout action. That changes which files you're touching.

The call trace for the new feature:

```
POST /api/cart/items/:itemId/save
  → cartRoutes.ts               new route added here
  → authMiddleware.ts           reuse existing auth
  → cartController.ts           new handler: saveItemForLater
    → cartService.ts or savedItemsService.ts (decision point)
      → cartRepository.ts       remove item from cart
      → savedItemsRepository.ts persist item to saved_items table
```

**Files You Would Actually Touch**

| File | What changes |
|---|---|
| `src/routes/cartRoutes.ts` | Add the new `POST /items/:itemId/save` route |
| `src/controllers/cartController.ts` | Add `saveItemForLater` handler |
| `src/services/cartService.ts` or new `savedItemsService.ts` | Business logic for the move operation |
| `src/repositories/cartRepository.ts` | `removeItem(userId, itemId)` if it doesn't exist |
| `src/repositories/savedItemsRepository.ts` | New file — `saveItem(userId, item)`, `getSavedItems(userId)` |
| `src/models/SavedItem.ts` | New file — shape of a saved item record |
| DB migration | New `saved_items` table |

The `checkoutController.ts` you were thinking of is likely **not** touched — this feature lives one layer up, in the cart, before checkout is ever initiated.

**One Thing to Decide Before You Start**

The key question is whether `savedItemsService` lives as its own service or gets folded into `cartService`:

- **Separate service**: cleaner single-responsibility, easier to test in isolation, scales if saved items grows (wishlists, sharing, etc.)
- **Inside cartService**: less indirection, fewer files, makes sense if "saved for later" is conceptually just a cart state change

What's your instinct, and why?
