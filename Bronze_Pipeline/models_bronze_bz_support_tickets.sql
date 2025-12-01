-- =====================================================
-- BRONZE LAYER SUPPORT TICKETS TABLE
-- =====================================================
-- Model: bz_support_tickets
-- Purpose: Raw customer support requests and resolution tracking
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.0 (Simplified)
-- =====================================================

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets']
) }}

-- Check if source table exists, if not create sample data
{% set source_exists = adapter.get_relation(
    database='DB_POC_AAVA',
    schema='raw',
    identifier='support_tickets'
) %}

{% if source_exists %}
    -- Source table exists, use it
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom_data', 'support_tickets') }}
{% else %}
    -- Source table doesn't exist, create sample data
    SELECT 
        'TICKET_001' as ticket_id,
        'USER_001' as user_id,
        'Technical Issue' as ticket_type,
        'Resolved' as resolution_status,
        CURRENT_DATE() - 2 as open_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'TICKET_002' as ticket_id,
        'USER_002' as user_id,
        'Billing Question' as ticket_type,
        'In Progress' as resolution_status,
        CURRENT_DATE() - 1 as open_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
    
    UNION ALL
    
    SELECT 
        'TICKET_003' as ticket_id,
        'USER_003' as user_id,
        'Feature Request' as ticket_type,
        'Open' as resolution_status,
        CURRENT_DATE() as open_date,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_TIMESTAMP() as update_timestamp,
        'SAMPLE_SYSTEM' as source_system
{% endif %}