#!/bin/bash
# MongkolShop Content Pipeline Setup
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "=== MongkolShop Setup ==="

# 1. ตรวจสอบ .env
if [ ! -f .env ]; then
  echo ""
  echo "Error: ไม่พบ .env — สร้างก่อนด้วยคำสั่ง:"
  echo ""
  echo "  cat > .env << 'EOF'"
  echo "  FB_PAGE_ID=your_page_id"
  echo "  FB_ACCESS_TOKEN=your_long_lived_token"
  echo "  EOF"
  echo ""
  exit 1
fi

# 2. อ่าน .env
set -a
source .env
set +a

if [ -z "$FB_PAGE_ID" ] || [ -z "$FB_ACCESS_TOKEN" ]; then
  echo "Error: .env ต้องมี FB_PAGE_ID และ FB_ACCESS_TOKEN"
  exit 1
fi

# 3. เขียน env vars ลง .claude/settings.local.json
mkdir -p .claude
cat > .claude/settings.local.json << EOF
{
  "env": {
    "FB_PAGE_ID": "$FB_PAGE_ID",
    "FB_ACCESS_TOKEN": "$FB_ACCESS_TOKEN"
  }
}
EOF
echo "✓ ENV vars บันทึกลง .claude/settings.local.json"

# 4. เพิ่ม settings.local.json ใน .gitignore
if ! grep -qF ".claude/settings.local.json" .gitignore 2>/dev/null; then
  echo ".claude/settings.local.json" >> .gitignore
  echo "✓ เพิ่ม .claude/settings.local.json ใน .gitignore"
fi

# 5. ตั้ง cron — news-agent รายวัน 8:30 ICT (เดียวที่ต้องการ)
echo ""
echo "ขั้นตอนต่อไป — ตั้ง cron สำหรับ news-agent:"
echo ""
echo "เปิด Claude Code แล้วพิมพ์:"
echo ""
echo "  ตั้ง cron รัน news-agent ทุกวัน 08:30 ICT"
echo "  อ่าน agents/content/news-agent.md"
echo ""
echo "────────────────────────────────────────────"
echo ""
echo "การรัน content generation (สัปดาห์ละครั้ง):"
echo ""
echo "  ./generate-content.sh              # 7 วัน เริ่มพรุ่งนี้"
echo "  ./generate-content.sh -d 14        # 14 วัน"
echo "  ./generate-content.sh --from DATE  # กำหนดวันเริ่มต้น"
echo ""
echo "✓ Setup เสร็จแล้ว"
