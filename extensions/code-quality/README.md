# Code Quality Pipeline Extension

Post-implementation quality assurance pipeline for spec-kit. Runs a 4-stage review, fix, validate, and ideation sequence with gate checks between stages.

## Installation

```bash
specify extension add code-quality --source ./extensions/code-quality
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `speckit.code-quality.pipeline` | `.all` | Full pipeline: review → fix → validate → future ideas |
| `speckit.code-quality.review` | `.cr` | Identify refactoring, tech debt, dead code, code smells |
| `speckit.code-quality.fix` | `.cf` | Auto-fix issues from the review report |
| `speckit.code-quality.validate` | `.vr` | Validate FR/NFR implementation, testability, documentation |
| `speckit.code-quality.future` | `.fi` | Generate improvement and evolution ideas |

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
