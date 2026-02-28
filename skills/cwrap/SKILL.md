---
name: cwrap
description: Run typecheck, lint, and test in parallel — fix all errors until everything passes
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, Task
---

## Instructions

You are finishing up work on the current branch. Run checks in parallel, fix issues, and verify.

### Step 1: Run checks in parallel

Launch **3 parallel Task agents** (subagent_type: `general-purpose`) to run all checks concurrently:

**Agent 1 — Typecheck:**
> Run `pnpm typecheck`. If there are errors, return the full error output. If clean, return "PASS".

**Agent 2 — Lint:**
> Run `pnpm lint`. If there are errors, return the full error output. If clean, return "PASS".

**Agent 3 — Test:**
> Run `pnpm test`. If there are failures, return the full error output. If clean, return "PASS".

Wait for all 3 to complete before proceeding.

### Step 2: Fix all issues

If any agent reported errors:
1. Collect all errors from all 3 agents
2. Fix all issues across the codebase (typecheck, lint, and test fixes together)
3. Re-run all 3 checks in parallel again (same pattern as Step 1)
4. Repeat until all 3 pass

### Step 3: Report

Once all checks pass, output a single line: **All checks pass.**
