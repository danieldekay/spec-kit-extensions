---
description: "Parse spec.md and generate dod.yml with machine-readable, testable DoD criteria for each FR and NFR"
---

# DoD Generate

Parse the feature's `spec.md`, extract every Functional Requirement (FR) and Non-Functional Requirement (NFR), and produce `dod.yml` — a machine-readable, schema-validated file that defines testable pass/fail criteria for each requirement.

The generated `dod.yml` is the contract between the spec and the implementation. It is updated `speckit.dod.validate` and exported to specfact by `speckit.dod.export`.

## User Input

$ARGUMENTS

## Prerequisites

1. `spec.md` exists in the active feature directory (created by `speckit.specify`)
2. FR and NFR tables use the standard spec-kit format

## Steps

### Step 1: Locate Feature Context

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
feature_id=$(basename "$feature_dir")
spec_file="$feature_dir/spec.md"
dod_file="$feature_dir/dod.yml"
config_file=".specify/extensions/dod/dod-config.yml"
```

Check that `spec.md` exists. If it does not, stop and instruct the user to run `speckit.specify` first.

If `dod.yml` already exists, ask the user:
- **Regenerate** — overwrite with a fresh parse (loses any hand-edited notes in evidence fields)
- **Update** — add criteria only for requirements not yet present in `dod.yml`
- **Cancel** — abort

Load configuration:

```bash
if [ -f "$config_file" ]; then
  criteria_per_fr=$(yq eval '.dod.criteria_per_fr // 2' "$config_file")
  enforcement_level=$(yq eval '.dod.enforcement_level // "observe"' "$config_file")
  specfact_project=$(yq eval '.dod.specfact.project_id // null' "$config_file")
  feature_tag_prefix=$(yq eval '.dod.specfact.feature_tag_prefix // "sk-"' "$config_file")
else
  criteria_per_fr=2
  enforcement_level="observe"
  specfact_project="null"
  feature_tag_prefix="sk-"
fi
```

### Step 2: Parse Functional Requirements

<!-- GREP:DOD-PARSE-FR -->
```
READ spec.md

LOCATE the Functional Requirements section. It typically contains a markdown table with columns:
  | ID  | Description | Acceptance Criteria | Priority |
  or
  | FR  | Requirement | Priority |

EXTRACT for each row:
  - id           → e.g. "FR1"
  - title        → short description of the requirement
  - priority     → P1/P2/P3 (default P2 if not present)
  - ac_text      → full Acceptance Criteria text for this FR (may be multi-line or a nested list)

IF no FR table is found, scan the document for lines matching the pattern "**FR\d+**" or "### FR\d+".

OUTPUT: list of { id, title, priority, ac_text } for all FRs
```

### Step 3: Generate FR Criteria (Given/When/Then)

<!-- GREP:DOD-GEN-FR-CRITERIA -->
```
FOR each FR:

  GENERATE `criteria_per_fr` criteria. Always include:
    C1 — Happy path (type: "behavioral")
    C2 — Negative / error path (type: "negative"), if acceptance criteria mention an error case
    C3 — Boundary / edge case (type: "boundary"), generated only if `criteria_per_fr >= 3`

  FOR each criterion:
    - Derive the Given/When/Then scenario from the FR title and acceptance criteria text
    - Choose test_strategy based on FR type:
        API endpoints            → "integration"
        UI interactions          → "e2e"
        Pure business logic      → "unit"
        Cross-service contracts  → "contract"
    - Set status: "pending"
    - Set evidence.test_files: []
    - Set evidence.test_ids: []
    - Keep criterion descriptions specific, verifiable, and unambiguous
    - The "then" clause must describe an observable, measurable outcome (HTTP code, DB state, UI element, return value)

  EXAMPLE output for FR1 "User can register with email and password":
    FR1-C1:
      description: "Happy path: valid credentials create a new account"
      type: "behavioral"
      given: "A visitor on the registration page with no existing account"
      when: "They submit the form with a valid unique email and a password of at least 8 characters"
      then: "The API returns HTTP 201, a user record is created in the database, and a confirmation email is enqueued"
      test_strategy: "integration"

    FR1-C2:
      description: "Negative: duplicate email is rejected"
      type: "negative"
      given: "An email address that is already registered"
      when: "A registration is attempted with that email"
      then: "The API returns HTTP 409 with an error body containing the key 'email_already_exists'"
      test_strategy: "integration"
```

### Step 4: Parse Non-Functional Requirements

<!-- GREP:DOD-PARSE-NFR -->
```
LOCATE the Non-Functional Requirements section in spec.md. Common column patterns:
  | ID   | Category    | Description | Priority |
  | NFR# | performance | ...         | P2       |

EXTRACT for each row:
  - id          → e.g. "NFR1"
  - title       → short description
  - category    → performance | security | accessibility | availability | scalability | compatibility | maintainability
  - priority    → P1/P2/P3
  - details     → any threshold or constraint text in the description

IF no NFR table is found, scan for "**NFR\d+**" patterns or a section headed "Non-Functional Requirements".
```

### Step 5: Generate NFR Criteria (Thresholds + Measurement)

<!-- GREP:DOD-GEN-NFR-CRITERIA -->
```
FOR each NFR:

  LOAD nfr_defaults for this category from config (or use built-in defaults).

  DETERMINE criterion type:
    - "threshold" when the description contains a measurable value (e.g. "< 200ms", "99.9%", "WCAG AA")
    - "audit"     when the description refers to a standard or review (e.g. "OWASP Top 10", "code review")
    - "compliance" when the description references a regulation or standard
    - "coverage"  when the description specifies a percentage target (e.g. "80% test coverage")

  EXTRACT threshold values from the description text:
    - Numeric thresholds: parse "<200ms", ">99.9%", "≤500ms", ">=1000 req/s"
    - If no numeric threshold: set value to null and type to "audit"

  GENERATE one primary criterion (NFR1-C1).
  If the description implies both a nominal and peak load scenario, generate NFR1-C2 as well.

  ASSIGN measurement from config defaults for the category:
    performance → method: benchmark, tool: from config
    security    → method: automated, tool: from config
    accessibility → method: automated, tool: from config
    availability → method: monitoring, tool: from config

  SET evidence.result: null, evidence.measured_at: null

  EXAMPLE output for NFR1 "API response time < 200ms at p95 under 50 concurrent users":
    NFR1-C1:
      description: "p95 response time under load does not exceed 200ms"
      type: "threshold"
      metric: "response_time_p95"
      operator: "lt"
      value: 200
      unit: "ms"
      load_profile: "50 concurrent users"
      measurement:
        method: "benchmark"
        tool: "k6"
        command: "npx k6 run tests/benchmarks/<feature_id>.k6.js"
        ci_step: "benchmark"
```

### Step 6: Build Gates

<!-- GREP:DOD-GEN-GATES -->
```
BUILD gates section:

ready_for_sprint:
  description: "All requirements are well-defined and independently testable before implementation starts"
  status: "pending"  (speckit.dod.validate will evaluate and update this)
  checks:
    - "Each FR has at least one criterion with a non-empty description, given, when, and then"
    - "Each NFR criterion has a measurement method and either a threshold value or an audit plan"
    - "test_strategy is set for all FR criteria"
    - "No FR or NFR has status 'failed'"

definition_of_done:
  description: "The implementation satisfies all specified criteria and is ready for release"
  status: "pending"
  checks:
    - "All FR criteria have status 'passed'"
    - "All NFR criteria have status 'passed'"
    - "gates.ready_for_sprint.status is 'passed'"
    - "All FR criteria have at least one entry in evidence.test_files"
    - "All NFR threshold criteria have a non-null evidence.result"
```

### Step 7: Write dod.yml

Write the complete `dod.yml` to `$feature_dir/dod.yml` using the validated schema at `extensions/dod/schemas/dod.schema.json`.

Include the meta section:
```yaml
meta:
  extension: "dod"
  dod_version: "1.0"
  feature_id: "<feature_id>"
  spec_file: "<relative path to spec.md>"
  generated_at: "<ISO 8601 timestamp>"
  last_validated_at: null
  specfact_compatible: true
```

Include the specfact section (pulling from config):
```yaml
specfact:
  project_id: <specfact_project or null>
  feature_tag: "<feature_tag_prefix><feature_id>"
  bundle: null
  enforcement_level: "<enforcement_level>"
  last_exported_at: null
```

After writing, validate the file against the JSON schema if `yq` or `jsonschema` is available:
```bash
if command -v jsonschema &>/dev/null; then
  jsonschema -i <(yq eval -o=json "$dod_file") extensions/dod/schemas/dod.schema.json \
    && echo "✅ dod.yml is valid" || echo "⚠️  dod.yml has schema violations — review manually"
fi
```

### Step 8: Report Summary

Print a summary table:

```
✅  dod.yml generated at <dod_file>

REQUIREMENTS EXTRACTED
  Functional (FR):       <n> requirements, <total_criteria> criteria
  Non-Functional (NFR):  <n> requirements, <total_criteria> criteria

GATE STATUS
  ready_for_sprint:    pending  (run speckit.dod.validate to evaluate)
  definition_of_done:  pending

NEXT STEPS
  1. Review dod.yml — edit criteria descriptions to sharpen testability
  2. Run speckit.dod.validate after implementation to update statuses
  3. Run speckit.dod.export to produce specfact-compatible JSON
```

If any FR or NFR was skipped (no parseable data), list them and explain what was missing.
