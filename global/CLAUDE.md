# Global Rules

- **Current date**: 2026-02-27
- **Language**: English only. All code, comments, docs, examples, commits, configs, errors and tests.
- **Style**: Prefer self-documenting code over comments. Use clear names instead of explanatory comments.
- **Comments**: Default is zero comments. Code must be self-explanatory; if it needs a comment to be understood, rewrite it with better names until it doesn't. Never write comment blocks: no multi-line explanations, no JSDoc or docstring headers on ordinary code, no banners, no section dividers, no step-by-step narration, no comments restating what the code does. A comment is a last resort: one line, only for a *why* the code can't express (non-obvious tradeoff, workaround, external constraint). This cap holds even in comment-heavy files: surrounding density is never a license to add more, and in a file with no comments add none.
- **Tools**: Use `rg` not `grep`, `fd` not `find`, `bat` not `cat`, `delta` for diffs, `fzf` for fuzzy search. `tree` is installed.
- **Inclusive terms**: allowlist/blocklist, primary/replica, placeholder/example, main branch, conflict-free, concurrent/parallel.

## Writing

Applies to everything I read or ship: docs, comments, commit and PR text, Slack, chat replies. Write so it doesn't read as AI-generated.

- **No em or en dashes**. Use a comma, period, colon or parentheses, or rewrite the sentence.
- **No Oxford comma**. No comma before the final "and" or "or" in a list.
- **Straight quotes and apostrophes only**, never curly or smart ones.
- **No antithesis templates** like "it's not just X, it's Y", "not only X but also Y" or "this isn't about X, it's about Y".
- **No inflated vocab**: delve, leverage, robust, seamless, elevate, boast, underscore, testament, realm, tapestry, landscape, navigate, intricate, crucial, pivotal, harness, foster, unlock, empower.
- **No throat-clearing or hedging**: "it's worth noting that", "it's important to note", "in today's fast-paced world".
- **No filler transitions** opening a sentence: "Moreover", "Furthermore", "Additionally".
- **No wrap-up lines** like "In conclusion", "Overall" or "In summary" unless I ask.
- **No forced rule-of-three** triads when one or two items carry the point.
- **No emoji** unless I use them first.

## Git

- **Branches**: Conventional prefix `<type>/<short-description>`. Types: feat, fix, docs, style, refactor, test, chore, perf.
- **PR titles**: Conventional format `<type>(<scope>): <subject>` (e.g., `feat(auth): Add token refresh on expiry`).
- **PR template**: When I ask for a PR, check the repo for a template (`.github/PULL_REQUEST_TEMPLATE.md` or `.github/PULL_REQUEST_TEMPLATE/`) and fill out every section. Don't write a freeform description when a template exists.
- **Commits**: Plain imperative subject, 50 chars max ("add login page" not "added login page"). No type prefixes. No period. Single-line only unless I ask otherwise. No attribution. Title only, no commit body or description.
- **Stacked PRs**: I use Graphite (`gt`). Always diff against the parent branch, not trunk. Use `gt branch info` to find the parent.
- **Atomic commits**: One logical change per commit. Split if addressing different concerns.

## Code

- **Prefer simple over clever**. Write the obvious solution first. Don't abstract until there's a real reason.
- **No barrel files** (index.ts). Import directly from source.
- **No console.log**. Use a scoped logger.
- **TypeScript strict mode**. No `any` casts unless unavoidable.
- **Prefer writing your own solution** over adding a package when the fix is simple.
- **Biome** for linting and formatting, not ESLint/Prettier.
- **pnpm** for package management. Monorepos use pnpm workspaces + turbo.

## Workflow

- Run checks in parallel when possible (typecheck, lint, test are independent).
- Don't commit, push or create PRs unless I explicitly say to. Every action requires explicit instruction every time. Saying "commit this" once does not grant permission for future commits or pushes in the same session.
- When I say "commit this" just do it. Don't ask for confirmation. But only commit. Don't push unless I also say push.
