# spec-kit-extensions

Custom [Spec Kit](https://github.com/danieldekay/spec-kit) presets and extensions.

## Presets

Presets override core Spec Kit templates and sit high in the resolution stack. Install with `specify preset add <id>`.

| Preset | Description |
|--------|-------------|
| [greppable-templates](presets/greppable-templates/) | Replaces core spec/tasks/checklist templates with greppable versions (`FR-NNN:`, `SC-NNN:`, `TASK-TNNN:`, `CHK-NNN:`) and ships `sk-query.sh` for shell-based artifact queries |

## Extensions

Extensions add new commands and hooks to the Spec Kit workflow. Install with `specify extension add <id>`.

| Extension | Hook | Description |
|-----------|------|-------------|
| [fleet](extensions/fleet/) | standalone | All-in-one 17-phase lifecycle orchestrator with bundled DoD, Codebase Impact, UX Research, Stitch MCP, and Code Quality — 20 commands, one install |
| [maqa-github-projects](extensions/maqa-github-projects/) | standalone | GitHub Projects v2 integration for MAQA: populate draft issues from specs, move items across Status columns, tick task lists in issue body. Credit: [GenieRobot](https://github.com/GenieRobot/spec-kit-maqa-github-projects) |

## Greppable marker reference

All templates emit structured line-start prefixes so you can query any artifact with `grep` or `sk-query.sh`:

| Marker | Template | Query |
|--------|----------|-------|
| `FR-NNN:` | spec.md | `sk-query.sh fr spec.md` |
| `SC-NNN:` | spec.md | `sk-query.sh sc spec.md` |
| `TASK-TNNN: [ ]` | tasks.md | `sk-query.sh open tasks.md` |
| `CHK-NNN: [ ]` | checklist.md | `sk-query.sh open-chk checklist.md` |
| `FINDING-NNN: severity\|category\|location\|description` | *-review.md | `sk-query.sh critical review.md` |

## License

MIT
