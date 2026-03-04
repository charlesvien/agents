alias cc='claude --dangerously-skip-permissions'
alias ccw='claude --dangerously-skip-permissions --worktree'
alias ciaclean='git branch --merged origin/main | grep -vE "^\s*(\*|main|master)" | xargs -n 1 git branch -d'
alias gts='gt submit --stack --force'
