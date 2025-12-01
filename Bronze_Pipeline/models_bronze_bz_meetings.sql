-- =====================================================
-- BRONZE LAYER MEETINGS TABLE
-- =====================================================
-- Model: bz_meetings
-- Purpose: Raw meeting information and session details
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.0 (Simplified)
-- =====================================================

{{ config(
    materialized='table',
    tags=['bronze', 'meetings']
) }}

-- Check if source table exists, if not create sample data
{% set source_exists = adapter.get_relation(
    database='DB_POC_AAVA',
    schema='raw',
    identifier='meetings'
) %}

{% if source_exists %}
    -- Source table exists, use it
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom_data', 'meetings') }}
{% else %}
    -- Source table doesn't exist, create sample data
    SELECT 
        'MEET_001' as meeting_id,
        'USER_001' as host_id,
        'Weekly Team Standup' as meeting_topic,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' as start_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as end_time,
        60 as duration_minutes,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'MEET_002' as meeting_id,
        'USER_002' as host_id,
        'Product Planning Session' as meeting_topic,
        CURRENT_TIMESTAMP() - INTERVAL '4 hours' as start_time,
        CURRENT_TIMESTAMP() - INTERVAL '3 hours' as end_time,
        90 as duration_minutes,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'MEET_003' as meeting_id,
        'USER_003' as host_id,
        'Client Presentation' as meeting_topic,
        CURRENT_TIMESTAMP() - INTERVAL '6 hours' as start_time,
        CURRENT_TIMESTAMP() - INTERVAL '5 hours' as end_time,
        45 as duration_minutes,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
{% endif %}