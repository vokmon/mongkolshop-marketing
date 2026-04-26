#!/bin/bash
# Delete old files in outputs/ and Codex temp sessions.
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

Delete files older than N days from outputs/ and optionally Codex temp sessions.
Skips outputs/audio/ (shared template assets).

Options:
  -d, --days N      Delete files older than N days (default: 30)
  -n, --dry-run     Show what would be deleted without deleting
  -s, --sessions    Also clean Codex temp sessions/images (generated_images,
                    sessions, archived_sessions, tmp, shell_snapshots)
  --sessions-only   Clean only Codex sessions, skip outputs/
  -h, --help        Show this help

Examples:
  $(basename "$0")                    # clean outputs/ older than 30 days
  $(basename "$0") -d 7               # clean outputs/ older than 7 days
  $(basename "$0") -s                 # clean outputs/ + Codex sessions
  $(basename "$0") --sessions-only    # clean only Codex sessions
  $(basename "$0") -d 7 -s -n        # preview both cleanups
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

delete_old_files() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  local find_args=(-type f)
  (( DAYS > 0 )) && find_args+=(-mtime +"$DAYS")

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
  done < <(find "$dir" "${find_args[@]}" -print0)
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
  echo "Cleaning outputs/ — files older than ${DAYS} day(s)${DRY_RUN:+ [DRY RUN]}"
  echo ""
  dir="$OUTPUTS/scheduled"
  if [[ -d "$dir" ]]; then
    echo "[scheduled]"
    delete_old_files "$dir"
    $DRY_RUN || remove_empty_dirs "$dir"
  fi
  echo ""
fi

# --- Codex sessions cleanup ---
if $CLEAN_SESSIONS; then
  CODEX_DIR="$HOME/.codex"
  echo "Cleaning Codex sessions — files older than ${DAYS} day(s)${DRY_RUN:+ [DRY RUN]}"
  echo ""
  for target in generated_images sessions archived_sessions tmp shell_snapshots; do
    dir="$CODEX_DIR/$target"
    [[ -d "$dir" ]] || continue
    echo "[codex/$target]"
    delete_old_files "$dir"
    $DRY_RUN || remove_empty_dirs "$dir"
  done
  echo ""
fi

print_summary
