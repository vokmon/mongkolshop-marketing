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
```

## Operations

### saveContent(content)
สร้าง folder `outputs/scheduled/[content_id]/` และบันทึก `content.json`
Return: `content_id`

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
