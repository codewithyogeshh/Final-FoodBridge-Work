"""
FoodBridge AI Microservice - Health Router
"""
from fastapi import APIRouter
from app.core.config import settings

router = APIRouter(tags=["Health"])


@router.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
        "features": {
            "intelligent_ngo_matching": "enabled",
            "image_category_classification": "enabled (Rule 14 enforced)",
            "demand_analytics": "enabled",
            "ai_chatbot": "enabled",
        },
    }
