---
name: clogs
description: Find all Claude/Twig log files for a session from a pasted log snippet
argument-hint: "<pasted log line with sessionId/taskRunId/cwd>"
allowed-tools:
  - Bash(ls *)
  - Bash(find *)
  - Bash(du *)
  - Bash(wc *)
  - Bash(stat *)
  - Read
  - Glob
  - Grep
---

# Find Claude/Twig Session Logs

Given a pasted log snippet, extract identifiers and locate all related log files across every known storage location.

## Step 1: Extract identifiers from `$ARGUMENTS`

Parse the pasted text to extract any of these fields (they may not all be present):

- `sessionId` — UUID (e.g. `019c8e11-1815-7341-972d-ec7a175fb093`)
- `taskRunId` — UUID (e.g. `a9ab141b-f111-4263-87e8-842e6185df53`)
- `cwd` — working directory path (e.g. `/Users/charlesvien/Cloud/posthog-unity`)

If only a raw UUID is pasted with no labels, treat it as a `sessionId`.

## Step 2: Derive search paths

The Twig Electron app stores Claude config at a custom `CLAUDE_CONFIG_DIR`:

```
~/Library/Application Support/@posthog/twig-dev/claude/   (dev)
~/Library/Application Support/@posthog/Twig/claude/       (prod)
```

The `cwd` determines the project subdirectory under `projects/`. The project path is the cwd with `/` replaced by `-` and prefixed with `-`. For example:
- cwd `/Users/charlesvien/Cloud/posthog-unity` becomes `-Users-charlesvien-Cloud-posthog-unity`

### Known log locations

| Log Type | Path Pattern |
|---|---|
| SDK transcript (dev) | `~/Library/Application Support/@posthog/twig-dev/claude/projects/{projectPath}/{sessionId}.jsonl` |
| SDK transcript (prod) | `~/Library/Application Support/@posthog/Twig/claude/projects/{projectPath}/{sessionId}.jsonl` |
| SDK debug (dev) | `~/Library/Application Support/@posthog/twig-dev/claude/debug/{sessionId}.txt` |
| SDK debug (prod) | `~/Library/Application Support/@posthog/Twig/claude/debug/{sessionId}.txt` |
| Twig session logs | `~/.twig/sessions/{taskRunId}/logs.ndjson` |
| Electron logs (dev) | `~/Library/Logs/twig-dev/` |
| Electron logs (prod) | `~/Library/Logs/Twig/` |

## Step 3: Search for files

1. If `sessionId` is available:
   - Check both dev and prod SDK transcript paths. If `cwd` is known, check the exact project path first. If not, use `find` to search across all project directories for `{sessionId}.jsonl`.
   - Check both dev and prod SDK debug paths for `{sessionId}.txt`.

2. If `taskRunId` is available:
   - Check `~/.twig/sessions/{taskRunId}/logs.ndjson`

3. If neither yields results, do a broader search:
   ```bash
   find ~/Library/Application\ Support/@posthog/twig-dev/claude -name "*{sessionId}*" 2>/dev/null
   find ~/Library/Application\ Support/@posthog/Twig/claude -name "*{sessionId}*" 2>/dev/null
   ```

For each file found, get the file size with `du -h` or `stat`.

## Step 4: Present results

Output a markdown table with all found files:

```
| Type | Path | Size | Status |
|------|------|------|--------|
| SDK transcript | ~/Library/Application Support/.../{sessionId}.jsonl | 1.6KB | Found |
| Twig logs | ~/.twig/sessions/{taskRunId}/logs.ndjson | 23KB | Found |
| SDK debug | ~/Library/Application Support/.../debug/{sessionId}.txt | 168KB | Found |
```

- Use `~` shorthand for the home directory to keep paths readable
- Show "Not found" for expected files that don't exist
- If a file is found, show its size
- If `cwd` or `taskRunId` wasn't available in the input, note that in the Status column as "N/A (no taskRunId)" etc.

## Step 5: Quick content summary

For each file that exists, show:
- **SDK transcript**: first and last 3 lines (to show session start/end)
- **Twig logs**: line count only
- **SDK debug**: line count and last 5 lines (usually has the error/end state)
