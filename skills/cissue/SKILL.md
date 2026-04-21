---
name: cissue
description: Paste Slack messages to find a matching GitHub issue or create a new one
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
user-invocable: true
arguments: slack-messages
argument-hint: "<pasted slack messages>"
---

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

**If matching issues were found**, display them ranked by relevance:

```
## Existing issues

### 1. <title>
**#<number>** · <state> · Updated <relative date e.g. "3 days ago">
<url>
Labels: `<label1>` `<label2>`

<first 2-3 sentences of the issue body, truncated with "..." if longer>

---

### 2. ...
```

Then stop. Do NOT offer to create a new issue. Let the user decide.

**If no matching issues were found**, continue to Step 4.

### Step 4: Draft a new issue

Generate issue metadata from the Slack conversation:

- **Title**: Short, specific, under 80 characters. Describe the problem not the symptom.
- **Description**: Structured as:
  - **Context**: Where this came up (Slack thread summary, who raised it)
  - **Problem**: What is broken or missing
  - **Expected behavior**: What should happen instead
  - **Steps to reproduce**: If any were mentioned in the thread
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
