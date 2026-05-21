# .grounduprc.md — Project-Level Configuration

groundup loads `.grounduprc.md` from the root of the project directory at the start of every session. If present, its contents are appended to the bootstrap context, letting teams extend or override the defaults.

This file is for things that are **specific to your codebase and team** — not generic engineering wisdom. Generic rules belong in groundup itself.

---

## What Belongs Here

**Team-specific patterns and conventions:**

```markdown
## Preferred Patterns
- All async operations use the outbox pattern via `src/lib/outbox.ts` — never publish events directly from service methods
- Pagination: cursor-based via `src/lib/pagination.ts:CursorPage` — never offset-based
- Error handling: throw domain-specific errors from `src/errors/` — never throw `new Error("message")`
```

**Domain-specific junior traps:**

```markdown
## Junior Traps in This Codebase
- Our `UserService.find()` returns null, not throws — not following this has caused production bugs
- Never call `db.query()` directly — always go through the repository layer
- The `processPayment()` method is not idempotent — calling it twice charges the user twice
```

**Adjusting iron laws:**

```markdown
## Iron Law Adjustments
- Skip the flow map for changes that touch only a single file with no external dependencies — document the skip reason inline
```

**Context the mentor needs:**

```markdown
## Codebase Context
- This is a payments service. Every change that touches `src/payments/` requires a security probe during grill — no exceptions
- We run on Node 18 — no top-level await outside of test files
- Integration tests in `test/integration/` hit a real Postgres instance — do not mock the DB
```

---

## What Doesn't Belong Here

- Generic engineering principles (already in the framework)
- Information derivable from reading the code
- Anything that should be in `README.md` or the repo's own docs

---

## Template

Copy `docs/grounduprc-template.md` from the groundup repo to `.grounduprc.md` in your project root and fill it in.

The file is read-only from Claude's perspective — Claude will not modify it. Keep it in version control so all team members share the same mentor configuration.
