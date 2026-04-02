#!/usr/bin/env bash
# sk-query.sh — Query spec-kit artifact files by greppable marker type
#
# Usage: sk-query.sh <type> <file> [options]
#
# Types:
#   fr            Functional Requirements  (grep "^FR-")
#   sc            Success Criteria         (grep "^SC-")
#   task          All tasks                (grep "^TASK-")
#   open          Open tasks only          (TASK-T* with "[ ]")
#   done          Completed tasks only     (TASK-T* with "[x]" or "[X]")
#   parallel      Parallel tasks           (TASK-T* with "[P]")
#   story <USN>   Tasks for a user story   (TASK-T* with "[USN]", e.g. US1)
#   findings      All findings             (grep "^FINDING-")
#   critical      Critical findings        (FINDING-* with "critical")
#   high          High severity findings   (FINDING-* with "high")
#   chk           Checklist items          (grep "^CHK-")
#   open-chk      Open checklist items     (CHK-* with "[ ]")
#   done-chk      Done checklist items     (CHK-* with "[x]" or "[X]")
#   stats         Task completion stats
#   list-types    Show all available types
#
# Examples:
#   sk-query.sh fr spec.md
#   sk-query.sh sc spec.md
#   sk-query.sh task tasks.md
#   sk-query.sh open tasks.md
#   sk-query.sh done tasks.md
#   sk-query.sh stats tasks.md
#   sk-query.sh story US1 tasks.md
#   sk-query.sh findings code-review/code-review.md
#   sk-query.sh critical code-review/code-review.md
#   sk-query.sh chk checklists/requirements.md
#
# Auto-discovery (omit file, searches default locations):
#   sk-query.sh fr            → searches specs/**/ for spec.md
#   sk-query.sh task          → searches specs/**/ for tasks.md
#   sk-query.sh findings      → searches specs/**/ for *code-review*.md and ux-research-report.md

set -euo pipefail

TYPE="${1:-}"
shift || true

# ── helpers ──────────────────────────────────────────────────────────────────

die() { echo "ERROR: $*" >&2; exit 1; }

usage() {
  sed -n '/^# sk-query/,/^[^ #]/p' "$0" | grep "^#" | sed 's/^# \?//'
  exit 0
}

count_matches() {
  local pattern="$1" file="$2"
  grep -c "$pattern" "$file" 2>/dev/null || echo 0
}

find_default() {
  local name="$1"
  # Search current directory, then specs/, then feature subdirs
  local found
  found=$(find . -maxdepth 4 -name "$name" -not -path "*/.git/*" 2>/dev/null | head -1)
  echo "$found"
}

# ── auto-discovery for default file arguments ─────────────────────────────────

resolve_file() {
  local type="$1" arg="${2:-}"
  if [[ -n "$arg" && -f "$arg" ]]; then
    echo "$arg"; return
  fi
  case "$type" in
    fr|sc)       find_default "spec.md" ;;
    task|open|done|parallel|stats) find_default "tasks.md" ;;
    findings|critical|high)
      local f; f=$(find_default "code-review.md")
      [[ -z "$f" ]] && f=$(find_default "ux-research-report.md")
      echo "$f" ;;
    chk|open-chk|done-chk) find_default "*.md" ;;
    *) echo "" ;;
  esac
}

# ── query functions ───────────────────────────────────────────────────────────

q_fr() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# Functional Requirements — $file"
  echo ""
  grep "^FR-" "$file" || echo "(none found)"
}

q_sc() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# Success Criteria — $file"
  echo ""
  grep "^SC-" "$file" || echo "(none found)"
}

q_task() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# All Tasks — $file"
  echo ""
  grep "^TASK-" "$file" || echo "(none found)"
}

q_open() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# Open Tasks — $file"
  echo ""
  grep "^TASK-.*\[ \]" "$file" || echo "(none — all done or no tasks)"
}

q_done() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# Completed Tasks — $file"
  echo ""
  grep -i "^TASK-.*\[x\]" "$file" || echo "(none completed yet)"
}

q_parallel() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# Parallel Tasks — $file"
  echo ""
  grep "^TASK-.*\[P\]" "$file" || echo "(none found)"
}

q_story() {
  local story="$1" file="$2"
  [[ -f "$file" ]] || die "File not found: $file"
  # Normalize: accept "US1", "us1", "[US1]"
  local tag
  tag=$(echo "$story" | tr '[:lower:]' '[:upper:]' | sed 's/^\[//;s/\]$//')
  echo "# Tasks for $tag — $file"
  echo ""
  grep "^TASK-.*\[$tag\]" "$file" || echo "(none found for $tag)"
}

q_findings() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# All Findings — $file"
  echo ""
  grep "^FINDING-" "$file" || echo "(none found)"
}

q_severity() {
  local severity="$1" file="$2"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# ${severity^} Findings — $file"
  echo ""
  grep -i "^FINDING-.*${severity}" "$file" || echo "(none found)"
}

q_chk() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# Checklist Items — $file"
  echo ""
  grep "^CHK-" "$file" || echo "(none found)"
}

q_open_chk() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# Open Checklist Items — $file"
  echo ""
  grep "^CHK-.*\[ \]" "$file" || echo "(none — all done or no items)"
}

q_done_chk() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  echo "# Completed Checklist Items — $file"
  echo ""
  grep -i "^CHK-.*\[x\]" "$file" || echo "(none completed yet)"
}

q_stats() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file"
  local total open done_count
  total=$(grep -c "^TASK-" "$file" 2>/dev/null || echo 0)
  open=$(grep -c "^TASK-.*\[ \]" "$file" 2>/dev/null || echo 0)
  done_count=$(grep -ci "^TASK-.*\[x\]" "$file" 2>/dev/null || echo 0)

  if [[ "$total" -eq 0 ]]; then
    echo "No TASK-T* entries found in $file"
    exit 0
  fi

  local pct
  pct=$(awk "BEGIN { printf \"%.0f\", ($done_count / $total) * 100 }")

  echo "# Task Stats — $file"
  echo ""
  echo "Total:     $total"
  echo "Done:      $done_count  ($pct%)"
  echo "Open:      $open"
  echo ""
  if [[ "$pct" -ge 100 ]]; then
    echo "Status:    ✅ Complete (100%) — ready for code quality pipeline"
  elif [[ "$pct" -ge 50 ]]; then
    echo "Status:    🔄 In progress ($pct%)"
  else
    echo "Status:    ⏸️  Early stage ($pct%)"
  fi
}

# ── dispatch ─────────────────────────────────────────────────────────────────

[[ -z "$TYPE" ]] && usage

case "$TYPE" in
  fr)
    FILE="${1:-$(resolve_file fr "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No spec.md found. Pass the file path: sk-query.sh fr <file>"
    q_fr "$FILE" ;;

  sc)
    FILE="${1:-$(resolve_file sc "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No spec.md found. Pass the file path: sk-query.sh sc <file>"
    q_sc "$FILE" ;;

  task)
    FILE="${1:-$(resolve_file task "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No tasks.md found. Pass the file path: sk-query.sh task <file>"
    q_task "$FILE" ;;

  open)
    FILE="${1:-$(resolve_file open "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No tasks.md found."
    q_open "$FILE" ;;

  done)
    FILE="${1:-$(resolve_file done "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No tasks.md found."
    q_done "$FILE" ;;

  parallel)
    FILE="${1:-$(resolve_file parallel "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No tasks.md found."
    q_parallel "$FILE" ;;

  story)
    STORY="${1:-}"; shift || true
    [[ -z "$STORY" ]] && die "Usage: sk-query.sh story <US1|US2...> [file]"
    FILE="${1:-$(resolve_file story "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No tasks.md found."
    q_story "$STORY" "$FILE" ;;

  findings)
    FILE="${1:-$(resolve_file findings "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No findings file found. Pass the file path."
    q_findings "$FILE" ;;

  critical|high|medium|low|info)
    FILE="${1:-$(resolve_file findings "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No findings file found. Pass the file path."
    q_severity "$TYPE" "$FILE" ;;

  chk)
    FILE="${1:-}"; shift || true
    [[ -z "$FILE" ]] && die "Usage: sk-query.sh chk <file>"
    q_chk "$FILE" ;;

  open-chk)
    FILE="${1:-}"; shift || true
    [[ -z "$FILE" ]] && die "Usage: sk-query.sh open-chk <file>"
    q_open_chk "$FILE" ;;

  done-chk)
    FILE="${1:-}"; shift || true
    [[ -z "$FILE" ]] && die "Usage: sk-query.sh done-chk <file>"
    q_done_chk "$FILE" ;;

  stats)
    FILE="${1:-$(resolve_file stats "$@")}"; shift || true
    [[ -z "$FILE" ]] && die "No tasks.md found."
    q_stats "$FILE" ;;

  list-types)
    echo "Available types: fr sc task open done parallel story findings critical high medium low info chk open-chk done-chk stats" ;;

  help|--help|-h)
    usage ;;

  *)
    die "Unknown type: $TYPE. Run 'sk-query.sh list-types' for available types." ;;
esac
