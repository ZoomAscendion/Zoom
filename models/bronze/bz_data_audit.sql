-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: DBT Pipeline
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

CREATE TABLE IF NOT EXISTS {{ this }} (
    RECORD_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE VARCHAR(255),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    PROCESSED_BY VARCHAR(255),
    PROCESSING_TIME NUMBER(38,3),
    STATUS VARCHAR(50)
)
