---
name: cstandup
description: Draft my [Charles] entry for the next agent-infra standup from the team canvas, GitHub and Slack, ready to paste under Standup in the canvas
disable-model-invocation: true
allowed-tools: Bash, mcp__claude_ai_Slack__slack_read_canvas, mcp__claude_ai_Slack__slack_read_channel, mcp__claude_ai_Slack__slack_read_thread, mcp__claude_ai_Slack__slack_search_public_and_private
---

## Instructions

Draft the `[Charles]` entry for the next agent-infra standup. The output is a short block he pastes under **Standup:** in the team canvas. Standups are Mon/Wed/Fri.

### Who and where

- Standup canvas: `F0C1W5UCNHK` (https://posthog.slack.com/docs/TSS5W8YQZ/F0C1W5UCNHK). Newest entry is at the top.
- Slack user: Charles Vien, `U0A0S8QT8R4`. Team channel: `#team-agent-infra` (`C0C1T3V1RJA`).
- GitHub login: `charlesvien`, org `PostHog` (mostly `posthog`, `ai-gateway`, `charts`).

### Gather

Do these in parallel. The window is everything since his last `[Charles]` entry in the canvas.

1. **Canvas.** Read it. Note the date and content of his last entry (what he said was in progress or "up for review") and any Topics he has already written for the upcoming day. The result is large; only the top few entries matter.
2. **GitHub.** GraphQL (`gh search`, `gh pr list`) is blocked in cloud sessions, and per-repo PR endpoints may be too. Use REST search, which works across the org:
   - `gh api -X GET search/issues -f q="is:pr author:charlesvien org:PostHog merged:>=<last standup ISO time>"`
   - `... is:pr author:charlesvien org:PostHog is:open` (then again with `review:approved` and `review:none` to get stamp status)
3. **Slack.** Search `from:<@U0A0S8QT8R4> after:<day before last standup>` sorted by timestamp, and read `#team-agent-infra` over the same window. Use it to learn what he announced, who reviewed and what is waiting on whom. Ignore social channels.
4. **Stacks.** Group open PRs into stacks. Consecutive PR numbers opened together are a hint, but confirm with branch ancestry when it matters:
   ```
   cd "$(mktemp -d)" && git init -q
   git fetch -q --filter=tree:0 --depth=40 https://github.com/PostHog/posthog +refs/pull/N/head:refs/pr/N ...
   git merge-base --is-ancestor refs/pr/A refs/pr/B   # true means B is stacked on A
   ```
   PRs with no ancestry between them are independent, not a stack.

### Write

Match how he actually writes standup. Look at his recent entries in the canvas for voice before drafting.

- **Size:** 3 to 6 top-level bullets. If the draft is longer, cut. One line each.
- **Voice:** lowercase starts, plain outcome statements, no PR-by-PR status, no review bookkeeping beyond "approved", "half stamped", "waiting on X re-review". Thank reviewers inline, e.g. `(ty Jonathan)`.
- **Stacks:** one bullet per stack, linking the words `PR stack` to the **bottom (base) PR** of the stack. Never list every PR of a stack.
  - `* agent runtime [PR stack](https://github.com/PostHog/posthog/pull/137684) is approved, merging today (ty Jonathan)`
- **Sets of related PRs that are not one stack link:** put the PRs in parentheses, comma-delimited, each linked: `([#139320](url), [#139321](url), [ai-gateway#654](url))`. Prefix the repo name for anything outside `posthog`.
- **Merged work:** one bullet summarising what merged in plain words. PR links optional; skip them when there are several small cleanups.
- **New work not yet reviewed:** group under one parent bullet `will be ready for review today:` with a sub-bullet per piece, each saying what changes for users of the system, then the PR links.
- **Conversations and non-PR work:** one bullet, e.g. `chatting with other teams to understand what their plans are and how we can best support them`.
- **Leave out:** anything already in his Topics or his Standup entry for that day, reviews he did of other people's PRs, small refactors, and anything from before the last standup that he already reported.

Example of the target shape:

```
**[Charles]**
* agent runtime [PR stack](https://github.com/PostHog/posthog/pull/137684) is approved, merging today (ty Jonathan)
* run lifecycle [PR stack](https://github.com/PostHog/posthog/pull/137680) is half stamped, waiting on Ale re-review
* merged the dead tasks code and dead Azure embeddings cleanup
* will be ready for review today:
    * tasks read the model list from the gateway and pick up new versions of an allowed family automatically ([#139328](...), [#139329](...), [#139330](...), [#139331](...), [ai-gateway#653](...)), no more hand-written model lists
    * deactivated orgs lose gateway access on every product ([#139320](...), [#139321](...), [ai-gateway#654](...))
* chatting with other teams to understand what their plans are and how we can best support them
```

### Deliver

- The canvas does not render pasted markdown. `[text](url)` stays literal, and text copied from the terminal breaks a bullet at every wrapped line. So put the entry on the clipboard as rich text, where links paste as real links:
  1. Write the bullets as an HTML fragment to a file in the scratchpad: one `<ul>` of `<li>`, a nested `<ul>` for sub-bullets, `<a href>` for links, `<code>` for code. If the canvas already has his `[Charles]` entry for that day, write only the new bullets. Otherwise make `[Charles]` the single top `<li>` with the bullets nested under it.
  2. Run `osascript -l JavaScript ~/.claude/skills/cstandup/copy-rich.js <file>` and check it prints `copied as rich text`.
- Reply with the entry first, as normal markdown and not in a code fence, so the links render in the terminal. Nothing above it. Then one line saying it is on the clipboard, ready to paste into the canvas.
- After the entry, at most three short lines for things he should know before standup: a stale review waiting on him, a promised follow-up with no written trace, an unanswered ask in the team channel, a wrong date on the canvas entry. Skip the section if there is nothing.
- Say plainly if something is an assumption (e.g. "merging today").
- Do not edit the canvas unless he asks. If he does, add the entry under **Standup:** in the newest dated section, and leave other people's entries alone.
