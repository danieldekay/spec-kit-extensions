---
description: "Generate ideas for improving and extending the feature further"
---

# Future Ideas

Analyze the implemented feature and generate structured improvement ideas across short, medium, and long-term horizons. Focus on practical enhancements, not theoretical perfection.

## User Input

$ARGUMENTS

## Prerequisites

1. Implementation is complete (all tasks `[x]`)
2. Code review and fixes are done (review artifacts exist)
3. `spec.md` and `plan.md` available for context

## Steps

### Step 1: Load Feature Context

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
```

Read all available artifacts: `spec.md`, `plan.md`, `tasks.md`, review reports, and the implemented source code.

### Step 2: Performance Improvements

<!-- GREP:CQ-FUTURE-PERFORMANCE -->
```
ANALYZE implemented code FOR:

  QUERY OPTIMIZATION:
    - Queries that could benefit from caching
    - Aggregations that could be pre-computed
    - Joins that could be denormalized for read-heavy paths

  RENDERING:
    - Components that re-render unnecessarily
    - Large lists without virtualization
    - Images without lazy loading
    - Missing bundle-splitting opportunities

  I/O:
    - Sequential operations that could be parallelized
    - Missing connection pooling
    - Unbatched operations (N API calls → 1 batch)

OUTPUT: performance table
  | ID   | Category | Current State         | Improvement                | Impact   | Effort |
  |------|----------|-----------------------|----------------------------|----------|--------|
  | PF01 | Query    | N+1 on dashboard load | Add select_related/prefetch| HIGH     | 2h     |
  | PF02 | Render   | Full list renders 500 items | Add virtualization    | MEDIUM   | 4h     |
```

### Step 3: Scalability Considerations

<!-- GREP:CQ-FUTURE-SCALABILITY -->
```
EVALUATE FOR:

  DATA GROWTH:
    - Will this work with 10x data?
    - Are there unbounded queries?
    - Is pagination implemented?

  USER GROWTH:
    - Rate limiting considerations
    - Session/cache strategy at scale
    - Background job offloading opportunities

  FEATURE GROWTH:
    - Extension points for future capabilities
    - Plugin/hook architecture opportunities
    - Configurable behavior vs hardcoded logic

OUTPUT: scalability table
  | ID   | Dimension | Risk at Scale          | Recommendation              | Horizon |
  |------|-----------|------------------------|-----------------------------|---------|
  | SC01 | Data      | Dashboard query O(n²)  | Add materialized view       | Medium  |
  | SC02 | Users     | No rate limiting       | Add per-user throttling     | Short   |
```

### Step 4: Developer Experience

<!-- GREP:CQ-FUTURE-DX -->
```
EVALUATE:

  ONBOARDING:
    - Is the code self-documenting?
    - Are there missing README sections?
    - Are error messages actionable?

  DEBUGGING:
    - Logging coverage for critical paths
    - Observability hooks (metrics, tracing)
    - Debug mode/tools available

  TESTING:
    - Missing test utilities/factories
    - Integration test gaps
    - E2E test candidates

OUTPUT: dx-improvement table
  | ID   | Area       | Current Gap               | Improvement              | Effort |
  |------|------------|---------------------------|--------------------------|--------|
  | DX01 | Onboarding | No API usage examples      | Add quickstart guide     | 2h     |
  | DX02 | Debugging  | Silent failures in auth    | Add structured logging   | 3h     |
```

### Step 5: Feature Evolution Ideas

<!-- GREP:CQ-FUTURE-EVOLUTION -->
```
BRAINSTORM based on:
  - User stories that were deferred or out of scope
  - Adjacent features that complement this one
  - Common patterns from similar products
  - Automation opportunities

CLASSIFY by horizon:
  SHORT  (next sprint)  — Quick wins, low effort
  MEDIUM (1-3 months)   — Meaningful enhancements
  LONG   (3-6 months)   — Strategic capabilities

OUTPUT: evolution roadmap
  | ID   | Idea                          | Horizon | Value  | Effort | Dependencies |
  |------|-------------------------------|---------|--------|--------|--------------|
  | EV01 | Bulk import from CSV          | SHORT   | HIGH   | 1d     | None         |
  | EV02 | Real-time dashboard updates   | MEDIUM  | HIGH   | 1w     | WebSocket    |
  | EV03 | AI-powered data insights      | LONG    | MEDIUM | 2w     | ML pipeline  |
```

### Step 6: Generate Future Ideas Report

Write `future-ideas.md` to `{feature_dir}/reviews/`:

<!-- GREP:CQ-FUTURE-TEMPLATE -->
```markdown
# Future Ideas: [FEATURE NAME]

**Generated**: [DATE]
**Ideas Generated**: [N]

## Performance Improvements
[table from Step 2]

## Scalability Considerations
[table from Step 3]

## Developer Experience
[table from Step 4]

## Feature Evolution Roadmap

### Short Term (next sprint)
[items from Step 5]

### Medium Term (1-3 months)
[items from Step 5]

### Long Term (3-6 months)
[items from Step 5]

## Prioritized Backlog

| Rank | ID   | Title                    | Value  | Effort | Horizon |
|------|------|--------------------------|--------|--------|---------|
| 1    | PF01 | Query optimization       | HIGH   | 2h     | SHORT   |
| 2    | SC02 | Rate limiting            | HIGH   | 4h     | SHORT   |
| 3    | EV01 | Bulk CSV import          | HIGH   | 1d     | SHORT   |
[ranked by value/effort ratio]
```

## Output

Produces `{feature_dir}/reviews/future-ideas.md` with a prioritized improvement backlog.
