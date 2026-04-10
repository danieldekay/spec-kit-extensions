# Changelog — Fleet Orchestrator

All notable changes to the `fleet` extension.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-04-09

### Changed

- Reset to v0.1.0 for pre-release development.
- All prior changelog entries preserved below for history.

## [0.1.1] — 2026-04-10

### Fixed

- Command namespace corrected to `speckit.fleet.*` for `specify` CLI compliance.
- Alias format corrected to `speckit.{extension}.{command}` pattern.
- Agent file names updated (`speckit.fleet.run.agent.md`, `speckit.fleet.review.agent.md`).

## [0.2.0] — 2025-07-24

### Added

- Phase 2: DoD Generate — produces machine-readable `dod.yml` from spec acceptance criteria.
- Phase 5: Codebase Impact — scans codebase for integration points, produces IMPACT-NNN task candidates.
- Phase 13: DoD Validate — validates implementation against `dod.yml` acceptance criteria.
- Adversarial multi-model review in Phase 15 — dispatches 2-3 review subagents on different AI models with consensus scoring (anvil-inspired).
- Config: `adversarial` section with `enabled`, `models`, and `threshold` settings.
- Config: `skip_dod` and `skip_impact` phase flags.

### Changed

- Expanded from 14 to 17 phases with full pipeline renumbering.
- Updated all artifact detection, resume logic, stale artifact chains, and edge cases for 17-phase pipeline.
- Config: updated all phase number references throughout.
- README: updated phases table, key behaviors, config table, Mermaid workflow diagram, coverage analysis, and gaps.
- Companion extensions now include `dod` and `codebase-impact` alongside `ux-research`, `stitch-implement`, `code-quality`.

## [2.0.0] — 2026-04-09

### Changed

- Standardized command namespace to `speckit.fleet.*`.
- Expanded from 11 to 14 phases: added UX Research (4), Stitch Prototype (9), Stitch Validate (11).
- Fully autonomous by default — `vscode_askQuestions` only for critical blockers and final ship approval.
- WIP auto-commits after every artifact-producing phase (`git.auto_commit`).
- Auto-stashes uncommitted changes before fleet run (`git.auto_stash`).
- Sub-agent delegation protocol: compact returns, per-phase tracking files.
- Rules 12-14: circuit breaker, `progress.md` session log, `.fleet-status.yml` tracker.
- Full RFC compliance: added `changelog`, `support`, `config_schema`, `aliases` to manifest.

## [1.0.0] — 2026-03-01

### Added

- Initial release: 11-phase feature lifecycle orchestrator.
- Auto-resume from correct phase on any branch.
- Cross-model review in Phase 8.
- Parallel subagents during Plan and Implement.
- Context budget management with compact summaries.
- Configurable model routing and phase skipping.
