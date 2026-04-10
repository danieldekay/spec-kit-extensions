# Proposal: Improving `spec-kit-extensions`

_Date: 2026-04-09_

## Purpose

This document captures a practical improvement roadmap for the extensions and preset in this repository.

> All extension and preset versions have been reset to **`0.1.0`** to reflect active pre-release development.

---

## Executive Summary

The repository is already strong in scope, intent, and RFC alignment. The biggest opportunities are:

1. **Standardize naming and metadata** across all extensions.
2. **Tighten config/schema consistency** so templates and manifests never drift.
3. **Improve cross-extension integration**, especially between `fleet`, `dod`, `code-quality`, and `ux-research`.
4. **Reduce agent ambiguity** by making command files slightly more declarative and less pseudo-shell-heavy.
5. **Add repo-level validation tooling** for RFC compliance, SemVer/changelog discipline, and config-schema alignment.

---

## Proposed Improvements by Extension

### 1) `code-quality`

**Current strengths**
- Strong post-implementation workflow.
- Good artifact conventions and grep tags.
- Useful `specfact` integration and `dod` bridge.

#### S — Small
- Add `review.principles` to `config_schema` to match `config-template.yml`.
- Add a short **Quick Start** block to `README.md`.
- Ensure `support.documentation` is present and consistent.

#### M — Medium
- Add clearer config examples to command docs.
- Improve validation and error messaging in `specfact-sync.md`.
- Add or normalize any missing grep tags across command sections.

#### L — Large
- Add a `dk.code-quality.report` command to combine all generated artifacts into one dashboard view.
- Formalize the `dod` bridge contract so status propagation is deterministic.

#### XL — Extra Large
- Build repo-wide validation that checks config-template ↔ config-schema consistency and command coverage.

---

### 2) `dod`

**Current strengths**
- Clear machine-readable DoD model.
- Good schema design and CI/export story.
- Strong pairing of generation, validation, export, and report commands.

#### S — Small
- Add a minimal `dod.yml` example to the README.
- Clarify where and how `dod-config.yml` should be placed after installation.

#### M — Medium
- Validate `project_id` and `feature_tag_prefix` more explicitly in `dod-export.md`.
- Add a short “when to run this command” guide in the README.

#### L — Large
- Add `dk.dod.fix` or `dk.dod.sync` to repair mild schema issues or migrate older `dod.yml` files.

#### XL — Extra Large
- Define a shared DoD/validation contract used by `dod`, `code-quality`, and `fleet`.

---

### 3) `fleet`

**Current strengths**
- Ambitious orchestration model.
- Clear lifecycle coverage.
- Good value as the top-level autonomous extension.

#### S — Small
- Add `support.documentation` to the manifest.
- Add a short “How to resume” example to the README.

#### M — Medium
- Add a simpler quick-start entrypoint for common use.
- Make the phase/status file semantics more explicit in documentation.

#### L — Large
- Extract the phase model into a reusable state-machine-like structure.
- Bundle more of the runtime guidance as reusable assets instead of embedding everything in command prose.

#### XL — Extra Large
- Build a lightweight shared runtime or validation harness for lifecycle transitions and resume logic.

---

### 4) `maqa-github-projects`

**Current strengths**
- Clear and useful GitHub Projects v2 niche.
- Focused manifest and config.
- Practical setup and population commands.

#### S — Small
- Add `support.documentation` to the manifest.
- Document `GH_TOKEN` usage more clearly in the README.

#### M — Medium
- Improve error handling for rate limits, missing fields, and GraphQL/API failures.
- Clarify `linked_repo` formatting rules in the config schema.

#### L — Large
- Add a `sync` command that updates issue checklist state or project status over time.

#### XL — Extra Large
- Add bi-directional project synchronization between feature/task progress and GitHub Projects metadata.

---

### 5) `stitch-implement`

**Current strengths**
- Well-scoped Stitch MCP integration.
- Good before/after implement hook placement.
- Clear UI prototyping and validation workflow.

#### S — Small
- Add `support.documentation` metadata.
- Clarify Stitch environment/setup requirements in README.

#### M — Medium
- Add a preflight command to verify Stitch MCP availability before execution.
- Document expected outputs and handoff format more explicitly.

#### L — Large
- Add a refresh/cleanup command to reconcile generated prototype state with the active feature.

#### XL — Extra Large
- Formalize a reusable Stitch artifact contract consumed by `fleet` and UI-related extensions.

---

### 6) `ux-research`

**Current strengths**
- Strong hook placement after planning.
- Good research-report generation pattern.
- Useful grep-tagged structure.

#### S — Small
- Add `support.documentation` metadata.
- Add a simple “run this when…” checklist in the README.

#### M — Medium
- Add targeting guidance for scanning specific directories or component areas.
- Improve fallback behaviour when a feature has UI but the report is missing.

#### L — Large
- Add a companion command to turn UX findings directly into task suggestions or plan addenda.

#### XL — Extra Large
- Deepen integration with `fleet` and `stitch-implement` through formal handoff contracts.

---

### 7) `greppable-templates` preset

**Current strengths**
- Excellent concept and strong utility.
- Clear structured markers.
- Good query tooling support.

#### S — Small
- Add `support.documentation` metadata.
- Add a small preset-level `README.md` with install and usage examples.

#### M — Medium
- Improve bootstrap/install guidance for `sk-query.sh` and `sk-query.ps1`.

#### L — Large
- Expand documentation showing how marker conventions integrate with `code-quality` and `ux-research` outputs.

#### XL — Extra Large
- Add richer query tooling or future extension-system support for helper scripts as first-class assets.

---

## Cross-Cutting Proposals

### S — Small
- Standardize manifest metadata completeness across all extensions.
- Standardize namespace usage (`dk.*` vs `speckit.*`).
- Keep changelog and SemVer conventions identical everywhere.

### M — Medium
- Standardize config naming/documentation patterns.
- Add a shared “install + configure + run” section format to all READMEs.
- Align command file structure so each one consistently includes: context, inputs, steps, outputs, failure modes.

### L — Large
- Define shared contracts for:
  - requirement IDs
  - report artifact locations
  - status propagation
  - grep marker naming
- Make `fleet`, `dod`, `code-quality`, and `ux-research` more intentionally composable.

### XL — Extra Large
- Add repo-level validation tooling that checks:
  - RFC-required manifest fields
  - SemVer formatting
  - changelog presence and version alignment
  - hook/command consistency
  - config-template vs config-schema drift
  - namespace consistency

---

## Gap: Planning Phase Lacks Architecture, Workflow, and Screen Design

### Problem

The core `speckit.plan` command produces `research.md`, `data-model.md`, and `contracts/` — but no architecture overview, no workflow diagrams, and no screen layouts. The `ux-research` extension discovers existing UI patterns and maps them to spec requirements, but it does not _design_ the new screens. By the time `stitch-implement` runs (Phase 9), it constructs Stitch prompts from task descriptions and UX-research findings — but there is no authoritative screen blueprint to work from.

This creates three gaps:

1. **No architecture schemata.** There is no system-level diagram showing how new components, services, or modules connect to each other and to existing code. The plan template has a "Project Structure" section, but that is a file tree, not an architecture view.
2. **No workflow diagrams.** User flows and data flows are implied by user stories but never drawn out explicitly. The UX research `INTERACTION FLOWS` step produces text-based flow descriptions per story, but these are _discovered_ flows, not _designed_ flows.
3. **No screen wireframes.** No step in the current pipeline produces ASCII (or structured) screen schemata that a Stitch agent can consume directly. The Stitch prototype command builds prompts on the fly from task descriptions — a lossy translation that loses layout intent.

### Proposed Solution

Extend `ux-research` with a new **Step 5.5: Design Artifacts** (between the current Interaction Flow Analysis and A11y Audit steps) that produces three deliverables:

#### A. Architecture overview (`architecture.md`)

An ASCII block diagram of the system as it will look _after_ the feature ships. Should show:

- New modules/services and how they connect
- Existing modules that gain new interfaces or dependencies
- Data flow direction between blocks
- External systems the feature touches

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Frontend    │────▸│  API Gateway │────▸│  Auth Svc   │
│  (new page)  │     │  (existing)  │     │  (existing)  │
└──────┬──────┘     └──────┬───────┘     └─────────────┘
       │                   │
       ▼                   ▼
┌─────────────┐     ┌──────────────┐
│  State Mgr  │◂───│  Feature Svc │
│  (extend)    │     │  (new)        │
└─────────────┘     └──────────────┘
```

#### B. Workflow diagrams (`workflows.md`)

One diagram per primary user flow, showing the happy path plus key error branches. Use ASCII flowchart notation that agents can parse:

```
[Landing Page] ──▸ Click "Sign Up"
    │
    ▼
[Registration Form] ──▸ Submit
    │                       │
    ▼                       ▼ (validation error)
[Verify Email]          [Show inline errors]
    │
    ▼
[Dashboard]
```

#### C. Screen schemata (`screens/`)

One ASCII wireframe per distinct screen or modal, stored as individual `.md` files under `screens/` in the feature directory. Each file includes:

- Screen name and route
- ASCII box layout showing regions, components, and placeholder content
- Annotations for interactive elements (buttons, inputs, dropdowns)
- Responsive behavior notes (what collapses/stacks on mobile)

```
screens/dashboard.md
─────────────────────
Route: /dashboard

┌──────────────────────────────────────┐
│  Header: Logo | Nav | Avatar ▾       │
├────────┬─────────────────────────────┤
│        │  ┌─────┐ ┌─────┐ ┌─────┐   │
│ Sidebar│  │ KPI │ │ KPI │ │ KPI │   │
│  - Nav │  │Card │ │Card │ │Card │   │
│  - Nav │  └─────┘ └─────┘ └─────┘   │
│  - Nav │  ┌─────────────────────┐    │
│        │  │  Activity Chart     │    │
│        │  │  [line chart]       │    │
│        │  └─────────────────────┘    │
│        │  ┌─────────────────────┐    │
│        │  │  Recent Items Table │    │
│        │  └─────────────────────┘    │
├────────┴─────────────────────────────┤
│  Footer                              │
└──────────────────────────────────────┘

Mobile: sidebar collapses to hamburger menu, KPI cards stack vertically
```

These screen files become the **primary input** for `stitch-implement` (Phase 9), replacing the current approach of synthesizing Stitch prompts from task descriptions. The Stitch prototype command should read `screens/*.md` and use each wireframe as the layout specification in the `stitch/generate_screen_from_text` prompt.

### Implementation Steps

| Size | Action |
|------|--------|
| M | Add Step 5.5 to `ux-research-analyze.md` with the three deliverable templates |
| M | Add `screens/` directory convention to the UX research report template |
| S | Update `stitch-prototype.md` Step 4 to prefer `screens/*.md` files as layout input over task-derived prompts |
| S | Add `architecture.md` and `workflows.md` to the artifact signal list in `fleet-run.md` Phase 4 |
| M | Update `fleet-review.md` to check architecture/workflow/screen coverage as a new review dimension |
| S | Add `screens.output_dir` config key to `ux-research` `config-template.yml` |

### Version Impact

- `ux-research`: **0.2.0** (MINOR — new output artifacts, no breaking changes)
- `stitch-implement`: **0.2.0** (MINOR — new input source, falls back to current behavior)
- `fleet`: **0.2.0** (MINOR — new artifact signals, no breaking changes)

---

## Gap: Research Phase Does Not Analyze Codebase Interaction

### Problem

The plan's Phase 0 (Research) resolves "NEEDS CLARIFICATION" items and evaluates technology choices. But it does not analyze how the _new_ code will interact with the _existing_ codebase. This means:

1. **No impact mapping.** Nobody checks which existing files, modules, or features will be touched, extended, or broken by the new feature.
2. **No integration surface analysis.** Shared state, event buses, database tables, API routes, CSS class names, and other integration points are not inventoried.
3. **Changes to existing code are discovered during implementation**, not during planning — leading to scope creep, missed regressions, and incorrect task estimates.

The `ux-research` extension does scan for reusable UI patterns, but only for frontend components. Backend services, data models, shared utilities, configuration, and cross-cutting concerns (auth, logging, caching) are not analyzed.

### Proposed Solution

Add a new extension command `dk.codebase-impact.analyze` (or extend the existing plan Phase 0) that runs a structured codebase interaction analysis _before_ design decisions are finalized.

#### What It Produces: `codebase-impact.md`

```markdown
# Codebase Impact Analysis: [FEATURE NAME]

## Integration Surface

| Integration Point       | Type          | Existing File/Module           | Change Needed        | Risk  |
|------------------------|---------------|--------------------------------|----------------------|-------|
| User model             | Data model    | src/models/user.py             | Add `preferences` field | LOW   |
| Auth middleware         | Middleware    | src/middleware/auth.py          | Add new role check   | MED   |
| API router             | Route config  | src/api/routes.py              | Register new endpoints | LOW   |
| Event bus              | Shared state  | src/events/dispatcher.py       | New event types      | MED   |
| Dashboard page         | UI            | src/pages/dashboard.tsx         | Add widget slot      | LOW   |
| Config schema          | Configuration | config/schema.json             | New section          | LOW   |
| CI pipeline            | Infra         | .github/workflows/test.yml     | Add new test suite   | LOW   |

## Affected Features

| Existing Feature        | How Affected                              | Regression Risk | Mitigation                    |
|------------------------|-------------------------------------------|-----------------|-------------------------------|
| User profile           | New fields added to user model            | LOW             | Backward-compatible migration |
| Admin dashboard        | New widget needs layout adjustment        | MED             | Test existing layout doesn't break |
| Notification system    | Must handle new event types               | MED             | Add fallback for unknown types |

## Dependency Graph (Existing → New)

Existing modules the new feature depends on, and their stability:

| Dependency              | Stability | Last Changed  | API Surface Used        |
|------------------------|-----------|---------------|-------------------------|
| src/lib/validators.py  | STABLE    | 6 months ago  | validate_email()        |
| src/services/mailer.py | ACTIVE    | 2 weeks ago   | send_template_email()   |

## Required Changes to Existing Code

Each entry becomes a task candidate for `tasks.md`:

- [ ] IMPACT-001: Add `preferences` JSON field to `User` model + migration
- [ ] IMPACT-002: Extend `auth.py` middleware to recognize `editor` role
- [ ] IMPACT-003: Register `/api/v1/preferences` route in `routes.py`
- [ ] IMPACT-004: Add `PreferencesUpdated` event to `dispatcher.py`
- [ ] IMPACT-005: Update `dashboard.tsx` layout grid to support new widget

## Test Impact

Existing test files that will need updates:

| Test File                        | Reason                          |
|---------------------------------|---------------------------------|
| tests/test_user_model.py        | New field, new validation       |
| tests/test_auth_middleware.py   | New role                        |
| tests/integration/test_api.py   | New routes                      |
```

#### Where It Fits in the Pipeline

**Option A (recommended):** New extension `codebase-impact` with hook `after_plan` (runs alongside or before `ux-research`). The fleet orchestrator would insert it as Phase 3.5, between Plan and UX Research.

**Option B:** Extend `speckit.plan` Phase 0 research to include codebase scanning. Downside: couples the core plan command to a potentially expensive codebase crawl.

#### How It Works

1. **Parse the spec** for entity names, API endpoints, route paths, event names, model fields, page names — anything that might collide with existing code.
2. **Grep/AST-scan the codebase** for references to those names and for files in the directories the plan's project structure targets.
3. **Classify each hit** as: existing code to MODIFY, existing code to EXTEND (add interface), existing code to DEPEND ON (read-only), or existing code at RISK (might break).
4. **Cross-reference with `data-model.md`** and `contracts/` to find schema mismatches or contract conflicts.
5. **Produce `codebase-impact.md`** with the tables above.
6. **Feed findings into `tasks.md`**: The `IMPACT-NNN` items become input for `speckit.tasks`, ensuring that "modify existing file X" tasks are not forgotten.

### Implementation Steps

| Size | Action |
|------|--------|
| L | Create `extensions/codebase-impact/` with `extension.yml`, `config-template.yml`, `commands/codebase-impact-analyze.md`, `CHANGELOG.md`, `README.md` |
| M | Write the analyze command with the 6-step workflow above |
| S | Register `after_plan` hook in `extension.yml` |
| M | Update `fleet-run.md` to insert Phase 3.5 (Codebase Impact) between Plan and UX Research, with `codebase-impact.md` as artifact signal |
| S | Update `fleet-review.md` to add "Codebase Impact Coverage" as review dimension 8 |
| M | Update `speckit.tasks` delegation in fleet to include `IMPACT-NNN` items as task candidates |
| S | Update repo `README.md` with new extension entry |

### Version Impact

- New extension: `codebase-impact` at **0.1.0**
- `fleet`: **0.2.0** (MINOR — new optional phase, graceful skip if extension missing)

---

## Suggested Priority Order

### Phase 1 — Immediate cleanup
- Fix schema/template mismatches.
- Normalize manifest metadata.
- Add missing README quick starts.
- Standardize namespace direction.

### Phase 2 — Better usability
- Improve error handling and fallback paths.
- Add companion helper commands (`report`, `sync`, `preflight`).
- Improve documentation around installation and execution timing.

### Phase 3 — Stronger integration
- Formalize shared contracts between `fleet`, `dod`, `code-quality`, and `ux-research`.
- Build repo-level validation and consistency tooling.
- **Add architecture, workflow, and screen wireframe outputs to `ux-research`** (feeds into Stitch).
- **Add `codebase-impact` extension** for interaction analysis during planning.

---

## Recommendation

If only a few improvements are done next, prioritize these five:

1. **Unify namespaces and manifest completeness** across all extensions.
2. **Fix config-schema / config-template drift** and add automated validation.
3. **Strengthen the `fleet` + `dod` + `code-quality` integration contract** so the ecosystem behaves like one coherent system.
4. **Add architecture/workflow/screen schemata to `ux-research`** so the Stitch agent has authoritative layout blueprints instead of reconstructing intent from task descriptions.
5. **Create `codebase-impact` extension** so the research phase surfaces how new code interacts with existing code _before_ implementation starts — preventing scope discovery during coding.
