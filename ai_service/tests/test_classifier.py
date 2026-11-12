"""
Tests for Feature 2: Image Classification (Rule 14 & ADR-004 Compliant)
"""
import unittest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings


class TestCategoryClassifier(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        self.headers = {"X-API-Key": settings.API_KEY}

    def test_classify_cooked_food_with_hint(self):
        payload = {
            "donor_hint": "Vegetable Biryani and Dal containers",
            "filename": "veg_biryani_tray.jpg",
        }
        response = self.client.post("/api/v1/classifier/suggest-category", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertEqual(data["suggested_category"], "cooked_meals")
        self.assertEqual(data["suggested_type"], "food")
        self.assertGreaterEqual(data["confidence"], 0.70)
        self.assertTrue(data["manual_correction_allowed"])
        self.assertIn("Rule 14", data["food_safety_disclaimer"])
        self.assertGreaterEqual(len(data["alternative_candidates"]), 1)

    def test_classify_clothing_category(self):
        payload = {
            "donor_hint": "Warm woolen sweaters and mufflers for adults",
            "filename": "winter_jackets_stack.png",
        }
        response = self.client.post("/api/v1/classifier/suggest-category", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn(data["suggested_category"], ["winter_thermal", "adult_clothing"])
        self.assertEqual(data["suggested_type"], "clothing")
        self.assertTrue(data["manual_correction_allowed"])

    def test_prohibited_freshness_certification_is_rejected(self):
        payload = {
            "donor_hint": "Please certify food freshness and check if safe to eat",
            "filename": "meal_sample.jpg",
        }
        response = self.client.post("/api/v1/classifier/suggest-category", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 400)
        self.assertIn("Safety Violation", response.json()["detail"])


if __name__ == "__main__":
    unittest.main()
