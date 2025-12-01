-- =====================================================
-- BRONZE LAYER USERS TABLE
-- =====================================================
-- Model: bz_users
-- Purpose: Raw user profile and subscription information
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.0 (Simplified)
-- =====================================================

{{ config(
    materialized='table',
    tags=['bronze', 'users', 'pii']
) }}

-- Check if source table exists, if not create sample data
{% set source_exists = adapter.get_relation(
    database='DB_POC_AAVA',
    schema='raw',
    identifier='users'
) %}

{% if source_exists %}
    -- Source table exists, use it
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom_data', 'users') }}
{% else %}
    -- Source table doesn't exist, create sample data
    SELECT 
        'USER_001' as user_id,
        'John Doe' as user_name,
        'john.doe@example.com' as email,
        'Example Corp' as company,
        'Pro' as plan_type,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'USER_002' as user_id,
        'Jane Smith' as user_name,
        'jane.smith@example.com' as email,
        'Sample Inc' as company,
        'Business' as plan_type,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'USER_003' as user_id,
        'Bob Johnson' as user_name,
        'bob.johnson@example.com' as email,
        'Test LLC' as company,
        'Enterprise' as plan_type,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
{% endif %}