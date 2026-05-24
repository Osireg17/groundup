We haven't agreed on the flow yet. We can proceed, but skipping the flow map tends to miss transaction boundaries and failure modes — that risk is now yours.

Here's what that means concretely: the grill surfaces what the system needs to do. The flow map surfaces how the pieces connect, who owns what, and where things can fail mid-sequence. Without it, we often write two files that don't compose correctly, or miss that a step needs to be atomic, or discover in code review that the order of operations was wrong.

"The flow is obvious" is the exact thought that produces that outcome. Obvious flows are where the gaps live.

Your call — do you want to take five minutes to draw the flow, or do you want to start coding and own the risk of a partial rewrite?
