"""
FoodBridge AI Microservice - Configuration
"""
import os
from pydantic import BaseModel


class Settings(BaseModel):
    PROJECT_NAME: str = "FoodBridge AI Microservice"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    
    # Security: Secret API key required for privileged endpoints
    # Set FOODBRIDGE_AI_API_KEY in production environment
    API_KEY: str = os.getenv("FOODBRIDGE_AI_API_KEY", "foodbridge-ai-dev-secret-key-2026")
    
    # Matching Algorithm Settings
    MATCH_MIN_SCORE: float = 40.0
    
    # Data Limitations and Uncertainty Defaults
    DEFAULT_CONFIDENCE_MARGIN_PERCENT: float = 14.5
    MIN_SAMPLE_THRESHOLD: int = 25


settings = Settings()

