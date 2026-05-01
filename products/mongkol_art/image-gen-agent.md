# Image Gen Instructions — MongkolArt (รูปมงคล)

Product: วอลเปเปอร์มือถือมงคล 9:16 แสดงเทพหรือสัญลักษณ์มงคล

## กลยุทธ์การแสดงรูป (Content Protection)
- **ห้าม post รูปเทพเต็มๆ เป็น image post** — คนจะ screenshot เอาไปใช้ได้เลยโดยไม่ซื้อ
- Image post ควรเป็น lifestyle scene ที่เห็น wallpaper อยู่ในหน้าจอมือถือเท่านั้น
- Video ปลอดภัยกว่า — scene เทพในวิดีโอถูก protect ด้วย caption overlay + motion + fade

## Hero Image (scene_01) — สำหรับ Video เท่านั้น
- scene_01 คือ deity wallpaper เต็มภาพ — generate เป็น internal reference ก่อนเสมอ
- ใช้เป็น visual reference สำหรับทุก scene และเป็น wallpaper ในหน้าจอมือถือ
- **ไม่ใช้ scene_01 เป็น image post โดยตรง**

## Visual Consistency
- append `visual_dna` จาก script ทุก scene — ไม่ปรับเปลี่ยนเอง
- ทุก scene ส่ง scene_01 เป็น visual style reference เพื่อ maintain color palette, lighting, atmosphere

## Scene Types และ Codex Command

### Image Post — Lifestyle Scene (ใช้กับ content_format: image)
รูปหลักของ post ต้องเป็น lifestyle scene เสมอ — wallpaper อยู่ในหน้าจอมือถือ ไม่ใช่รูปเดี่ยว
ใช้ command เดียวตาม template ด้านล่างสำหรับ image post

ตัวอย่าง story line — ไม่จำกัดเฉพาะนี้ สร้างรูปแบบอื่นๆ ได้ตาม angle ของ content:
- คนถือมือถือ มองหน้าจอที่มี wallpaper มงคล ยิ้มอย่างสงบ
- คนตื่นนอนตอนเช้า หยิบมือถือขึ้นมาดู wallpaper มงคล ดูสดชื่น
- คนนั่งทำงานที่โต๊ะ วางมือถือที่มี wallpaper มงคลอยู่ข้างๆ กาแฟ
- คนนั่งสมาธิ มือถือวางข้างหน้า หน้าจอแสดง wallpaper มงคล
- คนแสดงมือถือให้เพื่อนดู ทั้งคู่ยิ้ม
- มือถือวางบนโต๊ะบูชา/หิ้งพระ หน้าจอแสดง wallpaper มงคล

```bash
echo "Generate an image: [LIFESTYLE_SCENE_PROMPT], the phone screen shows a deity wallpaper with this style [DEITY_PROMPT], [VISUAL_DNA], realistic modern setting, soft natural daylight, photorealistic lifestyle photography style, 9:16 vertical format, no text, high quality. Save to outputs/scheduled/[content_id]/image.png" | codex exec
```
- สามารถเห็นทั้งมือ แขน หรือตัวคนได้ — ยิ่งเห็นคนมากยิ่งดู natural
- คนในรูปเป็นคนทั่วไปในชีวิตประจำวัน ไม่ต้องแต่งชุดศักดิ์สิทธิ์
- mood สะท้อน benefit ของ product (สงบ, มั่นใจ, มีความสุข, โชคดี)

### Video — Scene ทั่วไป (deity, symbol, atmosphere)
```bash
echo "Using outputs/scheduled/[content_id]/scene_01.png as visual style reference, maintain the same color palette, lighting, and atmosphere. Generate an image: [SCENE_PROMPT], [VISUAL_DNA], 9:16 vertical format, no text, high quality. Save to outputs/scheduled/[content_id]/scene_0N.png" | codex exec
```

### Video — Scene ที่แสดงผลิตภัณฑ์และ lifestyle
```bash
echo "Using outputs/scheduled/[content_id]/scene_01.png as the wallpaper displayed on the phone screen. Generate an image: [SCENE_PROMPT], realistic modern setting, soft natural daylight, photorealistic lifestyle photography style, 9:16 vertical format, no text, high quality — the phone screen must display exactly this wallpaper. Save to outputs/scheduled/[content_id]/scene_0N.png" | codex exec
```
- background รอบนอกต้องเป็น realistic/modern เสมอ ไม่ใช่ sacred art หรือ fantasy

## กฎเฉพาะ product นี้
- ห้ามมีตัวอักษรหรือข้อความในรูป (ใส่ทีหลังด้วย caption layer)
- format ต้องเป็น 9:16 เสมอ — รูปสำหรับ wallpaper มือถือ ไม่ใช่รูปติดผนัง
- เว้นพื้นที่ว่างด้านบนและด้านล่างเล็กน้อย ไม่ให้ subject ถูก notch หรือ navigation bar บัง
