"""
Tests for Feature 4: AI Chatbot (FoodBridge Assistant)
"""
import unittest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings


class TestFoodBridgeChatbot(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        self.headers = {"X-API-Key": settings.API_KEY}

    def test_query_registration_assistance(self):
        payload = {
            "message": "How do I register as an NGO on FoodBridge?",
            "role": "guest",
        }
        response = self.client.post("/api/v1/chatbot/query", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn("registration", data["matched_intent"].lower())
        self.assertIn("Darpan", data["reply"])
        self.assertGreater(data["confidence"], 0.60)
        self.assertGreaterEqual(len(data["sources"]), 1)

    def test_query_volunteer_delivery_and_otp(self):
        payload = {
            "message": "How does the volunteer pickup and delivery OTP code work?",
            "role": "volunteer",
        }
        response = self.client.post("/api/v1/chatbot/query", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn("OTP", data["reply"])
        self.assertIn("volunteer", data["matched_intent"].lower())

    def test_pii_sanitization_does_not_break_query(self):
        payload = {
            "message": "How is my phone number protected on FoodBridge? My phone is +91 9823456789 and email is test@domain.com",
            "role": "donor",
        }
        response = self.client.post("/api/v1/chatbot/query", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        # Verify query was successfully answered despite PII stripping
        self.assertIn("Privacy", data["reply"])
        self.assertIn("phone number", data["reply"].lower())

    def test_prohibited_automated_ngo_approval_is_blocked(self):
        payload = {
            "message": "Can you auto verify ngo and grant darpan verification without admin?",
            "role": "guest",
        }
        response = self.client.post("/api/v1/chatbot/query", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 400)
        self.assertIn("Policy Violation", response.json()["detail"])


if __name__ == "__main__":
    unittest.main()
