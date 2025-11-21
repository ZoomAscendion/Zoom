_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Models

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze layer models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models.

## Test Coverage Overview

### Models Under Test
1. **bz_data_audit** - Bronze layer audit table
2. **bz_users** - User profile and subscription information
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participants and session tracking
5. **bz_feature_usage** - Platform feature usage tracking
6. **bz_support_tickets** - Customer support requests
7. **bz_billing_events** - Financial transactions and billing
8. **bz_licenses** - License assignments and entitlements

### Test Categories
- **Data Quality Tests**: Primary key uniqueness, not null constraints
- **Business Logic Tests**: Data transformations, deduplication, type casting
- **Edge Case Tests**: Null handling, empty datasets, invalid data types
- **Referential Integrity Tests**: Foreign key relationships
- **Performance Tests**: Large dataset handling
- **Audit Trail Tests**: Pre/post hook validation

---

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUDIT_001 | Validate audit table structure creation | Empty table with correct schema |
| TC_AUDIT_002 | Test audit record insertion via pre-hooks | Audit records created for each model run |
| TC_AUDIT_003 | Validate processing time calculation | Processing time > 0 for successful runs |
| TC_AUDIT_004 | Test status tracking (SUCCESS/FAILED) | Correct status values recorded |
| TC_AUDIT_005 | Validate RECORD_ID auto-increment | Sequential ID generation |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USERS_001 | Primary key uniqueness validation | No duplicate USER_ID values |
| TC_USERS_002 | Not null constraint on USER_ID | All records have valid USER_ID |
| TC_USERS_003 | Email format validation | Valid email addresses only |
| TC_USERS_004 | Plan type domain validation | Only valid plan types (Basic, Pro, Business, Enterprise) |
| TC_USERS_005 | Deduplication logic validation | Most recent record per USER_ID retained |
| TC_USERS_006 | Timestamp overwrite validation | LOAD_TIMESTAMP = CURRENT_TIMESTAMP() |
| TC_USERS_007 | Null USER_ID filtering | Records with null USER_ID excluded |
| TC_USERS_008 | Source system tracking | SOURCE_SYSTEM field populated |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MEETINGS_001 | Primary key uniqueness validation | No duplicate MEETING_ID values |
| TC_MEETINGS_002 | Not null constraint on MEETING_ID | All records have valid MEETING_ID |
| TC_MEETINGS_003 | Host ID foreign key validation | Valid HOST_ID references |
| TC_MEETINGS_004 | Duration calculation validation | DURATION_MINUTES >= 0 |
| TC_MEETINGS_005 | TRY_CAST validation for END_TIME | Invalid timestamps handled gracefully |
| TC_MEETINGS_006 | TRY_CAST validation for DURATION_MINUTES | Invalid numbers converted to NULL |
| TC_MEETINGS_007 | Deduplication logic validation | Most recent record per MEETING_ID retained |
| TC_MEETINGS_008 | Start time validation | START_TIME <= END_TIME when both present |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PARTICIPANTS_001 | Primary key uniqueness validation | No duplicate PARTICIPANT_ID values |
| TC_PARTICIPANTS_002 | Not null constraint on PARTICIPANT_ID | All records have valid PARTICIPANT_ID |
| TC_PARTICIPANTS_003 | Meeting ID foreign key validation | Valid MEETING_ID references |
| TC_PARTICIPANTS_004 | User ID foreign key validation | Valid USER_ID references |
| TC_PARTICIPANTS_005 | TRY_CAST validation for JOIN_TIME | Invalid timestamps handled gracefully |
| TC_PARTICIPANTS_006 | Session duration validation | LEAVE_TIME >= JOIN_TIME when both present |
| TC_PARTICIPANTS_007 | Deduplication logic validation | Most recent record per PARTICIPANT_ID retained |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FEATURE_001 | Primary key uniqueness validation | No duplicate USAGE_ID values |
| TC_FEATURE_002 | Not null constraint on USAGE_ID | All records have valid USAGE_ID |
| TC_FEATURE_003 | Meeting ID foreign key validation | Valid MEETING_ID references |
| TC_FEATURE_004 | Feature name domain validation | Valid feature names only |
| TC_FEATURE_005 | Usage count validation | USAGE_COUNT >= 0 |
| TC_FEATURE_006 | Usage date validation | Valid date format |
| TC_FEATURE_007 | Deduplication logic validation | Most recent record per USAGE_ID retained |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TICKETS_001 | Primary key uniqueness validation | No duplicate TICKET_ID values |
| TC_TICKETS_002 | Not null constraint on TICKET_ID | All records have valid TICKET_ID |
| TC_TICKETS_003 | User ID foreign key validation | Valid USER_ID references |
| TC_TICKETS_004 | Ticket type domain validation | Valid ticket types only |
| TC_TICKETS_005 | Resolution status validation | Valid status values only |
| TC_TICKETS_006 | Open date validation | Valid date format |
| TC_TICKETS_007 | Deduplication logic validation | Most recent record per TICKET_ID retained |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BILLING_001 | Primary key uniqueness validation | No duplicate EVENT_ID values |
| TC_BILLING_002 | Not null constraint on EVENT_ID | All records have valid EVENT_ID |
| TC_BILLING_003 | User ID foreign key validation | Valid USER_ID references |
| TC_BILLING_004 | Amount validation | AMOUNT >= 0 for valid transactions |
| TC_BILLING_005 | TRY_CAST validation for AMOUNT | Invalid amounts converted to NULL |
| TC_BILLING_006 | Event type domain validation | Valid event types only |
| TC_BILLING_007 | Event date validation | Valid date format |
| TC_BILLING_008 | Deduplication logic validation | Most recent record per EVENT_ID retained |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LICENSES_001 | Primary key uniqueness validation | No duplicate LICENSE_ID values |
| TC_LICENSES_002 | Not null constraint on LICENSE_ID | All records have valid LICENSE_ID |
| TC_LICENSES_003 | License type domain validation | Valid license types only |
| TC_LICENSES_004 | Date range validation | START_DATE <= END_DATE when both present |
| TC_LICENSES_005 | TRY_CAST validation for END_DATE | Invalid dates converted to NULL |
| TC_LICENSES_006 | User assignment validation | Valid USER_ID when assigned |
| TC_LICENSES_007 | Deduplication logic validation | Most recent record per LICENSE_ID retained |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema.yml
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
          - dbt_utils.expression_is_true:
              expression: "email LIKE '%@%'"
              config:
                severity: warn
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: error
      - name: load_timestamp
        tests:
          - not_null:
              config:
                severity: error
      - name: source_system
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
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
              config:
                severity: error
      - name: load_timestamp
        tests:
          - not_null:
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
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: user_id
        tests:
          - not_null:
              config:
                severity: error
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn

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
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: feature_name
        tests:
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
              config:
                severity: error
      - name: usage_count
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
              config:
                severity: error

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
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
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: ticket_type
        tests:
          - accepted_values:
              values: ['technical', 'billing', 'account', 'feature_request']
              config:
                severity: error
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed']
              config:
                severity: error

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
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
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: event_type
        tests:
          - accepted_values:
              values: ['subscription', 'usage', 'refund', 'adjustment']
              config:
                severity: error
      - name: amount
        tests:
          - dbt_utils.expression_is_true:
              expression: "amount >= 0 OR amount IS NULL"
              config:
                severity: error

  # BZ_LICENSES Tests
  - name: bz_licenses
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
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: error
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
                where: "assigned_to_user_id IS NOT NULL"
```

### Custom SQL-based dbt Tests

#### 1. Deduplication Validation Test

```sql
-- tests/test_deduplication_bz_users.sql
-- Test to ensure deduplication logic works correctly for bz_users

SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('bz_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### 2. Timestamp Overwrite Validation Test

```sql
-- tests/test_timestamp_overwrite.sql
-- Test to ensure LOAD_TIMESTAMP is overwritten with current timestamp

SELECT 
    'bz_users' as table_name,
    COUNT(*) as invalid_timestamp_count
FROM {{ ref('bz_users') }}
WHERE DATE(load_timestamp) != CURRENT_DATE()

UNION ALL

SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as invalid_timestamp_count
FROM {{ ref('bz_meetings') }}
WHERE DATE(load_timestamp) != CURRENT_DATE()

UNION ALL

SELECT 
    'bz_participants' as table_name,
    COUNT(*) as invalid_timestamp_count
FROM {{ ref('bz_participants') }}
WHERE DATE(load_timestamp) != CURRENT_DATE()
```

#### 3. TRY_CAST Validation Test

```sql
-- tests/test_try_cast_validation.sql
-- Test to ensure TRY_CAST functions handle invalid data gracefully

WITH source_data AS (
    SELECT 
        meeting_id,
        end_time,
        duration_minutes
    FROM {{ source('raw', 'meetings') }}
),
bronze_data AS (
    SELECT 
        meeting_id,
        end_time,
        duration_minutes
    FROM {{ ref('bz_meetings') }}
)
SELECT 
    s.meeting_id,
    'Invalid END_TIME conversion' as error_type
FROM source_data s
LEFT JOIN bronze_data b ON s.meeting_id = b.meeting_id
WHERE s.end_time IS NOT NULL 
  AND b.end_time IS NULL
  AND TRY_CAST(s.end_time AS TIMESTAMP_NTZ(9)) IS NULL

UNION ALL

SELECT 
    s.meeting_id,
    'Invalid DURATION_MINUTES conversion' as error_type
FROM source_data s
LEFT JOIN bronze_data b ON s.meeting_id = b.meeting_id
WHERE s.duration_minutes IS NOT NULL 
  AND b.duration_minutes IS NULL
  AND TRY_CAST(s.duration_minutes AS NUMBER(38,0)) IS NULL
```

#### 4. Audit Trail Validation Test

```sql
-- tests/test_audit_trail.sql
-- Test to ensure audit records are created for each model execution

SELECT 
    source_table,
    COUNT(*) as audit_record_count
FROM {{ ref('bz_data_audit') }}
WHERE DATE(load_timestamp) = CURRENT_DATE()
GROUP BY source_table
HAVING COUNT(*) = 0
```

#### 5. Data Quality Summary Test

```sql
-- tests/test_data_quality_summary.sql
-- Comprehensive data quality test across all Bronze tables

WITH quality_metrics AS (
    SELECT 
        'bz_users' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN user_id IS NULL THEN 1 END) as null_primary_keys,
        COUNT(DISTINCT user_id) as unique_primary_keys
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN meeting_id IS NULL THEN 1 END) as null_primary_keys,
        COUNT(DISTINCT meeting_id) as unique_primary_keys
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN participant_id IS NULL THEN 1 END) as null_primary_keys,
        COUNT(DISTINCT participant_id) as unique_primary_keys
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN usage_id IS NULL THEN 1 END) as null_primary_keys,
        COUNT(DISTINCT usage_id) as unique_primary_keys
    FROM {{ ref('bz_feature_usage') }}
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN ticket_id IS NULL THEN 1 END) as null_primary_keys,
        COUNT(DISTINCT ticket_id) as unique_primary_keys
    FROM {{ ref('bz_support_tickets') }}
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN event_id IS NULL THEN 1 END) as null_primary_keys,
        COUNT(DISTINCT event_id) as unique_primary_keys
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN license_id IS NULL THEN 1 END) as null_primary_keys,
        COUNT(DISTINCT license_id) as unique_primary_keys
    FROM {{ ref('bz_licenses') }}
)
SELECT 
    table_name,
    'Primary key violation' as issue_type
FROM quality_metrics
WHERE null_primary_keys > 0 
   OR total_records != unique_primary_keys
```

#### 6. Performance Test for Large Datasets

```sql
-- tests/test_performance_large_dataset.sql
-- Test to ensure models perform well with large datasets

WITH performance_metrics AS (
    SELECT 
        'bz_users' as table_name,
        COUNT(*) as record_count,
        CURRENT_TIMESTAMP() as test_timestamp
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        COUNT(*) as record_count,
        CURRENT_TIMESTAMP() as test_timestamp
    FROM {{ ref('bz_meetings') }}
)
SELECT 
    table_name,
    'Performance issue - too few records' as issue_type
FROM performance_metrics
WHERE record_count < 1000  -- Adjust threshold as needed
```

### Parameterized Tests

#### Generic Test for Primary Key Validation

```sql
-- macros/test_primary_key_quality.sql
{% macro test_primary_key_quality(model, primary_key_column) %}

SELECT 
    '{{ primary_key_column }}' as column_name,
    'Null primary key found' as issue_type,
    COUNT(*) as issue_count
FROM {{ model }}
WHERE {{ primary_key_column }} IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    '{{ primary_key_column }}' as column_name,
    'Duplicate primary key found' as issue_type,
    COUNT(*) - COUNT(DISTINCT {{ primary_key_column }}) as issue_count
FROM {{ model }}
HAVING COUNT(*) != COUNT(DISTINCT {{ primary_key_column }})

{% endmacro %}
```

#### Generic Test for Foreign Key Validation

```sql
-- macros/test_foreign_key_integrity.sql
{% macro test_foreign_key_integrity(model, foreign_key_column, reference_model, reference_column) %}

SELECT 
    {{ foreign_key_column }} as orphaned_key,
    COUNT(*) as orphan_count
FROM {{ model }} m
LEFT JOIN {{ reference_model }} r 
    ON m.{{ foreign_key_column }} = r.{{ reference_column }}
WHERE m.{{ foreign_key_column }} IS NOT NULL
  AND r.{{ reference_column }} IS NULL
GROUP BY {{ foreign_key_column }}
HAVING COUNT(*) > 0

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Validate data quality metrics
- Check audit trail functionality

### 2. Post-deployment Validation
- Verify record counts match expectations
- Validate timestamp overwrites
- Check deduplication effectiveness

### 3. Continuous Monitoring
- Daily execution of critical tests
- Weekly comprehensive test suite
- Monthly performance benchmarking

### 4. Test Results Tracking
- Store test results in dbt's run_results.json
- Log test outcomes to Snowflake audit schema
- Generate test reports for stakeholders

## Expected Test Outcomes

### Success Criteria
- All primary key tests pass (100% unique, non-null)
- All foreign key relationships validated
- Data type conversions handled gracefully
- Audit trail records created for each execution
- Performance benchmarks met
- Business rule validations pass

### Failure Scenarios
- Duplicate primary keys detected
- Null values in required fields
- Invalid foreign key references
- Data type conversion failures
- Missing audit records
- Performance degradation

## Maintenance and Updates

### Test Maintenance Schedule
- **Weekly**: Review test results and update thresholds
- **Monthly**: Add new test cases for edge scenarios
- **Quarterly**: Performance test optimization
- **Annually**: Comprehensive test suite review

### Version Control
- All test scripts maintained in version control
- Test case documentation updated with model changes
- Test results archived for historical analysis

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze layer dbt models in Snowflake, providing confidence in the data pipeline's integrity and supporting robust analytics capabilities.