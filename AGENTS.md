# AGENTS.md

# Basera Agent Instructions

This repository is for building **Basera**, a rental management app for **iPhone and iPad** using **SwiftUI**.

Read this file before making any code changes.

---

## Product Context

Basera is a rental management platform for Nepal.

It supports two user roles:

- renter
- owner

A single account may have both roles, and users can switch roles later.

Core product areas:

- authentication with phone number and OTP
- renter and owner profile setup
- listing creation and listing discovery
- interest requests and owner approval
- gated chat after approval
- renter assignment
- agreement creation and signing
- tenancy tracking
- monthly billing
- payments
- reviews
- move-out flow

Basera acts as a **digital record platform** for agreements, not a legal enforcement platform.

---

## Technical Stack

- SwiftUI
- Xcode
- Firebase Authentication
- Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Firebase Remote Config

Target platforms:

- iPhone
- iPad

Unless explicitly requested otherwise:

- use SwiftUI only
- avoid UIKit unless clearly necessary
- do not introduce unnecessary third-party dependencies

---

## Architecture Rules

Use a **feature-first SwiftUI architecture** with **MVVM**.

### Required principles

- Keep business logic out of SwiftUI views
- Views should remain focused on rendering and user interaction
- Put state and interaction logic into ViewModels
- Put backend and persistence logic into services and repositories
- Do not call Firebase directly inside SwiftUI views
- Prefer protocol-based abstractions for services and repositories
- Keep code modular and easy to extend
- Prefer small, testable units over large multi-purpose files

### Dependency flow

Use this direction whenever possible:

```
View
→ ViewModel
→ Repository / Service
→ Firebase
```

Views should **never talk directly to Firebase**.

---

## Repository Structure

The project follows a **feature-first structure**.

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

### Folder responsibilities

**App**

- App entry point
- root navigation
- environment setup

**Core**

- shared models
- utilities
- constants
- base abstractions

**Services**

- Firebase services
- authentication
- storage
- messaging
- remote config

**Shared**

- reusable UI components
- design tokens
- shared view utilities

**Features**
Each major feature lives in its own module.

Examples:

```
Features/
  Auth/
  Profiles/
  Listings/
  Explore/
  Interests/
  Chat/
  Agreements/
  Tenancy/
  Billing/
  Payments/
  Reviews/
```

---

## Design System Expectations

Reusable UI components should live in **Shared**.

Examples:

- Button
- TextField
- Card
- Avatar
- Badge
- Chip
- Empty states
- Error states
- Loading indicators

All components should include **SwiftUI previews**.

---

## Data Handling Rules

- Firebase access must be abstracted through repositories or services
- Business rules must not live in views
- Use models for state representation
- Prefer immutable data patterns where practical

---

## Mocking and Development Mode

During early development:

- use **mock repositories**
- avoid wiring real Firebase unless explicitly required
- provide realistic preview data for SwiftUI previews

This keeps the app **runnable without backend configuration**.

---

## Testing Philosophy

Unit tests should focus on:

- invoice calculations
- carry-forward balance updates
- agreement locking after signing
- role switching behavior
- assignment and approval logic

Avoid overbuilding tests for purely visual UI unless requested.

---

## Change Management Rules

When making changes:

- preserve existing architecture unless there is a strong reason not to
- do not perform broad rewrites without explanation
- avoid renaming large portions of the codebase casually
- keep changes scoped to the requested task

If a structural issue is discovered, call it out clearly.

If a user instruction conflicts with these rules, follow the **latest explicit user instruction**.

---

## Expected Response Summary After Changes

After completing work, provide a concise summary including:

1. files created or changed
2. major implementation choices
3. assumptions made
4. anything that still needs manual setup or review

If something is intentionally mocked or stubbed, state that clearly.

---

## Initial Development Preference

Unless the task explicitly requires live backend wiring:

- prefer mocked services
- use repository abstractions
- keep the app runnable without production credentials
- ensure features work in preview mode

This project will use:

- **Codex Cloud** for large implementation phases
- **Codex IDE extension** for smaller changes and refactoring

Optimize implementation for this workflow.
