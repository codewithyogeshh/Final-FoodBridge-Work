"""
Tests for Feature 3: Demand Analytics & Uncertainty Tracking
"""
import unittest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings


class TestDemandAnalytics(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        self.headers = {"X-API-Key": settings.API_KEY}

    def test_generate_demand_insights_baseline(self):
        payload = {
            "timeframe_days": 30,
        }
        response = self.client.post("/api/v1/analytics/demand-insights", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertEqual(data["analysis_timeframe_days"], 30)
        self.assertGreater(data["total_records_analyzed"], 0)

        # Check temporal windows
        peaks = [p["peak_type"] for p in data["temporal_patterns"]]
        self.assertIn("LUNCH_SURPLUS", peaks)
        self.assertIn("DINNER_SURPLUS", peaks)

        # Check geographic deficit / surplus insights
        statuses = [g["deficit_status"] for g in data["geographic_insights"]]
        self.assertIn("DEFICIT", statuses)
        self.assertIn("SURPLUS", statuses)

        # Check seasonal trends
        seasons = [s["season"] for s in data["seasonal_trends"]]
        self.assertTrue(any("Winter" in s for s in seasons))

        # Check uncertainty metadata & data limitations
        unc = data["uncertainty"]
        self.assertGreater(unc["sample_size"], 0)
        self.assertGreater(unc["confidence_interval_percent"], 0)
        self.assertIn(unc["uncertainty_level"], ["LOW", "MODERATE", "HIGH"])
        self.assertGreaterEqual(len(unc["data_limitations"]), 2)

    def test_zone_filtering_restricts_insights(self):
        payload = {
            "timeframe_days": 60,
            "zone_filter": "Hadapsar",
        }
        response = self.client.post("/api/v1/analytics/demand-insights", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        for g in data["geographic_insights"]:
            self.assertIn("Hadapsar", g["zone"])


if __name__ == "__main__":
    unittest.main()
