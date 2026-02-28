# 🤖 Charles' Agentic Workflow

The skills and agents I use to ship code for PostHog. Built around Graphite stacked PRs and the PostHog Code ecosystem.

## Setup

```bash
git clone https://github.com/charlesvien/agents
cd agents
./install.sh
```

The install script handles skills and agents but **not** `settings.json` or `CLAUDE.md` since those are personal config that you'll want to customize. Instead of copying blindly, paste this prompt into Claude Code and it'll compare my config with yours, explain the differences and let you pick what to adopt:

```
Read the CLAUDE.md and settings.json from the agents repo I just
cloned. Then read my current ~/.claude/CLAUDE.md and
~/.claude/settings.json (create them if they don't exist).
Compare them side by side. For each rule or setting I'm missing,
explain what it does and why it's useful. Then let me pick which
ones to add. Apply only what I choose.
```

## Dependencies

The CLAUDE.md tells Claude to use these instead of the defaults. Install via Homebrew:

```bash
brew install ripgrep fd bat tree
```

| Tool | Replaces | Why |
|---|---|---|
| `rg` | `grep` | Faster, respects .gitignore |
| `fd` | `find` | Faster, saner syntax |
| `bat` | `cat` | Syntax highlighting, line numbers |
| `tree` | `ls -R` | Visual directory structure |

## Skills

Skills inherit whatever model your session is using.

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
| `code-reviewer` | Opus | Reviews diffs for bugs, security, performance and TS strictness |
| `refactor` | Opus | Analyzes code structure, identifies violations of store/service boundary and applies safe refactors |

## Experimenting with

**[RTK](https://github.com/rtk-ai/rtk)** - A Rust CLI that compresses command output before it hits Claude's context window. Claims 60-90% token reduction on common commands by stripping noise from `git status`, test output, etc. Still evaluating this. The token savings are real but I'm wary about stripping context that Opus might need, especially during debugging sessions where full output matters. If you're paying for Opus you probably want it to have as much context as possible to be effective.