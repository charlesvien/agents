# 🤖 Charles' Agentic Workflow

The skills and agents I use to ship code for PostHog. Built around Graphite stacked PRs and the PostHog Code ecosystem.

## Setup

```bash
git clone https://github.com/charlesvien/agents
cd agents
./install.sh
```

Symlinks everything into `~/.claude/` alongside your existing skills and agents.

## Skills

| Skill | What it does | When to use |
|---|---|---|
| `/ctrace` | Trace a tRPC call end-to-end | Before touching unfamiliar code paths |
| `/ctest` | Generate colocated tests for a source file | After writing or changing a module |
| `/cwrap` | Parallel typecheck + lint + test, fix all errors | Before committing — make sure nothing's broken |
| `/crebase` | Rebase onto parent, resolve conflicts | When your stack falls behind |
| `/cpr` | Create a Graphite PR with auto-generated title | Ready to ship — opens the PR for you |
| `/cscaffold` | Scaffold a new Twig feature | Starting a new feature from scratch |
| `/clogs` | Find Claude/Twig session log files | Debugging a session or task run |

## Agents

| Agent | Model | What it does |
|---|---|---|
| `code-reviewer` | Sonnet | Reviews diffs for bugs, security, performance, and TS strictness |
| `refactor` | Sonnet | Analyzes code structure, identifies violations of store/service boundary, and applies safe refactors |
