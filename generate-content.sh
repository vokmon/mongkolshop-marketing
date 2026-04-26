#!/bin/bash
# Generate, auto-approve, and schedule content for N days starting from a given date.
# Runs cleanup after generation. Default: 7 days starting tomorrow.
#
# Usage:
#   ./generate-content.sh                          # 7 days from tomorrow
#   ./generate-content.sh -d 14                    # 14 days from tomorrow
#   ./generate-content.sh --from 2026-05-01        # 7 days from May 1
#   ./generate-content.sh --from 2026-05-01 -d 3   # 3 days from May 1
#   ./generate-content.sh -d 1 -n                  # dry-run: 1 day, no posting
#   ./generate-content.sh -h                        # show help

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

DAYS=7
FROM_DATE="$(date -v+1d +%Y-%m-%d 2>/dev/null || date -d tomorrow +%Y-%m-%d)"
DRY_RUN=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Generate, auto-approve, and schedule content for N days.
News posts (Slot 2) are excluded — handled by daily cron.
Runs cleanup after generation.

Options:
  -d, --days N          Number of days to generate (default: 7)
  --from YYYY-MM-DD     Start date (default: tomorrow)
  -n, --dry-run         Create content only, skip posting to channels
  -h, --help            Show this help

Examples:
  $(basename "$0")                          # 7 days from tomorrow
  $(basename "$0") -d 14                    # 14 days from tomorrow
  $(basename "$0") --from 2026-05-01        # 7 days from May 1
  $(basename "$0") --from 2026-05-01 -d 3  # 3 days from May 1
  $(basename "$0") -d 1 -n                  # dry-run: 1 day, no posting
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
    --from)
      FROM_DATE="${2:?--from requires a date (YYYY-MM-DD)}"
      if ! [[ "$FROM_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error: --from must be in YYYY-MM-DD format" >&2; exit 1
      fi
      shift 2 ;;
    -n|--dry-run)
      DRY_RUN=true; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

# Load env vars
if [ -f .env ]; then
  set -a; source .env; set +a
fi

echo "=== MongkolShop Content Generation ==="
echo "Period : $FROM_DATE (+${DAYS} days)"
$DRY_RUN && echo "Mode   : dry-run (no posting)"
echo ""

run_claude() {
  local prompt="$1"
  local tmp
  tmp=$(mktemp)

  claude --dangerously-skip-permissions -p "$prompt" >"$tmp" 2>&1 &
  local pid=$!
  local start
  start=$(date +%s)

  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$(( $(date +%s) - start ))
    printf "\r  Working... %ds" "$elapsed"
    sleep 3
  done
  wait "$pid"
  local exit_code=$?
  printf "\r                    \r"

  cat "$tmp"
  rm -f "$tmp"
  return $exit_code
}

if $DRY_RUN; then
  run_claude "
1. สร้าง editorial content ครบทุก slot (ยกเว้น Slot 2 ข่าว) สำหรับ ${DAYS} วัน เริ่มจาก ${FROM_DATE}
   อ่าน skills/content-schedule.md
2. เรียก tracker-agent updateStatus ทุก content ที่เพิ่งสร้างเป็น 'approved'
"
else
  run_claude "
1. สร้าง editorial content ครบทุก slot (ยกเว้น Slot 2 ข่าว) สำหรับ ${DAYS} วัน เริ่มจาก ${FROM_DATE}
   อ่าน skills/content-schedule.md
2. เรียก tracker-agent updateStatus ทุก content ที่เพิ่งสร้างเป็น 'approved'
3. ส่งทั้งหมดให้ agents/channels/post-agent.md จัดการ
"
fi

echo ""
echo "=== Generation complete ==="
echo ""

# --- Cleanup old outputs + Codex sessions ---
echo "Running cleanup..."
bash "$PROJECT_DIR/cleanup.sh" --sessions
echo ""
echo "Done."
