---
name: ctest
description: Generate a colocated test file for a given source file following project conventions
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
user-invocable: true
arguments: file-path
---

## Instructions

Generate a test file for the given source file. The file path is provided as an argument (e.g., `/ctest apps/twig/src/renderer/stores/themeStore.ts`).

### Step 1: Analyze the target file

1. Read the target file completely
2. Determine its type:
   - **Store** — Zustand store (`create<...>()`)
   - **Service** — Injectable class (`@injectable()`)
   - **Component** — React component (exports JSX)
   - **Utility** — Pure functions / helpers
   - **Router** — tRPC router (`router({...})`)

### Step 2: Read existing test examples

Read 1-2 existing test files of the **same type** to match conventions:
- Search with `Glob` for `*.test.ts` or `*.test.tsx` near similar files
- Also read test helpers:
  - `apps/twig/src/test/setup.ts`
  - `apps/twig/src/test/utils.tsx`
  - `apps/twig/src/test/fixtures.ts`

### Step 3: Generate the test file

Create a colocated test file next to the source file (e.g., `themeStore.test.ts`).

Follow these patterns based on file type:

**Store tests:**
- `localStorage.clear()` and `useStore.setState({...})` in `beforeEach`
- Test state transitions via `useStore.getState().action()`
- Test persistence if the store uses `persist` middleware

**Service tests:**
- Mock DI dependencies with `vi.fn()`
- Use `vi.hoisted()` for complex module mocks
- Test public methods in isolation

**Component tests:**
- Use `renderWithProviders()` from test utils
- Mock tRPC calls and store state
- Test user interactions and rendered output

**Utility tests:**
- Direct function call tests
- Edge cases and boundary values

**General patterns:**
- Use `vi.hoisted()` for mocks that need hoisting
- Use `vi.mock()` for simple module mocks
- Use `vi.stubGlobal("fetch", mockFetch)` for fetch mocking
- `describe` / `it` blocks with clear names
- Follow the Arrange / Act / Assert pattern

### Step 4: Run and verify

Run the test to verify it passes:

```bash
pnpm --filter twig test -- <test-file-path>
```

If tests fail, fix the issues and re-run until they pass.

### Step 5: Output

Show a summary of what was tested and the test file path.
