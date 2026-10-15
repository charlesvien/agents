---
name: cstandup
description: List my PostHog/posthog and PostHog/ai-gateway PRs merged since the last standup (Mon/Wed/Fri 8:30 AM PT) as a numbered list with linked "PR" text, copied to the clipboard for a Slack canvas
disable-model-invocation: true
allowed-tools: Bash, Write
argument-hint: "[start date or day, defaults to the last standup]"
---

## Instructions

Build a standup list of the user's merged PRs and copy it to the clipboard as rich text so the links survive pasting into a Slack canvas.

### Step 1: Find the start time

Standup is Mon, Wed and Fri at 8:30 AM America/Los_Angeles. Default to the most recent one before now:

```bash
python3 -c '
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
now = datetime.now(ZoneInfo("America/Los_Angeles"))
t = now.replace(hour=8, minute=30, second=0, microsecond=0)
while t > now or t.weekday() not in (0, 2, 4):
    t -= timedelta(days=1)
print(t.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
'
```

If `$ARGUMENTS` names a different start (a date or a day like "monday"), use 8:30 AM PT on that day instead.

### Step 2: Fetch merged PRs

```bash
gh search prs --author @me --merged --merged-at ">=<since>" --repo PostHog/posthog --repo PostHog/ai-gateway --limit 100 --json number,title,url,repository,closedAt,body
```

Sort by `closedAt` (the merge time), oldest first. If there are none, say "No PRs merged since <day and time PT>" and stop.

### Step 3: Write one line per PR

Read each PR's title and body. Write one plain sentence, under 15 words, on what changed and why it matters. No conventional-commit prefix, no file names, no dashes, no trailing period.

Then write a recap: one plain sentence, under 25 words, naming the high level push or theme across the PRs (e.g. "Mostly hardening cloud task runs, plus some CI cleanup"). Same style rules.

### Step 4: Copy to the clipboard

Make a temp dir with `mktemp -d` and write two files into it:

- `standup.html`: `<p><recap></p>` then `<ol>` with one `<li><a href="<url>">PR</a> <sentence></li>` per PR. Escape `&`, `<` and `>` in all text.
- `standup.md`: the recap, a blank line, then `1. [PR](<url>) <sentence>` per line, as the plain text fallback.

Then copy both to the clipboard:

```bash
osascript -l JavaScript ~/.claude/skills/cstandup/clipboard.js <dir>/standup.html <dir>/standup.md
```

### Step 5: Output

Print the recap and the markdown list, then one line: `Copied to clipboard, paste into the canvas.` Nothing else.
