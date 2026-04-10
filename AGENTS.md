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
│   ├── fleet/               # All-in-one 17-phase orchestrator (v1.0.0) — bundles DoD, Impact, UX, Stitch, Code Quality
│   └── maqa-github-projects/# GitHub Projects v2 integration (v0.1.0)
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
| `speckit.fleet.run` | fleet |
| `speckit.fleet.sync` | fleet |
| `speckit.fleet.change-request` | fleet |
| `speckit.fleet.dod-generate` | fleet (DoD) |
| `speckit.fleet.dod-validate` | fleet (DoD) |
| `speckit.fleet.codebase-impact-analyze` | fleet (Impact) |
| `speckit.fleet.ux-research-analyze` | fleet (UX) |
| `speckit.fleet.stitch-prototype` | fleet (Stitch) |
| `speckit.fleet.quality-pipeline` | fleet (Code Quality) |
| `speckit.fleet.specfact-sync` | fleet (Code Quality) |

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

### `fleet` — v1.0.0

All-in-one 17-phase lifecycle orchestrator. Bundles DoD, Codebase Impact, UX Research, Stitch MCP, and Code Quality as built-in capabilities — one `specify extension add fleet` brings all 20 commands.

Hooks: `after_specify`, `after_plan` (2), `before_implement`, `after_implement` (3)  
Key commands: `speckit.fleet.run`, `speckit.fleet.sync`, `speckit.fleet.change-request`  
Bundled capabilities: DoD (4 commands), Codebase Impact (1), UX Research (1), Stitch (3), Code Quality (6)  
Schemas: `schemas/dod.schema.json`, `schemas/specfact-export.schema.json`

### `maqa-github-projects` — v0.1.0

GitHub Projects v2 integration. Populates draft issues from specs, moves items across status columns, ticks task lists in issue bodies.

Hook: standalone  
Key commands: `speckit.maqa-github-projects.bootstrap`, `speckit.maqa-github-projects.populate`

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
| `GREP:FLEET-*` | fleet (orchestrator) |
| `GREP:CQ-*` | fleet (code-quality) |
| `GREP:DOD-*` | fleet (dod) |
| `GREP:UXR-*` | fleet (ux-research) |
| `GREP:CI-*` | fleet (codebase-impact) |
| `GREP:STITCH-*` | fleet (stitch) |
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
