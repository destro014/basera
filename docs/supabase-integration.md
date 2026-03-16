# Supabase Integration Setup

This project supports two runtime modes:

- Supabase-backed mode (default)
- mock mode (`BASERA_USE_MOCK_SERVICES=1`)

## Required Environment Variables

- `BASERA_SUPABASE_URL`
- `BASERA_SUPABASE_ANON_KEY`

Optional:

- `BASERA_SUPABASE_DOCUMENTS_TABLE` (default: `app_documents`)
- `BASERA_SUPABASE_STORAGE_BUCKET` (default: `basera-media`)
- `BASERA_SUPABASE_DEBUG=1`

## Suggested Setup Steps

1. Create a Supabase project per environment (dev/staging/prod).
2. Create document table and indexes from `docs/supabase-schema.md`.
3. Add iOS environment variables in your Xcode run scheme.
4. Validate auth + listing + profile + notification read/write flows.

## iOS + Supabase Quickstart (Xcode)

1. Open **Product > Scheme > Edit Scheme...**.
2. Select **Run > Arguments**.
3. Under **Environment Variables**, add:
   - `BASERA_SUPABASE_URL` = your project URL (for example `https://YOUR_PROJECT_REF.supabase.co`)
   - `BASERA_SUPABASE_ANON_KEY` = your Supabase anon/public key
4. (Optional) Add:
   - `BASERA_SUPABASE_DEBUG` = `1` to print Supabase auth request status in Xcode logs.
   - `BASERA_USE_MOCK_SERVICES` = `1` when you want to run fully mocked flows without backend.

> Note: the app reads these values from either scheme environment variables or `Info.plist` keys with the same names.

## Supabase Dashboard Setup Checklist

### 1) Auth provider

- Go to **Authentication > Providers > Email** and enable email sign-in.
- Keep **Confirm email** enabled if you want OTP verification during registration (matches Basera auth flow).

### 2) Redirect URL (for recovery and email flows)

- Add your app deep link URL in **Authentication > URL Configuration**.
- For simulator testing, include local/development URLs you use for auth links.

### 3) Database table for app documents

Run SQL in Supabase SQL Editor:

```sql
create table if not exists public.app_documents (
  collection text not null,
  id text not null,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (collection, id)
);

create index if not exists app_documents_collection_idx
  on public.app_documents (collection);
```

If you use a custom table name, set `BASERA_SUPABASE_DOCUMENTS_TABLE` to match.

### 4) RLS policies (minimum to start)

For first integration, you can use permissive policies in development only, then tighten later:

```sql
alter table public.app_documents enable row level security;

create policy "dev allow read"
on public.app_documents
for select
using (true);

create policy "dev allow insert"
on public.app_documents
for insert
with check (true);

create policy "dev allow update"
on public.app_documents
for update
using (true)
with check (true);
```

## Common Failure Modes

- **Immediate auth error after entering email:**
  - missing `BASERA_SUPABASE_URL` or `BASERA_SUPABASE_ANON_KEY` in scheme.
  - email auth provider disabled on Supabase.
- **`invalid login credentials`:** wrong password or account not created yet.
- **OTP errors:** email confirmation/provider configuration mismatch.
- **403/401 from REST:** RLS/policies not configured for `app_documents`.

## Notes

- Current app repositories use a document-style JSON payload model on Supabase.
- Keep feature modules on repository interfaces; avoid direct backend calls from views.
