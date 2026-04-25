# Content Schedule — MongkolShop

## Weekly Template (Base Schedule)

4 slots/day — product เพียง 3 posts/สัปดาห์ (~10%) เพื่อไม่ให้ page ดู hard sale
**การกำหนดเวลาจริงเป็นหน้าที่ของ post-agent/scheduler ไม่ใช่ content agents**

| | Slot 1 (เช้า) | Slot 2 (เช้า auto) | Slot 3 (กลางวัน) | Slot 4 (เย็น) |
|---|---|---|---|---|
| **จันทร์** | ดวงวันนี้ (จ-อ infographic) | ข่าว (auto) | เรื่องเทพ | ความรัก/ครอบครัว |
| **อังคาร** | ดวงวันนี้ | ข่าว (auto) | ตำนาน/นิทานชาดก | ศาสตร์ดูดวง |
| **พุธ** | ดวงวันนี้ | ข่าว (auto) | เรื่องเทพ | **Product** (image) |
| **พฤหัส** | ดวงวันนี้ | ข่าว (auto) | เครื่องรางของขลัง | สุขภาพ + มงคล |
| **ศุกร์** | ดวงวันนี้ | ข่าว (auto) | เรื่องเทพ (angle ใหม่) | **Product** (video) |
| **เสาร์** | ดวงวันนี้ | ข่าว (auto) | ความมั่งคั่ง/การเงิน | ชีวิต/ท่องเที่ยว |
| **อาทิตย์** | ดวงวันนี้ | ข่าว (auto) | life topic | **Product** (สลับ) |

### วันสำคัญ (Festival Override)
เมื่อมีเทศกาล/วันสำคัญ — scheduler เพิ่ม festival post **ก่อน Slot 1 (ตี 6 หรือเช้ามืด)** เพื่อให้คนเห็นตั้งแต่เริ่มวัน และปรับ slot 3 เป็น festival content แทน
ดูรายละเอียดใน `agents/scheduler/post-agent.md`

## Posting Time Rationale

| เวลา | พฤติกรรม User |
|---|---|
| 7:00 น. | เช็คมือถือก่อนออกจากบ้าน — ดวงวันนี้ตรงกับ behavior |
| 8-9:00 น. | ระหว่างเดินทาง/เริ่มทำงาน — เช็คข่าวประจำวัน |
| 12:00 น. | พักกลางวัน — อ่านสาระ เรื่องเล่า |
| 19:00 น. | หลังเลิกงาน — engage, ตัดสินใจซื้อ |

## Image Format

| Content Type | Format | ขนาด |
|---|---|---|
| ดวง จ-อ weekly | Carousel (7 slides) | 1:1 (1080x1080) |
| ดวงวันนี้ | Single image | 4:5 (1080x1350) |
| เรื่องเทพ / ตำนาน / นิทาน | Single image | 4:5 |
| ศาสตร์ดูดวง / เครื่องราง | Single image | 4:5 |
| Life topics (ความรัก, สุขภาพ ฯลฯ) | Single image | 4:5 |
| ข่าว / พยากรณ์อากาศ | Single image | 4:5 |
| Product image post | Single image | 9:16 (1080x1920) |
| Product video | Video | 9:16 (1080x1920) |

## Image Style — Non-Product Posts

รูปเทพ + background ที่สื่อถึงเนื้อหา — ไม่ใช่ lifestyle scene (lifestyle ใช้เฉพาะ product post)

| Content | Background Style |
|---|---|
| เรื่องเทพ / คุณธรรม | Sacred realm — สวรรค์ วิหาร ธรรมชาติศักดิ์สิทธิ์ |
| ตำนาน / นิทานชาดก | Illustrated scene จากเรื่องนั้น |
| ศาสตร์ดูดวง | Celestial — ดาว ราศี จักรวาล |
| ความรัก | Lotus garden, warm soft light |
| ความมั่งคั่ง / การเงิน | Golden palace, เหรียญ, prosperity symbols |
| สุขภาพ | Nature — ป่า แม่น้ำ แสงรุ่งอรุณ |
| การเดินทาง | Journey landscape — ภูเขา เส้นทาง ขอบฟ้า |
| เครื่องรางของขลัง | Sacred objects บนแท่นบูชา |
| ดวงวันนี้ | Infographic — deity ประจำวัน + สีนำโชค |
| ข่าวทอง/หุ้น | Flat graphic — gold/financial visual + text zone |
| พยากรณ์อากาศ | Sky + nature + spiritual element |

## Content Ratio (สัปดาห์)

28 posts/สัปดาห์ (4/วัน)

| Category | Posts | % |
|---|---|---|
| News (auto, ทุกเช้า) | 7 | 25% |
| Horoscope (ทุกเช้า) | 7 | 25% |
| Educational (เทพ/ตำนาน/ศาสตร์/เครื่องราง) | 7 | 25% |
| Life Topics + Product | 7 | 25% |
| — Product | 3 | ~10% |
| — Life Topics | 4 | ~14% |
