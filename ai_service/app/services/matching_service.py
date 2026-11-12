"""
FoodBridge AI Microservice - Feature 1: Intelligent NGO Matching Service
Explainable rules-based matching algorithm evaluating:
- Donation Type & Subcategory
- Service Area / Zone Proximity
- Quantity vs NGO Capacity (including partial allocation)
- Storage Capabilities (Cold-chain, ambient, hot-holding)
- Availability & Urgency (Hours to pickup deadline)
"""
from typing import List
from app.models.schemas import (
    DonationInput,
    NgoCandidateInput,
    NgoMatchResult,
    ScoreBreakdown,
    MatchingResponse,
)


class IntelligentMatchingService:
    @staticmethod
    def match_ngos(
        donation: DonationInput,
        candidates: List[NgoCandidateInput],
        min_threshold: float = 40.0,
    ) -> MatchingResponse:
        results: List[NgoMatchResult] = []

        for candidate in candidates:
            # 1. Hard eligibility filters
            # Rule: Only verified NGOs can match
            if not candidate.is_verified:
                continue

            # Rule: NGO must be currently available
            if not candidate.is_available:
                continue

            # Rule: NGO must accept the donation type
            if donation.type.lower() not in [t.lower() for t in candidate.accepted_types]:
                continue

            # 2. Type & Category Compatibility (Weight: 10%)
            type_score = 100.0

            # 3. Service Area & Proximity Score (Weight: 30%)
            area_score = 0.0
            donor_zone = donation.service_area.strip().lower()
            candidate_zones = [z.strip().lower() for z in candidate.service_areas]

            if donor_zone in candidate_zones:
                area_score = 100.0
            elif any(donor_zone in z or z in donor_zone for z in candidate_zones):
                area_score = 85.0
            elif "pune" in candidate_zones or "all_city" in candidate_zones:
                area_score = 65.0
            else:
                area_score = 30.0

            # 4. Capacity Fit Score (Weight: 25%)
            capacity_score = 0.0
            can_handle_full = candidate.capacity_available >= donation.quantity

            if can_handle_full:
                # Optimal fit: NGO capacity is between 1.0x and 3.0x donation quantity
                ratio = candidate.capacity_available / donation.quantity
                if 1.0 <= ratio <= 3.0:
                    capacity_score = 100.0
                else:
                    # Excess capacity is still good, minor penalty for over-scaling
                    capacity_score = max(75.0, 100.0 - (ratio - 3.0) * 2)
            else:
                # Partial capacity allocation possible
                fraction = candidate.capacity_available / max(1.0, donation.quantity)
                capacity_score = max(20.0, fraction * 70.0)

            # 5. Storage Condition Compatibility (Weight: 20%)
            storage_score = 100.0
            req_storage = (donation.storage_requirement or "ambient").lower().strip()
            caps = [c.lower().strip() for c in candidate.storage_capabilities]

            if donation.type == "food":
                if req_storage == "chilled":
                    if "cold_storage" in caps or "chilled" in caps or "refrigerated" in caps:
                        storage_score = 100.0
                    else:
                        storage_score = 30.0  # Significant penalty if cold chain is missing
                elif req_storage == "hot":
                    if "hot_holding" in caps or "insulated" in caps or "immediate_distribution" in caps:
                        storage_score = 100.0
                    else:
                        storage_score = 60.0
                else:
                    # Ambient food
                    storage_score = 100.0
            else:
                # Clothing
                storage_score = 100.0

            # 6. Urgency & Responsiveness Score (Weight: 15%)
            urgency_score = 80.0
            urgency_hours = donation.urgency_hours_left or 4.0

            if urgency_hours <= 2.5:
                # Urgent rescue: prioritize exact zone NGOs
                if area_score >= 85.0:
                    urgency_score = 100.0
                else:
                    urgency_score = 50.0  # Remote NGOs cannot meet tight 2.5h window
            elif urgency_hours <= 6.0:
                urgency_score = 90.0
            else:
                urgency_score = 85.0

            # 7. Compute Aggregate Weighted Score
            # Weights: Area 30%, Capacity 25%, Storage 20%, Urgency 15%, Type 10%
            total_score = (
                (area_score * 0.30)
                + (capacity_score * 0.25)
                + (storage_score * 0.20)
                + (urgency_score * 0.15)
                + (type_score * 0.10)
            )
            total_score = round(min(100.0, max(0.0, total_score)), 1)

            if total_score < min_threshold:
                continue

            # Determine Tier
            if total_score >= 85.0:
                tier = "EXCELLENT_MATCH"
            elif total_score >= 70.0:
                tier = "GOOD_MATCH"
            else:
                tier = "FAIR_MATCH"

            # 8. Generate Human-Readable Explainability
            reasons = []
            if area_score >= 85.0:
                reasons.append(f"Direct operational presence in {donation.service_area}")
            else:
                reasons.append(f"Covers surrounding district zone")

            if can_handle_full:
                reasons.append(
                    f"Full quantity capacity available ({int(candidate.capacity_available)}/{int(donation.quantity)} {donation.unit})"
                )
            else:
                reasons.append(
                    f"Partial capacity allocation ({int(candidate.capacity_available)} {donation.unit} available)"
                )

            if req_storage == "chilled" and storage_score >= 90:
                reasons.append("Equipped with certified cold-storage facilities")
            elif req_storage == "hot":
                reasons.append("Equipped for immediate rapid meal distribution")

            if urgency_hours <= 2.5 and area_score >= 85:
                reasons.append("Nearby response team can meet urgent collection deadline")

            explanation = " • ".join(reasons)

            results.append(
                NgoMatchResult(
                    ngo_id=candidate.id,
                    ngo_name=candidate.name,
                    match_score=total_score,
                    tier=tier,
                    score_breakdown=ScoreBreakdown(
                        area_match_score=area_score,
                        capacity_score=capacity_score,
                        storage_score=storage_score,
                        urgency_score=urgency_score,
                        type_score=type_score,
                    ),
                    explanation=explanation,
                    can_handle_full_quantity=can_handle_full,
                )
            )

        # Sort matches by score descending
        results.sort(key=lambda r: r.match_score, reverse=True)

        return MatchingResponse(
            donation_id=donation.id,
            total_candidates_evaluated=len(candidates),
            matches_found=len(results),
            matches=results,
        )
