---
name: csync
description: Sync the whole Graphite stack, restack every tracked branch (resolving conflicts the way /crebase does), then force push them all up.
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
user-invocable: true
arguments: mode
argument-hint: "[clean] [nopush]"
---

## Instructions

Sync, restack and force push every Graphite-tracked branch in one shot. The flow: `gt sync` pulls trunk and rebases the branches that rebase cleanly, then you restack whatever sync left behind (resolving conflicts the way /crebase does), then you force push every stack.

Parse `$ARGUMENTS`:
- `clean`: also delete merged and closed branches during sync. Otherwise they're left alone.
- `nopush`: stop after sync and restack, don't force push anything.

Every `gt` command runs non-interactively so it can't hang waiting on a prompt.

### Step 1: Preflight

1. Confirm Graphite manages this repo: `gt log`. If it errors, stop and tell the user the repo isn't set up with Graphite.
2. `git status --porcelain`. If the working tree is dirty, STOP. Rebasing over uncommitted changes is unsafe. Tell the user to commit or stash first. This is the same hard rule as /crebase.
3. Capture the starting branch so you can return to it at the end:
   ```
   git rev-parse --abbrev-ref HEAD
   ```

### Step 2: Sync

Pull trunk and restack every branch that rebases cleanly.

**Default:**
```
gt sync --no-interactive
```

**If `clean` was passed** (also prune merged and closed branches):
```
gt sync --no-interactive --force --delete-all
```

`gt sync` restacks the branches that rebase cleanly and skips any that hit a conflict. The skipped ones are what Step 3 fixes.

### Step 3: Restack the leftovers and resolve conflicts

1. Run `gt log` and note any branch marked `(needs restack)`. Those are the ones sync couldn't finish.
2. If nothing needs a restack, skip to Step 4.
3. For each stack that has a branch needing restack, check out a branch in that stack and run:
   ```
   gt restack
   ```
4. If the restack stops on a conflict, resolve it the same way /crebase does:
   - Run `git status` to see the conflicted files.
   - Read each conflicted file fully and understand both sides. Resolve by merging the intent of both changes. Don't blindly pick a side.
   - Stage each resolved file with `git add <file>`.
   - Continue with `gt continue`.
   - Repeat until the restack finishes.
   - If a conflict is genuinely unresolvable, run `gt abort`, leave that stack alone and report it at the end instead of guessing.
5. Re-run `gt log` and confirm nothing still says `(needs restack)`.

### Step 4: Force push every stack

Skip this whole step if `nopush` was passed.

Force push every tracked branch up. This never touches trunk, since `gt submit --stack` excludes it.

1. Run `gt log` to see every stack. Each stack is a chain from trunk up to a top (leaf) branch.
2. For each separate stack, check out its top branch and submit the whole stack:
   ```
   gt submit --stack --force --no-edit --no-interactive
   ```
   `--stack` covers the branch's ancestors and descendants, so one submit from the top of a stack pushes every branch in it. If two stacks share a base branch it gets pushed twice, which is harmless.
3. Most of the time there's a single stack, so one `gt submit --stack --force --no-edit --no-interactive` from the top branch covers everything. This is the user's `gts` alias.

If a submit fails because a branch still isn't restacked, go back to Step 3 for that stack, then retry the submit.

### Step 5: Return and report

1. Check out the branch you started on (from Step 1). If it was deleted during a `clean` sync, check out trunk instead and say so.
2. Report:
   - Trunk synced and how many branches were restacked.
   - Conflicts resolved, with the branches and files, or "none".
   - Any stacks left aborted or unresolved that the user needs to handle.
   - Branches force pushed, or "skipped (nopush)".

## Notes

- This force pushes with `--force` to match the user's `gts` alias. On a branch shared with other people that can overwrite their pushes. Drop `--force` to fall back to Graphite's safer `--force-with-lease` if that's a concern.
- Add `--update-only` to the submit if you only want to push branches that already have a PR open and never create new ones.
- Never force push trunk (main).
