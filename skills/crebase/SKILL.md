---
name: crebase
description: Rebase the current branch onto its parent, resolving conflicts with mergiraf syntax-aware merging. Uses Graphite stacked PRs if available, falls back to git rebase.
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

## Instructions

Rebase the current branch onto its parent, resolving any conflicts along the way. Uses mergiraf for syntax-aware conflict resolution before falling back to manual resolution.

### Step 1: Check state

Run `git status` to make sure the working tree is clean. If there are uncommitted changes, stop and tell the user to commit or stash first.

### Step 2: Detect tooling and parent

Determine whether Graphite is available and tracking this branch:

1. Run `gt branch info` to check if Graphite manages this branch
2. **If Graphite is available:**
   - Run `gt log short` to see the stack position
   - Prefer `gt restack` which automatically rebases the entire stack correctly
3. **If Graphite is not available or fails:**
   - Fall back to `git rebase origin/main`

### Step 3: Rebase

Mergiraf is registered as a git merge driver and runs automatically during rebase. It resolves syntax-aware conflicts (reordered imports, moved-and-edited code, commutative struct fields) that git's line-based merge cannot handle.

**If Graphite is managing the stack:**
```
gt sync
gt restack
```

**If using plain git:**
```
git fetch origin main
git rebase origin/main
```

### Step 4: Resolve remaining conflicts

If there are merge conflicts after the automatic mergiraf pass:

1. Run `git status` to see which files are conflicted
2. For each conflicted file, run `mergiraf solve <file>` to attempt syntax-aware resolution of the remaining conflict markers. This handles conflicts that the merge driver couldn't resolve in its initial pass (e.g. when working from conflict markers rather than the original revisions).
3. If `mergiraf solve` fully resolves a file (no conflict markers remain), stage it with `git add <file>`
4. For any conflicts that mergiraf cannot resolve, read the file to understand both sides and resolve manually. Don't just pick one side blindly — understand the intent of both changes and merge them correctly.
5. Stage resolved files with `git add <file>`
6. Continue the rebase with `git rebase --continue`
7. Repeat until the rebase is complete

### Step 5: Verify

After the rebase completes:

1. Run `pnpm typecheck` to make sure nothing broke
2. Run `pnpm lint` to catch any lint issues introduced
3. Fix any issues found and amend the relevant commits if needed

Mergiraf is syntax-aware but not semantically aware. A clean merge can still produce logically incorrect code. The typecheck and lint steps are essential.

### Step 6: Report

Tell the user:
- The stack position (from `gt log short`, if using Graphite)
- How many conflicts were resolved (total and how many mergiraf handled vs manual)
- Which files were affected
- Whether typecheck and lint pass

Do NOT force push. Let the user decide when to push.
