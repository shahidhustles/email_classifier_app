# E-Commerce Email Organizer: Phase-Wise Implementation Plan

Reference source: `/Users/shahidpatel/Downloads/E-Commerce Email Organizer.md`  
Date: March 2, 2026

## Auth Library Strategy (Context7-Based)
- Primary recommendation: `google_sign_in` for Google OAuth in Flutter, with Gmail scopes requested directly during sign-in/authorization.
- Gmail API access path: use `google_sign_in` access token auth headers for REST calls, and/or authenticated client interop with `googleapis` where needed.
- Optional helper package: `extension_google_sign_in_as_googleapis_auth` (if we want less custom auth-client glue).
- Not recommended as primary path for this project: `firebase_auth` alone, because this app needs explicit Gmail API scope handling and token usage beyond basic identity auth.
- Decision for implementation: library-first auth flow using `google_sign_in` + `googleapis`, minimizing custom OAuth code.

## Auth Package Set (MVP)
- `google_sign_in`: Google login and OAuth scope authorization.
- `googleapis`: strongly typed Gmail API client (`GmailApi`).
- `http`: direct Gmail REST calls when needed.
- `flutter_secure_storage`: secure token persistence (if we cache tokens/session metadata).
- `provider`: state management for auth/session/email pipeline.

## Phase 0: Project Foundation
- Finalize MVP scope: keyword classifier first, ML later.
- Confirm target platforms: Android first, then iOS.
- Lock architecture: `models/services/providers/screens/widgets`.
- Define success metrics: login works, emails fetched, e-commerce emails categorized.
- Deliverable: implementation checklist and folder structure baseline.

## Phase 1: Flutter Setup and Environment
- Validate Flutter/Dart toolchain and emulator/device setup.
- Add core dependencies from the guide (`google_sign_in`, `googleapis`, `provider`, `shared_preferences`, etc.).
- Add auth-helper dependency if needed: `extension_google_sign_in_as_googleapis_auth`.
- Set up `.env` config handling.
- Deliverable: app builds and runs on local device/emulator.

## Phase 2: Google OAuth + Gmail API Enablement
- Configure Google Cloud project, OAuth consent screen, and Gmail API.
- Set Android/iOS OAuth config (`google-services.json`, iOS URL schemes).
- Implement `AuthService` with `google_sign_in` and scopes (`gmail.readonly`, optional `gmail.labels`).
- Implement explicit scope authorization checks/requests before Gmail fetch.
- Standardize token/header retrieval for Gmail API calls.
- Deliverable: user can sign in/out and authenticated client is available.

## Phase 3: Gmail Data Layer
- Implement `GmailService` for listing messages and fetching full payloads.
- Add label-based fetch support (`INBOX`, `SPAM`, `CATEGORY_PROMOTIONS`, etc. as needed).
- Implement pagination (`nextPageToken`) and basic retry/error handling.
- Deliverable: reliable email fetch and parsing pipeline.

## Phase 4: Email Parsing + Domain Model
- Implement `EmailModel` and robust Gmail message mapping.
- Parse headers (`From`, `Subject`, `Date`), snippet, and decoded body.
- Handle malformed/missing fields safely.
- Deliverable: normalized email entities ready for classification.

## Phase 5: Classification Engine (MVP)
- Implement keyword/domain-based `ClassifierService`.
- Add categories: `order`, `shipping`, `promotion`, `other`.
- Keep keyword/domain lists configurable for tuning.
- Deliverable: deterministic e-commerce classification.

## Phase 6: State Management + App Orchestration
- Implement `EmailProvider` for fetch/classify/filter/loading/error states.
- Wire auth + gmail + classifier + cache flow.
- Define refresh behavior and state transitions.
- Deliverable: centralized, reactive app state.

## Phase 7: UI Implementation
- Build login screen with Google sign-in.
- Build dashboard with list, refresh, loading/empty/error states.
- Build email card and category filter components.
- Add email detail screen navigation.
- Deliverable: complete user flow from login to categorized emails.

## Phase 8: Caching and Performance
- Implement `CacheService` with `SharedPreferences`.
- Add cache expiry policy (30 minutes) and invalidation rules.
- Optimize API usage with pagination and minimal requested fields.
- Deliverable: faster reloads and fewer redundant API calls.

## Phase 9: Security and Privacy Hardening
- Store sensitive tokens in `flutter_secure_storage`.
- Enforce minimum OAuth scopes and clear data on logout.
- Add privacy-first user messaging and policy readiness.
- Deliverable: stronger security posture and privacy compliance readiness.

## Phase 10: Testing and Quality
- Unit tests: classifier, parsing, cache logic.
- Widget tests: filter behavior, email card rendering, state transitions.
- Integration tests: auth -> fetch -> classify -> filter flow.
- Deliverable: stable test coverage for core functionality.

## Phase 11: Deployment Readiness
- Finalize app metadata, privacy policy links, and consent-screen verification.
- Validate on physical Android and iOS devices.
- Produce release artifacts (`apk`, `appbundle`, iOS release build).
- Deliverable: release candidate build for demo/submission.

## Phase 12: Post-MVP Enhancements (Optional)
- Add search and notifications.
- Add structured extraction (order ID, tracking number).
- Add optional on-device ML classifier (TFLite/ONNX) behind a feature flag.
- Deliverable: advanced roadmap after MVP stability.

## Recommended Execution Order
1. Phases 0-3
2. Phases 4-7
3. Phases 8-11
4. Phase 12 after MVP is stable

## Definition of Done (Project-Level)
- Google sign-in and Gmail read access work on target device(s).
- E-commerce emails are fetched, classified, and filterable by category.
- Caching reduces reload latency and API usage.
- Security/privacy controls are implemented.
- Core unit/widget/integration tests pass.
- Release build artifacts are generated successfully.

## Context7 References Used
- `google_sign_in`: `/websites/pub_dev_packages_google_sign_in`
- `googleapis`: `/websites/pub_dev_googleapis`
- `firebase` (comparison only): `/websites/firebase_google`
