# FoodBridge AI Microservice

Decoupled Python/FastAPI microservice providing advisory AI services for the FoodBridge platform.

## Features

1. **Intelligent NGO Matching:** Explainable multi-factor scoring (Area, Capacity, Storage, Urgency, Type).
2. **Image Category Classification:** Broad food/clothing classification with strict Rule 14 / ADR-004 non-freshness guarantee.
3. **Demand Analytics:** Aggregated temporal, geographic, and seasonal insights with explicit uncertainty bounds.
4. **Knowledge-Backed Chatbot:** Contextual assistant indexing approved project documentation with automated PII scrubbing.

---

## Installation & Setup

### Prerequisites
- Python 3.10+ (Tested on Python 3.12)
- pip

### Install Dependencies
```bash
cd ai_service
pip install -r requirements.txt
```

### Running Locally
```bash
# Start development server on port 8000
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Interactive API documentation will be available at:
- **Swagger UI:** `http://localhost:8000/docs`
- **ReDoc:** `http://localhost:8000/redoc`
- **Health Check:** `http://localhost:8000/health`

---

## Running the Test Suite

```bash
# Run all automated unit and integration tests
python tests/run_all_tests.py
```

---

## Environment Variables

| Variable | Default | Purpose |
|---|---|---|
| `FOODBRIDGE_AI_API_KEY` | `foodbridge-ai-dev-secret-key-2026` | API key required for privileged endpoints |
| `ENVIRONMENT` | `development` | Deployment environment name |

---

## Example Usage (cURL)

### 1. Health Check
```bash
curl -X GET http://localhost:8000/health
```

### 2. Intelligent NGO Matching
```bash
curl -X POST http://localhost:8000/api/v1/matching/recommend-ngos \
  -H "Content-Type: application/json" \
  -H "X-API-Key: foodbridge-ai-dev-secret-key-2026" \
  -d '{
    "donation": {
      "id": "dn-001",
      "type": "food",
      "category": "cooked_meals",
      "quantity": 50.0,
      "unit": "meals",
      "service_area": "Swargate",
      "storage_requirement": "hot",
      "urgency_hours_left": 2.0
    },
    "candidates": [
      {
        "id": "ngo-101",
        "name": "Asha Children Shelter",
        "is_verified": true,
        "is_available": true,
        "service_areas": ["Swargate"],
        "accepted_types": ["food"],
        "storage_capabilities": ["hot_holding"],
        "capacity_available": 60.0
      }
    ]
  }'
```

### 3. Image Category Classification
```bash
curl -X POST http://localhost:8000/api/v1/classifier/suggest-category \
  -H "Content-Type: application/json" \
  -H "X-API-Key: foodbridge-ai-dev-secret-key-2026" \
  -d '{
    "donor_hint": "Fresh cooked vegetable biryani trays",
    "filename": "biryani_tray.jpg"
  }'
```

### 4. Demand Analytics
```bash
curl -X POST http://localhost:8000/api/v1/analytics/demand-insights \
  -H "Content-Type: application/json" \
  -H "X-API-Key: foodbridge-ai-dev-secret-key-2026" \
  -d '{
    "timeframe_days": 30
  }'
```

### 5. Chatbot Query
```bash
curl -X POST http://localhost:8000/api/v1/chatbot/query \
  -H "Content-Type: application/json" \
  -H "X-API-Key: foodbridge-ai-dev-secret-key-2026" \
  -d '{
    "message": "How does the volunteer 2-task limit work?",
    "role": "volunteer"
  }'
```

