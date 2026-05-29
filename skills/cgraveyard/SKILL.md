---
name: cgraveyard
description: Show an ASCII graveyard of all subagents spawned in the current session
disable-model-invocation: true
allowed-tools:
  - Bash(python3 *)
---

Run the renderer and print its output verbatim. Do not add commentary, headers, or summaries — the script's output IS the entire response.

```bash
python3 ~/.claude/scripts/graveyard.py
```
