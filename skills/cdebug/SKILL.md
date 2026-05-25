---
name: cdebug
description: Triage a bug report - find the root cause, explain why it's happening and offer a fix
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Agent
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

### Step 3: Form hypotheses

From the symptom and the code located in Step 2, form 2-4 plausible hypotheses for where the bug originates. Examples:
- "The data is wrong at the source"
- "A transform between layers is dropping or mangling a field"
- "The component is rendering stale state"
- "A race condition between subscriptions"
- "A null/undefined is sneaking past a missing check"

Hypotheses should be specific enough to investigate, not vague ("something is wrong somewhere"). If you only have one hypothesis, that's fine, skip to Step 5 and trace directly.

### Step 4: Fan out subagents

Fan out one parallel subagent (using the Agent tool, subagent_type: `general-purpose`) per hypothesis in a single response. Each subagent investigates its hypothesis independently:

> You are investigating a specific hypothesis for the following bug.
>
> **Bug symptom**: <symptom from Step 1>
>
> **Hypothesis to test**: <hypothesis>
>
> **Starting points**:
> - <relevant file paths from Step 2>
> - <relevant function/component names>
>
> Steps:
> 1. Read every file in the relevant chain in full (not just diffs).
> 2. Follow the data flow: component -> hook -> store -> tRPC -> router -> service.
> 3. Identify where the actual value diverges from the expected value.
> 4. Check for race conditions, stale closures, missing null checks and incorrect assumptions.
>
> Return:
> - **Verdict**: confirmed | refuted | inconclusive
> - **Evidence**: specific `<file>:<line>` locations with quoted snippets
> - **If confirmed**: the exact line(s) causing the bug and a one-sentence explanation of why they cause the symptom

Wait for all subagents to complete.

### Step 5: Identify the root cause

Pick the hypothesis with the strongest confirmed evidence. Narrow down to the specific line(s). Explain:
- **Where**: The exact file and line
- **What**: What the code is doing wrong
- **Why**: Why this causes the symptom the user described

If no hypothesis was confirmed, form new hypotheses informed by the subagent findings and return to Step 4.

### Step 6: Check for related issues

Search for other places in the codebase with the same pattern. If the bug is caused by a common mistake, note all instances.

### Step 7: Output

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
