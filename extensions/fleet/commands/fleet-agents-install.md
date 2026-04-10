---
description: Copies fleet .agent.md files to .github/agents/ for VS Code Copilot users.
user-invocable: true
---

## Purpose

The fleet extension ships VS Code Copilot agent files alongside the spec-kit commands. This command copies them to `.github/agents/` so they appear as chat modes in VS Code.

## Steps

1. Locate the installed fleet extension path:
   ```
   .specify/extensions/fleet/
   ```

2. Create the target directory if it doesn't exist:
   ```bash
   mkdir -p .github/agents
   ```

3. Copy the agent files:
   ```bash
   cp .specify/extensions/fleet/agents/speckit.fleet.run.agent.md .github/agents/
   cp .specify/extensions/fleet/agents/speckit.fleet.review.agent.md .github/agents/
   ```

4. Confirm the files were installed:
   ```bash
   ls -la .github/agents/speckit.fleet*.agent.md
   ```

5. Report to the user:
   > Fleet agents installed:
   > - `.github/agents/speckit.fleet.run.agent.md` -- orchestrator agent (invoke via `@speckit.fleet.run`)
   > - `.github/agents/speckit.fleet.review.agent.md` -- cross-model reviewer (invoked by fleet automatically)

## Notes

- These files are VS Code Copilot-specific. Non-Copilot users can use the spec-kit commands `speckit.fleet.run` and `speckit.fleet.review` directly.
- The agents reference `.specify/scripts/` paths -- ensure the prerequisite scripts are installed (run `speckit.init` if not done yet).
- Add `.github/agents/speckit.fleet*.agent.md` to `.gitignore` if you don't want to commit them, or commit them to share the fleet workflow with your team.
