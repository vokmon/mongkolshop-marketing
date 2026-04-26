# Video Agent

## Role
รวม scene images + audio + captions เป็น video.mp4 ด้วย FFmpeg + Pillow

## Input
- `images[]` จาก image-gen-agent (path + duration ของแต่ละ scene)
- `captions` จาก script-agent (`hook_overlay`, `scenes[]`, `cta_overlay`)
- `idea_id`
- `product_id` — อ่าน product-specific instructions จาก `products/[product_id]/video-agent.md`

## Audio Selection
อ่านจาก `docs/music-list.md` — ทำตามนี้ทุกครั้ง:
1. อ่าน mood ของวิดีโอจาก script (hook tone + content angle)
2. อ่าน product instructions เพื่อดู mood guidance เฉพาะ product
3. กรอง tracks ที่ตรง mood tag
4. สุ่ม 1 track — ไม่ใช้ track เดิมซ้ำติดต่อกัน
5. ดาวน์โหลดเฉพาะเมื่อไม่มีไฟล์ใน `outputs/audio/`:
   ```bash
   [ -f outputs/audio/[filename] ] || curl -L "[url]" -o outputs/audio/[filename]
   ```

## Font
- Thai font: `/Users/arnon/Library/Fonts/NotoSansThai[wdth,wght].ttf`
- copy ไปที่ `/tmp/NotoSansThai.ttf` ก่อนใช้งาน (หลีกเลี่ยง bracket ใน path)
- ถ้ารันบน server อื่น: `brew install font-noto-sans-thai`

## Caption Rendering (Pillow)
ใช้ Python Pillow เพื่อ burn captions ลงบน captioned images ก่อน feed เข้า FFmpeg
— เนื่องจาก FFmpeg drawtext ไม่รองรับ Thai font บน macOS Homebrew build

อ่าน `products/[product_id]/video-agent.md` เพื่อดู caption layer specification ของ product นั้น
(fontsize, position, color, จำนวน layer, กฎการแสดง)

## FFmpeg Composition
```bash
ffmpeg \
  -loop 1 -t [duration] -i outputs/scheduled/[content_id]/scenes/scene_01_cap.png \
  -loop 1 -t [duration] -i outputs/scheduled/[content_id]/scenes/scene_02_cap.png \
  ... \
  -i [audio_path] \
  -filter_complex "
    [0:v]scale=1080:1920,setsar=1,fade=t=out:st=[end-0.5]:d=0.5[v0];
    [1:v]scale=1080:1920,setsar=1,fade=t=in:st=0:d=0.5,fade=t=out:st=[end-0.5]:d=0.5[v1];
    ...
    [v0][v1]...concat=n=[N]:v=1:a=0[v]
  " \
  -map "[v]" -map [audio_index]:a \
  -shortest -c:v libx264 -pix_fmt yuv420p -c:a aac \
  outputs/scheduled/[content_id]/video.mp4
```

## Process
1. อ่าน `products/[product_id]/video-agent.md` — ทำตาม caption layer spec ของ product
2. ตรวจว่า images ทุก scene มีอยู่จริง
3. เลือก audio track ตาม mood
4. Burn captions ลง images ด้วย Pillow → บันทึกเป็น `scenes/scene_0N_cap.png`
5. รัน FFmpeg รวม captioned images + audio
6. บันทึกลง `outputs/scheduled/[content_id]/video.mp4`
7. เรียก tracker-agent `updatePaths` และ `updateStatus([idea_id], 'ready')`

## กฎ
- Output ต้องเป็น 1080x1920 (9:16) เสมอ
- ใช้ `-shortest` เพื่อตัด audio ให้พอดีกับ video
- ถ้าไม่มี audio ให้สร้าง video แบบไม่มีเสียงก่อน แล้วแจ้ง user
- caption spec ยึดตาม product instructions — agent นี้ไม่ตัดสินใจเอง
