-- FoodBridge Database Migration 20261112000000
-- Generated for Supabase PostgreSQL with RLS, Extensions, Stored Procedures & Seed Data

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. ENUMS
-- ============================================================================
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('donor', 'ngo', 'volunteer', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE ngo_verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE donation_type AS ENUM ('food', 'clothing');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE donation_status AS ENUM (
        'draft', 'listed', 'claimed', 'assigned', 'picked_up', 'delivered', 'cancelled', 'expired'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE food_storage_condition AS ENUM ('ambient', 'hot', 'chilled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE clothing_condition AS ENUM ('brand_new', 'like_new', 'wearable');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE vehicle_type AS ENUM ('two_wheeler', 'four_wheeler', 'van');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- 2. TABLES
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    role user_role NOT NULL DEFAULT 'donor',
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.donor_profiles (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    organization_name TEXT,
    fssai_license_number TEXT,
    pickup_address TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Pune',
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.ngos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    legal_name TEXT NOT NULL,
    darpan_id TEXT UNIQUE NOT NULL,
    registration_certificate_url TEXT,
    tax_exemption_80g_url TEXT,
    verification_status ngo_verification_status NOT NULL DEFAULT 'pending',
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES public.profiles(id),
    shelter_address TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Pune',
    capacity_beneficiaries INT DEFAULT 50 CHECK (capacity_beneficiaries > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.volunteer_profiles (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    vehicle_type vehicle_type NOT NULL DEFAULT 'two_wheeler',
    vehicle_number TEXT,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    max_active_tasks INT NOT NULL DEFAULT 2 CHECK (max_active_tasks BETWEEN 1 AND 5),
    completed_deliveries_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.donations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    type donation_type NOT NULL,
    status donation_status NOT NULL DEFAULT 'listed',
    quantity NUMERIC(10, 2) NOT NULL CHECK (quantity > 0),
    unit TEXT NOT NULL,
    pickup_address TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Pune',
    latitude DOUBLE PRECISION NOT NULL DEFAULT 18.5204,
    longitude DOUBLE PRECISION NOT NULL DEFAULT 73.8567,
    pickup_deadline TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.food_details (
    donation_id UUID PRIMARY KEY REFERENCES public.donations(id) ON DELETE CASCADE,
    is_veg BOOLEAN NOT NULL DEFAULT TRUE,
    prep_time TIMESTAMPTZ NOT NULL,
    storage_condition food_storage_condition NOT NULL DEFAULT 'ambient',
    allergen_notes TEXT,
    safety_charter_agreed BOOLEAN NOT NULL DEFAULT TRUE CHECK (safety_charter_agreed = TRUE)
);

CREATE TABLE IF NOT EXISTS public.clothing_details (
    donation_id UUID PRIMARY KEY REFERENCES public.donations(id) ON DELETE CASCADE,
    clothing_category TEXT NOT NULL,
    condition_grade clothing_condition NOT NULL DEFAULT 'like_new',
    is_washed_and_clean BOOLEAN NOT NULL DEFAULT TRUE CHECK (is_washed_and_clean = TRUE)
);

CREATE TABLE IF NOT EXISTS public.donation_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donation_id UUID NOT NULL REFERENCES public.donations(id) ON DELETE CASCADE,
    ngo_id UUID NOT NULL REFERENCES public.ngos(id) ON DELETE CASCADE,
    requested_quantity NUMERIC(10, 2) NOT NULL CHECK (requested_quantity > 0),
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donation_id UUID UNIQUE NOT NULL REFERENCES public.donations(id) ON DELETE CASCADE,
    ngo_id UUID NOT NULL REFERENCES public.ngos(id) ON DELETE CASCADE,
    volunteer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    picked_up_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'assigned'
);

CREATE TABLE IF NOT EXISTS public.distribution_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL REFERENCES public.assignments(id) ON DELETE CASCADE,
    ngo_id UUID NOT NULL REFERENCES public.ngos(id) ON DELETE CASCADE,
    beneficiaries_served_count INT NOT NULL CHECK (beneficiaries_served_count >= 0),
    handover_notes TEXT,
    verified_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    route_payload TEXT,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    details JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 3. INDEXES
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_donations_status_type ON public.donations(status, type);
CREATE INDEX IF NOT EXISTS idx_donations_deadline ON public.donations(pickup_deadline);
CREATE INDEX IF NOT EXISTS idx_donations_donor ON public.donations(donor_id);
CREATE INDEX IF NOT EXISTS idx_assignments_volunteer ON public.assignments(volunteer_id, status);
CREATE INDEX IF NOT EXISTS idx_assignments_donation ON public.assignments(donation_id);
CREATE INDEX IF NOT EXISTS idx_ngos_verification ON public.ngos(verification_status);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON public.notifications(recipient_user_id, is_read);

-- ============================================================================
-- 4. ROW LEVEL SECURITY
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ngos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.volunteer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clothing_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donation_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.distribution_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Helper functions
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS user_role AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_verified_ngo()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.ngos
        WHERE user_id = auth.uid() AND verification_status = 'verified'
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
    SELECT (public.get_user_role() = 'admin');
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- RLS Policies
DROP POLICY IF EXISTS "Public profiles are readable" ON public.profiles;
CREATE POLICY "Public profiles are readable" ON public.profiles FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE TO authenticated USING (id = auth.uid());

DROP POLICY IF EXISTS "Donors can create donations" ON public.donations;
CREATE POLICY "Donors can create donations" ON public.donations FOR INSERT TO authenticated WITH CHECK (donor_id = auth.uid());

DROP POLICY IF EXISTS "Donations are readable" ON public.donations;
CREATE POLICY "Donations are readable" ON public.donations FOR SELECT TO authenticated USING (
    status = 'listed' OR donor_id = auth.uid() OR public.is_admin()
);

-- ============================================================================
-- 5. ATOMIC STORED PROCEDURES
-- ============================================================================
CREATE OR REPLACE FUNCTION public.claim_donation_atomic(
    p_donation_id UUID,
    p_ngo_id UUID,
    p_quantity NUMERIC
)
RETURNS JSONB AS $$
DECLARE
    v_donation RECORD;
    v_ngo_verified BOOLEAN;
BEGIN
    SELECT (verification_status = 'verified') INTO v_ngo_verified
    FROM public.ngos WHERE id = p_ngo_id;

    IF NOT COALESCE(v_ngo_verified, FALSE) THEN
        RAISE EXCEPTION 'UNAUTHORIZED: NGO is not verified to claim donations.';
    END IF;

    SELECT * INTO v_donation FROM public.donations WHERE id = p_donation_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'NOT_FOUND: Donation does not exist.';
    END IF;

    IF v_donation.status != 'listed' THEN
        RAISE EXCEPTION 'CONFLICT: Donation is already claimed or unavailable.';
    END IF;

    INSERT INTO public.donation_requests(donation_id, ngo_id, requested_quantity, status)
    VALUES (p_donation_id, p_ngo_id, p_quantity, 'active');

    UPDATE public.donations SET status = 'claimed', updated_at = NOW() WHERE id = p_donation_id;

    RETURN jsonb_build_object('success', TRUE, 'donation_id', p_donation_id, 'status', 'claimed');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
