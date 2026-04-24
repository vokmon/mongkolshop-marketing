# Video Agent

## Role
รวม scene images + audio + captions เป็น video.mp4 ด้วย FFmpeg

## Input
- `images[]` จาก image-gen-agent (path + duration ของแต่ละ scene)
- `captions` จาก script-agent (`hook_overlay`, `scenes[]`, `cta_overlay`)
- `idea_id`
- `audio_path` — BGM file เลือกอัตโนมัติจาก `docs/music-list.md` โดย:
  1. อ่าน mood ของวิดีโอจาก script (hook tone + content angle)
  2. กรอง tracks ที่ตรง mood tag
  3. สุ่ม 1 track จากที่กรองได้ — ไม่ใช้ track เดิมซ้ำติดต่อกัน
  4. ดาวน์โหลดเฉพาะเมื่อไม่มีไฟล์ใน `outputs/audio/`

## Font
- Thai font: `/Users/arnon/Library/Fonts/NotoSansThai[wdth,wght].ttf`
- ถ้ารันบน server อื่น ให้ install ก่อน: `brew install font-noto-sans-thai`

## Caption Layers

### 1. Hook Overlay (scene 1 เท่านั้น)
- ข้อความใหญ่ center frame
- fontsize: 72, สีขาว, border ดำหนา
- แสดงตลอด duration ของ scene 1

### 2. Scene Subtitles (ทุก scene)
- ข้อความเล็ก bottom center (y = h-180)
- fontsize: 48, สีขาว, border ดำบาง
- แสดงตลอด duration ของแต่ละ scene

### 3. CTA Overlay (scene สุดท้ายเท่านั้น)
- ข้อความกลาง-ใหญ่ lower center (y = h*2/3)
- fontsize: 56, สีทอง (#FFD700), border ดำ
- แสดงตลอด duration ของ scene สุดท้าย

## FFmpeg drawtext Template

```bash
FONT="/Users/arnon/Library/Fonts/NotoSansThai[wdth,wght].ttf"

# คำนวณ start time ของแต่ละ scene (scene duration = 4 วิ)
# scene 1: st=0, scene 2: st=4, scene 3: st=8, scene 4: st=12 ...

ffmpeg \
  -loop 1 -t 4 -i outputs/images/[idea_id]/scene_01.png \
  -loop 1 -t 4 -i outputs/images/[idea_id]/scene_02.png \
  -loop 1 -t 4 -i outputs/images/[idea_id]/scene_03.png \
  -loop 1 -t 4 -i outputs/images/[idea_id]/scene_04.png \
  -i [audio_path] \
  -filter_complex "
    [0:v]scale=1080:1920,setsar=1,fade=t=out:st=3.5:d=0.5[v0];
    [1:v]scale=1080:1920,setsar=1,fade=t=in:st=0:d=0.5,fade=t=out:st=3.5:d=0.5[v1];
    [2:v]scale=1080:1920,setsar=1,fade=t=in:st=0:d=0.5,fade=t=out:st=3.5:d=0.5[v2];
    [3:v]scale=1080:1920,setsar=1,fade=t=in:st=0:d=0.5[v3];
    [v0][v1][v2][v3]concat=n=4:v=1:a=0[base];

    [base]
    drawtext=fontfile='$FONT':text='[HOOK_LINE1]\n[HOOK_LINE2]':
      fontsize=72:fontcolor=white:borderw=4:bordercolor=black:
      x=(w-text_w)/2:y=(h-text_h)/2:
      enable='between(t,0,4)',

    drawtext=fontfile='$FONT':text='[SCENE1_SUBTITLE]':
      fontsize=48:fontcolor=white:borderw=3:bordercolor=black:
      x=(w-text_w)/2:y=h-180:
      enable='between(t,0,4)',

    drawtext=fontfile='$FONT':text='[SCENE2_SUBTITLE]':
      fontsize=48:fontcolor=white:borderw=3:bordercolor=black:
      x=(w-text_w)/2:y=h-180:
      enable='between(t,4,8)',

    drawtext=fontfile='$FONT':text='[SCENE3_SUBTITLE]':
      fontsize=48:fontcolor=white:borderw=3:bordercolor=black:
      x=(w-text_w)/2:y=h-180:
      enable='between(t,8,12)',

    drawtext=fontfile='$FONT':text='[CTA_LINE1]\n[CTA_LINE2]':
      fontsize=56:fontcolor=#FFD700:borderw=4:bordercolor=black:
      x=(w-text_w)/2:y=h*2/3:
      enable='between(t,12,16)'
    [v]
  " \
  -map "[v]" -map [audio_index]:a \
  -shortest -c:v libx264 -pix_fmt yuv420p -c:a aac \
  outputs/videos/[idea_id].mp4
```

## Process
1. ตรวจว่า images ทุก scene มีอยู่จริง
2. อ่าน `captions` จาก script JSON file
3. แทนค่า caption text ใน FFmpeg template
4. รัน FFmpeg
5. บันทึกลง `outputs/videos/[idea_id].mp4`
6. เรียก tracker-agent `updatePaths` และ `updateStatus([idea_id], 'ready')`

## กฎ
- Output ต้องเป็น 1080x1920 (9:16) เสมอ
- ใช้ `-shortest` เพื่อตัด audio ให้พอดีกับ video
- ถ้าไม่มี audio ให้สร้าง video แบบไม่มีเสียงก่อน แล้วแจ้ง user
- caption text ต้องเป็นภาษาไทย
- hook overlay และ CTA overlay ห้ามซ้อนกับ subtitle
