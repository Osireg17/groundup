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

**Internal documentation links:**

```markdown
## Internal Documentation
- Auth model: https://wiki.internal/auth-architecture
- Error catalogue: src/errors/README.md
- API contracts: docs/api/
```

The mentor cites these when they're relevant — instead of guessing how your auth model works, it reads the link you've provided and advises accordingly. Use file paths for things in the repo, URLs for things on your internal wiki or Confluence.

**Domain idioms — what words mean in your codebase:**

```markdown
## Domain Idioms
- "Handler" means: a class that processes a single command type, lives in src/handlers/
- "Service" vs "Repository": Services contain business logic; Repositories do DB access only
- "Event" means: a domain event on the internal bus, not an HTTP webhook
```

Without this, the mentor may use these terms differently than your team does — which creates confusion during grill and pseudocode. Fill in any term that has a company-specific meaning that differs from the generic engineering definition.

**Required probes for high-risk areas:**

```markdown
## Required Grill Probes by Area
- src/payments/: always probe for idempotency, replay attacks, double-charge scenarios
- src/auth/: always probe for token expiry edge cases, concurrent session handling
- src/migrations/: always probe for rollback plan and zero-downtime strategy
```

When a session involves a file whose path starts with one of these prefixes, the mentor runs the listed probes during grill — automatically, without the engineer needing to know they apply. Use this for areas where junior engineers have historically underestimated complexity or caused incidents.

**Style guide — company-specific conventions:**

```markdown
## Style Guide
- Error handling: always extend `src/errors/AppError.ts`, never throw `new Error()` directly
- Logging: always use `src/lib/logger.ts`, never console.log
- File naming: kebab-case for all new files
```

The mentor enforces these during per-file code review. Do not list generic best practices (those are already in the framework) — list only what's specific to your team and not obvious from reading the code.

**Onboarding context — week-1 knowledge:**

```markdown
## Onboarding Context
- We do not use ORMs — raw SQL via src/lib/db.ts
- Integration tests use a real Postgres instance — never mock the DB layer
- src/payments/ is PCI-scoped — all changes require a security probe and a second reviewer
```

This is what a new engineer needs to know that isn't obvious from reading the code. The mentor uses it to give contextually accurate advice from session one — instead of recommending an ORM query, it knows to use the raw SQL layer.

---

## What Doesn't Belong Here

- Generic engineering principles (already in the framework)
- Information derivable from reading the code
- Anything that should be in `README.md` or the repo's own docs

---

## Template

Copy `docs/grounduprc-template.md` from the groundup repo to `.grounduprc.md` in your project root and fill it in.

The file is read-only from Claude's perspective — Claude will not modify it. Keep it in version control so all team members share the same mentor configuration.
