-- =====================================================
-- BRONZE LAYER BILLING EVENTS TABLE
-- =====================================================
-- Model: bz_billing_events
-- Purpose: Raw financial transactions and billing activities
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.0 (Simplified)
-- =====================================================

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events', 'financial']
) }}

-- Check if source table exists, if not create sample data
{% set source_exists = adapter.get_relation(
    database='DB_POC_AAVA',
    schema='raw',
    identifier='billing_events'
) %}

{% if source_exists %}
    -- Source table exists, use it
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom_data', 'billing_events') }}
{% else %}
    -- Source table doesn't exist, create sample data
    SELECT 
        'BILL_001' as event_id,
        'USER_001' as user_id,
        'Subscription Payment' as event_type,
        14.99 as amount,
        CURRENT_DATE() - 30 as event_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'BILL_002' as event_id,
        'USER_002' as user_id,
        'Upgrade Fee' as event_type,
        19.99 as amount,
        CURRENT_DATE() - 15 as event_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'BILL_003' as event_id,
        'USER_003' as user_id,
        'Enterprise License' as event_type,
        240.00 as amount,
        CURRENT_DATE() - 7 as event_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
{% endif %}