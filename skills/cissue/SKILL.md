---
name: cissue
description: Paste Slack messages to find a matching GitHub issue or create a new one
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
user-invocable: true
arguments: slack-messages
argument-hint: "<pasted slack messages>"
---

## Writing conventions

- No em dashes. Use hyphens, commas or separate sentences instead.
- No Oxford commas (no comma before "and" in lists).
- English only.

## Instructions

You are triaging Slack messages to find or create a GitHub issue. The pasted messages are in `$ARGUMENTS`.

**Default repo**: `posthog/code`. All `gh` commands must use `--repo posthog/code` unless the user specifies a different repo.

### Step 1: Extract the problem

Parse the Slack messages. Identify:
- **The core problem or request** being discussed
- **Key technical terms**, error messages, component names, file paths or feature names
- **Who reported it** and any context about severity or urgency
- **Any reproduction steps** mentioned in the thread

Summarize the problem in one sentence for yourself before proceeding.

### Step 2: Search for existing issues

Build 2-3 search queries from the key terms identified in Step 1. Run each:

```bash
gh issue list --repo posthog/code --search "<query>" --state open --limit 5 --json number,title,url,labels,updatedAt,body
```

Combine and deduplicate results across all queries.

### Step 3: Evaluate matches

**If matching issues were found**, display them ranked by relevance. Use this exact format:

```
## Found <N> matching issues

**1. #<number>** - <url>
Title: <title>
Labels: `<label1>` `<label2>`
Updated: <relative date>
Body:
<first 2-3 sentences of the issue body, truncated with "..." if longer>

**2. #<number>** - <url>
...
```

Then stop. Do NOT offer to create a new issue. Let the user decide.

**If no matching issues were found**, continue to Step 4.

### Step 4: Draft a new issue

Generate issue metadata from the Slack conversation:

- **Title**: Short, specific, under 80 characters. Describe the problem not the symptom.
- **Description**: Pick the shape that fits the issue. Only include sections that are actually applicable.
  - **Bug**: `Problem` (what is broken), `Expected behavior` (what should happen instead), `Steps to reproduce` (only if mentioned in the thread).
  - **Enhancement or feature request**: `Description` (what is being asked for and why it matters), `Proposed solution` (only if one was suggested in the thread). Do not frame it as a "Problem" and do not include `Expected behavior` or `Steps to reproduce`.
  - **Task or chore**: `Context` (why this is needed), `Scope` (what should be done).
  Omit any section you have no real content for. Do not include empty headings.
- **Labels**: Pick from the repo's existing labels. Run `gh label list --repo posthog/code --limit 50 --json name` to get available labels. Pick 1-3 that fit. If none fit well, use none.

### Step 5: Preview and confirm

Show the user exactly what will be created:

```
## New issue preview

**Title**: <title>
**Labels**: <labels>

**Description**:
<full description body>
```

Then ask: **Create this issue? (y/N)**

- **If y**: Create it with `gh issue create --repo posthog/code --title "<title>" --body "<body>" --label "<label1>,<label2>"` and display the resulting URL.
- **If N or no response**: Do nothing. Tell the user they can adjust and re-run.

Do NOT create the issue without explicit confirmation.
