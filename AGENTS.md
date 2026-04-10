# AGENTS.md — spec-kit-extensions

Concise reference for AI coding agents working in this repository. This repo contains custom presets and extensions for [Spec Kit](https://github.com/github/spec-kit) — the spec-driven development framework.

---

## Repository Purpose

This repo provides **opt-in extensions** and **presets** that extend the core Spec Kit workflow without modifying it. All artefacts follow the [Spec Kit Extension System RFC](https://github.com/github/spec-kit/blob/main/extensions/RFC-EXTENSION-SYSTEM.md).

---

## Repository Structure

```
spec-kit-extensions/
├── extensions/
│   ├── codebase-impact/     # Codebase interaction analysis (v0.1.0)
│   ├── code-quality/        # Post-implementation quality pipeline (v0.1.0)
│   ├── dod/                 # Definition of Done generator (v0.1.0)
│   ├── fleet/               # Autonomous 14-phase lifecycle orchestrator (v0.1.0)
│   ├── maqa-github-projects/# GitHub Projects v2 integration (v0.1.0)
│   ├── stitch-implement/    # Stitch MCP UI prototyping (v0.1.0)
│   └── ux-research/         # UX research phase for planning (v0.1.0)
└── presets/
    └── greppable-templates/ # Greppable markers for spec/tasks/checklist
```

Each extension directory contains:

```
<extension>/
├── extension.yml            # REQUIRED — manifest (see RFC schema)
├── config-template.yml      # REQUIRED — user-editable config
├── commands/                # REQUIRED — one .md file per command
├── CHANGELOG.md             # REQUIRED — Keep a Changelog format
└── README.md                # REQUIRED — usage docs
```

---

## Extension Manifest Rules (RFC-compliant)

Every `extension.yml` **must** satisfy these rules. Agents must validate them before writing or modifying any manifest:

### Required Fields

```yaml
schema_version: "1.0"          # Always "1.0"

extension:
  id: "<lowercase-kebab>"       # Unique, alphanumeric + hyphens only
  name: "<Human Readable Name>"
  version: "<semver>"           # e.g. "1.2.3" — MUST follow SemVer 2.0.0
  description: "<one sentence>"
  author: "<github-handle or org>"
  license: "MIT"

requires:
  speckit_version: ">=0.1.0"   # SemVer range

provides:
  commands:
    - name: "<author>.<ext-id>.<command>"  # Namespace convention
      file: "commands/<file>.md"
      description: "<one sentence>"
```

### Optional but Strongly Recommended

```yaml
extension:
  repository: "https://github.com/..."
  homepage:   "https://github.com/.../README.md"

changelog: "https://github.com/.../CHANGELOG.md"

support:
  documentation: "https://..."
  issues:        "https://..."

tags:
  - "keyword"
```

### Validation Rules (from RFC Section 5)

1. `schema_version`, `extension`, `requires`, `provides` are **MUST** fields — fail if missing.
2. `extension.version` **MUST** be a valid SemVer 2.0.0 string (`MAJOR.MINOR.PATCH`).
3. `extension.id` **MUST** be unique across all extensions in this repo.
4. Command `file` paths **MUST** be relative to the extension root.
5. Hook `command` values **MUST** match a name defined in `provides.commands`.
6. `config_schema` **SHOULD** be present if the extension reads a config file.

---

## Versioning Policy (SemVer)

All extensions are versioned independently using [Semantic Versioning 2.0.0](https://semver.org/).

| Change type | Version bump |
|-------------|-------------|
| New command added | `MINOR` |
| Breaking change to command behaviour or config schema | `MAJOR` |
| Bug fix, doc update, new optional config key | `PATCH` |
| New hook added | `MINOR` |
| Removing a command or config key | `MAJOR` |

**Rules for agents:**

- When you edit a command file, config template, or `extension.yml`, **always bump the version** in `extension.yml`.
- When you bump the version, **always add a changelog entry** in `CHANGELOG.md` under a new `## [X.Y.Z] — YYYY-MM-DD` heading (Keep a Changelog format).
- Never skip the changelog. A PR that bumps a version without a matching changelog entry is invalid.

---

## Command Naming Convention

Commands use a three-part namespace:

```
<author>.<extension-id>.<command-name>
```

Examples from this repo:

| Full command name | Extension |
|-------------------|-----------|
| `dk.code-quality.pipeline` | code-quality |
| `dk.code-quality.specfact-sync` | code-quality |
| `dk.dod.generate` | dod |
| `dk.dod.validate` | dod |
| `dk.fleet.run` | fleet |
| `dk.codebase-impact.analyze` | codebase-impact |
| `dk.ux-research.analyze` | ux-research |

Aliases are allowed and declared in `provides.commands[*].aliases`.

---

## Hook System

Extensions may register hooks fired by Spec Kit core lifecycle events:

| Hook name | Fires after |
|-----------|-------------|
| `after_specify` | `/speckit.specify` completes |
| `after_plan` | `/speckit.plan` completes |
| `after_tasks` | `/speckit.tasks` completes |
| `after_implement` | `/speckit.implement` completes |
| `before_implement` | Before `/speckit.implement` starts |

Hooks are declared under `hooks:` in `extension.yml`. The `optional: true` flag means the user is prompted; `optional: false` means the hook fires automatically.

---

## Current Extensions

### `code-quality` — v0.1.0

Post-implementation code quality pipeline. Runs review → fix → validate → future-ideas with gate checks between stages, plus specfact export for CI governance.

Hook: `after_implement`  
Key commands: `dk.code-quality.pipeline`, `dk.code-quality.validate`, `dk.code-quality.specfact-sync`  
Integrates with: [specfact.com](https://specfact.com), [`dod` extension](#dod--v100) (optional bridge)

### `dod` — v0.1.0

Generates machine-readable, testable Definitions of Done from `spec.md`. Produces `dod.yml` validated against a JSON Schema, updates criterion statuses after implementation, and exports to specfact-compatible JSON for CI/CD enforcement.

Hooks: `after_specify` (generate), `after_implement` (validate)  
Key commands: `dk.dod.generate`, `dk.dod.validate`, `dk.dod.export`, `dk.dod.report`  
Schemas: `schemas/dod.schema.json` (dod.yml), `schemas/specfact-export.schema.json` (specfact export, format ID: `speckit-dod-export-v1`)

### `fleet` — v0.1.0

Autonomous 14-phase feature lifecycle orchestrator. Runs specify → clarify → plan → ux-research → checklist → tasks → analyze → review → stitch-prototype → implement → stitch-validate → code-review → release-readiness → CI. Auto-resumes from interruptions, only surfaces `vscode_askQuestions` for critical blockers.

Hook: standalone (orchestrates all core hooks internally)  
Key commands: `dk.fleet.run`, `dk.fleet.sync`, `dk.fleet.change-request`

### `maqa-github-projects` — v0.1.0

GitHub Projects v2 integration. Populates draft issues from specs, moves items across status columns, ticks task lists in issue bodies.

Hook: standalone  
Key commands: `dk.maqa-github-projects.bootstrap`, `dk.maqa-github-projects.populate`

### `codebase-impact` — v0.1.0

Codebase impact analysis phase. Scans the existing codebase for integration points, affected features, dependency stability, and test impact. Produces `codebase-impact.md` with greppable `IMPACT-NNN` task candidates that feed into `tasks.md`.

Hook: `after_plan`
Key commands: `dk.codebase-impact.analyze`

### `stitch-implement` — v0.1.0

Stitch MCP sub-agent for UI prototyping and validation during implementation.

Hooks: `before_implement` / `after_implement`  
Key commands: `dk.stitch-implement.prototype`, `dk.stitch-implement.validate`  
Requires: Stitch MCP server `>=1.0.0`

### `ux-research` — v0.1.0

Adds a UX research phase to planning. Identifies required UX changes and discovers reusable patterns from the existing tech stack.

Hook: `after_plan`  
Key commands: `dk.ux-research.analyze`

---

## Adding a New Extension

1. **Create the directory**: `extensions/<id>/`
2. **Write `extension.yml`** following the RFC schema above. Start at `1.0.0`.
3. **Create `CHANGELOG.md`** with an `## [1.0.0]` entry.
4. **Write commands** in `commands/<name>.md` with frontmatter `description` and `id` fields.
5. **Create `config-template.yml`** if the extension reads config.
6. **Write `README.md`** with installation, commands table, and usage.
7. **Update repo `README.md`**: add a row to the Extensions table.
8. Validate the manifest:
   - All required fields present
   - `extension.id` is unique
   - SemVer format for `version`
   - All hook `command` values match a `provides.commands[*].name`

---

## Modifying an Existing Extension

1. Read `extension.yml` and `CHANGELOG.md` before making any changes.
2. Apply the change to the relevant command file, config template, or manifest.
3. Determine the correct SemVer bump (see Versioning Policy above).
4. Update `extension.yml` → `extension.version`.
5. Add a new `## [X.Y.Z] — YYYY-MM-DD` section to `CHANGELOG.md` describing the change.
6. If a new command was added, update the extension's `README.md` commands table.
7. If the change affects the repo-level summary, update the root `README.md`.

---

## Presets

Presets override core Spec Kit templates and sit high in the resolution stack. They do **not** use `extension.yml`; they are raw template files installed via `specify preset add <id>`.

**`greppable-templates`**: Replaces spec/tasks/checklist templates with versions that emit structured line-start markers (`FR-NNN:`, `SC-NNN:`, `TASK-TNNN:`, `CHK-NNN:`) queryable with `sk-query.sh`.

---

## Grep Tags

All command templates use `<!-- GREP:TAG -->` markers for searchability. Tag prefix conventions:

| Prefix | Extension |
|--------|-----------|
| `GREP:CQ-*` | code-quality |
| `GREP:DOD-*` | dod |
| `GREP:FLEET-*` | fleet |
| `GREP:UXR-*` | ux-research |
| `GREP:CI-*` | codebase-impact |
| `GREP:STITCH-*` | stitch-implement |
| `GREP:MAQA-*` | maqa-github-projects |

---

## Development Guidelines for Agents

- **Read before writing.** Always read `extension.yml` and `CHANGELOG.md` before modifying an extension.
- **SemVer is mandatory.** Every code change → version bump → changelog entry. No exceptions.
- **RFC compliance.** All manifests must satisfy the RFC validation rules listed above.
- **No cross-extension coupling.** Extensions communicate via shared file conventions (`dod.yml`, `quality-export.json`) not by importing each other's code.
- **Config over code.** Behavioural toggles belong in `config-template.yml` with `config_schema` validation, not hard-coded in commands.
- **Grep tags.** Add `<!-- GREP:PREFIX-SECTION-NAME -->` to every substantive section of a new command file.
- **Keep command files self-contained.** A command file must be understandable in isolation; link to config or schema files by path, do not embed their full content.
