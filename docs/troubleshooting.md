# FoodBridge Operational Troubleshooting Guide
**SDLC Phase 12: Deployment & Maintenance**

---

## 1. Authentication & Access Issues

### 1.1. "Verification Required: Only verified NGOs can claim donations"
- **Cause:** The NGO account is newly registered and remains in `pending` status.
- **Resolution:**
  1. Log into the FoodBridge **Admin Console** as an administrator.
  2. Navigate to the **NGO Approvals** tab.
  3. Inspect the NGO's Darpan ID and 12A/80G document upload.
  4. Tap **Approve Verification**. The NGO account immediately gains claim privileges.

### 1.2. "Maximum concurrent dispatch limit reached (2 active tasks)"
- **Cause:** Volunteer has reached the safety cap of 2 active concurrent deliveries.
- **Resolution:**
  1. The courier must complete handover of at least one active delivery using the NGO's 4-digit Receipt OTP.
  2. If a vehicle breakdown or emergency occurred, tap the **Emergency Release** button on the active mission card to release the task back to the community pool.

---

## 2. Donation & Claiming Operations

### 2.1. "Requested quantity exceeds available stock"
- **Cause:** Another NGO concurrently claimed part of the listing, or the requested quantity exceeds the remaining unallocated balance.
- **Resolution:** Pull down to refresh the Available Feed to view current remaining stock. Enter a partial quantity $\le$ the remaining balance.

### 2.2. "Cannot claim this donation. Current status is..."
- **Cause:** The listing has expired, been cancelled, or already been allocated to another shelter.
- **Resolution:** Check the listing status chip. Expired food items are strictly locked to protect public health.

---

## 3. Volunteer Delivery & OTP Verification

### 3.1. "Invalid Pickup OTP code"
- **Cause:** Volunteer entered an incorrect 4-digit code.
- **Resolution:** Ask the donor to verify the 4-digit Pickup Code displayed on their Donor Dashboard active listing card.

### 3.2. "Invalid Delivery Receipt OTP code"
- **Cause:** Volunteer entered an incorrect 4-digit handover code.
- **Resolution:** The receiving shelter inventory manager must read the 4-digit code displayed in their NGO incoming deliveries feed.

---

## 4. AI Microservice Connectivity

### 4.1. HTTP `401 Unauthorized` on AI Endpoints
- **Cause:** Missing or mismatched `X-API-Key` or Bearer token.
- **Resolution:** Ensure `FOODBRIDGE_AI_API_KEY` matches between the client environment and the server `.env`.

### 4.2. HTTP `400 Bad Request: Safety Violation (Rule 14)`
- **Cause:** Query or image metadata requested food freshness or edibility certification.
- **Resolution:** AI cannot certify food safety under platform charter. The donor must agree to the FSSAI hygiene pledge and the receiving NGO must perform physical inspection.

---

## 5. Android & Build Issues

### 5.1. Gradle Cache Invalidation
If Gradle builds fail due to corrupted lock files:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

