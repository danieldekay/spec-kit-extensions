---
description: "Validate the current implementation against dod.yml, update criterion statuses, and write a dod-validation-report.md"
---

# DoD Validate

Check every criterion in `dod.yml` against the current implementation. For each FR criterion — find test files and test IDs. For each NFR criterion — measure or audit the implementation against the defined threshold. Update statuses (`pending` → `passed`/`failed`/`skipped`) in-place in `dod.yml` and write a human-readable `dod-validation-report.md`.

This command is the source of truth for the CI gate: after running it, `speckit.fleet.dod-export` can push results to specfact for enforcement.

## User Input

$ARGUMENTS

## Prerequisites

1. `dod.yml` exists in the active feature directory (created by `speckit.fleet.dod-generate`)
2. Implementation tasks are complete (all `[x]` in `tasks.md`)
3. Tests have been written

## Steps

### Step 1: Load Context

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
feature_id=$(basename "$feature_dir")
dod_file="$feature_dir/dod.yml"
spec_file="$feature_dir/spec.md"
report_file="$feature_dir/dod-validation-report.md"
config_file=".specify/extensions/dod/dod-config.yml"
```

Abort if `dod.yml` does not exist. Instruct the user to run `speckit.fleet.dod-generate` first.

Load config:
```bash
export_on_validate=$(yq eval '.dod.specfact.export_on_validate // false' "$config_file" 2>/dev/null || echo "false")
export_path=$(yq eval '.dod.specfact.export_path // ".specfact/dod-exports"' "$config_file" 2>/dev/null || echo ".specfact/dod-exports")
```

### Step 2: Validate Functional Requirements

<!-- GREP:DOD-VALIDATE-FR -->
```
FOR each FR in dod.yml:
  FOR each criterion in FR.criteria:

    STEP A — Locate test evidence
      SEARCH test directories for test files that cover this criterion:
        - Look in: tests/, test/, spec/, __tests__/, src/**/*test*, src/**/*spec*
        - Search for test names or comments referencing this criterion ID (FR#-C#)
        - Search for assertion patterns matching the "then" clause keywords
        - Search for Given/When/Then annotations (pytest-bdd, Cucumber, RSpec, Jest)

      RECORD all matching file paths in criterion.evidence.test_files
      RECORD matching test function names or IDs in criterion.evidence.test_ids

    STEP B — Assess test quality
      IF evidence.test_files is non-empty:
        CHECK that the test actually asserts the "then" outcome (not just calls code)
        CHECK that both the happy path and expected error are covered by type
        IF assertion quality is adequate → set criterion.status: "passed"
        IF assertion is too shallow (e.g. only checks HTTP 200 without body) → set criterion.status: "failed"
           Add a note: "Test exists but does not assert: <missing assertion>"
      ELSE:
        SET criterion.status: "failed"
        Add criterion.evidence.notes: "No test file found covering this criterion"

    STEP C — Locate implementation files
      SEARCH source directories for files implementing this FR:
        - Look for functions, classes, routes, handlers related to the FR description
        - Record in FR.implementation.files

COMPUTE FR aggregate status:
  ALL criteria passed → FR.status: "passed"
  ANY criterion failed → FR.status: "failed"
  ALL criteria skipped → FR.status: "skipped"
  Otherwise           → FR.status: "pending"
```

### Step 3: Validate Non-Functional Requirements

<!-- GREP:DOD-VALIDATE-NFR -->
```
FOR each NFR in dod.yml:
  FOR each criterion in NFR.criteria:

    DETERMINE validation approach from criterion.type and criterion.measurement.method:

    IF type is "threshold":
      ATTEMPT to find existing benchmark / monitoring data:
        - Check for benchmark result files: *.k6-results.json, benchmark-results.json, perf-report.*
        - Check for CI artifacts in CI output or test result directories
        - Check for performance test output in the feature's test directory
      IF results found:
        PARSE the relevant metric from the result file
        COMPARE to criterion.operator + criterion.value + criterion.unit
        IF passes → set criterion.status: "passed", set criterion.evidence.result + measured_at
        IF fails  → set criterion.status: "failed", set criterion.evidence.result + note
      IF no results found:
        SET criterion.status: "pending"
        ADD criterion.evidence.notes: "No benchmark results found. Run: <criterion.measurement.command>"

    IF type is "audit" or "compliance":
      CHECK for SAST / linting / audit report files (e.g. semgrep-report.json, bandit.json, eslint-report.json)
      IF a report is found with no critical findings → set criterion.status: "passed"
      IF a report is found with critical findings   → set criterion.status: "failed"
        Record the finding summary in criterion.evidence.notes
      IF no report found:
        SET criterion.status: "pending"
        ADD criterion.evidence.notes: "Run the audit tool: <criterion.measurement.tool>"

    IF type is "coverage":
      CHECK for coverage reports: coverage.xml, coverage.json, lcov.info
      PARSE the coverage percentage
      COMPARE to the threshold value
      Record result and set status accordingly

COMPUTE NFR aggregate status using same logic as FR.
```

### Step 4: Evaluate Gates

<!-- GREP:DOD-VALIDATE-GATES -->
```
EVALUATE gates.ready_for_sprint:
  Run each check:
  ✓ "Each FR has at least one criterion with non-empty given/when/then"
     → true if all FR criteria have non-empty given, when, then fields
  ✓ "Each NFR criterion has a measurement method and threshold or audit plan"
     → true if all NFR criteria have measurement.method set and either (value is not null) or (type is audit/compliance/coverage)
  ✓ "test_strategy is set for all FR criteria"
     → true if no FR criterion has an empty test_strategy
  ✓ "No FR or NFR has status 'failed'"
     → true if no FR or NFR has status failed

  SET gates.ready_for_sprint.status:
    ALL checks true → "passed"
    ANY check false → "failed"

EVALUATE gates.definition_of_done:
  Run each check:
  ✓ "All FR criteria have status 'passed'"
  ✓ "All NFR criteria have status 'passed'"
  ✓ "gates.ready_for_sprint.status is 'passed'"
  ✓ "All FR criteria have at least one entry in evidence.test_files"
  ✓ "All NFR threshold criteria have a non-null evidence.result"

  SET gates.definition_of_done.status accordingly.
```

### Step 5: Update dod.yml

Write the updated statuses, evidence, and gate evaluations back to `dod.yml`. Preserve all hand-edited fields (criterion descriptions, given/when/then scenarios, measurement commands). Only update:
- `criterion.status`
- `criterion.evidence.*`
- `FR.implementation.files`
- `gates.*.status`
- `meta.last_validated_at` (set to current ISO 8601 timestamp)

### Step 6: Write Validation Report

Write `$feature_dir/dod-validation-report.md`:

```markdown
# DoD Validation Report — <feature_id>

**Validated**: <timestamp>
**Gate: ready_for_sprint**: <status emoji>
**Gate: definition_of_done**: <status emoji>

## Functional Requirements

| FR ID | Title | Criteria | Passed | Failed | Status |
|-------|-------|----------|--------|--------|--------|
...

### FR Failures / Open Items

For each failed criterion:
  - **<FRn-Cm>**: <description>
    - Missing: <what is missing>
    - Suggested fix: <where to add the test>

## Non-Functional Requirements

| NFR ID | Category | Title | Status | Evidence |
|--------|----------|-------|--------|----------|
...

### NFR Failures / Open Items

For each failed or pending NFR criterion:
  - **<NFRn-Cn>**: <description>
    - Status: <pending|failed>
    - Next step: <run command / add test>

## Gate Summary

| Gate                | Status | Blocking |
|---------------------|--------|----------|
| ready_for_sprint    | <status> | Sprint entry |
| definition_of_done  | <status> | Release |

## Coverage

  FR coverage:   <n>/<total> criteria passed (<pct>%)
  NFR coverage:  <n>/<total> criteria passed (<pct>%)
  Overall DoD:   <passed|pending|failed>
```

### Step 7: Conditional specfact Export

If `export_on_validate` is `true` in config, automatically invoke `speckit.fleet.dod-export` after writing the report:

```
PRINT: "🔗 export_on_validate is enabled — running speckit.fleet.dod-export..."
RUN speckit.fleet.dod-export
```

Otherwise print:
```
💡 To push results to specfact, run: /speckit.fleet.dod-export
```

### Step 8: Final Summary

```
✅  Validation complete

  Functional Requirements:       <n_passed>/<n_fr> passed
  Non-Functional Requirements:   <n_passed>/<n_nfr> passed

  ready_for_sprint:    <status>
  definition_of_done:  <status>

  Report: <report_file>
  dod.yml updated: <dod_file>
```

If `definition_of_done` gate is `failed`, list the top-3 highest-priority open items.
