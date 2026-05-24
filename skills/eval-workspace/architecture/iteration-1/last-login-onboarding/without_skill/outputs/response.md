# Baseline Response — Last Login Onboarding (No Skill)

Great question — orient yourself before touching anything. Here's how I'd approach getting your bearings in this codebase before writing a single line.

**Step 1: Read the existing structure**

For a "last login" field, you'll almost certainly need to touch all three layers (model, service, controller). But before assuming that, find an existing feature that reads and writes a user field, and trace how it flows through those layers. That gives you the pattern to follow.

**Step 2: Find the user model**

Start at the data layer. Look for `src/models/user.js` or `src/models/User.js`. You're looking for: what fields already exist, what ORM is being used (Sequelize, Knex, Mongoose, Prisma — each handles schema changes differently), and whether `createdAt`/`updatedAt` timestamps already exist as a pattern.

**Step 3: Find where authentication happens**

"Last login" means: when a user successfully authenticates, record the timestamp. Find the login flow in `src/controllers/` — look for `authController.js` or similar. Trace it to its service. That service method is where you'll write the timestamp update.

**Step 4: Find the user profile endpoint**

Find the existing endpoint that returns user data (look for `getProfile` or `getUser` in controllers). Once `lastLogin` is stored on the model, this endpoint may already return it — you just need to confirm it's not being filtered out.

**Concrete first move:**
```bash
ls src/models/ && ls src/controllers/ && ls src/services/
grep -r "login" src/ --include="*.js" -l
```

**Three questions to answer before writing code:**
1. What ORM/database layer is being used? — this determines how you add the field and whether you need a migration.
2. Does the login flow live in a controller or a service? — this affects where you put the `lastLogin = now()` update.
3. Is there an existing timestamp pattern in the user model? — if `createdAt` is already there, follow the same approach.

Once you've answered those three, we can reason through exactly where each change goes.
