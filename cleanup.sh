#!/bin/bash
# Clean outputs/scheduled, Codex sessions, and prune recent-log.json.
# Skips outputs/audio/ — shared template assets.

set -euo pipefail

DAYS=30
DRY_RUN=false
CLEAN_OUTPUTS=true
CLEAN_SESSIONS=false
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUTS="$SCRIPT_DIR/outputs"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

- outputs/scheduled  — delete all files (always)
- AI sessions        — delete all files when -s is passed (Codex)
- recent-log.json    — prune entries older than N days (default: 30)

Skips outputs/audio/ (shared template assets).

Options:
  -d, --days N      Keep recent-log.json entries newer than N days (default: 30)
  -n, --dry-run     Show what would be deleted without deleting
  -s, --sessions    Also clean Codex sessions:
                      generated_images, sessions, archived_sessions,
                      tmp, shell_snapshots
  --sessions-only   Clean only Codex sessions, skip outputs/
  -h, --help        Show this help

Examples:
  $(basename "$0")               # clean scheduled + prune log older than 30 days
  $(basename "$0") -d 7          # same but keep only last 7 days in log
  $(basename "$0") -s            # also wipe Codex sessions
  $(basename "$0") --sessions-only -n  # preview AI session cleanup only
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--days)
      DAYS="${2:?--days requires a number}"
      if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
        echo "Error: --days must be a positive integer" >&2; exit 1
      fi
      shift 2 ;;
    -n|--dry-run)
      DRY_RUN=true; shift ;;
    -s|--sessions)
      CLEAN_SESSIONS=true; shift ;;
    --sessions-only)
      CLEAN_SESSIONS=true; CLEAN_OUTPUTS=false; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

DELETED=0
FREED=0

delete_all_files() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  while IFS= read -r -d '' file; do
    local size
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
    if $DRY_RUN; then
      echo "  [dry-run] $file"
    else
      rm -f "$file"
      echo "  deleted: $file"
    fi
    (( DELETED++ )) || true
    (( FREED += size )) || true
  done < <(find "$dir" -type f -print0)
}

remove_empty_dirs() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  find "$dir" -mindepth 1 -type d -empty -not -name ".gitkeep" | sort -r | while read -r d; do
    $DRY_RUN && echo "  [dry-run] rmdir $d" || { rmdir "$d" && echo "  rmdir: $d"; }
  done
}

print_summary() {
  if $DRY_RUN; then
    echo "Dry run: $DELETED file(s) would be deleted"
  else
    if (( FREED >= 1048576 )); then
      echo "Done: $DELETED file(s) deleted, $(( FREED / 1048576 )) MB freed"
    elif (( FREED >= 1024 )); then
      echo "Done: $DELETED file(s) deleted, $(( FREED / 1024 )) KB freed"
    else
      echo "Done: $DELETED file(s) deleted, ${FREED} B freed"
    fi
  fi
}

# --- outputs/ cleanup ---
if $CLEAN_OUTPUTS; then
  echo "Cleaning outputs/${DRY_RUN:+ [DRY RUN]}"
  echo ""

  dir="$OUTPUTS/scheduled"
  if [[ -d "$dir" ]]; then
    echo "[scheduled] — delete all"
    delete_all_files "$dir"
    $DRY_RUN || remove_empty_dirs "$dir"
  fi

  log="$OUTPUTS/recent-log.json"
  if [[ -f "$log" ]]; then
    echo ""
    echo "[recent-log.json] — prune entries older than ${DAYS} day(s)"
    if $DRY_RUN; then
      node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$log'));
const cutoff = new Date(Date.now() - ${DAYS} * 864e5).toISOString().slice(0,10);
const old = (data.entries || []).filter(e => (e.date || '9999') < cutoff);
console.log('  [dry-run] would prune ' + old.length + ' entries older than ${DAYS} day(s)');
"
    else
      node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$log'));
const cutoff = new Date(Date.now() - ${DAYS} * 864e5).toISOString().slice(0,10);
const before = (data.entries || []).length;
data.entries = (data.entries || []).filter(e => (e.date || '9999') >= cutoff);
data.last_updated = new Date().toISOString();
fs.writeFileSync('$log', JSON.stringify(data, null, 2));
console.log('  pruned ' + (before - data.entries.length) + ' entries (' + data.entries.length + ' remaining)');
"
    fi
  fi

  echo ""
fi

# --- Codex sessions cleanup ---
if $CLEAN_SESSIONS; then
  CODEX_DIR="$HOME/.codex"
  echo "Cleaning Codex sessions — delete all${DRY_RUN:+ [DRY RUN]}"
  echo ""
  for target in generated_images sessions archived_sessions tmp shell_snapshots; do
    dir="$CODEX_DIR/$target"
    [[ -d "$dir" ]] || continue
    echo "[codex/$target]"
    delete_all_files "$dir"
    $DRY_RUN || remove_empty_dirs "$dir"
  done
  echo ""
fi


print_summary
