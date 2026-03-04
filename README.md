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
| [`/cverify`](skills/cverify/SKILL.md) | Parallel typecheck + lint + build + test, fix all errors |
| [`/cpr`](skills/cpr/SKILL.md) | Generate PR title and description from uncommitted changes (or branch diff if clean) |
| [`/crebase`](skills/crebase/SKILL.md) | Rebase onto parent branch, resolve conflicts |
| [`/creview`](skills/creview/SKILL.md) | Review branch diff with severity categories and a verdict |
| [`/verification-loop`](skills/verification-loop/SKILL.md) | Full pre-PR gate: build, typecheck, lint, test, security scan and code review in one pass |

**Write**

| Skill | What it does |
|---|---|
| [`/ctest`](skills/ctest/SKILL.md) | Generate colocated tests for a source file |
| [`/crefactor`](skills/crefactor/SKILL.md) | Parallelize a code transformation across many files |

**Explore**

| Skill | What it does |
|---|---|
| [`/ctrace`](skills/ctrace/SKILL.md) | Trace a tRPC call end-to-end |
| [`/cdebug`](skills/cdebug/SKILL.md) | Triage a bug report, find root cause, explain and offer a fix |
| [`/clogs`](skills/clogs/SKILL.md) | Find Claude/Twig session log files |

**Loops**

| Skill | What it does |
|---|---|
| [`/cloop`](skills/cloop/SKILL.md) | Self-referential dev loop -- feeds output back as input until completion promise is met |
| [`/ccancel`](skills/ccancel/SKILL.md) | Cancel an active cloop |
| [`/ccompact`](skills/ccompact/SKILL.md) | Suggests manual `/compact` at logical phase transitions instead of arbitrary auto-compaction |

## Hooks

Configured in [`global/settings.json`](global/settings.json):

| Hook | Event | What it does |
|---|---|---|
| `suggest-compact.js` | PreToolUse (Edit/Write) | Counts tool calls per session, suggests `/compact` after 50 calls and every 25 after |
| `stop-hook.sh` | Stop | Powers cloop -- blocks exit and feeds the same prompt back for the next iteration |

## Agents

| Agent | Model | What it does |
|---|---|---|
| [`code-reviewer`](agents/code-reviewer.md) | Opus | Reviews diffs for bugs, security, performance and TS strictness |
| [`refactor-cleaner`](agents/refactor-cleaner.md) | Sonnet | Dead code cleanup -- runs knip/depcheck/ts-prune to find unused code, deps and exports then safely removes them |

## Commands

| Command | What it does |
|---|---|
| [`/checkpoint`](commands/checkpoint.md) | Create, verify or list workflow checkpoints tied to git SHAs |

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