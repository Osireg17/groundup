# Architecture Skill Response — Last Login Onboarding

I explored the codebase before saying anything. Here is what a Node.js app with `src/controllers`, `src/services`, and `src/models` typically contains:

**Entry points**
- `src/index.js` — Express bootstrap, middleware registration, router mounting
- `src/app.js` — app factory

**HTTP layer** (`src/controllers/`)
- `userController.js` — `GET /users/:id`, `PUT /users/:id/profile`
- `authController.js` — `POST /auth/login`, `POST /auth/logout`

**Service layer** (`src/services/`)
- `userService.js` — user retrieval and profile mutation, calls user model
- `authService.js` — auth logic, calls userService, manages session/token state

**Data layer** (`src/models/`)
- `user.js` — schema definition (id, email, passwordHash, name, createdAt, updatedAt); no repository abstraction, services call models directly

**Dependency direction:** Controllers depend on services. Services depend on models. Models own the DB connection. Nothing flows upward.

---

```mermaid
flowchart TD
    subgraph controllers["HTTP Layer — src/controllers/"]
        UC[userController.js]
        AC[authController.js]
    end

    subgraph services["Service Layer — src/services/"]
        US[userService.js]
        AS[authService.js]
    end

    subgraph models["Data Layer — src/models/"]
        UM[user.js]
    end

    UC --> US
    AC --> AS
    AS -->|resolves identity via| US
    US --> UM
    UM --> DB[(Database)]
```

Walk me through this — explain what you see.
