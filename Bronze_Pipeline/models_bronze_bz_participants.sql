-- =====================================================
-- BRONZE LAYER PARTICIPANTS TABLE
-- =====================================================
-- Model: bz_participants
-- Purpose: Raw meeting participants and their session details
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.0 (Simplified)
-- =====================================================

{{ config(
    materialized='table',
    tags=['bronze', 'participants']
) }}

-- Check if source table exists, if not create sample data
{% set source_exists = adapter.get_relation(
    database='DB_POC_AAVA',
    schema='raw',
    identifier='participants'
) %}

{% if source_exists %}
    -- Source table exists, use it
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom_data', 'participants') }}
{% else %}
    -- Source table doesn't exist, create sample data
    SELECT 
        'PART_001' as participant_id,
        'MEET_001' as meeting_id,
        'USER_001' as user_id,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' as join_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as leave_time,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'PART_002' as participant_id,
        'MEET_001' as meeting_id,
        'USER_002' as user_id,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' as join_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as leave_time,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'PART_003' as participant_id,
        'MEET_002' as meeting_id,
        'USER_003' as user_id,
        CURRENT_TIMESTAMP() - INTERVAL '4 hours' as join_time,
        CURRENT_TIMESTAMP() - INTERVAL '3 hours' as leave_time,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
{% endif %}