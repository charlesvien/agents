---
name: creview
description: Review code changes on the current branch or a GitHub PR URL
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Agent
---

## Instructions

Review the **holistic diff** of a branch as a single unit of work - NOT individual commits.

**IMPORTANT: Do NOT review individual commits. Do NOT run `git log` to analyze commit-by-commit changes. The only diff that matters is the full diff between the parent branch and HEAD. Treat the branch as one atomic changeset.**

### Step 0: Resolve target

Check if `$ARGUMENTS` contains a GitHub URL (matching `github.com/.+/pull/\d+`).

**If a GitHub PR URL was provided:**

1. Save the current branch name: `git rev-parse --abbrev-ref HEAD`
2. Run `gh pr view <URL> --json headRefName,baseRefName` to get the PR's head and base branches
3. Run `gh pr checkout <URL>` to check out the PR branch locally
4. Use the base branch from the PR JSON as the parent branch
5. After the review is complete, switch back to the original branch: `git checkout <saved-branch>`

**If no URL was provided:** proceed to Step 1 as normal.

### Step 1: Detect parent branch

Skip this step if a GitHub PR URL was provided (parent was already resolved in Step 0).

1. Run `gt branch info` to check if Graphite manages this branch
2. **If Graphite is available:**
   - Run `gt log short` to see the stack position
   - Use the parent branch from `gt branch info`
3. **If Graphite is not available or fails:**
   - Use `git merge-base HEAD origin/main` to find the fork point

### Step 2: Gather the diff

Run a single diff of the entire branch against the parent:

```
git diff <parent>...HEAD
```

This is the **only** diff you should review. Do not break it down by commit. Also check for uncommitted changes with `git diff` and `git status`.

### Step 3: Fan out subagents

Fan out 3 parallel subagents (using the Agent tool, subagent_type: `general-purpose`) in a single response. Each subagent reads every changed file in full for context and returns findings for its assigned lens.

**Subagent 1 - Critical correctness, security and architecture:**
> Review the diff between `<parent>` and HEAD. Read every changed file in full. Identify only Critical issues that must be fixed before merging:
> - Bugs, logic errors, race conditions
> - Security vulnerabilities (XSS, injection, leaked secrets)
> - Data loss risks
> - Breaking changes to public APIs
> - Architectural violations (wrong layer, circular dependencies, broken module boundaries)
>
> For each finding return `<file>:<line>`, a quoted snippet, an explanation and a suggested fix. Return "(none)" if there are no Critical issues.

**Subagent 2 - Code quality, nits and praise:**
> Review the diff between `<parent>` and HEAD. Read every changed file in full. Identify:
> - **Suggestions**: performance, error handling, code clarity, missing edge cases, duplicated code (same pattern 2+ times or duplicating existing repo code), code smells (god functions, deep nesting 3+ levels, boolean blindness, primitive obsession, feature envy), bad abstractions (wrong level, leaky, premature, inheritance where composition fits), coupling and cohesion (tight coupling between independent modules, low cohesion within a module, hidden dependencies via globals/singletons).
> - **Nits**: naming tweaks, comment improvements, minor restructuring.
> - **Praise**: clean abstractions, thoughtful error handling, good patterns worth calling out.
>
> For each finding return `<file>:<line>`, a quoted snippet, an explanation and a suggested fix.

**Subagent 3 - Test coverage:**
> For each changed file in the diff between `<parent>` and HEAD:
> 1. Find existing tests (colocated `*.test.ts`/`*.test.tsx` and related files in `tests/` or `__tests__/`).
> 2. Assess whether new or modified code paths are covered: new functions with no test cases, new branches/conditions, changed behavior existing tests don't validate, edge cases the changes introduce.
> 3. Flag testable code that lacks coverage: business logic, data transformations, utilities, state transitions (store actions, reducers), error handling, complex conditionals.
> 4. Skip: trivial glue code, type-only changes, simple re-exports, config files, pure UI layout changes with no logic.
>
> Return a list of changed files with their test status and concrete test cases that would add the most value (describe what to test, not full test code).

Wait for all three subagents to complete before proceeding.

### Step 4: Synthesize and output

Merge findings from the three subagents into a single review. Cross-check for overlap and resolve any contradictions using your own read of the diff. Present sections in this order: Critical, Suggestions, Nits, Praise, Test coverage. For each finding include `<file>:<line>`, the quoted snippet, the explanation and the suggested fix.

End with an overall **Verdict**: one of `Ship it`, `Needs changes` or `Needs discussion`.
