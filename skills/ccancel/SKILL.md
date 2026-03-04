---
name: ccancel
description: "Cancel an active cloop"
allowed-tools: ["Bash(test -f .claude/cloop.local.md:*)", "Bash(rm .claude/cloop.local.md)", "Read(.claude/cloop.local.md)"]
hide-from-slash-command-tool: "true"
---

# Cancel Loop

To cancel the loop:

1. Check if `.claude/cloop.local.md` exists using Bash: `test -f .claude/cloop.local.md && echo "EXISTS" || echo "NOT_FOUND"`

2. **If NOT_FOUND**: Say "No active loop found."

3. **If EXISTS**:
   - Read `.claude/cloop.local.md` to get the current iteration number from the `iteration:` field
   - Remove the file using Bash: `rm .claude/cloop.local.md`
   - Report: "Cancelled loop (was at iteration N)" where N is the iteration value
