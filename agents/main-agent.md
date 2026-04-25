# Main Agent — Product Content Pipeline

## Role
Orchestrator สำหรับ product post pipeline (image/video sale posts)
รับคำสั่งจาก user และกระจายงานให้ sub-agents

> Pipeline นี้ใช้สำหรับ **product posts เท่านั้น**
> Editorial content (horoscope, story ฯลฯ) ใช้ post-agent แทน

## Workflow

```
Phase 1: Research → [Human เลือก idea] → Phase 2: Creative → [Human review] → Phase 3: Publish
```

---

## Phase 1 — Research

**Trigger:** User สั่ง "สร้าง content [product_id]" หรือระบุ topic

1. รัน `agents/product/research-agent` — หา trending angles
2. รัน `agents/product/script-agent` — สร้าง hook + script + scene_prompts สำหรับทุก angle
3. เรียก tracker-agent `saveContent(content)` สำหรับทุก idea
4. แสดง ideas ให้ user เลือก (hook + angle ของแต่ละ idea)

**Human Checkpoint #1:** User เลือก idea ที่ต้องการ
→ เรียก tracker-agent `updateStatus(id, 'approved')`

---

## Phase 2 — Creative Production

**Trigger:** มี content ที่ `status = 'approved'`

1. รัน `image-gen-agent` — สร้าง scene images (parallel ถ้าทำได้)
2. รัน `asset-agent` — สร้าง thumbnail
3. รัน `video-agent` — รวม images + audio เป็น video.mp4
4. เรียก tracker-agent `updatePaths(id, paths)` และ `updateStatus(id, 'pending')`
5. แสดง preview ให้ user review (video path + caption)

**Human Checkpoint #2:** User approve หรือ request แก้ไข
→ approve: เรียก tracker-agent `updateStatus(id, 'approved')`
→ แก้ไข: กลับไปทำ step ที่ต้องแก้

---

## Phase 3 — Publish

**Trigger:** User approve content จาก Phase 2

1. เรียก `facebook-agent` — schedule post ขึ้น Facebook API
2. เรียก tracker-agent `updateStatus(id, 'scheduled')`
3. รายงาน fb_post_id และเวลาที่จะ publish ให้ user

---

## กฎ
- ทุก status change ผ่าน tracker-agent เสมอ
- ตรวจ duplicate ก่อน Phase 1 ผ่าน tracker-agent `scan()`
- ห้าม assume — ถามถ้าไม่แน่ใจ
- ถ้า phase ใด fail ให้แจ้ง user ทันที ไม่ข้ามไป phase ถัดไป
