---
description: "Copy sk-query scripts to .specify/scripts/ after the greppable-templates preset is activated"
mode: agent
user-invocable: true
---

# speckit.greppable-templates.install

## Purpose

Copies `sk-query` shell scripts from the installed `greppable-templates` preset into `.specify/scripts/` so they can be run from any project directory.

Templates are applied automatically by the preset resolution stack — this command only handles the bundled scripts (which spec-kit doesn't yet install via `type: "script"`).

## What Gets Installed

| Source (preset) | Destination (project) | Purpose |
|---|---|---|
| `scripts/sk-query.sh` | `.specify/scripts/sk-query.sh` | Bash query tool |
| `scripts/sk-query.ps1` | `.specify/scripts/sk-query.ps1` | PowerShell query tool |

## Steps

### Step 1: Locate Preset Root

Find the `greppable-templates` preset directory:

1. Check `.specify/presets/greppable-templates/` (installed preset via `specify preset add`)
2. Check sibling `presets/greppable-templates/` (local dev workspace)
3. Ask user for the path if neither found

### Step 2: Create Target Directory

```bash
mkdir -p .specify/scripts
```

### Step 3: Copy Scripts

```bash
cp <preset-root>/scripts/sk-query.sh  .specify/scripts/sk-query.sh
cp <preset-root>/scripts/sk-query.ps1 .specify/scripts/sk-query.ps1
chmod +x .specify/scripts/sk-query.sh
```

Do not overwrite scripts that are newer than the preset version unless the user confirms with `--force`.

### Step 4: Report Result

```
✅ sk-query scripts installed.

Templates are applied automatically by the preset resolution stack.
Run 'specify preset resolve spec-template' to confirm greppable-templates is active.

## Marker Reference

| Marker      | File         | Shell query                                       |
|-------------|--------------|---------------------------------------------------|
| FR-NNN      | spec.md      | sk-query.sh fr spec.md                            |
| SC-NNN      | spec.md      | sk-query.sh sc spec.md                            |
| TASK-TNNN   | tasks.md     | sk-query.sh task tasks.md                         |
|             |              | sk-query.sh open tasks.md   (open only)           |
|             |              | sk-query.sh done tasks.md   (completed only)      |
|             |              | sk-query.sh stats tasks.md  (completion %)        |
|             |              | sk-query.sh story US1 tasks.md  (by user story)   |
| CHK-NNN     | checklist.md | sk-query.sh chk checklist.md                      |
| FINDING-NNN | *-review.md  | sk-query.sh findings code-review.md               |
|             | ux-report.md | sk-query.sh critical code-review.md               |

Scripts are at: .specify/scripts/sk-query.sh
Add to PATH:    export PATH="$PWD/.specify/scripts:$PATH"
```

### Step 5: Update .gitignore (optional)

If the project has a `.gitignore`, prompt whether to add:

```
# spec-kit greppable scripts (optional — remove to commit them)
# .specify/scripts/
```

## Output

- `.specify/scripts/sk-query.sh` — Bash query tool
- `.specify/scripts/sk-query.ps1` — PowerShell query tool
