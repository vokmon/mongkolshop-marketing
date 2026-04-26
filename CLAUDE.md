# CLAUDE.md

Read **README.md** for full project documentation, goals, and conventions.

## Rules

**Content ที่ต้องมีรูป (story-agent, life-topic-agent) — ลำดับบังคับ:**
1. เขียน caption + image_prompt
2. รัน `codex exec -s workspace-write` สร้างรูป
3. ตรวจว่าไฟล์อยู่ที่ `outputs/scheduled/[content_id]/image.png`
4. ลบต้นฉบับจาก `~/.codex/generated_images/`
5. saveContent พร้อม image_path จริง

**ห้าม saveContent() ด้วย image_path ว่าง — งานยังไม่เสร็จถ้าไม่มีรูป**
