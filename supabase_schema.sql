-- ============================================================
-- QLINK SUPABASE DATABASE SCHEMA
-- Run this entire file in your Supabase SQL Editor
-- Project: https://vveftffbvwptlsqgeygp.supabase.co
-- ============================================================

-- ─── USERS TABLE ─────────────────────────────────────────────
create table if not exists public.users (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  full_name text,
  role text not null default 'guardian',
  avatar_url text,
  created_at timestamptz default now() not null
);

alter table public.users enable row level security;

create policy "Users: select own row" on public.users
  for select using (auth.uid() = id);

create policy "Users: insert own row" on public.users
  for insert with check (auth.uid() = id);

create policy "Users: update own row" on public.users
  for update using (auth.uid() = id);

-- ─── PROFILES TABLE ──────────────────────────────────────────
create table if not exists public.profiles (
  id uuid default gen_random_uuid() primary key,
  guardian_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  relationship text,
  birth_year int,
  blood_type text,
  allergies text,
  conditions text,
  safety_notes text,
  avatar_url text,
  is_active boolean not null default true,
  created_at timestamptz default now() not null
);

alter table public.profiles enable row level security;

create policy "Profiles: guardian full access" on public.profiles
  using (auth.uid() = guardian_id)
  with check (auth.uid() = guardian_id);

-- ─── EMERGENCY CONTACTS TABLE ────────────────────────────────
create table if not exists public.emergency_contacts (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  phone text not null,
  is_primary boolean not null default false,
  created_at timestamptz default now() not null
);

alter table public.emergency_contacts enable row level security;

create policy "Emergency contacts: guardian access" on public.emergency_contacts
  using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  );

-- ─── BRACELETS TABLE (Admin managed) ─────────────────────────
create table if not exists public.bracelets (
  id uuid default gen_random_uuid() primary key,
  code text unique not null,
  type text not null default 'Qlink Bracelet',
  battery_level int default 85,
  is_assigned boolean not null default false,
  assigned_to uuid references public.profiles(id),
  created_at timestamptz default now() not null
);

alter table public.bracelets enable row level security;

-- Anyone authenticated can read bracelets (needed for code lookup)
create policy "Bracelets: authenticated read" on public.bracelets
  for select using (auth.role() = 'authenticated');

-- Only service role can insert/update bracelets
create policy "Bracelets: service role write" on public.bracelets
  for all using (auth.role() = 'service_role');

-- ─── DEVICES TABLE ───────────────────────────────────────────
create table if not exists public.devices (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  code text,
  type text default 'Qlink Bracelet',
  connected boolean not null default false,
  battery_level int default 85,
  last_sync timestamptz,
  last_lat double precision,
  last_lng double precision,
  created_at timestamptz default now() not null
);

alter table public.devices enable row level security;

create policy "Devices: guardian access" on public.devices
  using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  );

-- ─── LOCATIONS TABLE ─────────────────────────────────────────
create table if not exists public.locations (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  timestamp timestamptz not null default now()
);

alter table public.locations enable row level security;

create policy "Locations: guardian read" on public.locations
  for select using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  );

create policy "Locations: insert" on public.locations
  for insert with check (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  );

-- ─── ALERTS TABLE ────────────────────────────────────────────
create table if not exists public.alerts (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  type text not null default 'SOS', -- SOS | GEOFENCE
  message text,
  is_read boolean not null default false,
  timestamp timestamptz not null default now()
);

alter table public.alerts enable row level security;

create policy "Alerts: guardian read" on public.alerts
  for select using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  );

-- Allow anyone authenticated to insert an alert (wearer SOS)
create policy "Alerts: authenticated insert" on public.alerts
  for insert with check (auth.role() = 'authenticated');

create policy "Alerts: guardian update" on public.alerts
  for update using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  );

-- ─── VAULT TABLE ─────────────────────────────────────────────
create table if not exists public.vault (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  file_url text not null,
  file_name text,
  file_type text,
  uploaded_at timestamptz not null default now()
);

alter table public.vault enable row level security;

create policy "Vault: guardian full access" on public.vault
  using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  );

-- ─── GEOFENCE ZONES TABLE ────────────────────────────────────
create table if not exists public.geofence_zones (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  center_lat double precision not null,
  center_lng double precision not null,
  radius_meters double precision not null default 500,
  label text,
  is_active boolean not null default true,
  created_at timestamptz default now() not null
);

alter table public.geofence_zones enable row level security;

create policy "Geofence: guardian access" on public.geofence_zones
  using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.guardian_id = auth.uid()
    )
  );

-- ─── ENABLE REALTIME ─────────────────────────────────────────
alter publication supabase_realtime add table public.alerts;
alter publication supabase_realtime add table public.locations;
alter publication supabase_realtime add table public.devices;

-- ─── STORAGE BUCKETS ─────────────────────────────────────────
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'vault',
  'vault',
  false,
  52428800, -- 50MB
  array['image/jpeg','image/png','image/gif','application/pdf','application/octet-stream']
) on conflict (id) do nothing;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'avatars',
  'avatars',
  true,
  5242880, -- 5MB
  array['image/jpeg','image/png','image/webp']
) on conflict (id) do nothing;

-- Storage policies for vault
create policy "Vault storage: guardian access"
  on storage.objects for all
  using (
    bucket_id = 'vault' and auth.role() = 'authenticated'
  )
  with check (
    bucket_id = 'vault' and auth.role() = 'authenticated'
  );

-- Storage policies for avatars
create policy "Avatars storage: public read"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "Avatars storage: authenticated write"
  on storage.objects for insert
  with check (bucket_id = 'avatars' and auth.role() = 'authenticated');

create policy "Avatars storage: own update"
  on storage.objects for update
  using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

-- ─── SEED DATA (Test bracelet codes) ─────────────────────────
insert into public.bracelets (code, type, battery_level) values
  ('QLINK-PULSE-8A3F2E', 'Qlink Smart Bracelet "Pulse"', 85),
  ('QLINK-NOVA-12B3OE8', 'Qlink Smart Bracelet "Nova"', 92),
  ('QLINK-BASIC-001', 'Qlink Bracelet', 78),
  ('QLINK-BASIC-002', 'Qlink Bracelet', 65),
  ('QLINK-TEST-0001', 'Qlink Bracelet', 100),
  ('QLINK-TEST-0002', 'Qlink Bracelet', 45)
on conflict (code) do nothing;

-- ─── HELPER FUNCTION: Auto-create user profile on signup ─────
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

-- Trigger to auto-create user row on auth signup
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- DONE! Your Qlink database is ready.
-- Test bracelet codes: QLINK-PULSE-8A3F2E, QLINK-NOVA-12B3OE8
-- ============================================================
