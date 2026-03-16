# Basera Database Design (New) — Auth + Registration

> Scope: **login and registration only**.
> This is a new relational design proposal for Supabase/Postgres and does not depend on the existing document-style `app_documents` approach.

## 1) Goals and Principles

- Support **email as the primary login/registration method**.
- Support **phone as optional** at registration time (`NULL` allowed) and verifiable later.
- Require phone during **profile setup completion** (phone presence required, verification can still happen later).
- Keep one fixed role per account: `renter` or `owner`.
- Keep registration resumable (user can verify email first and finish profile later).
- Keep PII secure, auditable, and RLS-protected.
- Align with Supabase architecture:
  - `auth.users` handles identity.
  - `public` schema stores app profile and onboarding state.
  - `storage` holds media/verification files.

---

## 2) High-Level Entity Model

1. `auth.users` (Supabase managed identity)
2. `public.user_accounts` (app-level account record, one per `auth.users.id`)
3. `public.user_roles` (single role assignment per user)
4. `public.registration_sessions` (tracks onboarding progress)
5. `public.email_verifications` (audit trail of email verification challenges)
6. `public.phone_verifications` (optional later phone verification audit)
7. `public.user_consents` (terms/privacy acceptance)
8. `public.profile_media` (references to uploaded profile assets)
9. `public.owner_identity_documents` (owner KYC metadata only)

---

## 3) SQL Schema (New Design)

```sql
-- Extensions
create extension if not exists pgcrypto;

-- ===== ENUMS =====
create type public.app_role as enum ('renter', 'owner');
create type public.registration_status as enum (
  'started',
  'email_verification_sent',
  'email_verified',
  'role_selected',
  'profile_incomplete',
  'completed',
  'cancelled',
  'expired'
);

create type public.email_verification_status as enum (
  'sent',
  'verified',
  'failed',
  'expired'
);

create type public.phone_verification_status as enum (
  'sent',
  'verified',
  'failed',
  'expired'
);

create type public.kyc_document_type as enum (
  'national_id_front',
  'national_id_back',
  'citizenship_front',
  'citizenship_back',
  'passport'
);

create type public.kyc_verification_status as enum (
  'pending',
  'approved',
  'rejected'
);

-- ===== TABLES =====

-- App account row (1:1 with auth.users)
-- NOTE: email is required + unique. phone_e164 is optional during initial signup,
-- but required before profile completion.
create table public.user_accounts (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  phone_e164 text,
  full_name text,
  profile_completed boolean not null default false,
  phone_verified boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint user_accounts_email_lower_chk
    check (email = lower(email)),
  constraint user_accounts_phone_format_chk
    check (phone_e164 is null or phone_e164 ~ '^\\+[1-9][0-9]{7,14}$'),
  constraint user_accounts_phone_verified_consistency_chk
    check (phone_verified = false or phone_e164 is not null),
  constraint user_accounts_profile_completion_phone_chk
    check (profile_completed = false or phone_e164 is not null)
);

create unique index user_accounts_email_uq on public.user_accounts (email);
create unique index user_accounts_phone_e164_uq
  on public.user_accounts (phone_e164)
  where phone_e164 is not null;

-- Exactly one role per user
create table public.user_roles (
  user_id uuid primary key references public.user_accounts(user_id) on delete cascade,
  role public.app_role not null,
  assigned_at timestamptz not null default now()
);

-- Registration progress tracker
create table public.registration_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(user_id) on delete cascade,
  status public.registration_status not null default 'started',
  selected_role public.app_role,
  started_at timestamptz not null default now(),
  email_verified_at timestamptz,
  completed_at timestamptz,
  expires_at timestamptz not null default (now() + interval '24 hours'),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index registration_sessions_user_id_idx on public.registration_sessions (user_id);
create index registration_sessions_status_idx on public.registration_sessions (status);

-- Email verification audit (do not store raw OTP/token)
create table public.email_verifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.user_accounts(user_id) on delete set null,
  email text not null,
  channel text not null default 'email',
  provider text,
  provider_request_id text,
  status public.email_verification_status not null,
  attempt_count int not null default 0,
  sent_at timestamptz,
  verified_at timestamptz,
  expires_at timestamptz,
  failure_reason text,
  created_at timestamptz not null default now(),

  constraint email_verifications_attempt_count_chk check (attempt_count >= 0),
  constraint email_verifications_email_lower_chk check (email = lower(email))
);

create index email_verifications_email_idx on public.email_verifications (email);
create index email_verifications_user_id_idx on public.email_verifications (user_id);
create index email_verifications_status_idx on public.email_verifications (status);

-- Optional phone verification audit (post-registration/later profile step)
create table public.phone_verifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.user_accounts(user_id) on delete set null,
  phone_e164 text not null,
  channel text not null default 'sms',
  provider text,
  provider_request_id text,
  status public.phone_verification_status not null,
  attempt_count int not null default 0,
  sent_at timestamptz,
  verified_at timestamptz,
  expires_at timestamptz,
  failure_reason text,
  created_at timestamptz not null default now(),

  constraint phone_verifications_attempt_count_chk check (attempt_count >= 0),
  constraint phone_verifications_phone_format_chk
    check (phone_e164 ~ '^\\+[1-9][0-9]{7,14}$')
);

create index phone_verifications_phone_idx on public.phone_verifications (phone_e164);
create index phone_verifications_user_id_idx on public.phone_verifications (user_id);
create index phone_verifications_status_idx on public.phone_verifications (status);

-- Legal acceptance records
create table public.user_consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(user_id) on delete cascade,
  consent_type text not null, -- e.g. 'terms_of_service', 'privacy_policy'
  consent_version text not null,
  accepted boolean not null,
  accepted_at timestamptz not null default now(),
  ip_address inet,
  user_agent text,

  constraint user_consents_type_chk check (consent_type in ('terms_of_service', 'privacy_policy'))
);

create index user_consents_user_idx on public.user_consents (user_id, consent_type);

-- Profile media pointers (actual file in Supabase Storage)
create table public.profile_media (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(user_id) on delete cascade,
  media_kind text not null, -- profile_photo, selfie, etc.
  storage_bucket text not null,
  storage_path text not null,
  mime_type text,
  file_size_bytes bigint,
  created_at timestamptz not null default now(),

  constraint profile_media_kind_chk check (media_kind in ('profile_photo', 'selfie')),
  constraint profile_media_file_size_chk check (file_size_bytes is null or file_size_bytes >= 0)
);

create unique index profile_media_user_kind_uq
  on public.profile_media (user_id, media_kind);

-- Owner KYC doc metadata
create table public.owner_identity_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(user_id) on delete cascade,
  document_type public.kyc_document_type not null,
  storage_bucket text not null,
  storage_path text not null,
  verification_status public.kyc_verification_status not null default 'pending',
  reviewed_by uuid,
  reviewed_at timestamptz,
  rejection_reason text,
  created_at timestamptz not null default now(),

  constraint owner_identity_review_chk
    check (
      (verification_status = 'pending' and reviewed_at is null and rejection_reason is null)
      or
      (verification_status = 'approved' and reviewed_at is not null)
      or
      (verification_status = 'rejected' and reviewed_at is not null and rejection_reason is not null)
    )
);

create index owner_identity_documents_user_idx
  on public.owner_identity_documents (user_id, verification_status);

-- ===== UPDATED_AT TRIGGER =====
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_user_accounts_updated_at
before update on public.user_accounts
for each row execute function public.set_updated_at();

create trigger trg_registration_sessions_updated_at
before update on public.registration_sessions
for each row execute function public.set_updated_at();
```

---

## 4) Role and Registration Rules

1. A valid app user must have one row in `user_accounts`.
2. Email is the primary credential and must be present + unique.
3. Phone is optional at signup (`phone_e164` nullable), but required to complete profile setup.
4. A valid completed registration must have one row in `user_roles`.
5. Role is immutable after first assignment (enforce via trigger in later phase).
6. Registration completes only when:
   - email is verified,
   - role selected,
   - required consents accepted,
   - minimal required profile fields provided (including phone number).
7. Verification events are append-only in `email_verifications` and `phone_verifications` for auditing.

---

## 5) Suggested Supabase Storage Buckets / Folder Layout

Use private buckets unless explicitly needed as public.

### Bucket: `basera-profile-media` (private)

Folder structure:

- `users/{user_id}/profile-photo/{uuid}.jpg`
- `users/{user_id}/selfie/{uuid}.jpg`

### Bucket: `basera-kyc-documents` (private)

Folder structure:

- `owners/{user_id}/national-id-front/{uuid}.jpg`
- `owners/{user_id}/national-id-back/{uuid}.jpg`
- `owners/{user_id}/citizenship-front/{uuid}.jpg`
- `owners/{user_id}/citizenship-back/{uuid}.jpg`
- `owners/{user_id}/passport/{uuid}.jpg`

### (Optional) Bucket: `basera-temp-auth` (private, lifecycle cleanup)

For temporary pre-verification uploads if needed:

- `pending/{registration_session_id}/{file}`

---

## 6) RLS (Row-Level Security) Baseline

Enable RLS on all `public.*` tables above.

- Users can `select/update` only their own rows (`user_id = auth.uid()`).
- Users can insert only rows tied to `auth.uid()`.
- Admin/service role can manage moderation/review rows.
- `owner_identity_documents.reviewed_by/reviewed_at` should only be writable by service/admin.

Example baseline policy pattern:

```sql
alter table public.user_accounts enable row level security;

create policy user_accounts_self_read
on public.user_accounts
for select
using (auth.uid() = user_id);

create policy user_accounts_self_update
on public.user_accounts
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy user_accounts_self_insert
on public.user_accounts
for insert
with check (auth.uid() = user_id);
```

Apply same pattern to:

- `user_roles`
- `registration_sessions`
- `email_verifications` (read own; writes often via edge function/service role)
- `phone_verifications` (read own; writes often via edge function/service role)
- `user_consents`
- `profile_media`
- `owner_identity_documents` (read own only, write with stricter constraints)

---

## 7) Login + Registration Flow Mapping

### A. New user registration (email primary)

1. Client triggers Supabase email signup / magic link / email OTP (project decision).
2. Insert/Upsert `user_accounts` with `email` once `auth.users` row exists.
3. Create `registration_sessions` row (`status='email_verification_sent'`).
4. Log challenge in `email_verifications` (`status='sent'`).
5. On successful email verification:
   - set `email_verifications.status='verified'`,
   - set `registration_sessions.status='email_verified'`.
6. User selects role:
   - set `registration_sessions.selected_role`, status `role_selected`.
7. User submits profile + consent:
   - write `user_roles`, `user_consents`, optional `profile_media`, optional `owner_identity_documents`.
   - require `user_accounts.phone_e164` before setting `profile_completed=true`.
8. Mark session `completed`, set `user_accounts.profile_completed=true`.

### B. Existing user login (email primary)

1. Sign in with email + password (or email OTP/magic link).
2. Read `user_accounts` + `user_roles`.
3. If `profile_completed=false`, route to profile completion.
4. Else route to role dashboard.

### C. Optional phone verification later

1. User enters phone number in profile.
2. Trigger SMS OTP and record row in `phone_verifications` with `status='sent'`.
3. After successful verification, set `phone_verifications.status='verified'` and update:
   - `user_accounts.phone_e164 = <verified number>`
   - `user_accounts.phone_verified = true`

> Note: phone verification is optional for profile completion in this phase; only phone presence is required.

---

## 8) Setup Guidance (Step-by-Step)

1. **Create Supabase project** (dev first).
2. **Enable Email Auth (primary)**:
   - Authentication → Providers → Email.
   - Decide mode: password-based and/or OTP/magic-link.
3. **Enable Phone Auth (optional, later verification)**:
   - Authentication → Providers → Phone.
   - Configure SMS provider and templates.
4. **Run schema SQL** (section 3) in SQL editor or migration.
5. **Enable and apply RLS policies** (section 6).
6. **Create storage buckets**:
   - `basera-profile-media` (private)
   - `basera-kyc-documents` (private)
   - optional `basera-temp-auth` (private)
7. **Add storage policies**:
   - Users can access only folder paths with their own `auth.uid()`.
8. **Create edge function(s)** (recommended):
   - email verification event logging into `email_verifications`
   - phone OTP event logging into `phone_verifications`
   - KYC moderation updates (admin flow)
9. **Configure iOS environment**:
   - `BASERA_SUPABASE_URL`
   - `BASERA_SUPABASE_ANON_KEY`
10. **Smoke test**:
   - New email registration
   - Role selection
   - Profile photo upload
   - Owner ID upload
   - Optional phone verification
   - Logout/login recovery

---

## 9) Notes / Non-Goals for This Phase

- No listings/tenancy/billing tables included yet.
- No payment integration schema yet.
- No full admin moderation schema beyond KYC metadata pointers.
- This design is intentionally scoped to **auth + registration foundation**.
