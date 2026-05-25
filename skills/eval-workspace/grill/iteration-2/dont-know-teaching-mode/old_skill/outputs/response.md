# Grill Simulation — dont-know-teaching-mode (old skill)

---

## Turn 1

**Engineer:** I want to build a web server that listens to connections and responds using HTTP.

---

**Claude:**

Good starting point. Before any design work, I need to understand what you're actually building — "web server" covers a wide range of things.

Walk me through what this server needs to do. What are the requests coming in, what processing happens, and what does the response look like?

---

## Turn 2

**Engineer:** we send over a json, then we marshall it.

---

**Claude:**

Okay — so a client sends a JSON payload and the server deserialises it into some structure. That tells me about the body, but HTTP requests have more to them than just the body.

What does the request line look like? What method, path, and HTTP version are you expecting to handle?

---

## Turn 3

**Engineer:** The method, the path, and the HTTP version.

---

**Claude:**

Right, those are the three components of an HTTP request line — that's what you'll need to parse. But I'm asking what values you're expecting: is this a single endpoint, multiple routes? POST only, or multiple methods? HTTP/1.1 only, or do you need to think about HTTP/2?

Let me come back to that in a moment. First — the path. If the client controls the path string, what happens if someone sends a path like `../../etc/passwd` or a path that doesn't exist on your server?

---

## Turn 4

**Engineer:** I'm not sure.

---

**Claude:**

That's the right place to stop and think, because path traversal is one of the most common vulnerabilities in servers that handle filesystem-mapped paths. If you're serving static files or mapping paths to resources on disk, a crafted path can walk outside your intended root directory.

Two questions wrapped into one here: Does your server need to serve files from the filesystem, or is it purely handling API routes in code? And if a path arrives that you don't recognise — no matching route, no matching file — what should the server send back?

---

## Turn 5

**Engineer:** I don't know you asking me more questions is overwhelming not helping

---

**Claude:**

That's fair feedback, and I hear it.

Here's why the questions matter: every one of them points to a place where your server can either work correctly or silently fail in a way that's hard to debug later. "I don't know" on path security is not a gap I can fill in for you — it's a decision that shapes how you write the routing and parsing code. If we skip it now, it comes back as a production bug or a security hole.

So let's narrow the scope instead of going wider.

Pick one: Are you building this server to serve static files from a directory, or to respond to defined API routes in code? That single answer closes off half of the questions I've been asking, because the two paths have completely different failure modes.

---
