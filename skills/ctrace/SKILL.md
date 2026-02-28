---
name: ctrace
description: Trace a tRPC procedure from renderer call site through router to service and back
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
arguments: procedure-name
---

## Instructions

Trace the full call path of a tRPC procedure. The procedure name is provided as an argument in `router.method` format (e.g., `/ctrace git.detectRepo`).

### Step 1: Parse the procedure name

Split the argument into:
- **Router name**: the part before the dot (e.g., `git`)
- **Method name**: the part after the dot (e.g., `detectRepo`)

### Step 2: Find the router

Search `apps/twig/src/main/trpc/routers/` for the router file that defines this procedure. Read the router file and find the specific procedure definition.

Identify:
- Input/output Zod schemas
- The service method it calls
- Whether it's a query, mutation, or subscription

### Step 3: Find the service

From the router, identify which service class and method are invoked. Find and read the service implementation. Note:
- What the method does
- What events it emits (if any)
- What other services it calls

### Step 4: Find renderer call sites

Search the renderer code for all usages of this procedure:

```
trpc.<router>.<method>
```

Look in:
- `apps/twig/src/renderer/` — components, hooks, stores, features

For each call site, note:
- The file and component/hook that makes the call
- Whether it uses `.query()`, `.useMutation()`, `.useQuery()`, etc.
- What it does with the result

### Step 5: Find related subscriptions

If the service emits events, search for tRPC subscriptions on related events in the same router. Then search the renderer for subscription consumers (`trpc.<router>.on*`, `.useSubscription()`).

### Step 6: Find consuming stores

Identify which Zustand stores consume or cache the data from this procedure. Search for store updates triggered by the query results or subscription events.

### Step 7: Output the call chain

Present a full trace diagram showing the data flow:

```
Renderer                          Main Process
────────                          ────────────
<component/hook>
  → trpc.<router>.<method>.<type>()
                                  → <router>Router.<method>
                                    → <Service>.<method>()
                                      → <what it does>
                                      → emits <Event> (if applicable)
                                  → <router>Router.<subscription> (if applicable)
  ← <store>.update()
```

Include:
- All renderer call sites (there may be multiple)
- The full service call chain
- Any event emissions and their subscribers
- Store updates triggered by the data

If the procedure is not found, say so and suggest similar procedure names.
