Hold on. "The flow is obvious" is one I want to name before we move.

You've built auth middleware before — that's real experience. But "I've done this before" and "the flow is obvious" are the two thoughts that most reliably cause engineers to miss something important. Not because they're wrong about the happy path. Because obvious flows are exactly where transaction boundaries and failure modes get skipped.

This specific codebase, this specific middleware placement, this specific token validation approach — they may differ from what you've built before in ways that matter. The whole point of the flow map isn't to draw something you don't know. It's to surface the one thing you assumed was the same that isn't.

We're not writing pseudocode yet. We haven't agreed on the flow.

Walk me through how you think the request moves through this middleware — from the point the request hits your route to the point it either proceeds or gets rejected. What does the middleware actually need to do, in order?
