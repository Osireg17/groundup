# Scoping Flow

This file contains the full scoping flow. Run it inline — do not invoke another skill.

There is no codebase to explore. There are no files to orient to. The engineer's knowledge of the problem is the only input. The job is to surface that knowledge, make it explicit, and capture it in a structured artifact that future sessions can build on without re-asking the same questions.

The output is `.groundup/scope.md`. That file is the input to every future implementation session on this project.

---

## The Five Questions

Work through these one at a time. Wait for a full answer before moving to the next. Each answer informs how you probe the next question — don't treat them as a checklist to rush through.

---

### Question 1 — Problem and User

Ask:

> "Describe the problem you're solving and who has it. Who is the primary user, and what do they do today to work around not having this?"

What you're looking for: a problem anchored to a real person doing a real thing. "Improving efficiency" is not a problem. "Our ops team manually reconciles two spreadsheets every morning because the two systems don't sync" is.

Probe if vague:
- "What does [user] actually do, step by step, when they hit this problem?"
- "What's the cost of the current workaround — time, money, errors, friction?"
- "Is there a specific person you could talk to for 30 minutes to understand this better before you build anything?"

Don't proceed until the problem is anchored to a specific person doing a specific thing.

---

### Question 2 — Success Condition

Ask:

> "What does success look like — specifically? How will you know this was worth building?"

What you're looking for: a measurable outcome, not a feature list. "It saves time" is not measurable. "The ops team reconciliation goes from 45 minutes daily to zero manual steps" is.

Probe if vague:
- "If you shipped this and came back in three months, what metric would tell you it was worth it?"
- "What's the minimum version that would count as a success?"
- "What would make you conclude it was not worth building?"

The success condition defines scope. If you can't measure it, you can't define done.

---

### Question 3 — Constraints

Ask:

> "What are the binding constraints? Think: tech stack you must use, timeline, team size, services or platforms you must integrate with, compliance requirements, budget."

What you're looking for: the constraints that aren't negotiable, as distinct from defaults or preferences. A preference is "we like Postgres." A constraint is "we must use the existing Postgres instance because the data lives there."

Probe:
- "Which of those are genuinely fixed, and which are defaults you've assumed but could change?"
- "Is there a deadline, and what happens if you miss it?"
- "Are there security, privacy, or compliance requirements (PCI, GDPR, SOC2) that apply to the data this system touches?"

The most dangerous constraint is the one that's assumed but never stated.

---

### Question 4 — Requirements

Ask:

> "Walk me through what the system must do — the core capabilities. Then tell me what it must guarantee or avoid: performance, availability, data integrity, things it must never do."

What you're looking for: functional requirements (what it does) and non-functional requirements (how it must behave), including negative requirements (what it must never do). Keep this grounded — not a full product spec, but enough to know what the first version must cover.

Probe:
- "Is there anything the system must never do — data it must never expose, operations it must never allow?"
- "What's the expected load? How many users, how many operations per day?"
- "What happens if the system is unavailable — is this blocking for users, or background work?"

Don't let this become a feature wish-list. Keep it anchored to the problem from Question 1.

---

### Question 5 — Unknowns

Ask:

> "What decisions haven't been made yet, or what do you need to find out before you can start building? Name the things you genuinely don't know."

What you're looking for: explicit unknowns. An unnamed unknown is a future bug or rewrite. A named one is a trackable risk.

Probe:
- "Is there anything in the requirements where you said 'I think' or 'probably' — something you assumed rather than confirmed?"
- "Are there technical questions you'd need to spike on before committing to an approach?"
- "Is there a stakeholder decision you're waiting on?"

---

## Exit Condition

Scoping is complete when the engineer can state all five of the following in one sentence each:

- [ ] The problem: "We are building X to solve Y for [user persona]"
- [ ] Success: "We will know it works when [measurable outcome]"
- [ ] Top constraint: "The most binding constraint is [X] because [Y]"
- [ ] Minimum first version: "[these things] and not [these things]"
- [ ] Biggest unknown: "We have not yet decided / confirmed [X]"

If any of these can't be stated, that is the next question. Don't move to writing the artifact until all five are answerable.

---

## Writing `.groundup/scope.md`

Once the exit condition is met, create `.groundup/` if it doesn't exist, then write `.groundup/scope.md`:

```markdown
# Scope — [project name or brief descriptor]

Updated: [ISO 8601 date]

## Problem

[One paragraph: what the problem is, who has it, what they do today as a workaround. Prose, not bullets — forces the problem to be stated as a coherent narrative.]

## Primary User

[Description of the primary user: role, context, the specific friction they experience.]

## Success Condition

[Measurable outcome. What changes in the world when this is built and working. If it can't be measured, it's not done yet.]

## Constraints

### Fixed
- [Non-negotiable constraint]

### Assumed (may be negotiable)
- [Assumption that could be challenged if needed]

## Requirements

### Must do
- [Functional requirement]

### Must guarantee / never do
- [Non-functional requirement]
- [Negative requirement — what the system must never do]

## Unknowns

- [ ] [Open question or unresolved decision]
- [ ] [Technical spike needed]
- [ ] [Stakeholder decision pending]

## Minimum First Version

[What the smallest deployable version includes. Explicit about what is out of scope for v1 — exclusions make scope real.]
```

After writing the file, update `.groundup/session-state.json`: set `task` to the one-sentence problem statement, keep `phase` as `"scoping"`.

Then say:

> "Scope is captured in `.groundup/scope.md`. Review it — if anything is wrong, tell me and we'll correct it before you start building.
>
> When you're ready to tackle the first feature or ticket, describe what you want to build and invoke `groundup:grill`. The grill will use this scope as the baseline — you won't need to re-explain the problem."

Do not invoke grill automatically. The engineer must decide what to build first. That decision may happen now or in a future session — both are fine.
