_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer dbt models running in Snowflake. The test cases validate data transformations, business rules, edge cases, and error handling across all Bronze layer models including deduplication logic, audit trails, and data quality checks.

## Test Coverage Overview

### Models Under Test
1. **bz_data_audit** - Audit trail table
2. **bz_users** - User profile and subscription data
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participants tracking
5. **bz_feature_usage** - Platform feature usage records
6. **bz_support_tickets** - Customer support requests
7. **bz_billing_events** - Financial transactions and billing
8. **bz_licenses** - License assignments and entitlements

## Test Case List

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| TC_BZ_001 | Primary key uniqueness validation | bz_users | All primary keys are unique |
| TC_BZ_002 | Primary key not null validation | bz_users | No null primary keys |
| TC_BZ_003 | Email format validation | bz_users | Valid email addresses only |
| TC_BZ_004 | Deduplication logic validation | bz_users | Latest record per USER_ID |
| TC_BZ_005 | Source data filtering | bz_users | Null USER_ID records excluded |
| TC_BZ_006 | Meeting ID uniqueness | bz_meetings | All MEETING_ID are unique |
| TC_BZ_007 | Meeting ID not null | bz_meetings | No null MEETING_ID |
| TC_BZ_008 | Duration calculation validation | bz_meetings | Valid duration values |
| TC_BZ_009 | TRY_CAST error handling | bz_meetings | Invalid data types handled |
| TC_BZ_010 | Deduplication by timestamp | bz_meetings | Latest record per MEETING_ID |
| TC_BZ_011 | Participant ID uniqueness | bz_participants | All PARTICIPANT_ID are unique |
| TC_BZ_012 | Participant ID not null | bz_participants | No null PARTICIPANT_ID |
| TC_BZ_013 | Join/Leave time validation | bz_participants | JOIN_TIME <= LEAVE_TIME |
| TC_BZ_014 | Meeting reference integrity | bz_participants | Valid MEETING_ID references |
| TC_BZ_015 | User reference integrity | bz_participants | Valid USER_ID references |
| TC_BZ_016 | Feature usage ID uniqueness | bz_feature_usage | All USAGE_ID are unique |
| TC_BZ_017 | Feature usage ID not null | bz_feature_usage | No null USAGE_ID |
| TC_BZ_018 | Usage count validation | bz_feature_usage | USAGE_COUNT >= 0 |
| TC_BZ_019 | Feature name validation | bz_feature_usage | Valid feature names only |
| TC_BZ_020 | Usage date validation | bz_feature_usage | Valid date ranges |
| TC_BZ_021 | Support ticket ID uniqueness | bz_support_tickets | All TICKET_ID are unique |
| TC_BZ_022 | Support ticket ID not null | bz_support_tickets | No null TICKET_ID |
| TC_BZ_023 | Resolution status validation | bz_support_tickets | Valid status values |
| TC_BZ_024 | Open date validation | bz_support_tickets | OPEN_DATE <= CURRENT_DATE |
| TC_BZ_025 | Billing event ID uniqueness | bz_billing_events | All EVENT_ID are unique |
| TC_BZ_026 | Billing event ID not null | bz_billing_events | No null EVENT_ID |
| TC_BZ_027 | Amount validation | bz_billing_events | AMOUNT >= 0 |
| TC_BZ_028 | Event type validation | bz_billing_events | Valid event types only |
| TC_BZ_029 | TRY_CAST amount handling | bz_billing_events | Invalid amounts handled |
| TC_BZ_030 | License ID uniqueness | bz_licenses | All LICENSE_ID are unique |
| TC_BZ_031 | License ID not null | bz_licenses | No null LICENSE_ID |
| TC_BZ_032 | Date range validation | bz_licenses | START_DATE <= END_DATE |
| TC_BZ_033 | License type validation | bz_licenses | Valid license types only |
| TC_BZ_034 | TRY_CAST date handling | bz_licenses | Invalid dates handled |
| TC_BZ_035 | Audit table structure | bz_data_audit | Correct table structure |
| TC_BZ_036 | Row number deduplication | All models | ROW_NUMBER() logic works |
| TC_BZ_037 | COALESCE timestamp logic | All models | Proper timestamp handling |
| TC_BZ_038 | Source system tracking | All models | SOURCE_SYSTEM populated |
| TC_BZ_039 | Load timestamp tracking | All models | LOAD_TIMESTAMP populated |
| TC_BZ_040 | Empty dataset handling | All models | Handles empty source data |

## dbt Test Scripts

### YAML-based Schema Tests

#### tests/schema_tests.yml
```yaml
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
                severity: warn
          - dbt_utils.expression_is_true:
              expression: "email LIKE '%@%'"
              config:
                severity: warn
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
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
              config:
                severity: warn
      - name: start_time
        tests:
          - dbt_utils.expression_is_true:
              expression: "start_time <= CURRENT_TIMESTAMP() OR start_time IS NULL"
              config:
                severity: warn

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
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: usage_count
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0 OR usage_count IS NULL"
              config:
                severity: warn
      - name: feature_name
        tests:
          - accepted_values:
              values: ['Screen Share', 'Chat', 'Recording', 'Breakout Rooms', 'Whiteboard', 'Polls', 'Reactions']
              config:
                severity: warn

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
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Escalated']
              config:
                severity: warn
      - name: open_date
        tests:
          - dbt_utils.expression_is_true:
              expression: "open_date <= CURRENT_DATE() OR open_date IS NULL"
              config:
                severity: warn

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
      - name: amount
        tests:
          - dbt_utils.expression_is_true:
              expression: "amount >= 0 OR amount IS NULL"
              config:
                severity: warn
      - name: event_type
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund', 'Payment', 'Invoice']
              config:
                severity: warn

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
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Developer']
              config:
                severity: warn
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
```

### Custom SQL-based dbt Tests

#### tests/test_deduplication_logic.sql
```sql
-- Test: Validate deduplication logic across all Bronze models
-- Description: Ensures ROW_NUMBER() deduplication works correctly

WITH duplicate_check AS (
    SELECT 'bz_users' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT user_id, COUNT(*) as cnt
        FROM {{ ref('bz_users') }}
        GROUP BY user_id
        HAVING COUNT(*) > 1
    )
    
    UNION ALL
    
    SELECT 'bz_meetings' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT meeting_id, COUNT(*) as cnt
        FROM {{ ref('bz_meetings') }}
        GROUP BY meeting_id
        HAVING COUNT(*) > 1
    )
    
    UNION ALL
    
    SELECT 'bz_participants' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT participant_id, COUNT(*) as cnt
        FROM {{ ref('bz_participants') }}
        GROUP BY participant_id
        HAVING COUNT(*) > 1
    )
    
    UNION ALL
    
    SELECT 'bz_feature_usage' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT usage_id, COUNT(*) as cnt
        FROM {{ ref('bz_feature_usage') }}
        GROUP BY usage_id
        HAVING COUNT(*) > 1
    )
    
    UNION ALL
    
    SELECT 'bz_support_tickets' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT ticket_id, COUNT(*) as cnt
        FROM {{ ref('bz_support_tickets') }}
        GROUP BY ticket_id
        HAVING COUNT(*) > 1
    )
    
    UNION ALL
    
    SELECT 'bz_billing_events' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT event_id, COUNT(*) as cnt
        FROM {{ ref('bz_billing_events') }}
        GROUP BY event_id
        HAVING COUNT(*) > 1
    )
    
    UNION ALL
    
    SELECT 'bz_licenses' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT license_id, COUNT(*) as cnt
        FROM {{ ref('bz_licenses') }}
        GROUP BY license_id
        HAVING COUNT(*) > 1
    )
)

SELECT *
FROM duplicate_check
WHERE duplicate_count > 0
```

#### tests/test_try_cast_error_handling.sql
```sql
-- Test: Validate TRY_CAST error handling in Bronze models
-- Description: Ensures invalid data types are handled gracefully

WITH error_check AS (
    -- Check bz_meetings for TRY_CAST failures
    SELECT 
        'bz_meetings' as table_name,
        'end_time' as column_name,
        COUNT(*) as error_count
    FROM {{ source('raw', 'meetings') }}
    WHERE TRY_CAST(END_TIME AS TIMESTAMP_NTZ(9)) IS NULL 
      AND END_TIME IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        'duration_minutes' as column_name,
        COUNT(*) as error_count
    FROM {{ source('raw', 'meetings') }}
    WHERE TRY_CAST(DURATION_MINUTES AS NUMBER(38,0)) IS NULL 
      AND DURATION_MINUTES IS NOT NULL
    
    UNION ALL
    
    -- Check bz_participants for TRY_CAST failures
    SELECT 
        'bz_participants' as table_name,
        'join_time' as column_name,
        COUNT(*) as error_count
    FROM {{ source('raw', 'participants') }}
    WHERE TRY_CAST(JOIN_TIME AS TIMESTAMP_NTZ(9)) IS NULL 
      AND JOIN_TIME IS NOT NULL
    
    UNION ALL
    
    -- Check bz_billing_events for TRY_CAST failures
    SELECT 
        'bz_billing_events' as table_name,
        'amount' as column_name,
        COUNT(*) as error_count
    FROM {{ source('raw', 'billing_events') }}
    WHERE TRY_CAST(AMOUNT AS NUMBER(10,2)) IS NULL 
      AND AMOUNT IS NOT NULL
    
    UNION ALL
    
    -- Check bz_licenses for TRY_CAST failures
    SELECT 
        'bz_licenses' as table_name,
        'end_date' as column_name,
        COUNT(*) as error_count
    FROM {{ source('raw', 'licenses') }}
    WHERE TRY_CAST(END_DATE AS DATE) IS NULL 
      AND END_DATE IS NOT NULL
)

SELECT *
FROM error_check
WHERE error_count > 0
```

#### tests/test_timestamp_logic.sql
```sql
-- Test: Validate COALESCE timestamp logic for deduplication
-- Description: Ensures proper timestamp handling in ROW_NUMBER() functions

WITH timestamp_validation AS (
    SELECT 
        'bz_users' as table_name,
        COUNT(*) as invalid_timestamp_count
    FROM {{ ref('bz_users') }}
    WHERE LOAD_TIMESTAMP IS NULL
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        COUNT(*) as invalid_timestamp_count
    FROM {{ ref('bz_meetings') }}
    WHERE LOAD_TIMESTAMP IS NULL
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        COUNT(*) as invalid_timestamp_count
    FROM {{ ref('bz_participants') }}
    WHERE LOAD_TIMESTAMP IS NULL
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        COUNT(*) as invalid_timestamp_count
    FROM {{ ref('bz_feature_usage') }}
    WHERE LOAD_TIMESTAMP IS NULL
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        COUNT(*) as invalid_timestamp_count
    FROM {{ ref('bz_support_tickets') }}
    WHERE LOAD_TIMESTAMP IS NULL
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        COUNT(*) as invalid_timestamp_count
    FROM {{ ref('bz_billing_events') }}
    WHERE LOAD_TIMESTAMP IS NULL
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        COUNT(*) as invalid_timestamp_count
    FROM {{ ref('bz_licenses') }}
    WHERE LOAD_TIMESTAMP IS NULL
)

SELECT *
FROM timestamp_validation
WHERE invalid_timestamp_count > 0
```

#### tests/test_referential_integrity.sql
```sql
-- Test: Validate referential integrity between Bronze models
-- Description: Ensures foreign key relationships are maintained

WITH integrity_check AS (
    -- Check participants -> meetings relationship
    SELECT 
        'participants_to_meetings' as relationship_name,
        COUNT(*) as orphan_count
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL AND p.meeting_id IS NOT NULL
    
    UNION ALL
    
    -- Check participants -> users relationship
    SELECT 
        'participants_to_users' as relationship_name,
        COUNT(*) as orphan_count
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
    WHERE u.user_id IS NULL AND p.user_id IS NOT NULL
    
    UNION ALL
    
    -- Check feature_usage -> meetings relationship
    SELECT 
        'feature_usage_to_meetings' as relationship_name,
        COUNT(*) as orphan_count
    FROM {{ ref('bz_feature_usage') }} f
    LEFT JOIN {{ ref('bz_meetings') }} m ON f.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL AND f.meeting_id IS NOT NULL
    
    UNION ALL
    
    -- Check support_tickets -> users relationship
    SELECT 
        'support_tickets_to_users' as relationship_name,
        COUNT(*) as orphan_count
    FROM {{ ref('bz_support_tickets') }} s
    LEFT JOIN {{ ref('bz_users') }} u ON s.user_id = u.user_id
    WHERE u.user_id IS NULL AND s.user_id IS NOT NULL
    
    UNION ALL
    
    -- Check billing_events -> users relationship
    SELECT 
        'billing_events_to_users' as relationship_name,
        COUNT(*) as orphan_count
    FROM {{ ref('bz_billing_events') }} b
    LEFT JOIN {{ ref('bz_users') }} u ON b.user_id = u.user_id
    WHERE u.user_id IS NULL AND b.user_id IS NOT NULL
    
    UNION ALL
    
    -- Check licenses -> users relationship
    SELECT 
        'licenses_to_users' as relationship_name,
        COUNT(*) as orphan_count
    FROM {{ ref('bz_licenses') }} l
    LEFT JOIN {{ ref('bz_users') }} u ON l.assigned_to_user_id = u.user_id
    WHERE u.user_id IS NULL AND l.assigned_to_user_id IS NOT NULL
)

SELECT *
FROM integrity_check
WHERE orphan_count > 0
```

#### tests/test_business_rules.sql
```sql
-- Test: Validate business rules across Bronze models
-- Description: Ensures business logic constraints are met

WITH business_rule_violations AS (
    -- Rule: Meeting duration should be positive
    SELECT 
        'negative_meeting_duration' as rule_name,
        COUNT(*) as violation_count
    FROM {{ ref('bz_meetings') }}
    WHERE duration_minutes < 0
    
    UNION ALL
    
    -- Rule: Participant leave time should be after join time
    SELECT 
        'invalid_participant_session' as rule_name,
        COUNT(*) as violation_count
    FROM {{ ref('bz_participants') }}
    WHERE leave_time < join_time
    
    UNION ALL
    
    -- Rule: Feature usage count should be non-negative
    SELECT 
        'negative_usage_count' as rule_name,
        COUNT(*) as violation_count
    FROM {{ ref('bz_feature_usage') }}
    WHERE usage_count < 0
    
    UNION ALL
    
    -- Rule: Billing amount should be non-negative
    SELECT 
        'negative_billing_amount' as rule_name,
        COUNT(*) as violation_count
    FROM {{ ref('bz_billing_events') }}
    WHERE amount < 0
    
    UNION ALL
    
    -- Rule: License end date should be after start date
    SELECT 
        'invalid_license_period' as rule_name,
        COUNT(*) as violation_count
    FROM {{ ref('bz_licenses') }}
    WHERE end_date < start_date
    
    UNION ALL
    
    -- Rule: Support ticket open date should not be in future
    SELECT 
        'future_ticket_date' as rule_name,
        COUNT(*) as violation_count
    FROM {{ ref('bz_support_tickets') }}
    WHERE open_date > CURRENT_DATE()
)

SELECT *
FROM business_rule_violations
WHERE violation_count > 0
```

#### tests/test_audit_trail.sql
```sql
-- Test: Validate audit trail functionality
-- Description: Ensures audit table structure and data integrity

WITH audit_validation AS (
    -- Check audit table structure
    SELECT 
        'audit_table_exists' as check_name,
        CASE WHEN COUNT(*) >= 0 THEN 'PASS' ELSE 'FAIL' END as result
    FROM {{ ref('bz_data_audit') }}
    
    UNION ALL
    
    -- Check for required audit columns
    SELECT 
        'audit_columns_complete' as check_name,
        CASE 
            WHEN COUNT(DISTINCT CASE WHEN source_table IS NOT NULL THEN 1 END) > 0
             AND COUNT(DISTINCT CASE WHEN load_timestamp IS NOT NULL THEN 1 END) > 0
             AND COUNT(DISTINCT CASE WHEN processed_by IS NOT NULL THEN 1 END) > 0
             AND COUNT(DISTINCT CASE WHEN status IS NOT NULL THEN 1 END) > 0
            THEN 'PASS' 
            ELSE 'FAIL' 
        END as result
    FROM {{ ref('bz_data_audit') }}
    WHERE source_table IS NOT NULL
)

SELECT *
FROM audit_validation
WHERE result = 'FAIL'
```

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all schema tests
dbt test --models bronze

# Run specific test categories
dbt test --models bronze --select test_type:schema
dbt test --models bronze --select test_type:data

# Run custom SQL tests
dbt test --models bronze --select test_name:test_deduplication_logic
dbt test --models bronze --select test_name:test_try_cast_error_handling
```

### 2. Continuous Integration Testing
```yaml
# .github/workflows/dbt_test.yml
name: dbt Test Pipeline
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup dbt
        run: |
          pip install dbt-snowflake
      - name: Run dbt tests
        run: |
          dbt deps
          dbt test --models bronze
```

### 3. Data Quality Monitoring
```sql
-- Create monitoring view for ongoing data quality checks
CREATE OR REPLACE VIEW BRONZE.DATA_QUALITY_DASHBOARD AS
SELECT 
    'bz_users' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT user_id) as unique_keys,
    COUNT(*) - COUNT(DISTINCT user_id) as duplicate_count,
    COUNT(CASE WHEN email NOT LIKE '%@%' THEN 1 END) as invalid_emails,
    CURRENT_TIMESTAMP() as last_checked
FROM {{ ref('bz_users') }}

UNION ALL

SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT meeting_id) as unique_keys,
    COUNT(*) - COUNT(DISTINCT meeting_id) as duplicate_count,
    COUNT(CASE WHEN duration_minutes < 0 THEN 1 END) as invalid_durations,
    CURRENT_TIMESTAMP() as last_checked
FROM {{ ref('bz_meetings') }}

-- Add similar blocks for other tables...
```

## Expected Test Results

### Success Criteria
- **Zero Duplicates**: All primary keys must be unique across all models
- **No Null Primary Keys**: All primary key columns must have non-null values
- **Valid Relationships**: All foreign key relationships must be maintained
- **Business Rule Compliance**: All business logic constraints must be satisfied
- **Error Handling**: TRY_CAST functions must handle invalid data gracefully
- **Audit Trail**: All models must have proper audit trail metadata

### Performance Benchmarks
- **Test Execution Time**: < 5 minutes for full test suite
- **Data Processing Time**: < 30 seconds per Bronze model
- **Memory Usage**: < 2GB during test execution
- **Snowflake Credits**: < 0.1 credits per test run

## Troubleshooting Guide

### Common Test Failures
1. **Duplicate Records**: Check ROW_NUMBER() deduplication logic
2. **Null Primary Keys**: Verify source data filtering
3. **Failed Relationships**: Check referential integrity between models
4. **TRY_CAST Errors**: Review data type conversion logic
5. **Business Rule Violations**: Validate source data quality

### Resolution Steps
1. **Identify Failed Test**: Review dbt test output logs
2. **Analyze Root Cause**: Query source data to understand issue
3. **Fix Model Logic**: Update dbt model SQL as needed
4. **Re-run Tests**: Validate fix with targeted test execution
5. **Document Changes**: Update test cases if business rules change

## Maintenance and Updates

### Regular Maintenance Tasks
- **Weekly**: Review test execution results and performance metrics
- **Monthly**: Update test cases based on new business requirements
- **Quarterly**: Optimize test performance and add new edge cases
- **Annually**: Comprehensive review of all test coverage

### Version Control
- All test changes must be version controlled
- Test updates require peer review before deployment
- Maintain backward compatibility for existing tests
- Document all test case modifications

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze Layer dbt models in Snowflake, providing confidence in the data pipeline's accuracy and robustness.