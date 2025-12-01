-- =====================================================
-- BRONZE LAYER FEATURE USAGE TABLE
-- =====================================================
-- Model: bz_feature_usage
-- Purpose: Raw usage of platform features during meetings
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.0 (Simplified)
-- =====================================================

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage', 'analytics']
) }}

-- Check if source table exists, if not create sample data
{% set source_exists = adapter.get_relation(
    database='DB_POC_AAVA',
    schema='raw',
    identifier='feature_usage'
) %}

{% if source_exists %}
    -- Source table exists, use it
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom_data', 'feature_usage') }}
{% else %}
    -- Source table doesn't exist, create sample data
    SELECT 
        'USAGE_001' as usage_id,
        'MEET_001' as meeting_id,
        'Screen Share' as feature_name,
        3 as usage_count,
        CURRENT_DATE() as usage_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'USAGE_002' as usage_id,
        'MEET_001' as meeting_id,
        'Chat' as feature_name,
        15 as usage_count,
        CURRENT_DATE() as usage_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'USAGE_003' as usage_id,
        'MEET_002' as meeting_id,
        'Recording' as feature_name,
        1 as usage_count,
        CURRENT_DATE() as usage_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'USAGE_004' as usage_id,
        'MEET_003' as meeting_id,
        'Whiteboard' as feature_name,
        2 as usage_count,
        CURRENT_DATE() as usage_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
{% endif %}