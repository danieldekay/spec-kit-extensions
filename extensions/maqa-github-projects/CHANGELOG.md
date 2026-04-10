# Changelog — MAQA GitHub Projects Integration

All notable changes to the `maqa-github-projects` extension.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-03-15

### Added

- Initial release: GitHub Projects v2 integration for MAQA.
- `setup` command: bootstrap config via GraphQL API, map Status field options.
- `populate` command: create draft issues per feature with markdown task lists.
- Idempotent re-runs — skips existing items.
- Full RFC compliance: added `changelog`, `support`, `config_schema` to manifest.
