# Junior Traps

Patterns that stunt growth. These are not character flaws — they're habits that form when the pressure to ship overrides the discipline to learn. Name them when you see them; don't shame them.

---

## In Problem Solving

### Speculative Implementation
"Let me just try it and see what happens."

Writing code before you understand the problem. The fix for one bug introduces two more. Hours of debugging produce a solution you can't explain. The mental model never forms.

**What to do instead:** State a hypothesis first. "I think X is causing Y because Z." Then implement to test the hypothesis, not to guess your way to a solution.

---

### Google-Paste-Run
Finding a Stack Overflow answer, copying it, running it, moving on.

The code works until the context changes. When it breaks, you can't debug it because you never understood it. You've borrowed someone else's knowledge without building your own.

**What to do instead:** Read the answer, close the tab, and implement from memory. If you can't, you don't understand it yet — read it again. The struggle of recall is where the learning happens.

---

### Symptom Fixing
Changing code until the error goes away.

This is the most expensive form of trial and error. You don't know what you changed, why it worked, or whether it introduced a new problem. The root cause is still there.

**What to do instead:** Reproduce the bug. Name the root cause. Make one targeted change to address the cause. Verify the fix works.

---

### "It Works on My Machine"
Shipping without considering the environment the code runs in.

Differences in OS, runtime version, environment variables, database state, and concurrency that don't exist locally will surface in staging or production.

**What to do instead:** Test in an environment as close to production as possible. Consider: what assumptions am I making about the environment that might not hold?

---

## In Design

### Designing for the Happy Path
Thinking only about what happens when everything works.

The happy path is 20% of the code. The other 80% handles what happens when things go wrong: null inputs, timeouts, missing permissions, duplicate requests, malformed data.

**What to do instead:** For every function, ask: what are the three most likely ways this could receive bad input or fail? Build those cases into the design before writing a line.

---

### Premature Optimisation
Optimising code before you know it's slow.

Time spent optimising something that isn't a bottleneck is time wasted. Worse, optimised code is harder to read and change — you've paid a readability cost for a performance gain you didn't need.

**What to do instead:** Write the clearest code first. Measure. Optimise only what the measurement tells you to.

---

### Big Bang Delivery
Building everything before showing anything.

Large, unreviewable changesets. No feedback until it's all done. When it doesn't work, you have no idea where to start.

**What to do instead:** Ship in vertical slices. The smallest possible thing that delivers value. Get feedback early, often, and incrementally.

---

## In Collaboration

### Asking Before Trying
"How do I do X?" before spending 20 minutes trying to figure it out.

The question robs you of the learning. The struggle of trying — hitting dead ends, reading docs, reasoning through it — is what builds the mental model. The answer without the struggle doesn't stick.

**What to do instead:** Try for 20-30 minutes first. Then ask with context: "I tried X and Y. X failed because Z. Y looked promising but I got stuck here. What am I missing?"

---

### Accepting the First Answer
Taking the first suggestion or search result without understanding the tradeoffs.

Every technical decision has tradeoffs. Accepting the first answer means you've made a decision without understanding what you traded away.

**What to do instead:** When given an option, ask: "What's the tradeoff? When would I not use this? What are the alternatives?" Make the decision with the full picture.

---

### Hiding the Struggle
Not asking for help until you've been stuck for hours, or hiding that you're stuck at all.

Being stuck is normal. Being stuck for hours without asking is a productivity problem that compounds. Senior engineers ask for help faster, not slower — they know that a 5-minute conversation can save hours.

**What to do instead:** Time-box attempts: 30 minutes of genuine effort, then ask. Frame it with what you tried and where you got stuck.
