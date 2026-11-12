# FoodBridge — Relational Database Schema & Data Dictionary

**Project:** FoodBridge: Real-Time Food and Clothing Donation & Redistribution Platform  
**Document Version:** 1.0  
**Phase:** Phase 4 — System Architecture and Database Design  
**Database Engine:** PostgreSQL 15+ (Supabase Managed)  
**Status:** Completed  

---

## 1. Custom PostgreSQL Types & Enumerations

```sql
-- Role classifications
CREATE TYPE user_role AS ENUM ('donor', 'ngo', 'volunteer', 'admin');

-- User account standing
CREATE TYPE account_status AS ENUM ('active', 'pending_verification', 'suspended', 'deactivated');

-- Donation classifications
CREATE TYPE donation_type AS ENUM ('food', 'clothing');

-- Food category taxonomy
CREATE TYPE food_category AS ENUM (
  'cooked_meals', 
  'packaged_groceries', 
  'fresh_produce', 
  'bakery_dairy', 
  'beverages'
);

-- Food storage & holding requirements
CREATE TYPE storage_condition AS ENUM (
  'ambient', 
  'hot_holding', 
  'refrigerated', 
  'frozen'
);

-- Clothing category taxonomy
CREATE TYPE clothing_category AS ENUM (
  'menswear', 
  'womenswear', 
  'children_infant', 
  'winterwear_blankets', 
  'footwear', 
  'mixed_linens'
);

-- Clothing condition assessment
CREATE TYPE clothing_condition AS ENUM (
  'new_with_tags', 
  'gently_used_like_new', 
  'good_wearable'
);

-- Donation lifecycle state machine
CREATE TYPE donation_status AS ENUM (
  'draft',
  'available',
  'requested',
  'accepted',
  'assigned_for_pickup',
  'picked_up',
  'delivered_to_ngo',
  'distributed',
  'completed',
  'cancelled',
  'expired',
  'rejected'
);

-- NGO request status
CREATE TYPE request_status AS ENUM (
  'pending',
  'approved',
  'rejected',
  'withdrawn',
  'fulfilled',
  'cancelled'
);

-- Volunteer assignment dispatch status
CREATE TYPE assignment_status AS ENUM (
  'open',
  'assigned',
  'accepted',
  'picked_up',
  'delivered_to_ngo',
  'completed',
  'cancelled',
  'failed'
);

-- NGO verification standing
CREATE TYPE verification_status AS ENUM (
  'unverified',
  'pending_review',
  'verified',
  'rejected'
);
```

---

## 2. Table Schemas & Data Dictionaries

### 2.1 Table: `profiles`
Central user profile table directly linked to `auth.users`.
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role user_role NOT NULL DEFAULT 'donor',
  display_name TEXT NOT NULL,
  phone TEXT,
  account_status account_status NOT NULL DEFAULT 'active',
  preferred_language TEXT NOT NULL DEFAULT 'en' CHECK (preferred_language IN ('en', 'hi', 'mr')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);
```

### 2.2 Table: `donor_profiles`
Specialized attributes for commercial and individual donors.
```sql
CREATE TABLE donor_profiles (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  donor_type TEXT NOT NULL CHECK (donor_type IN ('individual', 'restaurant', 'caterer', 'hotel', 'supermarket', 'corporate')),
  organization_name TEXT,
  default_pickup_area TEXT,
  default_pickup_address_private TEXT,
  contact_person TEXT
);
```

### 2.3 Table: `ngos`
Verified non-profit organizations, shelters, and community kitchens.
```sql
CREATE TABLE ngos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  registration_number TEXT NOT NULL UNIQUE,
  description TEXT,
  service_areas TEXT[] NOT NULL DEFAULT '{}',
  capacity_notes TEXT,
  daily_meal_capacity INTEGER CHECK (daily_meal_capacity >= 0),
  verification_status verification_status NOT NULL DEFAULT 'pending_review',
  verification_document_paths TEXT[] NOT NULL DEFAULT '{}',
  admin_review_notes TEXT,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);
```

### 2.4 Table: `volunteer_profiles`
Community volunteers coordinating field transport.
```sql
CREATE TABLE volunteer_profiles (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  vehicle_type TEXT NOT NULL CHECK (vehicle_type IN ('walking', 'bicycle', 'two_wheeler', 'car', 'van')),
  service_areas TEXT[] NOT NULL DEFAULT '{}',
  is_available BOOLEAN NOT NULL DEFAULT true,
  active_task_limit INTEGER NOT NULL DEFAULT 2 CHECK (active_task_limit BETWEEN 1 AND 5),
  total_completed_trips INTEGER NOT NULL DEFAULT 0 CHECK (total_completed_trips >= 0)
);
```

### 2.5 Table: `donations`
Master listing record for surplus food and clothing donations.
```sql
CREATE TABLE donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  donation_type donation_type NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  initial_quantity NUMERIC(10, 2) NOT NULL CHECK (initial_quantity > 0),
  available_quantity NUMERIC(10, 2) NOT NULL CHECK (available_quantity >= 0),
  unit TEXT NOT NULL, -- 'kg', 'boxes', 'portions', 'pieces', 'liters'
  photo_paths TEXT[] NOT NULL DEFAULT '{}',
  pickup_area_public TEXT NOT NULL, -- Two-tier public locality
  pickup_location_private TEXT NOT NULL, -- Exact address locked behind RLS
  pickup_phone_private TEXT NOT NULL, -- Donor phone locked behind RLS
  available_from TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  collection_deadline TIMESTAMPTZ NOT NULL,
  status donation_status NOT NULL DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT valid_quantities CHECK (available_quantity <= initial_quantity),
  CONSTRAINT valid_deadline CHECK (collection_deadline > available_from)
);
```

### 2.6 Table: `food_details`
Child table capturing perishable food attributes and handling declarations.
```sql
CREATE TABLE food_details (
  donation_id UUID PRIMARY KEY REFERENCES donations(id) ON DELETE CASCADE,
  food_category food_category NOT NULL,
  prepared_or_packed_at TIMESTAMPTZ NOT NULL,
  storage_condition storage_condition NOT NULL,
  allergen_notes TEXT,
  donor_safety_declaration BOOLEAN NOT NULL DEFAULT false,
  estimated_servings INTEGER CHECK (estimated_servings > 0),
  CONSTRAINT declaration_mandatory CHECK (donor_safety_declaration = true)
);
```

### 2.7 Table: `clothing_details`
Child table capturing wearable clothing metadata.
```sql
CREATE TABLE clothing_details (
  donation_id UUID PRIMARY KEY REFERENCES donations(id) ON DELETE CASCADE,
  item_category clothing_category NOT NULL,
  condition clothing_condition NOT NULL,
  size_range TEXT[] NOT NULL DEFAULT '{}',
  cleanliness_declaration BOOLEAN NOT NULL DEFAULT false,
  CONSTRAINT cleanliness_mandatory CHECK (cleanliness_declaration = true)
);
```

### 2.8 Table: `donation_requests`
NGO allocation claims and quantity reservation records.
```sql
CREATE TABLE donation_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donation_id UUID NOT NULL REFERENCES donations(id) ON DELETE RESTRICT,
  ngo_id UUID NOT NULL REFERENCES ngos(id) ON DELETE RESTRICT,
  requested_quantity NUMERIC(10, 2) NOT NULL CHECK (requested_quantity > 0),
  requires_volunteer_delivery BOOLEAN NOT NULL DEFAULT true,
  message TEXT,
  status request_status NOT NULL DEFAULT 'pending',
  decision_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);
```

### 2.9 Table: `assignments`
Physical dispatch and transport tasks assigned to volunteers.
```sql
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donation_request_id UUID NOT NULL REFERENCES donation_requests(id) ON DELETE RESTRICT,
  volunteer_id UUID REFERENCES volunteer_profiles(user_id) ON DELETE SET NULL,
  pickup_window_start TIMESTAMPTZ NOT NULL,
  pickup_window_end TIMESTAMPTZ NOT NULL,
  status assignment_status NOT NULL DEFAULT 'open',
  picked_up_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);
```

### 2.10 Table: `distribution_records`
Closed-loop impact and distribution logging without beneficiary personal data.
```sql
CREATE TABLE distribution_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donation_id UUID NOT NULL REFERENCES donations(id) ON DELETE RESTRICT,
  ngo_id UUID NOT NULL REFERENCES ngos(id) ON DELETE RESTRICT,
  quantity_received NUMERIC(10, 2) NOT NULL CHECK (quantity_received >= 0),
  quantity_distributed NUMERIC(10, 2) NOT NULL CHECK (quantity_distributed >= 0),
  beneficiaries_served_count INTEGER NOT NULL CHECK (beneficiaries_served_count >= 0),
  unit TEXT NOT NULL,
  distribution_date DATE NOT NULL DEFAULT CURRENT_DATE,
  summary_notes TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);
```

### 2.11 Table: `notifications`
Consolidated in-app event notification logs.
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  entity_type TEXT,
  entity_id UUID,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);
```

### 2.12 Table: `audit_logs`
Immutable audit trail recording all security and lifecycle transitions.
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  old_state JSONB,
  new_state JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);
```

---

## 3. High-Performance Indexes

```sql
-- Indexes on donations for feed filtering
CREATE INDEX idx_donations_status_deadline ON donations(status, collection_deadline) WHERE status = 'available';
CREATE INDEX idx_donations_donor ON donations(donor_id);
CREATE INDEX idx_donations_type ON donations(donation_type);
CREATE INDEX idx_donations_pickup_area ON donations(pickup_area_public);

-- Indexes on requests and assignments
CREATE INDEX idx_requests_donation ON donation_requests(donation_id, status);
CREATE INDEX idx_requests_ngo ON donation_requests(ngo_id);
CREATE INDEX idx_assignments_open ON assignments(status) WHERE status = 'open';
CREATE INDEX idx_assignments_volunteer ON assignments(volunteer_id, status);

-- Indexes on notifications and audit logs
CREATE INDEX idx_notifications_recipient ON notifications(recipient_user_id, read_at);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
```

