# Changelog — Codebase Impact Analysis

All notable changes to the `codebase-impact` extension.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-04-10

### Added

- Initial release: codebase impact analysis for spec-kit planning workflow.
- `speckit.codebase-impact.analyze` command: scan codebase for integration points, affected features, dependency stability, test impact, and IMPACT-NNN task candidates.
- `after_plan` hook for automatic impact analysis after planning.
- Configurable scan depth (full / shallow / targeted), directory exclusions, and risk thresholds.

## [0.1.1] — 2026-04-10

### Fixed

- Command namespace corrected to `speckit.codebase-impact.*` for `specify` CLI compliance.
- Alias format corrected to `speckit.{extension}.{command}` pattern.
- Greppable `IMPACT-NNN` output format compatible with `sk-query.sh`.
- Optional plan addendum when unaccounted integration points are found.
