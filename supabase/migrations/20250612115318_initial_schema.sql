-- ============================================================================
-- NUGE DATABASE SCHEMA - Simplified Production Version
-- FastAPI + Supabase (PostgreSQL) Backend for Food Vendor Location App
-- 
-- SECURITY UPDATES APPLIED:
-- ✅ All functions now have SET search_path = '' for security compliance
-- ✅ Extensions moved to 'extensions' schema (requires manual verification)
-- 
-- REMAINING ACTIONS REQUIRED (via Supabase Dashboard):
-- ⚠️  Enable leaked password protection in Auth settings
-- ⚠️  Configure additional MFA options (TOTP, etc.)
-- ============================================================================
-- ============================================================================
-- ⚠️  DATABASE RESET COMMANDS - USE WITH EXTREME CAUTION ⚠️
-- ============================================================================
-- 
-- DANGER: The following commands will PERMANENTLY DELETE ALL DATA!
-- Only run these commands if you want to completely reset the database.
-- 
-- To reset the database, uncomment and run the commands in the section below.
-- Make sure you have a backup if you need to preserve any data!
-- 
-- Usage:
-- 1. Uncomment the DROP commands below
-- 2. Run this entire file
-- 3. Re-comment the DROP commands to prevent accidental execution
-- ============================================================================
-- ============================================================================
-- STEP 1: DROP ALL SCHEDULED JOBS (if pg_cron was enabled)
-- ============================================================================
-- Drop scheduled cron jobs if they exist
-- SELECT cron.unschedule('create-monthly-partitions') WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'create-monthly-partitions');
-- SELECT cron.unschedule('cleanup-old-data') WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'cleanup-old-data');
-- SELECT cron.unschedule('check-location-heartbeats') WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'check-location-heartbeats');
-- ============================================================================
-- STEP 2: DROP ALL TABLES (in reverse dependency order)
-- ============================================================================
-- Drop all tables with CASCADE to handle dependencies
DROP TABLE IF EXISTS stripe_webhook_events CASCADE;
DROP TABLE IF EXISTS vendor_payouts CASCADE;
DROP TABLE IF EXISTS payout_batches CASCADE;
DROP TABLE IF EXISTS subscription_invoices CASCADE;
DROP TABLE IF EXISTS financial_transactions CASCADE;
DROP TABLE IF EXISTS vendor_financial_analytics CASCADE;
DROP TABLE IF EXISTS commission_rates CASCADE;
DROP TABLE IF EXISTS vendor_subscriptions CASCADE;
DROP TABLE IF EXISTS vendor_stripe_accounts CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;
DROP TABLE IF EXISTS trending_searches CASCADE;
DROP TABLE IF EXISTS search_history CASCADE;
DROP TABLE IF EXISTS user_activities CASCADE;
DROP TABLE IF EXISTS push_tokens CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS review_votes CASCADE;
DROP TABLE IF EXISTS vendor_reviews CASCADE;
DROP TABLE IF EXISTS user_favorites CASCADE;
DROP TABLE IF EXISTS product_tags CASCADE;
DROP TABLE IF EXISTS vendor_tags CASCADE;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS carts CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS options CASCADE;
DROP TABLE IF EXISTS option_groups CASCADE;
DROP TABLE IF EXISTS product_variants CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS vendor_events CASCADE;
DROP TABLE IF EXISTS vendor_analytics CASCADE;
DROP TABLE IF EXISTS vendor_locations CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
-- ============================================================================
-- STEP 3: DROP ALL CUSTOM FUNCTIONS
-- ============================================================================
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS generate_vendor_slug() CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS update_vendor_rating() CASCADE;
DROP FUNCTION IF EXISTS copy_preparation_time() CASCADE;
DROP FUNCTION IF EXISTS get_or_create_user_cart(uuid, uuid) CASCADE;
DROP FUNCTION IF EXISTS calculate_cart_total(uuid) CASCADE;
DROP FUNCTION IF EXISTS update_tag_usage_count() CASCADE;
DROP FUNCTION IF EXISTS verify_review_from_order() CASCADE;
DROP FUNCTION IF EXISTS update_review_helpful_count() CASCADE;
DROP FUNCTION IF EXISTS calculate_commission_amounts(uuid, decimal, timestamp with time zone) CASCADE;
DROP FUNCTION IF EXISTS create_order_financial_transaction() CASCADE;
DROP FUNCTION IF EXISTS generate_order_number() CASCADE;
DROP FUNCTION IF EXISTS check_vendor_location_heartbeat() CASCADE;
DROP FUNCTION IF EXISTS cleanup_expired_carts() CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_data() CASCADE;
DROP FUNCTION IF EXISTS find_vendors_near(geography, integer, integer) CASCADE;
DROP FUNCTION IF EXISTS calculate_order_ready_time(uuid, jsonb) CASCADE;
DROP FUNCTION IF EXISTS create_monthly_partitions() CASCADE;
-- ============================================================================
-- STEP 4: DROP ALL CUSTOM TYPES/ENUMS
-- ============================================================================
DROP TYPE IF EXISTS event_type_enum CASCADE;
DROP TYPE IF EXISTS order_status_enum CASCADE;
DROP TYPE IF EXISTS payment_status_enum CASCADE;
DROP TYPE IF EXISTS location_status_enum CASCADE;
DROP TYPE IF EXISTS language_enum CASCADE;
DROP TYPE IF EXISTS notification_type_enum CASCADE;
DROP TYPE IF EXISTS subscription_status_enum CASCADE;
DROP TYPE IF EXISTS invoice_status_enum CASCADE;
DROP TYPE IF EXISTS transaction_type_enum CASCADE;
-- ============================================================================
-- STEP 5: DROP EXTENSIONS (BE CAREFUL - these might be used by other databases)
-- ============================================================================
-- Note: Extensions in Supabase are typically managed at the platform level
-- Uncomment only if you need to completely reset extensions
-- DROP EXTENSION IF EXISTS postgis CASCADE;
-- DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;
-- DROP EXTENSION IF EXISTS pg_trgm CASCADE;
-- DROP EXTENSION IF EXISTS btree_gist CASCADE;
-- DROP EXTENSION IF EXISTS ltree CASCADE;
-- DROP EXTENSION IF EXISTS pg_cron CASCADE;
-- ============================================================================
-- STEP 6: CLEAN UP REMAINING OBJECTS
-- ============================================================================
-- Drop any remaining indexes that might not have been dropped with tables
DROP INDEX IF EXISTS idx_vendor_locations_geography;
DROP INDEX IF EXISTS idx_vendor_locations_current_active;
DROP INDEX IF EXISTS idx_vendor_locations_planned;
DROP INDEX IF EXISTS idx_profiles_last_location;
DROP INDEX IF EXISTS idx_user_activities_location;
DROP INDEX IF EXISTS idx_vendor_locations_heartbeat;
DROP INDEX IF EXISTS idx_orders_pickup_time;
DROP INDEX IF EXISTS idx_products_allergens;
DROP INDEX IF EXISTS idx_products_dietary;
DROP INDEX IF EXISTS idx_vendors_business_name;
DROP INDEX IF EXISTS idx_vendors_description;
DROP INDEX IF EXISTS idx_products_name;
DROP INDEX IF EXISTS idx_products_description;
DROP INDEX IF EXISTS idx_orders_user_status;
DROP INDEX IF EXISTS idx_orders_vendor_status;
DROP INDEX IF EXISTS idx_notifications_user_unread;
DROP INDEX IF EXISTS idx_cart_items_cart_product;
DROP INDEX IF EXISTS idx_financial_transactions_settlement;
DROP INDEX IF EXISTS idx_vendor_reviews_vendor_visible;
DROP INDEX IF EXISTS idx_vendor_analytics_vendor_date;
DROP INDEX IF EXISTS idx_vendor_financial_date;
DROP INDEX IF EXISTS idx_products_vendor_available;
DROP INDEX IF EXISTS idx_vendor_events_active_date;
DROP INDEX IF EXISTS idx_one_active_location_per_vendor;
DROP INDEX IF EXISTS idx_one_default_variant_per_product;
DROP INDEX IF EXISTS unique_active_cart_per_user_vendor;
DROP INDEX IF EXISTS unique_user_order_review;
DROP INDEX IF EXISTS one_default_per_product;
-- Drop statistics
DROP STATISTICS IF EXISTS vendor_location_stats;
DROP STATISTICS IF EXISTS order_vendor_stats;
DROP STATISTICS IF EXISTS product_vendor_stats;
-- ============================================================================
-- RESET COMPLETE
-- ============================================================================
-- After running these commands, you can proceed with the schema creation below
-- Remember to re-comment this section to prevent accidental execution!
-- Enable required extensions in extensions schema (Supabase best practice)
-- First, drop and recreate extensions in the correct schema if they exist in public
DO $$ BEGIN -- Check if extensions exist in public and move them to extensions schema
IF EXISTS (
    SELECT 1
    FROM pg_extension
    WHERE extname = 'postgis'
        AND extnamespace = (
            SELECT oid
            FROM pg_namespace
            WHERE nspname = 'public'
        )
) THEN DROP EXTENSION IF EXISTS postgis;
END IF;
IF EXISTS (
    SELECT 1
    FROM pg_extension
    WHERE extname = 'uuid-ossp'
        AND extnamespace = (
            SELECT oid
            FROM pg_namespace
            WHERE nspname = 'public'
        )
) THEN DROP EXTENSION IF EXISTS "uuid-ossp";
END IF;
IF EXISTS (
    SELECT 1
    FROM pg_extension
    WHERE extname = 'pg_trgm'
        AND extnamespace = (
            SELECT oid
            FROM pg_namespace
            WHERE nspname = 'public'
        )
) THEN DROP EXTENSION IF EXISTS pg_trgm;
END IF;
IF EXISTS (
    SELECT 1
    FROM pg_extension
    WHERE extname = 'btree_gist'
        AND extnamespace = (
            SELECT oid
            FROM pg_namespace
            WHERE nspname = 'public'
        )
) THEN DROP EXTENSION IF EXISTS btree_gist;
END IF;
IF EXISTS (
    SELECT 1
    FROM pg_extension
    WHERE extname = 'ltree'
        AND extnamespace = (
            SELECT oid
            FROM pg_namespace
            WHERE nspname = 'public'
        )
) THEN DROP EXTENSION IF EXISTS ltree;
END IF;
END $$;
CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;
-- For better text search
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA extensions;
-- For exclusion constraints
CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA extensions;
-- ============================================================================
-- ENUMS FOR TYPE SAFETY
-- ============================================================================
-- Event types enum
CREATE TYPE event_type_enum AS ENUM (
    'promotion',
    'announcement',
    'special_menu',
    'location_change',
    'hours_change',
    'temporary_closure',
    'new_product',
    'sold_out'
);
-- Order status enum
CREATE TYPE order_status_enum AS ENUM (
    'draft',
    -- Cart converted to order but not submitted
    'pending',
    -- Submitted, awaiting vendor confirmation
    'confirmed',
    -- Vendor confirmed
    'preparing',
    -- Being prepared
    'ready',
    -- Ready for pickup
    'completed',
    -- Picked up by customer
    'cancelled',
    -- Cancelled by customer or vendor
    'refunded' -- Payment refunded
);
-- Payment status enum  
CREATE TYPE payment_status_enum AS ENUM (
    'pending',
    'processing',
    -- Payment being processed
    'paid',
    'failed',
    'refunded',
    'partial_refund'
);
-- Location status enum
CREATE TYPE location_status_enum AS ENUM (
    'active',
    -- Currently selling at this location
    'inactive',
    -- Not at this location
    'planned',
    -- Future planned location
    'setting_up',
    -- Vendor arriving/setting up
    'closing_soon' -- About to leave location
);
-- Language enum
CREATE TYPE language_enum AS ENUM ('fr', 'nl', 'en');
-- Notification type enum
CREATE TYPE notification_type_enum AS ENUM (
    'order_ready',
    'vendor_nearby',
    'planned_location',
    'promotion',
    'order_confirmed',
    'order_cancelled',
    'vendor_review_reminder',
    'new_vendor_in_area',
    'favorite_vendor_active',
    'order_status_change',
    'location_reminder' -- Added for vendor location reminders
);
-- Subscription status enum
CREATE TYPE subscription_status_enum AS ENUM (
    'trialing',
    'active',
    'past_due',
    'canceled',
    'unpaid',
    'incomplete',
    'incomplete_expired',
    'paused'
);
-- Invoice status enum
CREATE TYPE invoice_status_enum AS ENUM (
    'draft',
    'open',
    'paid',
    'uncollectible',
    'void'
);
-- Transaction type enum
CREATE TYPE transaction_type_enum AS ENUM (
    'subscription_fee',
    'commission',
    'refund',
    'chargeback',
    'adjustment',
    'payout'
);
-- ============================================================================
-- CORE TABLES
-- ============================================================================
-- User profiles (extends Supabase auth.users)
CREATE TABLE profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    first_name varchar(100) NOT NULL DEFAULT '',
    last_name varchar(100) NOT NULL DEFAULT '',
    display_name varchar(200) GENERATED ALWAYS AS (
        NULLIF(TRIM(first_name || ' ' || last_name), '')
    ) STORED,
    phone_verified boolean NOT NULL DEFAULT false,
    avatar_url varchar(500),
    preferred_language language_enum NOT NULL DEFAULT 'fr',
    -- GDPR compliant defaults - user must opt-in
    notification_preferences jsonb NOT NULL DEFAULT '{"email": false, "push": false, "sms": false, "marketing": false}'::jsonb,
    location_permissions jsonb NOT NULL DEFAULT '{"background": false, "precise": false}'::jsonb,
    is_active boolean NOT NULL DEFAULT true,
    last_known_location geography(POINT, 4326),
    -- For proximity notifications
    last_location_update timestamp with time zone,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);
-- Function to handle user creation with better error handling
CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger AS $$ BEGIN
INSERT INTO public.profiles (id, first_name, last_name, preferred_language)
VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        COALESCE(
            NEW.raw_user_meta_data->>'preferred_language',
            'fr'
        )::language_enum
    ) ON CONFLICT (id) DO NOTHING;
-- Handle race conditions
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public';
-- Trigger to create profile on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER
INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
-- Categories with multilingual support
CREATE TABLE categories (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name jsonb NOT NULL DEFAULT '{}'::jsonb,
    -- {"fr": "Viande", "nl": "Vlees", "en": "Meat"}
    slug varchar(100) NOT NULL UNIQUE,
    description jsonb NOT NULL DEFAULT '{}'::jsonb,
    icon varchar(50),
    color varchar(7) CHECK (color ~ '^#[0-9A-Fa-f]{6}$'),
    parent_id uuid REFERENCES categories(id) ON DELETE CASCADE,
    level integer NOT NULL DEFAULT 0,
    path ltree,
    -- For efficient hierarchy queries
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_name CHECK (jsonb_typeof(name) = 'object'),
    CONSTRAINT valid_description CHECK (jsonb_typeof(description) = 'object')
);
-- Tags for flexible categorization
CREATE TABLE tags (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name jsonb NOT NULL DEFAULT '{}'::jsonb,
    -- Multilingual support for system tags
    slug varchar(100) NOT NULL UNIQUE,
    type varchar(50) NOT NULL CHECK (
        type IN (
            'dietary',
            'cuisine',
            'certification',
            'feature',
            'other'
        )
    ),
    color varchar(7) NOT NULL CHECK (color ~ '^#[0-9A-Fa-f]{6}$'),
    icon varchar(50),
    description jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_system boolean NOT NULL DEFAULT false,
    -- System tags vs user-created
    is_active boolean NOT NULL DEFAULT true,
    usage_count integer NOT NULL DEFAULT 0,
    -- Track popularity
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);
-- ============================================================================
-- VENDOR RELATED TABLES
-- ============================================================================
-- Main vendors table
CREATE TABLE vendors (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    business_name varchar(255) NOT NULL,
    business_slug varchar(255) NOT NULL UNIQUE,
    business_email varchar(255) NOT NULL,
    business_phone varchar(20),
    description text,
    -- Single description field
    logo_url varchar(500),
    business_address text,
    business_registration varchar(100),
    tax_number varchar(100),
    website_url varchar(255),
    social_media jsonb NOT NULL DEFAULT '{}'::jsonb,
    operating_hours jsonb NOT NULL DEFAULT '{}'::jsonb,
    -- Typical schedule
    minimum_order_amount decimal(10, 2) DEFAULT 0,
    average_preparation_time integer DEFAULT 15,
    -- Minutes
    auto_accept_orders boolean NOT NULL DEFAULT false,
    reminder_interval integer NOT NULL DEFAULT 30,
    -- Minutes between location reminders
    is_active boolean NOT NULL DEFAULT true,
    is_verified boolean NOT NULL DEFAULT false,
    is_featured boolean NOT NULL DEFAULT false,
    -- For promotions
    verification_date timestamp with time zone,
    suspension_reason text,
    suspended_until timestamp with time zone,
    -- Analytics fields (denormalized for performance)
    average_rating decimal(3, 2) DEFAULT 0,
    total_reviews integer DEFAULT 0,
    total_orders integer DEFAULT 0,
    total_revenue decimal(12, 2) DEFAULT 0,
    last_order_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT vendors_business_email_unique UNIQUE(business_email),
    CONSTRAINT valid_rating CHECK (
        average_rating >= 0
        AND average_rating <= 5
    ),
    CONSTRAINT valid_minimum_order CHECK (minimum_order_amount >= 0),
    CONSTRAINT valid_prep_time CHECK (average_preparation_time > 0),
    CONSTRAINT valid_reminder_interval CHECK (reminder_interval >= 15) -- Minimum 15 minutes
);
-- Create vendor slug automatically
CREATE OR REPLACE FUNCTION generate_vendor_slug() RETURNS TRIGGER AS $$ BEGIN NEW.business_slug := lower(
        regexp_replace(NEW.business_name, '[^a-zA-Z0-9]+', '-', 'g')
    );
-- Add random suffix if slug exists
WHILE EXISTS (
    SELECT 1
    FROM vendors
    WHERE business_slug = NEW.business_slug
        AND id != NEW.id
) LOOP NEW.business_slug := NEW.business_slug || '-' || substr(md5(random()::text), 1, 4);
END LOOP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
CREATE TRIGGER generate_vendor_slug_trigger BEFORE
INSERT
    OR
UPDATE OF business_name ON vendors FOR EACH ROW EXECUTE FUNCTION generate_vendor_slug();
-- Vendor locations (manual position sharing)
CREATE TABLE vendor_locations (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    name varchar(255),
    -- Optional location name
    address text,
    position geography(POINT, 4326) NOT NULL,
    status location_status_enum NOT NULL DEFAULT 'inactive',
    is_verified boolean NOT NULL DEFAULT false,
    -- GPS spoofing protection
    -- Time management
    starts_at timestamp with time zone NOT NULL DEFAULT now(),
    ends_at timestamp with time zone,
    last_heartbeat timestamp with time zone DEFAULT now(),
    -- For reminder system
    -- Additional metadata
    location_notes text,
    -- Special instructions for customers
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_time_range CHECK (
        ends_at IS NULL
        OR ends_at > starts_at
    ),
    -- Prevent overlapping active locations for same vendor
    EXCLUDE USING gist (
        vendor_id WITH =,
        tstzrange(
            starts_at,
            COALESCE(ends_at, 'infinity'::timestamptz)
        ) WITH &&
    )
    WHERE (status = 'active')
);
-- Vendor analytics
CREATE TABLE vendor_analytics (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    analytics_date date NOT NULL,
    -- Order metrics
    total_orders integer NOT NULL DEFAULT 0,
    completed_orders integer NOT NULL DEFAULT 0,
    cancelled_orders integer NOT NULL DEFAULT 0,
    total_revenue decimal(10, 2) NOT NULL DEFAULT 0,
    average_order_value decimal(10, 2) DEFAULT 0,
    average_preparation_time integer,
    -- Minutes
    -- Customer metrics
    unique_customers integer DEFAULT 0,
    returning_customers integer DEFAULT 0,
    new_customers integer DEFAULT 0,
    total_views integer DEFAULT 0,
    conversion_rate decimal(5, 4) DEFAULT 0,
    -- Views to orders
    -- Time-based metrics
    peak_hour integer CHECK (
        peak_hour BETWEEN 0 AND 23
    ),
    orders_by_hour jsonb DEFAULT '{}'::jsonb,
    -- {"0": 5, "1": 3, ...}
    revenue_by_hour jsonb DEFAULT '{}'::jsonb,
    -- Location metrics
    locations_visited integer DEFAULT 0,
    best_location_id uuid REFERENCES vendor_locations(id) ON DELETE
    SET NULL,
        -- Product metrics
        top_products jsonb DEFAULT '[]'::jsonb,
        -- Array of {product_id, quantity, revenue}
        -- External factors
        weather_condition varchar(50),
        temperature decimal(4, 1),
        -- Celsius
        created_at timestamp with time zone NOT NULL DEFAULT now(),
        CONSTRAINT vendor_analytics_unique_date UNIQUE(vendor_id, analytics_date),
        CONSTRAINT valid_revenue CHECK (total_revenue >= 0),
        CONSTRAINT valid_orders CHECK (
            completed_orders + cancelled_orders <= total_orders
        )
);
-- Vendor events and promotions
CREATE TABLE vendor_events (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    title varchar(255) NOT NULL,
    description text NOT NULL,
    event_type event_type_enum NOT NULL,
    -- Location binding
    vendor_location_id uuid REFERENCES vendor_locations(id) ON DELETE CASCADE,
    applies_to_all_locations boolean NOT NULL DEFAULT false,
    -- Timing
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone,
    is_recurring boolean NOT NULL DEFAULT false,
    recurrence_rule jsonb,
    -- iCal RRULE format
    timezone varchar(50) NOT NULL DEFAULT 'Europe/Brussels',
    -- Event specifics
    event_data jsonb NOT NULL DEFAULT '{}'::jsonb,
    -- Flexible data storage
    target_audience jsonb DEFAULT '{}'::jsonb,
    -- Targeting rules
    max_uses integer,
    -- For limited promotions
    current_uses integer DEFAULT 0,
    -- Status
    is_active boolean NOT NULL DEFAULT true,
    is_approved boolean NOT NULL DEFAULT true,
    -- For moderation
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_event_time CHECK (
        ends_at IS NULL
        OR ends_at > starts_at
    ),
    CONSTRAINT valid_max_uses CHECK (
        max_uses IS NULL
        OR max_uses > 0
    ),
    CONSTRAINT valid_current_uses CHECK (current_uses >= 0)
);
-- ============================================================================
-- PRODUCT RELATED TABLES
-- ============================================================================
-- Products table
CREATE TABLE products (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    category_id uuid NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    -- Basic info
    name varchar(255) NOT NULL,
    description varchar(256),
    -- Single description with character limit
    sku varchar(100),
    -- Stock Keeping Unit for vendor's reference
    -- Pricing
    price decimal(10, 2) NOT NULL,
    compare_at_price decimal(10, 2),
    -- Original price for showing discounts
    cost decimal(10, 2),
    -- Vendor's cost for profit calculations
    tax_rate decimal(5, 4) NOT NULL DEFAULT 0.06,
    -- 6% Belgian reduced rate for food
    -- Media
    image_url varchar(500),
    -- Single image only
    -- Availability
    is_available boolean NOT NULL DEFAULT true,
    -- Product attributes
    has_variants boolean NOT NULL DEFAULT false,
    is_customizable boolean NOT NULL DEFAULT false,
    -- Dietary and allergen info
    allergens varchar(50) [] NOT NULL DEFAULT '{}',
    dietary_tags varchar(50) [] NOT NULL DEFAULT '{}',
    -- vegan, halal, kosher, etc
    -- Preparation
    preparation_time integer NOT NULL DEFAULT 10,
    -- Minutes
    -- Display
    is_featured boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_price CHECK (price >= 0),
    CONSTRAINT valid_compare_price CHECK (
        compare_at_price IS NULL
        OR compare_at_price >= price
    ),
    CONSTRAINT valid_cost CHECK (
        cost IS NULL
        OR cost >= 0
    ),
    CONSTRAINT valid_tax_rate CHECK (
        tax_rate >= 0
        AND tax_rate <= 1
    ),
    CONSTRAINT valid_prep_time CHECK (preparation_time >= 0)
);
-- Product variants (sizes, types)
CREATE TABLE product_variants (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    -- Variant info
    name varchar(255) NOT NULL,
    -- e.g., "Large", "Medium", "Small"
    sku varchar(100) UNIQUE,
    -- Pricing
    price decimal(10, 2) NOT NULL,
    compare_at_price decimal(10, 2),
    cost decimal(10, 2),
    -- Variant attributes (size, type, etc)
    variant_options jsonb NOT NULL DEFAULT '{}'::jsonb,
    -- Display
    image_url varchar(500),
    is_default boolean NOT NULL DEFAULT false,
    is_available boolean NOT NULL DEFAULT true,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_variant_price CHECK (price >= 0),
    CONSTRAINT valid_variant_compare_price CHECK (
        compare_at_price IS NULL
        OR compare_at_price >= price
    ),
    CONSTRAINT valid_variant_cost CHECK (
        cost IS NULL
        OR cost >= 0
    )
);
CREATE UNIQUE INDEX one_default_per_product ON product_variants (product_id)
WHERE is_default = true;
-- Option groups (minimal structure)
CREATE TABLE option_groups (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    -- Group info
    name varchar(255) NOT NULL,
    -- e.g., "Toppings", "Sauce"
    -- Selection rules
    type varchar(50) NOT NULL DEFAULT 'single' CHECK (type IN ('single', 'multiple')),
    is_required boolean NOT NULL DEFAULT false,
    min_selections smallint NOT NULL DEFAULT 0,
    max_selections smallint NOT NULL DEFAULT 1,
    -- Display
    sort_order smallint NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_selection_range CHECK (
        min_selections >= 0
        AND min_selections <= max_selections
    )
);
-- Options (minimal structure)
CREATE TABLE options (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    option_group_id uuid NOT NULL REFERENCES option_groups(id) ON DELETE CASCADE,
    -- Option info
    name varchar(255) NOT NULL,
    -- e.g., "Extra Cheese", "No Onions"
    -- Pricing
    price_modifier decimal(10, 2) DEFAULT 0,
    modifier_type varchar(20) DEFAULT 'add' CHECK (modifier_type IN ('add', 'multiply', 'replace')),
    -- Display
    image_url varchar(500),
    is_default boolean NOT NULL DEFAULT false,
    is_available boolean NOT NULL DEFAULT true,
    is_recommended boolean NOT NULL DEFAULT false,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);
-- ============================================================================
-- ORDER SYSTEM TABLES
-- ============================================================================
-- Orders table
CREATE TABLE orders (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE RESTRICT,
    vendor_location_id uuid REFERENCES vendor_locations(id) ON DELETE
    SET NULL,
        -- Order identification
        order_number varchar(50) NOT NULL UNIQUE,
        -- Status tracking
        status order_status_enum NOT NULL DEFAULT 'pending',
        status_history jsonb NOT NULL DEFAULT '[]'::jsonb,
        -- Array of {status, timestamp, note}
        payment_status payment_status_enum NOT NULL DEFAULT 'pending',
        payment_method varchar(50),
        -- Stripe integration
        stripe_payment_intent_id varchar(255) UNIQUE,
        stripe_charge_id varchar(255),
        -- Amounts
        subtotal decimal(10, 2) NOT NULL,
        tax_amount decimal(10, 2) NOT NULL DEFAULT 0,
        -- VAT amount
        service_fee decimal(10, 2) NOT NULL DEFAULT 0,
        tip_amount decimal(10, 2) NOT NULL DEFAULT 0,
        discount_amount decimal(10, 2) NOT NULL DEFAULT 0,
        total_amount decimal(10, 2) NOT NULL,
        -- Customer info
        customer_name varchar(255),
        customer_phone varchar(20),
        customer_email varchar(255),
        customer_notes text,
        -- Timing
        requested_pickup_time timestamp with time zone,
        estimated_ready_time timestamp with time zone,
        actual_ready_time timestamp with time zone,
        picked_up_at timestamp with time zone,
        -- Vendor response
        vendor_notes text,
        preparation_time_minutes integer,
        rejection_reason text,
        -- Ratings
        vendor_rating smallint CHECK (
            vendor_rating BETWEEN 1 AND 5
        ),
        customer_rating smallint CHECK (
            customer_rating BETWEEN 1 AND 5
        ),
        -- Metadata
        device_info jsonb DEFAULT '{}'::jsonb,
        -- OS, app version, etc
        order_source varchar(50) DEFAULT 'app',
        -- app, web, pos
        created_at timestamp with time zone NOT NULL DEFAULT now(),
        updated_at timestamp with time zone NOT NULL DEFAULT now(),
        completed_at timestamp with time zone,
        cancelled_at timestamp with time zone,
        CONSTRAINT valid_amounts CHECK (
            subtotal >= 0
            AND total_amount >= 0
            AND tax_amount >= 0
            AND service_fee >= 0
            AND tip_amount >= 0
            AND discount_amount >= 0
        ),
        CONSTRAINT valid_total CHECK (
            total_amount = subtotal + tax_amount + service_fee + tip_amount - discount_amount
        )
);
-- Order items
CREATE TABLE order_items (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id uuid NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    product_variant_id uuid REFERENCES product_variants(id) ON DELETE
    SET NULL,
        -- Item details (snapshot at order time)
        product_name varchar(255) NOT NULL,
        product_sku varchar(100),
        variant_name varchar(255),
        -- Stores variant name at time of order
        -- Quantity and pricing
        quantity integer NOT NULL DEFAULT 1,
        unit_price decimal(10, 2) NOT NULL,
        unit_cost decimal(10, 2),
        total_price decimal(10, 2) NOT NULL,
        tax_amount decimal(10, 2) NOT NULL DEFAULT 0,
        -- Item-specific tax
        -- Customizations
        email varchar(255),
        selected_options jsonb DEFAULT '[]'::jsonb,
        -- Array of selected options with prices
        special_instructions text,
        -- Preparation
        preparation_time integer NOT NULL DEFAULT 0,
        created_at timestamp with time zone NOT NULL DEFAULT now(),
        CONSTRAINT valid_quantity CHECK (quantity > 0),
        CONSTRAINT valid_prices CHECK (
            unit_price >= 0
            AND total_price >= 0
        ),
        CONSTRAINT valid_item_total CHECK (total_price = unit_price * quantity)
);
-- ============================================================================
-- CART SYSTEM TABLES
-- ============================================================================
-- Shopping carts (users must be logged in)
CREATE TABLE carts (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    vendor_id uuid REFERENCES vendors(id) ON DELETE CASCADE,
    -- Cart state
    is_active boolean NOT NULL DEFAULT true,
    -- Timing
    expires_at timestamp with time zone DEFAULT (now() + interval '3 days'),
    last_activity_at timestamp with time zone DEFAULT now(),
    -- Saved info
    selected_pickup_time timestamp with time zone,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);
-- Ensure one active cart per user-vendor combination
CREATE UNIQUE INDEX unique_active_cart_per_user_vendor ON carts (user_id, vendor_id)
WHERE is_active = true;
-- Cart items
CREATE TABLE cart_items (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id uuid NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    product_variant_id uuid REFERENCES product_variants(id) ON DELETE
    SET NULL,
        -- Quantity and pricing
        quantity integer NOT NULL DEFAULT 1,
        unit_price decimal(10, 2) NOT NULL,
        -- Customizations
        selected_options jsonb DEFAULT '[]'::jsonb,
        special_instructions text,
        created_at timestamp with time zone NOT NULL DEFAULT now(),
        updated_at timestamp with time zone NOT NULL DEFAULT now(),
        CONSTRAINT valid_cart_quantity CHECK (quantity > 0),
        CONSTRAINT valid_cart_unit_price CHECK (unit_price >= 0)
);
-- ============================================================================
-- STRIPE INTEGRATION TABLES
-- ============================================================================
-- Subscription plans
CREATE TABLE subscription_plans (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    stripe_product_id varchar(255) NOT NULL UNIQUE,
    stripe_price_id varchar(255) NOT NULL UNIQUE,
    -- Plan details
    name jsonb NOT NULL DEFAULT '{}'::jsonb,
    description jsonb NOT NULL DEFAULT '{}'::jsonb,
    -- Pricing
    price decimal(10, 2) NOT NULL,
    currency varchar(3) NOT NULL DEFAULT 'EUR',
    billing_interval varchar(20) NOT NULL DEFAULT 'month',
    billing_interval_count integer NOT NULL DEFAULT 1,
    -- Trial
    trial_period_days integer DEFAULT 7,
    -- Promotional pricing
    is_promotional boolean NOT NULL DEFAULT false,
    promotional_price decimal(10, 2),
    promotional_months integer,
    promotional_end_date timestamp with time zone,
    -- Features and limits
    features jsonb NOT NULL DEFAULT '{}'::jsonb,
    max_locations integer,
    max_products integer,
    max_orders_per_month integer,
    commission_rate_override decimal(5, 4),
    -- Display
    is_active boolean NOT NULL DEFAULT true,
    is_featured boolean NOT NULL DEFAULT false,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_plan_price CHECK (price >= 0),
    CONSTRAINT valid_promotional_price CHECK (
        promotional_price IS NULL
        OR promotional_price >= 0
    ),
    CONSTRAINT valid_currency CHECK (currency IN ('EUR', 'USD', 'GBP'))
);
-- Vendor Stripe accounts
CREATE TABLE vendor_stripe_accounts (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE UNIQUE,
    -- Customer account (for subscriptions)
    stripe_customer_id varchar(255) NOT NULL UNIQUE,
    default_payment_method_id varchar(255),
    -- Connect account (for payouts)
    stripe_connect_account_id varchar(255) UNIQUE,
    is_connect_enabled boolean NOT NULL DEFAULT false,
    connect_charges_enabled boolean NOT NULL DEFAULT false,
    connect_payouts_enabled boolean NOT NULL DEFAULT false,
    connect_details_submitted boolean NOT NULL DEFAULT false,
    -- Account status
    account_status varchar(50) DEFAULT 'pending',
    verification_status jsonb DEFAULT '{}'::jsonb,
    -- Banking info (encrypted)
    bank_account_last4 varchar(4),
    bank_account_currency varchar(3),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);
-- Vendor subscriptions
CREATE TABLE vendor_subscriptions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    subscription_plan_id uuid NOT NULL REFERENCES subscription_plans(id) ON DELETE RESTRICT,
    stripe_subscription_id varchar(255) NOT NULL UNIQUE,
    -- Status
    status subscription_status_enum NOT NULL DEFAULT 'trialing',
    status_reason text,
    -- Billing periods
    current_period_start timestamp with time zone NOT NULL,
    current_period_end timestamp with time zone NOT NULL,
    trial_start timestamp with time zone,
    trial_end timestamp with time zone,
    -- Cancellation
    cancel_at_period_end boolean NOT NULL DEFAULT false,
    cancel_at timestamp with time zone,
    canceled_at timestamp with time zone,
    cancellation_reason text,
    cancellation_feedback jsonb,
    -- Pricing (may differ from plan)
    current_price decimal(10, 2) NOT NULL,
    current_currency varchar(3) NOT NULL DEFAULT 'EUR',
    -- Promotion tracking
    is_promotional boolean NOT NULL DEFAULT false,
    promotional_end_date timestamp with time zone,
    original_plan_id uuid REFERENCES subscription_plans(id),
    discount_code varchar(50),
    -- Usage tracking
    current_month_orders integer NOT NULL DEFAULT 0,
    current_month_revenue decimal(10, 2) NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_current_price CHECK (current_price >= 0),
    CONSTRAINT valid_period CHECK (current_period_end > current_period_start)
);
-- Commission rates
CREATE TABLE commission_rates (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id uuid REFERENCES vendors(id) ON DELETE CASCADE,
    subscription_plan_id uuid REFERENCES subscription_plans(id) ON DELETE
    SET NULL,
        -- Rate structure
        percentage_rate decimal(5, 4) NOT NULL DEFAULT 0.05,
        fixed_fee_cents integer NOT NULL DEFAULT 30,
        currency varchar(3) NOT NULL DEFAULT 'EUR',
        -- Promotional rates
        is_promotional boolean NOT NULL DEFAULT false,
        promotional_percentage decimal(5, 4),
        promotional_fixed_fee_cents integer,
        promotional_end_date timestamp with time zone,
        -- Application rules
        min_order_amount decimal(10, 2),
        max_order_amount decimal(10, 2),
        order_type_restrictions varchar(20) [],
        category_restrictions uuid [],
        -- Validity period
        effective_from timestamp with time zone NOT NULL DEFAULT now(),
        effective_until timestamp with time zone,
        is_active boolean NOT NULL DEFAULT true,
        -- Metadata
        name varchar(255),
        description text,
        created_at timestamp with time zone NOT NULL DEFAULT now(),
        CONSTRAINT valid_percentage CHECK (
            percentage_rate >= 0
            AND percentage_rate <= 1
        ),
        CONSTRAINT valid_promotional_percentage CHECK (
            promotional_percentage IS NULL
            OR (
                promotional_percentage >= 0
                AND promotional_percentage <= 1
            )
        ),
        CONSTRAINT valid_fees CHECK (
            fixed_fee_cents >= 0
            AND (
                promotional_fixed_fee_cents IS NULL
                OR promotional_fixed_fee_cents >= 0
            )
        ),
        CONSTRAINT valid_order_amounts CHECK (
            max_order_amount IS NULL
            OR min_order_amount IS NULL
            OR max_order_amount >= min_order_amount
        ),
        CONSTRAINT valid_effective_dates CHECK (
            effective_until IS NULL
            OR effective_until > effective_from
        )
);
-- Financial transactions
CREATE TABLE financial_transactions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE RESTRICT,
    order_id uuid REFERENCES orders(id) ON DELETE
    SET NULL,
        subscription_id uuid REFERENCES vendor_subscriptions(id) ON DELETE
    SET NULL,
        -- Transaction details
        transaction_type transaction_type_enum NOT NULL,
        transaction_status varchar(50) NOT NULL DEFAULT 'pending',
        -- Amounts (all in cents for precision)
        gross_amount_cents bigint NOT NULL,
        commission_percentage decimal(5, 4),
        commission_amount_cents bigint,
        fixed_fee_cents integer,
        stripe_fee_cents integer,
        net_amount_cents bigint NOT NULL,
        currency varchar(3) NOT NULL DEFAULT 'EUR',
        exchange_rate decimal(10, 6) DEFAULT 1,
        -- Stripe references
        stripe_payment_intent_id varchar(255),
        stripe_charge_id varchar(255),
        stripe_transfer_id varchar(255),
        stripe_refund_id varchar(255),
        stripe_payout_id varchar(255),
        -- Settlement tracking
        is_settled boolean NOT NULL DEFAULT false,
        settled_at timestamp with time zone,
        settlement_batch_id uuid,
        -- Payout tracking
        is_paid_to_vendor boolean NOT NULL DEFAULT false,
        paid_to_vendor_at timestamp with time zone,
        payout_method varchar(50),
        -- Metadata
        metadata jsonb DEFAULT '{}'::jsonb,
        notes text,
        idempotency_key varchar(255) UNIQUE,
        created_at timestamp with time zone NOT NULL DEFAULT now(),
        CONSTRAINT valid_amounts_cents CHECK (
            gross_amount_cents >= 0
            AND net_amount_cents >= 0
            AND (
                commission_amount_cents IS NULL
                OR commission_amount_cents >= 0
            )
            AND (
                fixed_fee_cents IS NULL
                OR fixed_fee_cents >= 0
            )
            AND (
                stripe_fee_cents IS NULL
                OR stripe_fee_cents >= 0
            )
        )
);
-- Subscription invoices
CREATE TABLE subscription_invoices (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_subscription_id uuid NOT NULL REFERENCES vendor_subscriptions(id) ON DELETE CASCADE,
    stripe_invoice_id varchar(255) NOT NULL UNIQUE,
    stripe_payment_intent_id varchar(255),
    -- Invoice details
    invoice_number varchar(100) UNIQUE,
    status invoice_status_enum NOT NULL DEFAULT 'draft',
    -- Amounts (in cents)
    subtotal_cents bigint NOT NULL,
    tax_cents bigint DEFAULT 0,
    total_cents bigint NOT NULL,
    amount_paid_cents bigint DEFAULT 0,
    amount_due_cents bigint NOT NULL,
    currency varchar(3) NOT NULL DEFAULT 'EUR',
    -- Dates
    invoice_date timestamp with time zone NOT NULL,
    due_date timestamp with time zone,
    paid_at timestamp with time zone,
    voided_at timestamp with time zone,
    -- Billing period
    period_start timestamp with time zone NOT NULL,
    period_end timestamp with time zone NOT NULL,
    -- URLs
    hosted_invoice_url varchar(500),
    invoice_pdf_url varchar(500),
    -- Metadata
    line_items jsonb NOT NULL DEFAULT '[]'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_invoice_amounts_cents CHECK (
        subtotal_cents >= 0
        AND total_cents >= 0
        AND amount_paid_cents >= 0
        AND amount_due_cents >= 0
        AND tax_cents >= 0
    )
);
-- Payout batches
CREATE TABLE payout_batches (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    batch_number varchar(50) NOT NULL UNIQUE,
    -- Batch details
    payout_date date NOT NULL,
    status varchar(50) NOT NULL DEFAULT 'pending',
    -- Totals
    total_vendors integer NOT NULL DEFAULT 0,
    total_amount_cents bigint NOT NULL DEFAULT 0,
    currency varchar(3) NOT NULL DEFAULT 'EUR',
    -- Processing
    processed_at timestamp with time zone,
    failed_at timestamp with time zone,
    failure_reason text,
    -- Stripe
    stripe_payout_batch_id varchar(255),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);
-- Individual vendor payouts
CREATE TABLE vendor_payouts (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    payout_batch_id uuid NOT NULL REFERENCES payout_batches(id) ON DELETE CASCADE,
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE RESTRICT,
    -- Payout details
    amount_cents bigint NOT NULL,
    currency varchar(3) NOT NULL DEFAULT 'EUR',
    description text,
    -- Status
    status varchar(50) NOT NULL DEFAULT 'pending',
    -- Stripe
    stripe_transfer_id varchar(255),
    stripe_payout_id varchar(255),
    -- Processing
    processed_at timestamp with time zone,
    failed_at timestamp with time zone,
    failure_reason text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_payout_amount CHECK (amount_cents > 0)
);
-- Stripe webhook events
CREATE TABLE stripe_webhook_events (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    stripe_event_id varchar(255) NOT NULL UNIQUE,
    event_type varchar(100) NOT NULL,
    api_version varchar(20),
    -- Event data
    event_data jsonb NOT NULL,
    -- Processing
    processed boolean NOT NULL DEFAULT false,
    processed_at timestamp with time zone,
    processing_duration_ms integer,
    processing_error text,
    error_count integer NOT NULL DEFAULT 0,
    last_error_at timestamp with time zone,
    -- Retry management
    retry_count integer NOT NULL DEFAULT 0,
    retry_after timestamp with time zone,
    max_retries integer NOT NULL DEFAULT 5,
    -- Metadata
    related_object_type varchar(50),
    related_object_id varchar(255),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT valid_retry_count CHECK (
        retry_count >= 0
        AND retry_count <= max_retries
    )
);
-- ============================================================================
-- FINANCIAL ANALYTICS
-- ============================================================================
-- Daily financial analytics
CREATE TABLE vendor_financial_analytics (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    analytics_date date NOT NULL,
    -- Revenue breakdown (cents for precision)
    gross_revenue_cents bigint NOT NULL DEFAULT 0,
    net_revenue_cents bigint NOT NULL DEFAULT 0,
    refunded_amount_cents bigint NOT NULL DEFAULT 0,
    -- Fee breakdown
    commission_paid_cents bigint NOT NULL DEFAULT 0,
    stripe_fees_cents bigint NOT NULL DEFAULT 0,
    subscription_fee_cents bigint NOT NULL DEFAULT 0,
    total_fees_cents bigint NOT NULL DEFAULT 0,
    -- Order metrics
    total_orders integer NOT NULL DEFAULT 0,
    completed_orders integer NOT NULL DEFAULT 0,
    cancelled_orders integer NOT NULL DEFAULT 0,
    refunded_orders integer NOT NULL DEFAULT 0,
    average_order_value_cents bigint DEFAULT 0,
    -- Product metrics
    items_sold integer NOT NULL DEFAULT 0,
    unique_products_sold integer NOT NULL DEFAULT 0,
    -- Commission metrics
    effective_commission_rate decimal(5, 4),
    blended_take_rate decimal(5, 4),
    -- Total fees / gross revenue
    -- Payment metrics
    payment_success_rate decimal(5, 4),
    average_payment_time_seconds integer,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT unique_vendor_date UNIQUE(vendor_id, analytics_date),
    CONSTRAINT valid_amounts_cents CHECK (
        gross_revenue_cents >= 0
        AND net_revenue_cents >= 0
        AND commission_paid_cents >= 0
        AND stripe_fees_cents >= 0
        AND subscription_fee_cents >= 0
        AND refunded_amount_cents >= 0
    )
);
-- ============================================================================
-- RELATIONSHIP TABLES
-- ============================================================================
-- Vendor tags (many-to-many)
CREATE TABLE vendor_tags (
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    tag_id uuid NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    added_by uuid REFERENCES profiles(id) ON DELETE
    SET NULL,
        created_at timestamp with time zone NOT NULL DEFAULT now(),
        PRIMARY KEY (vendor_id, tag_id)
);
-- Product tags (many-to-many)
CREATE TABLE product_tags (
    product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    tag_id uuid NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    PRIMARY KEY (product_id, tag_id)
);
-- User favorites (simplified)
CREATE TABLE user_favorites (
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    -- Notification preferences
    notifications_enabled boolean NOT NULL DEFAULT true,
    notify_new_locations boolean NOT NULL DEFAULT true,
    notify_promotions boolean NOT NULL DEFAULT true,
    notify_new_products boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, vendor_id)
);
-- ============================================================================
-- REVIEW SYSTEM
-- ============================================================================
-- Vendor reviews
CREATE TABLE vendor_reviews (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    vendor_id uuid NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    order_id uuid REFERENCES orders(id) ON DELETE
    SET NULL,
        -- Ratings
        overall_rating integer NOT NULL CHECK (
            overall_rating BETWEEN 1 AND 5
        ),
        food_rating integer CHECK (
            food_rating BETWEEN 1 AND 5
        ),
        service_rating integer CHECK (
            service_rating BETWEEN 1 AND 5
        ),
        value_rating integer CHECK (
            value_rating BETWEEN 1 AND 5
        ),
        -- Review content (limited to 500 chars)
        title varchar(255),
        comment varchar(500),
        -- Media (max 3 images)
        images jsonb DEFAULT '[]'::jsonb CHECK (jsonb_array_length(images) <= 3),
        -- Verification
        is_verified boolean NOT NULL DEFAULT false,
        verification_type varchar(50),
        -- 'order' only for MVP
        -- Response (limited)
        vendor_response varchar(500),
        vendor_response_at timestamp with time zone,
        -- Moderation
        is_hidden boolean NOT NULL DEFAULT false,
        hide_reason varchar(100),
        moderated_at timestamp with time zone,
        moderated_by uuid REFERENCES profiles(id) ON DELETE
    SET NULL,
        -- Engagement (likes only)
        helpful_count integer NOT NULL DEFAULT 0,
        created_at timestamp with time zone NOT NULL DEFAULT now(),
        updated_at timestamp with time zone NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX unique_user_order_review ON vendor_reviews(user_id, order_id)
WHERE order_id IS NOT NULL;
-- Review votes (helpful only)
CREATE TABLE review_votes (
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    review_id uuid NOT NULL REFERENCES vendor_reviews(id) ON DELETE CASCADE,
    is_helpful boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, review_id)
);
-- ============================================================================
-- NOTIFICATION SYSTEM
-- ============================================================================
-- Notifications
CREATE TABLE notifications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    -- Notification details
    type notification_type_enum NOT NULL,
    title varchar(255) NOT NULL,
    message text NOT NULL,
    -- Rich content
    data jsonb DEFAULT '{}'::jsonb,
    action_url varchar(500),
    image_url varchar(500),
    -- Delivery channels
    channels varchar(20) [] NOT NULL DEFAULT '{push}',
    -- Status tracking
    is_read boolean NOT NULL DEFAULT false,
    read_at timestamp with time zone,
    is_sent boolean NOT NULL DEFAULT false,
    sent_at timestamp with time zone,
    is_clicked boolean NOT NULL DEFAULT false,
    clicked_at timestamp with time zone,
    -- Scheduling
    scheduled_at timestamp with time zone,
    -- Expiration
    expires_at timestamp with time zone DEFAULT (now() + interval '30 days'),
    -- Priority
    priority varchar(20) NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    created_at timestamp with time zone NOT NULL DEFAULT now()
);
-- Push notification tokens
CREATE TABLE push_tokens (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    -- Token details
    token varchar(500) NOT NULL UNIQUE,
    platform varchar(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    -- Device info
    device_id varchar(255),
    device_model varchar(100),
    os_version varchar(50),
    app_version varchar(50),
    -- Status
    is_active boolean NOT NULL DEFAULT true,
    last_used_at timestamp with time zone,
    failure_count integer NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);
-- ============================================================================
-- ACTIVITY TRACKING (Optional for MVP)
-- ============================================================================
-- User activity log (can be removed for MVP)
CREATE TABLE user_activities (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    session_id varchar(255),
    -- Activity details
    activity_type varchar(50) NOT NULL,
    activity_data jsonb DEFAULT '{}'::jsonb,
    -- Context
    vendor_id uuid REFERENCES vendors(id) ON DELETE CASCADE,
    product_id uuid REFERENCES products(id) ON DELETE CASCADE,
    order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
    -- Device/location
    ip_address inet,
    user_agent text,
    location geography(POINT, 4326),
    created_at timestamp with time zone NOT NULL DEFAULT now()
);
-- Search history
CREATE TABLE search_history (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    -- Search details
    search_query text NOT NULL,
    search_filters jsonb DEFAULT '{}'::jsonb,
    search_location geography(POINT, 4326),
    -- Results
    result_count integer NOT NULL DEFAULT 0,
    clicked_results uuid [] DEFAULT '{}',
    created_at timestamp with time zone NOT NULL DEFAULT now()
);
-- Trending searches
CREATE TABLE trending_searches (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    search_term varchar(255) NOT NULL,
    normalized_term varchar(255) NOT NULL,
    -- Metrics
    search_count integer NOT NULL DEFAULT 1,
    unique_users integer NOT NULL DEFAULT 1,
    conversion_rate decimal(5, 4) DEFAULT 0,
    -- Time window
    period_start timestamp with time zone NOT NULL,
    period_end timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT unique_term_period UNIQUE(normalized_term, period_start, period_end)
);
-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================
-- Spatial indexes
CREATE INDEX idx_vendor_locations_geography ON vendor_locations USING GIST (position);
CREATE INDEX idx_vendor_locations_current_active ON vendor_locations (vendor_id, status)
WHERE status = 'active';
CREATE INDEX idx_vendor_locations_planned ON vendor_locations (vendor_id, starts_at)
WHERE status = 'planned';
CREATE INDEX idx_profiles_last_location ON profiles USING GIST (last_known_location);
CREATE INDEX idx_user_activities_location ON user_activities USING GIST (location);
-- Time-based indexes
CREATE INDEX idx_vendor_locations_heartbeat ON vendor_locations (last_heartbeat)
WHERE status = 'active';
CREATE INDEX idx_orders_pickup_time ON orders (requested_pickup_time)
WHERE status IN ('pending', 'confirmed', 'preparing');
-- Search indexes
CREATE INDEX idx_products_allergens ON products USING GIN (allergens);
CREATE INDEX idx_products_dietary ON products USING GIN (dietary_tags);
CREATE INDEX idx_vendors_business_name ON vendors USING GIN (business_name gin_trgm_ops);
CREATE INDEX idx_vendors_description ON vendors USING GIN (description gin_trgm_ops);
CREATE INDEX idx_products_name ON products USING GIN (name gin_trgm_ops);
CREATE INDEX idx_products_description ON products USING GIN (description gin_trgm_ops);
-- Performance indexes
CREATE INDEX idx_orders_user_status ON orders (user_id, status, created_at DESC);
CREATE INDEX idx_orders_vendor_status ON orders (vendor_id, status, created_at DESC);
CREATE INDEX idx_notifications_user_unread ON notifications (user_id, is_read, created_at DESC)
WHERE is_read = false;
CREATE INDEX idx_cart_items_cart_product ON cart_items (cart_id, product_id);
CREATE INDEX idx_financial_transactions_settlement ON financial_transactions (vendor_id, is_settled, created_at)
WHERE is_settled = false;
CREATE INDEX idx_vendor_reviews_vendor_visible ON vendor_reviews (vendor_id, is_hidden, created_at DESC)
WHERE is_hidden = false;
-- Composite indexes
CREATE INDEX idx_vendor_analytics_vendor_date ON vendor_analytics (vendor_id, analytics_date DESC);
CREATE INDEX idx_vendor_financial_date ON vendor_financial_analytics (vendor_id, analytics_date DESC);
CREATE INDEX idx_products_vendor_available ON products (vendor_id, is_available, is_featured DESC);
CREATE INDEX idx_vendor_events_active_date ON vendor_events (vendor_id, is_active, starts_at, ends_at)
WHERE is_active = true;
-- Unique partial indexes
CREATE UNIQUE INDEX idx_one_active_location_per_vendor ON vendor_locations (vendor_id)
WHERE status = 'active';
CREATE UNIQUE INDEX idx_one_default_variant_per_product ON product_variants (product_id)
WHERE is_default = true;
-- ============================================================================
-- TRIGGERS
-- ============================================================================
-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = now();
RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = '';
-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_profiles_updated_at BEFORE
UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vendors_updated_at BEFORE
UPDATE ON vendors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vendor_locations_updated_at BEFORE
UPDATE ON vendor_locations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE
UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_product_variants_updated_at BEFORE
UPDATE ON product_variants FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE
UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vendor_reviews_updated_at BEFORE
UPDATE ON vendor_reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_carts_updated_at BEFORE
UPDATE ON carts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_cart_items_updated_at BEFORE
UPDATE ON cart_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscription_plans_updated_at BEFORE
UPDATE ON subscription_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vendor_stripe_accounts_updated_at BEFORE
UPDATE ON vendor_stripe_accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vendor_subscriptions_updated_at BEFORE
UPDATE ON vendor_subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscription_invoices_updated_at BEFORE
UPDATE ON subscription_invoices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE
UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tags_updated_at BEFORE
UPDATE ON tags FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vendor_events_updated_at BEFORE
UPDATE ON vendor_events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_option_groups_updated_at BEFORE
UPDATE ON option_groups FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_options_updated_at BEFORE
UPDATE ON options FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_favorites_updated_at BEFORE
UPDATE ON user_favorites FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_push_tokens_updated_at BEFORE
UPDATE ON push_tokens FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payout_batches_updated_at BEFORE
UPDATE ON payout_batches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
-- Function to update vendor rating when review is added/updated/deleted
CREATE OR REPLACE FUNCTION update_vendor_rating() RETURNS TRIGGER AS $$ BEGIN IF TG_OP = 'DELETE' THEN
UPDATE vendors
SET average_rating = COALESCE(
        (
            SELECT ROUND(AVG(overall_rating)::numeric, 2)
            FROM vendor_reviews
            WHERE vendor_id = OLD.vendor_id
                AND is_hidden = false
        ),
        0
    ),
    total_reviews = (
        SELECT COUNT(*)
        FROM vendor_reviews
        WHERE vendor_id = OLD.vendor_id
            AND is_hidden = false
    )
WHERE id = OLD.vendor_id;
RETURN OLD;
ELSE
UPDATE vendors
SET average_rating = COALESCE(
        (
            SELECT ROUND(AVG(overall_rating)::numeric, 2)
            FROM vendor_reviews
            WHERE vendor_id = NEW.vendor_id
                AND is_hidden = false
        ),
        0
    ),
    total_reviews = (
        SELECT COUNT(*)
        FROM vendor_reviews
        WHERE vendor_id = NEW.vendor_id
            AND is_hidden = false
    )
WHERE id = NEW.vendor_id;
RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
CREATE TRIGGER update_vendor_rating_trigger
AFTER
INSERT
    OR
UPDATE
    OR DELETE ON vendor_reviews FOR EACH ROW EXECUTE FUNCTION update_vendor_rating();
-- Function to copy preparation_time to order_items when created
CREATE OR REPLACE FUNCTION copy_preparation_time() RETURNS TRIGGER AS $$ BEGIN
SELECT preparation_time INTO NEW.preparation_time
FROM products p
WHERE p.id = NEW.product_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
CREATE TRIGGER copy_preparation_time_trigger BEFORE
INSERT ON order_items FOR EACH ROW EXECUTE FUNCTION copy_preparation_time();
-- Function to get or create active cart for user
CREATE OR REPLACE FUNCTION get_or_create_user_cart(p_user_id uuid, p_vendor_id uuid) RETURNS uuid AS $$
DECLARE cart_id uuid;
BEGIN -- Try to find existing active cart for this vendor
SELECT id INTO cart_id
FROM carts
WHERE user_id = p_user_id
    AND vendor_id = p_vendor_id
    AND is_active = true
LIMIT 1;
-- If no active cart exists, create one
IF cart_id IS NULL THEN
INSERT INTO carts (user_id, vendor_id, is_active)
VALUES (p_user_id, p_vendor_id, true)
RETURNING id INTO cart_id;
END IF;
RETURN cart_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public';
-- Function to calculate cart total
CREATE OR REPLACE FUNCTION calculate_cart_total(p_cart_id uuid) RETURNS decimal(10, 2) AS $$
DECLARE total decimal(10, 2);
BEGIN
SELECT COALESCE(SUM(unit_price * quantity), 0) INTO total
FROM cart_items
WHERE cart_id = p_cart_id;
RETURN total;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public';
-- Function to update tag usage counts
CREATE OR REPLACE FUNCTION update_tag_usage_count() RETURNS TRIGGER AS $$ BEGIN IF TG_OP = 'INSERT' THEN
UPDATE tags
SET usage_count = usage_count + 1
WHERE id = NEW.tag_id;
ELSIF TG_OP = 'DELETE' THEN
UPDATE tags
SET usage_count = usage_count - 1
WHERE id = OLD.tag_id;
END IF;
RETURN NULL;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
CREATE TRIGGER update_vendor_tag_count
AFTER
INSERT
    OR DELETE ON vendor_tags FOR EACH ROW EXECUTE FUNCTION update_tag_usage_count();
CREATE TRIGGER update_product_tag_count
AFTER
INSERT
    OR DELETE ON product_tags FOR EACH ROW EXECUTE FUNCTION update_tag_usage_count();
-- Function to verify review based on order
CREATE OR REPLACE FUNCTION verify_review_from_order() RETURNS TRIGGER AS $$ BEGIN -- Auto-verify if linked to completed order
    IF NEW.order_id IS NOT NULL THEN IF EXISTS (
        SELECT 1
        FROM orders
        WHERE id = NEW.order_id
            AND user_id = NEW.user_id
            AND vendor_id = NEW.vendor_id
            AND status = 'completed'
    ) THEN NEW.is_verified := true;
NEW.verification_type := 'order';
END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
CREATE TRIGGER verify_review_trigger BEFORE
INSERT
    OR
UPDATE OF order_id ON vendor_reviews FOR EACH ROW EXECUTE FUNCTION verify_review_from_order();
-- Function to update review helpful count
CREATE OR REPLACE FUNCTION update_review_helpful_count() RETURNS TRIGGER AS $$ BEGIN IF TG_OP = 'INSERT' THEN
UPDATE vendor_reviews
SET helpful_count = helpful_count + 1
WHERE id = NEW.review_id;
ELSIF TG_OP = 'DELETE' THEN
UPDATE vendor_reviews
SET helpful_count = helpful_count - 1
WHERE id = OLD.review_id;
END IF;
RETURN NULL;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
CREATE TRIGGER update_helpful_count_trigger
AFTER
INSERT
    OR DELETE ON review_votes FOR EACH ROW EXECUTE FUNCTION update_review_helpful_count();
-- Function to calculate commission amounts
CREATE OR REPLACE FUNCTION calculate_commission_amounts(
        p_vendor_id uuid,
        p_order_amount decimal(10, 2),
        p_order_date timestamp with time zone DEFAULT now()
    ) RETURNS TABLE (
        commission_percentage decimal(5, 4),
        commission_amount decimal(10, 2),
        fixed_fee_amount decimal(10, 2),
        net_amount decimal(10, 2)
    ) AS $$
DECLARE v_commission_rate commission_rates %ROWTYPE;
v_percentage decimal(5, 4);
v_fixed_fee decimal(10, 2);
v_commission decimal(10, 2);
v_net decimal(10, 2);
BEGIN -- Find applicable commission rate
SELECT cr.* INTO v_commission_rate
FROM commission_rates cr
WHERE (
        cr.vendor_id = p_vendor_id
        OR cr.vendor_id IS NULL
    )
    AND cr.is_active = true
    AND cr.effective_from <= p_order_date
    AND (
        cr.effective_until IS NULL
        OR cr.effective_until > p_order_date
    )
    AND (
        cr.min_order_amount IS NULL
        OR p_order_amount >= cr.min_order_amount
    )
    AND (
        cr.max_order_amount IS NULL
        OR p_order_amount <= cr.max_order_amount
    )
ORDER BY cr.vendor_id IS NOT NULL DESC,
    -- Priority to vendor-specific rates
    cr.effective_from DESC
LIMIT 1;
-- If no rate found, use defaults
IF v_commission_rate.id IS NULL THEN v_percentage := 0.05;
-- 5% default
v_fixed_fee := 0.30;
-- 0.30€ default
ELSE -- Check if we're in promotional period
IF v_commission_rate.is_promotional = true
AND v_commission_rate.promotional_end_date IS NOT NULL
AND p_order_date <= v_commission_rate.promotional_end_date THEN v_percentage := v_commission_rate.promotional_percentage;
ELSE v_percentage := v_commission_rate.percentage_rate;
END IF;
v_fixed_fee := v_commission_rate.fixed_fee_cents / 100.0;
END IF;
-- Calculate amounts
v_commission := ROUND(p_order_amount * v_percentage, 2);
v_net := p_order_amount - v_commission - v_fixed_fee;
-- Ensure net amount is not negative
IF v_net < 0 THEN v_net := 0;
END IF;
-- Return results
commission_percentage := v_percentage;
commission_amount := v_commission;
fixed_fee_amount := v_fixed_fee;
net_amount := v_net;
RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public';
-- Function to create financial transaction when order is paid
CREATE OR REPLACE FUNCTION create_order_financial_transaction() RETURNS TRIGGER AS $$
DECLARE v_commission_data RECORD;
v_stripe_fee decimal(10, 2) := 0;
BEGIN -- Create transaction only when payment is confirmed
IF NEW.payment_status = 'paid'
AND (
    OLD.payment_status IS NULL
    OR OLD.payment_status != 'paid'
) THEN -- Calculate commission amounts
SELECT * INTO v_commission_data
FROM calculate_commission_amounts(NEW.vendor_id, NEW.total_amount, NEW.created_at);
-- Estimate Stripe fees (about 1.4% + 0.25€ for EU cards)
v_stripe_fee := ROUND(NEW.total_amount * 0.014 + 0.25, 2);
-- Create financial transaction (convert to cents)
INSERT INTO financial_transactions (
        vendor_id,
        order_id,
        transaction_type,
        gross_amount_cents,
        commission_percentage,
        commission_amount_cents,
        fixed_fee_cents,
        stripe_fee_cents,
        net_amount_cents,
        currency,
        stripe_payment_intent_id
    )
VALUES (
        NEW.vendor_id,
        NEW.id,
        'commission',
        (NEW.total_amount * 100)::bigint,
        v_commission_data.commission_percentage,
        (v_commission_data.commission_amount * 100)::bigint,
        (v_commission_data.fixed_fee_amount * 100)::bigint,
        (v_stripe_fee * 100)::bigint,
        (v_commission_data.net_amount * 100)::bigint,
        'EUR',
        NEW.stripe_payment_intent_id
    );
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
-- Function to generate order numbers
CREATE OR REPLACE FUNCTION generate_order_number() RETURNS TRIGGER AS $$ BEGIN NEW.order_number = 'ORD-' || TO_CHAR(now(), 'YYYYMMDD') || '-' || LPAD(
        EXTRACT(
            EPOCH
            FROM now()
        )::text,
        10,
        '0'
    );
RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = '';
CREATE TRIGGER generate_order_number_trigger BEFORE
INSERT ON orders FOR EACH ROW
    WHEN (NEW.order_number IS NULL) EXECUTE FUNCTION generate_order_number();
-- Trigger to create financial transactions
CREATE TRIGGER create_order_financial_transaction_trigger
AFTER
UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION create_order_financial_transaction();
-- Function to check vendor location heartbeat
CREATE OR REPLACE FUNCTION check_vendor_location_heartbeat() RETURNS void AS $$ BEGIN -- Mark locations as inactive if no heartbeat for vendor's reminder_interval + 10 minutes
UPDATE vendor_locations vl
SET status = 'inactive',
    updated_at = now()
FROM vendors v
WHERE vl.vendor_id = v.id
    AND vl.status = 'active'
    AND vl.last_heartbeat < now() - (v.reminder_interval + 10) * interval '1 minute';
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
-- Function to clean up expired carts
CREATE OR REPLACE FUNCTION cleanup_expired_carts() RETURNS integer AS $$
DECLARE deleted_count integer;
BEGIN
DELETE FROM carts
WHERE expires_at IS NOT NULL
    AND expires_at < now();
GET DIAGNOSTICS deleted_count = ROW_COUNT;
RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public';
-- Function to clean up old data
CREATE OR REPLACE FUNCTION cleanup_old_data() RETURNS void AS $$ BEGIN -- Delete old expired carts
    PERFORM cleanup_expired_carts();
-- Delete old notifications
DELETE FROM notifications
WHERE expires_at < now()
    AND is_read = true;
-- Delete old search history
DELETE FROM search_history
WHERE created_at < now() - interval '90 days';
-- Delete old webhook events
DELETE FROM stripe_webhook_events
WHERE created_at < now() - interval '30 days'
    AND processed = true;
-- Archive old orders
UPDATE orders
SET status = 'completed'
WHERE status = 'ready'
    AND updated_at < now() - interval '24 hours';
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================
-- Find vendors near a location
CREATE OR REPLACE FUNCTION find_vendors_near(
        p_location geography(POINT, 4326),
        p_radius_meters integer DEFAULT 5000,
        p_limit integer DEFAULT 50
    ) RETURNS TABLE (
        vendor_id uuid,
        business_name varchar,
        distance_meters integer,
        location geography(POINT, 4326),
        status location_status_enum
    ) AS $$ BEGIN RETURN QUERY
SELECT DISTINCT ON (v.id) v.id,
    v.business_name,
    ST_Distance(vl.position, p_location)::integer as distance_meters,
    vl.position,
    vl.status
FROM vendors v
    JOIN vendor_locations vl ON v.id = vl.vendor_id
WHERE v.is_active = true
    AND vl.status = 'active'
    AND ST_DWithin(vl.position, p_location, p_radius_meters)
ORDER BY v.id,
    ST_Distance(vl.position, p_location)
LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE
SET search_path = 'public, extensions';
-- Calculate estimated order ready time
CREATE OR REPLACE FUNCTION calculate_order_ready_time(
        p_vendor_id uuid,
        p_items jsonb -- Array of {product_id, quantity}
    ) RETURNS timestamp with time zone AS $$
DECLARE v_current_orders integer;
v_avg_prep_time integer;
v_total_prep_time integer := 0;
v_item record;
BEGIN -- Get vendor info and current orders
SELECT COUNT(*) FILTER (
        WHERE o.status IN ('confirmed', 'preparing')
    ),
    v.average_preparation_time INTO v_current_orders,
    v_avg_prep_time
FROM vendors v
    LEFT JOIN orders o ON v.id = o.vendor_id
    AND o.status IN ('confirmed', 'preparing')
WHERE v.id = p_vendor_id
GROUP BY v.id,
    v.average_preparation_time;
-- Calculate total preparation time for items
FOR v_item IN
SELECT *
FROM jsonb_array_elements(p_items) LOOP v_total_prep_time := v_total_prep_time + (
        SELECT COALESCE(MAX(preparation_time), v_avg_prep_time) * (v_item->>'quantity')::integer
        FROM products
        WHERE id = (v_item->>'product_id')::uuid
    );
END LOOP;
-- Add buffer time based on current load
v_total_prep_time := v_total_prep_time + (v_current_orders * 5);
RETURN now() + (v_total_prep_time || ' minutes')::interval;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
-- ============================================================================
-- ADMIN SETUP - MUST BE DONE BEFORE RLS POLICIES
-- ============================================================================
-- Add admin field to profiles table
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS is_admin boolean NOT NULL DEFAULT false;
-- Create index for admin queries
CREATE INDEX IF NOT EXISTS idx_profiles_admin ON profiles (is_admin)
WHERE is_admin = true;
-- Function to promote a user to admin
CREATE OR REPLACE FUNCTION promote_to_admin(user_email text) RETURNS boolean AS $$ BEGIN
UPDATE profiles
SET is_admin = true
WHERE id IN (
        SELECT id
        FROM auth.users
        WHERE email = user_email
    );
RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public, auth';
-- Function to demote an admin user
CREATE OR REPLACE FUNCTION demote_from_admin(user_email text) RETURNS boolean AS $$ BEGIN
UPDATE profiles
SET is_admin = false
WHERE id IN (
        SELECT id
        FROM auth.users
        WHERE email = user_email
    );
RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public, auth';
-- Function to check if current user is admin
CREATE OR REPLACE FUNCTION is_current_user_admin() RETURNS boolean AS $$ BEGIN RETURN EXISTS (
        SELECT 1
        FROM profiles
        WHERE id = auth.uid()
            AND is_admin = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public, auth';
-- ============================================================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================================================
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_stripe_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_financial_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE option_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE options ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_payouts ENABLE ROW LEVEL SECURITY;
-- Additional tables that need RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE commission_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE payout_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE stripe_webhook_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE trending_searches ENABLE ROW LEVEL SECURITY;
-- ============================================================================
-- MISSING RLS POLICIES FOR TABLES
-- ============================================================================
-- Cart items policies
CREATE POLICY cart_items_user_all ON cart_items FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM carts c
        WHERE c.id = cart_items.cart_id
            AND c.user_id = auth.uid()
    )
);
-- Option groups policies
CREATE POLICY option_groups_select_public ON option_groups FOR
SELECT USING (
        is_active = true
        OR EXISTS (
            SELECT 1
            FROM products p
                JOIN vendors v ON p.vendor_id = v.id
            WHERE p.id = option_groups.product_id
                AND v.user_id = auth.uid()
        )
    );
CREATE POLICY option_groups_manage_vendor ON option_groups FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM products p
            JOIN vendors v ON p.vendor_id = v.id
        WHERE p.id = option_groups.product_id
            AND v.user_id = auth.uid()
    )
);
-- Options policies
CREATE POLICY options_select_public ON options FOR
SELECT USING (
        is_available = true
        OR EXISTS (
            SELECT 1
            FROM option_groups og
                JOIN products p ON og.product_id = p.id
                JOIN vendors v ON p.vendor_id = v.id
            WHERE og.id = options.option_group_id
                AND v.user_id = auth.uid()
        )
    );
CREATE POLICY options_manage_vendor ON options FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM option_groups og
            JOIN products p ON og.product_id = p.id
            JOIN vendors v ON p.vendor_id = v.id
        WHERE og.id = options.option_group_id
            AND v.user_id = auth.uid()
    )
);
-- Order items policies
CREATE POLICY order_items_customer_select ON order_items FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM orders o
            WHERE o.id = order_items.order_id
                AND o.user_id = auth.uid()
        )
    );
CREATE POLICY order_items_vendor_select ON order_items FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM orders o
                JOIN vendors v ON o.vendor_id = v.id
            WHERE o.id = order_items.order_id
                AND v.user_id = auth.uid()
        )
    );
CREATE POLICY order_items_admin_select ON order_items FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- Product variants policies
CREATE POLICY product_variants_select_public ON product_variants FOR
SELECT USING (
        is_available = true
        OR EXISTS (
            SELECT 1
            FROM products p
                JOIN vendors v ON p.vendor_id = v.id
            WHERE p.id = product_variants.product_id
                AND v.user_id = auth.uid()
        )
    );
CREATE POLICY product_variants_manage_vendor ON product_variants FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM products p
            JOIN vendors v ON p.vendor_id = v.id
        WHERE p.id = product_variants.product_id
            AND v.user_id = auth.uid()
    )
);
-- Push tokens policies
CREATE POLICY push_tokens_user_all ON push_tokens FOR ALL USING (auth.uid() = user_id);
-- Review votes policies
CREATE POLICY review_votes_user_all ON review_votes FOR ALL USING (auth.uid() = user_id);
CREATE POLICY review_votes_select_public ON review_votes FOR
SELECT USING (true);
-- Search history policies
CREATE POLICY search_history_user_all ON search_history FOR ALL USING (
    user_id IS NULL
    OR auth.uid() = user_id
);
CREATE POLICY search_history_admin_select ON search_history FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- Subscription invoices policies
CREATE POLICY subscription_invoices_vendor_select ON subscription_invoices FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM vendor_subscriptions vs
                JOIN vendors v ON vs.vendor_id = v.id
            WHERE vs.id = subscription_invoices.vendor_subscription_id
                AND v.user_id = auth.uid()
        )
    );
CREATE POLICY subscription_invoices_admin_all ON subscription_invoices FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
-- User activities policies
CREATE POLICY user_activities_user_all ON user_activities FOR ALL USING (
    user_id IS NULL
    OR auth.uid() = user_id
);
CREATE POLICY user_activities_admin_select ON user_activities FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- User favorites policies
CREATE POLICY user_favorites_user_all ON user_favorites FOR ALL USING (auth.uid() = user_id);
-- Vendor events policies
CREATE POLICY vendor_events_select_public ON vendor_events FOR
SELECT USING (
        is_active = true
        AND is_approved = true
        AND (
            starts_at <= now()
            AND (
                ends_at IS NULL
                OR ends_at >= now()
            )
        )
    );
CREATE POLICY vendor_events_vendor_all ON vendor_events FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM vendors v
        WHERE v.id = vendor_events.vendor_id
            AND v.user_id = auth.uid()
    )
);
CREATE POLICY vendor_events_admin_all ON vendor_events FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
-- Vendor locations policies
CREATE POLICY vendor_locations_select_public ON vendor_locations FOR
SELECT USING (
        status IN ('active', 'planned', 'setting_up')
        OR EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = vendor_locations.vendor_id
                AND v.user_id = auth.uid()
        )
    );
CREATE POLICY vendor_locations_vendor_all ON vendor_locations FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM vendors v
        WHERE v.id = vendor_locations.vendor_id
            AND v.user_id = auth.uid()
    )
);
CREATE POLICY vendor_locations_admin_select ON vendor_locations FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- Vendor payouts policies
CREATE POLICY vendor_payouts_vendor_select ON vendor_payouts FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = vendor_payouts.vendor_id
                AND v.user_id = auth.uid()
        )
    );
CREATE POLICY vendor_payouts_admin_all ON vendor_payouts FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
-- Vendor stripe accounts policies
CREATE POLICY vendor_stripe_accounts_vendor_all ON vendor_stripe_accounts FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM vendors v
        WHERE v.id = vendor_stripe_accounts.vendor_id
            AND v.user_id = auth.uid()
    )
);
CREATE POLICY vendor_stripe_accounts_admin_select ON vendor_stripe_accounts FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- Vendor subscriptions policies
CREATE POLICY vendor_subscriptions_vendor_all ON vendor_subscriptions FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM vendors v
        WHERE v.id = vendor_subscriptions.vendor_id
            AND v.user_id = auth.uid()
    )
);
CREATE POLICY vendor_subscriptions_admin_select ON vendor_subscriptions FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- PostGIS system tables (created automatically in public schema)
-- Note: spatial_ref_sys is owned by postgres superuser and cannot be altered
-- This is a read-only reference table, so it's safe to exclude from RLS
-- ALTER TABLE spatial_ref_sys ENABLE ROW LEVEL SECURITY;
-- Profile policies
CREATE POLICY profiles_select_own ON profiles FOR
SELECT USING (
        auth.uid() = id
        OR is_active = true
    );
CREATE POLICY profiles_update_own ON profiles FOR
UPDATE USING (auth.uid() = id);
-- Vendor policies
CREATE POLICY vendors_select_public ON vendors FOR
SELECT USING (
        is_active = true
        OR auth.uid() IN (
            SELECT user_id
            FROM vendors
            WHERE id = vendors.id
        )
    );
CREATE POLICY vendors_manage_own ON vendors FOR ALL USING (auth.uid() = user_id);
-- Product policies
CREATE POLICY products_select_public ON products FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = products.vendor_id
                AND (
                    v.is_active = true
                    OR v.user_id = auth.uid()
                )
        )
    );
CREATE POLICY products_manage_vendor ON products FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM vendors v
        WHERE v.id = products.vendor_id
            AND v.user_id = auth.uid()
    )
);
-- Order policies
CREATE POLICY orders_customer_all ON orders FOR ALL USING (auth.uid() = user_id);
CREATE POLICY orders_vendor_select ON orders FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = orders.vendor_id
                AND v.user_id = auth.uid()
        )
    );
CREATE POLICY orders_vendor_update_status ON orders FOR
UPDATE USING (
        EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = orders.vendor_id
                AND v.user_id = auth.uid()
        )
    ) WITH CHECK (
        EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = orders.vendor_id
                AND v.user_id = auth.uid()
        )
    );
-- Cart policies
CREATE POLICY carts_user_all ON carts FOR ALL USING (auth.uid() = user_id);
-- Financial policies (read-only for vendors)
CREATE POLICY financial_vendor_select ON financial_transactions FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = financial_transactions.vendor_id
                AND v.user_id = auth.uid()
        )
    );
-- Notification policies
CREATE POLICY notifications_user_all ON notifications FOR ALL USING (auth.uid() = user_id);
-- Review policies
CREATE POLICY reviews_select_public ON vendor_reviews FOR
SELECT USING (
        is_hidden = false
        OR user_id = auth.uid()
    );
CREATE POLICY reviews_user_manage ON vendor_reviews FOR ALL USING (auth.uid() = user_id);
CREATE POLICY reviews_vendor_respond ON vendor_reviews FOR
UPDATE USING (
        EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = vendor_reviews.vendor_id
                AND v.user_id = auth.uid()
        )
    ) WITH CHECK (
        EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = vendor_reviews.vendor_id
                AND v.user_id = auth.uid()
        )
    );
-- Categories policies
CREATE POLICY categories_select_all ON categories FOR
SELECT USING (is_active = true);
CREATE POLICY categories_admin_all ON categories FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
-- Tags policies
CREATE POLICY tags_select_active ON tags FOR
SELECT USING (is_active = true);
CREATE POLICY tags_admin_all ON tags FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
CREATE POLICY tags_vendor_create_custom ON tags FOR
INSERT WITH CHECK (
        is_system = false
        AND EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.user_id = auth.uid()
        )
    );
-- Subscription plans policies
CREATE POLICY subscription_plans_select_active ON subscription_plans FOR
SELECT USING (is_active = true);
CREATE POLICY subscription_plans_admin_all ON subscription_plans FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
-- Commission rates policies
CREATE POLICY commission_rates_vendor_select ON commission_rates FOR
SELECT USING (
        vendor_id IS NOT NULL
        AND EXISTS (
            SELECT 1
            FROM vendors v
            WHERE v.id = commission_rates.vendor_id
                AND v.user_id = auth.uid()
        )
    );
CREATE POLICY commission_rates_admin_all ON commission_rates FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
-- Payout batches policies
CREATE POLICY payout_batches_admin_all ON payout_batches FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
-- Stripe webhook events policies
CREATE POLICY stripe_webhook_events_admin_select ON stripe_webhook_events FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- Vendor tags policies
CREATE POLICY vendor_tags_select_all ON vendor_tags FOR
SELECT USING (true);
CREATE POLICY vendor_tags_vendor_manage ON vendor_tags FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM vendors v
        WHERE v.id = vendor_tags.vendor_id
            AND v.user_id = auth.uid()
    )
);
-- Product tags policies
CREATE POLICY product_tags_select_all ON product_tags FOR
SELECT USING (true);
CREATE POLICY product_tags_vendor_manage ON product_tags FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM products p
            JOIN vendors v ON p.vendor_id = v.id
        WHERE p.id = product_tags.product_id
            AND v.user_id = auth.uid()
    )
);
-- Trending searches policies
CREATE POLICY trending_searches_select_all ON trending_searches FOR
SELECT USING (true);
CREATE POLICY trending_searches_admin_all ON trending_searches FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
-- PostGIS system table policies
-- Note: spatial_ref_sys RLS policy not needed since table RLS is disabled
-- CREATE POLICY spatial_ref_sys_select_all ON spatial_ref_sys FOR SELECT USING (true);
-- ============================================================================
-- PARTITIONING SETUP (Commented out for initial deployment)
-- ============================================================================
-- Uncomment and run these when you need partitioning for scale
-- -- Enable pg_cron extension for automated partition management
-- CREATE EXTENSION IF NOT EXISTS pg_cron;
-- -- Function to create monthly partitions automatically
-- CREATE OR REPLACE FUNCTION create_monthly_partitions()
-- RETURNS void AS $$
-- DECLARE
--     start_date date;
--     end_date date;
--     partition_name text;
-- BEGIN
--     -- Create partitions for next 3 months
--     FOR i IN 0..2 LOOP
--         start_date := date_trunc('month', CURRENT_DATE + (i || ' months')::interval);
--         end_date := date_trunc('month', CURRENT_DATE + ((i + 1) || ' months')::interval);
--         
--         -- Create partition for vendor_analytics
--         partition_name := 'vendor_analytics_' || to_char(start_date, 'YYYY_MM');
--         IF NOT EXISTS (
--             SELECT 1 FROM pg_tables 
--             WHERE tablename = partition_name
--         ) THEN
--             EXECUTE format(
--                 'CREATE TABLE %I PARTITION OF vendor_analytics FOR VALUES FROM (%L) TO (%L)',
--                 partition_name, start_date, end_date
--             );
--         END IF;
--         
--         -- Create partition for vendor_financial_analytics
--         partition_name := 'vendor_financial_analytics_' || to_char(start_date, 'YYYY_MM');
--         IF NOT EXISTS (
--             SELECT 1 FROM pg_tables 
--             WHERE tablename = partition_name
--         ) THEN
--             EXECUTE format(
--                 'CREATE TABLE %I PARTITION OF vendor_financial_analytics FOR VALUES FROM (%L) TO (%L)',
--                 partition_name, start_date, end_date
--             );
--         END IF;
--         
--         -- Create partition for user_activities
--         partition_name := 'user_activities_' || to_char(start_date, 'YYYY_MM');
--         IF NOT EXISTS (
--             SELECT 1 FROM pg_tables 
--             WHERE tablename = partition_name
--         ) THEN
--             EXECUTE format(
--                 'CREATE TABLE %I PARTITION OF user_activities FOR VALUES FROM (%L) TO (%L)',
--                 partition_name, start_date, end_date
--             );
--         END IF;
--     END LOOP;
-- END;
-- $$ LANGUAGE plpgsql;
-- -- Schedule automatic partition creation (runs on 1st of each month)
-- SELECT cron.schedule(
--     'create-monthly-partitions',
--     '0 0 1 * *',
--     'SELECT create_monthly_partitions()'
-- );
-- -- Schedule cleanup of old data (runs daily at 3 AM)
-- SELECT cron.schedule(
--     'cleanup-old-data',
--     '0 3 * * *',
--     'SELECT cleanup_old_data()'
-- );
-- -- Schedule vendor location heartbeat check (runs every 5 minutes)
-- SELECT cron.schedule(
--     'check-location-heartbeats',
--     '*/5 * * * *',
--     'SELECT check_vendor_location_heartbeat()'
-- );
-- ============================================================================
-- PERFORMANCE OPTIMIZATION SETTINGS
-- ============================================================================
-- Analyze tables for query optimization
ANALYZE;
-- Create statistics for multi-column queries
CREATE STATISTICS vendor_location_stats ON vendor_id,
status
FROM vendor_locations;
CREATE STATISTICS order_vendor_stats ON vendor_id,
status,
created_at
FROM orders;
CREATE STATISTICS product_vendor_stats ON vendor_id,
is_available
FROM products;
-- ============================================================================
-- ADMIN SYSTEM SETUP - ADDITIONAL HELPER FUNCTIONS
-- ============================================================================
-- ============================================================================
-- STEP 2: ADMIN RLS POLICIES FOR MISSING TABLES
-- ============================================================================
-- Note: RLS policies for these tables have been moved to the main RLS section above
-- ============================================================================
-- STEP 3: ADMIN HELPER FUNCTIONS
-- ============================================================================
-- Function to get all admin users
CREATE OR REPLACE FUNCTION get_admin_users() RETURNS TABLE (
        user_id uuid,
        email text,
        first_name varchar(100),
        last_name varchar(100),
        created_at timestamp with time zone
    ) AS $$ BEGIN RETURN QUERY
SELECT p.id,
    u.email,
    p.first_name,
    p.last_name,
    p.created_at
FROM profiles p
    JOIN auth.users u ON p.id = u.id
WHERE p.is_admin = true
ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public, auth';
-- Function to get system statistics (admin only)
CREATE OR REPLACE FUNCTION get_system_stats() RETURNS jsonb AS $$
DECLARE stats jsonb;
BEGIN -- Check if current user is admin
IF NOT is_current_user_admin() THEN RAISE EXCEPTION 'Access denied. Admin privileges required.';
END IF;
SELECT jsonb_build_object(
        'total_users',
        (
            SELECT COUNT(*)
            FROM profiles
        ),
        'total_vendors',
        (
            SELECT COUNT(*)
            FROM vendors
        ),
        'active_vendors',
        (
            SELECT COUNT(*)
            FROM vendors
            WHERE is_active = true
        ),
        'total_products',
        (
            SELECT COUNT(*)
            FROM products
        ),
        'available_products',
        (
            SELECT COUNT(*)
            FROM products
            WHERE is_available = true
        ),
        'total_orders',
        (
            SELECT COUNT(*)
            FROM orders
        ),
        'completed_orders',
        (
            SELECT COUNT(*)
            FROM orders
            WHERE status = 'completed'
        ),
        'total_revenue',
        (
            SELECT COALESCE(SUM(total_amount), 0)
            FROM orders
            WHERE status = 'completed'
        ),
        'total_reviews',
        (
            SELECT COUNT(*)
            FROM vendor_reviews
        ),
        'active_locations',
        (
            SELECT COUNT(*)
            FROM vendor_locations
            WHERE status = 'active'
        ),
        'last_updated',
        now()
    ) INTO stats;
RETURN stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public, auth';
-- Function to moderate vendor (admin only)
CREATE OR REPLACE FUNCTION moderate_vendor(
        p_vendor_id uuid,
        p_action varchar(20),
        -- 'approve', 'suspend', 'ban', 'verify'
        p_reason text DEFAULT NULL
    ) RETURNS boolean AS $$ BEGIN -- Check if current user is admin
    IF NOT is_current_user_admin() THEN RAISE EXCEPTION 'Access denied. Admin privileges required.';
END IF;
CASE
    p_action
    WHEN 'approve' THEN
    UPDATE vendors
    SET is_active = true,
        suspension_reason = NULL,
        suspended_until = NULL
    WHERE id = p_vendor_id;
WHEN 'verify' THEN
UPDATE vendors
SET is_verified = true,
    verification_date = now()
WHERE id = p_vendor_id;
WHEN 'suspend' THEN
UPDATE vendors
SET is_active = false,
    suspension_reason = p_reason,
    suspended_until = now() + interval '30 days'
WHERE id = p_vendor_id;
WHEN 'ban' THEN
UPDATE vendors
SET is_active = false,
    suspension_reason = p_reason,
    suspended_until = NULL -- Permanent ban
WHERE id = p_vendor_id;
ELSE RAISE EXCEPTION 'Invalid action. Use: approve, suspend, ban, verify';
END CASE
;
RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public, auth';
-- Function to moderate review (admin only)
CREATE OR REPLACE FUNCTION moderate_review(
        p_review_id uuid,
        p_action varchar(20),
        -- 'hide', 'show'
        p_reason varchar(100) DEFAULT NULL
    ) RETURNS boolean AS $$ BEGIN -- Check if current user is admin
    IF NOT is_current_user_admin() THEN RAISE EXCEPTION 'Access denied. Admin privileges required.';
END IF;
CASE
    p_action
    WHEN 'hide' THEN
    UPDATE vendor_reviews
    SET is_hidden = true,
        hide_reason = p_reason,
        moderated_at = now(),
        moderated_by = auth.uid()
    WHERE id = p_review_id;
WHEN 'show' THEN
UPDATE vendor_reviews
SET is_hidden = false,
    hide_reason = NULL,
    moderated_at = now(),
    moderated_by = auth.uid()
WHERE id = p_review_id;
ELSE RAISE EXCEPTION 'Invalid action. Use: hide, show';
END CASE
;
RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public, auth';
-- ============================================================================
-- STEP 4: UPDATE EXISTING POLICIES TO INCLUDE ADMIN ACCESS
-- ============================================================================
-- Update vendor policies to allow admin access
DROP POLICY IF EXISTS vendors_admin_all ON vendors;
CREATE POLICY vendors_admin_all ON vendors FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.id = auth.uid()
            AND p.is_admin = true
    )
);
-- Update order policies to allow admin access
DROP POLICY IF EXISTS orders_admin_select ON orders;
CREATE POLICY orders_admin_select ON orders FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- Update review policies to allow admin moderation
DROP POLICY IF EXISTS reviews_admin_moderate ON vendor_reviews;
CREATE POLICY reviews_admin_moderate ON vendor_reviews FOR
UPDATE USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    ) WITH CHECK (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- Update financial transaction policies for admin access
DROP POLICY IF EXISTS financial_admin_select ON financial_transactions;
CREATE POLICY financial_admin_select ON financial_transactions FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- Update analytics policies for admin access
DROP POLICY IF EXISTS vendor_analytics_admin_select ON vendor_analytics;
CREATE POLICY vendor_analytics_admin_select ON vendor_analytics FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
DROP POLICY IF EXISTS vendor_financial_analytics_admin_select ON vendor_financial_analytics;
CREATE POLICY vendor_financial_analytics_admin_select ON vendor_financial_analytics FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles p
            WHERE p.id = auth.uid()
                AND p.is_admin = true
        )
    );
-- ============================================================================
-- STEP 5: ADMIN NOTIFICATION SYSTEM
-- ============================================================================
-- Function to notify admins of important events
CREATE OR REPLACE FUNCTION notify_admins(
        p_title varchar(255),
        p_message text,
        p_data jsonb DEFAULT '{}'::jsonb,
        p_priority varchar(20) DEFAULT 'normal'
    ) RETURNS integer AS $$
DECLARE notification_count integer := 0;
admin_user RECORD;
BEGIN -- Insert notification for each admin user
FOR admin_user IN
SELECT id
FROM profiles
WHERE is_admin = true
    AND is_active = true LOOP
INSERT INTO notifications (
        user_id,
        type,
        title,
        message,
        data,
        priority,
        channels
    )
VALUES (
        admin_user.id,
        'announcement',
        p_title,
        p_message,
        p_data,
        p_priority,
        ARRAY ['push', 'email']
    );
notification_count := notification_count + 1;
END LOOP;
RETURN notification_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = 'public';
-- Trigger to notify admins of new vendor registrations
CREATE OR REPLACE FUNCTION notify_admin_new_vendor() RETURNS TRIGGER AS $$ BEGIN PERFORM notify_admins(
        'New Vendor Registration',
        'A new vendor "' || NEW.business_name || '" has registered and requires verification.',
        jsonb_build_object(
            'vendor_id',
            NEW.id,
            'vendor_name',
            NEW.business_name,
            'vendor_email',
            NEW.business_email
        ),
        'high'
    );
RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
CREATE TRIGGER notify_admin_new_vendor_trigger
AFTER
INSERT ON vendors FOR EACH ROW EXECUTE FUNCTION notify_admin_new_vendor();
-- Trigger to notify admins of reported reviews
CREATE OR REPLACE FUNCTION notify_admin_review_report() RETURNS TRIGGER AS $$ BEGIN -- Only notify if review was just hidden (reported)
    IF OLD.is_hidden = false
    AND NEW.is_hidden = true
    AND NEW.moderated_by IS NULL THEN PERFORM notify_admins(
        'Review Reported',
        'A review has been reported and requires moderation.',
        jsonb_build_object(
            'review_id',
            NEW.id,
            'vendor_id',
            NEW.vendor_id,
            'user_id',
            NEW.user_id,
            'hide_reason',
            NEW.hide_reason
        ),
        'normal'
    );
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = 'public';
CREATE TRIGGER notify_admin_review_report_trigger
AFTER
UPDATE ON vendor_reviews FOR EACH ROW EXECUTE FUNCTION notify_admin_review_report();
-- ============================================================================
-- End of schema
-- ============================================================================