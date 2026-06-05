---
name: groundup:architecture
description: "Maps an unfamiliar or brownfield codebase for a junior engineer — reads the system, produces a Mermaid diagram, then interrogates the engineer one question at a time on why it is shaped that way. Use this skill whenever an engineer says they don't know how a codebase works, they're new to a repo, they're a new hire onboarding, or they can't name the files their change will touch. Also invoke when the engineer says things like 'where do I even start?', 'I don't know this codebase', 'can you explain how this is structured?', or 'I've never worked in this repo before'. Always run this before orient when the engineer is unfamiliar with the system."
---

# Architecture — Read the System Design

Before touching any code, understand the system you are working in. A change made without understanding the architecture either fights the design or breaks a boundary the original authors put there deliberately.

This skill has two parts: **read** (you map the system), then **interrogate** (the engineer explains the reasoning behind the design).

---

## Part 1 — Read the Codebase

Explore the codebase yourself first. Do not ask the engineer to explain it to you — go find the answers.

Look for:

**Entry points**
- Where does the system start? (main, index, app bootstrap, CLI entrypoint)
- Where do external requests arrive? (HTTP controllers, queue consumers, event handlers, scheduled jobs)

**Layers and boundaries**
- What are the named layers? (controllers, services, repositories, domain, infrastructure, adapters)
- What is the dependency direction? Does the domain depend on infrastructure, or the other way around?
- Are there clear seams — interfaces, ports, abstractions — between layers?

**Services and ownership**
- If distributed: what are the services? What does each own?
- What calls what? Map the call direction, not just the existence of calls.
- What data does each service own? What does it read from others?

**Key abstractions**
- What are the central domain concepts? (User, Order, Payment, Event — whatever the domain is)
- Where are they defined? Where are they used?

---

## Part 2 — Produce the Diagram

Once you have read the codebase, produce an ASCII art system diagram.

The diagram must show:
- The layers or services as labelled boxes
- The dependency or call direction as arrows
- Labels on arrows where the relationship is not obvious ("calls", "owns", "reads from", "publishes to")

Use plain characters only: `+`, `-`, `|`, `v`, `^`, `>`, `<`, `-->`. No Mermaid — it requires a plugin to render and is unreadable in most terminals and editors.

**Example — layered monolith:**

```
+---------------------+
|   HTTP Controllers  |
+---------------------+
          |
          v
+---------------------+
|    Service Layer    |
+---------------------+
       |       |
       v       v
+----------+ +-------------+
|  Domain  | | Repositories|
+----------+ +-------------+
                   |
                   v
            +----------+
            | Database |
            +----------+
```

**Example — distributed system:**

```
+-------------+         +---------------+
| API Gateway | ------> | Auth Service  |
+-------------+         +---------------+
      |
      v
+-------------+         +---------------+
| Order Svc   | ------> | Payment Svc   |
+-------------+         +---------------+
      |                        |
      v                        v
+-------------+         +---------------+
|  Orders DB  |         |  Payments DB  |
+-------------+         +---------------+
      |
      v (publishes)
+-------------+         +---------------+
| Event Queue | ------> |  Notify Svc   |
+-------------+         +---------------+
```

Label anything that would surprise a new hire. Leave out anything obvious.

After producing the diagram, present it and say: "Walk me through this — explain what you see." Then stop. Let them talk.

---

## Part 3 — Interrogate the Engineer

The diagram is a prop. The real work is finding out whether the engineer understands the *reasoning* behind the design, not just the shape of it. Junior engineers often know *what* a system does without knowing *why* it is structured that way. That gap leads to changes that are locally correct but architecturally wrong.

**How to run the interrogation:**

Ask one question. Wait for the answer. Then decide what to probe next based on what they said — not based on a script.

The question categories below are a menu to draw from, not a sequence to follow. Pick the question that will reveal the biggest gap in their current answer.

**On boundaries** — use when you want to know if they understand what a layer *protects*:
- "Why does [layer A] not depend on [layer B]? What would break if it did?"
- "Where does [concept X] live? Why there and not in [other layer]?"
- "What is the contract between [A] and [B]? What breaks if A changes its output shape?"

**On dependency direction** — use when they can describe the arrows but not what they *mean*:
- "The arrow goes from [A] to [B]. Which side can change without breaking the other?"
- "If you needed to swap the database for a different one, which files change? Why only those?"

**On ownership** — use when multiple services touch shared data:
- "Which service owns [entity]? What does 'owns' mean here — who is the source of truth?"
- "If two services both read [data], who is responsible when it's wrong?"

**On design decisions** — use when the shape of the system seems arbitrary to them:
- "Why is [X] synchronous and [Y] asynchronous? What drove that?"
- "What would you have to change if this needed to scale to 10x traffic?"

**Pacing rule:** One question per turn. If their answer is vague, probe the same thing from a different angle rather than moving on. Move on only when you are satisfied — not when they have said *something*.

---

## Exit Condition

This skill is complete when the engineer can answer all three of these unprompted:

1. What is the dependency direction, and why does it run that way?
2. What are the key boundaries, and what does each one protect?
3. Where does their change fit in the diagram — which layer, which service, which boundary it crosses (if any)?

Do not move to `groundup:orient` until all three are answered clearly. If they can answer them, say so explicitly and hand off.

---

## After Architecture

Invoke `groundup:orient`. The engineer now has the map — orient traces the specific path their change will take through it.
