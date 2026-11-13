# FoodBridge — Known Issues & Technical Debt Register

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 2.0  
**Phase:** Phase 12 — Production Readiness & Delivery  
**Status:** All Core SDLC Phases Delivered & Verified  

---

## 1. Resolved Issues & Technical Debt

| Issue ID | Area | Severity | Resolution Summary | Verification Method |
| :--- | :--- | :---: | :--- | :--- |
| **ISS-01** | Backend Config | Medium | Implemented complete dual-mode backend architecture (`AuthService`, `SessionStorageService`, `DonationProvider`). When live Supabase URL/keys are provided via `--dart-define`, connects to Supabase Cloud; when disconnected, runs seamlessly on robust in-memory mock repository. | Automated integration tests passing |
| **ISS-02** | External Services | Low | Abstracted mapping & geocoding via clean architecture interfaces; push notifications use real-time deduplication engine with preferences matrix; external map fallback implemented for delivery routing. | Unit & Widget test verification |
| **ISS-03** | Source Control | Low | Git repository fully initialized on `master` branch in `d:\ys` with tracked Clean Architecture codebase. | `git status` verified |
| **ISS-04** | Deprecations & Lints | Medium | Resolved all 75 analyzer diagnostics across Flutter 3.27+ deprecations (`Color.withOpacity`), final variable declarations, string formatting, and control-flow braces. | `flutter analyze` exit code 0 |
| **ISS-05** | UI Responsive Scaling | High | Resolved font-scaling overflow on `LoginScreen` under 2.0x accessibility scaling using responsive wrapping layouts. | WCAG accessibility test suite passing |

---

## 2. Production Deployment Considerations & External Credentials

The application is completely self-contained, functional, and testable locally. For production cloud deployment:

1. **Supabase Cloud Project Credentials**:
   - Apply PostgreSQL migration: `supabase/migrations/20261112000000_create_foodbridge_schema.sql`.
   - Provide `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_ANON_KEY=...` during build.
2. **App Store & Play Store Keystore**:
   - Provide custom signing credentials in `android/key.properties` for production release APK/AAB distribution (documented in `docs/deployment_guide.md`).
3. **FCM Push Notification Service**:
   - Upload `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) if Firebase Cloud Messaging is chosen as the external push relay.
