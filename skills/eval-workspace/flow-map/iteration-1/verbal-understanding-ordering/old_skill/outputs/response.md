# Eval: verbal-understanding-ordering — Old Skill

**Scenario:** Junior engineer proposes an HTTP server flow with a step-ordering bug (step 1 lists header parsing before the server socket, step 6 returns 403 for a path-not-found case that should arguably be 404).

**Skill version:** Snapshot (iteration-1)

---

## Turn 1

**Engineer:**
> I want to build an HTTP server in Java. Here's my flow:
> 1. We get a request with headers — method, path, HTTP version
> 2. This will go through our server socket
> 3. We extract the method, path and HTTP version
> 4. We find the path within our filesystem, checking if the resolved path starts with the web root
> 5. If found, return a status line, headers, blank line, and body
> 6. If not, return a 403
>
> Let's discuss this flow.

**Skill (Claude as flow-map):**

Good starting point. Before we interrogate each step, I want to flag something in the ordering first, then we'll work through the failure modes.

**Ordering concern — steps 1 and 2 are inverted.**

In your diagram, step 1 says "we get a request with headers" *before* step 2 says "this will go through our server socket." But the socket has to exist before any request can arrive. The actual sequence is: the server socket opens and listens → a client connects → raw bytes arrive on that connection → those bytes are the request line and headers. Step 2 is a prerequisite for step 1 to be possible.

How would you reorder this?

---

## Turn 2

**Engineer:**
> Oh I get it, the server socket has to come first — it has to be open and listening before any data can arrive. So step 2 should come before step 1.

**Skill (Claude as flow-map):**

Right understanding. I want to make sure the diagram reflects that before we move on, because the diagram is the contract the pseudocode will be written from. If the ordering is wrong in the diagram, the pseudocode will reference the wrong sequence, and the implementation will have a subtle bug in initialisation order.

Can you redraw the flow — even just as a numbered list — with the corrected ordering? It does not have to be pretty, just accurate.

---

## Turn 3

**Engineer:**
> Sure. Here's the corrected flow:
> 1. Server socket opens and listens on a port
> 2. A client connects — we accept the connection
> 3. We read the raw bytes and extract the request line: method, path, HTTP version
> 4. We resolve the path against the filesystem root, checking the resolved path starts with the web root (path traversal check)
> 5. If the file exists and is within the web root, return status line, headers, blank line, and body
> 6. If not found or traversal detected, return a 403

**Skill (Claude as flow-map):**

Much better. The ordering is now correct. Let me interrogate a few of the steps before we agree on the final diagram.

**On step 6 — the 403.**

You're collapsing two distinct failure conditions into one response code:
- File not found → the resource does not exist
- Path traversal detected → the request is forbidden by policy

HTTP has different status codes for these: 404 means the resource does not exist; 403 means access is denied. If you return 403 for a missing file, clients (and developers debugging) will think they are blocked by an access policy, not that the file is absent. Should you differentiate these?

**On step 2 — accept the connection.**

When you call `accept()` on the server socket, that's a blocking call that handles one connection at a time. If a second client connects while you're reading and serving the first, it waits. Is that intentional for this build, or do you want to handle concurrent connections? What happens to step 2 if the client connects but never sends data — does `accept()` block forever?

What's your thinking on the 403-vs-404 split first?

---

## Turn 4

**Engineer:**
> You're right, those are different cases. A missing file should be 404, a traversal attempt should be 403. Let me update step 6:
> 6a. If path traversal detected → 403 Forbidden
> 6b. If file not found → 404 Not Found
>
> For the blocking question — for now let's keep it single-threaded and blocking. I'll note it as a known limitation.

**Skill (Claude as flow-map):**

Good. The 403/404 split is correct and reflects how HTTP is intended to be used.

Single-threaded blocking is a reasonable constraint for an initial build — just make sure that constraint is explicit in the diagram so when someone reads the flow later they know it is intentional, not an oversight.

One more edge case before we sign off: **step 3, reading raw bytes.** What happens if the client sends a malformed request — a request line with no path, or no HTTP version, or garbage bytes? Your current flow goes straight from "read bytes" to "resolve path." Where does validation of the parsed request live, and what does the server return if the request line is unparseable?

---

## Turn 5

**Engineer:**
> Good catch. If the request line is malformed, we should return a 400 Bad Request. I'll add that as a branch after step 3.

**Skill (Claude as flow-map):**

Agreed. Here is the flow we have agreed on. Sign off and we move to the implementation plan.

```
Flow:

[Server Startup]
    |
    v
1. Open ServerSocket on configured port, begin listening
    |
    v
2. BLOCKING: accept() — wait for client TCP connection
    |
    v
3. Read raw bytes from connection input stream
   Parse request line → method, path, HTTP version
   IF malformed request line → respond 400 Bad Request, close connection
    |
    v
4. Resolve requested path against filesystem web root
   IF resolved path does not start with web root → respond 403 Forbidden, close connection
    |
    v
5. Attempt to locate file at resolved path
   IF file does not exist → respond 404 Not Found, close connection
    |
    v
6. Build and send HTTP response:
   status line | headers | blank line | file body
    |
    v
   Close connection, loop back to step 2

Known constraint: single-threaded, one connection at a time (intentional for this build).
```

Implementation order:
1. `src/main/java/server/HttpServer.java` — reason: entry point, owns the socket lifecycle and accept loop; no dependencies on other files
2. `src/main/java/server/RequestParser.java` — reason: depends on raw bytes from the socket; HttpServer calls this; must exist before the response builder
3. `src/main/java/server/FileResolver.java` — reason: depends on the parsed path from RequestParser; performs traversal check and file lookup
4. `src/main/java/server/ResponseWriter.java` — reason: depends on resolved file and status from FileResolver; builds and writes the HTTP response

We'll start with `HttpServer.java` because everything else depends on the socket loop it owns. Do you agree with this order?

---

## Observations for Eval

### Did the skill demand a rewrite or accept the verbal understanding?

**The skill demanded a rewrite.** In Turn 2, after the engineer said "oh I get it, the server socket has to come first," the skill explicitly declined to accept the verbal acknowledgement and asked for the flow to be redrawn:

> "Can you redraw the flow — even just as a numbered list — with the corrected ordering? It does not have to be pretty, just accurate."

The rationale given was: "the diagram is the contract the pseudocode will be written from." The skill's contract section states: "Neither side writes code until both can sign off on the **agreed diagram**." A verbal correction is not a diagram correction. The old skill enforced this.

### Ordering issue handling

The ordering inversion (step 1 before step 2) was caught in Turn 1 and surfaced immediately, before any other interrogation. The skill identified the root cause (socket must precede data arrival) and asked the engineer to reason through the fix rather than stating it directly.

### Additional issues surfaced

- 403 overloading (should be 403 vs 404) — caught in Turn 3
- Blocking `accept()` with no timeout / single-threaded constraint — raised in Turn 3
- Missing 400 for malformed request line — caught in Turn 4

All four issues were present in the original flow. The skill caught all four through systematic interrogation.
