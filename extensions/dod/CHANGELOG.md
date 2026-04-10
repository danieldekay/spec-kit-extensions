# Changelog — Definition of Done Extension

All notable changes to the `dod` extension.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-04-09

### Changed

- Reset to v0.1.0 for pre-release development.

## [1.0.0] — 2026-04-09

### Added

- Initial release.
- `dk.dod.generate` — parse `spec.md` and write `dod.yml` with per-FR Given/When/Then criteria and per-NFR threshold/audit criteria.
- `dk.dod.validate` — check implementation and test coverage against `dod.yml`; update statuses; write `dod-validation-report.md`.
- `dk.dod.export` — produce `specfact-export-v1` JSON for consumption by the specfact CLI governance engine.
- `dk.dod.report` — render a human-readable DoD status summary (console or Markdown file).
- `after_specify` hook that prompts to run `dk.dod.generate` immediately after `speckit.specify`.
- `after_implement` hook that prompts to run `dk.dod.validate` after implementation is complete.
- JSON Schema for `dod.yml` (`schemas/dod.schema.json`).
- JSON Schema for the specfact export format (`schemas/specfact-export.schema.json`).
- Two quality gates: `ready_for_sprint` and `definition_of_done`.
- `enforcement_level` config (`observe` / `warn` / `enforce`) for CI pipeline integration.
- GitHub Actions snippet for `specfact govern check` in README.
