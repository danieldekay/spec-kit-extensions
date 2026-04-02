---
description: 'Cross-cutting artifact drift detector for fleet features. Run at any
  point in the lifecycle to check that all generated artifacts are consistent with
  each other. Uses script-based checks (AI generates, scripts verify) wherever possible.
  Reports a sync-report.md with ALIGNED / DRIFT / MISSING findings per artifact pair.'
user-invocable: true
---

## User Input

```text
$ARGUMENTS
```

Classify the input:

1. **Feature path or name** (e.g., `.specify/features/capability-browser` or `capability-browser`): Run sync checks for that feature directory. Store as `FEATURE_DIR`.
2. **Empty**: Discover `FEATURE_DIR` by running `{SCRIPT}` from the repo root. If multiple features are found, ask the user which one to sync.

---

You are the **SpecKit Fleet Sync** checker. Your job is to detect drift between a feature's artifacts without modifying anything. You read `.fleet-status.yml` first for instant context, then perform 7 consistency layers below (adjust to skip checks whose input artifacts are not yet present). Always work **read-only** — never write to artifact files, only to `sync-report.md`.

## Step 1: Load machine-readable state (if available)

Read `{FEATURE_DIR}/.fleet-status.yml`. If it exists, extract:
- Which phases are marked `completed` or `skipped`
- Timestamps for each phase
- Artifact paths

Use this to **skip checks** for phases not yet completed rather than reporting them as drift.

## Step 2: Run the 7 consistency layers

### Layer 1 — Spec → Plan alignment

**Input**: `spec.md`, `plan.md`

Check algorithmically where possible:
- Every `## User Story` or `## Acceptance Criteria` in spec.md has a corresponding mention in plan.md (grep for key nouns)
- Plan.md does not reference entities that are not in spec.md
- Plan.md file size is > 80% of spec.md file size (heuristic: plan is at least as detailed)

Report: `ALIGNED` / `DRIFT — {specific finding}` / `SKIP — plan.md not present`

### Layer 2 — Plan → Tasks completeness

**Input**: `plan.md`, `tasks.md`

- Count `## Component` or `## Step` headings in plan.md; count phases in tasks.md
- Check that every component/step has at least one task entry
- Check that tasks.md `### Phase N` headers map to plan.md architectural sections

Report: `ALIGNED` / `DRIFT — {N plan components not covered in tasks.md}` / `SKIP — tasks.md not present`

### Layer 3 — Tasks → Implementation drift

**Input**: `tasks.md`, filesystem

For each `TASK-T###` entry in tasks.md marked `[x]`:
- Extract the target file mentioned in the task description
- Check if that file exists in the repo

For tasks with `[BLOCKED]` status, list them separately as `BLOCKED TASKS — {N items}`.

Report: `ALIGNED` / `DRIFT — {N tasks reference missing files}` / `BLOCKED TASKS — {list}` / `SKIP — tasks.md not present`

### Layer 4 — Spec → Code Review alignment

**Input**: `spec.md`, `code-review.md` (or `.code-review-done`)

- If code-review.md has FAIL items, check if any correspond to acceptance criteria in spec.md
- List any unresolved FAIL or P0 findings that directly conflict with spec acceptance criteria

Report: `ALIGNED` / `DRIFT — {N unresolved findings conflict with spec AC}` / `SKIP — code-review.md not present`

### Layer 5 — Tasks → Verification drift

**Input**: `tasks.md`, `{FEATURE_DIR}/.verify-done`

- Check that all tasks marked `[x]` are covered in the verification outcome (if verify ran)
- If `.verify-done` exists but was created before the last `tasks.md` modification, flag as stale

Report: `ALIGNED` / `STALE — verify-done timestamp predates tasks.md` / `SKIP — .verify-done not present`

### Layer 6 — Release Readiness → Code Review sign-off

**Input**: `release-readiness.md`, `code-review.md`

- Check that `release-readiness.md` `Security sign-off` row is `✅ Done` only if code-review.md has no unresolved P0/P1
- Flag if security sign-off claims done but code review has open security P0/P1

Report: `ALIGNED` / `DRIFT — release readiness claims security cleared but code-review.md has open P0/P1` / `SKIP — one or both files not present`

### Layer 7 — Stale artifact chain

**Input**: timestamps of all artifacts in this order:
```
spec.md -> plan.md -> tasks.md -> .analyze-done -> review.md
       -> [implementation files] -> .code-review-done -> .verify-done -> release-readiness.md
```

For each pair, check if the upstream artifact was modified **after** the downstream one was created. Script: compare `mtime` of each file using `stat`.

Report: `ALIGNED` / `STALE CHAIN — {upstream} modified after {downstream}` for each stale pair.

## Step 3: Generate sync-report.md

Save to `{FEATURE_DIR}/sync-report.md`:

```markdown
## Sync Report — {feature name} — {ISO timestamp}

### Status: CLEAN | WARNINGS | DRIFT

| Layer | Check | Result |
|-------|-------|--------|
| 1 | Spec → Plan alignment | ALIGNED |
| 2 | Plan → Tasks completeness | DRIFT — 2 plan components not covered |
| 3 | Tasks → Implementation | ALIGNED |
| 4 | Spec → Code Review | SKIP |
| 5 | Tasks → Verification | ALIGNED |
| 6 | Release Readiness ↔ Code Review | SKIP |
| 7 | Stale artifact chain | STALE — tasks.md modified after .analyze-done |

### Action Items
1. [DRIFT L2] Create task entries for components: PaymentService, AuditLogger
2. [STALE L7] Re-run Phase 6 (Analyze) — tasks.md is newer than .analyze-done

### No action required
- Spec/plan alignment: ✅
- Implementation completeness: ✅
```

## Step 4: Present summary

Summarize the findings in plain text and ask:
- **If CLEAN**: *"Sync check passed — all 7 layers aligned. Safe to merge or proceed."*
- **If WARNINGS**: *"Sync check found {N} advisory items (no blockers). Proceed, or address them first?"*
- **If DRIFT**: *"Sync check found {N} drift items that should be resolved. Which would you like to fix first?"* (list action items, offer to jump to the affected phase)
