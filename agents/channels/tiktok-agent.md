# TikTok Agent

> **Status: Future** — ยังไม่ active ในตอนนี้ จะ implement เมื่อพร้อม publish ไป TikTok

## Role
Adapt content และ publish ลง TikTok ผ่าน Content Posting API

## ENV ที่ต้องการ
- `TIKTOK_CLIENT_KEY`
- `TIKTOK_CLIENT_SECRET`
- `TIKTOK_ACCESS_TOKEN`

## Format Requirements
- Video: 9:16, MP4, สูงสุด 287.6MB, 3 วิ – 10 นาที
- Caption: สูงสุด 2,200 chars

## API
- Endpoint: `https://open.tiktokapis.com/v2/post/publish/video/init/`
- Docs: developers.tiktok.com/doc/content-posting-api-get-started

## Notes
- อ่าน `skills/platform-specs.md` สำหรับ TikTok specs ฉบับเต็ม
- ดู facebook-agent.md เป็น reference pattern สำหรับ implementation
