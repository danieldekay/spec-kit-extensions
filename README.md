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
| [fleet](extensions/fleet/) | standalone | Full-lifecycle orchestrator: 10-phase workflow with human gates, cross-model review (Phase 7), parallel subagents, and auto-resume |
| [code-quality](extensions/code-quality/) | `after_implement` | Post-implementation pipeline: code review, auto-fix, FR/NFR validation, and future ideas |
| [ux-research](extensions/ux-research/) | `after_plan` | Analyze spec for UX needs, discover existing patterns, produce a `ux-research-report.md` |
| [stitch-implement](extensions/stitch-implement/) | `before/after_implement` | UI prototyping and validation via [Stitch MCP](https://stitch.withgoogle.com) |

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
