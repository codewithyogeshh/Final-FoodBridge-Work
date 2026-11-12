"""
FoodBridge AI Microservice - Feature 1 Router: Intelligent NGO Matching
"""
from fastapi import APIRouter, Depends, Query
from app.models.schemas import MatchingRequest, MatchingResponse
from app.services.matching_service import IntelligentMatchingService
from app.core.security import verify_api_key

router = APIRouter(prefix="/matching", tags=["Intelligent NGO Matching"])


@router.post(
    "/recommend-ngos",
    response_model=MatchingResponse,
    summary="Recommend verified NGOs for a food or clothing donation using explainable rules",
)
def recommend_ngos(
    payload: MatchingRequest,
    min_score: float = Query(40.0, ge=0.0, le=100.0, description="Minimum match score filter"),
    _token: str = Depends(verify_api_key),
) -> MatchingResponse:
    return IntelligentMatchingService.match_ngos(
        donation=payload.donation,
        candidates=payload.candidates,
        min_threshold=min_score,
    )
