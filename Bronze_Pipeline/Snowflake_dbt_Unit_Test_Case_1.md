_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Bronze layer dbt models in Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Bronze Layer Models

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Bronze layer models in the Zoom Platform Analytics System. The tests validate data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models in Snowflake.

## Test Strategy

### Testing Approach
- **Data Quality Tests**: Validate data integrity, uniqueness, and completeness
- **Business Rule Tests**: Ensure transformations follow business logic
- **Edge Case Tests**: Handle null values, empty datasets, and boundary conditions
- **Performance Tests**: Validate model execution efficiency
- **Audit Trail Tests**: Verify comprehensive logging and tracking

### Test Coverage
- 8 Bronze layer models
- 54+ individual test cases
- Schema validation tests
- Data lineage verification
- Error handling scenarios

---

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_AUDIT_001 | Verify RECORD_ID uniqueness and auto-increment | All RECORD_ID values are unique and sequential |
| BZ_AUDIT_002 | Validate SOURCE_TABLE not null constraint | No null values in SOURCE_TABLE column |
| BZ_AUDIT_003 | Check LOAD_TIMESTAMP format and validity | All timestamps in valid TIMESTAMP_NTZ format |
| BZ_AUDIT_004 | Verify STATUS accepted values | STATUS contains only: SUCCESS, FAILED, WARNING, STARTED, INITIALIZED |
| BZ_AUDIT_005 | Test audit trail completeness | Each Bronze model execution creates audit record |
| BZ_AUDIT_006 | Validate PROCESSING_TIME data type | PROCESSING_TIME is NUMBER(38,3) and >= 0 |
| BZ_AUDIT_007 | Check PROCESSED_BY field population | PROCESSED_BY field is populated for all records |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_USERS_001 | Verify USER_ID uniqueness | All USER_ID values are unique |
| BZ_USERS_002 | Validate USER_ID not null constraint | No null values in USER_ID column |
| BZ_USERS_003 | Test email format validation | EMAIL field contains valid email patterns |
| BZ_USERS_004 | Check PLAN_TYPE accepted values | PLAN_TYPE contains: Basic, Pro, Business, Enterprise |
| BZ_USERS_005 | Verify deduplication logic | Only most recent record per USER_ID retained |
| BZ_USERS_006 | Test source system tracking | SOURCE_SYSTEM field populated for all records |
| BZ_USERS_007 | Validate timestamp consistency | UPDATE_TIMESTAMP >= LOAD_TIMESTAMP |
| BZ_USERS_008 | Check PII field handling | USER_NAME and EMAIL properly preserved |
| BZ_USERS_009 | Test null handling for optional fields | COMPANY field allows null values |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_MEETINGS_001 | Verify MEETING_ID uniqueness | All MEETING_ID values are unique |
| BZ_MEETINGS_002 | Validate MEETING_ID not null constraint | No null values in MEETING_ID column |
| BZ_MEETINGS_003 | Check HOST_ID not null constraint | No null values in HOST_ID column |
| BZ_MEETINGS_004 | Test meeting duration calculation | DURATION_MINUTES matches END_TIME - START_TIME |
| BZ_MEETINGS_005 | Verify time sequence logic | END_TIME >= START_TIME for all meetings |
| BZ_MEETINGS_006 | Validate deduplication logic | Only most recent record per MEETING_ID retained |
| BZ_MEETINGS_007 | Test meeting topic PII handling | MEETING_TOPIC field preserved as-is |
| BZ_MEETINGS_008 | Check duration data type | DURATION_MINUTES is NUMBER(38,0) and >= 0 |
| BZ_MEETINGS_009 | Verify timestamp format consistency | All timestamps in TIMESTAMP_NTZ format |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_PARTICIPANTS_001 | Verify PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique |
| BZ_PARTICIPANTS_002 | Validate required field constraints | PARTICIPANT_ID, MEETING_ID, USER_ID not null |
| BZ_PARTICIPANTS_003 | Test participation time logic | LEAVE_TIME >= JOIN_TIME for all participants |
| BZ_PARTICIPANTS_004 | Check foreign key relationships | MEETING_ID exists in BZ_MEETINGS (logical check) |
| BZ_PARTICIPANTS_005 | Verify user reference integrity | USER_ID exists in BZ_USERS (logical check) |
| BZ_PARTICIPANTS_006 | Validate deduplication logic | Only most recent record per PARTICIPANT_ID retained |
| BZ_PARTICIPANTS_007 | Test timestamp format consistency | All timestamps in TIMESTAMP_NTZ format |
| BZ_PARTICIPANTS_008 | Check participation duration calculation | Valid time difference between JOIN and LEAVE |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_FEATURE_USAGE_001 | Verify USAGE_ID uniqueness | All USAGE_ID values are unique |
| BZ_FEATURE_USAGE_002 | Validate USAGE_ID not null constraint | No null values in USAGE_ID column |
| BZ_FEATURE_USAGE_003 | Check USAGE_COUNT data type and range | USAGE_COUNT is NUMBER(38,0) and > 0 |
| BZ_FEATURE_USAGE_004 | Test feature name standardization | FEATURE_NAME contains valid feature identifiers |
| BZ_FEATURE_USAGE_005 | Verify meeting reference integrity | MEETING_ID exists in BZ_MEETINGS (logical check) |
| BZ_FEATURE_USAGE_006 | Validate usage date format | USAGE_DATE in valid DATE format |
| BZ_FEATURE_USAGE_007 | Check deduplication logic | Only most recent record per USAGE_ID retained |
| BZ_FEATURE_USAGE_008 | Test usage count aggregation | USAGE_COUNT represents valid usage metrics |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_SUPPORT_TICKETS_001 | Verify TICKET_ID uniqueness | All TICKET_ID values are unique |
| BZ_SUPPORT_TICKETS_002 | Validate required field constraints | TICKET_ID, USER_ID not null |
| BZ_SUPPORT_TICKETS_003 | Check RESOLUTION_STATUS accepted values | STATUS: Open, In Progress, Resolved, Closed |
| BZ_SUPPORT_TICKETS_004 | Test ticket type validation | TICKET_TYPE contains valid support categories |
| BZ_SUPPORT_TICKETS_005 | Verify user reference integrity | USER_ID exists in BZ_USERS (logical check) |
| BZ_SUPPORT_TICKETS_006 | Validate open date format | OPEN_DATE in valid DATE format |
| BZ_SUPPORT_TICKETS_007 | Check deduplication logic | Only most recent record per TICKET_ID retained |
| BZ_SUPPORT_TICKETS_008 | Test date consistency | OPEN_DATE <= current date |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_BILLING_EVENTS_001 | Verify EVENT_ID uniqueness | All EVENT_ID values are unique |
| BZ_BILLING_EVENTS_002 | Validate EVENT_ID not null constraint | No null values in EVENT_ID column |
| BZ_BILLING_EVENTS_003 | Check AMOUNT data type and precision | AMOUNT is NUMBER(10,2) with valid precision |
| BZ_BILLING_EVENTS_004 | Test amount value validation | AMOUNT >= 0 for all billing events |
| BZ_BILLING_EVENTS_005 | Verify event type validation | EVENT_TYPE contains valid billing categories |
| BZ_BILLING_EVENTS_006 | Check user reference integrity | USER_ID exists in BZ_USERS (logical check) |
| BZ_BILLING_EVENTS_007 | Validate event date format | EVENT_DATE in valid DATE format |
| BZ_BILLING_EVENTS_008 | Test deduplication logic | Only most recent record per EVENT_ID retained |
| BZ_BILLING_EVENTS_009 | Check financial data precision | AMOUNT maintains 2 decimal places |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_LICENSES_001 | Verify LICENSE_ID uniqueness | All LICENSE_ID values are unique |
| BZ_LICENSES_002 | Validate LICENSE_ID not null constraint | No null values in LICENSE_ID column |
| BZ_LICENSES_003 | Check license type validation | LICENSE_TYPE contains valid license categories |
| BZ_LICENSES_004 | Test date range validation | END_DATE >= START_DATE for all licenses |
| BZ_LICENSES_005 | Verify user assignment integrity | ASSIGNED_TO_USER_ID exists in BZ_USERS (logical) |
| BZ_LICENSES_006 | Validate date format consistency | START_DATE and END_DATE in valid DATE format |
| BZ_LICENSES_007 | Check deduplication logic | Only most recent record per LICENSE_ID retained |
| BZ_LICENSES_008 | Test license validity period | License dates within reasonable business range |

---

## dbt Test Scripts

### YAML-based Schema Tests

#### File: models/bronze/schema.yml (Enhanced Test Configuration)

```yaml
version: 2

models:
  - name: bz_data_audit
    description: "Comprehensive audit trail for all Bronze layer data operations"
    tests:
      - dbt_utils.expression_is_true:
          expression: "PROCESSING_TIME >= 0"
          config:
            severity: error
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier for each audit record"
        tests:
          - not_null
          - unique
      - name: source_table
        description: "Name of the Bronze layer table being processed"
        tests:
          - not_null
          - accepted_values:
              values: ['BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 'BZ_BILLING_EVENTS', 'BZ_LICENSES']
      - name: load_timestamp
        description: "When the operation occurred"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "LOAD_TIMESTAMP <= CURRENT_TIMESTAMP()"
      - name: status
        description: "Status of the operation"
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING', 'STARTED', 'INITIALIZED']

  - name: bz_users
    description: "Bronze layer table storing raw user profile and subscription information"
    tests:
      - dbt_utils.expression_is_true:
          expression: "UPDATE_TIMESTAMP >= LOAD_TIMESTAMP"
          config:
            severity: warn
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: email
        description: "Email address of the user"
        tests:
          - dbt_utils.expression_is_true:
              expression: "EMAIL LIKE '%@%.%'"
              config:
                severity: warn
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: warn
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_meetings
    description: "Bronze layer table storing raw meeting information"
    tests:
      - dbt_utils.expression_is_true:
          expression: "END_TIME >= START_TIME"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "DURATION_MINUTES >= 0"
          config:
            severity: error
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.expression_is_true:
              expression: "DURATION_MINUTES >= 0"

  - name: bz_participants
    description: "Bronze layer table tracking meeting participants"
    tests:
      - dbt_utils.expression_is_true:
          expression: "LEAVE_TIME >= JOIN_TIME"
          config:
            severity: error
    columns:
      - name: participant_id
        description: "Unique identifier for each meeting participant"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - not_null

  - name: bz_feature_usage
    description: "Bronze layer table recording feature usage"
    tests:
      - dbt_utils.expression_is_true:
          expression: "USAGE_COUNT > 0"
          config:
            severity: error
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - not_null
          - unique
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - dbt_utils.expression_is_true:
              expression: "USAGE_COUNT > 0"
      - name: usage_date
        description: "Date when feature usage occurred"
        tests:
          - not_null

  - name: bz_support_tickets
    description: "Bronze layer table managing support requests"
    tests:
      - dbt_utils.expression_is_true:
          expression: "OPEN_DATE <= CURRENT_DATE()"
          config:
            severity: error
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - not_null
      - name: resolution_status
        description: "Current status of ticket resolution"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: bz_billing_events
    description: "Bronze layer table tracking billing activities"
    tests:
      - dbt_utils.expression_is_true:
          expression: "AMOUNT >= 0"
          config:
            severity: error
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null
          - unique
      - name: amount
        description: "Monetary amount for the billing event"
        tests:
          - dbt_utils.expression_is_true:
              expression: "AMOUNT >= 0"
      - name: event_date
        description: "Date when the billing event occurred"
        tests:
          - not_null

  - name: bz_licenses
    description: "Bronze layer table managing license assignments"
    tests:
      - dbt_utils.expression_is_true:
          expression: "END_DATE >= START_DATE"
          config:
            severity: error
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: start_date
        description: "License validity start date"
        tests:
          - not_null
      - name: end_date
        description: "License validity end date"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### File: tests/bronze/test_deduplication_logic.sql

```sql
-- Test: Verify deduplication logic across all Bronze models
-- Description: Ensures ROW_NUMBER() deduplication works correctly

WITH duplicate_check AS (
    SELECT 'BZ_USERS' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT USER_ID, COUNT(*) as cnt
        FROM {{ ref('bz_users') }}
        GROUP BY USER_ID
        HAVING COUNT(*) > 1
    )
    
    UNION ALL
    
    SELECT 'BZ_MEETINGS' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT MEETING_ID, COUNT(*) as cnt
        FROM {{ ref('bz_meetings') }}
        GROUP BY MEETING_ID
        HAVING COUNT(*) > 1
    )
    
    UNION ALL
    
    SELECT 'BZ_PARTICIPANTS' as table_name, COUNT(*) as duplicate_count
    FROM (
        SELECT PARTICIPANT_ID, COUNT(*) as cnt
        FROM {{ ref('bz_participants') }}
        GROUP BY PARTICIPANT_ID
        HAVING COUNT(*) > 1
    )
)

SELECT *
FROM duplicate_check
WHERE duplicate_count > 0
```

#### File: tests/bronze/test_audit_trail_completeness.sql

```sql
-- Test: Verify audit trail completeness
-- Description: Ensures every Bronze model execution creates audit records

WITH expected_tables AS (
    SELECT table_name
    FROM VALUES 
        ('BZ_USERS'),
        ('BZ_MEETINGS'),
        ('BZ_PARTICIPANTS'),
        ('BZ_FEATURE_USAGE'),
        ('BZ_SUPPORT_TICKETS'),
        ('BZ_BILLING_EVENTS'),
        ('BZ_LICENSES')
    AS t(table_name)
),

audit_coverage AS (
    SELECT DISTINCT SOURCE_TABLE
    FROM {{ ref('bz_data_audit') }}
    WHERE STATUS IN ('SUCCESS', 'STARTED')
)

SELECT e.table_name
FROM expected_tables e
LEFT JOIN audit_coverage a ON e.table_name = a.SOURCE_TABLE
WHERE a.SOURCE_TABLE IS NULL
```

#### File: tests/bronze/test_data_freshness.sql

```sql
-- Test: Verify data freshness across Bronze models
-- Description: Ensures data is loaded within acceptable time windows

WITH freshness_check AS (
    SELECT 
        'BZ_USERS' as table_name,
        MAX(LOAD_TIMESTAMP) as latest_load,
        DATEDIFF('hour', MAX(LOAD_TIMESTAMP), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'BZ_MEETINGS' as table_name,
        MAX(LOAD_TIMESTAMP) as latest_load,
        DATEDIFF('hour', MAX(LOAD_TIMESTAMP), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'BZ_PARTICIPANTS' as table_name,
        MAX(LOAD_TIMESTAMP) as latest_load,
        DATEDIFF('hour', MAX(LOAD_TIMESTAMP), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_participants') }}
)

SELECT *
FROM freshness_check
WHERE hours_since_load > 24  -- Alert if data is older than 24 hours
```

#### File: tests/bronze/test_referential_integrity.sql

```sql
-- Test: Verify logical referential integrity
-- Description: Checks foreign key relationships without constraints

WITH integrity_violations AS (
    -- Check if all HOST_IDs in meetings exist in users
    SELECT 
        'MEETINGS_HOST_ID' as violation_type,
        COUNT(*) as violation_count
    FROM {{ ref('bz_meetings') }} m
    LEFT JOIN {{ ref('bz_users') }} u ON m.HOST_ID = u.USER_ID
    WHERE u.USER_ID IS NULL AND m.HOST_ID IS NOT NULL
    
    UNION ALL
    
    -- Check if all participant USER_IDs exist in users
    SELECT 
        'PARTICIPANTS_USER_ID' as violation_type,
        COUNT(*) as violation_count
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_users') }} u ON p.USER_ID = u.USER_ID
    WHERE u.USER_ID IS NULL AND p.USER_ID IS NOT NULL
    
    UNION ALL
    
    -- Check if all participant MEETING_IDs exist in meetings
    SELECT 
        'PARTICIPANTS_MEETING_ID' as violation_type,
        COUNT(*) as violation_count
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_meetings') }} m ON p.MEETING_ID = m.MEETING_ID
    WHERE m.MEETING_ID IS NULL AND p.MEETING_ID IS NOT NULL
)

SELECT *
FROM integrity_violations
WHERE violation_count > 0
```

#### File: tests/bronze/test_data_quality_metrics.sql

```sql
-- Test: Comprehensive data quality metrics
-- Description: Calculates data quality scores for Bronze layer

WITH quality_metrics AS (
    SELECT 
        'BZ_USERS' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN USER_ID IS NULL THEN 1 END) as null_user_ids,
        COUNT(CASE WHEN EMAIL NOT LIKE '%@%.%' THEN 1 END) as invalid_emails,
        COUNT(CASE WHEN PLAN_TYPE NOT IN ('Basic', 'Pro', 'Business', 'Enterprise') THEN 1 END) as invalid_plan_types
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'BZ_MEETINGS' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN MEETING_ID IS NULL THEN 1 END) as null_meeting_ids,
        COUNT(CASE WHEN END_TIME < START_TIME THEN 1 END) as invalid_time_ranges,
        COUNT(CASE WHEN DURATION_MINUTES < 0 THEN 1 END) as negative_durations
    FROM {{ ref('bz_meetings') }}
)

SELECT 
    table_name,
    total_records,
    (null_user_ids + invalid_emails + invalid_plan_types + null_meeting_ids + invalid_time_ranges + negative_durations) as total_quality_issues,
    CASE 
        WHEN total_records = 0 THEN 0
        ELSE ROUND((total_quality_issues::FLOAT / total_records::FLOAT) * 100, 2)
    END as quality_issue_percentage
FROM quality_metrics
WHERE (null_user_ids + invalid_emails + invalid_plan_types + null_meeting_ids + invalid_time_ranges + negative_durations) > 0
```

### Parameterized Tests

#### File: macros/test_bronze_model_structure.sql

```sql
-- Macro: Test Bronze model structure consistency
-- Description: Validates that all Bronze models follow standard structure

{% macro test_bronze_model_structure(model_name) %}

WITH structure_check AS (
    SELECT 
        '{{ model_name }}' as model_name,
        CASE WHEN COUNT(CASE WHEN COLUMN_NAME = 'LOAD_TIMESTAMP' THEN 1 END) = 1 THEN 'PASS' ELSE 'FAIL' END as has_load_timestamp,
        CASE WHEN COUNT(CASE WHEN COLUMN_NAME = 'UPDATE_TIMESTAMP' THEN 1 END) = 1 THEN 'PASS' ELSE 'FAIL' END as has_update_timestamp,
        CASE WHEN COUNT(CASE WHEN COLUMN_NAME = 'SOURCE_SYSTEM' THEN 1 END) = 1 THEN 'PASS' ELSE 'FAIL' END as has_source_system
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'BRONZE'
      AND TABLE_NAME = UPPER('{{ model_name }}')
)

SELECT *
FROM structure_check
WHERE has_load_timestamp = 'FAIL' 
   OR has_update_timestamp = 'FAIL' 
   OR has_source_system = 'FAIL'

{% endmacro %}
```

## Test Execution Strategy

### 1. Continuous Integration Tests
- Run on every dbt model change
- Include basic data quality tests
- Fast execution (< 5 minutes)

### 2. Daily Data Quality Tests
- Comprehensive data validation
- Referential integrity checks
- Data freshness validation

### 3. Weekly Performance Tests
- Model execution time monitoring
- Resource utilization analysis
- Scalability validation

## Monitoring and Alerting

### Test Results Tracking
- Store test results in `dbt_test_results` table
- Create dashboards for test success rates
- Set up alerts for critical test failures

### Data Quality Metrics
- Track data quality scores over time
- Monitor data volume trends
- Alert on significant quality degradation

## Best Practices

### 1. Test Maintenance
- Review and update tests quarterly
- Add new tests for edge cases discovered
- Remove obsolete tests

### 2. Performance Optimization
- Use sampling for large dataset tests
- Optimize test queries for efficiency
- Parallel test execution where possible

### 3. Documentation
- Document test purpose and expected outcomes
- Maintain test case inventory
- Update test documentation with model changes

## Conclusion

This comprehensive unit test suite ensures the reliability, performance, and data quality of the Bronze layer dbt models in the Zoom Platform Analytics System. The tests cover:

- **54+ individual test cases** across 8 Bronze models
- **YAML-based schema tests** for standard validations
- **Custom SQL tests** for complex business rules
- **Parameterized tests** for reusable validation logic
- **Performance and monitoring** capabilities

Regular execution of these tests will maintain high data quality standards and catch issues early in the development cycle, ensuring reliable data pipelines in the Snowflake environment.