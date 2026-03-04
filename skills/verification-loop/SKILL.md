---
name: verification-loop
description: Run a verification loop on the current branch — build, typecheck, lint, test, security scan and code review before PR
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Task
---

## Instructions

Run a full verification loop on the current branch. This is a pre-PR gate that catches issues across build, types, lint, tests, security and code quality in one pass.

**Run all independent checks in parallel where possible. Stop early if a phase produces blocking failures.**

### Phase 0: Setup

1. Detect the parent branch:
   - Run `gt branch info` to check if Graphite manages this branch
   - If Graphite is available, use the parent branch from `gt branch info`
   - Otherwise use `git merge-base HEAD origin/main`
2. Detect the project toolchain by reading `package.json`, `tsconfig.json`, `pyproject.toml` or equivalent config files
3. Check for uncommitted changes with `git status` and `git diff` — warn if the working tree is dirty

### Phase 1: Build

Run the project's build command (e.g., `pnpm build`, `pnpm turbo build`, `cargo build`).

- **If build fails: STOP.** Report the errors and skip all remaining phases. Nothing else matters until it compiles.

### Phase 2: Parallel checks

Run these in parallel — they are independent of each other:

#### Typecheck
- Run `pnpm tsc --noEmit` (or project equivalent)
- Report any type errors with file and line references

#### Lint
- Run `pnpm biome check .` (or project equivalent)
- Report violations — skip style/formatting noise, focus on logic and correctness rules

#### Tests
- Run the project's test command (e.g., `pnpm test`, `pnpm vitest run`)
- Report failures with test name and assertion details
- If coverage is available, note any changed files below 80% coverage

#### Security scan
Scan the diff (`git diff <parent>...HEAD`) and changed files for:
- Hardcoded secrets, API keys, tokens or credentials
- `console.log` / `print` statements left in production code
- Disabled security features (CORS wildcards, auth bypasses)
- Known vulnerable patterns (SQL concatenation, `innerHTML`, `eval`, `dangerouslySetInnerHTML` without sanitization)
- `.env` files or secrets in committed files

### Phase 3: Code review

Review the **holistic diff** of the branch against its parent. Treat the branch as one atomic changeset — do NOT analyze individual commits.

1. Run `git diff <parent>...HEAD`
2. Read each changed file in full for surrounding context
3. Analyze for correctness, security, performance, readability and adherence to project conventions (see CLAUDE.md)

Categorize findings:

#### Critical
Must fix before merging:
- Bugs, logic errors, race conditions
- Security vulnerabilities (XSS, injection, leaked secrets)
- Data loss risks
- Breaking changes to public APIs

#### Suggestions
Should improve but not blocking:
- Performance improvements
- Better error handling
- Missing edge cases
- Code clarity / naming

#### Nits
Minor preference items:
- Naming tweaks
- Minor restructuring

#### Praise
Call out things done well. Good patterns, clean abstractions, thoughtful error handling.

### Phase 4: Test coverage assessment

For each changed file:
1. Find existing tests (colocated `*.test.*` files, `tests/` or `__tests__/` directories)
2. Check whether new or modified code paths are exercised by existing tests
3. Flag untested business logic, utilities, state transitions, error paths and complex conditionals
4. Skip test suggestions for: trivial glue code, type-only changes, config files and pure layout with no logic

### Phase 5: Report

Output a structured report:

```
## Verification Report

### Status: READY / NOT READY

| Check      | Status | Details          |
|------------|--------|------------------|
| Build      | pass/fail | ...           |
| Types      | pass/fail | N errors      |
| Lint       | pass/fail | N violations  |
| Tests      | pass/fail | N/M passing   |
| Security   | pass/fail | N issues      |
| Review     | pass/fail | N critical    |

### Critical Issues
(list with file:line, code snippet, explanation and fix)

### Suggestions
(list with file:line and recommendation)

### Nits
(list)

### Praise
(list)

### Test Coverage
- Changed files and whether they have corresponding tests
- Specific untested code paths
- Concrete test cases that would add the most value

### Verdict: Ship it / Needs changes / Needs discussion
```

The overall status is **NOT READY** if any of: build fails, critical review issues exist or tests fail. Everything else is advisory.
