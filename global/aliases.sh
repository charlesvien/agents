alias cc='claude --dangerously-skip-permissions --model opus --effort max'
alias ccw='claude --dangerously-skip-permissions --worktree --model opus --effort max'
alias ccu='claude --dangerously-skip-permissions --model opus --settings "{\"ultracode\": true}"'
alias ciaclean='git branch --merged "$(git symbolic-ref --short refs/remotes/origin/HEAD)" | grep -vE "^\s*(\*|\+|main|master)" | xargs -n 1 git branch -d'
