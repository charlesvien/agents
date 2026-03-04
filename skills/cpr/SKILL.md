---
name: cpr
description: Generate PR title and description from uncommitted changes (or branch diff if clean). Pass "commit" to also commit.
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

## Instructions

Generate a PR title and description from uncommitted changes or branch commits.

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

### Step 2: Gather changes and determine changeset

1. Run `git status` to see staged, unstaged and untracked files
2. Run `git diff` for unstaged changes
3. Run `git diff --cached` for staged changes

**If there are any uncommitted changes** (staged, unstaged or untracked files):
- These are the changeset. Generate the PR title and description from these changes only.
- Do NOT look at committed changes vs parent. The uncommitted work is what the user wants to describe.

**If there are no uncommitted changes** (clean working tree):
- Fall back to the branch's committed changes vs parent.
- Run `git diff <parent>...HEAD` for the diff
- Run `git log <parent>..HEAD --oneline` for commit history
- Generate the PR title and description from these.

### Step 3: Generate PR metadata

Based on the changeset from Step 2:

- **PR Title**: Concise, under 70 characters, conventional format `<type>(<scope>): <subject>`. Capitalize the first letter after the prefix (e.g., `feat(auth): Add token refresh on expiry`)
- **Commit message**: Plain imperative subject, no type prefix (e.g., `add token refresh on expiry`). Used only when committing in Step 4.
- **Description**: An ordered list of changes, 3-6 items max, short phrases not full sentences. Example:
  ```
  1. Add retry logic for stale session resume
  2. Show "New Session" button on connection failure
  3. Fix spinner not dismissing on error
  ```

### Step 4: Commit (only if argument is "commit")

If the user passed `commit`:

1. Stage all changes: `git add -A`
2. Commit using the **commit message** (plain, no type prefix):
   ```bash
   git commit -m "$(cat <<'EOF'
   <commit message>
   EOF
   )"
   ```
3. Do NOT push. Do NOT create a PR.

If no argument was passed, skip this step entirely.

### Step 5: Output

Always show the user:
- **PR Title**: the generated PR title (conventional format with type prefix)
- **PR Description**: the generated description
- Stack position if Graphite is active

If `commit` was used, confirm the commit was created.

If default mode (no commit), tell the user they can:
- Run `/cpr commit` to commit with this title
- Run `gt submit` (Graphite) or `git push -u origin HEAD && gh pr create` (plain git) when ready to create the PR
