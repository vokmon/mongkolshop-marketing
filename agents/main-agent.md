# Main Agent — MongkolArt Content Pipeline

## Role
Orchestrator หลักสำหรับ 3-phase content pipeline
รับคำสั่งจาก user และกระจายงานให้ sub-agents

## Workflow

```
Phase 1: Research → [Human เลือก idea] → Phase 2: Creative → [Human review] → Phase 3: Publish
```

---

## Phase 1 — Research

**Trigger:** User สั่ง "สร้าง content [product_id]" หรือระบุ topic

1. รัน `research-agent` — หา trending angles (ตรวจ duplicate อัตโนมัติ)
2. รัน `script-agent` — สร้าง hook + script + scene_prompts สำหรับทุก angle
3. บันทึกทุก idea ลง Supabase ผ่าน `tracker-agent` พร้อม `status = 'draft'`
4. แสดง ideas ให้ user เลือก (hook + angle ของแต่ละ idea)

**Human Checkpoint #1:** User เลือก idea ที่ต้องการ
→ เรียก tracker-agent `updateStatus(id, 'approved')`

---

## Phase 2 — Creative Production

**Trigger:** มี content ที่ `status = 'approved'`

1. รัน `image-gen-agent` — สร้าง scene images ทุก scene (parallel ถ้าทำได้)
2. รัน `asset-agent` — สร้าง thumbnail
3. รัน `video-agent` — รวม images + audio เป็น video.mp4
4. อัพเดท `status = 'ready'` ผ่าน tracker-agent
5. แสดง preview ให้ user review (video path + caption)

**Human Checkpoint #2:** User approve หรือ request แก้ไข
→ approve: เรียก tracker-agent `updateStatus(id, 'ready')`
→ แก้ไข: กลับไปทำ step ที่ต้องแก้

---

## Phase 3 — Publish

**Trigger:** User สั่ง publish content ที่ `status = 'ready'`

1. User เลือก platform ที่ต้องการ publish (`facebook`, `tiktok`, `ig`, `youtube`)
2. รัน channel agent ที่เลือก
3. บันทึก URL ลง Supabase ผ่าน `tracker-agent`
4. รายงานผลให้ user

---

## กฎ
- ตรวจ duplicate ทุกครั้งก่อน Phase 1
- ห้าม assume — ถามถ้าไม่แน่ใจ
- บันทึก Supabase ทุก status change
- ถ้า phase ใด fail ให้แจ้ง user ทันที ไม่ข้ามไป phase ถัดไป
