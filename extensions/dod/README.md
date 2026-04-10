# Definition of Done Extension

Machine-readable, testable Definitions of Done for every FR and NFR in a spec-kit feature. Generated from `spec.md` by the `speckit.specify` agent, validated against your implementation, and exported to [specfact.com](https://specfact.com) for CI/CD enforcement.

## What it does

| Problem | How this extension solves it |
|---------|------------------------------|
| "Done" is ambiguous and inconsistent across features | Generates a concrete, versioned `dod.yml` from spec.md FR/NFR tables |
| Acceptance criteria live only in the spec — no link to tests | Each FR criterion maps to test files and test IDs via `dk.dod.validate` |
| NFR thresholds are prose — can't be checked in CI | NFR criteria carry typed operators, values, units, and measurement commands |
| specfact doesn't know about spec-kit requirements | `dk.dod.export` produces `specfact-export-v1` JSON that specfact can enforce |

## Installation

```bash
specify extension add dod --source ./extensions/dod
```

## Commands

| Command | Alias | Hook | Description |
|---------|-------|------|-------------|
| `dk.dod.generate` | `dk.dod.gen` | `after_specify` | Parse spec.md → write `dod.yml` |
| `dk.dod.validate` | `dk.dod.check` | `after_implement` | Check implementation → update statuses |
| `dk.dod.export` | `dk.dod.sf` | — | Export `dod-export.json` for specfact |
| `dk.dod.report` | `dk.dod.rpt` | — | Human-readable DoD status report |

## Workflow

```
speckit.specify → dod.yml generated (after_specify hook)
       │
       ▼
  Implementation
       │
       ▼
dk.dod.validate → statuses updated in dod.yml + dod-validation-report.md
       │
       ├─ dk.dod.report  → human-readable status to console / markdown
       │
       └─ dk.dod.export  → dod-export.json  (specfact-compatible)
                                │
                                ▼
                    specfact govern check  (CI gate)
```

## The dod.yml Contract

`dod.yml` is a versioned, schema-validated YAML file written to the feature directory alongside `spec.md`. It is the single source of truth for what "done" means for the feature:

```yaml
meta:
  extension: "dod"
  dod_version: "1.0"
  feature_id: "user-registration"
  spec_file: ".specify/features/user-registration/spec.md"
  generated_at: "2026-04-09T12:00:00Z"
  specfact_compatible: true

functional_requirements:
  - id: "FR1"
    title: "User can register with email and password"
    priority: "P1"
    status: "pending"
    criteria:
      - id: "FR1-C1"
        description: "Happy path: valid credentials create a new account"
        type: "behavioral"
        given: "A visitor on the registration page with no existing account"
        when: "They submit the form with a valid unique email and password ≥ 8 chars"
        then: "The API returns HTTP 201, a user record is created, and a confirmation email is enqueued"
        test_strategy: "integration"
        status: "pending"
        evidence:
          test_files: []
          test_ids: []

non_functional_requirements:
  - id: "NFR1"
    title: "Registration API responds within 200ms at p95"
    category: "performance"
    priority: "P2"
    status: "pending"
    criteria:
      - id: "NFR1-C1"
        description: "p95 response time under load does not exceed 200ms"
        type: "threshold"
        metric: "response_time_p95"
        operator: "lt"
        value: 200
        unit: "ms"
        load_profile: "50 concurrent users"
        status: "pending"
        measurement:
          method: "benchmark"
          tool: "k6"
          command: "npx k6 run tests/benchmarks/user-registration.k6.js"
          ci_step: "benchmark"
        evidence:
          result: null
          measured_at: null

gates:
  ready_for_sprint:
    description: "All requirements are well-defined and independently testable"
    checks:
      - "Each FR has at least one criterion with non-empty given/when/then"
      - "Each NFR criterion has a measurement method and threshold or audit plan"
      - "test_strategy is set for all FR criteria"
    status: "pending"
  definition_of_done:
    description: "The implementation satisfies all specified criteria"
    checks:
      - "All FR criteria have status 'passed'"
      - "All NFR criteria have status 'passed'"
      - "All FR criteria have at least one entry in evidence.test_files"
      - "All NFR threshold criteria have a non-null evidence.result"
    status: "pending"
```

### FR Criterion Types

| Type | When to use |
|------|-------------|
| `behavioral` | Happy path — the primary intended use |
| `negative` | Error cases, invalid inputs, rejection flows |
| `boundary` | Edge values (empty, max, min, off-by-one) |
| `idempotent` | Same call twice → same result (PUT, DELETE) |
| `concurrency` | Parallel requests, race conditions |

### NFR Criterion Types

| Type | When to use |
|------|-------------|
| `threshold` | Numeric target: response time, error rate, score |
| `audit` | Expert or tool review: OWASP SAST, accessibility audit |
| `compliance` | Regulatory/standard adherence: GDPR, WCAG AA |
| `coverage` | Percentage target: test coverage ≥ 80% |

## specfact Integration

The extension exports a `dod-export.json` in the `speckit-dod-export-v1` schema that the [specfact CLI](https://github.com/nold-ai/specfact-cli) can consume for drift detection and pipeline enforcement.

### Quick start

```bash
# 1. Install specfact CLI
uvx specfact-cli@latest --help

# 2. Export DoD from spec-kit
/dk.dod.export --enforcement observe

# 3. Check DoD status
uvx specfact-cli@latest govern check \
  --bundle .specfact/projects/<project-id> \
  --dod .specfact/dod-exports/<feature-id>-dod-export.json
```

### GitHub Actions

Add this step to your CI workflow to enforce the DoD gate on every PR:

```yaml
name: Definition of Done Gate

on:
  pull_request:
    paths:
      - '.specify/features/**'
      - 'src/**'
      - 'tests/**'

jobs:
  dod-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate/Validate DoD
        run: |
          # If dod.yml exists, validate it; otherwise skip
          DOD_FILE=$(find .specify/features -name "dod.yml" | head -1)
          if [ -z "$DOD_FILE" ]; then
            echo "No dod.yml found — skipping DoD gate"
            exit 0
          fi

      - name: DoD Export
        run: |
          # Export all dod.yml files found in the feature tree
          for dod_file in $(find .specify/features -name "dod.yml"); do
            feature=$(basename $(dirname "$dod_file"))
            echo "Exporting DoD for: $feature"
            # Run export via spec-kit CLI or transform dod.yml to JSON manually
          done

      - name: specfact DoD Gate
        run: |
          uvx specfact-cli@latest govern check \
            --bundle .specfact/projects/${{ vars.SPECFACT_PROJECT_ID }} \
            --dod .specfact/dod-exports/ \
            --enforcement ${{ vars.SPECFACT_ENFORCEMENT_LEVEL || 'observe' }}
```

### Enforcement Levels

| Level | Behaviour |
|-------|-----------|
| `observe` | Reports DoD status, never fails the pipeline (default) |
| `warn` | Logs warnings for failed gates, never fails the pipeline |
| `enforce` | Fails the pipeline when `definition_of_done` gate is not `passed` |

## Output Artifacts

All files are written to the active feature directory (`.specify/features/<feature-id>/`):

| File | Created by | Description |
|------|-----------|-------------|
| `dod.yml` | `dk.dod.generate` | Machine-readable DoD contract |
| `dod-validation-report.md` | `dk.dod.validate` | Human-readable validation result |
| `.specfact/dod-exports/<id>-dod-export.json` | `dk.dod.export` | specfact-compatible export |

## Schema Reference

| Schema file | Purpose |
|-------------|---------|
| [`schemas/dod.schema.json`](schemas/dod.schema.json) | JSON Schema for `dod.yml` |
| [`schemas/specfact-export.schema.json`](schemas/specfact-export.schema.json) | JSON Schema for `dod-export.json` |

## Configuration

Copy `config-template.yml` to `.specify/extensions/dod/dod-config.yml` and adjust:

```yaml
dod:
  criteria_per_fr: 2           # criteria generated per FR (1–5)
  enforcement_level: "observe" # observe | warn | enforce
  nfr_defaults:
    performance:
      method: "benchmark"
      tool: "k6"
    security:
      method: "automated"
      tool: "Semgrep"
  specfact:
    project_id: "my-project"   # from .specfact/projects/
    export_on_validate: true   # auto-export after every validate run
```

## Compatibility

- **spec-kit**: `>=0.2.0`
- **specfact CLI**: `>=0.22.0` (for governance checks)
- **dod schema version**: `1.0`
- **export schema**: `speckit-dod-export-v1`
