# Fleet Orchestrator Extension

Full-lifecycle feature orchestrator for [Spec Kit](https://github.com/danieldekay/spec-kit). Drives a feature from idea to merged code through 10 phases with human-in-the-loop gates at every step.

## Phases

| # | Phase | Agent | Artifact |
|---|-------|-------|----------|
| 1 | Specify | `speckit.specify` | `spec.md` |
| 2 | Clarify | `speckit.clarify` | `## Clarifications` in spec.md |
| 3 | Plan | `speckit.plan` | `plan.md` |
| 4 | Checklist | `speckit.checklist` | `checklists/` |
| 5 | Tasks | `speckit.tasks` | `tasks.md` |
| 6 | Analyze | `speckit.analyze` | `.analyze-done` marker |
| 7 | Review | `speckit.fleet.review` | `review.md` (cross-model) |
| 8 | Implement | `speckit.implement` | all `[x]` in tasks.md |
| 9 | Verify | `speckit.verify` | `.verify-done` marker |
| 10 | Tests | terminal | CI passes |

**Key behaviors:**
- Resumes from the correct phase automatically — run `speckit.fleet.run` on any branch, at any point
- Human gate (Approve / Revise / Skip / Abort / Rollback) after every phase
- Parallel subagents (up to 3) during Plan and Implement for `[P]`-marked tasks
- Git WIP commits offered after Phases 5, 8, and 9
- Context budget management with compact summaries between phases
- Phase 7 uses a *different model* than the rest of the workflow to catch blind spots

## Install

```bash
specify extension add fleet --from https://github.com/danieldekay/spec-kit-extensions/archive/refs/heads/main.zip
```

### VS Code Copilot users

After installing the extension, run this once to copy the agent files to `.github/agents/`:

```
/speckit.fleet.agents-install
```

Or copy manually:
```bash
mkdir -p .github/agents
cp .specify/extensions/fleet/agents/speckit.fleet.*.agent.md .github/agents/
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `speckit.fleet.run` | `speckit.fleet` | Start or resume the full fleet workflow |
| `speckit.fleet.review` | — | Cross-model review of design artifacts (invoked by fleet automatically) |
| `speckit.fleet.agents-install` | — | Install VS Code Copilot agent files to `.github/agents/` |

## Configuration

After installing, generate a config file:

```bash
cp .specify/extensions/fleet/config-template.yml .specify/extensions/fleet/fleet-config.yml
```

Key settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `models.primary` | `"auto"` | Model for Phases 1–6 and 8–10 |
| `models.review` | `"ask"` | Model for Phase 7 (cross-model review) — prompted once, then saved |
| `phases.skip_review` | `false` | Skip Phase 7 entirely |
| `parallelism.max_concurrent` | `3` | Max concurrent subagents |

## Requires

- `speckit >= 0.2.0`
- Core SpecKit commands: `speckit.specify`, `speckit.clarify`, `speckit.plan`, `speckit.checklist`, `speckit.tasks`, `speckit.analyze`, `speckit.implement`
- Optional: `speckit.verify` from the [verify extension](https://github.com/ismaelJimenez/spec-kit-verify) (Phase 9)
