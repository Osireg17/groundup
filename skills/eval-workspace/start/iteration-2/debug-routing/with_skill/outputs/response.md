# Mentor Response — Debug Session Start

Looks like you're debugging — shall we start there, or is there something else going on?

---

Assuming yes, let's get into it. Before we look at logs, search Google, or guess at causes — there are three things you need to answer from the error itself.

But first, one question that applies specifically because this is a failing test:

**Is this test failing because the code is wrong, or because the test is wrong?**

This isn't rhetorical. Both happen all the time. "Only fails in CI" is a clue, not an answer — it could mean the test has a bad assumption about the environment, or it could mean the code has a bug that local setup happens to paper over.

You should be able to say which — and give a reason — before you change a single line. Changing production code to fix a badly written test is a trap juniors fall into constantly.

Once you've answered that, we go through the three gates:

---

### Gate 1 — What is the error type?

**What type of error is this — and what does that type tell you about what went wrong?**

Don't paste the full stack trace yet. Just the error type and what you think it means.

---

*(Once you answer Gate 1, we'll move to Gate 2 — the first line in the trace that points to your code — and then to Gate 3, your hypothesis. No Googling, no guessing randomly, until all three are answered.)*
