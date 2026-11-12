# FoodBridge Deployment Architecture & Environment Configuration

## 1. Multi-Platform Deployment Targets
- **Mobile (Android & iOS):** Primary targets for Donors, Volunteers, and NGO field workers.
- **Web (Responsive Admin & NGO Portal):** Admin dashboard and NGO bulk coordination desk.

---

## 2. Environment Variables & Secret Management
FoodBridge avoids hardcoding sensitive credentials in source code. Configuration parameters are injected at compile time using `--dart-define`:

```bash
# Example Development / Staging Build
flutter run \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Example Release Production APK Build
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://api.foodbridge.org \
  --dart-define=SUPABASE_ANON_KEY=prod-anon-key-here
```

When compiled without `--dart-define` parameters (e.g. during local offline development or automated widget tests), `EnvConfig.isConfigured` evaluates to `false`, activating the built-in mock demonstration engine so developers can test the full user flow without internet connectivity.

---

## 3. Database Migration Workflow (Supabase CLI)
Database changes follow an immutable migration history managed via the Supabase CLI:

```bash
# Initialize Supabase configuration locally
supabase init

# Generate new schema migration
supabase migration new create_foodbridge_schema

# Apply migrations to local container
supabase db reset

# Push approved migrations to staging / production
supabase db push
```

---

## 4. Continuous Integration & Continuous Delivery (CI/CD)
The GitHub Actions workflow enforces quality gates on every Pull Request to `master`:

```yaml
name: FoodBridge CI

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.8'
          channel: 'stable'

      - name: Install Dependencies
        run: flutter pub get

      - name: Analyze Static Quality
        run: flutter analyze --fatal-infos

      - name: Run Automated Test Suite
        run: flutter test --coverage
```
