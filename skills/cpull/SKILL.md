---
name: cpull
description: Pull all PR comments from GitHub (bots and humans), generate responses and code fixes, then optionally reply and resolve
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, Agent
user-invocable: true
arguments: pr-url-or-mode
argument-hint: "[<github pr url>] [each]"
---

## Writing conventions

- No em dashes. Use hyphens, commas or separate sentences instead.
- No Oxford commas (no comma before "and" in lists).
- English only.

## Instructions

You are processing PR review comments. Pull every unresolved comment (from bots and humans), generate a response and a code fix for each, print them to the console, then optionally apply changes and post replies.

Parse `$ARGUMENTS` for:
- A GitHub PR URL matching `github.com/.+/pull/\d+`. If absent, use the open PR for the current branch.
- The literal `each` flag. If present, ask y/N for each comment instead of batching at the end.

### Step 1: Resolve target PR

**If a PR URL was provided:**
- Extract `<owner>`, `<repo>`, `<number>` from the URL.

**If no URL was provided:**
- Find the open PR for the current branch:
  ```
  gh pr view --json number,url,title,headRefName,baseRefName,headRepository,baseRepository
  ```
- If no open PR exists, stop and tell the user.

### Step 2: Get viewer identity

Used to filter out the user's own comments:
```
gh api user --jq .login
```

### Step 3: Fetch comments and review threads

Run these in parallel:

**Inline review threads (line comments grouped, with resolution state):**
```
gh api graphql -f query='
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first: 50) {
            nodes {
              id
              author { login }
              body
              diffHunk
              createdAt
            }
          }
        }
      }
    }
  }
}' -f owner=<OWNER> -f repo=<REPO> -F number=<NUMBER>
```

**Top-level PR conversation comments:**
```
gh api repos/<OWNER>/<REPO>/issues/<NUMBER>/comments --paginate
```

**Review summaries (the body of a submitted review):**
```
gh api repos/<OWNER>/<REPO>/pulls/<NUMBER>/reviews --paginate
```

### Step 4: Filter to actionable comments

Skip:
- Anything authored by the viewer
- Resolved threads (`isResolved: true`)
- Outdated threads with no recent activity
- Empty bodies
- Review summaries with state `APPROVED` and no body

Mark bot comments. A login is a bot if it ends in `[bot]` or matches: `coderabbitai`, `graphite-app`, `vercel`, `claude`, `dependabot`, `renovate`, `codecov`.

### Step 5: Fan out subagents

Fan out one parallel subagent (using the Agent tool, subagent_type: `general-purpose`) per actionable comment in a single response. For PRs with many comments, batch ~5 comments per subagent instead of spawning one per comment.

Each subagent processes its assigned comment(s):

> You are processing PR review comments. For each comment below:
>
> 1. If inline, read the file at `<path>` with 10 lines of context around `<line>` (fall back to `<originalLine>` if line is null because the diff moved). Use the `diffHunk` to find the right spot if the line moved.
> 2. Classify the action:
>    - **change**: the comment is right, fix the code
>    - **reply**: needs a written response (a question, clarification or push-back)
>    - **both**: change the code and explain in a reply
>    - **dismiss**: bot false positive or stale, resolve without replying
> 3. Draft a short reply (1-3 sentences, conversational, no fluff). For bot false positives, the reply explains why the suggestion is wrong before dismissing.
> 4. If action is `change` or `both`: draft the exact code change as before/after.
>
> **Comments to process**:
> - Comment `<i>`: author `<login>`, type `<inline|top-level|review-summary>`, location `<file>:<line>`, body `<body>`, diffHunk `<diffHunk>`
> - ...
>
> Return for each comment: action, reply text (or "(none)" for dismiss), code change as before/after diff (or "(none)"), and the 5-line code context around the target with the target line marked `>>>`.

Wait for all subagents to complete before proceeding.

### Step 6: Print to console

Lead with a header:

```
## PR #<number>: <title>
<url>

Found <N> unresolved comments (<X> inline, <Y> top-level, <Z> reviews).
```

Then for each comment:

```
---

### Comment <i> of <N>
**Author**: <login> <(bot)>
**Type**: inline | top-level | review-summary
**Location**: <file>:<line>  (inline only)
**Posted**: <relative date>

**Comment**:
> <body, indented as quote>

**Code context** (inline only):
```<lang>
<5 lines around the target line, target marked with >>>
```

**Action**: change | reply | both | dismiss

**Reply**:
<drafted reply, or "(none)" for dismiss>

**Code change** (change or both):
File: <path>
```diff
- <before>
+ <after>
```
```

### Step 7: Apply (optional)

**If `each` was passed**: after printing each comment, ask `Apply this one? (y/N)`. Act per-comment as you go.

**Otherwise (default)**: after printing all comments, ask:

```
Apply all changes and post replies on GitHub? (y/N)
```

**If N or no answer**: stop. Tell the user they can re-run with `each` for per-comment confirmation.

**If y**:
1. Apply all `change` and `both` edits with Edit
2. Post replies:
   - Inline thread reply:
     ```
     gh api graphql -f query='mutation($threadId: ID!, $body: String!) {
       addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) {
         comment { id }
       }
     }' -f threadId=<THREAD_ID> -f body="<reply>"
     ```
   - Top-level reply: `gh pr comment <PR> --body "<reply>"`
   - Review summary reply: `gh pr comment <PR> --body "<reply>"`
3. Resolve each inline thread with action `change`, `both` or `dismiss`:
   ```
   gh api graphql -f query='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { id } } }' -f id=<THREAD_ID>
   ```
4. Report counts: replies posted, threads resolved, files edited

Do NOT commit or push. The user decides when to commit.
