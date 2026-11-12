# FoodBridge Central Asset Manifest & Guidelines

## 1. Asset Strategy & Optimization Rules
- **Vector First:** All icons and non-photographic illustrations use vector formats (SVG or Flutter Material / Cupertino vector glyphs) to ensure crisp rendering at any resolution with zero storage bloat.
- **Mobile Optimization:** Photographic assets are compressed using modern WebP format with maximum width capped at `1080px` and quality factor `82%`.
- **Licensing Compliance:** Only properly licensed open-source assets (Apache 2.0, MIT, or Unsplash/Pexels open commercial licenses) or custom-authored assets are integrated. Random hotlinked image URLs are prohibited.

---

## 2. Iconography Standards
FoodBridge uses a unified, consistent icon set based on **Material Symbols Rounded**:

| Category | Primary Icon | Use Case |
|---|---|---|
| Food | `Icons.restaurant_rounded` / `soup_kitchen_rounded` | Food donation listings & categories |
| Clothing | `Icons.checkroom_rounded` | Clothing donation listings & filters |
| Delivery / Rider | `Icons.two_wheeler_rounded` | Volunteer vehicle mode & task markers |
| Verification | `Icons.verified_rounded` | NGO verified shelter badge (Darpan/80G) |
| Time / Urgency | `Icons.timer_outlined` | Collection deadline countdown timer |
| Security | `Icons.shield_outlined` | Safety charter & data privacy |
| Impact | `Icons.eco_rounded` | CO₂ prevented & community metrics |

---

## 3. Illustration & Artwork Manifest

| Asset Name | Target Format | Key Purpose | Location |
|---|---|---|---|
| `logo_bridge_leaf` | Vector SVG | Primary brand logo & app icon | `assets/images/logo.png` |
| `hero_onboarding_donor` | Vector SVG | Donor role selection card artwork | `assets/illustrations/onboarding_donor.svg` |
| `hero_onboarding_ngo` | Vector SVG | NGO shelter role selection card artwork | `assets/illustrations/onboarding_ngo.svg` |
| `hero_onboarding_rider` | Vector SVG | Volunteer rider role selection card artwork | `assets/illustrations/onboarding_rider.svg` |
| `empty_donations` | Vector SVG | Zero active listings in feed | `assets/illustrations/empty_feed.svg` |
| `empty_tasks` | Vector SVG | Zero dispatch tasks for volunteer | `assets/illustrations/empty_tasks.svg` |
| `success_celebration` | Vector SVG | Handover completed celebration screen | `assets/illustrations/delivery_success.svg` |

---

## 4. Packaging & Asset Declaration in `pubspec.yaml`
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/illustrations/
```
All assets are versioned in Git alongside application source code to ensure deterministic offline builds.

