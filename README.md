# 🤖 Charles' Agentic Workflow

The skills and agents I use to ship code for PostHog. Built around Graphite stacked PRs and the PostHog Code ecosystem.

## Setup

```bash
git clone https://github.com/charlesvien/agents
cd agents
./install.sh
```

The install script handles skills and agents but **not** [`settings.json`](global/settings.json) or [`CLAUDE.md`](global/CLAUDE.md) since those are personal config that you'll want to customize. Instead of copying blindly, paste this prompt into Claude Code and it'll compare my config with yours, explain the differences and let you pick what to adopt:

```
Read the CLAUDE.md and settings.json from the agents repo I just
cloned. Then read my current ~/.claude/CLAUDE.md and
~/.claude/settings.json (create them if they don't exist).
Compare them side by side. For each rule or setting I'm missing,
explain what it does and why it's useful. Then let me pick which
ones to add. Apply only what I choose.
```

> [`CUSTOM.md`](CUSTOM.md) is a personality prompt - makes Claude more direct and less corporate. Append it to your `~/.claude/CLAUDE.md` if you want the same vibe.

## Dependencies

The CLAUDE.md tells Claude to use these instead of the defaults. Install via Homebrew:

```bash
brew install ripgrep fd bat tree git-delta fzf
```

| Tool | Replaces | Why |
|---|---|---|
| `rg` | `grep` | Faster, respects .gitignore |
| `fd` | `find` | Faster, saner syntax |
| `bat` | `cat` | Syntax highlighting, line numbers |
| `tree` | `ls -R` | Visual directory structure |
| `delta` | `diff` | Syntax-highlighted git diffs |
| `fzf` | manual searching | Fuzzy find anything - files, branches, history |

## Skills

Skills inherit whatever model your session is using.

**Ship**

| Skill | What it does |
|---|---|
| [`/cwrap`](skills/cwrap/SKILL.md) | Parallel typecheck + lint + test, fix all errors |
| [`/cpr`](skills/cpr/SKILL.md) | Create a PR with auto-generated title and description |
| [`/crebase`](skills/crebase/SKILL.md) | Rebase onto parent branch, resolve conflicts |
| [`/creview`](skills/creview/SKILL.md) | Review branch diff with severity categories and a verdict |

**Write**

| Skill | What it does |
|---|---|
| [`/ctest`](skills/ctest/SKILL.md) | Generate colocated tests for a source file |
| [`/cbatch`](skills/cbatch/SKILL.md) | Parallelize a code transformation across many files |

**Explore**

| Skill | What it does |
|---|---|
| [`/ctrace`](skills/ctrace/SKILL.md) | Trace a tRPC call end-to-end |
| [`/cdebug`](skills/cdebug/SKILL.md) | Triage a bug report, find root cause, explain and offer a fix |
| [`/clogs`](skills/clogs/SKILL.md) | Find Claude/Twig session log files |

## Agents

| Agent | Model | What it does |
|---|---|---|
| [`code-reviewer`](agents/code-reviewer.md) | Opus | Reviews diffs for bugs, security, performance and TS strictness |
| [`refactor`](agents/refactor.md) | Opus | Analyzes code structure, identifies violations of store/service boundary and applies safe refactors |

## Shell Commands

| Alias | What it does |
|---|---|
| `cc` | Launch Claude Code with all permissions |
| `ccw` | Launch Claude Code with all permissions in a worktree |
| `ciaclean` | Delete local branches already merged into main ([source](https://spencer.wtf/2026/02/20/cleaning-up-merged-git-branches-a-one-liner-from-the-cias-leaked-dev-docs.html)) |

## Experimenting with

| Tool | What it does | Status |
|---|---|---|
| [RTK](https://github.com/rtk-ai/rtk) | Compresses command output before it hits Claude's context (60-90% token reduction) | Evaluating - token savings are real but wary about stripping context Opus needs during debugging |