#!/bin/bash
# Symlinks shared skills and agents into ~/.claude/
# Safe to re-run — only creates new symlinks, never removes or overwrites your stuff.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GREEN='\033[32m'
YELLOW='\033[33m'
DIM='\033[2m'
RESET='\033[0m'

mkdir -p ~/.claude/skills ~/.claude/agents

new=0
existing=0
skipped=0

link_item() {
  local src="$1"
  local dest="$2"
  local name="$3"
  local type="$4"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$(cd "$(dirname "$current")" 2>/dev/null && pwd)/$(basename "$current")" = "$(cd "$(dirname "$src")" && pwd)/$(basename "$src")" ] || [ "$current" = "$src" ]; then
      printf "  ${DIM}✓ %s (%s, already linked)${RESET}\n" "$name" "$type"
      existing=$((existing + 1))
      return
    fi
  fi

  if [ -e "$dest" ]; then
    printf "  ${YELLOW}! %s (%s) — exists and isn't our symlink, skipping${RESET}\n" "$name" "$type"
    skipped=$((skipped + 1))
    return
  fi

  ln -s "$src" "$dest"
  printf "  ${GREEN}+ %s (%s)${RESET}\n" "$name" "$type"
  new=$((new + 1))
}

echo ""
echo "  Linking skills, agents and config into ~/.claude/"
echo ""

# CLAUDE.md (global rules)
link_item "$SCRIPT_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md" "CLAUDE.md" "config"

for skill in "$SCRIPT_DIR"/skills/*/; do
  [ -d "$skill" ] || continue
  name="$(basename "$skill")"
  link_item "$skill" "$HOME/.claude/skills/$name" "$name" "skill"
done

for agent in "$SCRIPT_DIR"/agents/*.md; do
  [ -f "$agent" ] || continue
  name="$(basename "$agent")"
  link_item "$agent" "$HOME/.claude/agents/$name" "$name" "agent"
done

echo ""
if [ $new -gt 0 ]; then
  printf "  ${GREEN}Added %d new.${RESET}" "$new"
fi
if [ $existing -gt 0 ]; then
  printf " %d already linked." "$existing"
fi
if [ $skipped -gt 0 ]; then
  printf " ${YELLOW}%d skipped (not ours).${RESET}" "$skipped"
fi
echo ""
echo ""
