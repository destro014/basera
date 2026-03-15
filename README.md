# Basera

**Basera** is a rental management mobile application that connects renters with property owners and manages the full rental lifecycle — from property discovery to agreements, billing, payments, and move-out.

The platform is designed initially for **Nepal** and built using **SwiftUI** with a **Supabase backend**.

Domain: **basera.app**

---

# Vision

Basera simplifies rental management by allowing:

- renters to easily discover rental spaces
- owners to manage properties and tenants digitally
- both parties to manage agreements, bills, and payments in one place

Basera acts as a **digital record platform for rental agreements**, not a legal enforcement system.

---

# Platforms

Basera supports:

- iPhone
- iPad

Technology stack:

- SwiftUI
- Supabase Auth
- Supabase Postgres (JSON document style tables)
- Supabase Storage
- Supabase Realtime / notification data fanout

Development environment:

- Xcode
- Swift

---

# Core Features

## Authentication

- Phone number login
- OTP verification

---

## Profiles

Users register as exactly one role:

- renter
- property owner

### Renter profile fields

- name
- phone
- email
- profile photo
- occupation
- family size
- pets
- smoking status

### Owner profile fields

- name
- phone
- email
- profile photo
- address
- national ID verification
- bank/payment details

---

# Property Listings

Supported property types:

- Room
- Flat
- Apartment

Owners may list:

- entire property
- individual rooms as separate listings

Listings contain:

- title
- description
- property type
- address
- map location
- number of rooms
- floor
- furnishing
- preferred tenant type
- available from date
- minimum stay duration
- photos and videos

Public listings display **approximate location only**.  
Exact address becomes visible only after renter approval.

---

# Discovery

Renters can browse listings through:

- list view
- map view

Filters include:

- price range
- property type
- furnished / unfurnished
- parking
- wifi
- pets allowed
- tenant preference
- location radius
- available date
- utilities included or excluded

Renters can also:

- save listings
- send interest requests

---

# Interest and Chat Flow

1. renter sends interest request
2. owner reviews request
3. owner accepts or rejects request
4. owner may approve chat access
5. chat becomes available after approval
6. owner selects renter for assignment

Multiple renters may express interest in the same listing.

---

# Agreements

Once a renter is selected:

1. owner creates agreement
2. renter reviews agreement
3. both parties confirm agreement
4. confirmation requires typed name and OTP

Agreement contains:

- owner details
- renter details
- property details
- monthly rent
- security deposit
- utility terms
- rules and regulations
- start date
- end date
- notice period
- guest rules
- pet rules

Agreement becomes **locked after signing**.

A **PDF version** can be generated.

---

# Tenancy

After agreement signing:

- tenancy becomes active
- renter sees tenancy dashboard
- owner manages tenant through owner dashboard

Move-in checklist may include:

- condition notes
- meter readings
- photos

---

# Billing

Billing cycle is **monthly**.

Invoices include:

- rent
- electricity
- water
- garbage
- internet
- parking
- other charges
- deductions

Electricity can be:

- flat fee
- per-unit entry
- meter-based calculation

Unpaid balances carry forward automatically.

Partial payment is supported.  
Advance payment is supported.

---

# Payments

Supported payment methods:

- eSewa
- Fonepay
- cash (manual marking)

Payment features:

- payment receipts
- payment history
- partial payments
- advance payments
- deposit tracking

---

# Reviews

Both renter and owner may leave reviews.

Reviews can be left:

- during stay
- after move-out

Review system:

- single overall rating
- public reviews
- ability to report abusive reviews

---

# Move-Out Flow

Renter may request move-out.

Owner approves move-out through structured flow.

Move-out includes:

- inspection checklist
- meter readings
- damage notes
- deposit refund summary

After tenancy ends:

- agreement remains accessible
- invoices remain accessible
- payment history remains accessible

---

# Supabase Backend

Basera uses Supabase services:

- Auth
- Database
- Storage
- Realtime/notifications data
- App configuration values

Data structure is documented in:

```
docs/supabase-schema.md
```

---

# Project Structure

The repository follows a **feature-first SwiftUI architecture**.

```
Basera/
  App/
  Core/
  Services/
  Shared/
  Features/
  Resources/
  TestsSupport/
```

High-level structure:

```
Basera/
  AGENTS.md
  README.md
  docs/
    PRD.md
    user-flows.md
    screens.md
    supabase-schema.md
    acceptance-criteria.md
    implementation-phases.md
    codex-prompts.md
```

---

# Development Approach

This project is designed for **agentic development using OpenAI Codex**.

Workflow:

- **Codex Cloud** for large feature implementations
- **Codex IDE extension** for local edits, fixes, and refactoring

Agents must read:

```
AGENTS.md
```

before making changes.

---

# Testing

Unit tests focus on:

- invoice calculations
- payment state updates
- agreement locking
- single-role account setup
- state transitions

Tests live in:

```
BaseraTests/
BaseraUITests/
```

---

# Future Roadmap

Potential future features include:

- maintenance request system
- dispute management
- advanced analytics for owners
- multilingual support
- admin moderation panel
- recommendation engine

---

# License

License will be defined before public release.
