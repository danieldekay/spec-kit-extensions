---
description: "Analyze spec for UX needs, discover existing UI patterns, and produce a UX research report with reuse recommendations"
---

# UX Research Analysis

Analyze the feature specification for UX/UI touchpoints. Scan the existing codebase for reusable patterns, components, and design conventions. Produce a structured report that guides the implementation phase.

## User Input

$ARGUMENTS

## Prerequisites

1. `spec.md` exists in the active feature directory
2. `plan.md` exists (this hook runs after planning)

## Steps

### Step 1: Locate Feature Context

```bash
# Detect feature directory
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
spec_file="$feature_dir/spec.md"
plan_file="$feature_dir/plan.md"
```

Read `spec.md` and `plan.md` from the feature directory. Extract all UI touchpoints, user stories with frontend interactions, and screen references.

### Step 2: Extract UX Surface Area

Parse the spec for UX-relevant content:

<!-- GREP:UX-SURFACE-AREA -->
```
SCAN spec.md FOR:
  - User stories with "I want to see/click/enter/navigate/view"
  - Acceptance criteria mentioning UI behavior
  - Non-functional requirements: accessibility, responsiveness, performance (LCP/FID/CLS)
  - Data display requirements (tables, lists, cards, charts)
  - Form interactions (inputs, validation, submission)
  - Navigation changes (routes, menus, breadcrumbs)
  - Notification/feedback UI (toasts, modals, alerts)

OUTPUT: ux-surface-area table
  | ID    | Source   | UX Need                    | Type       | Priority |
  |-------|----------|----------------------------|------------|----------|
  | UX001 | US1.AC2  | User registration form     | Form       | P1       |
  | UX002 | FR3      | Dashboard metrics display  | Data View  | P1       |
  | UX003 | NFR2     | Mobile-responsive layout   | Layout     | P2       |
```

### Step 3: Scan Existing Patterns

<!-- GREP:PATTERN-SCAN -->
```
SCAN codebase FOR existing UI patterns:

  1. COMPONENT INVENTORY
     - Search pattern directories for component files
     - Classify: form, layout, data-display, navigation, feedback, utility
     - Note component API: props, slots, events, variants

  2. DESIGN TOKENS
     - Colors, spacing, typography, breakpoints
     - Theme configuration files
     - CSS custom properties / Tailwind config / design system tokens

  3. INTERACTION PATTERNS
     - Form handling (validation, submission, error states)
     - Data fetching (loading, error, empty states)
     - Navigation patterns (routing, guards, transitions)
     - State management approach (stores, context, signals)

  4. LAYOUT PATTERNS
     - Page layout components (shell, sidebar, header, footer)
     - Grid/flex patterns in use
     - Responsive breakpoint strategy

OUTPUT: pattern-inventory table
  | Pattern          | Location                  | Reuse Status | Notes              |
  |------------------|---------------------------|--------------|--------------------|
  | FormField        | src/components/FormField  | REUSE        | Handles validation |
  | DataTable        | src/components/DataTable  | EXTEND       | Needs sort column  |
  | PageShell        | src/layouts/PageShell     | REUSE        | Standard layout    |
  | [missing]        | —                         | CREATE       | Dashboard chart    |
```

### Step 4: Component Mapping

<!-- GREP:COMPONENT-MAPPING -->
```
MAP each UX need to a resolution strategy:

  | UX Need    | Strategy | Component       | Source   | Work Estimate |
  |------------|----------|-----------------|----------|---------------|
  | UX001      | REUSE    | FormField       | local    | None          |
  | UX002      | EXTEND   | DataTable       | local    | ~2h           |
  | UX003      | COMPOSE  | PageShell+Grid  | local    | ~1h           |
  | UX004      | CREATE   | MetricsChart    | new      | ~4h           |
  | UX005      | INSTALL  | DatePicker      | shadcn   | ~30min        |

STRATEGY definitions:
  REUSE    — Existing component used as-is
  EXTEND   — Existing component with modifications
  COMPOSE  — Combine existing components
  INSTALL  — Install from component registry
  CREATE   — Build from scratch
```

### Step 5: Interaction Flow Analysis

<!-- GREP:INTERACTION-FLOWS -->
```
FOR each user story with UI:

  DOCUMENT flow:
    Screen → User Action → State Change → API Call → UI Feedback → Next Screen

  IDENTIFY:
    - Optimistic UI opportunities
    - Loading state requirements
    - Error recovery paths
    - Edge cases (empty state, overflow, concurrent edits)

  OUTPUT: flow diagram per story
    US1 Flow:
    [Login Page] → enter credentials → validate locally
      → POST /auth/login → show spinner
        → 200: redirect to /dashboard
        → 401: show inline error, keep form data
        → 500: show toast "Server error, try again"
```

### Step 6: Accessibility & Responsiveness Audit

<!-- GREP:A11Y-AUDIT -->
```
CHECK existing patterns for:
  - ARIA labels and roles
  - Keyboard navigation support
  - Screen reader compatibility
  - Color contrast (WCAG AA minimum)
  - Focus management
  - Touch target sizes (48px minimum)

CHECK responsive strategy:
  - Breakpoint definitions
  - Mobile-first vs desktop-first
  - Component behavior at each breakpoint

FLAG gaps in current implementation
```

### Step 7: Generate UX Research Report

Write `ux-research-report.md` to the feature directory:

<!-- GREP:UX-REPORT-TEMPLATE -->
```markdown
# UX Research Report: [FEATURE NAME]

**Generated**: [DATE]
**Spec**: [spec.md path]
**Plan**: [plan.md path]

## Executive Summary

[2-3 sentences: total UX needs found, reuse percentage, main gaps]

## UX Surface Area

| ID    | Source   | UX Need                    | Type       | Priority |
|-------|----------|----------------------------|------------|----------|
[table from Step 2]

## Pattern Inventory

### Existing Components
| Component   | Location              | API Summary           | Reusable? |
|-------------|-----------------------|-----------------------|-----------|
[table from Step 3]

### Design Tokens
| Category    | Source                | Values                |
|-------------|----------------------|------------------------|
[tokens found]

## Component Mapping

| UX Need | Strategy | Component     | Source  | Effort  |
|---------|----------|---------------|--------|---------|
[table from Step 4]

### Reuse Score: [N]% of UX needs covered by existing patterns

## Interaction Flows

[flows from Step 5]

## Accessibility Gaps

| Gap         | Severity | Existing Pattern | Recommendation      |
|-------------|----------|------------------|---------------------|
[gaps from Step 6]

## Recommendations

<!--
  GREPPABLE FORMAT: each recommendation MUST also appear as a FINDING-NNN line.
  Format: FINDING-NNN: severity | category | component/location | description
  Severity: must-have | should-have | nice-to-have
  Category: ux | a11y | pattern | component | interaction
  Shell: grep "^FINDING-" ux-research-report.md
         sk-query.sh findings ux-research-report.md
-->

### Must Have (before implementation)
- [Critical UX decisions needed]

FINDING-001: must-have | ux | [component or location] | [description]

### Should Have (during implementation)
- [Important patterns to follow]

FINDING-002: should-have | pattern | [component or location] | [description]

### Nice to Have (future iterations)
- [Improvements for later]

FINDING-003: nice-to-have | ux | [component or location] | [description]

## Installation Commands

[If INSTALL components needed]
```

### Step 8: Update Plan

If the UX research reveals new tasks or changes, append a `## UX Research Addendum` section to `plan.md` with:
- New components to create
- Existing components to extend
- Installation commands for registry components
- Updated file assignments for tasks.md

## Output

The command produces `ux-research-report.md` in the feature spec directory and optionally updates `plan.md` with UX addendum.
