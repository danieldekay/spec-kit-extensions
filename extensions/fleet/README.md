# Fleet Orchestrator Extension

Full-lifecycle feature orchestrator for [Spec Kit](https://github.com/danieldekay/spec-kit). Drives a feature from idea to merged code through 17 phases autonomously — auto-resumes, WIP auto-commits after every phase, auto-stashes dirty worktrees, and only interrupts via `vscode_askQuestions` for critical blockers or final ship approval.

Inspired by good ideas from the community: circuit breaker (Ralph), progress.md log (Ralph), machine-readable status tracker (Product Forge), sync-verify (Product Forge), change-request (Product Forge), post-implementation quality pipelines, and explicit --skip-* bypass flags (plan-review-gate).

## Phases

| # | Phase | Optional | Agent | Artifact |
|---|-------|----------|-------|----------|
| 1 | Specify | — | `speckit.specify` | `spec.md` |
| 2 | DoD Generate | `--skip-dod` | `speckit.dod.generate` | `dod.yml` |
| 3 | Clarify | `--skip-clarify` | `speckit.clarify` | `## Clarifications` in spec.md |
| 4 | Plan | — | `speckit.plan` | `plan.md` |
| 5 | Codebase Impact | `--skip-impact` | `speckit.codebase-impact.analyze` | `codebase-impact.md` |
| 6 | UX Research | `--skip-ux` (auto-skip if no UI) | `speckit.ux-research.analyze` | `ux-research-report.md` |
| 7 | Checklist | `--skip-checklist` | `speckit.checklist` | `checklists/` |
| 8 | Tasks | — | `speckit.tasks` | `tasks.md` |
| 9 | Analyze | — | `speckit.analyze` | `.analyze-done` marker |
| 10 | Review | `--skip-review` | `speckit.fleet.review` | `review.md` (cross-model) |
| 11 | Stitch Prototype | `--skip-stitch` (auto-skip if no UI) | `speckit.stitch-implement.prototype` | `.stitch-prototype-done` |
| 12 | Implement | — | `speckit.implement` | all `[x]` in tasks.md |
| 13 | DoD Validate | `--skip-dod` | `speckit.dod.validate` | `.dod-validate-done` |
| 14 | Stitch Validate | `--skip-stitch` (auto-skip if no UI) | `speckit.stitch-implement.validate` | `.stitch-validate-done` |
| 15 | Code Review | `--skip-code-review` | `speckit.code-quality.pipeline` + adversarial | `reviews/quality-summary.md` + `adversarial-review.md` |
| 16 | Release Readiness | `--skip-release` | fleet orchestrator | `release-readiness.md` |
| 17 | Tests | — | terminal | CI passes |

**Key behaviors:**
- Resumes from the correct phase automatically — run `speckit.fleet.run` on any branch, at any point
- **Autonomous by default** — uses `vscode_askQuestions` only for critical blockers (FAIL/CRITICAL findings, circuit breaker, missing extensions) and final ship approval (Phase 16)
- **WIP auto-commits** after every artifact-producing phase (`wip(fleet): phase {N} {name}`), controlled by `git.auto_commit` config
- **Auto-stashes** uncommitted changes before the run (`git stash push -m "fleet-auto-stash: ..."`) and reminds at completion, controlled by `git.auto_stash` config
- **Auto-skips Phase 10** when `models.review` is `"ask"` (unconfigured) — no prompting on first run
- **CI auto-fix** — first iteration auto-fixes without asking; iteration 2+ uses `vscode_askQuestions`
- Parallel subagents (up to 3) during Plan and Implement for `[P]`-marked tasks
- **Circuit breaker**: 3 consecutive zero-progress implement batches → halt and ask
- **`progress.md` log**: timestamped entry after every completed phase or explicit skip/override decision, enables fast resume across sessions
- **`.fleet-status.yml` tracker**: machine-readable phase state, powers the sync command
- Context budget management with compact summaries between phases
- Phase 2 DoD Generate produces machine-readable `dod.yml` from spec acceptance criteria; Phase 13 DoD Validate checks implementation against it
- Phase 5 Codebase Impact scans for integration points and produces IMPACT-NNN task candidates that feed into tasks.md
- Phase 10 uses a *different model* than the rest of the workflow to catch blind spots
- Phase 15 Code Review runs `speckit.code-quality.pipeline` then an **adversarial multi-model pass** — 2-3 review subagents on different AI models with consensus scoring
- Phase 16 Release Readiness generates a READY / CONDITIONAL / NOT READY checklist
- Phases 6, 11, and 14 auto-skip when the feature has no UI (keyword detection in spec.md/plan.md)

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
| `speckit.fleet.run` | `speckit.fleet.go` | Start or resume the full fleet workflow |
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
| `models.review` | `"ask"` | Model for Phase 10 (cross-model review) — auto-skips when `"ask"`, set a model name to enable |
| `phases.skip_dod` | `false` | Skip Phases 2 & 13 (DoD Generate + Validate) |
| `phases.skip_impact` | `false` | Skip Phase 5 (Codebase Impact) |
| `phases.skip_clarify` | `false` | Skip Phase 3 entirely |
| `phases.skip_ux` | `false` | Skip Phase 6 entirely (auto-skips if no UI detected) |
| `phases.skip_checklist` | `false` | Skip Phase 7 entirely |
| `phases.skip_review` | `false` | Skip Phase 10 entirely |
| `phases.skip_stitch` | `false` | Skip Phases 11+14 entirely (auto-skips if no UI detected) |
| `phases.skip_code_review` | `false` | Skip Phase 15 entirely |
| `phases.skip_release` | `false` | Skip Phase 16 entirely |
| `qa.cadence` | `"per_phase"` | When to run the Phase 15 code-quality pipeline: `per_phase` or `batch_end` |
| `qa.run_review` | `true` | Generate `reviews/code-review.md` |
| `qa.run_fix` | `true` | Apply auto-fixes and generate `reviews/code-fix-report.md` |
| `qa.run_validate` | `true` | Generate `reviews/validation-report.md` |
| `qa.run_future` | `true` | Generate `reviews/future-ideas.md` |
| `qa.pause_on_critical` | `true` | Pause Fleet if CRITICAL findings remain after Phase 15 |
| `adversarial.enabled` | `true` | Enable adversarial multi-model review pass in Phase 15 |
| `adversarial.models` | `["gpt-4.1", "gemini-2.5-pro", "claude-sonnet-4"]` | Models to dispatch as parallel review subagents |
| `adversarial.threshold` | `"medium"` | Minimum severity to report: `low`, `medium`, `high`, `critical` |
| `git.auto_commit` | `true` | WIP auto-commit after every artifact-producing phase |
| `git.auto_stash` | `true` | Auto-stash uncommitted changes before fleet run |
| `parallelism.max_concurrent` | `3` | Max concurrent subagents |

## Requires

- `speckit >= 0.2.0`
- Core SpecKit commands: `speckit.specify`, `speckit.clarify`, `speckit.plan`, `speckit.checklist`, `speckit.tasks`, `speckit.analyze`, `speckit.implement`
- Recommended companion extensions for the full Fleet experience: `dod`, `codebase-impact`, `ux-research`, `stitch-implement`, `code-quality`

## Workflow Diagram — Core + Extensions

Fleet wraps the entire Spec Kit core flow and interleaves extension phases where they add the most value. Core commands run unconditionally (or with simple skip flags); extension phases degrade gracefully when the extension is not installed.

```mermaid
flowchart TD
    %% ── Styles ──
    classDef core fill:#1f6feb,stroke:#1f6feb,color:#fff
    classDef ext fill:#8957e5,stroke:#8957e5,color:#fff
    classDef fleet fill:#da3633,stroke:#da3633,color:#fff
    classDef notint fill:#30363d,stroke:#8b949e,color:#8b949e,stroke-dasharray:5 5

    %% ── Pre-flight ──
    PRE["🔒 Pre-flight<br/>git stash · HEAD check · branch freshness<br/>artifact detection · resume logic"]

    %% ── Phase nodes ──
    P1["① Specify<br/><b>speckit.specify</b><br/>→ spec.md"]:::core
    P2["② DoD Generate ◇<br/><b>speckit.dod.generate</b><br/>→ dod.yml"]:::ext
    P3["③ Clarify ◇<br/><b>speckit.clarify</b><br/>→ §Clarifications"]:::core
    P4["④ Plan<br/><b>speckit.plan</b><br/>→ plan.md"]:::core
    P5["⑤ Codebase Impact ◇<br/><b>speckit.codebase-impact.analyze</b><br/>→ codebase-impact.md"]:::ext
    P6["⑥ UX Research ◇<br/><b>speckit.ux-research.analyze</b><br/>→ ux-research-report.md"]:::ext
    P7["⑦ Checklist ◇<br/><b>speckit.checklist</b><br/>→ checklists/"]:::core
    P8["⑧ Tasks<br/><b>speckit.tasks</b><br/>→ tasks.md"]:::core
    P9["⑨ Analyze<br/><b>speckit.analyze</b><br/>→ .analyze-done"]:::core
    P10["⑩ Review ◇<br/><b>speckit.fleet.review</b><br/>→ review.md"]:::ext
    P11["⑪ Stitch Prototype ◇<br/><b>speckit.stitch-implement.prototype</b><br/>→ .stitch-prototype-done"]:::ext
    P12["⑫ Implement<br/><b>speckit.implement</b><br/>→ all ☑ in tasks.md"]:::core
    P13["⑬ DoD Validate ◇<br/><b>speckit.dod.validate</b><br/>→ .dod-validate-done"]:::ext
    P14["⑭ Stitch Validate ◇<br/><b>speckit.stitch-implement.validate</b><br/>→ .stitch-validate-done"]:::ext
    P15["⑮ Code Review ◇<br/><b>speckit.code-quality.pipeline</b><br/>+ adversarial multi-model<br/>→ reviews/ + adversarial-review.md"]:::ext
    P16["⑯ Release Readiness ◇<br/>fleet orchestrator<br/>→ release-readiness.md"]:::fleet
    P17["⑰ Tests<br/>terminal CI runner<br/>→ tests pass"]:::fleet

    %% ── Not integrated ──
    NI_MAQA["⛌ maqa-github-projects<br/><i>standalone</i><br/><i>not wired into fleet</i>"]:::notint

    %% ── Flow ──
    PRE --> P1
    P1 --> P2 --> P3 --> P4 --> P5 --> P6
    P6 --> P7 --> P8 --> P9 --> P10 --> P11
    P11 --> P12 --> P13 --> P14 --> P15
    P15 --> P16 --> P17
```

**Legend:** ◇ = optional / skippable &ensp;|&ensp; 🟦 core spec-kit &ensp;|&ensp; 🟪 extension &ensp;|&ensp; 🟥 fleet-only &ensp;|&ensp; ⬛ not integrated

### Coverage Analysis

| Source | Commands | In Fleet? |
|--------|----------|-----------|
| **Spec Kit core** (8) | `constitution`, `specify`, `clarify`, `plan`, `checklist`, `tasks`, `analyze`, `implement` | 7 of 8 — `constitution` is a one-time project init, not a per-feature phase |
| **dod** ext | `speckit.dod.generate`, `.validate` | ✅ Phases 2 & 13 — generate after Specify, validate after Implement |
| **codebase-impact** ext | `speckit.codebase-impact.analyze` | ✅ Phase 5 — scans codebase for integration points after Plan |
| **ux-research** ext | `speckit.ux-research.analyze` | ✅ Phase 6 — auto-skips if no UI keywords in spec/plan |
| **stitch-implement** ext | `speckit.stitch-implement.prototype`, `.validate` | ✅ Phases 11 & 14 — auto-skip if no UI keywords |
| **code-quality** ext | `speckit.code-quality.pipeline` | ✅ Phase 15 — post-implementation quality gate + adversarial multi-model review |
| **fleet** (own) | `speckit.fleet.review`, release readiness, CI | ✅ Phases 10, 16, 17 |
| **maqa-github-projects** ext | `speckit.maqa-github-projects.bootstrap`, `.populate` | ❌ Standalone — no hook overlap with fleet phases |

### Gaps

1. **`maqa-github-projects`** — could sync task completion to GitHub Projects after Phase 8 (Tasks) and Phase 12 (Implement), though this is more of a side-effect than a pipeline phase.
