"""
FoodBridge AI Microservice - Data Models & Validation Schemas
"""
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field, field_validator


# ==========================================
# 1. INTELLIGENT NGO MATCHING SCHEMAS
# ==========================================

class DonationInput(BaseModel):
    id: str = Field(..., description="Unique donation identifier (UUID)")
    type: str = Field(..., description="Donation type: 'food' or 'clothing'")
    category: str = Field(..., description="Specific subcategory (e.g. cooked_meals, raw_produce, winter_wear)")
    quantity: float = Field(..., gt=0, description="Quantity in indicated units")
    unit: str = Field(..., description="Measurement unit (e.g. meals, kg, boxes, pieces)")
    service_area: str = Field(..., description="Neighborhood / locality name (e.g. Swargate, Kothrud, Hadapsar)")
    is_veg: Optional[bool] = Field(default=True, description="Applies to food donations")
    storage_requirement: Optional[str] = Field(default="ambient", description="'ambient', 'chilled', or 'hot'")
    urgency_hours_left: Optional[float] = Field(default=4.0, ge=0, description="Hours remaining before pickup deadline")

    @field_validator("type")
    @classmethod
    def validate_type(cls, v: str) -> str:
        clean = v.lower().strip()
        if clean not in ["food", "clothing"]:
            raise ValueError("Donation type must be either 'food' or 'clothing'")
        return clean


class NgoCandidateInput(BaseModel):
    id: str = Field(..., description="NGO identifier")
    name: str = Field(..., description="NGO organization name")
    is_verified: bool = Field(..., description="True if verified with 12A/80G/Darpan")
    is_available: bool = Field(default=True, description="Operational readiness to receive donations")
    service_areas: List[str] = Field(..., min_length=1, description="List of operational zones")
    accepted_types: List[str] = Field(..., min_length=1, description="Types accepted: 'food', 'clothing'")
    storage_capabilities: List[str] = Field(default_factory=lambda: ["ambient"], description="'ambient', 'cold_storage', 'hot_holding'")
    capacity_available: float = Field(..., ge=0, description="Current available capacity (in units matching donation)")
    operating_hours: str = Field(default="08:00 - 20:00", description="Operating hours window")


class MatchingRequest(BaseModel):
    donation: DonationInput
    candidates: List[NgoCandidateInput] = Field(..., min_length=1, description="List of verified candidate NGOs to evaluate")


class ScoreBreakdown(BaseModel):
    area_match_score: float = Field(..., description="Service area proximity score (0-100)")
    capacity_score: float = Field(..., description="Capacity fit score (0-100)")
    storage_score: float = Field(..., description="Storage condition compatibility (0-100)")
    urgency_score: float = Field(..., description="Deadline responsiveness score (0-100)")
    type_score: float = Field(..., description="Donation type compatibility (0-100)")


class NgoMatchResult(BaseModel):
    ngo_id: str
    ngo_name: str
    match_score: float = Field(..., ge=0, le=100, description="Aggregate match percentage")
    tier: str = Field(..., description="'EXCELLENT_MATCH' (>=85), 'GOOD_MATCH' (>=70), 'FAIR_MATCH' (>=50)")
    score_breakdown: ScoreBreakdown
    explanation: str = Field(..., description="Human-readable explainability text")
    can_handle_full_quantity: bool = Field(..., description="Whether NGO capacity >= donation quantity")


class MatchingResponse(BaseModel):
    donation_id: str
    total_candidates_evaluated: int
    matches_found: int
    matches: List[NgoMatchResult]
    algorithm_version: str = "rules-v1.0"


# ==========================================
# 2. IMAGE CLASSIFICATION SCHEMAS
# ==========================================

class ImageClassificationRequest(BaseModel):
    image_base64: Optional[str] = Field(None, description="Base64-encoded image string")
    filename: Optional[str] = Field(None, description="Image filename or label for classification")
    donor_hint: Optional[str] = Field(None, description="Optional text hint from donor (e.g. 'vegetable biryani' or 'winter jackets')")


class CandidateCategory(BaseModel):
    category_id: str
    display_name: str
    type: str = Field(..., description="'food' or 'clothing'")
    confidence: float = Field(..., ge=0, le=1)


class ImageClassificationResponse(BaseModel):
    suggested_category: str
    suggested_type: str = Field(..., description="'food' or 'clothing'")
    confidence: float = Field(..., ge=0, le=1)
    alternative_candidates: List[CandidateCategory]
    manual_correction_allowed: bool = True
    food_safety_disclaimer: str = Field(
        default="AI Advisory Only: This classification suggests broad category groupings. It does NOT evaluate freshness, bacterial safety, contamination, or edibility. Manual donor hygiene declaration and NGO physical check are mandatory (Rule 14 / ADR-004)."
    )


# ==========================================
# 3. DEMAND ANALYTICS SCHEMAS
# ==========================================

class HistoricalRecordInput(BaseModel):
    id: str
    donation_type: str
    category: str
    quantity: float
    unit: str
    zone: str
    created_at_hour: int = Field(..., ge=0, le=23)
    day_of_week: str
    is_distributed: bool = True


class DemandAnalyticsRequest(BaseModel):
    timeframe_days: int = Field(default=30, ge=7, le=365)
    zone_filter: Optional[str] = None
    records: Optional[List[HistoricalRecordInput]] = None


class HourlyPattern(BaseModel):
    hour_window: str
    average_surplus_quantity: float
    unit: str
    peak_type: str = Field(..., description="'LUNCH_SURPLUS', 'DINNER_SURPLUS', 'AFTERNOON_TROUGH', 'MORNING_PREP'")


class GeographicInsight(BaseModel):
    zone: str
    supply_index: float
    demand_index: float
    deficit_status: str = Field(..., description="'DEFICIT' (Demand > Supply), 'SURPLUS' (Supply > Demand), 'BALANCED'")
    recommendation: str


class SeasonalTrend(BaseModel):
    season: str
    category: str
    trend_direction: str = Field(..., description="'INCREASING', 'STABLE', 'DECREASING'")
    percentage_change: float
    rationale: str


class UncertaintyMetadata(BaseModel):
    sample_size: int
    confidence_interval_percent: float = Field(..., description="Statistical error margin e.g. ±14.5%")
    uncertainty_level: str = Field(..., description="'LOW', 'MODERATE', 'HIGH'")
    data_limitations: List[str]


class DemandAnalyticsResponse(BaseModel):
    analysis_timeframe_days: int
    total_records_analyzed: int
    temporal_patterns: List[HourlyPattern]
    geographic_insights: List[GeographicInsight]
    seasonal_trends: List[SeasonalTrend]
    uncertainty: UncertaintyMetadata


# ==========================================
# 4. AI CHATBOT SCHEMAS
# ==========================================

class ChatbotQueryRequest(BaseModel):
    user_id: Optional[str] = Field(None, description="Optional anonymous user ID")
    role: Optional[str] = Field(default="guest", description="'donor', 'ngo', 'volunteer', 'admin', 'guest'")
    message: str = Field(..., min_length=2, max_length=1000, description="User's query")


class KnowledgeSource(BaseModel):
    doc_id: str
    section: str
    relevance_score: float


class ChatbotResponse(BaseModel):
    reply: str
    matched_intent: str
    confidence: float
    sources: List[KnowledgeSource]
    suggested_quick_replies: List[str]
    support_escalation_available: bool = True
