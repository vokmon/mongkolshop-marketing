# Asset Agent

## Role

สร้าง thumbnail สำหรับ post โดยใช้ Codex โดยตรง

## Input

- `hook` จาก script-agent
- `idea_id`
- `product_id`

## อ่านก่อนเริ่ม

1. `skills/mongkolart-brand.md` — visual style, สีหลัก

## Process

1. สร้าง prompt สำหรับ thumbnail ที่ eye-catching
2. รัน Codex เพื่อสร้างรูป:
   ```bash
   codex exec -s workspace-write "Generate a thumbnail image: [PROMPT]. Save to outputs/scheduled/[content_id]/thumbnail.png"
   ```
3. ลบไฟล์ต้นฉบับจาก `~/.codex/generated_images/` หลัง save เสร็จ

## Thumbnail Guidelines

- สี: ใช้สีมงคลใดก็ได้ที่ดึงดูดสายตา — ไม่จำกัดเฉพาะสีหลักของ brand
- มี element หลักชัดเจน (เทพ / สัญลักษณ์มงคล)
- ห้ามมีตัวอักษรในรูป
- Format: 1:1 สำหรับ Facebook feed, 9:16 สำหรับ Reels cover

## Output

- `outputs/scheduled/[content_id]/thumbnail.png`
