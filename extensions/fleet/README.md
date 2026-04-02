# Fleet Orchestrator Extension

Full-lifecycle feature orchestrator for [Spec Kit](https://github.com/danieldekay/spec-kit). Drives a feature from idea to merged code through 12 phases with human-in-the-loop gates at every step.

Inspired by good ideas from the community: circuit breaker (Ralph), progress.md log (Ralph), machine-readable status tracker (Product Forge), sync-verify (Product Forge), change-request (Product Forge), parallel code-review (MAQA), qa_cadence config (MAQA), explicit --skip-* bypass flags (plan-review-gate).

## Phases

| # | Phase | Optional | Agent | Artifact |
|---|-------|----------|-------|----------|
| 1 | Specify | — | `speckit.specify` | `spec.md` |
| 2 | Clarify | `--skip-clarify` | `speckit.clarify` | `## Clarifications` in spec.md |
| 3 | Plan | — | `speckit.plan` | `plan.md` |
| 4 | Checklist | `--skip-checklist` | `speckit.checklist` | `checklists/` |
| 5 | Tasks | — | `speckit.tasks` | `tasks.md` |
| 6 | Analyze | — | `speckit.analyze` | `.analyze-done` marker |
| 7 | Review | `--skip-review` | `speckit.fleet.review` | `review.md` (cross-model) |
| 8 | Implement | — | `speckit.implement` | all `[x]` in tasks.md |
| 9 | Code Review | `--skip-code-review` | parallel agents (4) | `.code-review-done` marker |
| 10 | Verify | `--skip-verify` | `speckit.verify` | `.verify-done` marker |
| 11 | Release Readiness | `--skip-release` | fleet orchestrator | `release-readiness.md` |
| 12 | Tests | — | terminal | CI passes |

**Key behaviors:**
- Resumes from the correct phase automatically — run `speckit.fleet.run` on any branch, at any point
- Human gate (Approve / Revise / Skip / Abort / Rollback) after every phase
- Parallel subagents (up to 3) during Plan, Implement, and Code Review for `[P]`-marked tasks
- **Circuit breaker**: 3 consecutive zero-progress implement batches → halt and ask
- **`progress.md` log**: timestamped entry after every gate, enables fast resume across sessions
- **`.fleet-status.yml` tracker**: machine-readable phase state, powers the sync command
- Git WIP commits offered after Phases 5, 8, and 10
- Context budget management with compact summaries between phases
- Phase 7 uses a *different model* than the rest of the workflow to catch blind spots
- Phase 9 Code Review uses 4 parallel agents: quality, security, patterns, tests
- Phase 11 Release Readiness generates a READY / CONDITIONAL / NOT READY checklist

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
| `speckit.fleet.sync` | — | Cross-cutting artifact drift detector (7 consistency layers) |
| `speckit.fleet.change-request` | — | Formal scope change with CR-NNN tracking and artifact markers |

## Configuration

After installing, generate a config file:

```bash
cp .specify/extensions/fleet/config-template.yml .specify/extensions/fleet/fleet-config.yml
```

For personal overrides (gitignored — never commit model choices):

```bash
touch .specify/extensions/fleet/fleet-config.local.yml
echo '.specify/extensions/fleet/fleet-config.local.yml' >> .gitignore
```

Config precedence (highest wins): CLI flags > env vars > fleet-config.local.yml > fleet-config.yml > extension defaults.

Key settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `models.primary` | `"auto"` | Model for most phases |
| `models.review` | `"ask"` | Model for Phase 7 (cross-model review) — prompted once, then saved |
| `phases.skip_clarify` | `false` | Skip Phase 2 entirely |
| `phases.skip_checklist` | `false` | Skip Phase 4 entirely |
| `phases.skip_review` | `false` | Skip Phase 7 entirely |
| `phases.skip_code_review` | `false` | Skip Phase 9 entirely |
| `phases.skip_verify` | `false` | Skip Phase 10 entirely |
| `phases.skip_release` | `false` | Skip Phase 11 entirely |
| `qa.cadence` | `"per_phase"` | When to run code review: `per_phase` or `batch_end` |
| `qa.security` | `true` | Enable security dimension in Phase 9 code review |
| `qa.code_quality` | `true` | Enable quality dimension in Phase 9 code review |
| `qa.patterns` | `true` | Enable patterns dimension in Phase 9 code review |
| `qa.tests` | `true` | Enable test coverage dimension in Phase 9 code review |
| `parallelism.max_concurrent` | `3` | Max concurrent subagents |

## Requires

- `speckit >= 0.2.0`
- Core SpecKit commands: `speckit.specify`, `speckit.clarify`, `speckit.plan`, `speckit.checklist`, `speckit.tasks`, `speckit.analyze`, `speckit.implement`
- Optional: `speckit.verify` from the [verify extension](https://github.com/ismaelJimenez/spec-kit-verify) (Phase 10)
