# Main Agent — Product Content Pipeline

## Role
Orchestrator สำหรับ product post pipeline (image/video sale posts)
รับคำสั่งจาก user และกระจายงานให้ sub-agents

> Pipeline นี้ใช้สำหรับ **product posts เท่านั้น**
> Editorial content (horoscope, story ฯลฯ) ใช้ generate-content.sh แทน

## Workflow

```
Phase 1: Research → [Human เลือก idea] → Phase 2: Creative → [Human review] → Phase 3: Publish
```

---

## Phase 1 — Research

**Trigger:** User สั่ง "สร้าง content [product_id]" หรือระบุ topic

1. รัน `agents/product/research-agent` — หา trending angles
2. แสดง angles ให้ user เลือก (topic + angle ของแต่ละ idea)

**Human Checkpoint #1:** User เลือก angle ที่ต้องการ

---

## Phase 2 — Creative Production

**Trigger:** User เลือก angle แล้ว

1. รัน `agents/product/script-agent` สำหรับ angle ที่เลือก — สร้าง hook, script, caption, scene_prompts และ generate รูป/video
   - script-agent บันทึก content.json ด้วย `status: 'pending'` และเรียก tracker-agent `saveContent()` เอง
2. แสดง preview ให้ user review (image/video path + caption)

**Human Checkpoint #2:** User approve หรือ request แก้ไข
→ approve: เรียก tracker-agent `updateStatus(id, 'approved')`
→ แก้ไข: กลับไปทำ step ที่ต้องแก้

---

## Phase 3 — Publish

**Trigger:** User approve content จาก Phase 2

1. เรียก `agents/channels/post-agent` — จัดการ channel_status และ schedule ทุก channel
2. รายงานผลให้ user (เวลาที่จะ publish ต่อ channel)

---

## กฎ
- ทุก status change ผ่าน tracker-agent เสมอ
- ตรวจ duplicate ก่อน Phase 1 ผ่าน tracker-agent `scan()`
- ห้าม assume — ถามถ้าไม่แน่ใจ
- ถ้า phase ใด fail ให้แจ้ง user ทันที ไม่ข้ามไป phase ถัดไป
