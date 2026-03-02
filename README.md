# The Inbox Store

Phase 2 status: Google sign-in and Gmail authorization wiring are implemented for Android-first development.

## Environment Setup

1. Copy `.env.example` to `.env`.
2. Keep `GMAIL_SCOPES` as `https://www.googleapis.com/auth/gmail.readonly` for MVP.
3. `GOOGLE_CLIENT_ID` and `GOOGLE_SERVER_CLIENT_ID` are optional for Android if config files already provide values.

## Android OAuth + Gmail API Setup

1. In Google Cloud Console, create/select a project for this app.
2. Enable **Gmail API**.
3. Configure OAuth consent screen (Testing mode is fine for development).
4. Add your Gmail account as a test user.
5. Create Android OAuth credential with package name:
   - `com.shahidpatel.theinboxstore`
6. Register SHA-1 and SHA-256 fingerprints from your debug keystore:
   - Run `./gradlew signingReport` from `android/`.
7. If your chosen Google setup path provides `google-services.json`, place it at:
   - `android/app/google-services.json`

## Run

1. Install deps:
   - `flutter pub get`
2. Analyze:
   - `flutter analyze`
3. Run on Android:
   - `flutter run`

## Current App Flow (Auth + UI)

1. App bootstraps and attempts lightweight authentication.
2. If not signed in: dedicated branded `LoginScreen`.
3. If signed in: `AppShellScreen` with tabs:
   - `Home`: auto-loads and displays recent 10 inbox emails.
   - `Inbox`: displays fetched email list in compact mode.
   - `Profile`: account summary + sign out action.
   - `Settings`: placeholder for upcoming preferences.
4. Email pipeline:
   - list latest INBOX IDs,
   - fetch full message payloads,
   - parse to normalized `EmailModel`,
   - sort by latest `internalDate`,
   - render `From`, `Subject`, `Date`, `Snippet`.
