---
name: ctrace
description: Trace a tRPC procedure from renderer call site through router to service and back
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Agent
user-invocable: true
arguments: procedure-name
---

## Instructions

Trace the full call path of a tRPC procedure. The procedure name is provided as an argument in `router.method` format (e.g., `/ctrace git.detectRepo`).

### Step 1: Parse the procedure name

Split the argument into:
- **Router name**: the part before the dot (e.g., `git`)
- **Method name**: the part after the dot (e.g., `detectRepo`)

### Step 2: Fan out subagents

Fan out 4 parallel subagents (using the Agent tool, subagent_type: `general-purpose`) in a single response, one per search aspect:

**Subagent 1 - Router and service:**
> Find the router and service for tRPC procedure `<router>.<method>`.
> 1. Search `apps/twig/src/main/trpc/routers/` for the router file defining this procedure.
> 2. Read the router file and find the procedure definition. Note input/output Zod schemas, the service method called, and whether it's a query, mutation or subscription.
> 3. Read the service implementation in full. Note what the method does, any events it emits, and any other services it calls.
>
> Return: router file path, procedure definition snippet, service class and method, input/output schemas, procedure type (query/mutation/subscription), behavior summary, emitted events, dependent services.

**Subagent 2 - Renderer call sites:**
> Search `apps/twig/src/renderer/` (components, hooks, stores, features) for all usages of `trpc.<router>.<method>`. For each call site, note the file, the component or hook that makes the call, whether it uses `.query()`, `.useMutation()`, `.useQuery()` etc., and what it does with the result.
>
> Return: list of call sites with file, caller, call type and result handling.

**Subagent 3 - Related subscriptions:**
> Search `apps/twig/src/main/trpc/routers/` for the router file of `<router>` and identify any subscription procedures inside it (typically named `on*`) that relate to `<method>`. Then search `apps/twig/src/renderer/` for `.useSubscription()` consumers of those subscriptions.
>
> Return: list of related subscription procedures with their renderer consumers, or "none" if there are no relevant subscriptions.

**Subagent 4 - Consuming stores:**
> Search `apps/twig/src/renderer/` for Zustand stores that consume or cache data from `trpc.<router>.<method>`. Look for store updates triggered by query results or by subscriptions in the same router.
>
> Return: list of stores with file path, store name and how they consume the data.

Wait for all four subagents to complete.

### Step 3: Output the call chain

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
