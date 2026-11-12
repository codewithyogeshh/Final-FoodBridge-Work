# FoodBridge Backend API Contracts & Atomic Transactions

This document defines the server-side RPC stored procedures in PostgreSQL to ensure ACID transactional integrity and race-condition immunity.

---

## 1. Atomic Transaction Contracts

### 1.1 `claim_donation_atomic`
Locks the donation row using `FOR UPDATE`, checks availability and NGO verification, creates the claim request, and advances the status to `claimed`.

```sql
CREATE OR REPLACE FUNCTION claim_donation_atomic(
    p_donation_id UUID,
    p_ngo_id UUID,
    p_quantity NUMERIC
)
RETURNS JSONB AS $$
DECLARE
    v_donation RECORD;
    v_ngo_verified BOOLEAN;
BEGIN
    -- 1. Check if caller represents a verified NGO
    SELECT (verification_status = 'verified') INTO v_ngo_verified
    FROM public.ngos WHERE id = p_ngo_id;

    IF NOT COALESCE(v_ngo_verified, FALSE) THEN
        RAISE EXCEPTION 'UNAUTHORIZED: NGO is not verified to claim donations.'
            USING ERRCODE = 'FB001';
    END IF;

    -- 2. Acquire exclusive row lock on the donation
    SELECT * INTO v_donation
    FROM public.donations
    WHERE id = p_donation_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'NOT_FOUND: Donation does not exist.'
            USING ERRCODE = 'FB002';
    END IF;

    -- 3. Verify status and expiry
    IF v_donation.status != 'listed' THEN
        RAISE EXCEPTION 'CONFLICT: Donation is already claimed or no longer available.'
            USING ERRCODE = 'FB003';
    END IF;

    IF v_donation.pickup_deadline < NOW() THEN
        UPDATE public.donations SET status = 'expired' WHERE id = p_donation_id;
        RAISE EXCEPTION 'EXPIRED: Collection deadline has elapsed.'
            USING ERRCODE = 'FB004';
    END IF;

    -- 4. Record claim request
    INSERT INTO public.donation_requests(donation_id, ngo_id, requested_quantity, status)
    VALUES (p_donation_id, p_ngo_id, p_quantity, 'active');

    -- 5. Update donation state
    UPDATE public.donations
    SET status = 'claimed', updated_at = NOW()
    WHERE id = p_donation_id;

    -- 6. Insert audit trail
    INSERT INTO public.audit_logs(actor_id, action, entity_type, entity_id, details)
    VALUES (
        auth.uid(),
        'DONATION_CLAIMED',
        'donations',
        p_donation_id,
        jsonb_build_object('ngo_id', p_ngo_id, 'quantity', p_quantity)
    );

    RETURN jsonb_build_object(
        'success', TRUE,
        'donation_id', p_donation_id,
        'status', 'claimed'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### 1.2 `accept_assignment_atomic`
Ensures that only **one single volunteer** can lock and accept an available dispatch.

```sql
CREATE OR REPLACE FUNCTION accept_assignment_atomic(
    p_donation_id UUID,
    p_ngo_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_volunteer_id UUID := auth.uid();
    v_active_task_count INT;
    v_max_tasks INT;
    v_donation RECORD;
BEGIN
    -- 1. Check volunteer concurrency limit
    SELECT COUNT(*) INTO v_active_task_count
    FROM public.assignments
    WHERE volunteer_id = v_volunteer_id
    AND status IN ('assigned', 'in_transit');

    SELECT COALESCE(max_active_tasks, 2) INTO v_max_tasks
    FROM public.volunteer_profiles
    WHERE user_id = v_volunteer_id;

    IF v_active_task_count >= v_max_tasks THEN
        RAISE EXCEPTION 'LIMIT_EXCEEDED: You have reached the maximum allowed concurrent dispatches (% tasks). Complete your active task first.', v_max_tasks
            USING ERRCODE = 'FB010';
    END IF;

    -- 2. Lock donation row
    SELECT * INTO v_donation
    FROM public.donations
    WHERE id = p_donation_id
    FOR UPDATE;

    IF v_donation.status != 'claimed' THEN
        RAISE EXCEPTION 'CONFLICT: Dispatch task is no longer available.'
            USING ERRCODE = 'FB011';
    END IF;

    -- 3. Create or lock assignment record
    INSERT INTO public.assignments (donation_id, ngo_id, volunteer_id, status)
    VALUES (p_donation_id, p_ngo_id, v_volunteer_id, 'assigned')
    ON CONFLICT (donation_id) DO NOTHING;

    -- 4. Update donation state
    UPDATE public.donations
    SET status = 'assigned', updated_at = NOW()
    WHERE id = p_donation_id;

    RETURN jsonb_build_object(
        'success', TRUE,
        'donation_id', p_donation_id,
        'volunteer_id', v_volunteer_id,
        'status', 'assigned'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### 1.3 `confirm_pickup_atomic` & `confirm_delivery_atomic`
- `confirm_pickup_atomic(p_donation_id)`: Transitions assignment and donation to `picked_up` / `in_transit`, sets `picked_up_at = NOW()`.
- `confirm_delivery_atomic(p_donation_id, p_beneficiaries_served)`: Transitions status to `delivered`, creates `distribution_records`, increments volunteer's completed delivery score, and triggers completion audit log.

---

## 2. Client-Side Dart Interface Contract
```dart
abstract class IDonationRpcService {
  Future<Map<String, dynamic>> claimDonation({
    required String donationId,
    required String ngoId,
    required double quantity,
  });

  Future<Map<String, dynamic>> acceptAssignment({
    required String donationId,
    required String ngoId,
  });

  Future<bool> confirmPickup(String donationId);

  Future<bool> confirmDelivery({
    required String donationId,
    required int beneficiariesCount,
    String? handoverNotes,
  });
}
```

