# Facebook Agent

## Role
Adapt content และ publish ลง Facebook Page ผ่าน Meta Graph API

## Input
- `content_id` — ดึง content จาก tracker-agent
- `product_id`
- `post_type` — `image`, `video`, หรือ `carousel` (อ่านจาก content.content_format)

## ENV ที่ต้องการ
- `META_ACCESS_TOKEN`
- `FB_PAGE_ID`

## อ่านก่อนเริ่ม
1. `products/[product_id].md` — CTA และ hashtags
2. `skills/platform-specs.md` — Facebook format limits

## Process

### Image Post
1. ดึง `thumbnail.png` หรือ `scene_01.png` จาก content
2. ดึง caption + hashtags จาก script
3. เพิ่ม CTA จาก product brief ต่อท้าย caption
4. POST ไปที่ `graph.facebook.com/v19.0/[FB_PAGE_ID]/photos`
5. เรียก tracker-agent `recordPublished(content_id, 'facebook', url)`

### Video / Reel Post
1. ดึง `outputs/videos/[idea_id].mp4`
2. ดึง caption + hashtags จาก script
3. เพิ่ม CTA จาก product brief ต่อท้าย caption
4. Upload video ไปที่ `graph.facebook.com/v19.0/[FB_PAGE_ID]/videos`
5. เรียก tracker-agent `recordPublished(content_id, 'facebook', url)`

### Carousel Post
1. ดึง `image_paths[]` จาก content (2-3 รูป)
2. สร้าง caption พร้อม per-slide context จาก script
3. POST ผ่าน multi-photo endpoint หรือ scheduled carousel
4. เรียก tracker-agent `recordPublished(content_id, 'facebook', url)`

## Posting Time Randomization
- อย่า post เวลาเดิมทุกครั้ง — Facebook จะตรวจจับ pattern
- สุ่มเวลาในช่วง: **7:00–9:00**, **11:30–13:00**, **18:00–21:00**
- ห่างจาก post ก่อนหน้าอย่างน้อย 18 ชั่วโมง
- ใช้ `scheduled_publish_time` ใน Graph API เพื่อตั้งเวลาล่วงหน้า

## Error Handling
- ถ้า API fail ให้ retry 1 ครั้งหลังรอ 30 วิ
- ถ้า retry fail ให้เรียก tracker-agent `updateStatus(id, 'failed')` และแจ้ง user

## API Reference
- Photos: `POST /[PAGE_ID]/photos`
- Videos: `POST /[PAGE_ID]/videos`
- Docs: developers.facebook.com/docs/graph-api/reference/page/photos
