> [!IMPORTANT]
> Includes hedgehog spinner verbs. Your Claude will snuffle, waddle and quill-check everything.

# 🤖 Charles' Agentic Workflow

The global rules, skills and hooks I use to ship code for PostHog.

## Setup

```bash
git clone https://github.com/charlesvien/agents
cd agents
./scripts/install.sh
```

The install script symlinks skills and scripts into `~/.claude/` and prunes links to anything removed from this repo. It does **not** touch [`settings.json`](global/settings.json) or [`CLAUDE.md`](global/CLAUDE.md) since those are personal. Paste this into Claude Code to compare them with yours and pick what to adopt:

```
Read the CLAUDE.md and settings.json from the agents repo I just
cloned. Then read my current ~/.claude/CLAUDE.md and
~/.claude/settings.json (create them if they don't exist).
Compare them side by side. For each rule or setting I'm missing,
explain what it does and why it's useful. Then let me pick which
ones to add. Apply only what I choose.
```

## Dependencies

The CLAUDE.md tells Claude to use these instead of the defaults:

```bash
brew install ripgrep fd bat git-delta fzf
```

## Skills

| Skill | What it does |
|---|---|
| [`/coffice`](skills/coffice/SKILL.md) | YC-style office hours: pressure test an idea with forcing questions, then produce a design doc |
| [`/creview`](skills/creview/SKILL.md) | Review the branch diff or a PR URL with severity categories and a verdict |
| [`/cdocs`](skills/cdocs/SKILL.md) | Write or edit posthog.com docs following the PostHog docs style guide |
| [`/cuiflash`](skills/cuiflash/SKILL.md) | Fix SPAs/SSR apps that flash the wrong UI before client-side data resolves |
| [`/cgraveyard`](skills/cgraveyard/SKILL.md) | ASCII graveyard of every subagent that perished in the current session |

## Hooks

| Hook | Event | What it does |
|---|---|---|
| [`no-comments.js`](scripts/no-comments.js) | PostToolUse (Edit/Write/MultiEdit) | Flags newly added code comments back to Claude and tells it to delete them. Lint and type directives like `@ts-expect-error` or `biome-ignore` pass |

## Status line

[`statusline.sh`](scripts/statusline.sh) shows model, git branch with change counts, a context bar with used/total tokens, session cost and lines changed. `install.sh` symlinks it to `~/.claude/statusline.sh`:

```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/statusline.sh",
  "padding": 0
}
```

## Shell Commands

| Alias | What it does |
|---|---|
| `cc` | Launch Claude Code with Opus, max effort and all permissions |
| `ccw` | Same as `cc` in a worktree |
| `ccu` | Launch Claude Code with Opus, all permissions and ultracode mode enabled |
| `ciaclean` | Delete local branches already merged into the default branch ([source](https://spencer.wtf/2026/02/20/cleaning-up-merged-git-branches-a-one-liner-from-the-cias-leaked-dev-docs.html)) |

Defined in [`global/aliases.sh`](global/aliases.sh). Source it from your `.zshrc`.

## Attribution

- Environment variable tweaks (`CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING`, `CLAUDE_CODE_DISABLE_AUTO_MEMORY`, `CLAUDE_CODE_SUBAGENT_MODEL`) from [@kunchenguid](https://x.com/kunchenguid/status/2043511416448307378)
- `/cuiflash` copied from [no-ui-flash](https://github.com/RhysSullivan/skills/blob/main/skills/no-ui-flash/SKILL.md) by [@RhysSullivan](https://github.com/RhysSullivan)
- `/coffice` adapted from [gstack's office-hours](https://github.com/garrytan/gstack/blob/main/office-hours/SKILL.md) by [@garrytan](https://github.com/garrytan), with the gstack framework stripped out
