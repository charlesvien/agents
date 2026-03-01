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

### Step 5: Check test coverage

For each changed file, determine whether tests exist and whether the changes are adequately covered:

1. **Find existing tests**: Look for colocated test files (e.g., `foo.test.ts` next to `foo.ts`) and related test files in `tests/` or `__tests__/` directories.
2. **Assess coverage of changes**: Check whether the existing tests exercise the new or modified code paths. Look for:
   - New functions/methods that have no test cases
   - New branches/conditions that aren't covered
   - Changed behavior that existing tests don't validate
   - Edge cases introduced by the changes
3. **Identify testable code**: Flag code that should have tests but doesn't. Prioritize:
   - Business logic and data transformations
   - Utility functions and helpers
   - State transitions (store actions, reducers)
   - Error handling paths
   - Complex conditionals or algorithms
4. **Skip test suggestions for**: Trivial glue code, type-only changes, simple re-exports, config files and pure UI layout changes with no logic.

### Step 6: Output

Present the review in the categories above. For each item:
- Reference the file and line number (e.g., `src/main/services/git.ts:42`)
- Quote the relevant code snippet
- Explain the issue and suggest a fix

After the categorized feedback, add a **Test Coverage** section:
- List changed files and whether they have corresponding tests
- Call out specific functions or code paths that lack test coverage
- Suggest concrete test cases that would add the most value (describe what to test, not full test code)

End with an overall **Verdict**: one of `Ship it`, `Needs changes` or `Needs discussion`.
