# YouTube Agent

> **Status: Future** — ยังไม่ active ในตอนนี้ จะ implement เมื่อพร้อม publish ไป YouTube

## Role
Adapt content และ publish ลง YouTube Shorts ผ่าน YouTube Data API v3

## ENV ที่ต้องการ
- `YOUTUBE_API_KEY`
- `YOUTUBE_CLIENT_ID`
- `YOUTUBE_CLIENT_SECRET`
- `YOUTUBE_REFRESH_TOKEN`

## Format Requirements
- Shorts: 9:16, MP4, สูงสุด 60 วิ
- Title: สูงสุด 100 chars — ต้องมี `#Shorts`

## API
- Endpoint: `www.googleapis.com/upload/youtube/v3/videos`
- Docs: developers.google.com/youtube/v3/guides/uploading_a_video

## Notes
- อ่าน `skills/platform-specs.md` สำหรับ YouTube specs ฉบับเต็ม
- ดู facebook-agent.md เป็น reference pattern สำหรับ implementation
