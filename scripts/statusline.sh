#!/bin/bash
# Claude Code Status Line
# Shows: model | git branch | context % | cost | lines changed

input=$(cat)

# Colors
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
MAGENTA="\033[35m"
BLUE="\033[34m"

# Parse JSON
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CWD=$(echo "$input" | jq -r '.workspace.current_dir // empty')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Calculate context % from current usage (matches auto-compaction trigger)
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
CONTEXT_PCT=$(echo "scale=2; $CURRENT_TOKENS * 100 / $CONTEXT_SIZE" | bc 2>/dev/null || echo "0")

# Git info (detailed state like oh-my-zsh)
GIT_INFO=""
if [ -n "$CWD" ]; then
    cd "$CWD" 2>/dev/null || true
    if git rev-parse --git-dir >/dev/null 2>&1; then
        BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

        if [ -n "$BRANCH" ]; then
            STATE=""
            # Unstaged changes
            if ! git diff --no-ext-diff --quiet 2>/dev/null; then
                STATE="${STATE}*"
            fi
            # Staged changes
            if ! git diff --no-ext-diff --cached --quiet 2>/dev/null; then
                STATE="${STATE}+"
            fi
            # Untracked files
            if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -1)" ]; then
                STATE="${STATE}%"
            fi
            # Stash
            if git rev-parse --verify refs/stash >/dev/null 2>&1; then
                STATE="${STATE}\$"
            fi
            # Upstream comparison
            UPSTREAM=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
            if [ -n "$UPSTREAM" ]; then
                LOCAL_REV=$(git rev-parse @ 2>/dev/null)
                REMOTE_REV=$(git rev-parse @{upstream} 2>/dev/null)
                BASE_REV=$(git merge-base @ @{upstream} 2>/dev/null)
                if [ "$LOCAL_REV" = "$REMOTE_REV" ]; then
                    STATE="${STATE}="
                elif [ "$LOCAL_REV" = "$BASE_REV" ]; then
                    STATE="${STATE}<"
                elif [ "$REMOTE_REV" = "$BASE_REV" ]; then
                    STATE="${STATE}>"
                else
                    STATE="${STATE}<>"
                fi
            fi

            # Color based on state
            if [ -z "$STATE" ]; then
                GIT_INFO="${GREEN}${BRANCH}${RESET}"
            elif [[ "$STATE" == *"*"* ]] || [[ "$STATE" == *"+"* ]]; then
                GIT_INFO="${YELLOW}${BRANCH}${DIM}${STATE}${RESET}"
            else
                GIT_INFO="${GREEN}${BRANCH}${DIM}${STATE}${RESET}"
            fi
        fi
    fi
fi

# Context bar (5 char visual: ▓▓▓░░)
context_bar() {
    local pct=$1
    local filled=$(echo "$pct / 20" | bc 2>/dev/null || echo "0")
    local empty=$((5 - filled))
    local bar=""

    # Color based on usage
    local color="$GREEN"
    if (( $(echo "$pct > 80" | bc -l 2>/dev/null || echo 0) )); then
        color="$RED"
    elif (( $(echo "$pct > 60" | bc -l 2>/dev/null || echo 0) )); then
        color="$YELLOW"
    fi

    for ((i=0; i<filled; i++)); do bar+="▓"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo -e "${color}${bar}${RESET}"
}

# Format cost
format_cost() {
    local cost=$1
    if (( $(echo "$cost < 0.01" | bc -l 2>/dev/null || echo 1) )); then
        printf "%.0f¢" "$(echo "$cost * 100" | bc -l 2>/dev/null || echo 0)"
    else
        printf "\$%.2f" "$cost"
    fi
}

# Build status line
STATUS=""

# Model
STATUS+="${CYAN}${MODEL}${RESET}"

# Git branch
if [ -n "$GIT_INFO" ]; then
    STATUS+=" ${DIM}│${RESET} ${GIT_INFO}"
fi

# Context window
CTX_BAR=$(context_bar "$CONTEXT_PCT")
CTX_PCT_INT=$(printf "%.0f" "$CONTEXT_PCT" 2>/dev/null || echo "0")
STATUS+=" ${DIM}│${RESET} ${CTX_BAR} ${DIM}${CTX_PCT_INT}%${RESET}"

# Cost
COST_FMT=$(format_cost "$COST")
STATUS+=" ${DIM}│${RESET} ${MAGENTA}${COST_FMT}${RESET}"

# Lines changed (only if non-zero)
if [ "$LINES_ADDED" != "0" ] || [ "$LINES_REMOVED" != "0" ]; then
    STATUS+=" ${DIM}│${RESET} ${GREEN}+${LINES_ADDED}${RESET}${DIM}/${RESET}${RED}-${LINES_REMOVED}${RESET}"
fi

echo -e "$STATUS"
