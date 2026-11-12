# FoodBridge PostgreSQL Database Schema (Supabase)

This document provides the complete PostgreSQL DDL schema definition for FoodBridge, adhering to Supabase best practices, UUID primary keys, check constraints, foreign key cascades, and high-performance indexing.

```sql
-- Enable necessary PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis"; -- For spatial geolocation queries

-- ============================================================================
-- 1. ENUM TYPES
-- ============================================================================
CREATE TYPE user_role AS ENUM ('donor', 'ngo', 'volunteer', 'admin');
CREATE TYPE ngo_verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');
CREATE TYPE donation_type AS ENUM ('food', 'clothing');
CREATE TYPE donation_status AS ENUM (
    'draft', 'listed', 'claimed', 'assigned', 'picked_up', 'delivered', 'cancelled', 'expired'
);
CREATE TYPE food_storage_condition AS ENUM ('ambient', 'hot', 'chilled');
CREATE TYPE clothing_condition AS ENUM ('brand_new', 'like_new', 'wearable');
CREATE TYPE vehicle_type AS ENUM ('two_wheeler', 'four_wheeler', 'van');

-- ============================================================================
-- 2. CORE USERS & PROFILES
-- ============================================================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    role user_role NOT NULL DEFAULT 'donor',
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE donor_profiles (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    organization_name TEXT,
    fssai_license_number TEXT,
    pickup_address TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Pune',
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE ngos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    legal_name TEXT NOT NULL,
    darpan_id TEXT UNIQUE NOT NULL,
    registration_certificate_url TEXT,
    tax_exemption_80g_url TEXT,
    verification_status ngo_verification_status NOT NULL DEFAULT 'pending',
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES profiles(id),
    shelter_address TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Pune',
    capacity_beneficiaries INT DEFAULT 50 CHECK (capacity_beneficiaries > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE volunteer_profiles (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    vehicle_type vehicle_type NOT NULL DEFAULT 'two_wheeler',
    vehicle_number TEXT,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    max_active_tasks INT NOT NULL DEFAULT 2 CHECK (max_active_tasks BETWEEN 1 AND 5),
    completed_deliveries_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 3. DONATIONS & EXTENSIONS (FOOD & CLOTHING)
-- ============================================================================
CREATE TABLE donations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    type donation_type NOT NULL,
    status donation_status NOT NULL DEFAULT 'listed',
    quantity NUMERIC(10, 2) NOT NULL CHECK (quantity > 0),
    unit TEXT NOT NULL, -- 'meals', 'kg', 'boxes', 'pieces'
    pickup_address TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Pune',
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    pickup_deadline TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE food_details (
    donation_id UUID PRIMARY KEY REFERENCES donations(id) ON DELETE CASCADE,
    is_veg BOOLEAN NOT NULL DEFAULT TRUE,
    prep_time TIMESTAMPTZ NOT NULL,
    storage_condition food_storage_condition NOT NULL DEFAULT 'ambient',
    allergen_notes TEXT,
    safety_charter_agreed BOOLEAN NOT NULL DEFAULT TRUE CHECK (safety_charter_agreed = TRUE)
);

CREATE TABLE clothing_details (
    donation_id UUID PRIMARY KEY REFERENCES donations(id) ON DELETE CASCADE,
    clothing_category TEXT NOT NULL, -- 'kids', 'adults', 'winter', 'blankets'
    condition_grade clothing_condition NOT NULL DEFAULT 'like_new',
    is_washed_and_clean BOOLEAN NOT NULL DEFAULT TRUE CHECK (is_washed_and_clean = TRUE)
);

-- ============================================================================
-- 4. CLAIMS, ASSIGNMENTS & DISTRIBUTIONS
-- ============================================================================
CREATE TABLE donation_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donation_id UUID NOT NULL REFERENCES donations(id) ON DELETE CASCADE,
    ngo_id UUID NOT NULL REFERENCES ngos(id) ON DELETE CASCADE,
    requested_quantity NUMERIC(10, 2) NOT NULL CHECK (requested_quantity > 0),
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'fulfilled', 'cancelled'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donation_id UUID UNIQUE NOT NULL REFERENCES donations(id) ON DELETE CASCADE,
    ngo_id UUID NOT NULL REFERENCES ngos(id) ON DELETE CASCADE,
    volunteer_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    picked_up_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'assigned' -- 'assigned', 'in_transit', 'delivered', 'surrendered'
);

CREATE TABLE distribution_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    ngo_id UUID NOT NULL REFERENCES ngos(id) ON DELETE CASCADE,
    beneficiaries_served_count INT NOT NULL CHECK (beneficiaries_served_count >= 0),
    handover_notes TEXT,
    verified_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 5. NOTIFICATIONS & AUDIT LOGS
-- ============================================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    route_payload TEXT,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    details JSONB,
    ip_address INET,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 6. INDEXES FOR PERFORMANCE
-- ============================================================================
CREATE INDEX idx_donations_status_type ON donations(status, type);
CREATE INDEX idx_donations_deadline ON donations(pickup_deadline);
CREATE INDEX idx_donations_donor ON donations(donor_id);
CREATE INDEX idx_assignments_volunteer ON assignments(volunteer_id, status);
CREATE INDEX idx_assignments_donation ON assignments(donation_id);
CREATE INDEX idx_ngos_verification ON ngos(verification_status);
CREATE INDEX idx_notifications_recipient ON notifications(recipient_user_id, is_read);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
```
