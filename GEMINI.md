# Antigravity Global Engineering Rules

These rules apply globally across all projects and development workflows.

## 1. Flutter Development Standard
- **Plan First**: Before modifying or creating code, outline a clear implementation plan detailing widget architecture, routing, and data contracts.
- **Clean Architecture**: Strictly enforce separation of concerns across Presentation (UI/widgets, state), Domain (entities, use cases, business logic), and Data (data sources, repositories, models, serialization).
- **Verification Gate**: Never declare a Flutter task complete without running and passing both:
  ```bash
  flutter analyze
  flutter test
  ```

## 2. Security Review for New Features
- For every new feature, API endpoint, or data model, conduct a dedicated security audit:
  - **Insecure Defaults**: Ensure safe fallbacks, strict types, and safe default configurations.
  - **Secrets in Code**: Verify no API keys, private tokens, service account credentials, or environment secrets are committed.
  - **Authentication & Authorization**: Verify session validity, role permissions, and Supabase Row Level Security (RLS) policies.
  - **Data Storage**: Ensure encryption at rest for sensitive local storage and sanitized database queries.

## 3. UI & Design Excellence
- For any user interface (web, 3D overlays, or mobile app screens):
  - Always activate and adhere to **`taste-skill`** (refined typography, spacing consistency, modern restraint, anti-slop visual standard).
  - Always consult **`ui-ux-pro-max`** (design system tokens, accessible color palettes, responsive layouts, micro-interactions, WCAG AA compliance).

## 4. Empirical Evidence Before Assertions
- **Never claim work is complete, fixed, or passing without fresh empirical evidence**.
- Always run the relevant compiler, test suite, or analysis commands in the current workspace and confirm passing output before signing off.
