---
name: cpr
description: Create a PR from the current branch with auto-generated title and description. Uses Graphite stacked PRs if available, falls back to gh CLI.
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

## Instructions

Create a PR for the current branch.

### Step 1: Pre-flight checks

1. Run `git status` to check for uncommitted changes
2. If there are uncommitted changes, show them and **stop** — tell the user to commit first (suggest running `/cwrap` then committing)

### Step 2: Detect parent branch and tooling

Determine whether Graphite is available and tracking this branch:

1. Run `gt branch info` to check if Graphite manages this branch
2. **If Graphite is available:**
   - Run `gt log short` to see the stack position
   - Use the parent branch from `gt branch info`
3. **If Graphite is not available or fails:**
   - Use `git merge-base HEAD origin/main` to find the fork point
   - Use `origin/main` as the parent

### Step 3: Analyze the diff

1. Run `git diff <parent>...HEAD` to get the full diff
2. Run `git log <parent>..HEAD --oneline` to see commit history
3. Understand what changed and why

### Step 4: Generate PR metadata

Based on the diff analysis:

- **Title**: Concise, under 70 characters, conventional format (e.g., `feat(auth): add token refresh on expiry`)
- **Description**: An ordered list of changes, 3-6 items max, short phrases not full sentences. Example:
  ```
  1. Add retry logic for stale session resume
  2. Show "New Session" button on connection failure
  3. Fix spinner not dismissing on error
  ```

### Step 5: Create the PR

**If Graphite is available:**
```bash
gt create --title "<title>" --message "$(cat <<'EOF'
<description>
EOF
)"
```
Then tell the user to run `gt submit` when ready to push. Do NOT run `gt submit` yourself.

**If using plain git:**
```bash
git push -u origin HEAD
gh pr create --title "<title>" --body "$(cat <<'EOF'
<description>
EOF
)"
```

### Step 6: Output

Show the user:
- The PR title and description you used
- The stack position (if using Graphite) or the PR URL (if using gh)
