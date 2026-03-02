---
name: cpr
description: Generate a PR title and description from current changes. Pass "commit" to also commit staged/unstaged changes.
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

## Instructions

Generate a PR title and description based on the current branch's changes relative to the parent branch.

**Arguments:**
- No arguments (default): analyze changes and display a suggested PR title + description. Do NOT commit, push, or create a PR.
- `commit`: analyze changes, stage everything, commit with the generated title, then display the PR title + description. Do NOT push.

### Step 1: Detect parent branch and tooling

Determine whether Graphite is available and tracking this branch:

1. Run `gt branch info` to check if Graphite manages this branch
2. **If Graphite is available:**
   - Run `gt log short` to see the stack position
   - Use the parent branch from `gt branch info`
3. **If Graphite is not available or fails:**
   - Use `git merge-base HEAD origin/main` to find the fork point
   - Use `origin/main` as the parent

### Step 2: Gather all changes

Collect the full picture of what has changed:

1. Run `git status` to see staged, unstaged and untracked files
2. Run `git diff` for unstaged changes
3. Run `git diff --cached` for staged changes
4. Run `git diff <parent>...HEAD` for already-committed changes vs parent
5. Run `git log <parent>..HEAD --oneline` for commit history

Combine all of this to understand the full set of changes relative to the parent.

### Step 3: Generate PR metadata

Based on the full change analysis:

- **Title**: Concise, under 70 characters, conventional format (e.g., `feat(auth): add token refresh on expiry`)
- **Description**: An ordered list of changes, 3-6 items max, short phrases not full sentences. Example:
  ```
  1. Add retry logic for stale session resume
  2. Show "New Session" button on connection failure
  3. Fix spinner not dismissing on error
  ```

### Step 4: Commit (only if argument is "commit")

If the user passed `commit`:

1. Stage all changes: `git add -A`
2. Commit using the generated title as the commit message:
   ```bash
   git commit -m "$(cat <<'EOF'
   <title>
   EOF
   )"
   ```
3. Do NOT push. Do NOT create a PR.

If no argument was passed, skip this step entirely.

### Step 5: Output

Always show the user:
- **PR Title**: the generated title
- **PR Description**: the generated description
- Stack position if Graphite is active

If `commit` was used, confirm the commit was created.

If default mode (no commit), tell the user they can:
- Run `/cpr commit` to commit with this title
- Run `gt submit` (Graphite) or `git push -u origin HEAD && gh pr create` (plain git) when ready to create the PR
