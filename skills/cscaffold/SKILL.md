---
name: cscaffold
description: Scaffold a new Twig feature with service, router, store, and DI wiring
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
user-invocable: true
arguments: feature-name
---

## Instructions

Scaffold a new feature for the Twig desktop app. The feature name is provided as an argument (e.g., `/cscaffold notifications`).

### Step 0: Read existing examples

Before creating any files, read existing examples to match current conventions exactly:

1. Read one existing service (e.g., `apps/twig/src/main/services/`) — pick a simple one
2. Read the DI tokens file (`apps/twig/src/main/di/tokens.ts`)
3. Read the DI container file (`apps/twig/src/main/di/container.ts`)
4. Read one existing tRPC router (`apps/twig/src/main/trpc/routers/`)
5. Read the root router (`apps/twig/src/main/trpc/router.ts`)
6. Read one existing renderer store (`apps/twig/src/renderer/features/` or `apps/twig/src/renderer/stores/`)

Match the patterns you see — imports, naming, structure, decorators, etc.

### Step 1: Create main process service

Create `apps/twig/src/main/services/<name>.ts`:
- Import `injectable` from `inversify`
- Extend `TypedEventEmitter` with a `<Name>ServiceEvents` interface
- Add a basic event type enum `<Name>ServiceEvent`
- Include a placeholder public method

### Step 2: Add DI token

Add a new token to `apps/twig/src/main/di/tokens.ts`:
```typescript
<Name>Service: Symbol.for("<Name>Service"),
```

### Step 3: Add container binding

Add to `apps/twig/src/main/di/container.ts`:
```typescript
container.bind<Name>Service>(MAIN_TOKENS.<Name>Service).to(<Name>Service).inSingletonScope();
```

### Step 4: Create tRPC router

Create `apps/twig/src/main/trpc/routers/<name>.ts`:
- Use the `getService` pattern: `const getService = () => container.get<...>(MAIN_TOKENS.<Name>Service)`
- Add one placeholder query procedure
- Add one placeholder subscription (if the service has events)
- Use Zod schemas for input/output

### Step 5: Register router

Edit `apps/twig/src/main/trpc/router.ts`:
- Import the new router
- Add it to the `appRouter` definition

### Step 6: Create renderer feature directory

Create the following structure:
```
apps/twig/src/renderer/features/<name>/
├── components/     (empty dir — create a .gitkeep)
├── hooks/          (empty dir — create a .gitkeep)
└── stores/
    └── <name>Store.ts
```

The store should follow Zustand conventions:
- Separate `State` and `Actions` interfaces
- Combined `Store` type
- Use `create<Store>()` with appropriate middleware
- Add a scoped logger

### Step 7: Output summary

List all created/modified files and explain the wiring:
```
Created:
  - apps/twig/src/main/services/<name>.ts (service)
  - apps/twig/src/main/trpc/routers/<name>.ts (router)
  - apps/twig/src/renderer/features/<name>/stores/<name>Store.ts (store)
  - apps/twig/src/renderer/features/<name>/components/.gitkeep
  - apps/twig/src/renderer/features/<name>/hooks/.gitkeep

Modified:
  - apps/twig/src/main/di/tokens.ts (added token)
  - apps/twig/src/main/di/container.ts (added binding)
  - apps/twig/src/main/trpc/router.ts (registered router)
```
