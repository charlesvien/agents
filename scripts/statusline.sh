#!/bin/bash
# Claude Code status line: model | git branch + change counts | context bar | cost | lines changed
# Input schema: https://code.claude.com/docs/en/statusline

export LC_ALL=C

input=$(cat)

RESET=$'\033[0m'
DIM=$'\033[2m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
MAGENTA=$'\033[35m'
SEP=" ${DIM}│${RESET} "

# Unit separator as delimiter: unlike tab it is not IFS whitespace, so an
# empty field (e.g. no cwd) cannot collapse and shift the ones after it
IFS=$'\x1f' read -r MODEL CWD PCT USED_TOKENS WINDOW_SIZE COST LINES_ADDED LINES_REMOVED < <(
  printf '%s' "$input" | jq -r '[
    (.model.display_name // "Claude"),
    (.workspace.current_dir // .cwd // ""),
    (.context_window.used_percentage // 0),
    (.context_window.total_input_tokens // 0),
    (.context_window.context_window_size // 200000),
    (.cost.total_cost_usd // 0),
    (.cost.total_lines_added // 0),
    (.cost.total_lines_removed // 0)
  ] | map(tostring) | join("\u001f")'
)

MODEL=${MODEL:-Claude}
COST=${COST:-0}
LINES_ADDED=${LINES_ADDED:-0}
LINES_REMOVED=${LINES_REMOVED:-0}

PCT=${PCT%%.*}
[[ "$PCT" =~ ^[0-9]+$ ]] || PCT=0
[ "$PCT" -gt 100 ] && PCT=100

USED_TOKENS=${USED_TOKENS%%.*}
[[ "$USED_TOKENS" =~ ^[0-9]+$ ]] || USED_TOKENS=0
WINDOW_SIZE=${WINDOW_SIZE%%.*}
[[ "$WINDOW_SIZE" =~ ^[0-9]+$ ]] || WINDOW_SIZE=200000

fmt_tokens() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        local tenths=$((n % 1000000 / 100000))
        if [ "$tenths" -eq 0 ]; then
            printf '%dM' $((n / 1000000))
        else
            printf '%d.%dM' $((n / 1000000)) "$tenths"
        fi
    elif [ "$n" -ge 1000 ]; then
        printf '%dk' $((n / 1000))
    else
        printf '%d' "$n"
    fi
}

# Single git call for branch, ahead/behind and working tree counts
GIT_SEG=""
if [ -n "$CWD" ] && PORCELAIN=$(git --no-optional-locks -C "$CWD" status --porcelain=v2 --branch 2>/dev/null); then
    BRANCH="" OID="" AHEAD=0 BEHIND=0 STAGED=0 MODIFIED=0 UNTRACKED=0 CONFLICTS=0
    while IFS= read -r line; do
        case "$line" in
            "# branch.oid "*) OID=${line#"# branch.oid "} ;;
            "# branch.head "*) BRANCH=${line#"# branch.head "} ;;
            "# branch.ab "*)
                ab=${line#"# branch.ab "}
                AHEAD=${ab%% *}; AHEAD=${AHEAD#+}
                BEHIND=${ab##* }; BEHIND=${BEHIND#-}
                ;;
            "1 "* | "2 "*)
                xy=${line:2:2}
                [ "${xy:0:1}" != "." ] && STAGED=$((STAGED + 1))
                [ "${xy:1:1}" != "." ] && MODIFIED=$((MODIFIED + 1))
                ;;
            "u "*) CONFLICTS=$((CONFLICTS + 1)) ;;
            "? "*) UNTRACKED=$((UNTRACKED + 1)) ;;
        esac
    done <<<"$PORCELAIN"

    [ "$BRANCH" = "(detached)" ] && BRANCH=${OID:0:7}

    if [ -n "$BRANCH" ]; then
        if [ $((STAGED + MODIFIED + UNTRACKED + CONFLICTS)) -gt 0 ]; then
            GIT_SEG="${YELLOW}${BRANCH}${RESET}"
        else
            GIT_SEG="${GREEN}${BRANCH}${RESET}"
        fi
        [ "$STAGED" -gt 0 ] && GIT_SEG+=" ${GREEN}+${STAGED}${RESET}"
        [ "$MODIFIED" -gt 0 ] && GIT_SEG+=" ${YELLOW}~${MODIFIED}${RESET}"
        [ "$CONFLICTS" -gt 0 ] && GIT_SEG+=" ${RED}!${CONFLICTS}${RESET}"
        [ "$UNTRACKED" -gt 0 ] && GIT_SEG+=" ${DIM}?${UNTRACKED}${RESET}"
        [ "$AHEAD" -gt 0 ] && GIT_SEG+=" ${CYAN}↑${AHEAD}${RESET}"
        [ "$BEHIND" -gt 0 ] && GIT_SEG+=" ${RED}↓${BEHIND}${RESET}"
    fi
fi

BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
if [ "$PCT" -ge 90 ]; then BAR_COLOR=$RED
elif [ "$PCT" -ge 70 ]; then BAR_COLOR=$YELLOW
else BAR_COLOR=$GREEN; fi
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" "" && BAR=${FILL// /▓}
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" "" && BAR="${BAR}${PAD// /░}"

printf -v COST_FMT '$%.2f' "$COST" 2>/dev/null || COST_FMT='$0.00'

STATUS="${CYAN}${MODEL}${RESET}"
[ -n "$GIT_SEG" ] && STATUS+="${SEP}${GIT_SEG}"
STATUS+="${SEP}${BAR_COLOR}${BAR}${RESET} ${DIM}${PCT}% $(fmt_tokens "$USED_TOKENS")/$(fmt_tokens "$WINDOW_SIZE")${RESET}"
STATUS+="${SEP}${MAGENTA}${COST_FMT}${RESET}"
if [ "$LINES_ADDED" != "0" ] || [ "$LINES_REMOVED" != "0" ]; then
    STATUS+="${SEP}${GREEN}+${LINES_ADDED}${RESET}${DIM}/${RESET}${RED}-${LINES_REMOVED}${RESET}"
fi

printf '%s\n' "$STATUS"
