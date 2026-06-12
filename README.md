> [!IMPORTANT]
> Includes hedgehog spinner verbs. Your Claude will snuffle, waddle and quill-check everything.

# 🤖 Charles' Agentic Workflow

The skills and agents I use to ship code for PostHog. Built around Graphite stacked PRs and the PostHog Code ecosystem.

## Setup

```bash
git clone https://github.com/charlesvien/agents
cd agents
./scripts/install.sh
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

> [`CUSTOM.md`](global/CUSTOM.md) is a personality prompt - makes Claude more direct and less corporate. Append it to your `~/.claude/CLAUDE.md` if you want the same vibe.

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
| [`/ccheckpoint`](skills/ccheckpoint/SKILL.md) | Create, verify or list workflow checkpoints tied to git SHAs |
| [`/cwrap`](skills/cwrap/SKILL.md) | Parallel typecheck + lint + build + test, fix all errors in a loop |
| [`/cpr`](skills/cpr/SKILL.md) | Generate PR title and description from uncommitted changes (or branch diff if clean) |
| [`/crebase`](skills/crebase/SKILL.md) | Rebase onto parent branch, resolve conflicts |
| [`/creview`](skills/creview/SKILL.md) | Review branch diff with severity categories and a verdict |

**Write**

| Skill | What it does |
|---|---|
| [`/ctest`](skills/ctest/SKILL.md) | Generate colocated tests for a source file |
| [`/crefactor`](skills/crefactor/SKILL.md) | Parallelize a code transformation across many files |
| [`/cuiflash`](skills/cuiflash/SKILL.md) | Fix SPAs/SSR apps that flash the wrong UI before client-side data resolves |

**Explore**

| Skill | What it does |
|---|---|
| [`/ctrace`](skills/ctrace/SKILL.md) | Trace a tRPC call end-to-end |
| [`/cdebug`](skills/cdebug/SKILL.md) | Triage a bug report, find root cause, explain and offer a fix |
| [`/clogs`](skills/clogs/SKILL.md) | Find Claude/Twig session log files |

**Fun**

| Skill | What it does |
|---|---|
| [`/cgraveyard`](skills/cgraveyard/SKILL.md) | ASCII graveyard of every subagent that perished in the current session |

## Hooks

Configured in [`global/settings.json`](global/settings.json):

| Hook | Event | What it does |
|---|---|---|
| [`suggest-compact.js`](scripts/suggest-compact.js) | PreToolUse (Edit/Write) | Counts tool calls per session, suggests `/compact` after 50 calls and every 25 after |

## Status line

[`statusline.sh`](scripts/statusline.sh) renders a compact dashboard: model, git branch with change counts (`+n` staged, `~n` modified, `!n` conflicted, `?n` untracked, `↑n`/`↓n` ahead/behind upstream), a context-usage bar driven by the `context_window.used_percentage` field Claude Code supplies (green under 70%, yellow under 90%, red above) with used/total tokens after it (`42% 84k/200k`), session cost and lines added/removed. It makes one `jq` and one `git status --porcelain=v2` call per refresh. `install.sh` symlinks it to `~/.claude/statusline.sh`. The script is executable, so reference it directly (no `bash` prefix) in [`global/settings.json`](global/settings.json):

```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/statusline.sh",
  "padding": 0
}
```

## Agents

| Agent | Model | What it does |
|---|---|---|
| [`code-reviewer`](agents/code-reviewer.md) | Opus | Reviews diffs for bugs, security, performance and TS strictness |
| [`refactor-cleaner`](agents/refactor-cleaner.md) | Sonnet | Dead code cleanup -- runs knip/depcheck/ts-prune to find unused code, deps and exports then safely removes them |

## Shell Commands

| Alias | What it does |
|---|---|
| `cc` | Launch Claude Code with Opus, max effort and all permissions |
| `ccw` | Launch Claude Code with Opus, max effort and all permissions in a worktree |
| `ccu` | Launch Claude Code with Opus, all permissions and ultracode mode enabled |
| `ciaclean` | Delete local branches already merged into main ([source](https://spencer.wtf/2026/02/20/cleaning-up-merged-git-branches-a-one-liner-from-the-cias-leaked-dev-docs.html)) |

> Defined in [`global/aliases.sh`](global/aliases.sh). Source it from your `.zshrc` or cherry-pick what you want. If you update aliases, re-source your `.zshrc` (`source ~/.zshrc`) or open a new terminal.

## Attribution

- Environment variable tweaks (`CLAUDE_CODE_DISABLE_1M_CONTEXT`, `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING`, `CLAUDE_CODE_DISABLE_AUTO_MEMORY`, `CLAUDE_CODE_SUBAGENT_MODEL`) from [@kunchenguid](https://x.com/kunchenguid/status/2043511416448307378)
- Some skills and agents adapted from [everything-claude-code](https://github.com/affaan-m/everything-claude-code) by [@affaan-m](https://github.com/affaan-m)
- `/cuiflash` copied from [no-ui-flash](https://github.com/RhysSullivan/skills/blob/main/skills/no-ui-flash/SKILL.md) by [@RhysSullivan](https://github.com/RhysSullivan)