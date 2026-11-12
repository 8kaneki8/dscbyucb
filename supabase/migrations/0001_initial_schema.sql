create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now()
);
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'Untitled project',
  status text not null default 'draft' check (status in ('draft','queued','processing','completed','failed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.source_videos (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  source_url text,
  source_platform text not null,
  storage_path text,
  duration_seconds numeric,
  authorization_confirmed boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.processing_jobs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  status text not null default 'queued' check (status in ('queued','processing','completed','failed','cancelled')),
  progress smallint not null default 0 check (progress between 0 and 100),
  stage text,
  error_message text,
  provider_job_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.generated_clips (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  job_id uuid references public.processing_jobs(id) on delete set null,
  title text,
  description text,
  start_seconds numeric not null check (start_seconds >= 0),
  end_seconds numeric not null check (end_seconds > start_seconds),
  aspect_ratio text not null default '9:16' check (aspect_ratio in ('9:16','16:9','1:1')),
  storage_path text,
  subtitles jsonb not null default '[]'::jsonb,
  hashtags text[] not null default '{}',
  created_at timestamptz not null default now()
);
create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  default_clip_duration integer not null default 30 check (default_clip_duration in (15,30,45,60,90)),
  default_aspect_ratio text not null default '9:16' check (default_aspect_ratio in ('9:16','16:9','1:1')),
  subtitle_style jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.subscription_plans (
  id text primary key,
  name text not null,
  monthly_clip_limit integer not null,
  features jsonb not null default '[]'::jsonb
);
create table if not exists public.usage_statistics (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  period_start date not null,
  clips_generated integer not null default 0,
  processing_minutes numeric not null default 0,
  unique(user_id, period_start)
);

alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.source_videos enable row level security;
alter table public.processing_jobs enable row level security;
alter table public.generated_clips enable row level security;
alter table public.user_settings enable row level security;
alter table public.subscription_plans enable row level security;
alter table public.usage_statistics enable row level security;

create policy "profile owner access" on public.profiles for all using (auth.uid() = id) with check (auth.uid() = id);
create policy "project owner access" on public.projects for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "source owner access" on public.source_videos for all using (exists (select 1 from public.projects p where p.id = project_id and p.user_id = auth.uid())) with check (exists (select 1 from public.projects p where p.id = project_id and p.user_id = auth.uid()));
create policy "job owner access" on public.processing_jobs for all using (exists (select 1 from public.projects p where p.id = project_id and p.user_id = auth.uid())) with check (exists (select 1 from public.projects p where p.id = project_id and p.user_id = auth.uid()));
create policy "clip owner access" on public.generated_clips for all using (exists (select 1 from public.projects p where p.id = project_id and p.user_id = auth.uid())) with check (exists (select 1 from public.projects p where p.id = project_id and p.user_id = auth.uid()));
create policy "settings owner access" on public.user_settings for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "plans readable" on public.subscription_plans for select using (true);
create policy "usage owner read" on public.usage_statistics for select using (auth.uid() = user_id);
