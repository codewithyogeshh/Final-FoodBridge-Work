"""
FoodBridge AI Microservice - Security & Safety Enforcement
"""
import re
from typing import Optional
from fastapi import HTTPException, Security, status
from fastapi.security import APIKeyHeader, HTTPBearer, HTTPAuthorizationCredentials
from app.core.config import settings

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)
bearer_scheme = HTTPBearer(auto_error=False)


def verify_api_key(
    header_key: Optional[str] = Security(api_key_header),
    credentials: Optional[HTTPAuthorizationCredentials] = Security(bearer_scheme),
) -> str:
    """
    Validates API key from either 'X-API-Key' header or 'Authorization: Bearer <key>'.
    Ensures endpoints are strictly protected from unauthorized public access.
    """
    token = header_key or (credentials.credentials if credentials else None)
    
    if not token or token != settings.API_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Unauthorized: Valid FoodBridge AI API key required.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token


def sanitize_pii(text: str) -> str:
    """
    Sanitizes raw text to avoid sending or storing unnecessary personal identifiable information (PII).
    Masks 10-digit phone numbers and email addresses.
    """
    # Mask 10-digit Indian phone numbers
    phone_pattern = r"(\+91[\-\s]?)?[6-9]\d{9}"
    sanitized = re.sub(phone_pattern, "[PHONE_MASKED]", text)
    
    # Mask email addresses
    email_pattern = r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"
    sanitized = re.sub(email_pattern, "[EMAIL_MASKED]", sanitized)
    
    return sanitized


def guard_prohibited_ai_actions(intent: str, details: str = "") -> None:
    """
    Security guard: Strict adherence to ADR-004 & project safety rules.
    Prevents AI from:
    1. Certifying food freshness, microbial safety, or edibility.
    2. Automatically verifying NGOs (requires manual human admin review).
    3. Determining individual beneficiary welfare eligibility.
    """
    lower = f"{intent} {details}".lower()
    
    # Rule 14: Never certify food safety
    if any(k in lower for k in ["certify food", "guarantee safe", "edibility certificate", "freshness test", "safe to eat"]):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Safety Violation: AI cannot certify food freshness, microbial safety, or edibility. Mandatory human donor pledge and NGO physical inspection required (ADR-004 / Rule 14)."
        )
    
    # Prohibit automated NGO verification
    if any(k in lower for k in ["auto verify ngo", "approve ngo automatically", "grant darpan verification"]):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Policy Violation: Automated NGO verification is strictly prohibited. Only authorized human administrators can verify 12A/80G/Darpan credentials."
        )

    # Prohibit individual beneficiary eligibility determination
    if any(k in lower for k in ["beneficiary eligibility", "score welfare", "filter poor"]):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ethical AI Violation: Automated welfare eligibility scoring is barred. Distribution decisions belong strictly to partner NGOs."
        )
