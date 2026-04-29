# Batch Editorial — MongkolArt

Orchestrator สำหรับสร้าง editorial content หลายวัน — โหลด context ครั้งเดียว, parallel image gen

## Input

```
FROM_DATE = DD/MM/YYYY
DAYS = N
```

---

## Phase 0 — Preload (ครั้งเดียว ก่อนทุกอย่าง)

อ่านไฟล์ทั้งหมดพร้อมกันในคราวเดียว:

- `config.md`
- `skills/mongkolart-brand.md`
- `skills/content-schedule.md`
- `products/mongkol_art/brief.md`
- `agents/content/horoscope-agent.md`
- `agents/content/story-agent.md`
- `agents/content/life-topic-agent.md`
- `agents/creative/image-gen-agent.md`
- `agents/utils/tracker-agent.md`

จากนั้นอ่าน `outputs/recent-log.json` ครั้งเดียว — ใช้แทน scan() ทั้งหมด
ผลลัพธ์นี้ใช้ตลอด run สำหรับตรวจ duplicate ใน Phase 1

> ไฟล์ทั้งหมดในรายการนี้โหลดแล้ว — section "อ่านก่อนเริ่ม" ของทุก agent ใน Phase 2 ไม่ต้องทำซ้ำ

---

## Phase 1 — Plan

คำนวณทุกวันพร้อมกันด้วย python3 — ห้าม assume วันในสัปดาห์:

```bash
python3 -c "
import datetime
tz = datetime.timezone(datetime.timedelta(hours=7))
from_date = datetime.date(YYYY, M, D)
for i in range(DAYS):
    d = from_date + datetime.timedelta(days=i)
    print(d, d.strftime('%A'),
        int(datetime.datetime(d.year,d.month,d.day,7,0,tzinfo=tz).timestamp()),
        int(datetime.datetime(d.year,d.month,d.day,12,0,tzinfo=tz).timestamp()),
        int(datetime.datetime(d.year,d.month,d.day,19,0,tzinfo=tz).timestamp()))
"
```

ผลลัพธ์ = ตาราง plan ครบทุก content_id, topic, timestamp — ใช้ตลอด run

วาง plan โดยใช้ข้อมูลจาก `recent-log.json` (Phase 0) เพื่อหลีกเลี่ยง:
- `life_topic` ที่มี `topic_type` เดิมซ้ำใน 7 วัน
- story variants ที่มี `deity` + `content_type` เดิมซ้ำใน 14 วัน
- `deity` เดิมปรากฏมากกว่า 2 ครั้งใน 7 วัน (ทุก content_type รวมกัน)

---

## Phase 2 — Write All Captions

เขียน caption + image_prompt ทุกชิ้นต่อเนื่องกัน **ยังไม่ gen รูป**

ใช้ agent ตาม slot ที่ระบุใน `content-schedule.md` — ทำตาม Process ของแต่ละ agent (อ่านแล้วใน Phase 0) **เฉพาะขั้นตอนเขียน caption + image_prompt เท่านั้น ข้าม image gen และ saveContent**

---

## Phase 3 — Generate Images (Parallel)

รัน codex ตาม format ใน `image-gen-agent.md` — แบ่งเป็นชุดๆ ละไม่เกิน 4 parallel เพื่อหลีกเลี่ยง rate limit:

```bash
# ชุดที่ 1 (สูงสุด 4)
codex exec -s workspace-write "..." &
codex exec -s workspace-write "..." &
codex exec -s workspace-write "..." &
codex exec -s workspace-write "..." &
wait

# ชุดที่ 2 (ถ้ามี)
codex exec -s workspace-write "..." &
...
wait
```

หลังทุก `wait` — ตรวจทุก image_path ว่ามีไฟล์จริง ถ้าไม่มี gen ใหม่ทีละภาพก่อนไปต่อ
เมื่อสร้างรูปแล้วให้ update image_path ให้ถูกต้อง

---
