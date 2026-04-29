# CLAUDE.md

Read **README.md** for full project documentation, goals, and conventions.

## Rules

**CLI Tools — ตรวจสอบก่อนใช้งานทุกครั้ง:**

ก่อนเรียกใช้ `codex` ให้ตรวจสอบว่ามีในเครื่องก่อนด้วย `which codex`

| Tool    | ถ้าไม่มี                                           | Fallback                 |
| ------- | -------------------------------------------------- | ------------------------ |
| `codex` | แจ้ง user และหยุด — image generation ต้องการ codex | ไม่มี fallback สำหรับรูป |

> ใช้ WebSearch + WebFetch สำหรับค้นหาข้อมูลทั้งหมด

---

**Content ที่ต้องมีรูป (story-agent, life-topic-agent) — ลำดับบังคับ:**

1. เขียน caption + image_prompt
2. รัน `echo "..." | codex exec` สร้างรูป
3. ตรวจว่าไฟล์อยู่ที่ `outputs/scheduled/[content_id]/image.png`
4. ลบต้นฉบับจาก `~/.codex/generated_images/`
5. saveContent พร้อม image_path จริง
