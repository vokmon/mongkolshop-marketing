# Platform Specs

Reference สำหรับ channel agents — ข้อจำกัดและ format ของแต่ละ platform

## Facebook (active)

### Image Post
- Ratio: 1:1 (1080x1080) หรือ 4:5 (1080x1350)
- Format: JPG, PNG
- Caption: สูงสุด 63,206 chars (ใช้จริงไม่เกิน 300)
- Hashtags: ไม่มีผลต่อ reach บน Facebook มากนัก — ใช้ 3-5 อัน

### Video / Reel
- Ratio: 9:16 (1080x1920)
- Duration: 3 วิ – 90 วิ (Reels), สูงสุด 240 นาที (feed video)
- Format: MP4, MOV
- Max size: 4GB
- Caption: สูงสุด 2,200 chars

### API
- Graph API v19.0+
- ENV: `META_ACCESS_TOKEN`, `FB_PAGE_ID`

---

## TikTok (future)

### Video
- Ratio: 9:16 (1080x1920)
- Duration: 3 วิ – 10 นาที
- Format: MP4, MOV
- Max size: 287.6MB
- Caption: สูงสุด 2,200 chars + hashtags

### API
- Content Posting API v2
- ENV: `TIKTOK_CLIENT_KEY`, `TIKTOK_CLIENT_SECRET`, `TIKTOK_ACCESS_TOKEN`

---

## Instagram (future)

### Reels
- Ratio: 9:16 (1080x1920)
- Duration: 3 วิ – 90 วิ
- Format: MP4
- Caption: สูงสุด 2,200 chars

### API
- Meta Graph API v19.0+
- ENV: `META_ACCESS_TOKEN`, `IG_USER_ID`

---

## YouTube Shorts (future)

### Video
- Ratio: 9:16 (1080x1920)
- Duration: สูงสุด 60 วิ
- Format: MP4
- Title: สูงสุด 100 chars — ต้องมี `#Shorts`

### API
- YouTube Data API v3
- ENV: `YOUTUBE_API_KEY`, `YOUTUBE_CLIENT_ID`, `YOUTUBE_CLIENT_SECRET`, `YOUTUBE_REFRESH_TOKEN`
