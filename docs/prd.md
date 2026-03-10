# Basera – Product Requirements Document

## Overview

Basera is a rental management mobile application that connects renters with property owners and digitizes the entire rental lifecycle.

The app enables:

- discovery of rental spaces
- communication between renters and owners
- digital agreements
- tenancy tracking
- billing and payments
- reviews and ratings
- move-out and deposit management

Basera acts as a **digital rental record platform**, not a legal enforcement platform.

Initial launch target: **Nepal**

Platforms:

- iPhone
- iPad

Technology:

- SwiftUI
- Firebase backend

---

# User Types

Basera supports two main user roles.

## Renter

A renter is someone searching for a rental property.

Capabilities:

- browse listings
- filter listings
- view listing details
- save listings
- send interest requests
- chat with owners after approval
- sign rental agreements
- view bills
- make payments
- leave reviews
- request move-out

---

## Owner

A property owner lists properties and manages tenants.

Capabilities:

- create listings
- manage listings
- approve renter interests
- schedule visits
- assign renter
- create agreements
- generate bills
- track payments
- manage tenancy
- process move-outs
- leave reviews

---

# Property Listings

Supported property types:

- Room
- Flat
- Apartment

Owners may create:

- a listing for an entire property
- separate listings for individual rooms

Example:

House with 4 rooms:

Owner may create:

- one listing for entire property  
  or
- four listings for four separate rooms

---

# Listing Details

Each listing must include:

- title
- description
- property type
- address
- map location
- number of rooms
- floor
- furnishing status
- tenant preference
- available date
- minimum stay duration

Media:

- photos
- videos

---

# Location Privacy

Public listings show:

- approximate map location

Exact address becomes visible only after:

- owner accepts renter interest

---

# Listing Discovery

Renters discover listings through:

- list view
- map view

Supported filters:

- price range
- property type
- furnished/unfurnished
- parking
- wifi
- pets allowed
- tenant preference
- location radius
- available date
- utilities included

---

# Interest Flow

1. renter sends interest request
2. owner receives request
3. owner accepts or rejects
4. owner optionally enables chat
5. chat opens
6. owner selects renter

Multiple renters can show interest.

Owner can assign only one renter.

---

# Visit Scheduling

Owner may schedule a visit.

Visit includes:

- date
- time
- optional note

Renter confirms visit.

---

# Assignment

After choosing a renter:

1. owner assigns renter
2. renter must accept assignment
3. agreement creation begins

---

# Agreements

Agreement contains:

- owner details
- renter details
- property details
- rent
- deposit
- utility terms
- rules
- start date
- end date
- notice period
- guest rules
- pet rules
- repair responsibility

Agreement confirmation requires:

- typed name
- OTP verification

Agreement becomes locked after signing.

PDF copy available.

---

# Tenancy

After signing:

- tenancy becomes active
- renter dashboard shows active property
- owner dashboard shows tenant

Move-in checklist includes:

- room condition
- furniture
- appliances
- meter reading
- photos

---

# Billing

Billing cycle: monthly.

Invoice includes:

- rent
- electricity
- water
- garbage
- internet
- parking
- other charges
- deductions

Electricity billing types:

- flat
- per-unit input
- meter reading

---

# Payments

Supported methods:

- eSewa
- Fonepay
- cash marking

Features:

- partial payments
- advance payments
- payment receipts
- payment history
- deposit tracking

---

# Reviews

Both sides may review each other.

Review timing:

- during stay
- after move-out

Rating:

- single overall rating

Reviews are public.

Users may report abusive reviews.

---

# Move-Out

Renter may request move-out.

Owner approves move-out.

Move-out includes:

- inspection checklist
- meter readings
- damage notes
- deposit deduction
- refund summary

After move-out:

- agreements remain accessible
- bills remain accessible
- payments remain accessible
