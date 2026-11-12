# FoodBridge Environment Setup & Configuration Guide
**SDLC Phase 12: Deployment & Maintenance**

---

## 1. Environment Architecture

FoodBridge is structured across three segregated environments:

| Environment | Purpose | Mobile Client Config | Backend (Supabase) | AI Microservice |
|---|---|---|---|---|
| **Development** | Feature coding & local testing | Local in-memory seed / Dev DB | Local Supabase Docker / Dev Project | `http://localhost:8000` |
| **Pilot (Staging)** | Controlled real-world pilot with initial partners | Staging APK build (`org.foodbridge.app.pilot`) | Dedicated Staging Supabase Project | Cloud Container (`https://ai-pilot.foodbridge.org`) |
| **Production** | Full community public operations | Release App Bundle (`org.foodbridge.app`) | High-Availability Production Cluster | Auto-scaled Cloud Run / ECS cluster |

---

## 2. Prerequisites & Toolchain Setup

### 2.1. Mobile Application (Flutter)
- **Flutter SDK:** Version `3.38.1` (Channel `stable`)
- **Dart SDK:** Version `3.10.0+`
- **JDK:** OpenJDK `17.0.x`
- **Android SDK:** API Level 34 / 35 (Build tools `34.0.0+`)
- Verify installation:
  ```bash
  flutter doctor -v
  ```

### 2.2. AI Microservice (Python & FastAPI)
- **Python:** Version `3.12.x` (or `3.10+`)
- **Virtual Environment:**
  ```bash
  cd ai_service
  python -m venv venv
  # Windows
  .\venv\Scripts\activate
  # Linux/macOS
  source venv/bin/activate
  pip install -r requirements.txt
  ```

### 2.3. Backend Infrastructure (Supabase & PostgreSQL)
- **Supabase CLI** (optional for local migrations):
  ```bash
  npm install -g supabase
  ```
- **PostgreSQL Client** (`psql`) or Supabase Dashboard access.

---

## 3. Configuration Variables & Secrets Matrix

### 3.1. Flutter Client Configuration (`lib/core/config/env_config.dart`)
Configuration is injected via compile-time `--dart-define` flags or environment defaults:

| Variable | Description | Pilot / Production Default | Exposure Tier |
|---|---|---|---|
| `APP_ENV` | Environment identifier | `pilot` or `production` | Public Client |
| `SUPABASE_URL` | Supabase project API gateway | `https://<project-ref>.supabase.co` | Public Client |
| `SUPABASE_ANON_KEY` | Public publishable client key | `eyJhbGciOi...` | Public Client (Protected by RLS) |
| `AI_SERVICE_URL` | Microservice base endpoint | `https://ai.foodbridge.org` | Public Client |

> [!IMPORTANT]
> **Zero Master Key Exposure:** The Supabase `service_role` secret key and backend administrative keys must **never** be injected into Flutter client builds.

### 3.2. AI Microservice Configuration (`.env`)
Create `ai_service/.env`:

```env
ENVIRONMENT=production
PROJECT_NAME="FoodBridge AI Microservice"
VERSION="1.0.0"

# Secret API Key required for privileged AI endpoints
FOODBRIDGE_AI_API_KEY=foodbridge-ai-pilot-prod-secret-2026-key

# Server Binding
HOST=0.0.0.0
PORT=8000
```

---

## 4. Verification & Health Check

1. **Verify AI Microservice:**
   ```bash
   curl -X GET http://localhost:8000/health
   # Expected: {"status":"healthy","service":"FoodBridge AI Microservice",...}
   ```
2. **Verify Flutter Test Suite:**
   ```bash
   flutter test
   # Expected: All tests passed! (101/101 tests)
   ```
3. **Verify Database Connectivity:**
   Confirm RLS policies in Supabase dashboard under **Authentication > Policies**.
