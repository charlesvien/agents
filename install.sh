#!/bin/bash
# Symlinks shared skills and agents into ~/.claude/
# Safe to re-run — won't clobber your existing stuff.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.claude/skills ~/.claude/agents

for skill in "$SCRIPT_DIR"/skills/*/; do
  ln -sf "$skill" ~/.claude/skills/
done

for agent in "$SCRIPT_DIR"/agents/*.md; do
  [ -f "$agent" ] && ln -sf "$agent" ~/.claude/agents/
done

echo "Done. Skills and agents linked into ~/.claude/"
