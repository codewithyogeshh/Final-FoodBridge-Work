"""
FoodBridge AI Microservice - FastAPI Main Entry Point
SDLC Phase 10: AI Integration for FoodBridge
"""
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.routers import health, matching, classifier, analytics, chatbot

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description=(
        "Decoupled Python/FastAPI AI Microservice for FoodBridge.\n"
        "Provides Intelligent NGO Matching, Image Category Classification (Rule 14 Compliant), "
        "Demand Analytics with explicit uncertainty metadata, and Knowledge-Backed AI Chatbot Assistant."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS Middleware for safe client access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(health.router)
app.include_router(matching.router, prefix=settings.API_V1_STR)
app.include_router(classifier.router, prefix=settings.API_V1_STR)
app.include_router(analytics.router, prefix=settings.API_V1_STR)
app.include_router(chatbot.router, prefix=settings.API_V1_STR)


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": f"Internal Server Error: {str(exc)}"},
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
