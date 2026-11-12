"""
FoodBridge AI Microservice - Feature 4 Router: AI Chatbot (FoodBridge Assistant)
"""
from fastapi import APIRouter, Depends
from app.models.schemas import ChatbotQueryRequest, ChatbotResponse
from app.services.chatbot_service import FoodBridgeChatbotService
from app.core.security import verify_api_key

router = APIRouter(prefix="/chatbot", tags=["AI Chatbot Assistant"])


@router.post(
    "/query",
    response_model=ChatbotResponse,
    summary="Answer user questions using approved project documentation knowledge base",
)
def query_assistant(
    request: ChatbotQueryRequest,
    _token: str = Depends(verify_api_key),
) -> ChatbotResponse:
    return FoodBridgeChatbotService.answer_query(request)

