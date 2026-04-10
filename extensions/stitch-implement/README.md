# Stitch Implementation Extension

Integrates Google Stitch MCP into the spec-kit implementation phase for UI prototyping, code extraction, and post-implementation validation. Supports pinned projects, design master screens, and companion skills (`stitch-loop`, `taste-design`).

## Installation

```bash
specify extension add stitch-implement --source ./extensions/stitch-implement
```

## Requirements

- Stitch MCP server configured in your AI agent
- Active Stitch account

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `speckit.stitch-implement.prototype` | `speckit.stitch-implement.ui` | Generate UI screens and extract code patterns |
| `speckit.stitch-implement.validate` | — | Validate implementation against prototypes |
| `speckit.stitch-implement.setup` | — | Discover Stitch projects and design masters, write config override |

## Modes

Controlled by `stitch.mode` in configuration:

| Mode | Before Implement | After Implement |
|------|-----------------|-----------------|
| `prototype` | Generate screens | — |
| `validate` | — | Check consistency |
| `both` | Generate screens | Check consistency |

## Grep Tags

| Tag | Section |
|-----|---------|
| `GREP:STITCH-UI-TASKS` | UI task identification |
| `GREP:STITCH-PROJECT-SETUP` | Stitch project resolution (config or create) |
| `GREP:STITCH-DESIGN-MASTERS` | Design master loading and context extraction |
| `GREP:STITCH-SCREEN-GENERATION` | Screen generation workflow |
| `GREP:STITCH-CODE-EXTRACTION` | Code pattern extraction |
| `GREP:STITCH-GUIDE-TEMPLATE` | Implementation guide output |
| `GREP:STITCH-VALIDATION` | Post-implementation validation |
| `GREP:STITCH-TOKEN-AUDIT` | Design token compliance check |
| `GREP:STITCH-VALIDATION-REPORT` | Validation report output |
| `GREP:STITCH-SETUP-DISCOVERY` | Setup command — project/screen discovery |
| `GREP:STITCH-SETUP-LIST-PROJECTS` | Setup — project listing |
| `GREP:STITCH-SETUP-LIST-SCREENS` | Setup — screen listing |
| `GREP:STITCH-SETUP-CONFIG-WRITE` | Setup — config override generation |

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `stitch.mode` | `"both"` | `prototype`, `validate`, or `both` |
| `stitch.auto_extract_code` | `true` | Extract code patterns from approved screens |
| `stitch.variant_count` | `2` | Number of variants to generate per screen |
| `stitch.resolution` | `"1024x768"` | Default screen resolution |
| `stitch.project_prefix` | `"speckit-"` | Prefix for auto-created project names |
| `stitch.output_directory` | `"design-artifacts"` | Where to save extracted design artifacts |
| `stitch.skip_backend_tasks` | `true` | Skip validation for non-UI tasks |
| `stitch.projects` | `[]` | Pinned Stitch projects (discovered via `setup`) |
| `stitch.design_masters` | `[]` | Screen IDs used as visual style references |

Run `speckit.stitch-implement.setup` to populate `projects` and `design_masters` interactively.

## Companion Skills

For the full Stitch workflow, install these skills:

```sh
npx skills add https://github.com/google-labs-code/stitch-skills --skill stitch-loop
npx skills add https://github.com/google-labs-code/stitch-skills --skill taste-design
```

| Skill | Purpose |
|-------|--------|
| **stitch-loop** | Autonomous baton-passing loop for iterative website building with Stitch |
| **taste-design** | Generates `DESIGN.md` with premium design system (atmosphere, colours, typography, motion) |
