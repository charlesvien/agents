alias cc='claude --dangerously-skip-permissions --model claude-opus-5-5 --effort xhigh'
alias ccw='claude --dangerously-skip-permissions --worktree --model claude-opus-5-5 --effort xhigh'
alias ccu='claude --dangerously-skip-permissions --model claude-opus-5-5 --settings "{\"ultracode\": true}"'
alias ciaclean='git branch --merged "$(git symbolic-ref --short refs/remotes/origin/HEAD)" | grep -vE "^\s*(\*|\+|main|master)" | xargs -n 1 git branch -d'
