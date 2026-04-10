---
description: "Export dod.yml to specfact-compatible JSON for CI/CD enforcement and specfact governance checks"
---

# DoD Export

Read the current `dod.yml` and produce a `dod-export.json` in the specfact export schema (`speckit-dod-export-v1`). The export file can be consumed by the specfact CLI for governance, drift detection, and pipeline enforcement.

## User Input

$ARGUMENTS

Optional flags passed as arguments:
- `--enforcement observe|warn|enforce` — override the enforcement level from config
- `--output <path>` — override the output file path
- `--feature <id>` — override the feature ID (useful in CI with a fixed path)

## Prerequisites

1. `dod.yml` exists in the active feature directory
2. The specfact CLI is available if you want to push the export directly (`uvx specfact-cli@latest`)

## Steps

### Step 1: Load Context

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
feature_id=$(basename "$feature_dir")
dod_file="$feature_dir/dod.yml"
config_file=".specify/extensions/dod/dod-config.yml"

# Resolve output path
default_export_path=$(yq eval '.dod.specfact.export_path // ".specfact/dod-exports"' "$config_file" 2>/dev/null || echo ".specfact/dod-exports")
export_file="${default_export_path}/${feature_id}-dod-export.json"

# Allow --output override from $ARGUMENTS
if echo "$ARGUMENTS" | grep -q -- '--output'; then
  export_file=$(echo "$ARGUMENTS" | grep -oP '(?<=--output )\S+')
fi

# Resolve enforcement level
enforcement_level=$(yq eval '.dod.enforcement_level // "observe"' "$config_file" 2>/dev/null || echo "observe")
if echo "$ARGUMENTS" | grep -q -- '--enforcement'; then
  enforcement_level=$(echo "$ARGUMENTS" | grep -oP '(?<=--enforcement )\S+')
fi

mkdir -p "$(dirname "$export_file")"
```

Abort if `dod.yml` does not exist. Instruct the user to run `speckit.dod.generate` first.

### Step 2: Build the Export Payload

<!-- GREP:DOD-EXPORT-BUILD -->
```
READ dod.yml in full.

BUILD dod-export.json with schema_id "speckit-dod-export-v1":

meta fields:
  $schema_id:           "speckit-dod-export-v1"
  version:              "1.0"
  feature:              <meta.feature_id>
  feature_tag:          <specfact.feature_tag or null>
  spec_file:            <meta.spec_file>
  generated_at:         <current ISO 8601 timestamp>
  speckit_dod_version:  <meta.dod_version>

requirements.functional:
  FOR each FR in dod.yml.functional_requirements:
    COMPUTE:
      criteria_total:  count(FR.criteria)
      criteria_passed: count(criteria where status == "passed")
      criteria_failed: count(criteria where status == "failed")
      testable:        true if ALL criteria have at least one test_file entry OR test_id entry
    MAP FR.criteria to export criteria format:
      - id, description, type
      - scenario: { given, when, then }
      - test_strategy, status
      - test_files (from evidence.test_files)
      - test_ids (from evidence.test_ids)

requirements.non_functional:
  FOR each NFR in dod.yml.non_functional_requirements:
    COMPUTE:
      criteria_total, criteria_passed, criteria_failed
      measurable: true if ALL criteria have measurement.method AND either (value != null) OR (type != "threshold")
    MAP NFR.criteria to export criteria format:
      - id, description, type
      - metric, threshold: { operator, value, unit }
      - measurement_method (from measurement.method)
      - measurement_tool (from measurement.tool)
      - measurement_command (from measurement.command)
      - status
      - measured_value (from evidence.result)
      - measured_at (from evidence.measured_at)

requirements.summary:
  fr_total:   count(functional_requirements)
  fr_passed:  count(FRs where status == "passed")
  fr_failed:  count(FRs where status == "failed")
  fr_pending: count(FRs where status == "pending")
  nfr_total, nfr_passed, nfr_failed, nfr_pending: same pattern
  overall_status:
    IF all FRs and NFRs are "passed" → "passed"
    IF any FR or NFR is "failed"     → "failed"
    ELSE                             → "pending"

gates:
  ready_for_sprint:
    status: <from dod.yml>
    checks: evaluate each check and mark passed: true/false
  definition_of_done:
    status: <from dod.yml>
    checks: evaluate each check and mark passed: true/false

enforcement:
  level: <enforcement_level from config or argument>
  fail_on: ["definition_of_done"]  (always; set "ready_for_sprint" if enforcement level is "enforce")
```

### Step 3: Validate the Export

If `jsonschema` is available, validate the generated JSON against the export schema:

```bash
if command -v jsonschema &>/dev/null; then
  jsonschema -i "$export_file" extensions/dod/schemas/specfact-export.schema.json \
    && echo "✅ Export schema valid" \
    || echo "⚠️  Export has schema violations"
fi
```

### Step 4: Write Export File

Write the final JSON to `$export_file`. Use compact JSON (no trailing whitespace) but pretty-print for readability.

Update `dod.yml`:
```yaml
specfact:
  last_exported_at: <current ISO 8601 timestamp>
```

### Step 5: Show specfact Integration Guidance

Print the following usage instructions tailored to the current project state:

```
✅  Export written to: <export_file>

SPECFACT INTEGRATION
─────────────────────────────────────────────────────────────────

1. CHECK DoD status in specfact (manual):

   uvx specfact-cli@latest govern check \
     --bundle .specfact/projects/<project_id> \
     --dod <export_file>

2. GITHUB ACTIONS — add to your CI workflow:

   - name: DoD Gate
     run: |
       uvx specfact-cli@latest govern check \
         --bundle .specfact/projects/<project_id> \
         --dod <export_file> \
         --enforcement <enforcement_level>

   Enforcement levels:
     observe  → report only, never fails the build  (current)
     warn     → logs warnings, never fails the build
     enforce  → fails the build when definition_of_done gate is not passed

3. CHANGE ENFORCEMENT LEVEL:

   Edit .specify/extensions/dod/dod-config.yml:
     dod:
       enforcement_level: "enforce"

   Or pass at export time:
     /speckit.dod.export --enforcement enforce
```

If `specfact.project_id` is null in config, add a note:
```
⚠️  specfact.project_id is not configured.
    Set it in .specify/extensions/dod/dod-config.yml to enable full specfact integration.
    Run 'uvx specfact-cli@latest init' in your project to create a specfact bundle first.
```

### Step 6: Print Summary

```
EXPORT SUMMARY
  Feature:              <feature_id>
  Feature tag:          <feature_tag>
  Enforcement level:    <enforcement_level>

  FR:  <fr_passed>/<fr_total> passed
  NFR: <nfr_passed>/<nfr_total> passed

  ready_for_sprint:    <status>
  definition_of_done:  <status>

  Export: <export_file>
```
