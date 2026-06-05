# Wiring Vivi into OpenCode

## 1. Install

```bash
bash install.sh --hosts opencode --target ./.eidolons/vivi
```

This copies methodology files to `.eidolons/vivi/` and creates `.opencode/agents/vivi.md`.

## 2. Config

The installer creates `.opencode/agents/vivi.md`:

```markdown
---
name: vivi
description: Vivi feature implementation methodology for brownfield codebases
---

You are the Vivi feature implementation agent.

Load your full instructions from: .eidolons/vivi/agent.md
Full methodology: .eidolons/vivi/SPEC.md

Cycle: A → P → I → V → Δ/R
```

OpenCode discovers agents in `.opencode/agents/` automatically and makes them available via the agent selector.

## 3. Verify

In OpenCode, select the `vivi` agent and send:

```
New task: add pagination to the user list endpoint.
What complexity tier applies and what is your first action?
```

Expected: Agent classifies as Standard or Complex, initiates Analyze phase, states it will run a repo map first.

## 4. Troubleshooting

**Agent not visible in OpenCode**: Confirm `.opencode/agents/vivi.md` exists. OpenCode may require a project reload. Check OpenCode docs for the agents directory path if it differs from `.opencode/agents/`.

**Instructions not loading**: Confirm `.eidolons/vivi/agent.md` was installed. Re-run `bash install.sh --dry-run` to verify the file list.
