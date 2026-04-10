---
description: "Comprehensive code review: identify refactoring opportunities, tech debt, dead code, and code smells"
---

# Code Review

Perform a structured code review of all files changed during implementation. Identify refactoring opportunities, tech debt, dead code, and code smells. Produce a greppable review report.

## User Input

$ARGUMENTS

## Prerequisites

1. All tasks in `tasks.md` are marked `[x]` (implementation complete)
2. `spec.md` and `plan.md` exist for context

## Steps

### Step 1: Establish Review Scope

```bash
feature_dir=$(bash .specify/scripts/bash/check-prerequisites.sh --json | jq -r '.FEATURE_DIR')
```

Read `tasks.md` to identify all files created or modified during implementation. These are the review targets.

Also read:


- `spec.md` — for requirement context
- `plan.md` — for architecture decisions
- `.specify/memory/constitution.md` — for project conventions (if exists)

### Step 2: Refactoring Opportunities

<!-- GREP:CQ-REFACTORING -->
```
SCAN each file FOR:

  COMPLEXITY:
    - Functions > 30 lines
    - Cyclomatic complexity > 10
    - Nesting depth > 3 levels
    - Parameter count > 4

  DUPLICATION:
    - Repeated code blocks (3+ lines identical/similar)
    - Copy-paste patterns across files
    - Similar logic with minor variations (extract + parameterize)

  ABSTRACTION:
    - Missing interfaces/protocols where polymorphism is used
    - God classes (>300 lines, >7 methods)
    - Feature envy (method uses another class more than its own)
    - Shotgun surgery (one change requires touching many files)

  NAMING:
    - Inconsistent naming conventions within the feature
    - Misleading names (name doesn't match behavior)
    - Abbreviations that reduce readability

OUTPUT: refactoring table
  | ID   | File           | Line | Category      | Severity | Description                    | Recommendation          |
  |------|----------------|------|---------------|----------|--------------------------------|-------------------------|
  | RF01 | src/service.py | 45   | Complexity    | MEDIUM   | Function 42 lines, 3 branches | Extract helper methods  |
  | RF02 | src/views.py   | 120  | Duplication   | HIGH     | 15-line block repeated 3x     | Extract shared utility  |
```

### Step 3: Tech Debt Analysis

<!-- GREP:CQ-TECH-DEBT -->
```
SCAN FOR:

  SHORTCUTS:
    - TODO/FIXME/HACK/XXX comments in new code
    - Hardcoded values that should be configurable
    - Missing error handling (bare except, swallowed errors)
    - Temporary workarounds with no cleanup plan

  DEPENDENCIES:
    - Tight coupling between layers
    - Circular dependencies
    - Missing dependency injection
    - Direct database access from presentation layer

  TESTING:
    - Missing test coverage for critical paths
    - Tests that test implementation instead of behavior
    - Missing edge case tests
    - Fragile tests (depend on ordering, timing, external state)

  INFRASTRUCTURE:
    - Missing indexes for queried fields
    - N+1 query patterns
    - Missing caching where appropriate
    - Unbounded queries (no pagination/limits)

OUTPUT: tech-debt table
  | ID   | File           | Category     | Severity | Description                  | Effort | Priority |
  |------|----------------|-------------|----------|------------------------------|--------|----------|
  | TD01 | src/models.py  | Performance  | HIGH     | N+1 query in list endpoint   | 1h     | P1       |
  | TD02 | src/auth.py    | Shortcut     | MEDIUM   | Hardcoded token expiry       | 30min  | P2       |
```

### Step 4: Dead Code Detection

<!-- GREP:CQ-DEAD-CODE -->
```
SCAN FOR:

  UNREACHABLE:
    - Functions/methods never called (search for usages)
    - Import statements for unused modules
    - Variables assigned but never read
    - Unreachable code after return/raise/break

  COMMENTED OUT:
    - Commented-out code blocks (>3 lines)
    - Disabled test cases
    - Old implementations left as "reference"

  VESTIGIAL:
    - Empty classes/interfaces with no implementations
    - Configuration for removed features
    - Migration files that can be squashed

OUTPUT: dead-code table
  | ID   | File           | Line  | Type         | Description                      | Action      |
  |------|----------------|-------|-------------|----------------------------------|-------------|
  | DC01 | src/utils.py   | 88    | Unused func  | format_legacy() — 0 call sites  | Remove      |
  | DC02 | src/views.py   | 201   | Commented    | 12 lines of old implementation   | Remove      |
```

### Step 5: Code Smell Detection

<!-- GREP:CQ-CODE-SMELLS -->
```
SCAN FOR:

  STRUCTURAL:
    - Long method (>30 lines)
    - Large class (>300 lines)
    - Long parameter list (>4 params)
    - Data clumps (same group of params in multiple places)
    - Primitive obsession (strings/ints where value objects fit)

  BEHAVIORAL:
    - Switch/if-else chains (>3 branches on same condition)
    - Type checking (isinstance/typeof chains)
    - Temporary fields (fields only used in some methods)
    - Message chains (a.b.c.d.method())

  COUPLING:
    - Inappropriate intimacy (class accesses another's internals)
    - Middle man (class delegates everything)
    - Speculative generality (abstractions for hypothetical future use)

OUTPUT: smell table
  | ID   | File           | Line | Smell              | Severity | Description                 |
  |------|----------------|------|--------------------|----------|-----------------------------|
  | CS01 | src/handler.py | 30   | Long Method        | MEDIUM   | 45-line request handler     |
  | CS02 | src/models.py  | 15   | Primitive Obsession| LOW      | Email as plain string       |
```

### Step 6: Generate Code Review Report

Write `code-review.md` to `{feature_dir}/reviews/`:

<!-- GREP:CQ-REVIEW-TEMPLATE -->
```markdown
# Code Review: [FEATURE NAME]

**Generated**: [DATE]
**Files Reviewed**: [N]
**Total Findings**: [N]

## Summary

| Category              | Critical | High | Medium | Low | Total |
|-----------------------|----------|------|--------|-----|-------|
| Refactoring           | —        | N    | N      | N   | N     |
| Tech Debt             | N        | N    | N      | N   | N     |
| Dead Code             | —        | N    | N      | N   | N     |
| Code Smells           | —        | N    | N      | N   | N     |
| **Total**             | **N**    | **N**| **N**  | **N**| **N**|

## Refactoring Opportunities
[table from Step 2]

## Tech Debt
[table from Step 3]

## Dead Code
[table from Step 4]

## Code Smells
[table from Step 5]

## Action Items (prioritized)

<!--
  GREPPABLE FORMAT: each item MUST also appear as a checkbox item starting with - [ ] FINDING-NNN
  Format: - [ ] FINDING-NNN: severity | category | location | description
  Severity: critical | high | medium | low | info
  Category: refactor | tech-debt | dead-code | smell | perf | security
  Shell: grep "\- \[ \] FINDING-" code-review.md
         sk-query.sh findings code-review.md
         sk-query.sh critical code-review.md
-->

### Must Fix (Critical/High)
- [ ] FINDING-001: critical | [category] | [file:line] | [description]

### Should Fix (Medium)
- [ ] FINDING-002: medium | [category] | [file:line] | [description]

### Consider (Low)
- [ ] FINDING-003: low | [category] | [file:line] | [description]
```

## Output

Produces `{feature_dir}/reviews/code-review.md` with all findings.
