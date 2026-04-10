# Code Quality Pipeline Extension

Post-implementation quality assurance pipeline for spec-kit. Runs a 4-stage review, fix, validate, and ideation sequence with gate checks between stages.

## Installation

```bash
specify extension add code-quality --source ./extensions/code-quality
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `speckit.code-quality.pipeline` | `speckit.code-quality.all` | Full pipeline: review → fix → validate → future ideas |
| `speckit.code-quality.review` | `speckit.code-quality.cr` | Identify refactoring, tech debt, dead code, code smells |
| `speckit.code-quality.fix` | `speckit.code-quality.cf` | Auto-fix issues from the review report |
| `speckit.code-quality.validate` | `speckit.code-quality.vr` | Validate FR/NFR implementation, testability, documentation |
| `speckit.code-quality.future` | `speckit.code-quality.fi` | Generate improvement and evolution ideas |
| `speckit.code-quality.specfact-sync` | `speckit.code-quality.sf` | Export quality findings to specfact-compatible JSON; optionally run `specfact govern check` |

## Pipeline Flow

```
Implementation Complete
        │
        ▼
  ┌─────────────┐
  │ Code Review  │ → code-review.md
  └──────┬──────┘
         │ GATE: findings exist?
         ▼
  ┌─────────────┐
  │  Code Fix   │ → code-fix-report.md
  └──────┬──────┘
         │ GATE: critical items resolved?
         ▼
  ┌──────────────┐
  │  Validate    │ → validation-report.md
  │  Requirements│
  └──────┬───────┘
         │ GATE: score >= 80%?
         ▼
  ┌──────────────┐
  │ Future Ideas │ → future-ideas.md
  └──────┬───────┘
         │
         ▼
  quality-summary.md
        │
        ▼ (if sync_after_pipeline: true)
  ┌──────────────────┐
  │ specfact Sync    │ → quality-export.json
  └──────────────────┘
```

## Output Artifacts

All reports are saved to `{feature-dir}/reviews/`:

| File | Content |
|------|---------|
| `code-review.md` | Refactoring opportunities, tech debt, dead code, code smells |
| `code-fix-report.md` | Fixes applied, deferred items, verification results |
| `validation-report.md` | FR/NFR traceability, testability matrix, documentation coverage |
| `future-ideas.md` | Performance, scalability, DX, feature evolution roadmap |
| `quality-summary.md` | Pipeline summary with stage results and next steps |
| `quality-export.json` | specfact-compatible export (`speckit-quality-export-v1`), produced by `speckit.code-quality.specfact-sync` |

## Grep Tags

All templates use `<!-- GREP:TAG -->` markers for search:

### Code Review
| Tag | Section |
|-----|---------|
| `GREP:CQ-REFACTORING` | Complexity, duplication, abstraction, naming |
| `GREP:CQ-TECH-DEBT` | Shortcuts, dependencies, testing, infrastructure |
| `GREP:CQ-DEAD-CODE` | Unreachable, commented-out, vestigial code |
| `GREP:CQ-CODE-SMELLS` | Structural, behavioral, coupling smells |
| `GREP:CQ-REVIEW-TEMPLATE` | Review report output structure |

### Code Fix
| Tag | Section |
|-----|---------|
| `GREP:CQ-FIX-TRIAGE` | Auto/semi-auto/manual classification |
| `GREP:CQ-FIX-LOOP` | Iterative fix-verify cycle |
| `GREP:CQ-FIX-REPORT-TEMPLATE` | Fix report output structure |

### Validate Requirements
| Tag | Section |
|-----|---------|
| `GREP:CQ-VALIDATE-FR` | Functional requirements verification |
| `GREP:CQ-VALIDATE-NFR` | Non-functional requirements verification |
| `GREP:CQ-VALIDATE-TESTABILITY` | Test coverage and quality assessment |
| `GREP:CQ-VALIDATE-DOCS` | Documentation coverage check |
| `GREP:CQ-VALIDATE-TEMPLATE` | Validation report output structure |

### Future Ideas
| Tag | Section |
|-----|---------|
| `GREP:CQ-FUTURE-PERFORMANCE` | Query, rendering, I/O optimizations |
| `GREP:CQ-FUTURE-SCALABILITY` | Data, user, feature growth analysis |
| `GREP:CQ-FUTURE-DX` | Developer experience improvements |
| `GREP:CQ-FUTURE-EVOLUTION` | Feature evolution roadmap |
| `GREP:CQ-FUTURE-TEMPLATE` | Future ideas report output structure |

### Pipeline
| Tag | Section |
|-----|---------|
| `GREP:CQ-PIPELINE-INIT` | Pipeline initialization and gate rules |
| `GREP:CQ-PIPELINE-REVIEW` | Review stage execution |
| `GREP:CQ-PIPELINE-FIX` | Fix stage with critical gate |
| `GREP:CQ-PIPELINE-VALIDATE` | Validation stage with score gate |
| `GREP:CQ-PIPELINE-FUTURE` | Future ideas generation |
| `GREP:CQ-PIPELINE-SUMMARY` | Pipeline summary output |
| `GREP:CQ-PIPELINE-SF-SYNC` | Conditional specfact sync step |

### Validate Requirements (specfact bridge)
| Tag | Section |
|-----|---------|
| `GREP:CQ-VALIDATE-DOD-BRIDGE` | Propagate statuses to dod.yml |
| `GREP:CQ-VALIDATE-SF-EXPORT` | Conditional specfact-sync invocation |

### specfact Sync
| Tag | Section |
|-----|---------|
| `GREP:CQ-SF-LOAD-CONTEXT` | Load feature context and config |
| `GREP:CQ-SF-GATHER` | Parse all review artifacts |
| `GREP:CQ-SF-METRICS` | Compute health and coverage metrics |
| `GREP:CQ-SF-EXPORT-JSON` | Write quality-export.json |
| `GREP:CQ-SF-GOVERN` | Run specfact govern check |
| `GREP:CQ-SF-CI-GUIDANCE` | Print CI integration snippet |

---

## specfact Integration

The `code-quality` extension integrates with [specfact](https://specfact.com) for automated governance.

### Quick Start

1. **Configure your project ID** in `.specify/extensions/code-quality/code-quality-config.yml`:

   ```yaml
   code_quality:
     specfact:
       project_id: "my-project"
       enforcement_level: "warn"   # observe | warn | enforce
   ```

2. **Run the sync command** after a quality pipeline run:

   ```
   /speckit.code-quality.specfact-sync
   ```

3. **Enable automatic sync** so every pipeline run exports to specfact:

   ```yaml
   code_quality:
     specfact:
       sync_after_pipeline: true
   ```

### dod Extension Bridge

If the [`dod` extension](../dod/README.md) is also installed, `speckit.code-quality.validate` will
automatically write validated FR/NFR statuses back into `dod.yml`, keeping the definition of done
in sync with validation results. Enable with:

```yaml
code_quality:
  specfact:
    update_dod: true   # default
```

### CI/CD

Add governance enforcement to GitHub Actions:

```yaml
- name: Quality Gate (specfact)
  run: |
    uvx specfact-cli@latest govern check \
      --bundle .specfact/projects/${{ env.SPECFACT_PROJECT_ID }} \
      --quality-report ${{ env.FEATURE_DIR }}/reviews/quality-export.json \
      --enforcement enforce
```

**Enforcement levels:**

| Level | Effect |
|-------|--------|
| `observe` | Log only — never fails CI |
| `warn` | Warnings in PR comment — never fails CI |
| `enforce` | Fails CI when any tracked gate is FAIL |
