# Baseline Response — Microservices Rate Limiting (No Skill)

**Where Does Rate Limiting Go in a Microservices Setup?**

With an api-gateway, auth-service, user-service, and notification-service, your topology is:

```
Client
  |
api-gateway          <- single entry point for all external traffic
  |       |       |
auth-service  user-service  notification-service
```

**The api-gateway is almost always the right place for rate limiting.**

Reasons:
1. It's the single entry point — every external request passes through it. One policy protects all downstream services.
2. Your downstream services don't need to know about it. Rate limiting is a cross-cutting concern, not domain logic.
3. Enforcement at the edge is cheaper — you reject bad traffic before it hits your database or business logic.

**Defence in depth — when you'd also add it at the service level:**
- notification-service wraps an external provider (email/SMS) with its own quota — you'd want your own limit upstream of that call
- Internal callers (other services, tools) also need throttling
- Protection against a misconfigured internal service hammering another

**What rate limiting needs to work regardless of location:**
1. A shared store (Redis) — per-instance in-memory counters don't survive horizontal scaling
2. A key strategy — IP address (easy but unreliable behind NAT/proxies), user/API key (precise, requires auth context), or endpoint-specific limits
3. A policy — fixed window, sliding window, or token bucket (each has different burst/fairness characteristics)

**For your specific setup:**
1. Implement in the api-gateway as middleware, backed by Redis
2. Use user ID or API key as the rate limit key — this means auth must happen *before* the rate limit check
3. Add tighter limits on auth-service endpoints specifically (`/login`, `/register`, `/reset-password`) — high-value attack surfaces
4. If notification-service wraps an external provider, add a separate internal rate limit there

**Key question before you build:** Does the api-gateway currently validate tokens, or does it delegate to auth-service? This determines whether you have the user ID available for rate limit keying at the gateway, or whether you're forced to use IP — which is weaker, especially behind load balancers.
