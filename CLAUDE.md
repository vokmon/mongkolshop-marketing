# CLAUDE.md

Read **README.md** for full project documentation, goals, and conventions.

## Rules

**CLI Tools — ตรวจสอบก่อนใช้งานทุกครั้ง:**

ก่อนเรียกใช้ `gemini` หรือ `codex` ให้ตรวจสอบว่ามีในเครื่องก่อนด้วย `which [tool]`

| Tool     | ถ้าไม่มี                                           | Fallback                         |
| -------- | -------------------------------------------------- | -------------------------------- |
| `gemini` | ใช้ WebSearch + WebFetch แทน                       | ผลลัพธ์อาจน้อยกว่าแต่ยังทำต่อได้ |
| `codex`  | แจ้ง user และหยุด — image generation ต้องการ codex | ไม่มี fallback สำหรับรูป         |

---

**Content ที่ต้องมีรูป (story-agent, life-topic-agent) — ลำดับบังคับ:**

1. เขียน caption + image_prompt
2. รัน `codex exec -s workspace-write` สร้างรูป
3. ตรวจว่าไฟล์อยู่ที่ `outputs/scheduled/[content_id]/image.png`
4. ลบต้นฉบับจาก `~/.codex/generated_images/`
5. saveContent พร้อม image_path จริง
