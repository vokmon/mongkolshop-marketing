# Tracker Agent

## Role
Single interface สำหรับ tracking content ทุกประเภท — file-based ทั้งหมด
แต่ละ agent เรียก tracker-agent เสมอ ไม่จัดการไฟล์ตรงๆ เอง

## Storage

ทุก content เก็บใน `outputs/scheduled/` — ไม่มี external database

```
outputs/scheduled/
├── pending/     ← สร้างแล้ว รอ human approve
├── approved/    ← approve แล้ว รอ schedule ขึ้น Facebook
├── scheduled/   ← ส่ง Facebook API แล้ว รอ publish
└── posted/      ← publish แล้ว — archive (เก็บ 30 วัน)
```

แต่ละ content เป็น folder: `[content_id]/content.json` + รูป/วิดีโอ

## Operations

### saveContent(content)
สร้าง folder ใน `pending/[content_id]/` และบันทึก `content.json`
Return: `content_id`

### updateStatus(content_id, status)
ย้าย folder ระหว่าง pending → approved → scheduled → posted

### updatePaths(content_id, paths)
อัปเดต `image_path`, `image_paths`, `video_path` ใน `content.json`

### get(content_id)
อ่าน `content.json` จาก folder ที่ตรงกัน (scan ทุก status subfolder)

### scan(filters)
อ่าน `content.json` ทุก folder แล้วกรองตาม filters
```json
{ "status": "pending", "date": "2026-04-28" }
{ "days_back": 14, "fields": ["deity", "content_type", "topic"] }
```

### cleanup()
ลบ folder ใน `posted/` ที่ `posted_at` เกิน 30 วัน

## Status Values

| Status | ความหมาย |
|---|---|
| `pending` | รอ human approve |
| `approved` | approve แล้ว รอ schedule |
| `scheduled` | ส่ง Facebook API แล้ว รอ publish |
| `auto_posted` | post ทันที ไม่ผ่าน approve (news) |
| `posted` | publish แล้ว |
| `rejected` | ไม่ใช้ |
| `failed` | ล้มเหลว |

## Content File Format (content.json)

```json
{
  "content_id": "horoscope_daily_20260428",
  "content_type": "horoscope_daily",
  "status": "pending",
  "created_at": "2026-04-28T05:00:00+07:00",
  "posted_at": null,
  "caption": "...",
  "hashtags": [],
  "image_path": "image.png",
  "deity": "พระอังคาร",
  "topic": null
}
```
