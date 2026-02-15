---
name: agent-guild-roster
description: DnD-themed roster of available agents with roles and guidance for party formation.
targets: ["*"]
---

# Agent Guild Roster

Generate a DnD-style roster dynamically by searching the agent directory and extracting each agent's frontmatter description. Use the results to recommend parties. Keep parties small and focused.

## Roster Discovery

Run this command to list agents and descriptions:

```bash
ls ~/.config/opencode/agent/ | sed 's/\.md$//' | xargs -I {} sh -c 'echo -n "@{}: "; head -5 ~/.config/opencode/agent/{}.md | grep description: | sed "s/description: //"'
```

## Expected Output Format

```txt
@warrior: "Spec-driven code implementer - executes technical specifications and architectural designs from party members"
@scout: "Repository content finder and summarizer specialist for fast information discovery and synthesis"
```
