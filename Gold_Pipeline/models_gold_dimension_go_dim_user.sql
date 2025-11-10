-- =====================================================
-- USER DIMENSION MODEL
-- Project: Zoom Platform Analytics System - Gold Layer
-- Purpose: User profile and subscription dimension with SCD Type 2
-- Materialization: Table
-- Dependencies: source('silver', 'si_users'), source('silver', 'si_licenses')
-- =====================================================

{{ config(
    materialized='table',
    tags=['dimension', 'user', 'scd_type_2'],
    cluster_by=['plan_type', 'user_status'],
    pre_hook="{{ log('Starting GO_DIM_USER transformation', info=True) }}",
    post_hook="{{ log('Completed GO_DIM_USER transformation', info=True) }}"
) }}

-- Source data with quality filters
WITH source_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date,
        data_quality_score,
        validation_status
    FROM {{ source('silver', 'si_users') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_score_threshold') }}
),

-- Get license information for user status derivation
user_licenses AS (
    SELECT 
        assigned_to_user_id,
        license_type,
        start_date,
        end_date,
        ROW_NUMBER() OVER (
            PARTITION BY assigned_to_user_id 
            ORDER BY end_date DESC NULLS FIRST
        ) AS license_rank
    FROM {{ source('silver', 'si_licenses') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_score_threshold') }}
),

-- Get most recent license per user
latest_user_licenses AS (
    SELECT 
        assigned_to_user_id,
        license_type,
        start_date,
        end_date
    FROM user_licenses
    WHERE license_rank = 1
),

-- Transform and enrich user data
transformed_users AS (
    SELECT 
        u.user_id,
        
        -- Clean and standardize user name
        COALESCE(TRIM(INITCAP(u.user_name)), 'Unknown User') AS user_name,
        
        -- Extract email domain
        CASE 
            WHEN u.email IS NOT NULL AND POSITION('@' IN u.email) > 0 THEN
                LOWER(TRIM(SUBSTRING(u.email, POSITION('@' IN u.email) + 1)))
            ELSE 'unknown.domain'
        END AS email_domain,
        
        -- Clean and standardize company
        COALESCE(TRIM(INITCAP(u.company)), 'Unknown Company') AS company,
        
        -- Standardize plan type
        CASE 
            WHEN UPPER(TRIM(u.plan_type)) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(TRIM(u.plan_type)) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN UPPER(TRIM(u.plan_type)) IN ('BUSINESS') THEN 'Business'
            WHEN UPPER(TRIM(u.plan_type)) IN ('ENTERPRISE') THEN 'Enterprise'
            ELSE 'Other'
        END AS plan_type,
        
        -- Derive plan category
        CASE 
            WHEN UPPER(TRIM(u.plan_type)) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(TRIM(u.plan_type)) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN UPPER(TRIM(u.plan_type)) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Other'
        END AS plan_category,
        
        -- Registration date (using load_date as proxy)
        u.load_date AS registration_date,
        
        -- Derive user status based on license information
        CASE 
            WHEN l.assigned_to_user_id IS NOT NULL AND 
                 (l.end_date IS NULL OR l.end_date >= CURRENT_DATE()) THEN 'Active'
            WHEN l.assigned_to_user_id IS NOT NULL AND 
                 l.end_date < CURRENT_DATE() THEN 'Expired'
            ELSE 'Inactive'
        END AS user_status,
        
        -- Geographic region (derived from email domain - simplified)
        CASE 
            WHEN LOWER(u.email) LIKE '%.com' THEN 'North America'
            WHEN LOWER(u.email) LIKE '%.co.uk' OR LOWER(u.email) LIKE '%.eu' THEN 'Europe'
            WHEN LOWER(u.email) LIKE '%.com.au' OR LOWER(u.email) LIKE '%.co.nz' THEN 'Asia Pacific'
            WHEN LOWER(u.email) LIKE '%.ca' THEN 'Canada'
            ELSE 'Other'
        END AS geographic_region,
        
        -- Industry sector (derived from company name - simplified)
        CASE 
            WHEN LOWER(u.company) LIKE '%tech%' OR LOWER(u.company) LIKE '%software%' THEN 'Technology'
            WHEN LOWER(u.company) LIKE '%bank%' OR LOWER(u.company) LIKE '%financial%' THEN 'Financial Services'
            WHEN LOWER(u.company) LIKE '%health%' OR LOWER(u.company) LIKE '%medical%' THEN 'Healthcare'
            WHEN LOWER(u.company) LIKE '%edu%' OR LOWER(u.company) LIKE '%university%' THEN 'Education'
            WHEN LOWER(u.company) LIKE '%retail%' OR LOWER(u.company) LIKE '%store%' THEN 'Retail'
            ELSE 'Other'
        END AS industry_sector,
        
        -- User role (derived from plan type)
        CASE 
            WHEN UPPER(TRIM(u.plan_type)) IN ('ENTERPRISE', 'BUSINESS') THEN 'Admin'
            WHEN UPPER(TRIM(u.plan_type)) IN ('PRO', 'PROFESSIONAL') THEN 'Power User'
            ELSE 'Standard User'
        END AS user_role,
        
        -- Account type
        CASE 
            WHEN UPPER(TRIM(u.plan_type)) IN ('ENTERPRISE', 'BUSINESS') THEN 'Corporate'
            WHEN UPPER(TRIM(u.plan_type)) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            ELSE 'Individual'
        END AS account_type,
        
        -- Time zone (simplified based on geographic region)
        CASE 
            WHEN LOWER(u.email) LIKE '%.com' THEN 'America/New_York'
            WHEN LOWER(u.email) LIKE '%.co.uk' OR LOWER(u.email) LIKE '%.eu' THEN 'Europe/London'
            WHEN LOWER(u.email) LIKE '%.com.au' THEN 'Australia/Sydney'
            WHEN LOWER(u.email) LIKE '%.ca' THEN 'America/Toronto'
            ELSE 'UTC'
        END AS time_zone,
        
        -- Language preference (simplified)
        CASE 
            WHEN LOWER(u.email) LIKE '%.co.uk' OR LOWER(u.email) LIKE '%.com.au' THEN 'English (UK)'
            WHEN LOWER(u.email) LIKE '%.ca' THEN 'English (CA)'
            ELSE 'English (US)'
        END AS language_preference,
        
        -- SCD Type 2 fields
        u.load_date AS effective_start_date,
        
        -- Source metadata
        u.source_system,
        u.load_date,
        u.update_date
        
    FROM source_users u
    LEFT JOIN latest_user_licenses l ON u.user_id = l.assigned_to_user_id
),

-- Implement SCD Type 2 logic
scd_type_2_users AS (
    SELECT 
        user_id,
        user_name,
        email_domain,
        company,
        plan_type,
        plan_category,
        registration_date,
        user_status,
        geographic_region,
        industry_sector,
        user_role,
        account_type,
        time_zone,
        language_preference,
        effective_start_date,
        
        -- Calculate effective end date
        LEAD(effective_start_date, 1, DATE('9999-12-31')) OVER (
            PARTITION BY user_id 
            ORDER BY effective_start_date
        ) AS effective_end_date,
        
        -- Current record flag
        CASE 
            WHEN LEAD(effective_start_date, 1) OVER (
                PARTITION BY user_id 
                ORDER BY effective_start_date
            ) IS NULL THEN TRUE 
            ELSE FALSE 
        END AS is_current_record,
        
        source_system,
        load_date,
        update_date
        
    FROM transformed_users
),

-- Final dimension with surrogate key
final_user_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY user_id, effective_start_date) AS user_dim_id,
        user_name,
        email_domain,
        company,
        plan_type,
        plan_category,
        registration_date,
        user_status,
        geographic_region,
        industry_sector,
        user_role,
        account_type,
        time_zone,
        language_preference,
        effective_start_date,
        effective_end_date,
        is_current_record,
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
        
    FROM scd_type_2_users
)

SELECT * FROM final_user_dimension
ORDER BY user_dim_id

-- Add documentation
{{ doc("go_dim_user", "
User Dimension Table with SCD Type 2

This dimension table contains user profile and subscription information with
Slowly Changing Dimension Type 2 implementation to track historical changes.

Key Features:
- SCD Type 2 for tracking user attribute changes over time
- Email domain extraction for organizational analysis
- Plan type standardization and categorization
- Geographic region derivation from email domains
- Industry sector classification from company names
- User status derivation from license information
- Comprehensive data quality filtering

Transformations Applied:
- Data cleansing and standardization
- Business rule implementations
- Derived attributes for analytics
- Historical change tracking

Usage:
- Join with fact tables using user_dim_id
- Filter on is_current_record for current state analysis
- Use effective dates for point-in-time analysis
- Group by plan_category, geographic_region for segmentation
") }}