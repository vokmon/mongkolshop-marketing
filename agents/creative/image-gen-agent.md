# Image Gen Agent

## Role
สร้างรูปโดยใช้ Codex โดยตรง (ไม่เรียก API เอง) — รองรับสอง mode

## Mode

### Single Image (editorial content)
Input จาก story-agent, life-topic-agent:
- `image_prompt` — prompt สำหรับรูปเดียว
- `content_id`

### Multi-scene (product content)
Input จาก script-agent:
- `scene_prompts[]` — prompts ทีละ scene
- `visual_dna` — style anchor สำหรับทุก scene
- `content_id`
- `product_id` — อ่าน product-specific instructions จาก `products/[product_id]/image-gen-agent.md`

---

## Process — Single Image

0. ตรวจสอบว่ามี codex ในเครื่องก่อน:
   ```bash
   which codex
   ```
   ถ้าไม่มี — หยุดทันที แจ้ง user ว่า "image generation ต้องการ codex — ไม่สามารถสร้างรูปได้" อย่า saveContent() ด้วย image_path ว่าง

1. Generate รูปด้วย Codex:
   ```bash
   echo "Generate an image: [image_prompt], 4:5 aspect ratio 1080x1350px, no text, high quality. Save to outputs/scheduled/[content_id]/image.png" | codex exec
   ```
   ก่อนรัน — ถ้า `image_prompt` มีคนหรือฉากชีวิต แต่ยังไม่มี ethnic/location marker ให้ inject เพิ่มก่อนส่ง codex:
   - เพิ่ม `Southeast Asian [man/woman]` ถ้า prompt มีคนแต่ไม่ระบุ ethnicity
   - เพิ่ม `contemporary Thailand setting` ถ้า prompt มี scene ในเมือง/บ้าน แต่ไม่ระบุ location
2. ตรวจว่าไฟล์ถูกสร้างที่ `outputs/scheduled/[content_id]/image.png`
3. ลบไฟล์ต้นฉบับจาก `~/.codex/generated_images/`
4. คืน path กลับให้ agent ที่เรียก เพื่อ update `image_path` ใน content.json

---

## Process — Multi-scene

1. อ่าน `products/[product_id]/image-gen-agent.md` — ทำตาม instructions ของ product นั้นทุกอย่าง
2. Generate scene_01 ก่อนเสมอ:
   ```bash
   echo "Generate an image: [SCENE_01_PROMPT], [VISUAL_DNA], no text, high quality. Save to outputs/scheduled/[content_id]/scenes/scene_01.png" | codex exec
   ```
3. Generate scene ถัดไปตาม product instructions — ส่ง reference images ตามที่ product กำหนด
4. ตรวจว่าไฟล์ถูกสร้างครบทุก scene
5. ลบไฟล์ต้นฉบับจาก `~/.codex/generated_images/`
6. เรียก tracker-agent `updatePaths(content_id, { image_paths })`

---

## กฎ

**ทุก asset อยู่ใน `outputs/scheduled/[content_id]/` เสมอ:**
- **Image post** → `outputs/scheduled/[content_id]/image.png`
- **Video scenes** → `outputs/scheduled/[content_id]/scenes/scene_0N.png`
- **Final video** → `outputs/scheduled/[content_id]/video.mp4`

- ลบไฟล์ต้นฉบับจาก `~/.codex/generated_images/` หลัง save เสร็จทุกครั้ง
- Multi-scene: format และ style ยึดตาม product instructions — agent นี้ไม่ตัดสินใจเอง

**รูปที่มีคนหรือฉากชีวิต (lifestyle/human scene):**
- ใช้ `Southeast Asian` สำหรับ features ของคน — ไม่ใช่ยุโรปหรือตะวันตก
- ใช้ `contemporary Thailand` สำหรับ setting — ครอบคลุมทั้ง Bangkok และเมืองต่างจังหวัดที่ทันสมัย ไม่ใช่ชนบทหรือทุ่งนา
- ตัวอย่าง: `contemporary Thailand setting, Southeast Asian woman, modern urban lifestyle`
