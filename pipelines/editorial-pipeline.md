# Editorial Pipeline — MongkolArt

สร้าง editorial content ครบ batch → approve → schedule Facebook ในขั้นตอนเดียว

## Input

```
FROM_DATE = DD/MM/YYYY
DAYS = N
```

---

## Step 1 — สร้าง Content

ทำตาม `pipelines/batch-editorial.md` ครบทุก Phase (0-3)

---

## Step 2 — Approve

tracker-agent `updateStatus(content_id, 'approved')` ทุก content ที่เพิ่งสร้างใน Step 1

---

## Step 3 — Publish

ทำตาม `agents/channels/post-agent.md`
