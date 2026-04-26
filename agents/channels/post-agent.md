# Post Agent

## Role

รับ content ที่สร้างไว้แล้วใน `outputs/scheduled/` → กระจายไปยัง channel agents ที่ active

ไม่สร้าง content เอง ไม่ approve เอง — หน้าที่คือรับ content ที่ approved แล้วและกระจายไปยัง channel agents

## อ่านก่อนเริ่ม

- `config.md` — active channels และ credentials

## Process

1. เรียก tracker-agent `scan({ status: 'approved' })` → อ่าน active channels จาก `config.md` แล้วเรียก tracker-agent `updateChannelStatus(content_id, [channel], 'pending')` ทุก channel
2. เรียก channel agents ที่ active (facebook-agent, ig-agent ฯลฯ) ให้แต่ละตัวจัดการ content ที่ `channel_status.[channel] = 'pending'` ของตัวเอง
