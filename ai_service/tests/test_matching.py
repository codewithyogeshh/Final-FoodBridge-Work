"""
Tests for Feature 1: Intelligent NGO Matching
"""
import unittest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings


class TestIntelligentMatching(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        self.headers = {"X-API-Key": settings.API_KEY}

    def test_recommend_ngos_returns_high_match_for_compatible_ngo(self):
        payload = {
            "donation": {
                "id": "don-101",
                "type": "food",
                "category": "cooked_meals",
                "quantity": 50.0,
                "unit": "meals",
                "service_area": "Swargate",
                "is_veg": True,
                "storage_requirement": "hot",
                "urgency_hours_left": 2.0,
            },
            "candidates": [
                {
                    "id": "ngo-1",
                    "name": "Asha Children Shelter",
                    "is_verified": True,
                    "is_available": True,
                    "service_areas": ["Swargate", "Shivajinagar"],
                    "accepted_types": ["food"],
                    "storage_capabilities": ["hot_holding", "ambient"],
                    "capacity_available": 60.0,
                    "operating_hours": "08:00 - 22:00",
                },
                {
                    "id": "ngo-2",
                    "name": "Distant Rural Relief",
                    "is_verified": True,
                    "is_available": True,
                    "service_areas": ["Baramati"],
                    "accepted_types": ["food"],
                    "storage_capabilities": ["ambient"],
                    "capacity_available": 100.0,
                    "operating_hours": "09:00 - 18:00",
                },
            ],
        }

        response = self.client.post("/api/v1/matching/recommend-ngos", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertEqual(data["donation_id"], "don-101")
        self.assertGreaterEqual(data["matches_found"], 1)

        top_match = data["matches"][0]
        self.assertEqual(top_match["ngo_id"], "ngo-1")
        self.assertGreaterEqual(top_match["match_score"], 85.0)
        self.assertEqual(top_match["tier"], "EXCELLENT_MATCH")
        self.assertTrue(top_match["can_handle_full_quantity"])
        self.assertIn("Swargate", top_match["explanation"])

    def test_unverified_ngo_is_excluded_from_matching(self):
        payload = {
            "donation": {
                "id": "don-102",
                "type": "food",
                "category": "cooked_meals",
                "quantity": 25.0,
                "unit": "meals",
                "service_area": "Kothrud",
            },
            "candidates": [
                {
                    "id": "ngo-unverified",
                    "name": "Unverified Community Group",
                    "is_verified": False,  # Not verified
                    "is_available": True,
                    "service_areas": ["Kothrud"],
                    "accepted_types": ["food"],
                    "storage_capabilities": ["ambient"],
                    "capacity_available": 50.0,
                }
            ],
        }

        response = self.client.post("/api/v1/matching/recommend-ngos", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["matches_found"], 0)

    def test_cold_storage_requirement_penalizes_lacking_ngos(self):
        payload = {
            "donation": {
                "id": "don-103",
                "type": "food",
                "category": "dairy_chilled",
                "quantity": 30.0,
                "unit": "kg",
                "service_area": "Viman Nagar",
                "storage_requirement": "chilled",
            },
            "candidates": [
                {
                    "id": "ngo-cold",
                    "name": "Equipped Food Bank",
                    "is_verified": True,
                    "is_available": True,
                    "service_areas": ["Viman Nagar"],
                    "accepted_types": ["food"],
                    "storage_capabilities": ["cold_storage", "ambient"],
                    "capacity_available": 50.0,
                },
                {
                    "id": "ngo-ambient-only",
                    "name": "Basic Day Shelter",
                    "is_verified": True,
                    "is_available": True,
                    "service_areas": ["Viman Nagar"],
                    "accepted_types": ["food"],
                    "storage_capabilities": ["ambient"],
                    "capacity_available": 50.0,
                },
            ],
        }

        response = self.client.post("/api/v1/matching/recommend-ngos", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)
        matches = response.json()["matches"]
        self.assertGreater(matches[0]["match_score"], matches[1]["match_score"])
        self.assertEqual(matches[0]["score_breakdown"]["storage_score"], 100.0)
        self.assertEqual(matches[1]["score_breakdown"]["storage_score"], 30.0)


if __name__ == "__main__":
    unittest.main()

