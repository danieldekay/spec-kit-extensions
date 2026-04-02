# Findings: [FEATURE NAME / REVIEW TYPE]

**Generated**: [DATE]
**Source**: [code-review | ux-research | research | analysis]
**Feature**: [path to spec.md]
**Total Findings**: [N]

<!--
  GREPPABLE FORMAT: Each finding must use the FINDING-NNN: prefix at the start of the line.
  Format: FINDING-NNN: severity | category | location | description
  
  Severity levels: critical | high | medium | low | info
  Categories:      refactor | tech-debt | dead-code | smell | ux | perf | security | a11y | pattern
  Location:        file:line, component name, section name, or "global"
  
  Shell query: grep "^FINDING-" findings.md
               grep "^FINDING-.*critical" findings.md
               grep "^FINDING-.*refactor" findings.md
               sk-query.sh findings findings.md
-->

## Summary

| Severity | Count |
|----------|-------|
| critical | [N]   |
| high     | [N]   |
| medium   | [N]   |
| low      | [N]   |
| info     | [N]   |

## Findings

<!--
  List all findings here using the greppable FINDING-NNN: prefix.
  Examples:
  
  FINDING-001: critical | refactor | src/auth/session.py:45 | Session token not invalidated on logout
  FINDING-002: high | security | src/api/users.py:120 | Missing authorization check on delete endpoint
  FINDING-003: medium | tech-debt | src/models/user.py:1-200 | Model handles 5 concerns — split into User, Profile, Preferences
  FINDING-004: low | dead-code | src/utils/legacy.py | File never imported — safe to delete
  FINDING-005: info | pattern | src/components/Button | Reusable Button component available — use instead of inline styles
-->

FINDING-001: [severity] | [category] | [location] | [description]
FINDING-002: [severity] | [category] | [location] | [description]
FINDING-003: [severity] | [category] | [location] | [description]

## Action Items

### Must Fix (critical / high)

<!-- FINDING-NNN items with severity critical or high go here as an action list -->
- [FINDING-001] [description] — [owner or auto-assigned]

### Should Fix (medium)

<!-- FINDING-NNN items with severity medium -->
- [FINDING-002] [description]

### Consider (low / info)

<!-- FINDING-NNN items with severity low or info -->
- [FINDING-003] [description]

## Notes

[Any additional context, links to related issues, or follow-up actions]
