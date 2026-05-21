# Why groundup Exists

## The Paradox

Junior engineers today have access to something no previous generation had: an AI that can produce working code on demand. That sounds like a gift. In practice, it creates a trap.

The engineers who became brilliant in previous decades did so *because* things were hard. They spent hours debugging without Stack Overflow. They read documentation that was incomplete. They wrote code that broke in production and had to understand why. They worked through problems that took days because there was no shortcut.

That struggle built something: the ability to reason through a problem they'd never seen before. To debug a system they didn't write. To look at a failing test and know where to look. To smell a design that's going to cause problems six months from now.

AI removes the struggle. And the struggle was the point.

A junior engineer who uses AI to produce working code without understanding it has shipped features they can't maintain, debugged systems they can't reason about, and built a career on borrowed understanding that will eventually run out.

## The Opportunity

But the answer isn't to avoid AI. That's both impractical and wasteful. Senior engineers who use AI well are dramatically more productive. The question is: can you use AI as a lever without letting it become a crutch?

The difference is where the thinking happens. When AI does the thinking — generates the design, writes the code, figures out the bug — the engineer's skill doesn't grow. When the engineer does the thinking and AI helps execute, the engineer's skill compounds.

groundup is designed to make that distinction explicit and enforce it.

## What groundup Does

groundup makes Claude act as a demanding senior engineer — one who:

- **Refuses to give the answer** before asking whether the engineer has thought it through
- **Requires you to draw the flow** before any code is written, because most junior bugs are design bugs
- **Teaches patterns before you implement**, so you build with industry best practices, not discover them in code review
- **Writes the pseudocode** at the right abstraction level — descriptive enough to constrain the design, abstract enough to require real thinking to translate
- **Won't review code** until tests exist
- **Asks one targeted question** after every file — not to quiz, but to build the instinct that makes the next file faster

The process is slower than just asking Claude to build the feature. That's intentional. The feature is a vehicle. The goal is the engineer who comes out the other side able to build the next one faster, with fewer bugs, and with a mental model they can reason from.

## The Design Choices

**Hybrid triggers, not iron laws.**
Superpowers uses hard gates — it refuses to proceed until the gate is met. groundup names the skip and the risk, then lets the engineer decide. This is intentional. The discipline of recognising which gates matter and when to invoke them is itself a skill. An engineer who is blocked can't learn. An engineer who is told "you're skipping this, here's what that costs" learns something every time they skip.

**Problem-domain pseudocode.**
If pseudocode looks like code in another language, the engineer just transcribes it. The abstraction has to be real — "GET the user record for this userId" rather than `userRepo.findById(userId)`. The translation from problem-domain step to implementation syntax is where the thinking happens. That's where the skill gets built.

**Patterns before design is locked.**
Teaching a pattern in code review is too late. "This would have been better with the outbox pattern" is useful information after the fact, but the engineer already made the decision. Teaching the pattern during the flow discussion — before the diagram is agreed — means the engineer can apply it intentionally from the start. That's a fundamentally different kind of learning.

**Engineer draws the flow.**
The hardest thing for junior engineers to see is how data moves through a system. It's easy to understand what a function does. It's much harder to understand where the transaction boundary sits, which service owns what, what happens when a dependency fails. Making the engineer draw it — not Claude — forces them to confront what they actually understand. The gaps in the diagram are the gaps in their mental model.

**One reflection question, no answer.**
Growth reviews don't give the answer because the value isn't the answer — it's building the instinct to ask the question yourself next time. "What would have caught this bug before it reached review?" is a question senior engineers ask automatically. Junior engineers learn to ask it by being asked it, repeatedly, in context, at the moment it's most relevant.

## What groundup Is Not

groundup is not a productivity tool. It will not make you ship features faster in the short term. That's not the goal.

It's a growth framework. The investment is time and effort now for faster, more independent shipping later — and eventually, for the ability to reason through problems you've never seen before.

That's what distinguishes engineers who get better every year from engineers who plateau.
