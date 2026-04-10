---
id: speckit.code-quality.specfact-sync
alias: speckit.code-quality.sf
description: >
  Aggregates all code-quality review artifacts into a specfact-compatible
  quality-export.json and optionally runs `specfact govern check` against the
  project bundle. Supports enforcement levels observe / warn / enforce.
arguments:
  - name: --enforcement
    type: string
    enum: [observe, warn, enforce]
    required: false
    description: Override the enforcement level from config for this run.
  - name: --feature
    type: string
    required: false
    description: Feature directory name (defaults to current feature context).
  - name: --dry-run
    type: boolean
    required: false
    default: false
    description: Build the export JSON but skip running specfact govern check.
version: "1.0"
---

# speckit.code-quality.specfact-sync

Export code-quality findings to specfact and run governance checks.

---

### Step 1: Load Context

<!-- GREP:CQ-SF-LOAD-CONTEXT -->

```bash
# Resolve feature directory
feature_dir="${feature_dir:-$(cat .specify/.context/current-feature 2>/dev/null)}"
if [[ -z "$feature_dir" ]]; then
  echo "❌ No feature context found. Run from inside a feature directory or set feature_dir."
  exit 1
fi

config_file=".specify/extensions/code-quality/code-quality-config.yml"

project_id=$(yq eval '.code_quality.specfact.project_id // ""' "$config_file" 2>/dev/null)
enforcement_level=$(yq eval '.code_quality.specfact.enforcement_level // "observe"' "$config_file" 2>/dev/null)
export_path=$(yq eval '.code_quality.specfact.export_path // ".specfact/quality-exports"' "$config_file" 2>/dev/null)

# CLI argument overrides config
if [[ -n "$ARGUMENT_enforcement" ]]; then
  enforcement_level="$ARGUMENT_enforcement"
fi

reviews_dir="$feature_dir/reviews"
export_file="$reviews_dir/quality-export.json"

echo "📂 Feature: $feature_dir"
echo "📊 Enforcement: $enforcement_level"
echo "📁 Export path: $export_path"
```

---

### Step 2: Gather Quality Artifacts

<!-- GREP:CQ-SF-GATHER -->

Load each review artifact and extract structured data:

**From `code-review.md`** (if present):
```
PARSE review findings:
  critical_count   = count lines matching "🔴|CRITICAL|Severity: critical" (case-insensitive)
  high_count       = count "🟠|HIGH|Severity: high"
  medium_count     = count "🟡|MEDIUM|Severity: medium"
  low_count        = count "🟢|LOW|Severity: low"
  debt_items       = count "Tech Debt" section items
  dead_code_items  = count "Dead Code" section items
  smell_count      = count "Code Smell" items
  reviewed_at      = file mtime (ISO 8601)
```

**From `code-fix-report.md`** (if present):
```
PARSE fix report:
  fixes_applied    = count "✅ Applied" items
  fixes_deferred   = count "⏸ Deferred" items
  fixes_rejected   = count "❌ Rejected" items
  fixed_at         = file mtime (ISO 8601)
```

**From `validation-report.md`** (if present):
```
PARSE validation results:
  fr_total         = count FR rows in summary table
  fr_implemented   = count "✅ IMPLEMENTED" rows
  fr_partial       = count "⚠️ PARTIAL" rows
  fr_missing       = count "❌ MISSING" rows
  nfr_total        = count NFR rows
  nfr_met          = count "✅ MET" rows
  nfr_at_risk      = count "⚠️ AT RISK" rows
  nfr_failing      = count "❌ FAILING" rows
  testability_pct  = extract "Testability Coverage" percentage
  docs_coverage    = extract "Documentation Coverage" percentage
  validated_at     = file mtime (ISO 8601)
```

**From `quality-summary.md`** (if present):
```
PARSE summary:
  overall_score    = extract numeric score (0-100)
  gate_status      = "PASS" | "FAIL" | "CONDITIONAL"
  summarized_at    = file mtime (ISO 8601)
```

If any artifact is missing, record `"available": false` for that section and use `null` values.

---

### Step 3: Compute Derived Metrics

<!-- GREP:CQ-SF-METRICS -->

```
fr_coverage_pct  = round(fr_implemented / fr_total * 100) if fr_total > 0 else null
nfr_coverage_pct = round(nfr_met / nfr_total * 100) if nfr_total > 0 else null

review_health = "green"  if critical_count == 0 and high_count == 0
              | "yellow" if critical_count == 0 and high_count <= 2
              | "red"    if critical_count > 0 or high_count > 2

validation_health = "green"  if fr_missing == 0 and nfr_failing == 0
                  | "yellow" if fr_missing == 0 or nfr_failing == 0
                  | "red"    if fr_missing > 0 and nfr_failing > 0

overall_health = "green"  if review_health == "green"  and validation_health == "green"
               | "yellow" if review_health != "red"    and validation_health != "red"
               | "red"    otherwise
```

---

### Step 4: Write quality-export.json

<!-- GREP:CQ-SF-EXPORT-JSON -->

Write `quality-export.json` to `$reviews_dir/` with the schema below. This file is also the target
artifact consumed by `specfact govern check --quality-report <path>`.

```json
{
  "$schema_id": "speckit-quality-export-v1",
  "speckit_version": "1.0",
  "exported_at": "<ISO 8601 timestamp>",
  "feature": {
    "id": "<feature dir name>",
    "path": "<feature_dir>"
  },
  "config": {
    "enforcement_level": "<enforcement_level>",
    "specfact_project_id": "<project_id or null>"
  },
  "health": {
    "overall": "<overall_health>",
    "review": "<review_health>",
    "validation": "<validation_health>"
  },
  "review": {
    "available": true,
    "reviewed_at": "<ISO 8601>",
    "findings": {
      "critical": "<critical_count>",
      "high": "<high_count>",
      "medium": "<medium_count>",
      "low": "<low_count>"
    },
    "tech_debt_items": "<debt_items>",
    "dead_code_items": "<dead_code_items>",
    "code_smells": "<smell_count>"
  },
  "fixes": {
    "available": true,
    "fixed_at": "<ISO 8601>",
    "applied": "<fixes_applied>",
    "deferred": "<fixes_deferred>",
    "rejected": "<fixes_rejected>"
  },
  "validation": {
    "available": true,
    "validated_at": "<ISO 8601>",
    "functional_requirements": {
      "total": "<fr_total>",
      "implemented": "<fr_implemented>",
      "partial": "<fr_partial>",
      "missing": "<fr_missing>",
      "coverage_pct": "<fr_coverage_pct>"
    },
    "non_functional_requirements": {
      "total": "<nfr_total>",
      "met": "<nfr_met>",
      "at_risk": "<nfr_at_risk>",
      "failing": "<nfr_failing>",
      "coverage_pct": "<nfr_coverage_pct>"
    },
    "testability_pct": "<testability_pct>",
    "docs_coverage_pct": "<docs_coverage>"
  },
  "summary": {
    "available": true,
    "overall_score": "<overall_score>",
    "gate_status": "<gate_status>",
    "summarized_at": "<ISO 8601>"
  },
  "gates": {
    "review_gate": {
      "status": "<PASS if review_health != 'red' else FAIL>",
      "rule": "No critical or more than 2 high severity findings"
    },
    "implementation_gate": {
      "status": "<PASS if fr_missing == 0 else FAIL>",
      "rule": "All functional requirements must be implemented"
    },
    "quality_gate": {
      "status": "<gate_status>",
      "rule": "Overall quality score as determined by pipeline summary"
    }
  },
  "enforcement": {
    "level": "<enforcement_level>",
    "fail_on": ["review_gate", "implementation_gate", "quality_gate"]
  }
}
```

Print: `✅ quality-export.json written to $reviews_dir/`

Optionally also copy to `$export_path/<feature-id>-quality-export.json` if `export_path` differs from reviews dir.

---

### Step 5: Run specfact govern check (conditional)

<!-- GREP:CQ-SF-GOVERN -->

```bash
if [[ "$ARGUMENT_dry_run" == "true" ]]; then
  echo "⚗️  Dry-run mode — skipping specfact govern check."
  exit 0
fi

if [[ -z "$project_id" ]]; then
  echo "ℹ️  specfact.project_id not set — skipping govern check."
  echo "   Set code_quality.specfact.project_id in $config_file to enable."
else
  echo "🔍 Running: specfact govern check..."
fi
```

When `project_id` is configured:

```bash
bundle_path=".specfact/projects/$project_id"

if [[ ! -d "$bundle_path" ]]; then
  echo "⚠️  Bundle not found at $bundle_path"
  echo "   Run: specfact project init --id $project_id  to initialise"
  exit 1
fi

uvx specfact-cli@latest govern check \
  --bundle "$bundle_path" \
  --quality-report "$export_file" \
  --enforcement "$enforcement_level"
```

**Exit code behaviour by enforcement level:**

| Level     | Effect on CI |
|-----------|-------------|
| `observe` | Always exit 0; findings logged to stdout |
| `warn`    | Always exit 0; failed gates produce warnings |
| `enforce` | Exit 1 if any gate in `enforcement.fail_on[]` is FAIL |

---

### Step 6: Print CI Integration Guidance

<!-- GREP:CQ-SF-CI-GUIDANCE -->

Always print CI guidance so teams can wire this into their pipelines:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CI/CD Integration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Add to your GitHub Actions workflow:

  - name: Quality Gate (specfact)
    run: |
      uvx specfact-cli@latest govern check \
        --bundle .specfact/projects/<YOUR_PROJECT_ID> \
        --quality-report ${{ env.FEATURE_DIR }}/reviews/quality-export.json \
        --enforcement enforce

Enforcement levels:
  observe  → log only, never fails CI
  warn     → warnings in PR comment, never fails CI
  enforce  → fails CI if review_gate, implementation_gate, or quality_gate is FAIL

Current enforcement: <enforcement_level>

Tip: Generate the export file as part of your agent pipeline by setting:
  code_quality.specfact.sync_after_pipeline: true

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Output

Produces `{feature_dir}/reviews/quality-export.json` in the `speckit-quality-export-v1` format.
Optionally runs `specfact govern check` if `specfact.project_id` is configured.
Always prints CI integration guidance.
