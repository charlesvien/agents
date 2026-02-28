# 🤖 Charles' Agentic Workflow

The skills and agents I use to ship code for PostHog. Built around Graphite stacked PRs and the PostHog Code ecosystem.

## Setup

Symlinks skills and agents into `~/.claude/`.

```bash
git clone https://github.com/charlesvien/agents
cd agents
./install.sh
```

The install script handles skills and agents but **not** `settings.json` or `CLAUDE.md` since those are personal config that you'll want to customize. Instead of copying blindly, paste this prompt into Claude Code and it'll compare my config with yours, explain the differences and let you pick what to adopt:

```
Read the CLAUDE.md and settings.json from the agents repo I just cloned. Then read my current ~/.claude/CLAUDE.md and ~/.claude/settings.json (create them if they don't exist). Compare them side by side. For each rule or setting I'm missing, explain what it does and why it's useful. Then let me pick which ones to add. Apply only what I choose.
```

## Skills

| Skill | What it does | When to use |
|---|---|---|
| `/ctrace` | Trace a tRPC call end-to-end | Before touching unfamiliar code paths |
| `/ctest` | Generate colocated tests for a source file | After writing or changing a module |
| `/cwrap` | Parallel typecheck + lint + test, fix all errors | Before committing  - make sure nothing's broken |
| `/crebase` | Rebase onto parent, resolve conflicts | When your stack falls behind |
| `/cpr` | Create a Graphite PR with auto-generated title | Ready to ship  - opens the PR for you |
| `/cscaffold` | Scaffold a new Twig feature | Starting a new feature from scratch |
| `/clogs` | Find Claude/Twig session log files | Debugging a session or task run |
| `/cbatch` | Parallelize a code transformation across many files | Migrations, renames and API changes  - e.g. `/cbatch migrate from trpc to orpc` |

## Agents

| Agent | Model | What it does |
|---|---|---|
| `code-reviewer` | Sonnet | Reviews diffs for bugs, security, performance and TS strictness |
| `refactor` | Sonnet | Analyzes code structure, identifies violations of store/service boundary and applies safe refactors |