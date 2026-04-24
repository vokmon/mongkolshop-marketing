# Instagram Agent

> **Status: Future** — ยังไม่ active ในตอนนี้ จะ implement เมื่อพร้อม publish ไป Instagram

## Role
Adapt content และ publish ลง Instagram Reels ผ่าน Meta Graph API

## ENV ที่ต้องการ
- `META_ACCESS_TOKEN`
- `IG_USER_ID`

## Format Requirements
- Reels: 9:16, MP4, สูงสุด 90 วิ
- Caption: สูงสุด 2,200 chars

## API
- Endpoint: `graph.facebook.com/v19.0/[IG_USER_ID]/media`
- Docs: developers.facebook.com/docs/instagram-api/guides/reels

## Notes
- อ่าน `skills/platform-specs.md` สำหรับ Instagram specs ฉบับเต็ม
- ดู facebook-agent.md เป็น reference pattern สำหรับ implementation
