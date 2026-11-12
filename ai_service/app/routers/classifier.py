"""
FoodBridge AI Microservice - Feature 2 Router: Image Category Classification
"""
from fastapi import APIRouter, Depends
from app.models.schemas import (
    ImageClassificationRequest,
    ImageClassificationResponse,
)
from app.services.classifier_service import CategoryClassifierService
from app.core.security import verify_api_key

router = APIRouter(prefix="/classifier", tags=["Image Category Classification"])


@router.post(
    "/suggest-category",
    response_model=ImageClassificationResponse,
    summary="Suggest broad food or clothing categories from image cues (Rule 14 Compliant)",
)
def suggest_category(
    request: ImageClassificationRequest,
    _token: str = Depends(verify_api_key),
) -> ImageClassificationResponse:
    return CategoryClassifierService.classify_image(request)
