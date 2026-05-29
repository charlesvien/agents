#!/usr/bin/env python3
"""Render an ASCII graveyard of subagents spawned in the current session."""

import json
import os
import sys
from datetime import datetime
from pathlib import Path

TYPE_ABBR = {
    "general-purpose": "gen",
    "Explore": "Exp",
    "Plan": "Pln",
    "code-reviewer": "rev",
    "refactor-cleaner": "ref",
    "statusline-setup": "sln",
    "claude": "cld",
    "claude-code-guide": "ccg",
}

PER_ROW = 5
TOMB_W = 7
GAP = 3

HEADER = [
    "",
    "                  .  *  .  *  .  *",
    "             *  .                  .  *",
    "          .       T H E   A G E N T       .",
    "             *      G R A V E Y A R D    *",
    "          .                              .",
    "             *  .  *  .  *  .  *  .  *",
    "",
]


def find_transcript():
    cwd = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    slug = "-" + cwd.replace("/", "-").lstrip("-")
    project_dir = Path.home() / ".claude" / "projects" / slug
    if not project_dir.exists():
        return None
    sid = os.environ.get("CLAUDE_SESSION_ID")
    if sid:
        path = project_dir / f"{sid}.jsonl"
        if path.exists():
            return path
    candidates = list(project_dir.glob("*.jsonl"))
    if not candidates:
        return None
    return max(candidates, key=lambda p: p.stat().st_mtime)


def parse_agents(path):
    agents = []
    with open(path) as fh:
        for line in fh:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            msg = obj.get("message", {})
            content = msg.get("content", [])
            if not isinstance(content, list):
                continue
            for c in content:
                if not isinstance(c, dict) or c.get("type") != "tool_use":
                    continue
                if c.get("name") not in ("Agent", "Task"):
                    continue
                inp = c.get("input", {})
                if "subagent_type" not in inp and "prompt" not in inp:
                    continue
                agents.append({
                    "description": inp.get("description") or "(no description)",
                    "subagent_type": inp.get("subagent_type") or "general-purpose",
                    "timestamp": obj.get("timestamp", ""),
                })
    return agents


def abbreviate(t):
    if t in TYPE_ABBR:
        return TYPE_ABBR[t]
    tail = t.split(":")[-1] if ":" in t else t
    return tail[:3].lower()


def fmt_time(iso_ts, with_seconds=False):
    try:
        dt = datetime.fromisoformat(iso_ts.replace("Z", "+00:00")).astimezone()
        return dt.strftime("%H:%M:%S" if with_seconds else "%H:%M")
    except (ValueError, AttributeError):
        return "??:??:??" if with_seconds else "??:??"


def tomb(agent):
    abbr = abbreviate(agent["subagent_type"])
    tm = fmt_time(agent["timestamp"])
    return [
        "  ___  ",
        " /   \\ ",
        "|     |",
        f"| {abbr:<3} |",
        f"|{tm:^5}|",
        "|_____|",
    ]


def render_empty():
    lines = list(HEADER)
    lines += [
        "             The graveyard is silent.",
        "             No agents have perished... yet.",
        "",
    ]
    print("\n".join(lines))


def render(agents):
    lines = list(HEADER)
    indent = "    "
    for i in range(0, len(agents), PER_ROW):
        batch = agents[i:i + PER_ROW]
        n = len(batch)
        row_width = TOMB_W * n + GAP * (n - 1)
        tombs = [tomb(a) for a in batch]
        height = len(tombs[0])
        for j in range(height):
            sep = "___" if j == height - 1 else "   "
            lines.append(indent + sep.join(t[j] for t in tombs))
        lines.append(indent + "░" * row_width)
        lines.append("")

    n = len(agents)
    verb = "lies" if n == 1 else "lie"
    noun = "agent" if n == 1 else "agents"
    lines.append(f"  Here {verb} {n} {noun}, lost in service of your task.")
    lines.append("")
    for a in agents:
        t = a["subagent_type"]
        tm = fmt_time(a["timestamp"], with_seconds=True)
        desc = a["description"]
        if len(desc) > 60:
            desc = desc[:57] + "..."
        lines.append(f"     ·  {t:<16}  {tm}   \"{desc}\"")
    lines.append("")
    print("\n".join(lines))


def main():
    path = find_transcript()
    if path is None:
        render_empty()
        return
    agents = parse_agents(path)
    if not agents:
        render_empty()
    else:
        render(agents)


if __name__ == "__main__":
    main()
