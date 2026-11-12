# FoodBridge Navigation Architecture & Sitemap

```mermaid
flowchart TD
    Splash["/ (SplashScreen)"] -->|Initial Load| Onboarding["/onboarding"]
    Onboarding -->|Role Selected| Register["/register?role="]
    Onboarding -->|Existing User| Login["/login"]
    Login -->|Auth Success: Donor| DonorDash["/donor"]
    Login -->|Auth Success: NGO| NgoDash["/ngo"]
    Login -->|Auth Success: Volunteer| VolDash["/volunteer"]
    Login -->|Auth Success: Admin| AdminDash["/admin"]

    subgraph Shared["Shared User Paths"]
        Profile["/profile"]
        Notifications["/notifications"]
        DonationDetail["/donation-detail/:id"]
    end

    subgraph DonorGroup["Donor Experience"]
        DonorDash --> CreateDonation["/create-donation"]
        DonorDash --> MyDonations["/donor/my-donations"]
        DonorDash --> DonationDetail
        CreateDonation --> DonationPreview["/donor/preview"]
    end

    subgraph NgoGroup["NGO Experience"]
        NgoDash --> ExploreDonations["/ngo/explore"]
        NgoDash --> NgoClaims["/ngo/my-claims"]
        NgoDash --> NgoVerification["/ngo/verification-upload"]
        NgoDash --> DonationDetail
    end

    subgraph VolGroup["Volunteer Experience (Rider Mode)"]
        VolDash --> VolTaskDetail["/volunteer/task/:id"]
        VolDash --> VolHistory["/volunteer/history"]
        VolDash --> DonationDetail
    end

    subgraph AdminGroup["Admin Console"]
        AdminDash --> NgoQueue["/admin/verifications"]
        AdminDash --> UserMgmt["/admin/users"]
        AdminDash --> AuditLogs["/admin/audit"]
    end

    DonorDash -.-> Profile
    NgoDash -.-> Profile
    VolDash -.-> Profile
    AdminDash -.-> Profile

    DonorDash -.-> Notifications
    NgoDash -.-> Notifications
    VolDash -.-> Notifications
    AdminDash -.-> Notifications
```

## Route Specifications Table

| Path | Screen Class | Access Level | Description |
|---|---|---|---|
| `/` | `SplashScreen` | Public | Brand reveal & auth token validation |
| `/onboarding` | `OnboardingScreen` | Public | Role selection & value proposition intro |
| `/login` | `LoginScreen` | Public | Email/Password login + role selector |
| `/register` | `RegisterScreen` | Public | Role registration + safety charter check |
| `/donor` | `DonorDashboardScreen` | Role: Donor | Live listings, quick actions, impact metrics |
| `/create-donation` | `CreateDonationScreen` | Role: Donor | Food & Clothing listing multi-category form |
| `/donation-detail/:id` | `DonationDetailScreen` | Authenticated | Detail card with contextual role actions |
| `/ngo` | `NgoDashboardScreen` | Role: NGO | Filtered discovery feed & claim actions |
| `/volunteer` | `VolunteerDashboardScreen` | Role: Volunteer | Rider mode dispatch feed & 1-tap progress |
| `/admin` | `AdminDashboardScreen` | Role: Admin | NGO verification queue & audit activity |
| `/profile` | `ProfileScreen` | Authenticated | Account details, theme & language switches |
| `/notifications` | `NotificationsScreen` | Authenticated | In-app notification center |

## Route Guards & Role Protection
1. **Unauthenticated Redirect:** Any request attempting to access `/donor`, `/ngo`, `/volunteer`, or `/admin` without an active session is redirected to `/login`.
2. **Role Boundaries:** When a user navigates to a role dashboard not matching their profile, `AppRouter` redirects them to their designated home screen or surfaces an authorized switch prompt.
3. **Demo Fallback:** In prototype mode, the role switcher in `ProfileScreen` allows switching active simulated roles for testing.

