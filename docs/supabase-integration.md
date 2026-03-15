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

## Notes

- Current app repositories use a document-style JSON payload model on Supabase.
- Keep feature modules on repository interfaces; avoid direct backend calls from views.
