#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GREEN='\033[32m'
YELLOW='\033[33m'
DIM='\033[2m'
RESET='\033[0m'

mkdir -p ~/.claude/skills ~/.claude/scripts

new=0
existing=0
skipped=0
pruned=0

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
echo "  Linking skills and scripts into ~/.claude/"
echo ""

for link in "$HOME"/.claude/skills/* "$HOME"/.claude/agents/* "$HOME"/.claude/scripts/*; do
  [ -L "$link" ] && [ ! -e "$link" ] || continue
  case "$(readlink "$link")" in
    "$SCRIPT_DIR"/*)
      rm "$link"
      printf "  ${DIM}- %s (removed from repo)${RESET}\n" "$(basename "$link")"
      pruned=$((pruned + 1))
      ;;
  esac
done

for skill in "$SCRIPT_DIR"/skills/*/; do
  [ -d "$skill" ] || continue
  name="$(basename "$skill")"
  link_item "$skill" "$HOME/.claude/skills/$name" "$name" "skill"
done

for script in "$SCRIPT_DIR"/scripts/*; do
  [ -f "$script" ] || continue
  name="$(basename "$script")"
  [ "$name" = "statusline.sh" ] && continue   # linked to ~/.claude/ top level below
  link_item "$script" "$HOME/.claude/scripts/$name" "$name" "script"
done

# statusline lives at the top level since settings.json points to ~/.claude/statusline.sh
link_item "$SCRIPT_DIR/scripts/statusline.sh" "$HOME/.claude/statusline.sh" "statusline.sh" "statusline"

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
if [ $pruned -gt 0 ]; then
  printf " %d pruned." "$pruned"
fi
echo ""
echo ""
