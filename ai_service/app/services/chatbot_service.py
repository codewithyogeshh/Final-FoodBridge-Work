"""
FoodBridge AI Microservice - Feature 4: AI Chatbot Service (FoodBridge Assistant)
Answers questions on:
- User registration & role requirements
- Donation creation & hygiene charter
- NGO discovery, claiming, and partial allocation
- Volunteer task acceptance, navigation, dual OTPs, and emergency release
- App navigation & profile switching
- Frequently Asked Questions (two-tier privacy, Rule 14 disclaimer)

Uses approved project documentation as its authoritative source.
Includes PII sanitization and safety enforcement.
"""
import os
import json
from typing import List, Dict, Any
from app.models.schemas import (
    ChatbotQueryRequest,
    ChatbotResponse,
    KnowledgeSource,
)
from app.core.security import sanitize_pii, guard_prohibited_ai_actions


class FoodBridgeChatbotService:
    _knowledge_cache: List[Dict[str, Any]] = []

    @classmethod
    def load_knowledge_base(cls) -> List[Dict[str, Any]]:
        if cls._knowledge_cache:
            return cls._knowledge_cache

        base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        kb_path = os.path.join(base_dir, "knowledge_base", "foodbridge_knowledge.json")

        if os.path.exists(kb_path):
            with open(kb_path, "r", encoding="utf-8") as f:
                cls._knowledge_cache = json.load(f)
        else:
            cls._knowledge_cache = []
        return cls._knowledge_cache

    @classmethod
    def answer_query(cls, request: ChatbotQueryRequest) -> ChatbotResponse:
        # 1. PII Sanitization
        sanitized_query = sanitize_pii(request.message)

        # 2. Guard against prohibited AI actions (Rule 14 & auto-approvals)
        guard_prohibited_ai_actions("chatbot_query", sanitized_query)

        # 3. Retrieve knowledge base
        kb = cls.load_knowledge_base()

        # 4. Search and match relevant entries
        q_tokens = set(sanitized_query.lower().split())
        best_entry: Dict[str, Any] = {}
        best_score = 0.0

        for entry in kb:
            score = 0.0
            keywords = entry.get("keywords", [])
            topic = entry.get("topic", "")

            # Exact keyword matches
            for kw in keywords:
                if kw in sanitized_query.lower():
                    score += 2.0
                else:
                    kw_tokens = set(kw.lower().split())
                    if kw_tokens.intersection(q_tokens):
                        score += 0.8

            # Topic match
            if topic in sanitized_query.lower():
                score += 1.5

            if score > best_score:
                best_score = score
                best_entry = entry

        # 5. Format response
        if best_entry and best_score >= 1.2:
            sources = [
                KnowledgeSource(
                    doc_id=best_entry.get("source_doc", "FoodBridge Documentation"),
                    section=best_entry.get("section", "General"),
                    relevance_score=min(1.0, round(best_score / 4.0, 2)),
                )
            ]
            reply = f"**{best_entry.get('title')}**\n\n{best_entry.get('details')}"
            followups = best_entry.get("suggested_followups", [])
            matched_intent = best_entry.get("topic", "faq")
            confidence = min(0.98, max(0.65, round(best_score / 4.0, 2)))
        else:
            # Fallback for general unindexed queries
            reply = (
                "FoodBridge connects food and clothing donors, verified NGOs, and volunteer couriers to reduce waste and bridge need.\n\n"
                "I can assist you with:\n"
                "• **Registration & Verification** (Donor, NGO 12A/80G/Darpan, Volunteer)\n"
                "• **Publishing Donations** (Cooked meals, raw produce, packaged rations, clothing)\n"
                "• **NGO Claiming** (Discovery feed, atomic claims, partial quantity allocation)\n"
                "• **Volunteer Delivery** (GPS navigation, 2-task limit, dual Pickup/Delivery OTPs)\n"
                "• **Platform Privacy & Safety** (Two-tier address protection, Rule 14 food charter)\n\n"
                "Feel free to ask a specific question or contact support at support@foodbridge.org."
            )
            sources = [
                KnowledgeSource(
                    doc_id="docs/requirement_analysis.md",
                    section="Section 1: Project Overview",
                    relevance_score=0.50,
                )
            ]
            followups = [
                "How do I donate food?",
                "What is the volunteer 2-task limit?",
                "How does NGO verification work?",
            ]
            matched_intent = "general_fallback"
            confidence = 0.50

        return ChatbotResponse(
            reply=reply,
            matched_intent=matched_intent,
            confidence=confidence,
            sources=sources,
            suggested_quick_replies=followups,
            support_escalation_available=True,
        )
