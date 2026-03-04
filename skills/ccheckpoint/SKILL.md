---
name: ccheckpoint
description: Create, verify or list workflow checkpoints tied to git SHAs
allowed-tools: Bash, Read, Write, Glob, Grep
user-invocable: true
arguments: action-and-name
argument-hint: "create|verify|list|clear [name]"
---

## Instructions

You manage workflow checkpoints. Parse `$ARGUMENTS` to determine the action: `create <name>`, `verify <name>`, `list` or `clear`.

### create <name>

1. Verify working tree is clean (`git status --porcelain`). If dirty, warn and ask whether to proceed.
2. Log the checkpoint:

```bash
mkdir -p .claude
echo "$(date +%Y-%m-%d-%H:%M) | $NAME | $(git rev-parse --short HEAD)" >> .claude/checkpoints.log
```

3. Report: checkpoint name, SHA and timestamp.

### verify <name>

1. Read `.claude/checkpoints.log` and find the named checkpoint.
2. Extract the SHA from the log entry.
3. Compare current state to that SHA:

```bash
git diff --stat <sha>..HEAD
git log --oneline <sha>..HEAD
```

4. Report:

```
CHECKPOINT COMPARISON: $NAME
============================
Commits since: N
Files changed: X
```

If tests are available (`pnpm test` or similar), run them and include pass/fail count.

### list

1. Read `.claude/checkpoints.log`.
2. For each entry, show name, timestamp, SHA and whether HEAD is at/ahead of that SHA.

### clear

1. Read `.claude/checkpoints.log`.
2. Keep the last 5 entries, remove the rest.
3. Report how many were removed.

### No arguments or invalid action

Print usage:

```
Usage: /ccheckpoint <action> [name]

Actions:
  create <name>  - Create named checkpoint at current HEAD
  verify <name>  - Compare current state against checkpoint
  list           - Show all checkpoints
  clear          - Remove old checkpoints (keeps last 5)
```
