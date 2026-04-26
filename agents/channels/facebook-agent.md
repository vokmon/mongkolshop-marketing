# Facebook Agent

## Role
รับ content จาก post-agent แล้ว schedule ขึ้น Facebook Page ผ่าน Graph API
Facebook จะ publish เองอัตโนมัติตามเวลาที่กำหนด — ไม่ต้องมีคนกด publish

## ENV ที่ต้องการ
- `FB_ACCESS_TOKEN` — Page Access Token (long-lived ~60 วัน)
- `FB_PAGE_ID`

## Input
```json
{
  "content_id": "...",
  "pipeline": "editorial",
  "format": "image",
  "caption": "...",
  "hashtags": [],
  "image_path": "outputs/scheduled/[content_id]/image.png",
  "scheduled_publish_time": 1746342000
}
```

`scheduled_publish_time` — Unix timestamp ของเวลาที่ต้องการโพส (กำหนดโดย content agents ตอนสร้าง)
ต้องอยู่ระหว่าง **10 นาที ถึง 75 วัน** ในอนาคต

## Process

1. เรียก tracker-agent `scan({ channel_status: { facebook: 'pending' } })` → ดู content ที่รอ schedule ลง Facebook
2. อ่าน `scheduled_publish_time` จาก `content.json` ของแต่ละ content

### Image Post
1. Upload รูปไปที่ Graph API (unpublished)
2. Schedule post:
```
POST /{FB_PAGE_ID}/photos
{
  "published": false,
  "scheduled_publish_time": [unix_timestamp],
  "message": "[caption]\n[hashtags]",
  "url": "[image_url]"
}
```
3. เรียก tracker-agent `updateChannelStatus(content_id, 'facebook', 'scheduled')` พร้อม `fb_post_id`

### Video Post
1. Upload video ผ่าน resumable upload API ก่อน (ได้ `video_id`)
2. Schedule post:
```
POST /{FB_PAGE_ID}/videos
{
  "published": false,
  "scheduled_publish_time": [unix_timestamp],
  "description": "[caption]\n[hashtags]",
  "video_id": "[video_id]"
}
```
3. เรียก tracker-agent `updateChannelStatus(content_id, 'facebook', 'scheduled')` พร้อม `fb_post_id`

### Immediate Post (news, festival วันนี้)
เหมือนกันทุกอย่าง แต่ใช้ `"published": true` และไม่ต้องใส่ `scheduled_publish_time`
หลัง post สำเร็จ → เรียก tracker-agent `updateChannelStatus(content_id, 'facebook', 'posted')`

## Error Handling
- ถ้า API fail → retry 1 ครั้งหลังรอ 30 วิ
- ถ้า retry fail → เรียก tracker-agent `updateStatus(content_id, 'failed')` และแจ้ง user

## Status หลัง Schedule สำเร็จ
`scheduled` — post อยู่ใน Facebook queue รอ publish ตามเวลา
ดู/แก้ไข scheduled posts ได้ที่ Meta Business Suite

## API Reference
- Photos: `POST /{page-id}/photos`
- Videos: `POST /{page-id}/videos`
- Resumable upload: `POST /{page-id}/videos` (chunked)
