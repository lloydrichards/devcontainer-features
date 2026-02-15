
# Agent Party Feature (agent-party)

Install a small DnD-themed agent party (agents, commands, skills) using Rulesync.

## Example Usage

```json
"features": {
    "ghcr.io/lloydrichards/devcontainer-features/agent-party:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| targets | Comma-separated list of Rulesync targets to generate. | string | opencode |
| features | Comma-separated list of Rulesync features to generate. | string | rules,commands,subagents,skills |
| configPath | Global Rulesync configuration path inside the container. | string | /usr/local/share/rulesync |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/lloydrichards/devcontainer-features/blob/main/src/agent-party/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
