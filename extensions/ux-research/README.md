# UX Research Extension

Adds a UX research phase to the spec-kit planning workflow. Automatically identifies UX needs from the specification, scans the existing codebase for reusable patterns, and produces a structured report guiding implementation.

## Installation

```bash
specify extension add ux-research --source ./extensions/ux-research
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `speckit.ux-research.analyze` | `speckit.ux-research.ux` | Analyze spec for UX needs, discover existing patterns, produce report |

## What It Does

After the planning phase (`/speckit.plan`), this extension:

1. **Extracts UX surface area** from spec — user stories, acceptance criteria, and NFRs with UI touchpoints
2. **Scans existing patterns** — components, design tokens, interaction patterns, layouts
3. **Maps components** — classifies each UX need as REUSE / EXTEND / COMPOSE / INSTALL / CREATE
4. **Documents interaction flows** — screen-by-screen user journeys with error paths
5. **Audits accessibility** — WCAG compliance gaps in existing patterns
6. **Produces `ux-research-report.md`** — greppable structured report in the feature directory

## Configuration

Copy `config-template.yml` to your project's `.specify/extensions/ux-research/ux-research-config.yml` and customize:

- `pattern_directories` — where to scan for existing UI components
- `component_registries` — which registries to check (shadcn, etc.)
- `scan_depth` — full / shallow / targeted

## Grep Tags

All report sections are tagged for easy access:

| Tag | Section |
|-----|---------|
| `GREP:UX-SURFACE-AREA` | UX needs extracted from spec |
| `GREP:PATTERN-SCAN` | Existing codebase patterns |
| `GREP:COMPONENT-MAPPING` | Resolution strategy per UX need |
| `GREP:INTERACTION-FLOWS` | User journey flows |
| `GREP:A11Y-AUDIT` | Accessibility gaps |
| `GREP:UX-REPORT-TEMPLATE` | Output report structure |
