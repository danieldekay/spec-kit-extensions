---
description: "Generate a human-readable DoD status report summarising coverage, gate status, and open items"
---

# DoD Report

Read `dod.yml` and render a comprehensive, human-readable status report to the console (or optionally to a Markdown file). Useful for sprint reviews, PR descriptions, and stakeholder updates.

Unlike `speckit.dod.validate`, this command does **not** re-run any checks — it renders the current state of `dod.yml` as-is. Run `speckit.dod.validate` first to ensure the statuses are current.

## User Input

$ARGUMENTS

Optional flags:
- `--format console|markdown` — output format (default: console)
- `--output <path>` — write to a file instead of stdout (implies `--format markdown`)
- `--show-passed` — include passed criteria in the detail tables (default: show only failed/pending)
- `--summary-only` — print only gate status and coverage numbers

## Steps

### Step 1: Load Context

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
feature_id=$(basename "$feature_dir")
dod_file="$feature_dir/dod.yml"
```

Abort if `dod.yml` does not exist. Instruct the user to run `speckit.dod.generate` first.

Parse flags from `$ARGUMENTS`:
- Default `--format` is `console`
- If `--output` is specified, force `--format markdown`
- Default `--show-passed` is false

### Step 2: Compute Aggregate Statistics

<!-- GREP:DOD-REPORT-STATS -->
```
COMPUTE from dod.yml:

FR statistics:
  fr_total              = count(functional_requirements)
  fr_passed             = count(FRs where status == "passed")
  fr_failed             = count(FRs where status == "failed")
  fr_pending            = count(FRs where status == "pending")
  fr_criteria_total     = sum(count(FR.criteria) for each FR)
  fr_criteria_passed    = sum(count(criteria where status == "passed") for each FR)
  fr_testable           = count(FRs where ALL criteria have evidence.test_files non-empty)

NFR statistics:
  nfr_total, nfr_passed, nfr_failed, nfr_pending (same pattern)
  nfr_criteria_total, nfr_criteria_passed
  nfr_measured          = count(NFRs where ALL threshold criteria have evidence.result non-null)

Gate status:
  ready_for_sprint_status    = dod.yml gates.ready_for_sprint.status
  definition_of_done_status  = dod.yml gates.definition_of_done.status

Last validated: dod.yml meta.last_validated_at (null = "Never")
```

### Step 3: Render Report

<!-- GREP:DOD-REPORT-RENDER -->

Render the report in the selected format:

```
═══════════════════════════════════════════════════════════════
  DEFINITION OF DONE — <feature_id>
═══════════════════════════════════════════════════════════════
  Last validated: <last_validated_at or "Never — run speckit.dod.validate">
  Spec file:      <meta.spec_file>

GATES
  ● ready_for_sprint:    <✅ PASSED | ❌ FAILED | ⏳ PENDING>
  ● definition_of_done:  <✅ PASSED | ❌ FAILED | ⏳ PENDING>

COVERAGE
  Functional (FR)
    Requirements:  <fr_passed>/<fr_total> passed
    Criteria:      <fr_criteria_passed>/<fr_criteria_total> passed
    Testable:      <fr_testable>/<fr_total> with test evidence

  Non-Functional (NFR)
    Requirements:  <nfr_passed>/<nfr_total> passed
    Criteria:      <nfr_criteria_passed>/<nfr_criteria_total> passed
    Measured:      <nfr_measured>/<nfr_total> with measured evidence

IF NOT --summary-only:

FUNCTIONAL REQUIREMENTS DETAIL
────────────────────────────────────────────────────────────────
  FOR each FR (filter by status if not --show-passed):

  <status emoji> <FR.id> — <FR.title>  [<FR.priority>]
    FOR each criterion (filter by status):
      <status emoji> <criterion.id>: <criterion.description>
        Given:  <given>
        When:   <when>
        Then:   <then>
        Tests:  <count(test_files)> file(s)  <test_files joined by ", " or "(none)">
        IF status == "failed":
          ⚠  <criterion.evidence.notes>

NON-FUNCTIONAL REQUIREMENTS DETAIL
────────────────────────────────────────────────────────────────
  FOR each NFR:

  <status emoji> <NFR.id> — <NFR.title>  [<NFR.category> / <NFR.priority>]
    FOR each criterion:
      <status emoji> <criterion.id>: <criterion.description>
        Type:         <type>
        IF type == "threshold":
          Threshold:  <operator> <value> <unit>
          Load:       <load_profile or "—">
          Measured:   <evidence.result> <unit> at <evidence.measured_at> or "(not yet measured)"
        Method:       <measurement.method> (<measurement.tool or "—">)
        Command:      <measurement.command or "—">
        IF status == "failed" or status == "pending":
          Next step: <measurement.command or "Run the audit tool: " + measurement.tool>

OPEN ITEMS  (failed + pending)
────────────────────────────────────────────────────────────────
  Prioritised by: FR/NFR priority, then by criterion type (behavioral before boundary)

  FOR top open items (max 10):
  [<priority>] <id>  <description>  → <action>
```

### Step 4: Output

If `--output <path>` was specified: write the report as Markdown to that path and confirm:
```
📄 Report written to: <path>
```

Otherwise: print to console.

At the end always print:
```
──────────────────────────────────────────────────────────────
  To refresh statuses: /speckit.dod.validate
  To export for CI:    /speckit.dod.export
```
