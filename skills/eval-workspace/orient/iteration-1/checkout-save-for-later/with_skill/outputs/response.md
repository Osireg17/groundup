# Orient Session — "Save for Later" in the Checkout Flow

## Step 1 — Pick One Journey

Before reading anything, I need to pin down the specific user action we're tracing.

"Save for later" can be triggered from multiple surfaces — the cart page, the checkout flow, maybe a wishlist. For this session I need one concrete entry point.

The journey we're tracing:

> "A user clicks 'Save for Later' on a line item during checkout — the item is removed from their active cart and added to a saved-items list."

Good. Let me trace it.

---

## Step 2 — Trace It End-to-End

Fabricated codebase structure (Node.js/TypeScript, Express, layered monolith):

```
src/
  routes/
    checkout.routes.ts
  controllers/
    CheckoutController.ts
  services/
    CheckoutService.ts
    CartService.ts
    SavedItemsService.ts       ← does not exist yet
  repositories/
    CartRepository.ts
    OrderRepository.ts
    SavedItemsRepository.ts    ← does not exist yet
  models/
    Cart.ts
    CartItem.ts
    Order.ts
    SavedItem.ts               ← does not exist yet
  middleware/
    auth.middleware.ts
    validate.middleware.ts
```

### Hop-by-Hop Trace

```
[1] HTTP POST /checkout/cart/:cartId/items/:itemId/save-for-later
    → src/routes/checkout.routes.ts:34
      Mounted at /checkout, behind auth.middleware.ts (line 12)
      and validate.middleware.ts (line 15)
      Extracts: req.params.cartId, req.params.itemId, req.user.id from JWT

[2] → src/controllers/CheckoutController.ts:88 — saveItemForLater()
      Receives: cartId (string), itemId (string), userId (string)
      Validates itemId belongs to cartId via shape check
      Delegates immediately to CheckoutService — owns no business logic
      Calls: CheckoutService.saveItemForLater(cartId, itemId, userId)

[3] → src/services/CheckoutService.ts:112 — saveItemForLater()
      Orchestrates the move as a single logical unit:
        a) CartService.removeItem(cartId, itemId) → CartItem
        b) SavedItemsService.addItem(userId, cartItem) → SavedItem
      *** TRANSACTION BOUNDARY CONCERN: both calls must succeed or data is lost ***

[4a] → src/services/CartService.ts:67 — removeItem()
       Calls CartRepository.removeItem(cartId, itemId) → CartItem
       Throws NotFoundError("CartItem not found") if item not in cart
       Returns full CartItem (needed by step 4b to construct SavedItem)

[4b]   → src/repositories/CartRepository.ts:45 — removeItem()
         Issues: DELETE FROM cart_items WHERE cart_id = ? AND item_id = ?
         Returns deleted CartItem row
         If no rows affected, throws NotFoundError

[5a] → src/services/SavedItemsService.ts — addItem()      ← DOES NOT EXIST
       Receives userId + CartItem
       Constructs SavedItem shape, persists via SavedItemsRepository

[5b]   → src/repositories/SavedItemsRepository.ts — create()   ← DOES NOT EXIST
         Issues: INSERT INTO saved_items (user_id, product_id, added_at, ...)
         Returns persisted SavedItem row

[6] → back to src/services/CheckoutService.ts:130
      Receives SavedItem from SavedItemsService
      Returns SavedItem to controller

[7] → back to src/controllers/CheckoutController.ts:101
      Serialises SavedItem → JSON
      Returns HTTP 201 { savedItem: { id, userId, productId, addedAt } }
```

---

### Critical Gap Flagged at Hop [3]

`CheckoutService` calls `CartService.removeItem` and `SavedItemsService.addItem` in sequence with no database transaction wrapping both. If `removeItem` succeeds and `addItem` fails, the cart item is deleted with no saved record — it silently vanishes. This assumption needs a name before any code is written.

---

## Step 3 — Mark Where the Change Lands

Files affected, in dependency order:

| Order | File | Status | Why |
|-------|------|--------|-----|
| 1 | `src/routes/checkout.routes.ts` | Modify | Register new route |
| 2 | `src/controllers/CheckoutController.ts` | Modify | Add `saveItemForLater()` handler |
| 3 | `src/services/CheckoutService.ts` | Modify | Add orchestration method — **change starts here** |
| 4 | `src/repositories/SavedItemsRepository.ts` | **New file** | DB persistence for saved items |
| 5 | `src/services/SavedItemsService.ts` | **New file** | Business rules for saved items |

The change starts at `CheckoutService.ts` — that's where the orchestration logic lives and where the business decision (move item atomically) must be implemented.

**Point to the hop where our change starts. Which file do we touch first — and why that one rather than the route?**

---

## Step 4 — Surface What You Don't Know

**Was there any hop in that journey where you weren't sure what was happening — where you followed the call but didn't fully understand the decision?**

The one I want to flag explicitly: the transaction gap at hop [3]. If `removeItem` succeeds and `addItem` fails, what state is the user's data in? That's not a rhetorical question — it's assumption number one on the grill list.

---

## Exit State

- One user journey traced hop-by-hop with file and line references
- Entry point: `POST /checkout/cart/:cartId/items/:itemId/save-for-later`
- Change start: `CheckoutService.ts:112 — saveItemForLater()`
- Boundary identified: service layer owns orchestration, repository layer owns persistence
- Unknown hop named: transaction atomicity between cart removal and saved-item creation
- Engineer response pending on which file they touch first

**Next: `groundup:grill`**
