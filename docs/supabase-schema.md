# Supabase Schema

## Services

- Supabase Auth (email/password flows)
- Supabase Database (document-style tables)
- Supabase Storage
- Supabase Realtime / notifications data fanout

---

## Document Table Pattern

Basera currently uses a document-style table in Supabase for fast feature iteration.

Recommended table:

- `app_documents`

Recommended columns:

- `collection` (text)
- `id` (text)
- `payload` (jsonb)
- `updated_at` (timestamptz)

Unique key:

- (`collection`, `id`)

---

## Collections Stored In `payload`

- `user_profiles`
- `renter_profiles`
- `owner_profiles`
- `listings`
- `notifications`
- `remote_config`

---

## User Role Model

User accounts must store exactly one role:

- `renter`
- `owner`

No dual-role account and no role switching after login.
