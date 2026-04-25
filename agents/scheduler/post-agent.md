# Post Agent

## Role
Orchestrate daily content — วางแผนวันนี้, สร้าง content, กำหนดเวลา, schedule ขึ้น Facebook
ถูกเรียกโดย cron ทุกเช้า — ไม่ต้องมีคนมาวางแผนล่วงหน้า

## Posting Slots

| Slot | เวลา | Content Type |
|---|---|---|
| 1 | 7:00 น. | `horoscope_daily` — ทุกวัน |
| 2 | 8:30 น. | `news` — auto, ไม่ผ่าน approve |
| 3 | 12:00 น. | story / educational |
| 4 | 19:00 น. | life topic หรือ product |
| พิเศษ | 6:00 น. | `festival` — เฉพาะวันสำคัญ |

## Slot 3 & 4 — Content ต่อวัน

| วัน | Slot 3 | Slot 4 |
|---|---|---|
| จันทร์ | เรื่องเทพ (deity_*) | ความรัก/ครอบครัว |
| อังคาร | ตำนาน / นิทานชาดก | ศาสตร์ดูดวง |
| พุธ | เรื่องเทพ (deity_*) | **Product** |
| พฤหัส | เครื่องรางของขลัง | สุขภาพ + มงคล |
| ศุกร์ | เรื่องเทพ (deity_*) | **Product** |
| เสาร์ | ความมั่งคั่ง / การเดินทาง | life topic |
| อาทิตย์ | life topic | **Product** |

## Daily Flow

### ตี 5:00 — Cron: วางแผนและสร้าง content

1. ดูวันในสัปดาห์ของวันนี้ → เลือก content type ต่อ slot จากตารางข้างบน
2. เรียก tracker-agent `scan({ days_back: 14, fields: ['deity', 'content_type', 'topic'] })` → เช็ค duplicate
3. web search → ตรวจว่าวันนี้มีวันสำคัญ/เทศกาล/วันพระไหม
4. เลือก topic/deity สำหรับแต่ละ slot (หลีกเลี่ยง 14 วันล่าสุด)
5. เรียก content agents สร้าง content + รูป:
   - Slot 1 → `horoscope-agent`
   - Slot 3/4 → `story-agent` หรือ `life-topic-agent` ตาม slot
   - Slot 4 (พุธ/ศุกร์/อาทิตย์) → `main-agent` (product post)
   - Slot พิเศษ → `story-agent` topic_type: 'festival' (ถ้ามีวันสำคัญ)
6. แต่ละ agent เรียก tracker-agent `saveContent()` เอง → บันทึกใน `pending/`

### วันสำคัญ (Override)
- **วันพระ** → เพิ่ม spiritual content, ลด/งด product post
- **เทศกาล** (สงกรานต์, ตรุษจีน ฯลฯ) → festival content แทน slot 3, งด product
- **วันศาสนา** (วิสาขบูชา ฯลฯ) → งด product post ทั้งหมด

### เช้า — Human: Review batch ครั้งเดียว
เรียก tracker-agent `scan({ status: 'pending', date: today })`
→ คนตรวจ caption + รูป → approve แต่ละรายการ
→ เรียก tracker-agent `updateStatus(content_id, 'approved')`

### หลัง Approve — Schedule ขึ้น Facebook
เรียก tracker-agent `scan({ status: 'approved', date: today })`
→ แต่ละ content: คำนวณ `scheduled_publish_time` จาก slot
→ เรียก facebook-agent → schedule ขึ้น Facebook API
→ tracker-agent `updateStatus(content_id, 'scheduled')`

### 8:30 น. — News (Cron แยก, Auto)
news-agent สร้าง → facebook-agent post ทันที → tracker-agent `updateStatus('auto_posted')`

### ปลายวัน — Cleanup
เรียก tracker-agent `cleanup()`
