Before we do anything else — what does the error message actually say?

I need you to paste the full stack trace here. Not a summary, not your interpretation of it — the raw output. Unhandled promise rejections in Node always include the rejection reason and a stack trace. That stack trace is going to tell us exactly which promise is rejecting and where it originated.

While you're finding that: what does your webhook handler look like at a high level? Is it async? Are you awaiting everything inside it, or are you firing any promises without awaiting them?
