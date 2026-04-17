-- ============================================================
-- QLINK APP - SAFE SETUP (Separate from website tables)
-- Uses prefix "app_" to avoid conflict with existing tables
-- Run this in Supabase SQL Editor
-- ============================================================

-- ─── APP USERS ────────────────────────────────────────────────
create table if not exists public.app_users (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  full_name text,
  role text not null default 'guardian',
  avatar_url text,
  created_at timestamptz default now() not null
);
alter table public.app_users enable row level security;
create policy "app_users_policy" on public.app_users
  using (auth.uid() = id) with check (auth.uid() = id);

-- ─── APP PROFILES (patients) ──────────────────────────────────
create table if not exists public.app_profiles (
  id uuid default gen_random_uuid() primary key,
  guardian_id uuid not null references public.app_users(id) on delete cascade,
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
alter table public.app_profiles enable row level security;
create policy "app_profiles_policy" on public.app_profiles
  using (auth.uid() = guardian_id) with check (auth.uid() = guardian_id);

-- ─── EMERGENCY CONTACTS ───────────────────────────────────────
create table if not exists public.app_emergency_contacts (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.app_profiles(id) on delete cascade,
  phone text not null,
  is_primary boolean not null default false,
  created_at timestamptz default now() not null
);
alter table public.app_emergency_contacts enable row level security;
create policy "app_emergency_contacts_policy" on public.app_emergency_contacts
  using (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));

-- ─── BRACELETS (admin managed) ────────────────────────────────
create table if not exists public.app_bracelets (
  id uuid default gen_random_uuid() primary key,
  code text unique not null,
  type text not null default 'Qlink Bracelet',
  battery_level int default 85,
  is_assigned boolean not null default false,
  created_at timestamptz default now() not null
);
alter table public.app_bracelets enable row level security;
create policy "app_bracelets_read" on public.app_bracelets
  for select using (auth.role() = 'authenticated');

-- ─── DEVICES ──────────────────────────────────────────────────
create table if not exists public.app_devices (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.app_profiles(id) on delete cascade,
  code text,
  type text default 'Qlink Bracelet',
  connected boolean not null default false,
  battery_level int default 85,
  last_sync timestamptz,
  last_lat double precision,
  last_lng double precision,
  created_at timestamptz default now() not null
);
alter table public.app_devices enable row level security;
create policy "app_devices_policy" on public.app_devices
  using (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));

-- ─── LOCATIONS ────────────────────────────────────────────────
create table if not exists public.app_locations (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.app_profiles(id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  timestamp timestamptz not null default now()
);
alter table public.app_locations enable row level security;
create policy "app_locations_policy" on public.app_locations
  using (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));

-- ─── ALERTS ───────────────────────────────────────────────────
create table if not exists public.app_alerts (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.app_profiles(id) on delete cascade,
  type text not null default 'SOS',
  message text,
  is_read boolean not null default false,
  timestamp timestamptz not null default now()
);
alter table public.app_alerts enable row level security;
create policy "app_alerts_select" on public.app_alerts
  for select using (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));
create policy "app_alerts_insert" on public.app_alerts
  for insert with check (auth.role() = 'authenticated');
create policy "app_alerts_update" on public.app_alerts
  for update using (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));

-- ─── VAULT ────────────────────────────────────────────────────
create table if not exists public.app_vault (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid not null references public.app_profiles(id) on delete cascade,
  file_url text not null,
  file_name text,
  file_type text,
  uploaded_at timestamptz not null default now()
);
alter table public.app_vault enable row level security;
create policy "app_vault_policy" on public.app_vault
  using (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.app_profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));

-- ─── Enable Realtime ──────────────────────────────────────────
alter publication supabase_realtime add table public.app_alerts;
alter publication supabase_realtime add table public.app_locations;

-- ─── Storage Buckets ──────────────────────────────────────────
insert into storage.buckets (id, name, public, file_size_limit)
values ('app-vault', 'app-vault', false, 52428800)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public, file_size_limit)
values ('app-avatars', 'app-avatars', true, 5242880)
on conflict (id) do nothing;

-- ─── Seed test bracelet codes ─────────────────────────────────
insert into public.app_bracelets (code, type, battery_level) values
  ('QLINK-PULSE-8A3F2E', 'Qlink Smart Bracelet "Pulse"', 85),
  ('QLINK-NOVA-12B3OE8', 'Qlink Smart Bracelet "Nova"', 92),
  ('QLINK-BASIC-001', 'Qlink Bracelet', 78),
  ('QLINK-TEST-0001', 'Qlink Bracelet', 100)
on conflict (code) do nothing;

-- ─── Auto-create app_users row on signup ─────────────────────
create or replace function public.handle_app_new_user()
returns trigger as $$
begin
  insert into public.app_users (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'role', 'guardian')
  )
  on conflict (id) do update
    set
      email = excluded.email,
      full_name = coalesce(excluded.full_name, public.app_users.full_name),
      role = coalesce(excluded.role, public.app_users.role);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_app_user_created on auth.users;
create trigger on_auth_app_user_created
  after insert on auth.users
  for each row execute procedure public.handle_app_new_user();

-- ============================================================
-- DONE! All app tables created with "app_" prefix.
-- Your website tables are completely untouched.
-- ============================================================
