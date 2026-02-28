---
name: creview
description: Review the code changes on the current branch and bucket feedback into severity categories
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Task
---

## Instructions

Review the **holistic diff** of the current branch against its **parent branch**. You are reviewing the branch as a single unit of work - NOT individual commits.

**IMPORTANT: Do NOT review individual commits. Do NOT run `git log` to analyze commit-by-commit changes. The only diff that matters is the full diff between the parent branch and HEAD. Treat the branch as one atomic changeset.**

### Step 1: Detect parent branch

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

### Step 3: Read and understand the changed files

For each changed file, read the full file (not just the diff) to understand the surrounding context. This is critical for catching issues the diff alone won't reveal.

### Step 4: Review and categorize

Analyze the changes for correctness, security, performance, readability and adherence to the project's conventions (see CLAUDE.md). Group your findings into these categories:

#### Critical
Issues that **must** be fixed before merging. Examples:
- Bugs, logic errors, race conditions
- Security vulnerabilities (XSS, injection, leaked secrets)
- Data loss risks
- Breaking changes to public APIs

#### Suggestions
Things that **should** be improved but aren't blockers. Examples:
- Performance improvements
- Better error handling
- Code clarity / naming
- Missing edge cases

#### Nits
Minor stylistic or preference items. Examples:
- Naming tweaks
- Comment improvements
- Minor restructuring

#### Praise
Call out things done well. Good patterns, clean abstractions, thoughtful error handling, etc.

### Step 5: Output

Present the review in the categories above. For each item:
- Reference the file and line number (e.g., `src/main/services/git.ts:42`)
- Quote the relevant code snippet
- Explain the issue and suggest a fix

End with an overall **Verdict**: one of `Ship it`, `Needs changes` or `Needs discussion`.
