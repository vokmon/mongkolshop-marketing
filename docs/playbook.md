# MongkolShop Content Pipeline — Playbook

## Setup ครั้งแรก (ทำครั้งเดียว)

---

### 1. ตั้ง ENV vars

สร้างไฟล์ `settings.local.json` ใน project .claude

```
{
  "env": {
    "FB_ACCESS_TOKEN": "",
    "FB_PAGE_ID": ""
  }
}

---

## Maintenance

| สิ่งที่ต้องทำ       | เมื่อไหร่   | วิธี                                                    |
| ------------------- | ----------- | ------------------------------------------------------- |
| ต่ออายุ cron (news) | ทุก 7 วัน   | `ต่ออายุ cron news-agent ให้รันต่ออีก 7 วัน`            |
| อัปเดต FB token     | ทุก ~50 วัน | อัปเดต `FB_ACCESS_TOKEN` ใน `settings.local.json` |

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

run แบบ batch ไม่โดยที่ไม่ post

```

สร้าง editorial content 7 วัน เริ่มจาก 04/05/2026
อ่าน pipelines/batch-editorial.md

```

run แบบ batch และ post

```

สร้าง editorial content 7 วัน เริ่มจาก 04/05/2026
อ่าน pipelines/editorial-pipeline.md

```

```
