# FoodBridge Installation & Setup Guide
**SDLC Phase 12: Deployment & Maintenance**

---

## 1. System Requirements

### 1.1. Client Device Requirements (Mobile)
- **Android:** Android 7.0 (API Level 24) or higher; 2 GB RAM minimum (4 GB recommended); GPS & camera capability.
- **iOS:** iOS 14.0 or higher.
- **Web:** Modern Chromium, Firefox, or Safari browser.

### 1.2. Server & Cloud Requirements
- **PostgreSQL Database:** Supabase Cloud Project or self-hosted PostgreSQL 15+ with PostGIS and pgcrypto extensions.
- **AI Microservice Host:** Linux container (Debian 12 / Ubuntu 22.04 LTS), 1 vCPU, 1 GB RAM minimum.

---

## 2. Database Initialization (Supabase)

1. Open your Supabase project dashboard at `https://supabase.com/dashboard`.
2. Navigate to **SQL Editor > New Query**.
3. Copy and execute the contents of the database schema migration:
   [20261112000000_create_foodbridge_schema.sql](file:///d:/ys/supabase/migrations/20261112000000_create_foodbridge_schema.sql)
4. Confirm successful creation of all 12 tables:
   - `profiles`, `donor_profiles`, `ngo_profiles`, `volunteer_profiles`
   - `donations`, `food_details`, `clothing_details`
   - `donation_claims`, `volunteer_tasks`, `distribution_records`
   - `audit_logs`, `complaints`
5. Navigate to **Storage** and ensure private buckets exist:
   - `donation-photos` (Public read for thumbnail display, authenticated write).
   - `ngo-verification-docs` (Strictly private; readable exclusively by `admin`).

---

## 3. Python AI Microservice Installation

### Option A: Local Virtual Environment
```bash
# 1. Navigate to service root
cd ai_service

# 2. Create and activate Python virtual environment
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# 3. Install production dependencies
pip install -r requirements.txt

# 4. Start the service
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Option B: Docker Container Deployment
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```
Build and run:
```bash
docker build -t foodbridge-ai:1.0.0 ./ai_service
docker run -d -p 8000:8000 --env-file ./ai_service/.env foodbridge-ai:1.0.0
```

---

## 4. Mobile Client Installation (Android Pilot)

### 4.1. Sideloading Pilot APK (Direct Distribution)
1. Download the pilot release APK: `build/app/outputs/flutter-apk/app-release.apk`.
2. Transfer the APK file to the pilot tester's Android device.
3. Enable *"Install from Unknown Sources"* in Android Settings for the file manager.
4. Tap the APK file and select **Install**.
5. Launch **FoodBridge** from the app launcher.

### 4.2. Google Play Internal Testing Track
1. Upload the signed Android App Bundle (`.aab`) to the Google Play Developer Console.
2. Create an **Internal Testing Track** release.
3. Add email addresses of pilot donors, verified NGO coordinators, and volunteers to the testers list.
4. Testers accept the invite link and install directly via the Google Play Store.

