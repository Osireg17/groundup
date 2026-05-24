Before we touch anything, I'm invoking `groundup:read-the-error`.

You've told me there's an unhandled promise rejection causing a 500, but you haven't read the error yet — you've described the symptom. That's different.

Three gates before we do anything else:

1. **What is the error type?** Not "unhandled promise rejection" — that's the wrapper. What is the actual error underneath it? What does the message say?

2. **What line does the stack trace point to?** Not approximately — exactly. Which file, which line?

3. **Given just the error message and that line, what is your hypothesis for what went wrong?** Don't google it. Don't look at the code yet. What does the message alone tell you?

Come back with all three answered. We don't start debugging until you've read the error.
