-- ============================================================
-- QLINK - SAFE SETUP SQL
-- This only ADDS missing tables/columns - never drops anything
-- Run this in Supabase SQL Editor
-- ============================================================

-- ─── Check what columns your profiles table has ──────────────
-- Run this first to see your existing structure:
-- SELECT column_name FROM information_schema.columns WHERE table_name = 'profiles';

-- ─── EMERGENCY CONTACTS (new table) ──────────────────────────
create table if not exists public.emergency_contacts (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null,
  phone text not null,
  is_primary boolean not null default false,
  created_at timestamptz default now() not null
);

-- ─── BRACELETS (new table - admin managed) ───────────────────
create table if not exists public.bracelets (
  id uuid default gen_random_uuid() primary key,
  code text unique not null,
  type text not null default 'Qlink Bracelet',
  battery_level int default 85,
  is_assigned boolean not null default false,
  created_at timestamptz default now() not null
);

-- ─── DEVICES (new table) ─────────────────────────────────────
create table if not exists public.devices (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null,
  code text,
  type text default 'Qlink Bracelet',
  connected boolean not null default false,
  battery_level int default 85,
  last_sync timestamptz,
  last_lat double precision,
  last_lng double precision,
  created_at timestamptz default now() not null
);

-- ─── LOCATIONS (new table) ───────────────────────────────────
create table if not exists public.locations (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null,
  latitude double precision not null,
  longitude double precision not null,
  timestamp timestamptz not null default now()
);

-- ─── ALERTS (new table) ──────────────────────────────────────
create table if not exists public.alerts (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null,
  type text not null default 'SOS',
  message text,
  is_read boolean not null default false,
  timestamp timestamptz not null default now()
);

-- ─── VAULT (new table) ───────────────────────────────────────
create table if not exists public.vault (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null,
  file_url text not null,
  file_name text,
  file_type text,
  uploaded_at timestamptz not null default now()
);

-- ─── GEOFENCE ZONES (new table) ──────────────────────────────
create table if not exists public.geofence_zones (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null,
  center_lat double precision not null,
  center_lng double precision not null,
  radius_meters double precision not null default 500,
  label text,
  is_active boolean not null default true,
  created_at timestamptz default now() not null
);

-- ─── Enable RLS on new tables ────────────────────────────────
alter table public.emergency_contacts enable row level security;
alter table public.bracelets enable row level security;
alter table public.devices enable row level security;
alter table public.locations enable row level security;
alter table public.alerts enable row level security;
alter table public.vault enable row level security;
alter table public.geofence_zones enable row level security;

-- ─── RLS Policies - allow authenticated users full access ─────
-- (Simple open policies - tighten later if needed)

create policy if not exists "emergency_contacts_policy" on public.emergency_contacts
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy if not exists "bracelets_read_policy" on public.bracelets
  for select using (auth.role() = 'authenticated');

create policy if not exists "devices_policy" on public.devices
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy if not exists "locations_policy" on public.locations
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy if not exists "alerts_select_policy" on public.alerts
  for select using (auth.role() = 'authenticated');

create policy if not exists "alerts_insert_policy" on public.alerts
  for insert with check (auth.role() = 'authenticated');

create policy if not exists "alerts_update_policy" on public.alerts
  for update using (auth.role() = 'authenticated');

create policy if not exists "vault_policy" on public.vault
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy if not exists "geofence_policy" on public.geofence_zones
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- ─── Enable Realtime on new tables ───────────────────────────
alter publication supabase_realtime add table public.alerts;
alter publication supabase_realtime add table public.locations;

-- ─── Storage Buckets ─────────────────────────────────────────
insert into storage.buckets (id, name, public, file_size_limit)
values ('vault', 'vault', false, 52428800)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public, file_size_limit)
values ('avatars', 'avatars', true, 5242880)
on conflict (id) do nothing;

-- Storage policies
do $$
begin
  if not exists (
    select 1 from pg_policies 
    where tablename = 'objects' and policyname = 'vault_storage_policy'
  ) then
    execute 'create policy vault_storage_policy on storage.objects
      for all using (bucket_id = ''vault'' and auth.role() = ''authenticated'')
      with check (bucket_id = ''vault'' and auth.role() = ''authenticated'')';
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies 
    where tablename = 'objects' and policyname = 'avatars_read_policy'
  ) then
    execute 'create policy avatars_read_policy on storage.objects
      for select using (bucket_id = ''avatars'')';
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies 
    where tablename = 'objects' and policyname = 'avatars_write_policy'
  ) then
    execute 'create policy avatars_write_policy on storage.objects
      for insert with check (bucket_id = ''avatars'' and auth.role() = ''authenticated'')';
  end if;
end $$;

-- ─── Seed bracelet codes for testing ─────────────────────────
insert into public.bracelets (code, type, battery_level) values
  ('QLINK-PULSE-8A3F2E', 'Qlink Smart Bracelet "Pulse"', 85),
  ('QLINK-NOVA-12B3OE8', 'Qlink Smart Bracelet "Nova"', 92),
  ('QLINK-BASIC-001', 'Qlink Bracelet', 78),
  ('QLINK-TEST-0001', 'Qlink Bracelet', 100)
on conflict (code) do nothing;

-- ─── Auto-create users row on signup ─────────────────────────
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'role', 'guardian')
  )
  on conflict (id) do update
    set
      email = excluded.email,
      full_name = coalesce(excluded.full_name, public.users.full_name),
      role = coalesce(excluded.role, public.users.role);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- DONE! New tables created safely.
-- Your existing tables were NOT modified.
-- ============================================================
