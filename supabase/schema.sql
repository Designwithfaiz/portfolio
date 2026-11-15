-- Run this in Supabase SQL Editor after creating your project.
-- 1) Create an admin user in Authentication > Users (invite/create user).
-- 2) Copy that user's UUID and replace YOUR_AUTH_USER_UUID below.
create extension if not exists pgcrypto;
create table if not exists public.portfolio_admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
insert into public.portfolio_admins(user_id) values ('YOUR_AUTH_USER_UUID')
on conflict do nothing;
create or replace function public.is_portfolio_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.portfolio_admins where user_id = auth.uid()) $$;
revoke all on function public.is_portfolio_admin() from public;
grant execute on function public.is_portfolio_admin() to authenticated, anon;
create table if not exists public.portfolio_projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null check (category in ('AI Video','Reels','Long-form')),
  description text default '',
  video_url text not null,
  thumbnail_url text,
  published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.portfolio_admins enable row level security;
alter table public.portfolio_projects enable row level security;
drop policy if exists "Admins can read admin list" on public.portfolio_admins;
create policy "Admins can read admin list" on public.portfolio_admins for select to authenticated using (public.is_portfolio_admin());
drop policy if exists "Public can view published portfolio projects" on public.portfolio_projects;
create policy "Public can view published portfolio projects" on public.portfolio_projects for select to anon, authenticated using (published or public.is_portfolio_admin());
drop policy if exists "Admins manage portfolio projects" on public.portfolio_projects;
create policy "Admins manage portfolio projects" on public.portfolio_projects for all to authenticated using (public.is_portfolio_admin()) with check (public.is_portfolio_admin());
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('portfolio-videos','portfolio-videos',true,1073741824,array['video/mp4','video/quicktime','video/webm'])
on conflict (id) do update set public=true,file_size_limit=1073741824,allowed_mime_types=array['video/mp4','video/quicktime','video/webm'];
drop policy if exists "Public read portfolio video files" on storage.objects;
create policy "Public read portfolio video files" on storage.objects for select to anon, authenticated using (bucket_id='portfolio-videos');
drop policy if exists "Admins upload portfolio video files" on storage.objects;
create policy "Admins upload portfolio video files" on storage.objects for insert to authenticated with check (bucket_id='portfolio-videos' and public.is_portfolio_admin());
drop policy if exists "Admins update portfolio video files" on storage.objects;
create policy "Admins update portfolio video files" on storage.objects for update to authenticated using (bucket_id='portfolio-videos' and public.is_portfolio_admin()) with check (bucket_id='portfolio-videos' and public.is_portfolio_admin());
drop policy if exists "Admins delete portfolio video files" on storage.objects;
create policy "Admins delete portfolio video files" on storage.objects for delete to authenticated using (bucket_id='portfolio-videos' and public.is_portfolio_admin());
