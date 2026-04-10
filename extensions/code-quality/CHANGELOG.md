# Changelog — Code Quality Pipeline

All notable changes to the `code-quality` extension.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-04-09

### Changed

- Reset to v0.1.0 for pre-release development.
- All prior changelog entries preserved below for history.

## [0.1.1] — 2026-04-10

### Fixed

- Command namespace corrected to `speckit.code-quality.*` for `specify` CLI compliance.
- Alias format corrected to `speckit.{extension}.{command}` pattern.

## [2.1.0] — 2026-05-01

### Added

- New command `speckit.code-quality.specfact-sync` (`speckit.code-quality.sf`): aggregates quality artifacts into a `speckit-quality-export-v1` JSON and optionally runs `specfact govern check`.
- DoD bridge in `speckit.code-quality.validate` (Step 7): propagates FR/NFR validation statuses back into `dod.yml` when the `dod` extension is installed and `update_dod: true`.
- Conditional specfact sync at end of `speckit.code-quality.validate` (`sync_after_validate` config option).
- Conditional specfact sync at end of `speckit.code-quality.pipeline` (`sync_after_pipeline` config option).
- `specfact` configuration section in `config-template.yml` with `project_id`, `enforcement_level`, `export_path`, `update_dod`, `sync_after_validate`, `sync_after_pipeline`.
- New grep tags: `CQ-VALIDATE-DOD-BRIDGE`, `CQ-VALIDATE-SF-EXPORT`, `CQ-PIPELINE-SF-SYNC`, `CQ-SF-*` for the sync command.

### Changed

- `extension.yml` version reset to 0.1.0 for pre-release development.
- `speckit.code-quality.pipeline` produces an optional sixth artifact: `quality-export.json`.
- Pipeline diagram in `quality-pipeline.md` extended with Step 7 (conditional specfact sync).

## [2.0.0] — 2026-04-09

### Changed

- Standardized command namespace to `speckit.code-quality.*`.
- Full RFC compliance: added `changelog`, `support`, `config_schema` to manifest.
- README aliases now use fully qualified names per RFC spec.

## [1.0.0] — 2026-03-01

### Added

- Initial release: 4-stage pipeline (review → fix → validate → future ideas).
- Gate checks between stages.
- Configurable severity thresholds and principle sets.
- `after_implement` hook for automatic post-implementation quality checks.
