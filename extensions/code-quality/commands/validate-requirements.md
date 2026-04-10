---
description: "Validate FR/NFR implementation, testability, and documentation coverage against spec"
---

# Validate Requirements

Systematically verify that all Functional Requirements (FR) and Non-Functional Requirements (NFR) from the specification are implemented, testable, and documented.

## User Input

$ARGUMENTS

## Prerequisites

1. `spec.md` exists with FR/NFR tables
2. Implementation is complete (all tasks `[x]`)
3. Test files exist for the feature

## Steps

### Step 1: Load Requirements

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
```

Parse `spec.md` for:
- Functional Requirements table (FR1, FR2, ...)
- Non-Functional Requirements table (NFR1, NFR2, ...)
- User stories and acceptance criteria

### Step 2: Validate Functional Requirements

<!-- GREP:CQ-VALIDATE-FR -->
```
FOR each FR in spec.md:

  1. LOCATE implementation:
     - Search codebase for code implementing this requirement
     - Map to specific files, classes, and functions

  2. VERIFY completeness:
     - Does the implementation cover all acceptance criteria?
     - Are edge cases handled (empty input, max values, concurrent access)?
     - Are error paths implemented (not just happy path)?

  3. SCORE:
     ✅ IMPLEMENTED — fully implemented and matches spec
     ⚠️ PARTIAL     — implemented but missing edge cases or criteria
     ❌ MISSING      — not implemented or significantly deviates
     🔄 CHANGED     — implemented but spec evolved during implementation

OUTPUT: fr-validation table
  | FR ID | Requirement               | Status | Implementation Location    | Notes              |
  |-------|---------------------------|--------|----------------------------|--------------------|
  | FR1   | User registration         | ✅     | src/auth/register.py:45    | All criteria met   |
  | FR2   | Email verification        | ⚠️     | src/auth/verify.py:20      | Missing retry logic|
  | FR3   | Password reset            | ❌     | —                          | Not implemented    |
```

### Step 3: Validate Non-Functional Requirements

<!-- GREP:CQ-VALIDATE-NFR -->
```
FOR each NFR in spec.md:

  PERFORMANCE:
    - Are there measurable benchmarks?
    - Is the implementation within stated thresholds?
    - Are there obvious bottlenecks?

  SECURITY:
    - Input validation on all user-facing endpoints
    - Output escaping/sanitization
    - Authentication and authorization checks
    - No sensitive data in logs or error messages

  ACCESSIBILITY:
    - ARIA labels and roles present
    - Keyboard navigation supported
    - Color contrast meets WCAG AA
    - Screen reader compatible

  RELIABILITY:
    - Error recovery paths
    - Graceful degradation
    - Timeout handling
    - Retry logic where appropriate

  COMPATIBILITY:
    - Browser/platform requirements met
    - API versioning strategy

OUTPUT: nfr-validation table
  | NFR ID | Category      | Requirement                | Status | Evidence                    |
  |--------|---------------|----------------------------|--------|-----------------------------|
  | NFR1   | Performance   | API response < 200ms       | ✅     | Measured: avg 120ms         |
  | NFR2   | Security      | All inputs sanitized       | ⚠️     | Missing: file upload check  |
  | NFR3   | Accessibility | WCAG AA compliance         | ❌     | Missing: keyboard nav       |
```

### Step 4: Testability Assessment

<!-- GREP:CQ-VALIDATE-TESTABILITY -->
```
FOR each FR and NFR:

  1. CHECK test existence:
     - Is there at least one test covering this requirement?
     - Does the test verify the acceptance criteria (not just code coverage)?

  2. ASSESS test quality:
     - Does the test assert the right thing?
     - Is the test deterministic (no flaky timing/ordering)?
     - Does it test behavior (not implementation details)?
     - Are both success and failure paths tested?

  3. CALCULATE coverage:
     - [N] / [Total] FRs have dedicated tests
     - [N] / [Total] NFRs have verification tests
     - Overall testability score

OUTPUT: testability matrix
  | Req ID | Type | Test File                      | Tests | Passes | Quality  | Gaps                   |
  |--------|------|--------------------------------|-------|--------|----------|------------------------|
  | FR1    | FR   | tests/test_registration.py     | 5     | 5      | Good     | Missing: concurrent    |
  | FR2    | FR   | tests/test_verify.py           | 3     | 3      | Partial  | Missing: retry test    |
  | NFR1   | NFR  | tests/test_performance.py      | 1     | 1      | Minimal  | No load test           |
  | NFR3   | NFR  | —                              | 0     | —      | MISSING  | No a11y tests          |
```

### Step 5: Documentation Coverage

<!-- GREP:CQ-VALIDATE-DOCS -->
```
CHECK documentation at three levels:

  CODE-LEVEL:
    - Public functions/classes have docstrings
    - Complex logic has inline comments explaining WHY
    - Type annotations present

  FEATURE-LEVEL:
    - README or docs cover the new feature
    - API docs exist for new endpoints
    - Configuration options documented
    - Error codes and messages documented

  USER-LEVEL:
    - User-facing help text present
    - Migration guide (if breaking changes)
    - Changelog entry prepared

OUTPUT: documentation table
  | Level    | Item                    | Status | Location              | Gap                    |
  |----------|-------------------------|--------|-----------------------|------------------------|
  | Code     | Auth service docstrings | ✅     | src/auth/service.py   | —                      |
  | Feature  | API endpoint docs       | ⚠️     | docs/api.md           | Missing: error codes   |
  | User     | Changelog entry         | ❌     | —                     | Not created            |
```

### Step 6: Generate Validation Report

Write `validation-report.md` to `{feature_dir}/reviews/`:

<!-- GREP:CQ-VALIDATE-TEMPLATE -->
```markdown
# Requirements Validation: [FEATURE NAME]

**Generated**: [DATE]
**Spec**: [spec.md path]

## Summary

| Category          | Total | ✅ Passed | ⚠️ Partial | ❌ Missing |
|-------------------|-------|-----------|-----------|-----------|
| Functional Reqs   | N     | N         | N         | N         |
| Non-Functional    | N     | N         | N         | N         |
| Test Coverage     | N     | N         | N         | N         |
| Documentation     | N     | N         | N         | N         |

**Overall Score**: [N]% requirements validated

## Functional Requirements
[table from Step 2]

## Non-Functional Requirements
[table from Step 3]

## Testability Assessment
[matrix from Step 4]

### Test Coverage Score: [N]% of requirements have dedicated tests

## Documentation Coverage
[table from Step 5]

## Critical Gaps (must address before ship)

1. [Gap description — requirement ID — action needed]

## Recommended Actions

### Before Ship
- [Action items for missing/partial requirements]

### After Ship
- [Action items for nice-to-have improvements]
```

## Output

Produces `{feature_dir}/reviews/validation-report.md` with comprehensive requirement traceability.

---

### Step 7: Bridge to dod.yml (if dod extension installed)

<!-- GREP:CQ-VALIDATE-DOD-BRIDGE -->

If the `dod` extension is also active in this workspace, propagate the validation results back into `dod.yml` so both extensions share a single source of truth.

```bash
config_file=".specify/extensions/code-quality/code-quality-config.yml"
update_dod=$(yq eval '.code_quality.specfact.update_dod // true' "$config_file" 2>/dev/null || echo "true")
dod_file="$feature_dir/dod.yml"

if [[ "$update_dod" == "true" ]] && [[ -f "$dod_file" ]]; then
  echo "📎 dod.yml found — bridging validation results..."
else
  echo "ℹ️  Skipping dod.yml bridge (not installed or update_dod: false)"
fi
```

When `update_dod` is true and `dod.yml` exists:

```
FOR each FR in validation-report.md:
  FIND the matching FR ID in dod.yml.functional_requirements

  IF FR status is ✅ IMPLEMENTED:
    FOR each criterion in dod.yml FR that has evidence.test_files non-empty:
      SET criterion.status: "passed"    (only if not already "failed")
    COMPUTE FR aggregate status

  IF FR status is ❌ MISSING:
    FOR each criterion in dod.yml FR:
      IF criterion.status is "pending":
        SET criterion.status: "failed"
        APPEND evidence.notes: "Not implemented per speckit.code-quality.validate"

  IF FR status is ⚠️ PARTIAL:
    Leave criterion statuses as-is; append a note to FR.implementation.status_note

FOR each NFR in validation-report.md:
  FIND the matching NFR ID in dod.yml.non_functional_requirements

  IF NFR has evidence (e.g. measured value):
    SET matching NFR criterion evidence.result and evidence.measured_at
    IF measured value passes the threshold operator:
      SET criterion.status: "passed"
    ELSE:
      SET criterion.status: "failed"

UPDATE dod.yml gates:
  Re-evaluate ready_for_sprint and definition_of_done based on new statuses
  SET meta.last_validated_at to current timestamp

PRINT: "✅ dod.yml updated from validation results"
```

### Step 8: specfact Export (conditional)

<!-- GREP:CQ-VALIDATE-SF-EXPORT -->

```bash
sync_after_validate=$(yq eval '.code_quality.specfact.sync_after_validate // false' "$config_file" 2>/dev/null || echo "false")
```

If `sync_after_validate` is `true` in config:
```
PRINT: "🔗 sync_after_validate is enabled — running speckit.code-quality.specfact-sync..."
RUN speckit.code-quality.specfact-sync
```

Otherwise:
```
💡 To push quality results to specfact:  /speckit.code-quality.specfact-sync
💡 To update DoD enforcement gate:       /speckit.dod.export  (if dod extension is installed)
```
