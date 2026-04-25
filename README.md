# MongkolShop Marketing

Marketing automation and content generation for MongkolArt — น้องมงคล LINE OA Chatbot (`@652hgnwz`).

Goal: drive sales to the LINE OA channel through automated content creation, image generation, and social media posting.

---

## Scope

- **Content generation** — captions, posts, hashtags for Facebook and LINE
- **Image generation** — promotional visuals using AI image tools
- **Posting automation** — scheduled and triggered posts to Facebook Page and LINE Broadcast
- **Campaign planning** — strategy, content calendar, and briefs

---

## Products

| product_id | ชื่อ | ราคา | ช่องทาง | Brief |
|---|---|---|---|---|
| `mongkol_art` | รูปมงคล | 159 THB | LINE OA `@652hgnwz` | `products/mongkol_art/brief.md` |

---

## Content Pipeline

3-phase workflow พร้อม human checkpoint 2 จุด:

```
Phase 1: Research → [Human เลือก idea] → Phase 2: Creative → [Human review] → Phase 3: Publish
```

### Agent Router

| Task | Agent |
|---|---|
| สร้าง content ใหม่ (ทั้ง pipeline) | `agents/main-agent.md` |
| Research + script เท่านั้น | `agents/research/research-agent.md` |
| สร้างรูป | `agents/creative/image-gen-agent.md` |
| สร้าง video | `agents/creative/video-agent.md` |
| สร้าง thumbnail | `agents/creative/asset-agent.md` |
| Publish ไป Facebook | `agents/channels/facebook-agent.md` |
| ดู / อัพเดท database | `agents/utils/tracker-agent.md` |

---

## Project Structure

```
agents/
├── main-agent.md              # orchestrator (3-phase pipeline)
├── research/
│   ├── research-agent.md      # web search — trends + angles
│   └── script-agent.md        # hook, script, caption, scene prompts
├── creative/
│   ├── image-gen-agent.md     # Codex image generation
│   ├── video-agent.md         # FFmpeg composition
│   └── asset-agent.md         # thumbnails
├── channels/
│   ├── facebook-agent.md      # active
│   ├── tiktok-agent.md        # future
│   ├── ig-agent.md            # future
│   └── youtube-agent.md       # future
└── utils/
    └── tracker-agent.md       # Supabase read/write
products/
└── mongkol_art.md             # product brief
skills/
├── hook-generator.md          # hook patterns
├── mongkolart-brand.md        # brand voice + visual style
└── platform-specs.md          # per-platform format limits
docs/                          # strategy, campaign plans
outputs/
├── scripts/                   # generated script JSON files
├── images/                    # generated scene images
├── videos/                    # composed video files
└── published/                 # publish records
```

---

## AI CLI Tools

```bash
claude -p "<task>"
codex exec -s workspace-write "<task>"
```

| Task | Tool |
|---|---|
| Strategy, campaign planning, Thai copy | Claude |
| Image prompt generation | Claude |
| Image generation | Codex (directly generates — no API script) |
| Automation scripts | Codex |

### Image Generation Convention
- รัน `codex exec -s workspace-write` โดยตรง
- บันทึกลง `outputs/images/[idea_id]/`
- ลบไฟล์ต้นฉบับจาก `~/.codex/generated_images/` หลัง save เสร็จ

---

## Database

**Supabase** — content tracking และ duplicate prevention

### Schema
```sql
content (id, product_id, topic, angle, hook, content_format, visual_style, script_path, image_paths, video_path, status, created_at)
published (id, content_id, platform, url, published_at)
```

### Status Flow
`draft` → `approved` → `ready` → `published` / `failed`

---

## Channels

| Channel | Purpose | Status |
|---|---|---|
| Facebook Page | Organic content, promotions | Active |
| LINE OA `@652hgnwz` | Broadcast to existing customers | Active |
| TikTok | Short video content | Future |
| Instagram | Reels | Future |
| YouTube | Shorts | Future |

---

## ENV Variables

```env
# Anthropic
ANTHROPIC_API_KEY=

# OpenAI (Codex image generation)
OPENAI_API_KEY=

# Supabase
SUPABASE_URL=
SUPABASE_ANON_KEY=

# Facebook
META_ACCESS_TOKEN=
FB_PAGE_ID=

# TikTok (future)
TIKTOK_CLIENT_KEY=
TIKTOK_CLIENT_SECRET=
TIKTOK_ACCESS_TOKEN=

# Instagram (future) — shares META_ACCESS_TOKEN
IG_USER_ID=

# YouTube (future)
YOUTUBE_API_KEY=
YOUTUBE_CLIENT_ID=
YOUTUBE_CLIENT_SECRET=
YOUTUBE_REFRESH_TOKEN=
```

---

## Rules

- ห้าม hardcode API keys — อ่านจาก ENV เสมอ
- output ทุกอย่างบันทึกใน `outputs/`
- บันทึก Supabase ทุกครั้งที่ status เปลี่ยน
- ห้ามระบุว่าใช้ AI สร้างรูปในโฆษณา
- ถามก่อนทำถ้าไม่แน่ใจ อย่า assume

---

## Content Themes

- เทพพราหมณ์ฮินดู — พระพิฆเนศ, พระแม่ลักษมี, พระศิวะ และองค์อื่นๆ
- เทพจีน — เจ้าแม่กวนอิม, ไฉ่สิ้งเอี้ย, กวนอู และองค์อื่นๆ
- เทพไทย — พระภูมิเจ้าที่, นางกวัก, แม่ย่านาง และองค์อื่นๆ
- โชคชะตา, มงคล, ความเชื่อ, วอลเปเปอร์มือถือมงคล
