---
name: cbrief
description: Brief me on a PR or branch before I review it. Architecture context, the few things worth flagging and which files to read closely
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Write
argument-hint: "[PR URL or number, defaults to the current branch]"
---

## Instructions

Write a short briefing that orients the reviewer before they open the diff: where the change sits in the system, the few things a human reviewer would flag and which files deserve a close read.

The reader has ADHD and skips long text. Noise is the failure mode. A line earns its place only if the reviewer would be worse off without it. When in doubt, cut it.

This is not a full review. No verdict, no nits, no style feedback, no praise. `/creview` does that.

### Step 1: Resolve the target

**PR URL or number in `$ARGUMENTS`:** work from the fetched head. Never check out the PR branch. The working tree stays untouched.

```bash
gh pr view <pr> --json number,title,body,url,author,baseRefName,headRefOid,additions,deletions,changedFiles,labels,closingIssuesReferences
git fetch -q origin <baseRefName>
git fetch -q origin pull/<number>/head
```

The range is `origin/<baseRefName>...<headRefOid>`. Read files at the head with `git show <headRefOid>:<path>` and search it with `git grep -n <symbol> <headRefOid>`.

If the current directory is not a clone of the PR's repo, skip the fetches. Take the file list from `gh pr view <pr> --json files`, the diff from `gh pr diff <pr>` and file contents from `gh api "repos/<owner>/<repo>/contents/<path>?ref=<headRefOid>" -H "Accept: application/vnd.github.raw"`.

**No argument:** brief the current branch. The parent is the open PR's base (`gh pr view --json baseRefName -q .baseRefName`), otherwise the fork point from the default branch (`git merge-base HEAD "$(git symbolic-ref --short refs/remotes/origin/HEAD)"`). The range is `<parent>...HEAD`. If the branch has a PR, fetch the same metadata as above.

### Step 2: Sort the files

```bash
git diff --numstat -M <range>
```

Put every changed file in exactly one bucket:

- **Source**: code and config that changes behavior. Includes migrations, schemas, feature flag definitions, CI workflows and deploy config.
- **Tests**: test files, fixtures, mocks, test helpers, e2e specs and Storybook stories.
- **Skip**: lockfiles, generated code and types, snapshots, vendored code, docs, pure renames or moves, formatting-only changes and large data files.

A pure rename shows as `0 0` with `old => new`. When the path alone doesn't settle the bucket, look at the hunk.

### Step 3: Read

Read in this order so a huge PR stays manageable:

1. The PR description, any linked issues (`gh issue view <number> --repo <owner>/<repo> --json title,body`) and any docs the PR changes. Treat them as the author's claim, not as fact.
2. The source diff only: `git diff <range> -- <source files>`.
3. One hop around the diff. For each file that carries real logic, read enough of it at the head to know what the changed code belongs to. Find the direct callers and direct callees of the changed functions, then stop.
4. The test diff last: `git diff <range> -- <test files>`. Read it for which behaviors it pins down, not line by line.
5. The rest of the skip bucket: numstat only. Never read it.

### Step 4: Decide what is worth flagging

A flag is something a careful human reviewer would stop and leave a comment on:

- a likely bug or a broken edge case
- data loss or a security or privacy exposure
- a breaking change to an API, schema or contract that other code depends on
- the diff doing something the description doesn't mention, or not doing something it claims
- risky logic that no test exercises

Not flags: style, naming, small refactors, missing tests for trivial code, anything that "looks intended", anything that is probably fine and general observations.

Do the homework before flagging. If a grep or one more file read can settle a doubt, settle it. Keep the flag only if the problem is real, or if you still can't tell and being wrong would be expensive. Never hand the reviewer a question you could have answered yourself.

Max 3 flags, most serious first. Zero is a good outcome. Most PRs have nothing worth flagging.

### Step 5: Write the report

Use this structure and nothing more:

```markdown
# <title> (#<number>)

<PR url> · <author login> · +<additions> -<deletions> · <files> source, <files> test, <files> skip

**TL;DR** <what changes and why, two sentences max>

## Architecture
- <where the change sits and which boundaries it crosses>

`<entry point> -> *<changed piece>* -> <downstream>`

## Worth flagging
- [`<path>:<line>`](<link>R<line>) <the problem and what it would break>

## Read closely
1. [`<path>`](<link>) <why, under 12 words>
```

What goes in each section:

- **TL;DR**: the change from outside the code. What a user, customer or operator sees or can do differently. Name any flag or rollout gate. If nothing is user-visible, say "Internal only" and say who benefits.
- **Architecture**: which services, layers or modules the change touches and how data or control moves through them. Call out every boundary it crosses: API contracts, database schema and migrations, queues, caches, feature flags, new dependencies and cross-service calls. End with one flow line and mark the changed pieces with `*`. Max 5 bullets.
- **Worth flagging**: the flags from step 4. One sentence each: state the problem plainly and what it would break. If there are none, write "Nothing worth flagging."
- **Read closely**: only the source files where the real logic or risk lives, ordered by how the change flows. Max 5. Do not list anything else: no skim list, no test list, no skip list. The counts in the header cover those.

Rules:

- Describe what the diff does, not what the description says it does.
- The whole report stays under 25 lines. For a PR under about 50 changed source lines, Architecture shrinks to the flow line.
- With a PR, link every file to its diff on GitHub: `<PR url>/files#diff-<sha256 of the path>`. Without a PR, write plain `path:line` and no links.
- As link text, show the shortest path that is unambiguous within the PR, not the full path.
- Every line number is a new-side number from the file at the head. Confirm it with `git grep -n` or `git show <headRefOid>:<path>` before writing it and never estimate. In "Worth flagging", append `R<line>` to the link so it opens on that line.

Get the hashes for the files you link:

```bash
git diff --name-only <range> | while IFS= read -r p; do
  printf '%s %s\n' "$(printf '%s' "$p" | shasum -a 256 | cut -c1-64)" "$p"
done
```

### Step 6: Save and print

Make a temp dir with `mktemp -d` and write the report to `<dir>/brief-<number>.md`, or `<dir>/brief.md` when there is no PR.

Print the report, then one line with the file path. Nothing else.
