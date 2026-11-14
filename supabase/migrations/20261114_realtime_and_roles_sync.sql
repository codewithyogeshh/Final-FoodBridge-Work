-- ============================================================================
-- FoodBridge Real-Time Multi-Role Sync & Permissive RLS Policies
-- Enables live synchronization across Donor, NGO, Volunteer, and Admin
-- ============================================================================

-- 1. Ensure Full Replica Identity so Supabase Realtime sends complete payloads
ALTER TABLE public.donations REPLICA IDENTITY FULL;
ALTER TABLE public.profiles REPLICA IDENTITY FULL;
ALTER TABLE public.food_details REPLICA IDENTITY FULL;
ALTER TABLE public.clothing_details REPLICA IDENTITY FULL;
ALTER TABLE public.donation_requests REPLICA IDENTITY FULL;
ALTER TABLE public.assignments REPLICA IDENTITY FULL;

-- 2. Permissive RLS Policies for Profiles (Any role can view donors, NGOs, volunteers)
DROP POLICY IF EXISTS "Public profiles are readable" ON public.profiles;
CREATE POLICY "Public profiles are readable" ON public.profiles
    FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Users can insert profiles" ON public.profiles;
CREATE POLICY "Users can insert profiles" ON public.profiles
    FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
CREATE POLICY "Users update own profile" ON public.profiles
    FOR UPDATE USING (TRUE);

-- 3. Permissive RLS Policies for Donations (Visible to Donor, NGO, Volunteer, Admin)
DROP POLICY IF EXISTS "Donations are readable" ON public.donations;
DROP POLICY IF EXISTS "Donations are readable by all" ON public.donations;
CREATE POLICY "Donations are readable by all" ON public.donations
    FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Donors can create donations" ON public.donations;
CREATE POLICY "Donors can create donations" ON public.donations
    FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Donations can be updated" ON public.donations;
CREATE POLICY "Donations can be updated" ON public.donations
    FOR UPDATE USING (TRUE);

-- 4. Permissive RLS Policies for Food Details
DROP POLICY IF EXISTS "Food details are readable" ON public.food_details;
CREATE POLICY "Food details are readable" ON public.food_details
    FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Food details can be inserted" ON public.food_details;
CREATE POLICY "Food details can be inserted" ON public.food_details
    FOR INSERT WITH CHECK (TRUE);

-- 5. Permissive RLS Policies for Clothing Details
DROP POLICY IF EXISTS "Clothing details are readable" ON public.clothing_details;
CREATE POLICY "Clothing details are readable" ON public.clothing_details
    FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Clothing details can be inserted" ON public.clothing_details;
CREATE POLICY "Clothing details can be inserted" ON public.clothing_details
    FOR INSERT WITH CHECK (TRUE);

-- 6. Permissive RLS Policies for Role Tables
DROP POLICY IF EXISTS "Donor profiles are readable" ON public.donor_profiles;
CREATE POLICY "Donor profiles are readable" ON public.donor_profiles FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Donor profiles insert" ON public.donor_profiles;
CREATE POLICY "Donor profiles insert" ON public.donor_profiles FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "NGOs are readable" ON public.ngos;
CREATE POLICY "NGOs are readable" ON public.ngos FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "NGOs insert" ON public.ngos;
CREATE POLICY "NGOs insert" ON public.ngos FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Volunteer profiles are readable" ON public.volunteer_profiles;
CREATE POLICY "Volunteer profiles are readable" ON public.volunteer_profiles FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Volunteer profiles insert" ON public.volunteer_profiles;
CREATE POLICY "Volunteer profiles insert" ON public.volunteer_profiles FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Assignments readable" ON public.assignments;
CREATE POLICY "Assignments readable" ON public.assignments FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Assignments insert" ON public.assignments;
CREATE POLICY "Assignments insert" ON public.assignments FOR INSERT WITH CHECK (TRUE);
DROP POLICY IF EXISTS "Assignments update" ON public.assignments;
CREATE POLICY "Assignments update" ON public.assignments FOR UPDATE USING (TRUE);

-- 7. Ensure All Tables are Added to Supabase Realtime Publication
DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.donations;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.food_details;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.clothing_details;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.donation_requests;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.assignments;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
END $$;

-- 8. Ensure Realtime Tracking Columns on Donations Table
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS claimed_by_ngo_id TEXT;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS claimed_by_ngo_name TEXT;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMPTZ;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS assigned_volunteer_id TEXT;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS assigned_volunteer_name TEXT;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS assigned_volunteer_phone TEXT;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMPTZ;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS picked_up_at TIMESTAMPTZ;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMPTZ;



