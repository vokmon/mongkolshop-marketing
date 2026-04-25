# MongkolShop Content Pipeline — Playbook

## Setup ครั้งแรก (ทำครั้งเดียว)

> **ทางลัด:** รัน `./setup.sh` เพื่อทำขั้นตอนที่ 1-2 อัตโนมัติ แล้วข้ามไปขั้นตอนที่ 3 ได้เลย

---

### 1. ตั้ง ENV vars

สร้างไฟล์ `.env` ใน project root (ข้างๆ `CLAUDE.md`):

```
FB_PAGE_ID=your_page_id
FB_ACCESS_TOKEN=your_long_lived_token
```

> ตรวจสอบว่า `.env` อยู่ใน `.gitignore` เพื่อไม่ให้ token ขึ้น git
>
> หรือใช้ `./setup.sh` — จะอ่าน `.env` และบันทึก env vars ลง `.claude/settings.local.json` ให้อัตโนมัติ

---

### 2. ตั้ง Cron 2 ตัว

พิมพ์ใน Claude Code ทีละอัน:

**Cron 1 — สร้าง content ทุกเช้า ตี 5:**
```
ตั้ง cron รัน post-agent ทุกวัน 05:00 ICT
อ่าน agents/scheduler/post-agent.md
```

**Cron 2 — โพส news ทุกเช้า 8:30:**
```
ตั้ง cron รัน news-agent ทุกวัน 08:30 ICT
อ่าน agents/content/news-agent.md
```

> **หมายเหตุ:** Cron ของ Claude Code หมดอายุทุก 7 วัน ต้องต่ออายุทุกสัปดาห์

---

---

## ตารางการใช้งานประจำวัน

| เวลา | ระบบทำอะไร | คุณต้องทำอะไร | คำสั่งที่พิมพ์ใน Claude Code |
|---|---|---|---|
| **ตี 5** | Cron รัน post-agent อัตโนมัติ — สร้าง content ทุก slot สำหรับวันนี้ | ไม่ต้องทำอะไร | — |
| **8:30** | Cron รัน news-agent อัตโนมัติ — โพสข่าวทันที | ไม่ต้องทำอะไร | — |
| **ช่วงเช้า** | รอ human approve | ดู content ที่รอ approve | `แสดง pending content วันนี้` |
| **ช่วงเช้า** | — | Approve ทั้งหมด + ส่ง Facebook | `approve และ schedule content ทั้งหมดวันนี้` |
| **ตลอดวัน** | Facebook auto-publish ตรงเวลา (12:00, 19:00) | ไม่ต้องทำอะไร | — |

---

## คำสั่ง Approve (เลือกตามสถานการณ์)

### ดู content ก่อน approve

```
แสดง pending content วันนี้
```
> จะแสดง caption + path รูปของแต่ละ slot

### Approve ทั้งหมดในครั้งเดียว

```
approve และ schedule content ทั้งหมดวันนี้
```

### Approve ทีละอัน

```
approve idea_001 และ schedule ขึ้น Facebook
```

### แก้ caption ก่อน approve

```
แก้ caption ของ idea_002 เป็น "[caption ใหม่]" แล้ว approve และ schedule
```

### ไม่ใช้ content ชิ้นไหน

```
reject idea_003
```

---

## คำสั่ง Product Post (สร้างเมื่อต้องการ)

### Phase 1 — หา ideas

```
สร้าง content mongkol_art
อ่าน agents/main-agent.md แล้วรัน Phase 1
```

> ระบบจะแสดง 3-5 ideas ให้เลือก

### Phase 2 — สร้างรูป/วิดีโอ

```
เลือก idea_002 แล้วไปต่อ Phase 2
```

### Phase 3 — Schedule ขึ้น Facebook

```
approve idea_002 และ schedule วันศุกร์ 19:00
```

---

## คำสั่ง Maintenance

| ทำเมื่อไหร่ | คำสั่งที่พิมพ์ |
|---|---|
| ทุก 7 วัน (cron หมดอายุ) | `ต่ออายุ cron ทั้ง 2 ตัว ให้ run ต่ออีก 7 วัน` |
| ทุก ~50 วัน (FB token หมด) | อัปเดต `FB_ACCESS_TOKEN` ใน `~/.zshrc` แล้ว `source ~/.zshrc` |
| ทุกอาทิตย์ | `รัน tracker-agent cleanup ลบ posted content เกิน 30 วัน` |
| ถ้า cron พัง / ไม่รัน | `รัน post-agent สำหรับวันนี้ — อ่าน agents/scheduler/post-agent.md` |

---

## คำสั่ง เช็คสถานะ

```
แสดง content ทั้งหมดวันนี้ ทุก status
```

```
แสดง content ที่โพสแล้ว 7 วันล่าสุด
```

```
เช็ค cron ที่ตั้งไว้ทั้งหมด
```

---

## Flow สรุป

```
ตี 5: Cron → post-agent สร้าง content ทุก slot
         ↓
ช่วงเช้า: คุณพิมพ์ "แสดง pending content วันนี้"
         ↓
         ดู → พิมพ์ "approve และ schedule content ทั้งหมดวันนี้"
         ↓
8:30: news-agent โพสข่าวอัตโนมัติ
         ↓
12:00 & 19:00: Facebook auto-publish ตรงเวลา
```
