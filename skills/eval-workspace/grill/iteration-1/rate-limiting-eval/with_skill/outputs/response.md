You've described a solution before you've described the problem. Let's back up.

Rate limiting can mean a lot of things depending on who you're protecting, what you're protecting, and from what. Before we talk Redis keys and counters, I want to understand what's actually happening.

Walk me through this from first principles: what problem are you actually solving? What does "too many requests" look like in your system — is this a user hammering a specific endpoint, a bot scraping the API, a legitimate user on a slow polling loop, or something else? What broke, or what are you afraid will break, that made you reach for rate limiting?
