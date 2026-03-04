---
name: cwrap
description: Run typecheck, lint, build, and test in parallel — fix all errors until everything passes
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, Agent
---

## Instructions

You are finishing up work on the current branch. Run checks in parallel, fix issues, and loop until everything is green. Do not stop until all checks pass.

### Step 1: Run checks in parallel

Launch **4 parallel agents** (using the Agent tool, subagent_type: `general-purpose`) to run all checks concurrently:

**Agent 1 — Typecheck:**
> Run `pnpm typecheck`. If there are errors, return the full error output. If clean, return "PASS".

**Agent 2 — Lint:**
> Run `pnpm lint`. If there are errors, return the full error output. If clean, return "PASS".

**Agent 3 — Build:**
> Run `pnpm build`. If there are errors, return the full error output. If clean, return "PASS".

**Agent 4 — Test:**
> Run `pnpm test`. If there are failures, return the full error output. If clean, return "PASS".

Wait for all 4 to complete before proceeding.

### Step 2: Fix and loop

If any agent reported errors:
1. Collect all errors from all 4 agents
2. Fix all issues across the codebase (typecheck, lint, build, and test fixes together)
3. Go back to Step 1 — re-run all 4 checks in parallel
4. **Keep looping until all 4 pass.** Do not give up or ask the user for help. You must resolve every failure yourself.

### Step 3: Report

Once all checks pass, output a single line: **All checks pass.**
