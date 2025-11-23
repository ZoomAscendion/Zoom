-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

CREATE TABLE IF NOT EXISTS {{ this }} (
    RECORD_ID NUMBER AUTOINCREMENT PRIMARY KEY,
    SOURCE_TABLE VARCHAR(255) NOT NULL,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9) NOT NULL,
    PROCESSED_BY VARCHAR(255) NOT NULL,
    PROCESSING_TIME NUMBER(38,3),
    STATUS VARCHAR(50) NOT NULL
)
