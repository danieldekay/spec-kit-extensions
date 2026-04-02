# Stitch Implementation Extension

Integrates Google Stitch MCP into the spec-kit implementation phase for UI prototyping, code extraction, and post-implementation validation.

## Installation

```bash
specify extension add stitch-implement --source ./extensions/stitch-implement
```

## Requirements

- Stitch MCP server configured in your AI agent
- Active Stitch account

## Commands

| Command | Description |
|---------|-------------|
| `speckit.stitch-implement.prototype` | Generate UI screens and extract code patterns |
| `speckit.stitch-implement.validate` | Validate implementation against prototypes |

## Modes

Controlled by `stitch.mode` in configuration:

| Mode | Before Implement | After Implement |
|------|-----------------|-----------------|
| `prototype` | Generate screens | — |
| `validate` | — | Check consistency |
| `both` | Generate screens | Check consistency |

## Grep Tags

| Tag | Section |
|-----|---------|
| `GREP:STITCH-UI-TASKS` | UI task identification |
| `GREP:STITCH-PROJECT-SETUP` | Stitch project creation |
| `GREP:STITCH-SCREEN-GENERATION` | Screen generation workflow |
| `GREP:STITCH-CODE-EXTRACTION` | Code pattern extraction |
| `GREP:STITCH-GUIDE-TEMPLATE` | Implementation guide output |
| `GREP:STITCH-VALIDATION` | Post-implementation validation |
| `GREP:STITCH-TOKEN-AUDIT` | Design token compliance check |
| `GREP:STITCH-VALIDATION-REPORT` | Validation report output |
