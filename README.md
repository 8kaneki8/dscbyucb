# ClipForge AI

A dark, premium AI video-clipping SaaS starter built with Next.js App Router, TypeScript and Tailwind CSS.

## Current implementation

- Responsive landing page and clipping workspace UI.
- URL parsing and source classification for YouTube, Twitch, Kick, TikTok, Instagram, Facebook, X and direct video files.
- Server-side validation and explicit content-rights confirmation.
- Honest integration readiness state: the API does not fabricate analysis or generated clips.
- Supabase client bootstrap and environment template.

## Run locally

```bash
npm install
cp .env.example .env.local
npm run dev
```

Open http://localhost:3000.

## Configure real processing

Set the Supabase URL and anon key for database/auth features. Set `OPENAI_API_KEY`, `VIDEO_WORKER_URL` and `VIDEO_WORKER_SECRET` server-side to begin integrating a transcription/analysis provider and an authorized processing worker.

**Important:** this repository intentionally does not pretend that those integrations already exist. The analysis endpoint reports setup status until a real worker adapter is implemented. Add official platform OAuth/API adapters where available; otherwise require an authorized user upload. Never bypass DRM, authentication, or platform restrictions.

## Suggested next production milestones

1. Supabase Auth, RLS policies and migrations for projects, source videos, clips, jobs, settings and usage.
2. Resumable direct-to-object-storage uploads with file size/type validation.
3. Queue-backed worker (e.g. Redis/BullMQ) for FFmpeg, transcription, scene/silence detection and clip rendering.
4. Provider adapter interface, job progress events, retry/cancellation and observability.
5. Timeline editor with persisted trim points, captions, overlays and export presets.
6. Billing, quotas, retention policies and abuse controls.

## Security

- Never expose service-role keys or provider secrets to browser code.
- Validate ownership on every project/asset/job operation.
- Use signed upload/download URLs and short-lived worker credentials.
- Enforce per-user quotas, source allowlists, request limits and upload limits.
