---
description: "Generate UI screen prototypes via Stitch MCP and extract component patterns for implementation tasks"
tools:
  - 'stitch/create_project'
  - 'stitch/list_projects'
  - 'stitch/generate_screen_from_text'
  - 'stitch/edit_screens'
  - 'stitch/get_screen'
  - 'stitch/get_project'
  - 'stitch/list_screens'
  - 'stitch/generate_variants'
---

# Stitch Prototype Generation

Generate UI prototypes for implementation tasks using the Stitch MCP. Operates in two modes: full prototype generation or pattern validation, controlled by configuration.

## User Input

$ARGUMENTS

## Prerequisites

1. `spec.md` and `plan.md` exist in the feature directory
2. `tasks.md` exists with UI-related tasks identified
3. Stitch MCP server is configured and accessible
4. (Optional) `ux-research-report.md` exists from the UX research extension

## Steps

### Step 1: Detect Mode and Load Context

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
config_file=".specify/extensions/stitch-implement/stitch-implement-config.yml"
```

Read configuration to determine mode (`prototype` / `validate` / `both`).

Load from feature directory:
- `spec.md` — user stories with UI touchpoints
- `plan.md` — architecture and component decisions
- `tasks.md` — tasks flagged as UI-related
- `ux-research-report.md` (if exists) — reuse recommendations and component mappings

### Step 2: Identify UI Tasks

<!-- GREP:STITCH-UI-TASKS -->
```
SCAN tasks.md FOR tasks involving:
  - Frontend components, views, pages
  - Form creation or modification
  - Data display (tables, charts, cards)
  - Layout changes
  - Navigation modifications
  - User-facing interactions

FILTER OUT:
  - Pure backend tasks (API, models, migrations, services)
  - Test-only tasks
  - Configuration/infrastructure tasks

OUTPUT: ui-task-list
  | Task ID | Description              | Screen Type        | Components Needed |
  |---------|--------------------------|--------------------|--------------------|
  | T003    | User registration form   | Form               | FormField, Button  |
  | T006    | Dashboard metrics view   | Data Display       | Chart, Card, Grid  |
  | T009    | Settings page layout     | Settings           | Tabs, FormField    |
```

### Step 3: Resolve Stitch Project

<!-- GREP:STITCH-PROJECT-SETUP -->

Check for a local config override first:

```
local_config=".specify/extensions/stitch-implement/stitch-implement-config.local.yml"

IF local_config exists AND stitch.projects[] is non-empty:
  USE first matching project from stitch.projects[]
  project_id = projects[0].id
  LOG "Reusing configured project: {projects[0].name} ({project_id})"
ELSE:
  USE stitch/create_project:
    name: "speckit-{feature-name}"
    description: "UI prototypes for {feature-name}"
  STORE project_id for subsequent calls
```

### Step 3b: Load Design Masters

<!-- GREP:STITCH-DESIGN-MASTERS -->

If `stitch.design_masters[]` is configured, load each master screen to extract its design theme and visual patterns:

```
IF local_config exists AND stitch.design_masters[] is non-empty:
  FOR each master in design_masters:
    USE stitch/get_screen:
      project_id: master.project_id
      screen_id: master.id
    EXTRACT design_theme (colorMode, font, roundness, customColor, saturation)
    EXTRACT layout patterns, component styles, spacing rhythm
  STORE as design_context for use in screen generation prompts
  LOG "Loaded {count} design master(s) as style reference"
ELSE:
  design_context = null
  LOG "No design masters configured — screens will use Stitch defaults"
```

### Step 4: Generate Screens (Prototype Mode)

<!-- GREP:STITCH-SCREEN-GENERATION -->
```
FOR each UI task:

  1. BUILD prompt from:
     - User story acceptance criteria
     - Component mapping from ux-research-report (if available)
     - Design tokens from codebase (colors, typography, spacing)
     - Existing component patterns to match
     - Design master context (if loaded in Step 3b) — include colour mode,
       font family, roundness, accent colour, and layout rhythm so generated
       screens match the established visual language

  2. GENERATE screen:
     USE stitch/generate_screen_from_text:
       project_id: {project_id}
       prompt: "{constructed prompt}"

  3. REVIEW generated screen:
     USE stitch/get_screen to inspect result

  4. GENERATE variants (if variant_count > 1):
     USE stitch/generate_variants:
       screen_id: {screen_id}
       count: {variant_count}

  5. REFINE if needed:
     USE stitch/edit_screens with specific adjustments

OUTPUT: screen-manifest
  | Task ID | Screen ID  | Variants | Status   |
  |---------|------------|----------|----------|
  | T003    | scr_abc123 | 2        | Approved |
  | T006    | scr_def456 | 2        | Needs edit|
```

### Step 5: Extract Code Patterns (if auto_extract_code enabled)

<!-- GREP:STITCH-CODE-EXTRACTION -->
```
FOR each approved screen:

  EXTRACT from Stitch:
    - HTML structure (semantic markup)
    - CSS patterns (layout, spacing, responsive rules)
    - Component composition (hierarchy, props)

  MAP to project tech stack:
    - React → JSX component structure
    - Vue → SFC template
    - Svelte → .svelte component
    - Plain HTML → semantic markup

  SAVE to {feature_dir}/design-artifacts/:
    - {task-id}-structure.md — component hierarchy
    - {task-id}-styles.md — CSS patterns to apply
    - {task-id}-props.md — component props and variants
```

### Step 6: Generate Stitch Implementation Guide

Write `stitch-guide.md` to the feature directory:

<!-- GREP:STITCH-GUIDE-TEMPLATE -->
```markdown
# Stitch Implementation Guide: [FEATURE NAME]

**Generated**: [DATE]
**Stitch Project**: [project-id]
**Mode**: [prototype/validate/both]

## Screen Manifest

| Task | Screen | Status | Variants | Code Extracted |
|------|--------|--------|----------|----------------|
[manifest from Step 4]

## Component Patterns

[For each screen: component hierarchy, props, styles extracted]

## Implementation Notes

- Components to install: [list]
- Existing components to extend: [list]
- Design token overrides: [list]

## Quick Reference

To view screens: `/speckit.fleet.stitch-prototype view`
To re-generate: `/speckit.fleet.stitch-prototype regenerate {task-id}`
To validate: `/speckit.fleet.stitch-validate`
```

## Output

Produces `stitch-guide.md` and `design-artifacts/` directory in the feature spec folder.
