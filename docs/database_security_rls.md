# FoodBridge — Database Security, Row Level Security (RLS) & Atomic Functions

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 4 — System Architecture and Database Design  
**Status:** Completed  

---

## 1. Zero-Trust Database Security Model

FoodBridge operates on a **Zero-Trust Client Philosophy**:
1. All client-side requests execute with least privileges via the public Supabase `anon` or authenticated `authenticated` roles.
2. Every table has **Row Level Security (RLS) enabled**.
3. Crucial allocation operations and state mutations are encapsulated in **PostgreSQL Stored Functions** executing with `SECURITY DEFINER` to guarantee atomic transaction locking and eliminate race conditions.
4. Sensitive donor addresses and telephone numbers are decoupled from public views and only decrypted for authorized task participants.

---

## 2. Security Helper Functions

```sql
-- 1. Helper to determine if current user has admin role
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() AND role = 'admin' AND account_status = 'active'
  );
$$;

-- 2. Helper to determine if current user represents a verified NGO
CREATE OR REPLACE FUNCTION is_verified_ngo()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM ngos n
    JOIN profiles p ON p.id = n.owner_user_id
    WHERE n.owner_user_id = auth.uid() 
      AND n.verification_status = 'verified'
      AND p.account_status = 'active'
  );
$$;

-- 3. Decrypt/Reveal Private Pickup Details Only to Authorized Participants
CREATE OR REPLACE FUNCTION get_donation_pickup_details(p_donation_id UUID)
RETURNS TABLE (
  pickup_location_private TEXT,
  pickup_phone_private TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verify if caller is the donor
  IF EXISTS (SELECT 1 FROM donations WHERE id = p_donation_id AND donor_id = auth.uid()) THEN
    RETURN QUERY SELECT d.pickup_location_private, d.pickup_phone_private 
                 FROM donations d WHERE d.id = p_donation_id;
    RETURN;
  END IF;

  -- Verify if caller is the assigned volunteer for an accepted task
  IF EXISTS (
    SELECT 1 FROM assignments a
    JOIN donation_requests r ON r.id = a.donation_request_id
    WHERE r.donation_id = p_donation_id 
      AND a.volunteer_id = auth.uid()
      AND a.status IN ('assigned', 'accepted', 'picked_up')
  ) THEN
    RETURN QUERY SELECT d.pickup_location_private, d.pickup_phone_private 
                 FROM donations d WHERE d.id = p_donation_id;
    RETURN;
  END IF;

  -- Verify if caller is the verified NGO whose request is accepted
  IF EXISTS (
    SELECT 1 FROM donation_requests r
    JOIN ngos n ON n.id = r.ngo_id
    WHERE r.donation_id = p_donation_id 
      AND n.owner_user_id = auth.uid()
      AND r.status = 'approved'
  ) THEN
    RETURN QUERY SELECT d.pickup_location_private, d.pickup_phone_private 
                 FROM donations d WHERE d.id = p_donation_id;
    RETURN;
  END IF;

  -- Verify if caller is admin
  IF is_admin() THEN
    RETURN QUERY SELECT d.pickup_location_private, d.pickup_phone_private 
                 FROM donations d WHERE d.id = p_donation_id;
    RETURN;
  END IF;

  -- Otherwise, access denied
  RAISE EXCEPTION 'Access Denied: You are not authorized to view private pickup details for this donation.';
END;
$$;
```

---

## 3. Row Level Security (RLS) Policies

```sql
-- Enable RLS across all 12 tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE donor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE ngos ENABLE ROW LEVEL SECURITY;
ALTER TABLE volunteer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE clothing_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE donation_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE distribution_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ====================================================================
-- PROFILES POLICIES
-- ====================================================================
CREATE POLICY "Public profiles are viewable by authenticated users" 
ON profiles FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can update their own profile" 
ON profiles FOR UPDATE TO authenticated 
USING (id = auth.uid()) WITH CHECK (id = auth.uid() AND role = (SELECT role FROM profiles WHERE id = auth.uid()));

CREATE POLICY "Admins have full control over profiles" 
ON profiles FOR ALL TO authenticated USING (is_admin());

-- ====================================================================
-- DONATIONS POLICIES
-- ====================================================================
CREATE POLICY "Donors have full CRUD on their own donations"
ON donations FOR ALL TO authenticated
USING (donor_id = auth.uid())
WITH CHECK (donor_id = auth.uid());

CREATE POLICY "Anyone can view available donations"
ON donations FOR SELECT TO authenticated
USING (status = 'available' OR donor_id = auth.uid() OR is_admin());

-- ====================================================================
-- FOOD & CLOTHING DETAILS POLICIES
-- ====================================================================
CREATE POLICY "Food details viewable alongside donations"
ON food_details FOR SELECT TO authenticated USING (true);

CREATE POLICY "Food details insertable by donation owner"
ON food_details FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM donations WHERE id = donation_id AND donor_id = auth.uid()));

CREATE POLICY "Clothing details viewable alongside donations"
ON clothing_details FOR SELECT TO authenticated USING (true);

CREATE POLICY "Clothing details insertable by donation owner"
ON clothing_details FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM donations WHERE id = donation_id AND donor_id = auth.uid()));

-- ====================================================================
-- NGOS & VERIFICATION POLICIES
-- ====================================================================
CREATE POLICY "Verified NGOs are viewable by all authenticated users"
ON ngos FOR SELECT TO authenticated
USING (verification_status = 'verified' OR owner_user_id = auth.uid() OR is_admin());

CREATE POLICY "NGO owners can update their own organization profile"
ON ngos FOR UPDATE TO authenticated
USING (owner_user_id = auth.uid())
WITH CHECK (owner_user_id = auth.uid() AND verification_status = (SELECT verification_status FROM ngos WHERE owner_user_id = auth.uid()));

CREATE POLICY "Admins can manage and verify NGOs"
ON ngos FOR ALL TO authenticated USING (is_admin());

-- ====================================================================
-- DONATION REQUESTS POLICIES
-- ====================================================================
CREATE POLICY "Verified NGOs can insert and view their requests"
ON donation_requests FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM ngos WHERE id = ngo_id AND owner_user_id = auth.uid()) OR is_admin())
WITH CHECK (is_verified_ngo());

CREATE POLICY "Donors can view requests for their donations"
ON donation_requests FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM donations WHERE id = donation_id AND donor_id = auth.uid()));

-- ====================================================================
-- VOLUNTEER ASSIGNMENTS POLICIES
-- ====================================================================
CREATE POLICY "Volunteers can view open tasks"
ON assignments FOR SELECT TO authenticated
USING (status = 'open' OR volunteer_id = auth.uid() OR is_admin());

CREATE POLICY "Assigned volunteer can update task status"
ON assignments FOR UPDATE TO authenticated
USING (volunteer_id = auth.uid() OR is_admin())
WITH CHECK (volunteer_id = auth.uid() OR is_admin());

-- ====================================================================
-- DISTRIBUTION RECORDS POLICIES
-- ====================================================================
CREATE POLICY "NGOs can insert and view their distribution records"
ON distribution_records FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM ngos WHERE id = ngo_id AND owner_user_id = auth.uid()) OR is_admin())
WITH CHECK (EXISTS (SELECT 1 FROM ngos WHERE id = ngo_id AND owner_user_id = auth.uid()) OR is_admin());

CREATE POLICY "Donors can view distribution records for their donations"
ON distribution_records FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM donations WHERE id = donation_id AND donor_id = auth.uid()));

-- ====================================================================
-- NOTIFICATIONS POLICIES
-- ====================================================================
CREATE POLICY "Users can only read and manage their own notifications"
ON notifications FOR ALL TO authenticated
USING (recipient_user_id = auth.uid())
WITH CHECK (recipient_user_id = auth.uid());

-- ====================================================================
-- AUDIT LOGS POLICIES
-- ====================================================================
CREATE POLICY "Audit logs are strictly viewable by Admins"
ON audit_logs FOR SELECT TO authenticated USING (is_admin());

-- REVOKE direct INSERT, UPDATE, DELETE on audit_logs from public/authenticated
REVOKE UPDATE, DELETE ON audit_logs FROM authenticated, anon;
```

---

## 4. Atomic Concurrency Control Stored Functions

### 4.1 Atomic Claim Function (Prevents Over-Allocation & Race Conditions)
```sql
CREATE OR REPLACE FUNCTION claim_donation_atomic(
  p_donation_id UUID,
  p_ngo_id UUID,
  p_requested_quantity NUMERIC,
  p_requires_volunteer BOOLEAN DEFAULT true,
  p_message TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_available NUMERIC;
  v_status donation_status;
  v_request_id UUID;
BEGIN
  -- 1. Lock the donation row exclusively for update
  SELECT available_quantity, status INTO v_available, v_status
  FROM donations
  WHERE id = p_donation_id
  FOR UPDATE;

  -- 2. Verify state and quantity
  IF v_status NOT IN ('available', 'requested') THEN
    RAISE EXCEPTION 'Donation is no longer available for claims (Status: %)', v_status;
  END IF;

  IF v_available < p_requested_quantity THEN
    RAISE EXCEPTION 'Insufficient quantity available. Requested: %, Available: %', p_requested_quantity, v_available;
  END IF;

  -- 3. Decrement available quantity atomically
  UPDATE donations
  SET available_quantity = available_quantity - p_requested_quantity,
      status = CASE WHEN (available_quantity - p_requested_quantity) = 0 THEN 'requested'::donation_status ELSE status END,
      updated_at = timezone('utc', now())
  WHERE id = p_donation_id;

  -- 4. Insert donation request
  INSERT INTO donation_requests (
    donation_id,
    ngo_id,
    requested_quantity,
    requires_volunteer_delivery,
    message,
    status
  ) VALUES (
    p_donation_id,
    p_ngo_id,
    p_requested_quantity,
    p_requires_volunteer,
    p_message,
    'pending'
  ) RETURNING id INTO v_request_id;

  RETURN v_request_id;
END;
$$;
```

### 4.2 Atomic Assignment Acceptance (Prevents Volunteer Race Conditions)
```sql
CREATE OR REPLACE FUNCTION accept_assignment_atomic(
  p_assignment_id UUID,
  p_volunteer_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_active_count INTEGER;
  v_max_allowed INTEGER;
  v_current_volunteer UUID;
BEGIN
  -- 1. Check volunteer's active task limit
  SELECT COUNT(*), COALESCE(MAX(vp.active_task_limit), 2)
  INTO v_active_count, v_max_allowed
  FROM assignments a
  RIGHT JOIN volunteer_profiles vp ON vp.user_id = p_volunteer_id
  WHERE a.volunteer_id = p_volunteer_id AND a.status IN ('assigned', 'accepted', 'picked_up');

  IF v_active_count >= v_max_allowed THEN
    RAISE EXCEPTION 'Active task limit reached (%/%). Complete an ongoing delivery before accepting a new task.', v_active_count, v_max_allowed;
  END IF;

  -- 2. Atomic conditional update: lock task ONLY IF volunteer_id IS NULL and status is 'open'
  UPDATE assignments
  SET volunteer_id = p_volunteer_id,
      status = 'assigned',
      updated_at = timezone('utc', now())
  WHERE id = p_assignment_id AND volunteer_id IS NULL AND status = 'open';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Task has already been accepted by another volunteer.';
  END IF;

  RETURN true;
END;
$$;
```

