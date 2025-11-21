_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze layer pipeline running in Snowflake. The test suite covers all 8 Bronze layer models including data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Coverage Overview

### Models Under Test
1. **bz_data_audit** - Audit trail table
2. **bz_users** - User profile and subscription data
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participant tracking
5. **bz_feature_usage** - Platform feature usage analytics
6. **bz_support_tickets** - Customer support ticket management
7. **bz_billing_events** - Financial transactions and billing
8. **bz_licenses** - License assignments and entitlements

---

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_AUDIT_001 | Verify audit table structure initialization | Table created with correct schema, no initial data |
| BZ_AUDIT_002 | Test audit record insertion capability | Records can be inserted with all required fields |
| BZ_AUDIT_003 | Validate RECORD_ID auto-increment functionality | Sequential ID generation works correctly |
| BZ_AUDIT_004 | Test audit timestamp accuracy | LOAD_TIMESTAMP reflects actual processing time |
| BZ_AUDIT_005 | Verify audit status field validation | STATUS field accepts valid values (INITIALIZED, SUCCESS, FAILED, WARNING) |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_USERS_001 | Test primary key uniqueness (USER_ID) | No duplicate USER_ID values in output |
| BZ_USERS_002 | Test email uniqueness constraint | No duplicate EMAIL values in output |
| BZ_USERS_003 | Verify NULL primary key filtering | Records with NULL USER_ID are excluded |
| BZ_USERS_004 | Verify NULL email filtering | Records with NULL EMAIL are excluded |
| BZ_USERS_005 | Test default value generation for USER_NAME | NULL USER_NAME gets default value (user_id + '_user') |
| BZ_USERS_006 | Test default email generation | NULL EMAIL gets default format (user_id + '@gmail.com') |
| BZ_USERS_007 | Test deduplication logic | Most recent record per USER_ID is retained |
| BZ_USERS_008 | Verify timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP use current DBT run time |
| BZ_USERS_009 | Test PLAN_TYPE domain validation | Only valid plan types (Basic, Pro, Business, Enterprise) accepted |
| BZ_USERS_010 | Test source system preservation | SOURCE_SYSTEM field maintained from raw data |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_MEETINGS_001 | Test primary key uniqueness (MEETING_ID) | No duplicate MEETING_ID values in output |
| BZ_MEETINGS_002 | Verify NULL primary key filtering | Records with NULL MEETING_ID are excluded |
| BZ_MEETINGS_003 | Verify NULL host_id filtering | Records with NULL HOST_ID are excluded |
| BZ_MEETINGS_004 | Verify NULL start_time filtering | Records with NULL START_TIME are excluded |
| BZ_MEETINGS_005 | Test END_TIME data type conversion | VARCHAR END_TIME converted to TIMESTAMP_NTZ or NULL |
| BZ_MEETINGS_006 | Test DURATION_MINUTES data type conversion | VARCHAR DURATION_MINUTES converted to NUMBER or NULL |
| BZ_MEETINGS_007 | Test deduplication logic | Most recent record per MEETING_ID is retained |
| BZ_MEETINGS_008 | Verify timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP use current DBT run time |
| BZ_MEETINGS_009 | Test invalid END_TIME handling | Invalid END_TIME values converted to NULL |
| BZ_MEETINGS_010 | Test invalid DURATION_MINUTES handling | Invalid DURATION_MINUTES values converted to NULL |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_PARTICIPANTS_001 | Test primary key uniqueness (PARTICIPANT_ID) | No duplicate PARTICIPANT_ID values in output |
| BZ_PARTICIPANTS_002 | Verify NULL primary key filtering | Records with NULL PARTICIPANT_ID are excluded |
| BZ_PARTICIPANTS_003 | Verify NULL meeting_id filtering | Records with NULL MEETING_ID are excluded |
| BZ_PARTICIPANTS_004 | Verify NULL user_id filtering | Records with NULL USER_ID are excluded |
| BZ_PARTICIPANTS_005 | Test JOIN_TIME data type conversion | VARCHAR JOIN_TIME converted to TIMESTAMP_NTZ or NULL |
| BZ_PARTICIPANTS_006 | Test deduplication logic | Most recent record per PARTICIPANT_ID is retained |
| BZ_PARTICIPANTS_007 | Verify timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP use current DBT run time |
| BZ_PARTICIPANTS_008 | Test invalid JOIN_TIME handling | Invalid JOIN_TIME values converted to NULL |
| BZ_PARTICIPANTS_009 | Test LEAVE_TIME preservation | LEAVE_TIME values maintained from source |
| BZ_PARTICIPANTS_010 | Test referential data consistency | MEETING_ID and USER_ID reference valid entities |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_FEATURE_USAGE_001 | Test primary key uniqueness (USAGE_ID) | No duplicate USAGE_ID values in output |
| BZ_FEATURE_USAGE_002 | Verify NULL primary key filtering | Records with NULL USAGE_ID are excluded |
| BZ_FEATURE_USAGE_003 | Verify NULL meeting_id filtering | Records with NULL MEETING_ID are excluded |
| BZ_FEATURE_USAGE_004 | Verify NULL feature_name filtering | Records with NULL FEATURE_NAME are excluded |
| BZ_FEATURE_USAGE_005 | Verify NULL usage_count filtering | Records with NULL USAGE_COUNT are excluded |
| BZ_FEATURE_USAGE_006 | Verify NULL usage_date filtering | Records with NULL USAGE_DATE are excluded |
| BZ_FEATURE_USAGE_007 | Test deduplication logic | Most recent record per USAGE_ID is retained |
| BZ_FEATURE_USAGE_008 | Verify timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP use current DBT run time |
| BZ_FEATURE_USAGE_009 | Test FEATURE_NAME domain validation | Valid feature names (screen_share, recording, chat, breakout_rooms, whiteboard) |
| BZ_FEATURE_USAGE_010 | Test USAGE_COUNT non-negative validation | USAGE_COUNT values are >= 0 |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_SUPPORT_TICKETS_001 | Test primary key uniqueness (TICKET_ID) | No duplicate TICKET_ID values in output |
| BZ_SUPPORT_TICKETS_002 | Verify NULL primary key filtering | Records with NULL TICKET_ID are excluded |
| BZ_SUPPORT_TICKETS_003 | Verify NULL user_id filtering | Records with NULL USER_ID are excluded |
| BZ_SUPPORT_TICKETS_004 | Verify NULL ticket_type filtering | Records with NULL TICKET_TYPE are excluded |
| BZ_SUPPORT_TICKETS_005 | Verify NULL resolution_status filtering | Records with NULL RESOLUTION_STATUS are excluded |
| BZ_SUPPORT_TICKETS_006 | Verify NULL open_date filtering | Records with NULL OPEN_DATE are excluded |
| BZ_SUPPORT_TICKETS_007 | Test deduplication logic | Most recent record per TICKET_ID is retained |
| BZ_SUPPORT_TICKETS_008 | Verify timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP use current DBT run time |
| BZ_SUPPORT_TICKETS_009 | Test TICKET_TYPE domain validation | Valid ticket types (technical, billing, account, feature_request) |
| BZ_SUPPORT_TICKETS_010 | Test RESOLUTION_STATUS domain validation | Valid statuses (open, in_progress, resolved, closed) |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_BILLING_EVENTS_001 | Test primary key uniqueness (EVENT_ID) | No duplicate EVENT_ID values in output |
| BZ_BILLING_EVENTS_002 | Verify NULL primary key filtering | Records with NULL EVENT_ID are excluded |
| BZ_BILLING_EVENTS_003 | Verify NULL user_id filtering | Records with NULL USER_ID are excluded |
| BZ_BILLING_EVENTS_004 | Verify NULL event_type filtering | Records with NULL EVENT_TYPE are excluded |
| BZ_BILLING_EVENTS_005 | Verify NULL event_date filtering | Records with NULL EVENT_DATE are excluded |
| BZ_BILLING_EVENTS_006 | Test AMOUNT default value handling | NULL or empty AMOUNT defaults to 0.00 |
| BZ_BILLING_EVENTS_007 | Test AMOUNT data type conversion | VARCHAR AMOUNT converted to NUMBER(10,2) |
| BZ_BILLING_EVENTS_008 | Test deduplication logic | Most recent record per EVENT_ID is retained |
| BZ_BILLING_EVENTS_009 | Verify timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP use current DBT run time |
| BZ_BILLING_EVENTS_010 | Test EVENT_TYPE domain validation | Valid event types (subscription, usage, refund, adjustment) |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_LICENSES_001 | Test primary key uniqueness (LICENSE_ID) | No duplicate LICENSE_ID values in output |
| BZ_LICENSES_002 | Verify NULL primary key filtering | Records with NULL LICENSE_ID are excluded |
| BZ_LICENSES_003 | Verify NULL license_type filtering | Records with NULL LICENSE_TYPE are excluded |
| BZ_LICENSES_004 | Verify NULL start_date filtering | Records with NULL START_DATE are excluded |
| BZ_LICENSES_005 | Test END_DATE data type conversion | VARCHAR END_DATE converted to DATE or NULL |
| BZ_LICENSES_006 | Test deduplication logic | Most recent record per LICENSE_ID is retained |
| BZ_LICENSES_007 | Verify timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP use current DBT run time |
| BZ_LICENSES_008 | Test invalid END_DATE handling | Invalid END_DATE values converted to NULL |
| BZ_LICENSES_009 | Test LICENSE_TYPE domain validation | Valid license types (Basic, Pro, Business, Enterprise) |
| BZ_LICENSES_010 | Test ASSIGNED_TO_USER_ID nullable handling | NULL ASSIGNED_TO_USER_ID values preserved |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  # BZ_USERS Tests
  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: user_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: email
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: warn
      - name: load_timestamp
        tests:
          - not_null:
              config:
                severity: error
      - name: update_timestamp
        tests:
          - not_null:
              config:
                severity: error

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: meeting_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: host_id
        tests:
          - not_null:
              config:
                severity: error
      - name: start_time
        tests:
          - not_null:
              config:
                severity: error
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
              config:
                severity: error

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: participant_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: meeting_id
        tests:
          - not_null:
              config:
                severity: error
      - name: user_id
        tests:
          - not_null:
              config:
                severity: error

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: usage_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: meeting_id
        tests:
          - not_null:
              config:
                severity: error
      - name: feature_name
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
              config:
                severity: warn
      - name: usage_count
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
              config:
                severity: error

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: ticket_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: user_id
        tests:
          - not_null:
              config:
                severity: error
      - name: ticket_type
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['technical', 'billing', 'account', 'feature_request']
              config:
                severity: warn
      - name: resolution_status
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed']
              config:
                severity: warn

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: event_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: user_id
        tests:
          - not_null:
              config:
                severity: error
      - name: event_type
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['subscription', 'usage', 'refund', 'adjustment']
              config:
                severity: warn
      - name: amount
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "amount >= 0"
              config:
                severity: warn

  # BZ_LICENSES Tests
  - name: bz_licenses
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: license_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: license_type
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: warn
      - name: start_date
        tests:
          - not_null:
              config:
                severity: error
```

### Custom SQL-based dbt Tests

#### 1. Test for Timestamp Overwrite Validation

```sql
-- tests/test_timestamp_overwrite.sql
-- Test that load_timestamp and update_timestamp are overwritten with current DBT run time

SELECT 
    'bz_users' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('bz_users') }}
WHERE load_timestamp != update_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL

UNION ALL

SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('bz_meetings') }}
WHERE load_timestamp != update_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL

UNION ALL

SELECT 
    'bz_participants' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('bz_participants') }}
WHERE load_timestamp != update_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL

UNION ALL

SELECT 
    'bz_feature_usage' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('bz_feature_usage') }}
WHERE load_timestamp != update_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL

UNION ALL

SELECT 
    'bz_support_tickets' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('bz_support_tickets') }}
WHERE load_timestamp != update_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL

UNION ALL

SELECT 
    'bz_billing_events' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('bz_billing_events') }}
WHERE load_timestamp != update_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL

UNION ALL

SELECT 
    'bz_licenses' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('bz_licenses') }}
WHERE load_timestamp != update_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL

HAVING failed_records > 0
```

#### 2. Test for Deduplication Logic

```sql
-- tests/test_deduplication.sql
-- Test that deduplication logic works correctly (no duplicates on primary keys)

WITH duplicate_check AS (
    SELECT 'bz_users' as table_name, user_id as pk, COUNT(*) as cnt
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_meetings' as table_name, meeting_id as pk, COUNT(*) as cnt
    FROM {{ ref('bz_meetings') }}
    GROUP BY meeting_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_participants' as table_name, participant_id as pk, COUNT(*) as cnt
    FROM {{ ref('bz_participants') }}
    GROUP BY participant_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_feature_usage' as table_name, usage_id as pk, COUNT(*) as cnt
    FROM {{ ref('bz_feature_usage') }}
    GROUP BY usage_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_support_tickets' as table_name, ticket_id as pk, COUNT(*) as cnt
    FROM {{ ref('bz_support_tickets') }}
    GROUP BY ticket_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_billing_events' as table_name, event_id as pk, COUNT(*) as cnt
    FROM {{ ref('bz_billing_events') }}
    GROUP BY event_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_licenses' as table_name, license_id as pk, COUNT(*) as cnt
    FROM {{ ref('bz_licenses') }}
    GROUP BY license_id
    HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

#### 3. Test for Data Type Conversion Validation

```sql
-- tests/test_data_type_conversions.sql
-- Test that data type conversions work correctly and handle invalid values

WITH conversion_tests AS (
    -- Test BZ_MEETINGS END_TIME conversion
    SELECT 
        'bz_meetings_end_time' as test_name,
        COUNT(*) as total_records,
        SUM(CASE WHEN end_time IS NOT NULL AND TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) IS NULL THEN 1 ELSE 0 END) as invalid_conversions
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    -- Test BZ_MEETINGS DURATION_MINUTES conversion
    SELECT 
        'bz_meetings_duration' as test_name,
        COUNT(*) as total_records,
        SUM(CASE WHEN duration_minutes IS NOT NULL AND duration_minutes < 0 THEN 1 ELSE 0 END) as invalid_conversions
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    -- Test BZ_PARTICIPANTS JOIN_TIME conversion
    SELECT 
        'bz_participants_join_time' as test_name,
        COUNT(*) as total_records,
        SUM(CASE WHEN join_time IS NOT NULL AND TRY_CAST(join_time AS TIMESTAMP_NTZ(9)) IS NULL THEN 1 ELSE 0 END) as invalid_conversions
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    -- Test BZ_BILLING_EVENTS AMOUNT conversion
    SELECT 
        'bz_billing_events_amount' as test_name,
        COUNT(*) as total_records,
        SUM(CASE WHEN amount IS NOT NULL AND amount < 0 THEN 1 ELSE 0 END) as invalid_conversions
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    -- Test BZ_LICENSES END_DATE conversion
    SELECT 
        'bz_licenses_end_date' as test_name,
        COUNT(*) as total_records,
        SUM(CASE WHEN end_date IS NOT NULL AND TRY_CAST(end_date AS DATE) IS NULL THEN 1 ELSE 0 END) as invalid_conversions
    FROM {{ ref('bz_licenses') }}
)

SELECT *
FROM conversion_tests
WHERE invalid_conversions > 0
```

#### 4. Test for Default Value Generation

```sql
-- tests/test_default_values.sql
-- Test that default values are generated correctly for NULL fields

WITH default_value_tests AS (
    -- Test BZ_USERS default USER_NAME generation
    SELECT 
        'bz_users_default_name' as test_name,
        COUNT(*) as failed_records
    FROM {{ ref('bz_users') }}
    WHERE user_name IS NULL
       OR (user_name NOT LIKE '%_user' AND user_name != CONCAT(user_id, '_user'))
    
    UNION ALL
    
    -- Test BZ_USERS default EMAIL generation
    SELECT 
        'bz_users_default_email' as test_name,
        COUNT(*) as failed_records
    FROM {{ ref('bz_users') }}
    WHERE email IS NULL
       OR (email NOT LIKE '%@gmail.com' AND email != CONCAT(user_id, '@gmail.com'))
    
    UNION ALL
    
    -- Test BZ_BILLING_EVENTS default AMOUNT
    SELECT 
        'bz_billing_events_default_amount' as test_name,
        COUNT(*) as failed_records
    FROM {{ ref('bz_billing_events') }}
    WHERE amount IS NULL
)

SELECT *
FROM default_value_tests
WHERE failed_records > 0
```

#### 5. Test for Source System Preservation

```sql
-- tests/test_source_system_preservation.sql
-- Test that source_system field is preserved from raw data

WITH source_system_tests AS (
    SELECT 
        'bz_users' as table_name,
        COUNT(*) as records_without_source_system
    FROM {{ ref('bz_users') }}
    WHERE source_system IS NULL OR source_system = ''
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        COUNT(*) as records_without_source_system
    FROM {{ ref('bz_meetings') }}
    WHERE source_system IS NULL OR source_system = ''
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        COUNT(*) as records_without_source_system
    FROM {{ ref('bz_participants') }}
    WHERE source_system IS NULL OR source_system = ''
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        COUNT(*) as records_without_source_system
    FROM {{ ref('bz_feature_usage') }}
    WHERE source_system IS NULL OR source_system = ''
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        COUNT(*) as records_without_source_system
    FROM {{ ref('bz_support_tickets') }}
    WHERE source_system IS NULL OR source_system = ''
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        COUNT(*) as records_without_source_system
    FROM {{ ref('bz_billing_events') }}
    WHERE source_system IS NULL OR source_system = ''
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        COUNT(*) as records_without_source_system
    FROM {{ ref('bz_licenses') }}
    WHERE source_system IS NULL OR source_system = ''
)

SELECT *
FROM source_system_tests
WHERE records_without_source_system > 0
```

### Parameterized Tests for Reusability

#### Generic Test Macro for Primary Key Validation

```sql
-- macros/test_primary_key_integrity.sql
{% macro test_primary_key_integrity(model, column_name) %}

  SELECT 
    '{{ model }}' as model_name,
    '{{ column_name }}' as primary_key_column,
    COUNT(*) as duplicate_count
  FROM {{ ref(model) }}
  WHERE {{ column_name }} IS NOT NULL
  GROUP BY {{ column_name }}
  HAVING COUNT(*) > 1

{% endmacro %}
```

#### Generic Test Macro for Timestamp Validation

```sql
-- macros/test_timestamp_consistency.sql
{% macro test_timestamp_consistency(model) %}

  SELECT 
    '{{ model }}' as model_name,
    COUNT(*) as inconsistent_timestamps
  FROM {{ ref(model) }}
  WHERE load_timestamp IS NULL 
     OR update_timestamp IS NULL
     OR load_timestamp != update_timestamp
     OR load_timestamp > CURRENT_TIMESTAMP()
     OR update_timestamp > CURRENT_TIMESTAMP()

{% endmacro %}
```

---

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Validate data type conversions and transformations
- Check deduplication logic and primary key integrity
- Verify timestamp overwrite functionality

### 2. Post-deployment Validation
- Execute custom SQL tests to validate business rules
- Check data quality metrics and completeness
- Validate referential integrity across models
- Monitor audit trail functionality

### 3. Continuous Monitoring
- Schedule regular test execution in production
- Set up alerts for test failures
- Track data quality trends over time
- Monitor performance metrics

### 4. Test Data Management
- Create representative test datasets
- Include edge cases and boundary conditions
- Test with various data volumes
- Validate error handling scenarios

---

## Expected Test Results

### Success Criteria
- All primary key uniqueness tests pass
- No NULL values in required fields
- All data type conversions execute successfully
- Timestamp overwrite functionality works correctly
- Deduplication logic eliminates duplicates
- Default value generation works as expected
- Domain value validation passes for all constrained fields
- Source system information is preserved
- Audit trail captures all operations

### Performance Benchmarks
- Test execution time < 5 minutes for full suite
- Individual model tests complete within 30 seconds
- Memory usage remains within Snowflake warehouse limits
- No test timeouts or resource constraints

---

## Maintenance and Updates

### Test Suite Maintenance
- Review and update tests when models change
- Add new tests for additional business rules
- Optimize test performance as data volumes grow
- Document test failures and resolutions

### Version Control
- Track all test changes in version control
- Maintain test documentation alongside code
- Review test coverage in code reviews
- Ensure backward compatibility of tests

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze layer dbt models in Snowflake, providing confidence in the data pipeline's accuracy and consistency.