---
name: crebase
description: Rebase the current branch onto its parent, resolving conflicts. Uses Graphite stacked PRs if available, falls back to git rebase.
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

## Instructions

Rebase the current branch onto its parent, resolving any conflicts along the way.

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

### Step 4: Resolve conflicts

If there are merge conflicts:

1. Run `git status` to see which files are conflicted
2. Read each conflicted file fully to understand both sides
3. Resolve the conflict intelligently — don't just pick one side blindly. Understand the intent of both changes and merge them correctly.
4. After resolving a file, stage it with `git add <file>`
5. Continue the rebase with `git rebase --continue`
6. Repeat until the rebase is complete

### Step 5: Verify

After the rebase completes:

1. Run `pnpm typecheck` to make sure nothing broke
2. Run `pnpm lint` to catch any lint issues introduced
3. Fix any issues found and amend the relevant commits if needed

### Step 6: Report

Tell the user:
- The stack position (from `gt log short`, if using Graphite)
- How many conflicts were resolved (if any)
- Which files were affected
- Whether typecheck and lint pass

Do NOT force push. Let the user decide when to push.
