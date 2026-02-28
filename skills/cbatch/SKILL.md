---
name: cbatch
description: Parallelize a straightforward code transformation across many files (migrations, renames, pattern replacements)
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, Task
user-invocable: true
arguments: task-description
---

## Instructions

You are running a parallelized code transformation across the codebase. The task is described in `$ARGUMENTS` (e.g., "migrate from trpc to orpc", "rename logger.scope to logger.child", "replace all Radix Dialog with custom Modal component").

### Step 1: Understand the transformation

Parse the task description from `$ARGUMENTS`. Determine:
- **What to find**: The pattern, API, import, or code construct being changed
- **What to change it to**: The target pattern, API, or construct
- **Scope**: Which file types and directories are affected

### Step 2: Find all affected files

Use `Grep` and `Glob` to find every file that needs the transformation. Be thorough — search for:
- Direct usage of the source pattern
- Imports related to the source
- Type references
- Re-exports

Collect the full list of affected files.

### Step 3: Analyze a few examples

Read 2-3 affected files in full to understand the variety of usage patterns. Identify:
- The common case (most files will look like this)
- Edge cases (files that use the pattern differently)
- Dependencies between files (e.g., type definitions that other files import)

### Step 4: Order and group

Split files into two groups:

1. **Foundation files** — type definitions, shared utilities, core modules that other files depend on. These must be done first, sequentially.
2. **Leaf files** — components, hooks, stores, routes, tests that consume the foundation. These can be parallelized.

### Step 5: Transform foundation files

Process foundation files sequentially yourself (don't parallelize these). After each one, verify imports still resolve.

### Step 6: Parallelize leaf file transformations

Split the leaf files into batches of ~5 files each. For each batch, launch a **parallel Task agent** (subagent_type: `general-purpose`) with this prompt structure:

> You are performing the following code transformation:
>
> **Task:** [the transformation description]
>
> **Pattern:** Change [source pattern] → [target pattern]
>
> **Examples of correct transformation:**
> ```
> // Before
> [example from Step 3]
>
> // After
> [transformed example]
> ```
>
> **Your files:**
> - [file1]
> - [file2]
> - [file3]
> - [file4]
> - [file5]
>
> For each file:
> 1. Read the file
> 2. Apply the transformation
> 3. Make sure imports are updated
>
> Return a summary of what you changed in each file.

Launch all batch agents in parallel. Wait for all to complete.

### Step 7: Verify

After all agents complete:

1. Run `pnpm typecheck` — fix any type errors
2. Run `pnpm lint` — fix any lint errors
3. Run `pnpm test` — fix any test failures

If there are errors, fix them directly (don't re-batch).

### Step 8: Summary

Output:
- Total files transformed
- The transformation pattern applied
- Any files that needed special handling
- Any files that were skipped and why
- Verification results (typecheck/lint/test)
