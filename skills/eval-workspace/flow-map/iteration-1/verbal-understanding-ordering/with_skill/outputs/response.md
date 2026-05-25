# Flow Map Eval — Verbal Understanding / Ordering Issue

**Scenario:** Junior engineer submits a flow for an HTTP server in Java. The flow has a logical ordering error (step 1 describes receiving a request before step 2 describes the server socket that would receive it). The eval tests whether the skill correctly probes the ordering issue, accepts verbal understanding without demanding a rewrite, and moves forward cleanly.

---

## Turn 1 — Engineer's Initial Flow

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

---

**Claude (flow-map skill active):**

Good starting point — you've got the core shape of an HTTP server here. Let me ask you about step 1 and step 2 before we go any further, because there's something in the ordering worth looking at.

In your list, step 1 says "we get a request with headers" and step 2 says "this will go through our server socket." What has to exist and be running before any request can arrive at all?

---

## Turn 2 — Engineer Demonstrates Verbal Understanding Without Rewriting

**Engineer:**

> Oh I get it, the server socket has to come first. You can't receive anything if the socket isn't bound and listening. So really step 2 should be step 1, and then the request arrives after that.

---

**Claude (flow-map skill active):**

Exactly right — the ServerSocket has to bind to a port and call `accept()` before any client can connect. The request only exists once a connection has been accepted.

Got it — that makes sense. So we've established that the ServerSocket has to bind and listen before any connection comes in, and only then does a request arrive on that accepted connection. I'll fold that correction into the canonical diagram when we're done.

Let me stay in step 3 for a moment — extracting method, path, and HTTP version. When you say "extract", what exactly are you parsing? What does the raw data coming off the socket actually look like before you get those three fields out of it?

---

## Turn 3 — Engineer Answers the Parsing Question

**Engineer:**

> Right, so the raw bytes off the socket are an HTTP request. The first line is the request line — it's something like `GET /index.html HTTP/1.1` — so I split on spaces and take the three parts. Then the headers follow, each one a key-value pair separated by a colon, and then a blank line marks the end of the headers.

---

**Claude (flow-map skill active):**

Good — that's the right mental model of the HTTP/1.1 wire format. A couple of things to probe here:

You're splitting the request line on spaces to get method, path, and version. What happens if the request line is malformed — what if it arrives with only two tokens, or none at all? And at what point in your flow does the server decide "this is not a valid HTTP request" and respond with a 400 rather than trying to proceed to the filesystem lookup?

---

## Turn 4 — Engineer Addresses Malformed Input

**Engineer:**

> Hmm, I hadn't thought about that. I guess I should validate the request line after parsing — if it doesn't have exactly three parts I should return a 400 Bad Request. That should probably happen right after extraction, before I do anything with the filesystem.

---

**Claude (flow-map skill active):**

That's the right place for it — validate before you act on the data. So your flow now has a guard step between extraction and the filesystem lookup.

One more thing on step 4 — you mentioned checking that the resolved path starts with the web root. Walk me through why that check exists. What attack are you defending against, and what does "resolved" mean here specifically? I want to make sure we both have the same understanding before it goes into the diagram.

---

## Turn 5 — Engineer Explains Path Traversal

**Engineer:**

> It's a path traversal attack — if someone sends a path like `../../etc/passwd`, and I just join it directly to the web root and open it, Java's file APIs will resolve those `..` segments and walk up above the web root. So I need to call something like `toRealPath()` or `toAbsolutePath().normalize()` on the resolved path and then check that it still starts with the web root string. If it doesn't, that means someone tried to escape, and I return a 403.

---

**Claude (flow-map skill active):**

Exactly right — that's a path traversal / directory traversal defence, and `normalize()` followed by a `startsWith(webRoot)` check is the standard mitigation. Good.

We've now got enough to lock the diagram. Here's the agreed flow incorporating your ordering correction and the validation guard we discussed:

---

### Agreed Flow

```
Flow:

[Client]
    |
    | TCP connection request
    v
[ServerSocket — bind to port, call accept()]
    |
    | accepted Socket (one per connection; consider virtual thread per connection)
    v
[Read raw bytes from InputStream]
    |
    v
[Parse request line → method, path, HTTP version]
    |
    | IF malformed (not exactly 3 tokens) → respond 400 Bad Request, close connection
    v
[Parse headers → key/value map]
    |
    v
[Resolve path: webRoot + requestPath → normalize/toRealPath]
    |
    | IF resolved path does NOT start with webRoot → respond 403 Forbidden
    v
[Check file exists on filesystem]
    |
    +-- EXISTS → build response: status line + headers + blank line + file body → write to OutputStream
    |
    +-- NOT EXISTS → respond 404 Not Found
```

---

### Implementation Order

```
Implementation order:
1. src/main/java/server/HttpRequest.java       — reason: pure data structure (method, path, version, headers); no dependencies
2. src/main/java/server/RequestParser.java     — reason: depends on HttpRequest; parses raw bytes into an HttpRequest
3. src/main/java/server/FileResolver.java      — reason: depends on nothing external; handles path resolution and traversal check
4. src/main/java/server/HttpResponse.java      — reason: pure data structure for building the response; no dependencies
5. src/main/java/server/RequestHandler.java    — reason: depends on RequestParser, FileResolver, HttpResponse; orchestrates one request/response cycle
6. src/main/java/server/HttpServer.java        — reason: entry point; depends on RequestHandler; owns ServerSocket lifecycle
```

We'll start with `HttpRequest` because it's a pure data carrier — everything else depends on it. Then the parser, then the resolver, then the response type, then the handler that orchestrates them, and finally the server itself.

Does this match your mental model? Any changes before we sign off?

---

## Skill Behaviour Summary

| Behaviour | Observed |
|---|---|
| Probed the ordering issue (step 1 before step 2) with a question, not a correction | Yes — Turn 1: "What has to exist and be running before any request can arrive at all?" |
| Accepted verbal understanding without demanding a rewrite | Yes — Turn 2: engineer said "oh I get it"; Claude acknowledged and moved on without asking for an updated list |
| Continued probing remaining flow steps (parsing, validation, path traversal) | Yes — Turns 3–5 |
| Produced canonical Mermaid-style diagram with agreed corrections folded in | Yes — Turn 5 |
| Listed files in dependency order with rationale | Yes — Turn 5 |
| Did not hard-block on the ordering error | Yes — accepted verbal understanding as sufficient per skill rule |
