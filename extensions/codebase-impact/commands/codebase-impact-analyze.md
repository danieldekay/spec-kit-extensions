---
description: "Scan the codebase for integration points, affected features, and dependency stability. Produces codebase-impact.md with IMPACT-NNN task candidates."
---

# Codebase Impact Analysis

Analyze how the planned feature interacts with the existing codebase. Identify integration surfaces, affected features, dependency stability, and test impact. Produce a structured report with greppable `IMPACT-NNN` task candidates that feed directly into `tasks.md`.

## User Input

$ARGUMENTS

## Prerequisites

1. `spec.md` exists in the active feature directory
2. `plan.md` exists (this hook runs after planning)
3. `data-model.md` exists (produced by `speckit.plan` Phase 1)

## Steps

### Step 1: Locate Feature Context

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
spec_file="$feature_dir/spec.md"
plan_file="$feature_dir/plan.md"
data_model_file="$feature_dir/data-model.md"
contracts_dir="$feature_dir/contracts"
config_file=".specify/extensions/codebase-impact/codebase-impact-config.yml"
```

Read `spec.md`, `plan.md`, and `data-model.md`. If `contracts/` exists, read those files too. Load config if present; use defaults otherwise.

### Step 2: Extract Identifiers from Plan Artifacts

<!-- GREP:CI-IDENTIFIER-EXTRACTION -->
```
PARSE spec.md, plan.md, data-model.md, and contracts/ FOR:

  1. ENTITY NAMES
     - Model/class names from data-model.md
     - Table names, field names, relationship names
     - State machine states and transition names

  2. API SURFACE
     - Route paths from contracts/ or plan.md
     - Endpoint names, method signatures
     - Event names, message types, signal names

  3. UI SURFACE
     - Page/screen names, route paths
     - Component names referenced in plan.md
     - CSS class prefixes, design token names

  4. CONFIGURATION SURFACE
     - Config keys, environment variables
     - Feature flags, permission names
     - Schema identifiers

  5. SHARED ABSTRACTIONS
     - Service names, utility function names
     - Middleware, hooks, decorators, mixins
     - Base classes the feature intends to inherit from

OUTPUT: identifier-list
  | Identifier           | Source       | Category        |
  |----------------------|-------------|-----------------|
  | User                 | data-model  | entity          |
  | preferences          | data-model  | field           |
  | /api/v1/preferences  | contracts   | route           |
  | PreferencesUpdated   | spec        | event           |
  | DashboardPage        | plan        | component       |
  | EDITOR_ROLE          | spec        | permission      |
```

### Step 3: Scan Codebase for Integration Points

<!-- GREP:CI-CODEBASE-SCAN -->
```
FOR each identifier from Step 2:

  1. SEARCH the codebase using grep/AST scanning:
     - Exact name matches (case-sensitive for code, case-insensitive for config)
     - Partial matches for compound names (e.g., "User" matches "UserService", "user_model")
     - Import/require statements referencing the identifier's module
     - Type references, interface implementations, class inheritance

  2. FOR each hit, RECORD:
     - File path (absolute)
     - Line number(s)
     - Context: the surrounding code (3-5 lines)
     - Match type: DEFINITION | USAGE | IMPORT | TYPE_REF | INHERITANCE

  3. CLASSIFY each integration point:
     - MODIFY  — existing file needs code changes (new field, new method, altered logic)
     - EXTEND  — existing file gains a new interface or public API surface
     - DEPEND  — new code will call/import this file read-only; no changes needed
     - AT_RISK — existing file might break due to changed behavior or shared state

RESPECT config exclusions:
  - Skip directories listed in exclude_directories
  - If scan_depth is "shallow", limit to directories in plan.md project structure
  - If scan_depth is "targeted", limit to scan_directories from config

OUTPUT: raw-hits table (internal, not in final report)
```

### Step 4: Build Integration Surface Map

<!-- GREP:CI-INTEGRATION-SURFACE -->
```
AGGREGATE raw hits from Step 3 into integration points:

  GROUP BY file → deduplicate → merge context

FOR each integration point, DETERMINE:
  - Integration Point: human-readable name
  - Type: data-model | middleware | route-config | shared-state | UI | configuration | infra | utility | test
  - Existing File/Module: path relative to repo root
  - Change Needed: one-line description of required modification
  - Risk: LOW (additive, backward-compatible) | MED (modifies behavior, needs testing) | HIGH (breaking change, affects public API)

OUTPUT: integration-surface table
  | Integration Point       | Type          | Existing File/Module           | Change Needed        | Risk  |
  |------------------------|---------------|--------------------------------|----------------------|-------|
```

### Step 5: Identify Affected Features

<!-- GREP:CI-AFFECTED-FEATURES -->
```
FROM the integration surface, IDENTIFY existing features (not files) that are affected:

  1. TRACE each MODIFY or AT_RISK file back to the feature it belongs to:
     - Check README, module docstrings, or directory-level documentation
     - Infer from directory structure (e.g., src/features/auth/ → "Authentication")
     - Check git log for recent feature branches that touched this file

  2. FOR each affected feature, ASSESS:
     - How it is affected (data model change, API change, UI change, behavioral change)
     - Regression risk: LOW (cosmetic, additive) | MED (functional, testable) | HIGH (breaking, user-facing)
     - Mitigation strategy: what to do to prevent regressions

OUTPUT: affected-features table
  | Existing Feature        | How Affected                    | Regression Risk | Mitigation                    |
  |------------------------|----------------------------------|-----------------|-------------------------------|
```

### Step 6: Audit Dependency Stability

<!-- GREP:CI-DEPENDENCY-STABILITY -->
```
SKIP this step if include_dependency_stability is false in config.

FOR each file classified as DEPEND (read-only dependency):

  1. CHECK git history:
     git log --oneline --since="6 months ago" -- <file> | wc -l

  2. CLASSIFY stability:
     - STABLE: 0-2 commits in 6 months, no open PRs touching it
     - ACTIVE: 3-10 commits in 6 months
     - VOLATILE: >10 commits or actively being refactored

  3. IDENTIFY the API surface the new feature will use:
     - Function/method names called
     - Classes instantiated or inherited
     - Constants or config values read

OUTPUT: dependency-stability table
  | Dependency              | Stability | Last Changed  | API Surface Used        |
  |------------------------|-----------|---------------|-------------------------|
```

### Step 7: Assess Test Impact

<!-- GREP:CI-TEST-IMPACT -->
```
SKIP this step if include_test_impact is false in config.

FOR each file classified as MODIFY or EXTEND:

  1. FIND associated test files:
     - Convention-based: test_<name>.py, <name>.test.ts, <name>_spec.rb, etc.
     - Import-based: grep test directories for imports of the modified module
     - Co-located: tests in the same directory

  2. FOR each test file found, DETERMINE:
     - Why it needs updating (new field, changed behavior, new route)
     - Whether new test cases are needed (not just updates)

OUTPUT: test-impact table
  | Test File                        | Reason                          |
  |---------------------------------|---------------------------------|
```

### Step 8: Generate IMPACT Task Candidates

<!-- GREP:CI-IMPACT-TASKS -->
```
FROM Steps 4-7, generate IMPACT-NNN checklist items:

NUMBERING: sequential, starting at IMPACT-001

FOR each MODIFY or EXTEND integration point:
  - [ ] IMPACT-NNN: <one-line description of change needed> (`<file path>`)

FOR each affected feature with MED or HIGH regression risk:
  - [ ] IMPACT-NNN: Add regression test for <feature> (<mitigation>)

FOR each test file that needs updates:
  - [ ] IMPACT-NNN: Update <test file> (<reason>)

SORT by risk (HIGH first), then by dependency order (foundational changes before dependent ones).

FORMAT (greppable):
  - [ ] IMPACT-NNN: risk | type | file-or-feature | description
  Shell: grep "\- \[ \] IMPACT-" codebase-impact.md
         sk-query.sh impact codebase-impact.md
```

### Step 9: Write Codebase Impact Report

Write `codebase-impact.md` to the feature directory:

<!-- GREP:CI-REPORT-TEMPLATE -->
```markdown
# Codebase Impact Analysis: [FEATURE NAME]

**Generated**: [DATE]
**Spec**: [spec.md path]
**Plan**: [plan.md path]

## Executive Summary

[2-3 sentences: total integration points found, number of files to modify,
number of affected features, overall risk assessment]

## Integration Surface

| Integration Point       | Type          | Existing File/Module           | Change Needed        | Risk  |
|------------------------|---------------|--------------------------------|----------------------|-------|
[table from Step 4]

### Summary
- **Total integration points**: [N]
- **Files to modify**: [N]
- **Files to extend**: [N]
- **Read-only dependencies**: [N]
- **At-risk files**: [N]

## Affected Features

| Existing Feature        | How Affected                    | Regression Risk | Mitigation                    |
|------------------------|----------------------------------|-----------------|-------------------------------|
[table from Step 5]

## Dependency Stability

| Dependency              | Stability | Last Changed  | API Surface Used        |
|------------------------|-----------|---------------|-------------------------|
[table from Step 6, or "Skipped per configuration" if disabled]

## Test Impact

| Test File                        | Reason                          |
|---------------------------------|---------------------------------|
[table from Step 7, or "Skipped per configuration" if disabled]

## Required Changes (Task Candidates)

<!--
  GREPPABLE FORMAT: each item MUST start with - [ ] IMPACT-NNN
  Format: - [ ] IMPACT-NNN: risk | type | file-or-feature | description
  Severity: HIGH | MED | LOW
  Type: data-model | middleware | route | event | UI | config | test | infra
  Shell: grep "\- \[ \] IMPACT-" codebase-impact.md
         sk-query.sh impact codebase-impact.md
-->

### HIGH Risk
- [ ] IMPACT-001: HIGH | type | file-or-feature | description

### MED Risk
- [ ] IMPACT-002: MED | type | file-or-feature | description

### LOW Risk
- [ ] IMPACT-003: LOW | type | file-or-feature | description
```

### Step 10: Update Plan with Impact Addendum

If the impact analysis reveals integration points or required changes not accounted for in `plan.md`, append a `## Codebase Impact Addendum` section to `plan.md` with:

- Files that require modification (not previously listed in the project structure)
- New tasks for existing-code changes that the plan did not anticipate
- Risk flags for volatile dependencies

## Output

The command produces `codebase-impact.md` in the feature spec directory and optionally updates `plan.md` with an impact addendum. The `IMPACT-NNN` items are designed as direct input for `speckit.tasks` so they appear as real tasks in the implementation pipeline.
