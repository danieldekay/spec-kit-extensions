---
description: "Run the full quality pipeline: review → fix → validate → future ideas"
---

# Quality Pipeline

Orchestrate the full post-implementation quality pipeline in sequence. Each stage gates the next — if critical issues remain after fix, the pipeline pauses for user action.

## User Input

$ARGUMENTS

## Prerequisites

1. All tasks in `tasks.md` are marked `[x]`
2. `spec.md` with FR/NFR tables exists

## Steps

### Step 1: Initialize Pipeline

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
reviews_dir="$feature_dir/reviews"
mkdir -p "$reviews_dir"
```

<!-- GREP:CQ-PIPELINE-INIT -->
```
PIPELINE stages:
  1. CODE REVIEW   → code-review.md
  2. CODE FIX      → code-fix-report.md
  3. VALIDATE REQS → validation-report.md
  4. FUTURE IDEAS  → future-ideas.md

GATE rules:
  - Stage 2 requires Stage 1 output
  - Stage 3 runs independently (only needs spec.md + code)
  - Stage 4 runs after Stage 3
  - Pipeline pauses if Stage 2 has unresolved CRITICAL findings
```

### Step 2: Execute Code Review

<!-- GREP:CQ-PIPELINE-REVIEW -->
```
RUN /speckit.fleet.code-review

CHECK output:
  - code-review.md exists in reviews/
  - Parse finding counts by severity

GATE:
  IF 0 findings → skip Stage 3 (fix), proceed to Stage 4
  IF findings exist → proceed to Stage 3
```

### Step 3: Execute Code Fix

<!-- GREP:CQ-PIPELINE-FIX -->
```
RUN /speckit.fleet.code-fix

CHECK output:
  - code-fix-report.md exists in reviews/
  - Parse remaining unresolved items

GATE:
  IF unresolved CRITICAL items > 0 →
    PAUSE pipeline
    ASK user: "Critical issues remain after fix. Continue or address manually?"
    IF continue → proceed
    IF address → STOP pipeline

  IF all resolved or only LOW/MEDIUM deferred → proceed
```

### Step 4: Validate Requirements

<!-- GREP:CQ-PIPELINE-VALIDATE -->
```
RUN /speckit.fleet.validate-requirements

CHECK output:
  - validation-report.md exists in reviews/
  - Parse overall validation score

GATE:
  IF validation score < 80% →
    WARN user with gap summary
    ASK: "Continue to future ideas or address gaps first?"

  IF validation score >= 80% → proceed
```

### Step 5: Generate Future Ideas

<!-- GREP:CQ-PIPELINE-FUTURE -->
```
RUN /speckit.fleet.future-ideas

CHECK output:
  - future-ideas.md exists in reviews/
```

### Step 6: Generate Pipeline Summary

Write `quality-summary.md` to `{feature_dir}/reviews/`:

<!-- GREP:CQ-PIPELINE-SUMMARY -->
```markdown
# Quality Pipeline Summary: [FEATURE NAME]

**Generated**: [DATE]
**Pipeline Duration**: [time]

## Stage Results

| Stage           | Status | Artifacts                | Key Metric           |
|-----------------|--------|--------------------------|----------------------|
| Code Review     | ✅/⚠️  | code-review.md           | N findings           |
| Code Fix        | ✅/⚠️  | code-fix-report.md       | N fixed / N deferred |
| Validate Reqs   | ✅/⚠️  | validation-report.md     | N% validated         |
| Future Ideas    | ✅     | future-ideas.md          | N ideas generated    |

## Critical Items

[Any unresolved critical findings or missing requirements]

### Step 7: specfact Sync (conditional)

<!-- GREP:CQ-PIPELINE-SF-SYNC -->

```bash
config_file=".specify/extensions/code-quality/code-quality-config.yml"
sync_after_pipeline=$(yq eval '.code_quality.specfact.sync_after_pipeline // false' "$config_file" 2>/dev/null || echo "false")
```

If `sync_after_pipeline` is `true` in config:
```
PRINT: "🔗 sync_after_pipeline is enabled — exporting quality findings to specfact..."
RUN speckit.fleet.specfact-sync
```

Otherwise:
```
💡 To export all quality findings to specfact, run:  /speckit.fleet.specfact-sync
```

## Artifacts Generated

All reports saved to: `{feature_dir}/reviews/`
- `code-review.md` — refactoring, tech debt, dead code, code smells
- `code-fix-report.md` — fixes applied and deferred items
- `validation-report.md` — FR/NFR traceability, testability, docs
- `future-ideas.md` — improvement roadmap
- `quality-summary.md` — this summary
- `quality-export.json` — specfact-compatible export (when `sync_after_pipeline: true` or `/speckit.fleet.specfact-sync` is run)

## Next Steps

[Recommended actions based on pipeline results]
```

## Output

Runs all 4 stages sequentially with gates. Produces 5 report files in `{feature_dir}/reviews/` plus an optional `quality-export.json` for specfact governance.
