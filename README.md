# Qlink — Safety & Tracking App v2.4.0

> A dual-role safety system connecting **Guardians** and **Wearers** through real-time tracking, emergency alerts, medical vaults, and QR-based emergency ID.

---

## 🔷 Architecture

```
lib/
├── core/
│   ├── constants/        # App constants, Supabase keys
│   ├── router/           # GoRouter navigation
│   ├── theme/            # Design system (colors, typography, gradients)
│   └── widgets/          # Shared reusable widgets
├── features/
│   ├── auth/
│   │   └── screens/      # Splash, Role Selection, Sign In, Sign Up
│   ├── guardian/
│   │   └── screens/      # Home, Map, Vault, Settings, Add Profile, Geofence, Alerts, QR Scanner
│   └── wearer/
│       └── screens/      # Home, Health, QR Code, Find Bracelet, Settings
├── models/               # All data models
├── services/
│   ├── supabase_service.dart   # Full CRUD service layer
│   └── providers.dart          # Riverpod state providers
└── main.dart
```

---

## 🔷 Design System

| Token | Value |
|-------|-------|
| Primary Navy | `#273469` |
| Primary Blue | `#1758E7` |
| Secondary Blue | `#0066CC` |
| Success | `#01D47B` |
| Error | `#E03232` |
| Button Gradient | `#0066CC → #273469` |
| Heading Font | Century Gothic |
| Body Font | Roboto |

---

## 🔷 Supabase Schema

### Tables
- `users` — id, email, full_name, role, avatar_url
- `profiles` — id, guardian_id, name, relationship, birth_year, blood_type, allergies, conditions, safety_notes
- `emergency_contacts` — id, profile_id, phone, is_primary
- `devices` — id, profile_id, code, type, connected, battery_level
- `bracelets` — id, code, type, battery_level (admin-managed)
- `locations` — id, profile_id, latitude, longitude, timestamp
- `alerts` — id, profile_id, type, message, is_read, timestamp
- `vault` — id, profile_id, file_url, file_name, file_type, uploaded_at

### Storage Buckets
- `vault` — medical files per profile (private)
- `avatars` — user/profile avatars (public)

---

## 🔷 Getting Started

### 1. Prerequisites
- Flutter SDK ≥ 3.3.0
- Android Studio / Xcode
- Supabase project at `https://vveftffbvwptlsqgeygp.supabase.co`

### 2. Setup Supabase Tables

Run this SQL in your Supabase SQL editor:

```sql
-- Users table
create table if not exists public.users (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  full_name text,
  role text default 'guardian',
  avatar_url text,
  created_at timestamptz default now()
);
alter table public.users enable row level security;
create policy "Users can manage own row" on public.users
  using (auth.uid() = id) with check (auth.uid() = id);

-- Profiles table
create table if not exists public.profiles (
  id uuid default gen_random_uuid() primary key,
  guardian_id uuid references public.users(id) on delete cascade,
  name text not null,
  relationship text,
  birth_year int,
  blood_type text,
  allergies text,
  conditions text,
  safety_notes text,
  avatar_url text,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "Guardians manage own profiles" on public.profiles
  using (auth.uid() = guardian_id) with check (auth.uid() = guardian_id);

-- Emergency contacts table
create table if not exists public.emergency_contacts (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade,
  phone text not null,
  is_primary boolean default false,
  created_at timestamptz default now()
);
alter table public.emergency_contacts enable row level security;
create policy "Guardians manage emergency contacts" on public.emergency_contacts
  using (exists (
    select 1 from public.profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));

-- Bracelets table (admin managed)
create table if not exists public.bracelets (
  id uuid default gen_random_uuid() primary key,
  code text unique not null,
  type text default 'Qlink Bracelet',
  battery_level int default 85,
  is_assigned boolean default false,
  created_at timestamptz default now()
);
alter table public.bracelets enable row level security;
create policy "Anyone can read bracelets" on public.bracelets for select using (true);

-- Devices table
create table if not exists public.devices (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade,
  code text,
  type text default 'Qlink Bracelet',
  connected boolean default false,
  battery_level int default 85,
  last_sync timestamptz,
  last_lat double precision,
  last_lng double precision,
  created_at timestamptz default now()
);
alter table public.devices enable row level security;
create policy "Guardians manage devices" on public.devices
  using (exists (
    select 1 from public.profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));

-- Locations table
create table if not exists public.locations (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  timestamp timestamptz default now()
);
alter table public.locations enable row level security;
create policy "Guardians read locations" on public.locations
  using (exists (
    select 1 from public.profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));

-- Alerts table
create table if not exists public.alerts (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade,
  type text not null default 'SOS',
  message text,
  is_read boolean default false,
  timestamp timestamptz default now()
);
alter table public.alerts enable row level security;
create policy "Guardians read alerts" on public.alerts
  using (exists (
    select 1 from public.profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));
create policy "Anyone insert alerts" on public.alerts for insert with check (true);

-- Vault table
create table if not exists public.vault (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade,
  file_url text not null,
  file_name text,
  file_type text,
  uploaded_at timestamptz default now()
);
alter table public.vault enable row level security;
create policy "Guardians manage vault" on public.vault
  using (exists (
    select 1 from public.profiles p
    where p.id = profile_id and p.guardian_id = auth.uid()
  ));

-- Enable Realtime
alter publication supabase_realtime add table public.alerts;
alter publication supabase_realtime add table public.locations;

-- Storage buckets
insert into storage.buckets (id, name, public) values ('vault', 'vault', false) on conflict do nothing;
insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true) on conflict do nothing;

-- Sample bracelet codes (for testing)
insert into public.bracelets (code, type) values
  ('QLINK-PULSE-8A3F2E', 'Qlink Smart Bracelet "Pulse"'),
  ('QLINK-NOVA-12B3OE8', 'Qlink Smart Bracelet "Nova"'),
  ('QLINK-BASIC-001', 'Qlink Bracelet'),
  ('QLINK-TEST-0001', 'Qlink Bracelet')
on conflict do nothing;
```

### 3. Install & Run

```bash
flutter pub get
flutter run
```

---

## 🔷 Features

### Guardian Role
- ✅ Create & manage patient profiles (3-step wizard)
- ✅ Connect Qlink bracelets by code
- ✅ Real-time GPS map tracking (OpenStreetMap)
- ✅ Geofencing zone setup
- ✅ SOS & geofence alert notifications
- ✅ Medical vault per profile (upload/view files)
- ✅ QR code scanner
- ✅ Settings (edit profile, change password, switch role)

### Wearer Role
- ✅ SOS emergency button (press & hold)
- ✅ Health monitoring (heart rate simulation)
- ✅ Emergency QR code display
- ✅ Find My Bracelet with signal indicator
- ✅ Bracelet connection status & battery
- ✅ Settings (edit profile, switch role)

---

## 🔷 State Management
- **Riverpod** for all state
- `AuthNotifier` — auth state & user session
- `ProfilesNotifier` — guardian profiles CRUD
- `AlertsNotifier` — alerts list
- `FutureProvider` — vault files, individual profile

---

## 🔷 Navigation
- **GoRouter** with shell routes for tab navigation
- Guardian shell: Home / Map / [+FAB] / Vault / Settings
- Wearer shell: Home / Health / QR Code / Settings
