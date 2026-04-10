# Changelog — Stitch Implementation Assistant

All notable changes to the `stitch-implement` extension.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] — 2026-04-10

### Added

- `speckit.stitch-implement.setup` command — interactive Stitch project and screen discovery that writes a local config override.
- Config: `stitch.projects` list — pin Stitch projects for reuse across runs instead of creating throwaway projects.
- Config: `stitch.design_masters` list — designate screens as visual style references for new screen generation.
- Companion skill references: `stitch-loop` and `taste-design` from `google-labs-code/stitch-skills`.

### Changed

- `stitch-prototype` now checks for configured projects before creating new ones (Step 3).
- `stitch-prototype` loads design master screens and injects their design theme into generation prompts (Step 3b).
- README: added Configuration table, Companion Skills section, and new GREP tags for setup command.

## [0.1.0] — 2026-04-09

### Changed

- Reset to v0.1.0 for pre-release development.

## [1.0.0] — 2026-03-15

### Added

- Initial release: Stitch MCP integration for UI prototyping and validation.
- `prototype` command: generate UI screens and extract code patterns.
- `validate` command: compare implementation against Stitch prototypes.
- `before_implement` and `after_implement` hooks.
- Configurable modes: prototype, validate, both.
- Full RFC compliance: added `changelog`, `support`, `config_schema` to manifest.
