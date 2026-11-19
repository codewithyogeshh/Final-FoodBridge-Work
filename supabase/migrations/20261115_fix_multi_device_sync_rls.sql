-- ============================================================================
-- FoodBridge Multi-Device Realtime & Database Persistence Sync Fix
-- Solves foreign key constraints and enables seamless multi-device sync
-- ============================================================================

-- 1. Remove strict foreign keys that block demo/offline users without matching auth.users row:
ALTER TABLE public.donations DROP CONSTRAINT IF EXISTS donations_donor_id_fkey;
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- 2. Add image_url column to donations table if not present:
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 3. Enable permissive RLS policies on profiles:
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public profiles are readable" ON public.profiles;
CREATE POLICY "Public profiles are readable" ON public.profiles FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Users can insert profiles" ON public.profiles;
CREATE POLICY "Users can insert profiles" ON public.profiles FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (TRUE);

-- 4. Enable permissive RLS policies on donations:
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Donations are readable by all" ON public.donations;
CREATE POLICY "Donations are readable by all" ON public.donations FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Donors can create donations" ON public.donations;
CREATE POLICY "Donors can create donations" ON public.donations FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Donations can be updated" ON public.donations;
CREATE POLICY "Donations can be updated" ON public.donations FOR UPDATE USING (TRUE);

-- 5. Enable permissive policies on food and clothing details:
ALTER TABLE public.food_details ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Food details readable" ON public.food_details;
CREATE POLICY "Food details readable" ON public.food_details FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Food details insert" ON public.food_details;
CREATE POLICY "Food details insert" ON public.food_details FOR INSERT WITH CHECK (TRUE);

ALTER TABLE public.clothing_details ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Clothing details readable" ON public.clothing_details;
CREATE POLICY "Clothing details readable" ON public.clothing_details FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Clothing details insert" ON public.clothing_details;
CREATE POLICY "Clothing details insert" ON public.clothing_details FOR INSERT WITH CHECK (TRUE);

-- 6. Seed default demo profiles if they do not exist:
INSERT INTO public.profiles (id, email, full_name, role)
VALUES 
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'donor@foodbridge.org', 'Vikram Joshi (Green Leaf Bistro)', 'donor'),
    ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'ngo@foodbridge.org', 'Sunita Rao (Asha Foundation)', 'ngo'),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'volunteer@foodbridge.org', 'Rohit Kulkarni', 'volunteer'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'admin@foodbridge.org', 'Super Admin - Neha Deshmukh', 'admin')
ON CONFLICT (id) DO UPDATE 
SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, role = EXCLUDED.role;

-- 7. Ensure realtime publication includes donations and profiles:
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.donations;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
