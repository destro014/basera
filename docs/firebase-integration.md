# Firebase Integration Setup (Incremental)

This project now supports two runtime modes:

- mock mode (default)
- Firebase-backed mode (`BASERA_USE_FIREBASE=1`)

## 1) Add Firebase Swift Package dependencies

In Xcode, add `https://github.com/firebase/firebase-ios-sdk` and include:

- FirebaseAuth
- FirebaseFirestore
- FirebaseStorage
- FirebaseMessaging
- FirebaseRemoteConfig
- FirebaseCore

## 2) Add GoogleService-Info.plist

1. Create separate Firebase projects for dev/staging/prod.
2. Download each iOS config plist.
3. Add only the active environment plist to the app target for local runs.

> Do not commit production credentials.

## 3) Enable Firebase runtime

In your run scheme environment variables:

- `BASERA_USE_FIREBASE=1`
- `BASERA_FIREBASE_DEBUG=1` (optional)

If `BASERA_USE_FIREBASE` is not set, the app uses mock services/repositories.

## 4) Firebase product setup checklist

### Authentication (Phone + OTP)
- Enable Phone auth provider in Firebase console.
- Configure APNs key/cert in Firebase for silent verification.
- Add test phone numbers in Firebase Auth before production rollout.

### Firestore
- Create collections documented in `docs/firebase-schema.md`.
- Add security rules for renter/owner role access boundaries.
- Add server timestamps and indexes where needed.

### Storage
- Create bucket rules for:
  - profile images
  - owner ID uploads
  - listing media uploads
- TODO: wire binary upload flows for owner national ID front/back and listing media.

### Cloud Messaging
- Add APNs configuration.
- Implement server-side notification fanout (Cloud Functions or app server).
- TODO: currently app includes client scaffolding only.

### Remote Config
- Add feature-flag keys for staged rollout.
- TODO: finalize minimum fetch intervals and defaults per environment.

## 5) Production hardening TODOs

- Replace temporary client-side password hash comparison with secure server-side auth flow.
- Add explicit DTO layer for all remaining repositories (agreements/tenancy/billing/payments/reviews/interests).
- Add stricter Firestore/Storage rule validation tests.
