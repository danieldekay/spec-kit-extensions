# Codebase Impact Analysis Extension

Adds a codebase impact analysis phase to the spec-kit planning workflow. After planning produces `plan.md` and `data-model.md`, this extension scans the existing codebase to identify integration points, affected features, dependency stability, and test impact — before implementation starts.

## Installation

```bash
specify extension add codebase-impact --source ./extensions/codebase-impact
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `speckit.codebase-impact.analyze` | `speckit.codebase-impact.scan` | Scan codebase for integration points, affected features, and task candidates |

## What It Does

After the planning phase (`/speckit.plan`), this extension:

1. **Extracts identifiers** from spec, plan, data-model, and contracts — entity names, routes, events, components, config keys
2. **Scans the codebase** for files that reference those identifiers — grep and import-based matching
3. **Classifies integration points** as MODIFY, EXTEND, DEPEND, or AT\_RISK
4. **Maps affected features** — traces touched files back to the features they belong to, with regression risk
5. **Audits dependency stability** — uses git history to flag volatile dependencies
6. **Identifies test impact** — finds existing test files that need updates
7. **Produces `codebase-impact.md`** — greppable structured report with `IMPACT-NNN` task candidates

The `IMPACT-NNN` items feed directly into `speckit.tasks` so that "modify existing file X" tasks are never forgotten during implementation.

## Configuration

Copy `config-template.yml` to your project's `.specify/extensions/codebase-impact/codebase-impact-config.yml` and customize:

- `scan_depth` — full (entire repo) / shallow (plan directories only) / targeted (explicit list)
- `exclude_directories` — directories to skip (node\_modules, .git, etc.)
- `risk_threshold` — minimum risk level to include in the report
- `include_test_impact` — whether to identify test files needing updates
- `include_dependency_stability` — whether to audit dependency churn via git log

## Grep Tags

All report sections are tagged for easy access:

| Tag | Section |
|-----|---------|
| `GREP:CI-IDENTIFIER-EXTRACTION` | Identifiers parsed from plan artifacts |
| `GREP:CI-CODEBASE-SCAN` | Codebase search methodology |
| `GREP:CI-INTEGRATION-SURFACE` | Integration point classification |
| `GREP:CI-AFFECTED-FEATURES` | Features at risk of regression |
| `GREP:CI-DEPENDENCY-STABILITY` | Dependency churn audit |
| `GREP:CI-TEST-IMPACT` | Test files needing updates |
| `GREP:CI-IMPACT-TASKS` | IMPACT-NNN task candidates |
| `GREP:CI-REPORT-TEMPLATE` | Output report structure |

## Fleet Integration

When used with the [fleet orchestrator](../fleet/), this extension runs as **Phase 3.5** between Plan (Phase 3) and UX Research (Phase 4). The artifact signal is `codebase-impact.md` in the feature directory. The phase auto-skips gracefully if the extension is not installed.
