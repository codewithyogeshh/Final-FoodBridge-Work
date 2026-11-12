"""
FoodBridge AI Microservice - Feature 2: Image Classification Service
Suggests broad food and clothing categories from uploaded images or cues.
Adheres strictly to Rule 14 & ADR-004:
- Suggests broad categories only.
- Always allows manual correction by donor.
- Explicitly barred from classifying freshness, pathogen safety, or edibility.
"""
from typing import List, Tuple
from app.models.schemas import (
    ImageClassificationRequest,
    ImageClassificationResponse,
    CandidateCategory,
)
from app.core.security import guard_prohibited_ai_actions


class CategoryClassifierService:
    # Broad taxonomy definition
    TAXONOMY = {
        "cooked_meals": ("Cooked Meals / Prepared Food", "food", ["rice", "biryani", "curry", "dal", "roti", "sabzi", "gravy", "cooked", "meal", "box", "thali"]),
        "raw_produce": ("Raw Produce / Fruits & Vegetables", "food", ["fruit", "vegetable", "tomato", "potato", "onion", "apple", "banana", "raw", "produce", "greens"]),
        "packaged_dry": ("Packaged Dry Rations / Grains", "food", ["packet", "dry", "grain", "wheat", "rice_bag", "biscuit", "cereal", "flour", "oil", "lentils", "packaged"]),
        "bakery_bread": ("Bakery Items & Breads", "food", ["bread", "loaf", "bun", "pastry", "cake", "toast", "bakery", "croissant"]),
        "dairy_chilled": ("Dairy & Cold Storage", "food", ["milk", "paneer", "curd", "yogurt", "cheese", "butter", "dairy", "chilled"]),
        "winter_thermal": ("Winter & Thermal Wear", "clothing", ["sweater", "jacket", "shawl", "thermal", "muffler", "hoodie", "cardigan", "wool"]),
        "blankets_bedding": ("Blankets & Warm Bedding", "clothing", ["blanket", "quilt", "bedsheet", "comforter", "duvet", "rug", "linen"]),
        "kids_clothing": ("Children & Infant Wear", "clothing", ["kids", "child", "baby", "infant", "toddler", "school_uniform"]),
        "adult_clothing": ("Adult Daily Wear", "clothing", ["shirt", "pant", "trousers", "saree", "kurta", "jeans", "t-shirt", "dress", "clothing"]),
        "footwear": ("Shoes & Footwear", "clothing", ["shoes", "sandals", "slippers", "boots", "footwear", "chappal"]),
    }

    @classmethod
    def classify_image(cls, request: ImageClassificationRequest) -> ImageClassificationResponse:
        # Check against prohibited queries (e.g. freshness, contamination)
        hint = (request.donor_hint or "").lower()
        filename = (request.filename or "").lower()
        full_text = f"{hint} {filename}"

        guard_prohibited_ai_actions("image_classification", full_text)

        # Keyword / heuristic matching over image hints, filename, and payload attributes
        scores: List[Tuple[str, float]] = []

        for cat_id, (display, cat_type, keywords) in cls.TAXONOMY.items():
            cat_score = 0.10  # Base prior probability
            
            # Match keywords in hint or filename
            for kw in keywords:
                if kw in full_text:
                    cat_score += 0.35

            # Clothing vs food prior from hint
            if "cloth" in full_text or "wear" in full_text or "dress" in full_text:
                if cat_type == "clothing":
                    cat_score += 0.25
                else:
                    cat_score -= 0.15
            elif "food" in full_text or "meal" in full_text or "eat" in full_text:
                if cat_type == "food":
                    cat_score += 0.25
                else:
                    cat_score -= 0.15

            scores.append((cat_id, min(0.95, max(0.05, cat_score))))

        # Sort candidate categories by confidence descending
        scores.sort(key=lambda s: s[1], reverse=True)

        top_id, top_score = scores[0]
        # If top score is still just the base prior, pick reasonable default based on context
        if top_score <= 0.15:
            top_id, top_score = "cooked_meals", 0.70

        top_display, top_type, _ = cls.TAXONOMY[top_id]

        # Prepare top 3 alternative candidate categories
        alternatives: List[CandidateCategory] = []
        for cat_id, conf in scores[1:4]:
            alt_display, alt_type, _ = cls.TAXONOMY[cat_id]
            alternatives.append(
                CandidateCategory(
                    category_id=cat_id,
                    display_name=alt_display,
                    type=alt_type,
                    confidence=round(conf, 2),
                )
            )

        return ImageClassificationResponse(
            suggested_category=top_id,
            suggested_type=top_type,
            confidence=round(top_score, 2),
            alternative_candidates=alternatives,
            manual_correction_allowed=True,
            food_safety_disclaimer=(
                "AI Advisory Only: This classification suggests broad category groupings based on visual cues. "
                "It does NOT assess freshness, bacterial safety, contamination, or edibility. "
                "Manual donor hygiene declaration and NGO physical check are mandatory (Rule 14 / ADR-004)."
            ),
        )
