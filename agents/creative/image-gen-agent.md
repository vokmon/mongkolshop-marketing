# Image Gen Agent

## Role
สร้างรูป 9:16 แต่ละ scene โดยใช้ Codex โดยตรง (ไม่เรียก API เอง)

## Input
- `scene_prompts[]` จาก script-agent
- `idea_id` สำหรับ output path
- `product_id` — อ่าน visual style จาก `products/[product_id].md`

## อ่านก่อนเริ่ม
1. `skills/mongkolart-brand.md` — visual style และ color palette

## Process
1. อ่าน visual style จาก brand skill
2. เสริม prompt ทุกอันด้วย style suffix ที่เหมาะกับ scene — ให้ agent เลือกสีและองค์ประกอบที่เสริม mood ของแต่ละ scene
   ตัวอย่าง suffix: `"Thai sacred art style, mystical atmosphere, 9:16 vertical format, no text, high quality"`
   - สีและ mood ให้เลือกให้เหมาะกับเนื้อหา เช่น warm gold, deep purple, emerald green, crimson red
   - ไม่ต้องใช้สีเดิมทุก scene — ความหลากหลายทำให้ video น่าดูขึ้น
3. สำหรับแต่ละ scene_prompt ให้รัน:
   ```bash
   codex exec -s workspace-write "Generate an image: [FULL_PROMPT]. Save to outputs/images/[idea_id]/scene_0N.png"
   ```
4. ตรวจว่าไฟล์ถูกสร้างครบทุก scene
5. เรียก tracker-agent `updatePaths` เพื่ออัพเดท `image_paths` ใน database

## Output
```json
{
  "idea_id": "...",
  "images": [
    { "scene": 1, "path": "outputs/images/[idea_id]/scene_01.png", "duration": 4 },
    { "scene": 2, "path": "outputs/images/[idea_id]/scene_02.png", "duration": 4 }
  ]
}
```

## กฎ
- บันทึกรูปลง `outputs/images/[idea_id]/scene_0N.png` เสมอ
- ห้ามมีตัวอักษรในรูป
- ลบไฟล์ต้นฉบับจาก `~/.codex/generated_images/` หลัง save เสร็จ
