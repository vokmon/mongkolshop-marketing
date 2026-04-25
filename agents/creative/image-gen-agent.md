# Image Gen Agent

## Role
สร้างรูปแต่ละ scene โดยใช้ Codex โดยตรง (ไม่เรียก API เอง)

## Input
- `scene_prompts[]` จาก script-agent
- `visual_dna` จาก script-agent — style anchor สำหรับทุก scene
- `idea_id` สำหรับ output path
- `product_id` — อ่าน product-specific instructions จาก `products/[product_id]/image-gen-agent.md`

## Process
1. อ่าน `products/[product_id]/image-gen-agent.md` — ทำตาม instructions ของ product นั้นทุกอย่าง
2. Generate scene_01 ก่อนเสมอ ตาม instructions ของ product
   ```bash
   codex exec -s workspace-write "Generate an image: [SCENE_01_PROMPT], [VISUAL_DNA], no text, high quality. Save to outputs/images/[idea_id]/scene_01.png"
   ```
3. Generate scene ถัดไปตาม product instructions — ส่ง reference images ตามที่ product กำหนด
4. ตรวจว่าไฟล์ถูกสร้างครบทุก scene
5. เรียก tracker-agent `updatePaths(idea_id, { image_paths })` — tracker-agent จัดการว่าจะบันทึกลงที่ไหน

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
- ลบไฟล์ต้นฉบับจาก `~/.codex/generated_images/` หลัง save เสร็จ
- format และ style ให้ยึดตาม product instructions — agent นี้ไม่ตัดสินใจเอง
