_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Updated comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake with business key relationships
## *Version*: 2
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Layer Pipeline - Version 2

## Description

This document contains updated comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer Pipeline that transforms raw data into bronze layer tables in Snowflake. The tests have been updated to reflect the actual Bronze layer implementation without primary key ID fields, focusing on business key relationships and 1-1 mapping validation.

## Key Updates in Version 2

### Changes Applied:
1. **Removed Primary Key Dependencies**: Updated all test cases to exclude non-existent ID fields (EVENT_ID, USAGE_ID, LICENSE_ID, etc.)
2. **Data Type Alignment**: Aligned test validations with actual Raw Schema data types
3. **Business Key Relationships**: Added tests for business key relationships instead of surrogate keys
4. **1-1 Mapping Validation**: Added specific tests to validate 1-1 mapping between RAW and BRONZE layers
5. **Enhanced Audit Log Testing**: Comprehensive audit log validation tests
6. **Field Mapping Accuracy**: Added field-level mapping validation tests
7. **Updated Schema Tests**: Modified schema.yml to reflect actual Bronze table structure
8. **Performance Tests**: Updated for business key lookups instead of ID-based queries

## Test Case Overview

The bronze layer pipeline consists of 9 models:
- `bz_audit_log` - Audit logging for data processing activities (with AUTOINCREMENT record_id)
- `bz_billing_events` - Billing and payment event data (no EVENT_ID)
- `bz_feature_usage` - Feature usage tracking data (no USAGE_ID)
- `bz_licenses` - License management data (no LICENSE_ID)
- `bz_meetings` - Meeting data (no MEETING_ID)
- `bz_participants` - Meeting participant data (no PARTICIPANT_ID)
- `bz_support_tickets` - Support ticket data (no TICKET_ID)
- `bz_users` - User account data (no USER_ID)
- `bz_webinars` - Webinar data (no WEBINAR_ID)

## Updated Test Case List

| Test Case ID | Test Case Description | Expected Outcome | Model |
|--------------|----------------------|------------------|-------|
| TC_BZ_001 | Validate audit log initialization and AUTOINCREMENT | Audit log table created with auto-incrementing record_id | bz_audit_log |
| TC_BZ_002 | Test billing events 1-1 mapping without EVENT_ID | All billing events transformed maintaining row count parity | bz_billing_events |
| TC_BZ_003 | Validate feature usage business key relationships | Feature usage data linked via meeting business keys | bz_feature_usage |
| TC_BZ_004 | Test license data transformation with composite keys | License data transformed using license_type + assigned_to_user_id | bz_licenses |
| TC_BZ_005 | Validate meeting data processing with business keys | Meeting data processed using host_id + meeting_topic + start_time | bz_meetings |
| TC_BZ_006 | Test participant relationships via business keys | Participant data maintains relationships via meeting business keys | bz_participants |
| TC_BZ_007 | Validate support ticket processing without TICKET_ID | Support tickets processed using user_id + ticket_type + open_date | bz_support_tickets |
| TC_BZ_008 | Test user data uniqueness via email | User data maintains email uniqueness as business key | bz_users |
| TC_BZ_009 | Validate webinar data with composite business keys | Webinar data processed using host_id + webinar_topic + start_time | bz_webinars |
| TC_BZ_010 | Test null value handling in 1-1 mapping | Null values handled consistently between RAW and BRONZE | All models |
| TC_BZ_011 | Validate precise data type conversions | Data types match Raw Schema specifications (VARCHAR(16777216), NUMBER(10,2), TIMESTAMP_NTZ(9)) | All models |
| TC_BZ_012 | Test comprehensive audit trail functionality | Audit records created for each model execution with processing metrics | All models |
| TC_BZ_013 | Validate timestamp consistency in 1-1 mapping | Load and update timestamps preserved from RAW to BRONZE | All models |
| TC_BZ_014 | Test edge case - empty source tables without IDs | Models handle empty source tables gracefully without ID dependencies | All models |
| TC_BZ_015 | Validate business key referential integrity | Foreign key relationships maintained using business keys | Related models |
| TC_BZ_016 | **NEW**: Test audit log model functionality | Audit log captures all processing activities with AUTOINCREMENT | bz_audit_log |
| TC_BZ_017 | **NEW**: Field-level mapping accuracy validation | All fields mapped 1-1 from RAW to BRONZE with exact value preservation | All models |
| TC_BZ_018 | **NEW**: Data lineage validation tests | Data lineage tracked correctly through load_timestamp, update_timestamp, source_system | All models |
| TC_BZ_019 | **NEW**: Metadata preservation tests | Metadata fields (load_timestamp, update_timestamp, source_system) preserved accurately | All models |
| TC_BZ_020 | **NEW**: Missing business key handling | Test handling of missing business keys without surrogate key fallback | All models |
| TC_BZ_021 | **NEW**: Duplicate record handling via business keys | Test duplicate record detection using composite business keys | All models |
| TC_BZ_022 | **NEW**: Business key referential integrity | Test referential integrity using business key combinations | Related models |

## Updated dbt Test Scripts

### Updated YAML-based Schema Tests

```yaml
# tests/schema_tests_v2.yml
version: 2

models:
  # Updated Audit Log Tests - Now includes AUTOINCREMENT validation
  - name: bz_audit_log
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
    columns:
      - name: record_id
        tests:
          - unique
          - not_null
          - dbt_expectations.expect_column_values_to_be_increasing  # AUTOINCREMENT validation
      - name: source_table
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - accepted_values:
              values: ['BZ_BILLING_EVENTS', 'BZ_FEATURE_USAGE', 'BZ_LICENSES', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 'BZ_SUPPORT_TICKETS', 'BZ_USERS', 'BZ_WEBINARS']
      - name: load_timestamp
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz
      - name: processed_by
        tests:
          - not_null
          - accepted_values:
              values: ['DBT_BRONZE_PIPELINE']
      - name: processing_time
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 3600  # Max 1 hour processing time
      - name: status
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'INITIALIZED']

  # Updated Billing Events Tests - Removed EVENT_ID dependencies
  - name: bz_billing_events
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
      # 1-1 Mapping validation test
      - dbt_utils.equal_rowcount:
          compare_model: source('raw_zoom', 'BILLING_EVENTS')
    columns:
      - name: user_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: string
      - name: event_type
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - accepted_values:
              values: ['PAYMENT', 'REFUND', 'SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'CHARGEBACK', 'CREDIT']
      - name: amount
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number  # NUMBER(10,2) as per Raw Schema
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 99999999.99  # Max for NUMBER(10,2)
      - name: event_date
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date
      - name: load_timestamp
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz  # TIMESTAMP_NTZ(9) precision
      - name: update_timestamp
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz
      - name: source_system
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: string  # VARCHAR(16777216)

  # Updated Feature Usage Tests - Removed USAGE_ID, focus on business keys
  - name: bz_feature_usage
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_utils.equal_rowcount:
          compare_model: source('raw_zoom', 'FEATURE_USAGE')
    columns:
      - name: meeting_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: string
      - name: feature_name
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - accepted_values:
              values: ['SCREEN_SHARE', 'RECORDING', 'CHAT', 'BREAKOUT_ROOMS', 'WHITEBOARD', 'POLLING', 'ANNOTATION', 'VIRTUAL_BACKGROUND']
      - name: usage_count
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number  # NUMBER(38,0)
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 999999999999999999999999999999999999999  # Max for NUMBER(38,0)
      - name: usage_date
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date

  # Updated Licenses Tests - Removed LICENSE_ID, use composite business key
  - name: bz_licenses
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_utils.equal_rowcount:
          compare_model: source('raw_zoom', 'LICENSES')
      # Business key uniqueness test
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - license_type
            - assigned_to_user_id
            - start_date
    columns:
      - name: license_type
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'EDUCATION', 'GOVERNMENT']
      - name: assigned_to_user_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: start_date
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date
      - name: end_date
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date

  # Updated Meetings Tests - Removed MEETING_ID, use composite business key
  - name: bz_meetings
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_utils.equal_rowcount:
          compare_model: source('raw_zoom', 'MEETINGS')
      # Business key uniqueness test
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - host_id
            - meeting_topic
            - start_time
    columns:
      - name: host_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: string
      - name: meeting_topic
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: string  # VARCHAR(16777216)
      - name: start_time
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz  # TIMESTAMP_NTZ(9)
      - name: end_time
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz
      - name: duration_minutes
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number  # NUMBER(38,0)
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10080  # 7 days max

  # Updated Participants Tests - Removed PARTICIPANT_ID, use composite business key
  - name: bz_participants
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_utils.equal_rowcount:
          compare_model: source('raw_zoom', 'PARTICIPANTS')
      # Business key uniqueness test
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - meeting_id
            - user_id
            - join_time
    columns:
      - name: meeting_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: user_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: join_time
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz
      - name: leave_time
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz

  # Updated Support Tickets Tests - Removed TICKET_ID, use composite business key
  - name: bz_support_tickets
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_utils.equal_rowcount:
          compare_model: source('raw_zoom', 'SUPPORT_TICKETS')
      # Business key uniqueness test
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
            - ticket_type
            - open_date
    columns:
      - name: user_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: ticket_type
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - accepted_values:
              values: ['TECHNICAL', 'BILLING', 'FEATURE_REQUEST', 'BUG_REPORT', 'ACCOUNT_ISSUE', 'INTEGRATION']
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'ESCALATED', 'PENDING']
      - name: open_date
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date

  # Updated Users Tests - Removed USER_ID, use email as business key
  - name: bz_users
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_utils.equal_rowcount:
          compare_model: source('raw_zoom', 'USERS')
    columns:
      - name: user_name
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: string  # VARCHAR(16777216)
      - name: email
        tests:
          - not_null
          - unique  # Business key
          - dbt_utils.not_empty_string
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: string
      - name: company
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: string
      - name: plan_type
        tests:
          - not_null
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'EDUCATION', 'GOVERNMENT']

  # Updated Webinars Tests - Removed WEBINAR_ID, use composite business key
  - name: bz_webinars
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_utils.equal_rowcount:
          compare_model: source('raw_zoom', 'WEBINARS')
      # Business key uniqueness test
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - host_id
            - webinar_topic
            - start_time
    columns:
      - name: host_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: webinar_topic
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: string
      - name: start_time
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz
      - name: end_time
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz
      - name: registrants
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number  # NUMBER(38,0)
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000  # Reasonable max registrants
```

### Updated Custom SQL-based dbt Tests

```sql
-- tests/test_audit_log_autoincrement.sql
-- NEW: Test to ensure audit log record_id is auto-incrementing
SELECT 
    record_id,
    LAG(record_id) OVER (ORDER BY record_id) as prev_record_id
FROM {{ ref('bz_audit_log') }}
WHERE record_id <= LAG(record_id) OVER (ORDER BY record_id)
   OR record_id - LAG(record_id) OVER (ORDER BY record_id) != 1
```

```sql
-- tests/test_one_to_one_mapping_billing_events.sql
-- NEW: Test to validate 1-1 mapping between RAW and BRONZE billing events
WITH raw_count AS (
    SELECT COUNT(*) as raw_row_count
    FROM {{ source('raw_zoom', 'BILLING_EVENTS') }}
    WHERE USER_ID IS NOT NULL 
      AND EVENT_TYPE IS NOT NULL 
      AND AMOUNT IS NOT NULL
),
bronze_count AS (
    SELECT COUNT(*) as bronze_row_count
    FROM {{ ref('bz_billing_events') }}
)
SELECT 
    raw_row_count,
    bronze_row_count,
    ABS(raw_row_count - bronze_row_count) as row_count_diff
FROM raw_count
CROSS JOIN bronze_count
WHERE raw_row_count != bronze_row_count
```

```sql
-- tests/test_field_mapping_accuracy.sql
-- NEW: Test to validate field-level mapping accuracy
WITH raw_sample AS (
    SELECT 
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_zoom', 'BILLING_EVENTS') }}
    LIMIT 1000
),
bronze_sample AS (
    SELECT 
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ ref('bz_billing_events') }}
    LIMIT 1000
)
SELECT 
    r.USER_ID,
    r.EVENT_TYPE,
    r.AMOUNT,
    r.EVENT_DATE
FROM raw_sample r
LEFT JOIN bronze_sample b ON (
    r.USER_ID = b.user_id
    AND r.EVENT_TYPE = b.event_type
    AND r.AMOUNT = b.amount
    AND r.EVENT_DATE = b.event_date
    AND r.LOAD_TIMESTAMP = b.load_timestamp
    AND r.UPDATE_TIMESTAMP = b.update_timestamp
    AND r.SOURCE_SYSTEM = b.source_system
)
WHERE b.user_id IS NULL
```

```sql
-- tests/test_business_key_relationships.sql
-- NEW: Test business key relationships without surrogate keys
WITH participant_meetings AS (
    SELECT DISTINCT p.meeting_id
    FROM {{ ref('bz_participants') }} p
),
meeting_business_keys AS (
    SELECT DISTINCT 
        CONCAT(host_id, '|', meeting_topic, '|', start_time) as meeting_business_key
    FROM {{ ref('bz_meetings') }} m
)
SELECT 
    p.meeting_id
FROM participant_meetings p
LEFT JOIN meeting_business_keys m ON (
    p.meeting_id = SPLIT_PART(m.meeting_business_key, '|', 1)  -- Simplified join logic
)
WHERE m.meeting_business_key IS NULL
```

```sql
-- tests/test_data_type_precision.sql
-- NEW: Test data type precision alignment with Raw Schema
SELECT 
    'bz_billing_events' as table_name,
    'amount' as column_name,
    amount
FROM {{ ref('bz_billing_events') }}
WHERE amount::STRING NOT REGEXP '^[0-9]{1,8}\.[0-9]{2}$'  -- NUMBER(10,2) validation
   OR LENGTH(SPLIT_PART(amount::STRING, '.', 1)) > 8
   OR LENGTH(SPLIT_PART(amount::STRING, '.', 2)) != 2

UNION ALL

SELECT 
    'bz_users' as table_name,
    'email' as column_name,
    email
FROM {{ ref('bz_users') }}
WHERE LENGTH(email) > 16777216  -- VARCHAR(16777216) validation
```

```sql
-- tests/test_metadata_preservation.sql
-- NEW: Test metadata field preservation from RAW to BRONZE
WITH raw_metadata AS (
    SELECT 
        COUNT(*) as raw_count,
        COUNT(LOAD_TIMESTAMP) as raw_load_ts_count,
        COUNT(UPDATE_TIMESTAMP) as raw_update_ts_count,
        COUNT(SOURCE_SYSTEM) as raw_source_sys_count
    FROM {{ source('raw_zoom', 'BILLING_EVENTS') }}
),
bronze_metadata AS (
    SELECT 
        COUNT(*) as bronze_count,
        COUNT(load_timestamp) as bronze_load_ts_count,
        COUNT(update_timestamp) as bronze_update_ts_count,
        COUNT(source_system) as bronze_source_sys_count
    FROM {{ ref('bz_billing_events') }}
)
SELECT 
    'load_timestamp' as metadata_field,
    raw_load_ts_count,
    bronze_load_ts_count
FROM raw_metadata
CROSS JOIN bronze_metadata
WHERE raw_load_ts_count != bronze_load_ts_count

UNION ALL

SELECT 
    'update_timestamp' as metadata_field,
    raw_update_ts_count,
    bronze_update_ts_count
FROM raw_metadata
CROSS JOIN bronze_metadata
WHERE raw_update_ts_count != bronze_update_ts_count

UNION ALL

SELECT 
    'source_system' as metadata_field,
    raw_source_sys_count,
    bronze_source_sys_count
FROM raw_metadata
CROSS JOIN bronze_metadata
WHERE raw_source_sys_count != bronze_source_sys_count
```

```sql
-- tests/test_duplicate_business_keys.sql
-- NEW: Test duplicate record handling using composite business keys
SELECT 
    license_type,
    assigned_to_user_id,
    start_date,
    COUNT(*) as duplicate_count
FROM {{ ref('bz_licenses') }}
GROUP BY license_type, assigned_to_user_id, start_date
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    host_id as license_type,  -- Reusing column names for UNION
    meeting_topic as assigned_to_user_id,
    start_time::DATE as start_date,
    COUNT(*) as duplicate_count
FROM {{ ref('bz_meetings') }}
GROUP BY host_id, meeting_topic, start_time::DATE
HAVING COUNT(*) > 1
```

```sql
-- tests/test_timestamp_precision.sql
-- NEW: Test TIMESTAMP_NTZ(9) precision
SELECT 
    'bz_meetings' as table_name,
    start_time,
    end_time
FROM {{ ref('bz_meetings') }}
WHERE start_time::STRING NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{9}$'
   OR end_time::STRING NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{9}$'
```

### Updated Parameterized Tests

```sql
-- macros/test_business_key_uniqueness.sql
{% macro test_business_key_uniqueness(model, business_key_columns) %}

SELECT 
    {% for column in business_key_columns %}
    {{ column }}{{ ',' if not loop.last else '' }}
    {% endfor %},
    COUNT(*) as duplicate_count
FROM {{ model }}
GROUP BY 
    {% for column in business_key_columns %}
    {{ column }}{{ ',' if not loop.last else '' }}
    {% endfor %}
HAVING COUNT(*) > 1

{% endmacro %}
```

```sql
-- macros/test_one_to_one_mapping.sql
{% macro test_one_to_one_mapping(bronze_model, raw_source, filter_conditions='1=1') %}

WITH raw_count AS (
    SELECT COUNT(*) as raw_row_count
    FROM {{ raw_source }}
    WHERE {{ filter_conditions }}
),
bronze_count AS (
    SELECT COUNT(*) as bronze_row_count
    FROM {{ bronze_model }}
)
SELECT 
    raw_row_count,
    bronze_row_count,
    ABS(raw_row_count - bronze_row_count) as row_count_diff
FROM raw_count
CROSS JOIN bronze_count
WHERE raw_row_count != bronze_row_count

{% endmacro %}
```

```sql
-- macros/test_data_type_alignment.sql
{% macro test_data_type_alignment(model, column_name, expected_type, precision=null, scale=null) %}

SELECT 
    '{{ model.name }}' as table_name,
    '{{ column_name }}' as column_name,
    {{ column_name }}
FROM {{ model }}
WHERE 
    {% if expected_type == 'NUMBER' and precision and scale %}
        {{ column_name }}::STRING NOT REGEXP '^[0-9]{1,{{ precision - scale }}}\.[0-9]{{ '{' }}{{ scale }}{{ '}' }}$'
    {% elif expected_type == 'VARCHAR' and precision %}
        LENGTH({{ column_name }}) > {{ precision }}
    {% elif expected_type == 'TIMESTAMP_NTZ' %}
        {{ column_name }}::STRING NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{9}$'
    {% else %}
        FALSE  -- Default case
    {% endif %}

{% endmacro %}
```

## Updated Test Execution Strategy

### 1. Pre-execution Tests
- Validate source data availability without ID field dependencies
- Check schema compatibility for business key structures
- Verify connection to Snowflake with proper data type handling

### 2. Transformation Tests
- **1-1 Mapping Validation**: Ensure exact row count parity between RAW and BRONZE
- **Data Type Precision**: Validate NUMBER(10,2), VARCHAR(16777216), TIMESTAMP_NTZ(9)
- **Business Key Integrity**: Test composite business key uniqueness
- **Metadata Preservation**: Verify load_timestamp, update_timestamp, source_system preservation

### 3. Post-execution Tests
- **Business Key Relationship Validation**: Test referential integrity using business keys
- **Audit Trail Verification**: Validate AUTOINCREMENT functionality in audit log
- **Data Quality Checks**: Comprehensive validation without ID field dependencies

### 4. Performance Tests
- **Business Key Lookup Performance**: Test query performance on composite keys
- **Index Strategy Validation**: Verify optimal indexing for business key queries
- **Scalability Testing**: Test performance with large datasets using business keys

## Updated Test Data Scenarios

### Happy Path Scenarios
- Valid data with all required business key fields
- Proper data types matching Raw Schema specifications
- Consistent timestamps with nanosecond precision
- Valid business key relationships across tables

### Edge Case Scenarios
- Null values in optional fields (not business keys)
- Boundary value testing for NUMBER(10,2) precision
- Empty string handling in VARCHAR(16777216) fields
- Maximum timestamp precision validation

### Exception Scenarios
- Missing business key components
- Duplicate business key combinations
- Business key referential integrity violations
- Data type precision mismatches

## Business Key Relationship Mapping

### Primary Business Key Relationships:
1. **Users**: `email` (unique business key)
2. **Meetings**: `host_id + meeting_topic + start_time` (composite business key)
3. **Participants**: `meeting_id + user_id + join_time` (composite business key)
4. **Licenses**: `license_type + assigned_to_user_id + start_date` (composite business key)
5. **Billing Events**: `user_id + event_type + event_date + amount` (composite business key)
6. **Feature Usage**: `meeting_id + feature_name + usage_date` (composite business key)
7. **Support Tickets**: `user_id + ticket_type + open_date` (composite business key)
8. **Webinars**: `host_id + webinar_topic + start_time` (composite business key)
9. **Audit Log**: `record_id` (AUTOINCREMENT primary key)

## Monitoring and Alerting Updates

### dbt Test Results Tracking
- Monitor 1-1 mapping test pass/fail rates
- Track business key relationship test execution times
- Alert on critical business key integrity failures
- Generate test coverage reports for business key validations

### Snowflake Audit Schema Integration
- Log test results with business key context to audit tables
- Track data lineage using business key relationships
- Monitor data quality trends for composite key structures
- Generate compliance reports for 1-1 mapping validation

## Maintenance Guidelines Updates

### Regular Test Updates
- Review and update business key definitions quarterly
- Add new tests for new business rule implementations
- Remove tests dependent on non-existent ID fields
- Update test thresholds based on business key data patterns

### Performance Optimization
- Optimize test queries for business key lookups on large datasets
- Use sampling strategies for performance-intensive business key tests
- Implement incremental testing for composite key validations
- Monitor test execution resource usage for complex business key joins

## Conclusion

This updated comprehensive test suite (Version 2) ensures the reliability, accuracy, and performance of the Zoom Bronze Layer Pipeline in Snowflake with proper business key relationship handling and 1-1 mapping validation. The removal of non-existent ID field dependencies and addition of business key-focused tests provides accurate coverage of the actual Bronze layer implementation. The enhanced data type precision validation and metadata preservation tests ensure compliance with the Raw Schema specifications and 1-1 mapping requirements. Regular execution and monitoring of these updated tests will maintain high data quality standards while accurately reflecting the Bronze layer architecture.