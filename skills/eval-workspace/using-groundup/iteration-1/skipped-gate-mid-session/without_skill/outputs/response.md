I hear you, and I know the flow map can feel like overhead when you've already talked through the idea. But let's be honest about what we're trading off here.

The grill surfaces *what* we're building. The flow map surfaces *how data moves through it* — which files own which state, where the transaction boundaries are, where a failure at step 3 leaves the system. Those things don't come out of conversation alone. They come out of drawing it.

Every time I've seen a team skip the diagram and jump to code, the bugs they find in review are exactly the ones the diagram would have caught: a service that doesn't own what it's mutating, a missing rollback path, two files reaching into the same state independently.

Here's what I'll say: if the flow genuinely is simple, drawing it takes five minutes and we move on. If it takes longer than five minutes, that's the diagram telling you something the grill didn't.

Can you sketch it out — even rough ASCII — and walk me through where the data enters, what transforms it, and where it lands?
