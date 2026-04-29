# Tracker Agent

## Role
Single interface สำหรับ tracking content ทุกประเภท — file-based ทั้งหมด
แต่ละ agent เรียก tracker-agent เสมอ ไม่จัดการไฟล์ตรงๆ เอง

## Storage

ทุก content เก็บใน `outputs/scheduled/[content_id]/` — ไม่มี external database
status ติดตามใน `content.json` ของแต่ละ content — ไม่ใช้ subfolder

```
outputs/scheduled/
└── [content_id]/
    ├── content.json    ← metadata + status
    ├── image.png       ← image post (ถ้ามี)
    ├── video.mp4       ← video post (ถ้ามี)
    └── scenes/         ← video scene images (ถ้ามี)

outputs/recent-log.json ← compact index สำหรับ dedup (auto-maintained)
```

### recent-log.json

ไฟล์ compact ที่เก็บเฉพาะ field ที่ใช้ตรวจ duplicate — อ่านไฟล์เดียวแทนการ scan ทุก folder

```json
{
  "last_updated": "2026-04-29T07:00:00+07:00",
  "note": "auto-maintained by tracker-agent on every saveContent() — last 30 days only",
  "entries": [
    {
      "content_id": "life_wealth_20260429",
      "content_type": "life_topic",
      "date": "2026-04-29",
      "topic_type": "wealth",
      "deity": "พระแม่ลักษมี"
    }
  ]
}
```

Fields ที่เขียนต่อ entry (เฉพาะที่มีค่า — ข้ามถ้า null/empty):

| content_type | fields |
|---|---|
| `life_topic` | `content_id`, `content_type`, `date`, `topic_type`, `deity` |
| story variants (`deity_*`, `legend`, `jataka`, `amulet`, `astrology_science`, `festival`, `occult`) | `content_id`, `content_type`, `date`, `topic`, `deity` |
| `product` | `content_id`, `content_type`, `date`, `deity`, `topic`, `angle`, `content_format`, `visual_style` |
| `horoscope_daily`, `news` | ไม่เขียน — ไม่มี dedup |

## Operations

### saveContent(content)
สร้าง folder `outputs/scheduled/[content_id]/` และบันทึก `content.json`
ตั้ง `created_at` เป็น current datetime (ISO 8601, +07:00) อัตโนมัติ — ไม่ต้องรับจาก caller
Return: `content_id`

หลัง saveContent() สำเร็จ — อัปเดต `outputs/recent-log.json` อัตโนมัติ:
1. อ่านไฟล์ปัจจุบัน (สร้างใหม่ถ้ายังไม่มี)
2. เพิ่ม entry ใหม่ตาม field mapping ในตาราง Storage ด้านบน — **ข้าม content_type ต่อไปนี้:**
   - `horoscope_daily`
   - `news`
3. ลบ entries ที่ `date` เก่ากว่า 30 วัน
4. อัปเดต `last_updated` เป็น current datetime
5. เขียนกลับ

### updateStatus(content_id, status)
อัปเดต field `status` ใน `content.json` — ไม่ย้าย folder

### updateChannelStatus(content_id, channel, status)
อัปเดต `channel_status.[channel]` ใน `content.json`
ถ้าทุก channel ใน `channel_status` เป็น `posted` แล้ว → อัปเดต overall `status` เป็น `posted` อัตโนมัติ

### updatePaths(content_id, paths)
อัปเดต `image_path`, `image_paths`, `video_path` ใน `content.json`

### get(content_id)
อ่าน `outputs/scheduled/[content_id]/content.json`

### scan(filters)
อ่าน `content.json` ทุก folder ใน `outputs/scheduled/` แล้วกรองตาม filters
```json
{ "status": "pending", "date": "2026-04-28" }
{ "channel_status": { "facebook": "pending" } }
{ "days_back": 14, "fields": ["deity", "content_type", "topic"] }
```

## Status Values

| Status | ความหมาย |
|---|---|
| `pending` | สร้างแล้ว รอ human approve (manual pipeline) |
| `approved` | พร้อม schedule — ผ่าน auto-approve (automated flow) หรือ human approve (manual pipeline) แล้ว |
| `scheduled` | ส่งทุก channel แล้ว รอ publish |
| `auto_posted` | post ทันที ไม่ผ่าน schedule (news) |
| `posted` | publish แล้ว |
| `failed` | ล้มเหลว |

## Content File Format (content.json)

```json
{
  "content_id": "horoscope_daily_20260428",
  "content_type": "horoscope_daily",
  "status": "approved",
  "channel_status": {
    "facebook": "pending"
  },
  "created_at": "2026-04-28T05:00:00+07:00",
  "scheduled_publish_time": 1746342000,
  "posted_at": null,
  "caption": "...",
  "hashtags": [],
  "image_path": "image.png",
  "deity": "พระอังคาร",
  "topic": null
}
```
