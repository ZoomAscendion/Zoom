_____________________________________________
## *Author*: AAVA
## *Created on*: 11-11-2025
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 11-11-2025
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze Layer pipeline. The tests validate data transformations, business rules, edge cases, and error handling across all Bronze layer models in Snowflake.

## Test Strategy

The testing approach covers:
- **Data Quality Tests**: Uniqueness, completeness, and validity
- **Business Logic Tests**: Deduplication, audit logging, and transformations
- **Edge Case Tests**: Null handling, duplicate records, and schema changes
- **Performance Tests**: Query efficiency and resource utilization
- **Integration Tests**: Cross-model relationships and dependencies

---

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUDIT_001 | Validate audit table structure initialization | Table created with correct schema, no data rows |
| TC_AUDIT_002 | Test audit record insertion via pre/post hooks | Audit records created for each model execution |
| TC_AUDIT_003 | Validate processing time calculation | Processing time > 0 for successful operations |
| TC_AUDIT_004 | Test audit status tracking | Status values: INITIALIZED, STARTED, SUCCESS |
| TC_AUDIT_005 | Validate record_id auto-increment | Sequential numbering without gaps |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USERS_001 | Test successful data load from RAW.USERS | All records loaded with 1:1 mapping |
| TC_USERS_002 | Validate deduplication logic | Latest record by UPDATE_TIMESTAMP retained |
| TC_USERS_003 | Test handling of null values | Null values preserved without transformation |
| TC_USERS_004 | Validate unique key constraint | USER_ID uniqueness maintained |
| TC_USERS_005 | Test PII data handling | USER_NAME and EMAIL fields preserved |
| TC_USERS_006 | Validate PLAN_TYPE domain values | Only valid plan types: Basic, Pro, Business, Enterprise |
| TC_USERS_007 | Test empty source table handling | Model completes without errors |
| TC_USERS_008 | Validate timestamp preservation | LOAD_TIMESTAMP and UPDATE_TIMESTAMP unchanged |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MEETINGS_001 | Test successful data load from RAW.MEETINGS | All records loaded with 1:1 mapping |
| TC_MEETINGS_002 | Validate deduplication logic | Latest record by UPDATE_TIMESTAMP retained |
| TC_MEETINGS_003 | Test meeting duration validation | DURATION_MINUTES matches calculated difference |
| TC_MEETINGS_004 | Validate HOST_ID foreign key relationship | All HOST_IDs exist in BZ_USERS |
| TC_MEETINGS_005 | Test timestamp logic validation | END_TIME >= START_TIME |
| TC_MEETINGS_006 | Validate meeting topic PII handling | MEETING_TOPIC preserved as-is |
| TC_MEETINGS_007 | Test zero duration meetings | Meetings with 0 duration handled correctly |
| TC_MEETINGS_008 | Validate source system tracking | SOURCE_SYSTEM field populated |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PARTICIPANTS_001 | Test successful data load from RAW.PARTICIPANTS | All records loaded with 1:1 mapping |
| TC_PARTICIPANTS_002 | Validate deduplication logic | Latest record by UPDATE_TIMESTAMP retained |
| TC_PARTICIPANTS_003 | Test participant session validation | LEAVE_TIME >= JOIN_TIME |
| TC_PARTICIPANTS_004 | Validate MEETING_ID foreign key relationship | All MEETING_IDs exist in BZ_MEETINGS |
| TC_PARTICIPANTS_005 | Validate USER_ID foreign key relationship | All USER_IDs exist in BZ_USERS |
| TC_PARTICIPANTS_006 | Test multiple participants per meeting | Multiple records per MEETING_ID allowed |
| TC_PARTICIPANTS_007 | Test same user multiple meetings | Same USER_ID across different meetings |
| TC_PARTICIPANTS_008 | Validate participant uniqueness | PARTICIPANT_ID unique across all records |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FEATURE_001 | Test successful data load from RAW.FEATURE_USAGE | All records loaded with 1:1 mapping |
| TC_FEATURE_002 | Validate deduplication logic | Latest record by UPDATE_TIMESTAMP retained |
| TC_FEATURE_003 | Test usage count validation | USAGE_COUNT >= 0 |
| TC_FEATURE_004 | Validate MEETING_ID foreign key relationship | All MEETING_IDs exist in BZ_MEETINGS |
| TC_FEATURE_005 | Test feature name standardization | FEATURE_NAME values consistent |
| TC_FEATURE_006 | Validate usage date alignment | USAGE_DATE within meeting date range |
| TC_FEATURE_007 | Test zero usage count handling | Records with USAGE_COUNT = 0 preserved |
| TC_FEATURE_008 | Validate usage aggregation | Multiple usage records per meeting allowed |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TICKETS_001 | Test successful data load from RAW.SUPPORT_TICKETS | All records loaded with 1:1 mapping |
| TC_TICKETS_002 | Validate deduplication logic | Latest record by UPDATE_TIMESTAMP retained |
| TC_TICKETS_003 | Test resolution status validation | Valid statuses: Open, In Progress, Resolved, Closed |
| TC_TICKETS_004 | Validate USER_ID foreign key relationship | All USER_IDs exist in BZ_USERS |
| TC_TICKETS_005 | Test ticket type categorization | TICKET_TYPE values properly categorized |
| TC_TICKETS_006 | Validate open date logic | OPEN_DATE <= current date |
| TC_TICKETS_007 | Test ticket lifecycle tracking | Status progression validation |
| TC_TICKETS_008 | Validate ticket uniqueness | TICKET_ID unique across all records |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BILLING_001 | Test successful data load from RAW.BILLING_EVENTS | All records loaded with 1:1 mapping |
| TC_BILLING_002 | Validate deduplication logic | Latest record by UPDATE_TIMESTAMP retained |
| TC_BILLING_003 | Test amount validation | AMOUNT field with proper decimal precision |
| TC_BILLING_004 | Validate USER_ID foreign key relationship | All USER_IDs exist in BZ_USERS |
| TC_BILLING_005 | Test event type categorization | EVENT_TYPE values properly categorized |
| TC_BILLING_006 | Validate event date logic | EVENT_DATE <= current date |
| TC_BILLING_007 | Test negative amount handling | Negative amounts for refunds allowed |
| TC_BILLING_008 | Validate billing event uniqueness | EVENT_ID unique across all records |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LICENSES_001 | Test successful data load from RAW.LICENSES | All records loaded with 1:1 mapping |
| TC_LICENSES_002 | Validate deduplication logic | Latest record by UPDATE_TIMESTAMP retained |
| TC_LICENSES_003 | Test license date validation | END_DATE >= START_DATE |
| TC_LICENSES_004 | Validate ASSIGNED_TO_USER_ID relationship | All user IDs exist in BZ_USERS |
| TC_LICENSES_005 | Test license type validation | LICENSE_TYPE values properly categorized |
| TC_LICENSES_006 | Validate license period logic | Active licenses within date range |
| TC_LICENSES_007 | Test license assignment tracking | User can have multiple licenses |
| TC_LICENSES_008 | Validate license uniqueness | LICENSE_ID unique across all records |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  - name: bz_data_audit
    description: "Audit table for Bronze layer operations"
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id > 0"
      - dbt_utils.expression_is_true:
          expression: "status IN ('INITIALIZED', 'STARTED', 'SUCCESS', 'FAILED', 'WARNING')"
    columns:
      - name: record_id
        description: "Unique audit record identifier"
        tests:
          - unique
          - not_null
      - name: source_table
        description: "Source table name"
        tests:
          - not_null
      - name: load_timestamp
        description: "Operation timestamp"
        tests:
          - not_null
      - name: status
        description: "Operation status"
        tests:
          - accepted_values:
              values: ['INITIALIZED', 'STARTED', 'SUCCESS', 'FAILED', 'WARNING']

  - name: bz_users
    description: "Bronze layer users table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "plan_type IN ('Basic', 'Pro', 'Business', 'Enterprise')"
      - dbt_utils.expression_is_true:
          expression: "update_timestamp >= load_timestamp"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - unique
          - not_null
      - name: user_name
        description: "User display name"
        tests:
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - unique
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: update_timestamp
        description: "Record update timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  - name: bz_meetings
    description: "Bronze layer meetings table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_time >= start_time"
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null

  - name: bz_participants
    description: "Bronze layer participants table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "leave_time >= join_time"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: join_time
        description: "Participant join timestamp"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave timestamp"
        tests:
          - not_null

  - name: bz_feature_usage
    description: "Bronze layer feature usage table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_count >= 0"
    columns:
      - name: usage_id
        description: "Unique usage record identifier"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
      - name: usage_count
        description: "Usage count"
        tests:
          - not_null
      - name: usage_date
        description: "Usage date"
        tests:
          - not_null

  - name: bz_support_tickets
    description: "Bronze layer support tickets table"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: resolution_status
        description: "Ticket resolution status"
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
      - name: open_date
        description: "Ticket open date"
        tests:
          - not_null

  - name: bz_billing_events
    description: "Bronze layer billing events table"
    columns:
      - name: event_id
        description: "Unique billing event identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: amount
        description: "Billing amount"
        tests:
          - not_null
      - name: event_date
        description: "Billing event date"
        tests:
          - not_null

  - name: bz_licenses
    description: "Bronze layer licenses table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_date >= start_date"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "Reference to assigned user"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### 1. Deduplication Logic Test

```sql
-- tests/test_deduplication_logic.sql
-- Test that deduplication logic works correctly across all Bronze models

WITH duplicate_check AS (
  SELECT 
    'bz_users' as table_name,
    user_id as key_field,
    COUNT(*) as record_count
  FROM {{ ref('bz_users') }}
  GROUP BY user_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 
    'bz_meetings' as table_name,
    meeting_id as key_field,
    COUNT(*) as record_count
  FROM {{ ref('bz_meetings') }}
  GROUP BY meeting_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 
    'bz_participants' as table_name,
    participant_id as key_field,
    COUNT(*) as record_count
  FROM {{ ref('bz_participants') }}
  GROUP BY participant_id
  HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

#### 2. Audit Trail Validation Test

```sql
-- tests/test_audit_trail_validation.sql
-- Validate that audit records are created for each model execution

WITH expected_tables AS (
  SELECT table_name
  FROM (
    VALUES 
      ('BZ_USERS'),
      ('BZ_MEETINGS'),
      ('BZ_PARTICIPANTS'),
      ('BZ_FEATURE_USAGE'),
      ('BZ_SUPPORT_TICKETS'),
      ('BZ_BILLING_EVENTS'),
      ('BZ_LICENSES')
  ) AS t(table_name)
),

audit_records AS (
  SELECT DISTINCT source_table
  FROM {{ ref('bz_data_audit') }}
  WHERE status IN ('STARTED', 'SUCCESS')
)

SELECT et.table_name
FROM expected_tables et
LEFT JOIN audit_records ar ON et.table_name = ar.source_table
WHERE ar.source_table IS NULL
```

#### 3. Data Freshness Test

```sql
-- tests/test_data_freshness.sql
-- Ensure data is loaded within acceptable time windows

WITH freshness_check AS (
  SELECT 
    'bz_users' as table_name,
    MAX(load_timestamp) as latest_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
  FROM {{ ref('bz_users') }}
  
  UNION ALL
  
  SELECT 
    'bz_meetings' as table_name,
    MAX(load_timestamp) as latest_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
  FROM {{ ref('bz_meetings') }}
)

SELECT *
FROM freshness_check
WHERE hours_since_load > 24  -- Data should be refreshed within 24 hours
```

#### 4. Cross-Model Relationship Test

```sql
-- tests/test_cross_model_relationships.sql
-- Validate referential integrity across Bronze models

WITH orphaned_records AS (
  -- Check for meetings without valid hosts
  SELECT 
    'meetings_without_hosts' as issue_type,
    m.meeting_id as record_id,
    m.host_id as foreign_key
  FROM {{ ref('bz_meetings') }} m
  LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
  WHERE u.user_id IS NULL
  
  UNION ALL
  
  -- Check for participants without valid users
  SELECT 
    'participants_without_users' as issue_type,
    p.participant_id as record_id,
    p.user_id as foreign_key
  FROM {{ ref('bz_participants') }} p
  LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
  WHERE u.user_id IS NULL
  
  UNION ALL
  
  -- Check for participants without valid meetings
  SELECT 
    'participants_without_meetings' as issue_type,
    p.participant_id as record_id,
    p.meeting_id as foreign_key
  FROM {{ ref('bz_participants') }} p
  LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
  WHERE m.meeting_id IS NULL
)

SELECT *
FROM orphaned_records
```

#### 5. Business Logic Validation Test

```sql
-- tests/test_business_logic_validation.sql
-- Validate business rules and logic across models

WITH business_rule_violations AS (
  -- Meeting duration should match calculated duration
  SELECT 
    'invalid_meeting_duration' as violation_type,
    meeting_id as record_id,
    duration_minutes as reported_duration,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
  FROM {{ ref('bz_meetings') }}
  WHERE duration_minutes != DATEDIFF('minute', start_time, end_time)
  
  UNION ALL
  
  -- Participant leave time should be after join time
  SELECT 
    'invalid_participant_session' as violation_type,
    participant_id as record_id,
    NULL as reported_duration,
    NULL as calculated_duration
  FROM {{ ref('bz_participants') }}
  WHERE leave_time < join_time
  
  UNION ALL
  
  -- License end date should be after start date
  SELECT 
    'invalid_license_period' as violation_type,
    license_id as record_id,
    NULL as reported_duration,
    NULL as calculated_duration
  FROM {{ ref('bz_licenses') }}
  WHERE end_date < start_date
)

SELECT *
FROM business_rule_violations
```

#### 6. Performance Monitoring Test

```sql
-- tests/test_performance_monitoring.sql
-- Monitor query performance and resource usage

WITH performance_metrics AS (
  SELECT 
    source_table,
    AVG(processing_time) as avg_processing_time,
    MAX(processing_time) as max_processing_time,
    COUNT(*) as execution_count
  FROM {{ ref('bz_data_audit') }}
  WHERE status = 'SUCCESS'
    AND load_timestamp >= DATEADD('day', -7, CURRENT_TIMESTAMP())
  GROUP BY source_table
)

SELECT *
FROM performance_metrics
WHERE avg_processing_time > 300  -- Flag tables taking more than 5 minutes on average
   OR max_processing_time > 1800  -- Flag tables taking more than 30 minutes maximum
```

### Parameterized Tests

#### Generic Test for Row Count Validation

```sql
-- macros/test_row_count_threshold.sql
{% macro test_row_count_threshold(model, threshold=1000) %}

  SELECT COUNT(*) as row_count
  FROM {{ model }}
  HAVING COUNT(*) < {{ threshold }}

{% endmacro %}
```

#### Generic Test for Data Type Validation

```sql
-- macros/test_data_type_consistency.sql
{% macro test_data_type_consistency(model, column_name, expected_type) %}

  SELECT 
    '{{ column_name }}' as column_name,
    COUNT(*) as invalid_records
  FROM {{ model }}
  WHERE NOT (
    {% if expected_type == 'timestamp' %}
      TRY_CAST({{ column_name }} AS TIMESTAMP_NTZ) IS NOT NULL
    {% elif expected_type == 'number' %}
      TRY_CAST({{ column_name }} AS NUMBER) IS NOT NULL
    {% elif expected_type == 'date' %}
      TRY_CAST({{ column_name }} AS DATE) IS NOT NULL
    {% else %}
      {{ column_name }} IS NOT NULL
    {% endif %}
  )
  HAVING COUNT(*) > 0

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Validate data quality and business rules
- Check for performance regressions

### 2. Post-deployment Validation
- Execute custom SQL tests after successful deployment
- Validate cross-model relationships
- Monitor audit trail completeness

### 3. Continuous Monitoring
- Schedule daily data freshness tests
- Monitor performance metrics weekly
- Alert on business rule violations

### 4. Test Data Management
- Maintain test datasets for edge cases
- Use dbt seeds for reference data
- Implement data masking for PII fields

## Expected Test Results

### Success Criteria
- All unique and not_null tests pass
- No referential integrity violations
- Deduplication logic working correctly
- Audit trail complete for all models
- Performance within acceptable thresholds

### Failure Scenarios
- Duplicate records in unique key fields
- Missing audit records for model executions
- Business rule violations detected
- Performance degradation beyond thresholds
- Data freshness exceeding acceptable limits

## Test Maintenance

### Regular Updates
- Review and update test thresholds quarterly
- Add new tests for business rule changes
- Optimize test performance as data grows
- Update expected values for domain tests

### Documentation
- Maintain test case documentation
- Document test failure resolution procedures
- Keep performance baseline metrics updated
- Track test coverage metrics

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze Layer dbt models in Snowflake, providing confidence in the data pipeline's operation and enabling early detection of potential issues.
