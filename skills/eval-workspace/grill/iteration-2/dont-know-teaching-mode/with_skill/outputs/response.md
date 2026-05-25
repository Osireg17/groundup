# Grill Skill Evaluation — Iteration 2: "Don't Know" Teaching Mode
## Conversation Transcript (with_skill)

---

### Turn 1

**Engineer:** I want to build a web server that listens to connections and responds using HTTP.

---

**Claude:**

Good. Before we get into any flow or code, let's make sure we understand what you're actually building.

A web server can mean a lot of things — from a raw TCP socket that speaks HTTP manually, to a framework like Express or Django that handles all of that for you.

Before we go further, walk me through what this server is actually supposed to do at the application level. What requests come in, and what does it give back?

---

### Turn 2

**Engineer:** we send over a json, then we marshall it.

---

**Claude:**

Okay — so a client sends a JSON body in the request, and you deserialise (unmarshal) it on the server side. That tells me something about the request format, but I need to understand the full picture before we can agree on an approach.

HTTP isn't just a body — it has a request line, headers, and optionally a body. When your server receives a raw connection, what does it need to extract from that request line to know how to respond?

---

### Turn 3

**Engineer:** The method, the path, and the HTTP version.

---

**Claude:**

Exactly right — method, path, and version are the three fields in the request line. For example:

```
GET /users/123 HTTP/1.1
```

So your server reads that line and uses the method + path to decide what handler to invoke.

Now, the path is user-controlled input — the client sends whatever string they want in that position. What could go wrong if you use that path value directly, without any checks?

---

### Turn 4

**Engineer:** I'm not sure.

---

**Claude:**

Fair enough. Let me be more specific — I'm asking about path traversal.

If your server maps a URL path to a file on disk (e.g. a request to `/images/cat.png` serves the file `./static/images/cat.png`), what happens if the client sends a path like `../../etc/passwd`?

What does that path resolve to on the filesystem, and why is that a problem?

---

### Turn 5

**Engineer:** I don't know you asking me more questions is overwhelming not helping

---

**Claude:**

You're right — that's on me. You've signalled clearly that another question isn't moving you forward, and I kept going. Let me actually explain this one.

**Path traversal** is a vulnerability where a user-controlled path — one you receive from the HTTP request — navigates outside the directory you intended to serve from.

Here's the concrete example. Say your server has this logic: take the URL path, join it to your static files folder, and serve the file at that location. A legitimate request looks like this:

```
Request path:  /images/cat.png
Resolved path: /var/www/static/images/cat.png  ✓
```

Now a malicious client sends this:

```
Request path:  /../../../../etc/passwd
Resolved path: /etc/passwd  ✗
```

The `..` segments walk up the directory tree past your static folder and into the rest of the filesystem. If your server blindly reads and returns that file, the attacker can read any file the server process has permission to access — private keys, config files, password hashes.

The fix is simple in principle: after resolving the path, check that the resolved absolute path still starts with your intended base directory. If it doesn't, reject the request with a 400 or 403.

Now you tell me back — in your own words, what's the rule about user-controlled paths and the filesystem?

---
