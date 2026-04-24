# Tracker Agent

## Role
จัดการ content tracking ผ่าน Supabase — บันทึกสถานะ ป้องกัน duplicate และ query content

## ENV ที่ต้องการ
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## Database Schema

### ตาราง `content`
| Column | Type | ค่า |
|---|---|---|
| id | uuid | auto |
| product_id | text | เช่น `mongkol_art` |
| topic | text | หัวข้อหลัก |
| angle | text | content angle |
| hook | text | hook ที่ใช้ |
| content_format | text | `image`, `video`, `carousel` |
| visual_style | text | สรุปสั้นๆ เช่น "สีม่วงเข้ม, พระพิฆเนศ, ดอกบัวใกล้ชิด" |
| script_path | text | path ของ script file |
| image_paths | text[] | paths ของรูป |
| video_path | text | path ของ video.mp4 |
| status | text | ดูด้านล่าง |
| created_at | timestamp | auto |

### Status Values
- `draft` — สร้างแล้ว รอ human เลือก
- `approved` — human เลือกแล้ว รอสร้าง video
- `ready` — video พร้อม รอ human review
- `published` — publish แล้ว
- `rejected` — human ไม่เลือก
- `failed` — publish ล้มเหลว

### ตาราง `published`
| Column | Type | ค่า |
|---|---|---|
| id | uuid | auto |
| content_id | uuid | references content.id |
| platform | text | `facebook`, `tiktok`, `ig`, `youtube` |
| url | text | URL หลัง publish |
| published_at | timestamp | auto |

## Operations

### ตรวจ Duplicate ก่อนสร้าง content ใหม่
Query `content` หา rows ที่ `product_id` ตรงกัน และ:
- `topic` + `angle` ซ้ำกัน, หรือ
- `hook` คล้ายกัน (ใช้ ilike หรือ similarity), หรือ
- `visual_style` ซ้ำกัน (ป้องกันรูปหน้าตาเหมือนกัน)
ถ้าเจอ duplicate ให้แจ้ง agent ว่า "already exists: [id]" และหยุด

### getRecentFormats(product_id, limit)
ดึง `content_format` ล่าสุด N รายการ เพื่อให้ script-agent หลีกเลี่ยงการใช้ format เดิมซ้ำต่อเนื่องกัน

### createContent(data)
Insert ลงตาราง `content` พร้อม `status = 'draft'`
Return `id` ของ row ที่สร้าง

### updateStatus(id, status)
Update `status` ของ content row

### updatePaths(id, { script_path, image_paths, video_path })
Update paths หลังสร้าง assets เสร็จ

### getDrafts(product_id)
ดึง rows ที่ `status = 'draft'` และ `product_id` ตรงกัน

### getApproved(product_id)
ดึง rows ที่ `status = 'approved'` และ `product_id` ตรงกัน

### getReady(product_id)
ดึง rows ที่ `status = 'ready'` และ `product_id` ตรงกัน

### recordPublished(content_id, platform, url)
Insert ลงตาราง `published` และ update `content.status = 'published'`

## Tools
- Supabase JS client (`@supabase/supabase-js`) หรือ REST API
- ใช้ ENV `SUPABASE_URL` และ `SUPABASE_ANON_KEY` เสมอ — ห้าม hardcode
