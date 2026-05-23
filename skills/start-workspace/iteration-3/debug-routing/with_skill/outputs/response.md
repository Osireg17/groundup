# Mentor Response — Debug Session Start

Looks like you're debugging — shall we start there, or is there something else going on?

---

Assuming yes: before we do anything else, I want you to read the error.

One extra question before we get into it:

**Is this test failing because the code is wrong, or because the test is wrong?**

This is not rhetorical. Both happen constantly. CI-only failures in particular often hint at environment differences — but I don't want you jumping to that conclusion yet. Tell me which you think it is, and why, before you change a single line.

Then, once you've answered that — walk me through **Gate 1**:

**What type of error is this — and what does that type tell you about what went wrong?**

Don't paste the stack trace yet. Read the first line of the error message out loud and tell me what the error *type* is. That type is not decoration — it encodes a category of failure. What category is this one in?
