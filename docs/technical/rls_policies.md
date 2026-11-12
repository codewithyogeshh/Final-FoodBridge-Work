# FoodBridge Row Level Security (RLS) Policies

This document specifies the PostgreSQL Row Level Security (RLS) policies implemented on Supabase to enforce role-based access control and protect sensitive PII.

```sql
-- Enable RLS across all application tables
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

-- ============================================================================
-- HELPER FUNCTIONS FOR ROLE CHECKS (RUN AS SECURITY DEFINER)
-- ============================================================================
CREATE OR REPLACE FUNCTION auth.get_user_role()
RETURNS user_role AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION auth.is_verified_ngo()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.ngos
        WHERE user_id = auth.uid() AND verification_status = 'verified'
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
    SELECT (auth.get_user_role() = 'admin');
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ============================================================================
-- 1. PROFILES POLICIES
-- ============================================================================
-- Anyone can view public profile names (donors, volunteers)
CREATE POLICY "Public profiles are readable by authenticated users"
ON profiles FOR SELECT
TO authenticated
USING (TRUE);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- ============================================================================
-- 2. DONATIONS & DETAILS POLICIES
-- ============================================================================
-- Donors can create their own listings
CREATE POLICY "Donors can create donations"
ON donations FOR INSERT
TO authenticated
WITH CHECK (donor_id = auth.uid() AND auth.get_user_role() = 'donor');

-- Anyone authenticated can view active listings
CREATE POLICY "Available donations are readable by authenticated users"
ON donations FOR SELECT
TO authenticated
USING (
    status = 'listed'
    OR donor_id = auth.uid()
    OR auth.is_admin()
    OR EXISTS (
        SELECT 1 FROM assignments a
        WHERE a.donation_id = donations.id
        AND (a.volunteer_id = auth.uid() OR a.ngo_id IN (SELECT id FROM ngos WHERE user_id = auth.uid()))
    )
);

-- Food & Clothing details inherit visibility from parent donation
CREATE POLICY "Food details readable if parent donation is readable"
ON food_details FOR SELECT
TO authenticated
USING (EXISTS (SELECT 1 FROM donations d WHERE d.id = food_details.donation_id));

CREATE POLICY "Clothing details readable if parent donation is readable"
ON clothing_details FOR SELECT
TO authenticated
USING (EXISTS (SELECT 1 FROM donations d WHERE d.id = clothing_details.donation_id));

-- ============================================================================
-- 3. ASSIGNMENTS & SENSITIVE LOCATION ACCESS POLICIES
-- ============================================================================
-- Address Protection: Volunteers only see pickup details for assigned tasks
CREATE POLICY "Volunteers can view their assigned dispatches"
ON assignments FOR SELECT
TO authenticated
USING (
    volunteer_id = auth.uid()
    OR ngo_id IN (SELECT id FROM ngos WHERE user_id = auth.uid())
    OR auth.is_admin()
);

-- Volunteers can update assignment progress (picked_up, delivered)
CREATE POLICY "Assigned volunteer can update status"
ON assignments FOR UPDATE
TO authenticated
USING (volunteer_id = auth.uid())
WITH CHECK (volunteer_id = auth.uid());

-- ============================================================================
-- 4. NGO VERIFICATION & DOCUMENT POLICIES
-- ============================================================================
-- Only verified NGOs or Admins can claim donations
CREATE POLICY "Verified NGOs can insert donation requests"
ON donation_requests FOR INSERT
TO authenticated
WITH CHECK (auth.is_verified_ngo());

-- Only Admins can update NGO verification status
CREATE POLICY "Admins can update NGO verification"
ON ngos FOR UPDATE
TO authenticated
USING (auth.is_admin())
WITH CHECK (auth.is_admin());

-- Registration documents (12A/80G) are strictly private between NGO and Admin
CREATE POLICY "NGO can view own registration, Admin views all"
ON ngos FOR SELECT
TO authenticated
USING (user_id = auth.uid() OR auth.is_admin());

-- ============================================================================
-- 5. NOTIFICATIONS & AUDIT LOG POLICIES
-- ============================================================================
-- Users only access their own notifications
CREATE POLICY "Users access own notifications"
ON notifications FOR ALL
TO authenticated
USING (recipient_user_id = auth.uid())
WITH CHECK (recipient_user_id = auth.uid());

-- Audit logs are strictly append-only; readable only by Admins
CREATE POLICY "Audit logs insertable by system"
ON audit_logs FOR INSERT
TO authenticated
WITH CHECK (TRUE);

CREATE POLICY "Audit logs readable only by Admin"
ON audit_logs FOR SELECT
TO authenticated
USING (auth.is_admin());
```

