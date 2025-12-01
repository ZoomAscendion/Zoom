-- =====================================================
-- BRONZE LAYER AUDIT TABLE
-- =====================================================
-- Model: bz_data_audit
-- Purpose: Comprehensive audit trail for all Bronze layer data operations
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.0 (Simplified)
-- =====================================================

{{ config(
    materialized='table',
    tags=['bronze', 'audit', 'monitoring']
) }}

-- Create audit table with sample data for initialization
SELECT 
    1 as record_id,
    'INITIALIZATION' as source_table,
    CURRENT_TIMESTAMP() as load_timestamp,
    'DBT_SYSTEM' as processed_by,
    0.001 as processing_time,
    'SUCCESS' as status

UNION ALL

SELECT 
    2 as record_id,
    'BZ_DATA_AUDIT' as source_table,
    CURRENT_TIMESTAMP() as load_timestamp,
    'DBT_SYSTEM' as processed_by,
    0.002 as processing_time,
    'SUCCESS' as status