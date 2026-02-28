---
name: cdebug
description: Triage a bug report - find the root cause, explain why it's happening and offer a fix
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Task
user-invocable: true
arguments: bug-description
---

## Instructions

You are triaging a bug. The description is in `$ARGUMENTS` (could be an error message, a user report, a stack trace or a description of unexpected behavior).

### Step 1: Understand the symptom

Parse the bug description. Identify:
- **What's happening** (the symptom)
- **What should happen** (expected behavior, if stated)
- **Any error messages or stack traces**
- **Any file paths, component names or function names mentioned**

### Step 2: Locate the code

Use the symptom to find the relevant code:
- Search for error messages, function names or component names with `Grep`
- If a stack trace is provided, read every file in the trace
- If it's a UI issue, find the component and trace its data source
- If it's a data issue, trace the tRPC call from renderer to service using the router

### Step 3: Trace the flow

Starting from where the bug manifests, trace backwards through the code:
- Read every file in the chain, not just the diffs
- Follow the data flow: component -> hook -> store -> tRPC -> router -> service
- Look for where the actual value diverges from the expected value
- Check for race conditions, stale closures, missing null checks and incorrect assumptions

### Step 4: Identify the root cause

Narrow down to the specific line(s) causing the bug. Explain:
- **Where**: The exact file and line
- **What**: What the code is doing wrong
- **Why**: Why this causes the symptom the user described

### Step 5: Check for related issues

Search for other places in the codebase with the same pattern. If the bug is caused by a common mistake, note all instances.

### Step 6: Output

```
## Root cause

<file>:<line> - <one sentence explanation>

## Why this happens

<2-3 sentences explaining the chain of events from trigger to symptom>

## Fix

<the specific code change needed, with before/after>

## Related

<any other files with the same pattern, or "None found">
```

Do NOT apply the fix. Just explain it and let the user decide.
