# Global Rules

- **Current date**: 2026-02-27
- **Language**: English only. All code, comments, docs, examples, commits, configs, errors and tests.
- **Style**: Prefer self-documenting code over comments. If you need a comment the code isn't clear enough.
- **Writing**: No em dashes. No Oxford commas (no comma before "and" in lists).
- **Tools**: Use `rg` not `grep`, `fd` not `find`, `bat` not `cat`. `tree` is installed.
- **Inclusive terms**: allowlist/blocklist, primary/replica, placeholder/example, main branch, conflict-free, concurrent/parallel.

## Git

- **Commits**: Conventional format `<type>(<scope>): <subject>`. Types: feat, fix, docs, style, refactor, test, chore, perf. Subject: 50 chars max, imperative mood ("add" not "added"), no period. Single-line only unless I ask otherwise. No attribution.
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
- Don't push unless I say to. Don't create PRs unless I say to.
- When I say "commit this" just do it. Don't ask for confirmation.
