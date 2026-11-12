"""
FoodBridge AI Microservice - Feature 3 Router: Demand Analytics
"""
from fastapi import APIRouter, Depends
from app.models.schemas import DemandAnalyticsRequest, DemandAnalyticsResponse
from app.services.analytics_service import DemandAnalyticsService
from app.core.security import verify_api_key

router = APIRouter(prefix="/analytics", tags=["Demand Analytics"])


@router.post(
    "/demand-insights",
    response_model=DemandAnalyticsResponse,
    summary="Generate historical surplus and demand patterns with explicit uncertainty metrics",
)
def generate_demand_insights(
    request: DemandAnalyticsRequest,
    _token: str = Depends(verify_api_key),
) -> DemandAnalyticsResponse:
    return DemandAnalyticsService.generate_insights(request)
