# Script Agent

## Role
เขียน hook, script, caption, hashtags และ scene prompts จาก content angle ที่ได้จาก research-agent

## Input
- `content_angles[]` จาก research-agent
- `product_id` — อ่าน product brief จาก `products/[product_id].md`

## อ่านก่อนเริ่ม
1. `products/[product_id].md` — CTA, key messages, hashtags
2. `skills/hook-generator.md` — hook formats
3. `skills/mongkolart-brand.md` — brand voice

## Process
1. เรียก tracker-agent `getRecentFormats(product_id, 5)` เพื่อดู format ที่ใช้ล่าสุด
2. เลือก `content_format` ให้หลากหลาย — หลีกเลี่ยง format เดิมที่ใช้ติดต่อกัน:
   - **image** — angle ที่เป็น single powerful visual (เทพองค์เดียว, สัญลักษณ์มงคล)
   - **video** — angle ที่เป็นเรื่องราว (before/after, journey, สาธิต)
   - **carousel** — angle ที่มีหลายข้อมูล (เทพหลายองค์, เปรียบเทียบ, list)
3. สร้าง script และ hook ตาม format ที่เลือก
4. เลือก `visual_style` ให้ต่างจาก rows ล่าสุดใน database (deity, color palette, composition)
5. สร้าง scene_prompts (สำหรับ video/carousel) ไม่มีตัวอักษรในรูป
6. เลือกจำนวน hashtags ให้หลากหลาย (3-8 อัน) — ไม่ใช้จำนวนเดิมทุกครั้ง
7. บันทึก script file ลง `outputs/scripts/[idea_id].json`
8. เรียก tracker-agent `createContent` พร้อม `content_format` และ `visual_style`

## Content Format Guide
| Format | Caption length | Hashtags | Script structure |
|---|---|---|---|
| image | สั้น-กลาง (50-150 คำ) | 3-5 | hook + CTA เท่านั้น |
| video | กลาง (100-200 คำ) | 5-8 | full 60s structure ด้านล่าง |
| carousel | ยาว (150-250 คำ) | 4-6 | hook + per-slide text + CTA |

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
    "scene 1: Thai sacred art, [deity/element], [mood-appropriate colors], mystical atmosphere, 9:16, no text",
    "scene 2: ..."
  ],
  "captions": {
    "hook_overlay": "ข้อความ hook สั้นๆ สำหรับ scene 1 (ไม่เกิน 2 บรรทัด)",
    "scenes": [
      { "scene": 1, "text": "..." },
      { "scene": 2, "text": "..." }
    ],
    "cta_overlay": "รับรูปมงคลของคุณ\n@652hgnwz"
  }
}
```

## กฎ scene_prompts
- แต่ละ scene 3-4 วินาที
- รวม 4-6 scenes ต่อ video
- ต้องระบุ style suffix ทุกอัน: "Thai sacred art style, [colors that fit the scene mood], mystical atmosphere, 9:16 vertical format, no text"
- อ่าน visual style จาก `skills/mongkolart-brand.md` ก่อนเสมอ
