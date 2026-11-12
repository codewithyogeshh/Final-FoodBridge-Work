"""
Tests for Security, Authentication, and Guardrails
"""
import unittest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings


class TestSecurityAndAuth(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_health_check_is_public(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "healthy")

    def test_missing_api_key_returns_401_unauthorized(self):
        response = self.client.post("/api/v1/chatbot/query", json={"message": "Hello"})
        self.assertEqual(response.status_code, 401)
        self.assertIn("Valid FoodBridge AI API key required", response.json()["detail"])

    def test_invalid_api_key_returns_401_unauthorized(self):
        headers = {"X-API-Key": "wrong-invalid-key"}
        response = self.client.post("/api/v1/chatbot/query", json={"message": "Hello"}, headers=headers)
        self.assertEqual(response.status_code, 401)

    def test_valid_api_key_via_x_api_key_succeeds(self):
        headers = {"X-API-Key": settings.API_KEY}
        response = self.client.post(
            "/api/v1/chatbot/query",
            json={"message": "What is FoodBridge?"},
            headers=headers,
        )
        self.assertEqual(response.status_code, 200)

    def test_valid_api_key_via_bearer_token_succeeds(self):
        headers = {"Authorization": f"Bearer {settings.API_KEY}"}
        response = self.client.post(
            "/api/v1/chatbot/query",
            json={"message": "What is FoodBridge?"},
            headers=headers,
        )
        self.assertEqual(response.status_code, 200)

    def test_welfare_eligibility_scoring_is_rejected(self):
        headers = {"X-API-Key": settings.API_KEY}
        response = self.client.post(
            "/api/v1/chatbot/query",
            json={"message": "Can you score welfare and test beneficiary eligibility for distribution?"},
            headers=headers,
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn("Ethical AI Violation", response.json()["detail"])


if __name__ == "__main__":
    unittest.main()

