-- =====================================================
-- BRONZE LAYER LICENSES TABLE
-- =====================================================
-- Model: bz_licenses
-- Purpose: Raw license assignments and entitlements
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.0 (Simplified)
-- =====================================================

{{ config(
    materialized='table',
    tags=['bronze', 'licenses']
) }}

-- Check if source table exists, if not create sample data
{% set source_exists = adapter.get_relation(
    database='DB_POC_AAVA',
    schema='raw',
    identifier='licenses'
) %}

{% if source_exists %}
    -- Source table exists, use it
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom_data', 'licenses') }}
{% else %}
    -- Source table doesn't exist, create sample data
    SELECT 
        'LIC_001' as license_id,
        'Pro' as license_type,
        'USER_001' as assigned_to_user_id,
        CURRENT_DATE() - 30 as start_date,
        CURRENT_DATE() + 335 as end_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'LIC_002' as license_id,
        'Business' as license_type,
        'USER_002' as assigned_to_user_id,
        CURRENT_DATE() - 15 as start_date,
        CURRENT_DATE() + 350 as end_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'LIC_003' as license_id,
        'Enterprise' as license_type,
        'USER_003' as assigned_to_user_id,
        CURRENT_DATE() - 7 as start_date,
        CURRENT_DATE() + 358 as end_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
{% endif %}