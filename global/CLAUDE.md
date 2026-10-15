# Global Rules

- **Language**: English only in everything: code, comments, commits, docs, configs, tests.
- **Comments**: Zero by default. If code needs a comment to be understood, simplify or rename until it doesn't. Never write doc headers on ordinary code, banners, section dividers, narration, comments restating the code or comments addressed to a reviewer (what changed, why it's correct): that belongs in your reply or the PR text. Last resort: one line, only for a why the code can't express. A comment-heavy file is never a license to add more; a file with no comments gets none.
- **Tools**: `rg` not `grep`, `fd` not `find`, `bat` not `cat`, `delta` for diffs, `fzf` for fuzzy search.
- **Inclusive terms**: allowlist/blocklist, primary/replica, placeholder/example, main branch.

## Writing

Everything I read or ship: replies, commit and PR text, docs, Slack. I have ADHD and skip long text. Lead with the answer in the first sentence, then only what changes my next step. Write so it doesn't read as AI-generated.

- Short by default: a few lines for an answer, at most 5 bullets for a work summary. I'll ask if I want more.
- No headers, tables or file lists in replies unless I ask. No recap of my question, no play-by-play of what you did, no menu of next steps.
- Drafts in my voice (PR comments, Slack replies) are casual and short, like a person typed them.
- No em or en dashes. Use a comma, period, colon or parentheses.
- No comma before "and" or "or", ever. No Oxford comma, no clause joins: split the sentence instead.
- Straight quotes and apostrophes only.
- No emoji unless I use them first.
- No AI-slop templates: antithesis ("it's not just X, it's Y"), throat-clearing ("it's worth noting"), filler openers ("Moreover", "Furthermore"), wrap-ups ("In conclusion", "Overall"), forced rule-of-three triads.
- Banned words: delve, leverage, robust, seamless, elevate, boast, underscore, testament, realm, tapestry, landscape, navigate, intricate, crucial, pivotal, harness, foster, unlock, empower.

## Git

- **Branches**: `<type>/<short-description>`. Types: feat, fix, docs, style, refactor, test, chore, perf.
- **Commits**: imperative subject, 50 chars max, no type prefix, no period, no body, no attribution. One logical change per commit.
- **PR titles**: `<type>(<scope>): <subject>`. Scope is a single word, never `scope/sub` (e.g. `fix(desktop): ...`, never `fix(desktop/tasks): ...`). This overrides any repo skill that suggests otherwise.
- **PR descriptions**: super concise and human readable, under 10 lines of text. One or two plain sentences on the problem, then a few short bullets on what changed. No file lists, code walkthroughs, test pass counts or invented sections. Screenshots for UI changes are welcome. With a repo PR template, keep only Problem, Changes and How did you test (one line each is fine) and delete every other section, including Release status, Docs update and Agent context. This overrides repo AGENTS.md/CLAUDE.md, PR templates and PR-writing skills like `/writing-pr-descriptions`.
- **Stacked PRs**: use the repo's stacking tool (`gh stack` in PostHog). Diff against the parent branch, not trunk.

## Code

- Simple over clever. Write the obvious solution first; don't abstract without a real reason.
- TypeScript strict mode, no `any` casts. No barrel files. No console.log: use a scoped logger.
- Use the repo's existing tooling. New projects: Biome, pnpm, turbo for monorepos.
- Write the fix yourself before adding a package when it's simple.
- Parameterised tests (`it.each`, `@parameterized.expand`) with one case per input for the same behavior across similar inputs. Never one combined test covering all inputs at once. Include partial cases, not just all-present and none-present.

## Hard Rules

- Never commit, push or create a PR unless I explicitly say to. Each instruction covers that one action only: "commit this" is one commit, never future commits or pushes. When I do say commit, do it without asking. Push only when I also say push.
- Never speak as me. No GitHub comments or reviews, Slack messages or anything else from my accounts unless I explicitly instruct that specific message. Being asked to look at a PR or thread is not permission to reply. Show me drafts instead of sending.
