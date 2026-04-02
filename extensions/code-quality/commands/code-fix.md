---
description: "Auto-fix issues identified in the code review report"
---

# Code Fix

Read the code review report and systematically fix identified issues. Operates in cycles: fix → verify → re-check until clean or budget exhausted.

## User Input

$ARGUMENTS

## Prerequisites

1. `code-review.md` exists in `{feature_dir}/reviews/`
2. The review has actionable findings (Critical, High, or Medium severity)

## Steps

### Step 1: Load Review Report

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
review_file="$feature_dir/reviews/code-review.md"
```

Parse `code-review.md` for all findings. Prioritize by severity: Critical → High → Medium → Low.

### Step 2: Triage Findings

<!-- GREP:CQ-FIX-TRIAGE -->
```
CLASSIFY each finding:

  AUTO-FIXABLE (fix without confirmation):
    - Dead code removal (unused imports, unreachable code, commented blocks)
    - Formatting and naming consistency
    - Missing type annotations (additive only)
    - Simple duplication extraction

  SEMI-AUTO (fix with brief explanation):
    - Refactoring extractions (long method → helpers)
    - Code smell resolution (primitive obsession → value object)
    - Missing error handling addition
    - Test coverage gaps

  MANUAL (require user decision):
    - Architecture changes (layer violations, coupling)
    - API signature changes (breaking changes)
    - Performance optimizations (trade-off decisions)
    - Security-related changes

OUTPUT: fix-plan
  | Finding ID | Severity | Category   | Fix Type  | Estimated Effort |
  |------------|----------|------------|-----------|------------------|
  | RF01       | HIGH     | Refactor   | SEMI-AUTO | 15min            |
  | DC01       | LOW      | Dead Code  | AUTO      | 2min             |
  | TD01       | HIGH     | Tech Debt  | MANUAL    | 1h               |
```

### Step 3: Execute Fixes (Iterative Loop)

<!-- GREP:CQ-FIX-LOOP -->
```
FOR cycle = 1 TO max_fix_cycles:

  1. FIX all AUTO-FIXABLE items
  2. FIX all SEMI-AUTO items (with inline explanation)
  3. SKIP all MANUAL items (log for user action)

  4. VERIFY fixes:
     - Run linter on changed files
     - Run tests affected by changes
     - Check for regressions

  5. IF new issues introduced by fixes:
     - Add to fix queue
     - Continue to next cycle

  6. IF all auto/semi-auto fixes pass verification:
     - Break loop

  IF cycle > max_fix_cycles:
     - Log remaining unfixed items
     - Escalate to user

FIX RULES:
  - One logical change per commit-sized batch
  - Preserve existing test behavior
  - Add tests for any behavior change
  - Never change public API signatures without MANUAL classification
```

### Step 4: Generate Fix Report

Write `code-fix-report.md` to `{feature_dir}/reviews/`:

<!-- GREP:CQ-FIX-REPORT-TEMPLATE -->
```markdown
# Code Fix Report: [FEATURE NAME]

**Generated**: [DATE]
**Fix Cycles**: [N]
**Findings Addressed**: [N] / [Total]

## Fix Summary

| Category   | Auto-Fixed | Semi-Auto Fixed | Deferred (Manual) | Remaining |
|------------|-----------|-----------------|-------------------|-----------| 
| Refactoring| N         | N               | N                 | N         |
| Tech Debt  | N         | N               | N                 | N         |
| Dead Code  | N         | N               | N                 | N         |
| Code Smells| N         | N               | N                 | N         |

## Fixes Applied

| Finding ID | Fix Description                  | Files Changed        | Verified |
|------------|----------------------------------|----------------------|----------|
| DC01       | Removed unused format_legacy()   | src/utils.py         | ✅       |
| RF02       | Extracted shared validation util | src/utils.py, views  | ✅       |

## Deferred Items (require user action)

| Finding ID | Severity | Description              | Reason Deferred       |
|------------|----------|--------------------------|-----------------------|
| TD01       | HIGH     | N+1 query optimization   | Architecture decision  |

## Verification Results

| Check    | Status | Details                              |
|----------|--------|--------------------------------------|
| Lint     | ✅     | No new warnings                      |
| Tests    | ✅     | All passing (47/47)                  |
| Types    | ✅     | No new errors                        |
```

## Output

Produces `{feature_dir}/reviews/code-fix-report.md` and applies fixes to source files.
