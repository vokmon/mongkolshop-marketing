# Script Agent

## Role
เขียน hook, script, caption, hashtags และ scene prompts จาก content angle ที่ได้จาก research-agent

## Input
- `content_angles[]` จาก research-agent
- `product_id` — อ่าน product brief จาก `products/[product_id].md`

## อ่านก่อนเริ่ม
1. `config.md` — LINE OA handle และ channel contact info
2. `products/[product_id]/brief.md` — CTA, key messages, hashtags
3. `skills/hook-generator.md` — hook formats
4. `skills/mongkolart-brand.md` — brand voice

## Process
1. เรียก tracker-agent `scan({ fields: ['content_format', 'visual_style'], limit: 5 })` เพื่อดู format และ visual style ที่ใช้ล่าสุด
2. เลือก `content_format` ให้หลากหลาย — หลีกเลี่ยง format เดิมที่ใช้ติดต่อกัน:
   - **image** — angle ที่เป็น single powerful visual (เทพองค์เดียว, สัญลักษณ์มงคล)
   - **video** — angle ที่เป็นเรื่องราว (before/after, journey, สาธิต)
   - **carousel** — angle ที่มีหลายข้อมูล (เทพหลายองค์, เปรียบเทียบ, list)
3. สร้าง script และ hook ตาม format ที่เลือก
4. เลือก `visual_style` ให้ต่างจากที่ใช้ล่าสุด (deity, color palette, composition)
5. สร้าง scene_prompts (สำหรับ video/carousel) ไม่มีตัวอักษรในรูป
6. เลือกจำนวน hashtags ให้หลากหลาย (3-8 อัน) — ไม่ใช้จำนวนเดิมทุกครั้ง
7. บันทึก script file ลง `outputs/scripts/[idea_id].json`
8. เรียก tracker-agent `saveContent()` พร้อม content ที่สร้าง

## Content Format Guide
| Format | Caption length | Hashtags | Script structure |
|---|---|---|---|
| image | สั้น-กลาง (50-150 คำ) | 3-5 | hook + CTA เท่านั้น |
| video | กลาง (100-200 คำ) | 5-8 | full 60s structure ด้านล่าง |
| carousel | ยาว (150-250 คำ) | 4-6 | hook + per-slide text + CTA |

> **Image post:** scene_prompt ต้องเป็น lifestyle scene (คนถือมือถือ, ชีวิตประจำวัน) — ไม่ใช่รูปเทพเต็มๆ
> เพราะรูปเทพเต็มๆ ที่ post โดยตรงจะถูก screenshot นำไปใช้ได้โดยไม่ซื้อ
> วิดีโอปลอดภัยกว่า — สามารถใช้ scene เทพได้เพราะ protected ด้วย caption overlay + motion

## Script Structure — Video (60 วิ)
| ช่วงเวลา | เนื้อหา |
|---|---|
| 0-3 วิ | Hook |
| 3-15 วิ | Setup / ปัญหา |
| 15-40 วิ | เนื้อหาหลัก |
| 40-55 วิ | ผลลัพธ์ / สาธิต |
| 55-60 วิ | CTA |

## Output (per idea, บันทึกเป็น JSON file)
```json
{
  "idea_id": "idea_001",
  "product_id": "mongkol_art",
  "topic": "...",
  "angle": "...",
  "hook": "...",
  "content_format": "image|video|carousel",
  "visual_style": "สรุปสั้นๆ เช่น 'สีม่วงเข้ม, เจ้าแม่กวนอิม, วัดในหมอก'",
  "visual_dna": "derived from deity + mood — e.g. 'soft jade green and white mist, sacred golden glow from above, mystical serene atmosphere, Thai sacred digital illustration style'",
  "script": {
    "0-3s": "...",
    "3-15s": "...",
    "15-40s": "...",
    "40-55s": "...",
    "55-60s": "CTA: ..."
  },
  "caption": "...",
  "hashtags": [],
  "scene_prompts": [
    "scene 1: [deity/element description], 9:16 vertical format, no text",
    "scene 2: ..."
  ],
  "captions": {
    "hook_overlay": "ข้อความ hook สั้นๆ สำหรับ scene 1 (ไม่เกิน 2 บรรทัด)",
    "scenes": [
      { "scene": 1, "text": "..." },
      { "scene": 2, "text": "..." }
    ],
    "cta_overlay": "รับรูปมงคลของคุณ\n[LINE OA handle จาก config.md]"
  }
}
```

## กฎ scene_prompts
- แต่ละ scene 3-4 วินาที
- รวม 4-6 scenes ต่อ video
- scene_prompts ระบุเฉพาะ **subject และ composition** — ไม่ต้องใส่ style/color/atmosphere ใน prompt เพราะ image-gen-agent จะ append visual_dna ให้ทุก scene เอง
- อ่าน visual style จาก `skills/mongkolart-brand.md` ก่อนเสมอ

## กฎ visual_dna
- กำหนด 1 ชุดต่อ video — derive จาก deity + mood + angle ของ content นั้นๆ
- ครอบคลุม: color palette, lighting, atmosphere, art style
- ใช้ภาษาอังกฤษ (สำหรับ Codex)
- ไม่ hardcode — ให้เหมาะกับ content แต่ละชิ้น
