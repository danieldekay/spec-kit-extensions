---
description: "Validate implemented UI against Stitch prototypes and design tokens for visual consistency"
tools:
  - 'stitch/get_project'
  - 'stitch/get_screen'
  - 'stitch/list_screens'
---

# Stitch Validation

Compare the implemented UI code against Stitch screen prototypes. Check design token adherence, component structure consistency, and interaction flow completeness.

## User Input

$ARGUMENTS

## Prerequisites

1. Implementation tasks are complete (all UI tasks marked `[x]`)
2. `stitch-guide.md` exists (from the prototype phase)
3. Stitch project screens are available

## Steps

### Step 1: Load Validation Context

Read from the feature directory:
- `stitch-guide.md` — screen manifest and component patterns
- `tasks.md` — completed UI tasks
- Implemented source files referenced by UI tasks

### Step 2: Screen-by-Screen Comparison

<!-- GREP:STITCH-VALIDATION -->
```
FOR each screen in stitch-guide.md:

  1. LOAD Stitch screen via stitch/get_screen
  2. READ implemented component code
  3. COMPARE:

     STRUCTURE CHECK:
       - Component hierarchy matches prototype
       - Semantic HTML elements used correctly
       - Accessibility attributes present (aria-*, role, etc.)

     STYLE CHECK:
       - Design tokens applied (colors, spacing, typography)
       - Responsive breakpoints implemented
       - Layout matches prototype at desktop/tablet/mobile

     INTERACTION CHECK:
       - User flows match prototype navigation
       - Loading/error/empty states implemented
       - Form validation patterns consistent

  4. SCORE each dimension:
     ✅ PASS — matches prototype
     ⚠️ DRIFT — minor deviation (acceptable with justification)
     ❌ MISMATCH — significant deviation from prototype

OUTPUT: validation-matrix
  | Screen   | Structure | Styles | Interactions | Overall |
  |----------|-----------|--------|-------------|---------|
  | Login    | ✅        | ✅     | ⚠️          | PASS    |
  | Dashboard| ✅        | ⚠️     | ✅          | PASS    |
  | Settings | ❌        | ✅     | ✅          | FAIL    |
```

### Step 3: Design Token Audit

<!-- GREP:STITCH-TOKEN-AUDIT -->
```
SCAN implemented files FOR:
  - Hardcoded colors (hex, rgb, hsl not from tokens)
  - Hardcoded spacing (px values not from scale)
  - Hardcoded typography (font-size, line-height not from tokens)
  - Magic numbers in layout

FLAG each as:
  TOKEN_VIOLATION — should use design token
  ACCEPTABLE — justified deviation
```

### Step 4: Generate Validation Report

Write `stitch-validation.md` to the feature directory:

<!-- GREP:STITCH-VALIDATION-REPORT -->
```markdown
# Stitch Validation Report: [FEATURE NAME]

**Generated**: [DATE]
**Screens Validated**: [N]
**Pass Rate**: [N]%

## Validation Matrix

| Screen   | Structure | Styles | Interactions | Overall |
|----------|-----------|--------|-------------|---------|
[matrix from Step 2]

## Findings

### Mismatches (require attention)
| ID | Screen | Dimension | Expected | Actual | Severity |
|----|--------|-----------|----------|--------|----------|
[mismatches]

### Drifts (acceptable deviations)
| ID | Screen | Dimension | Deviation | Justification |
|----|--------|-----------|-----------|---------------|
[drifts]

### Token Violations
| File | Line | Value | Expected Token |
|------|------|-------|----------------|
[violations from Step 3]

## Recommendations

[Prioritized list of fixes, grouped by severity]
```

## Output

Produces `stitch-validation.md` in the feature spec directory. Flags include actionable fix recommendations.
