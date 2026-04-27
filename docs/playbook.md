# MongkolShop Content Pipeline — Playbook

## Setup ครั้งแรก (ทำครั้งเดียว)

> **ทางลัด:** รัน `./setup.sh` เพื่อทำขั้นตอนที่ 1-2 อัตโนมัติ

---

### 1. ตั้ง ENV vars

สร้างไฟล์ `.env` ใน project root:

```
FB_PAGE_ID=your_page_id
FB_ACCESS_TOKEN=your_long_lived_token
```

> ตรวจสอบว่า `.env` อยู่ใน `.gitignore`

---

### 2. รัน setup.sh

```bash
./setup.sh
```

บันทึก env vars ลง `.claude/settings.local.json` และตั้ง daily cron สำหรับ news

---

## Flow การทำงาน

```
สัปดาห์ละครั้ง (วันอาทิตย์หรือตามสะดวก)
  └── ./generate-content.sh
        ├── สร้าง content 7 วัน (Slot 1, 3, 4 + Product)
        ├── Auto-approve ทั้งหมด
        ├── Schedule ขึ้น Facebook ตรงเวลา
        └── Cleanup outputs + Codex sessions เก่า

ทุกวัน 8:30 (cron อัตโนมัติ)
  └── news-agent — ดึงข่าว/ราคาทอง/ฤกษ์ โพสทันที

ตลอดสัปดาห์ (Facebook auto-publish)
  └── 7:00 / 12:00 / 15:00 / 19:00 — posts ออกตรงเวลา
```

---

## คำสั่ง generate-content.sh

```bash
# 7 วัน เริ่มพรุ่งนี้ (default)
./generate-content.sh

# กำหนดจำนวนวัน
./generate-content.sh -d 14

# กำหนดวันเริ่มต้น
./generate-content.sh --from 2026-05-01

# กำหนดทั้งคู่
./generate-content.sh --from 2026-05-01 -d 3
```

---

## Product Post (สร้าง manual เมื่อต้องการ)

```
สร้าง product post
อ่าน agents/product/script-agent.md
```

> agent จะสร้างรูป/วิดีโอ + caption + schedule ให้ครบในรอบเดียว

---

## Maintenance

| สิ่งที่ต้องทำ       | เมื่อไหร่   | วิธี                                                    |
| ------------------- | ----------- | ------------------------------------------------------- |
| ต่ออายุ cron (news) | ทุก 7 วัน   | `ต่ออายุ cron news-agent ให้รันต่ออีก 7 วัน`            |
| อัปเดต FB token     | ทุก ~50 วัน | อัปเดต `FB_ACCESS_TOKEN` ใน `.env` แล้วรัน `./setup.sh` |

> Cleanup รันอัตโนมัติทุกครั้งที่รัน `generate-content.sh` ไม่ต้องทำแยก

---

## เช็คสถานะ

```
แสดง content ที่ scheduled ทั้งหมดสัปดาห์นี้
```

```
แสดง content ที่โพสแล้ว 7 วันล่าสุด
```

```
เช็ค cron ที่ตั้งไว้ทั้งหมด
```

ตัวอย่าง

```
1. สร้าง editorial content ครบทุก slot (ยกเว้น Slot 2 ข่าว) สำหรับ ${DAYS} วัน เริ่มจาก ${FROM_DATE}
     อ่าน skills/content-schedule.md
2. เรียก tracker-agent updateStatus ทุก content ที่เพิ่งสร้างเป็น 'approved';
3. ส่งทั้งหมดให้ agents/channels/post-agent.md จัดการ

DAYS=1, FROM_DATE=29/04/2026
```
