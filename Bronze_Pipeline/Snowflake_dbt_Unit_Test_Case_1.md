_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze layer dbt models that run in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Strategy Overview

The testing approach covers:
- **Happy Path Testing**: Valid transformations, joins, and aggregations
- **Edge Case Testing**: Null values, empty datasets, invalid lookups, schema mismatches
- **Exception Testing**: Failed relationships, unexpected values, data type mismatches
- **Data Quality Testing**: Uniqueness, completeness, referential integrity
- **Performance Testing**: Large dataset handling and processing efficiency

---

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUDIT_001 | Verify audit table structure creation | Table created with correct schema |
| TC_AUDIT_002 | Test audit record insertion during model execution | Audit records inserted with correct timestamps |
| TC_AUDIT_003 | Validate audit status values | Only accepted status values allowed |
| TC_AUDIT_004 | Test processing time calculation | Processing time calculated correctly |
| TC_AUDIT_005 | Verify record_id uniqueness | All record_id values are unique |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USERS_001 | Validate user_id uniqueness and not null | All user_id values unique and not null |
| TC_USERS_002 | Test deduplication logic | Latest record per user_id retained |
| TC_USERS_003 | Verify email format validation | Valid email addresses only |
| TC_USERS_004 | Test null filtering for primary keys | Records with null user_id excluded |
| TC_USERS_005 | Validate plan_type accepted values | Only valid plan types allowed |
| TC_USERS_006 | Test source system tracking | Source system properly recorded |
| TC_USERS_007 | Verify timestamp handling | Load and update timestamps handled correctly |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MEETINGS_001 | Validate meeting_id uniqueness | All meeting_id values unique |
| TC_MEETINGS_002 | Test host_id foreign key relationship | Valid host_id references exist |
| TC_MEETINGS_003 | Verify duration calculation logic | Duration calculated correctly from start/end times |
| TC_MEETINGS_004 | Test TRY_CAST for end_time and duration | Invalid values converted to null gracefully |
| TC_MEETINGS_005 | Validate meeting start/end time logic | End time >= start time |
| TC_MEETINGS_006 | Test null filtering for required fields | Records with null meeting_id or host_id excluded |
| TC_MEETINGS_007 | Verify deduplication by latest timestamp | Most recent meeting record retained |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PARTICIPANTS_001 | Validate participant_id uniqueness | All participant_id values unique |
| TC_PARTICIPANTS_002 | Test meeting_id foreign key integrity | Valid meeting references exist |
| TC_PARTICIPANTS_003 | Test user_id foreign key integrity | Valid user references exist |
| TC_PARTICIPANTS_004 | Verify join/leave time logic | Leave time >= join time when both present |
| TC_PARTICIPANTS_005 | Test TRY_CAST for join_time | Invalid timestamps handled gracefully |
| TC_PARTICIPANTS_006 | Validate null filtering for foreign keys | Records with null foreign keys excluded |
| TC_PARTICIPANTS_007 | Test participant session duration calculation | Session duration calculated correctly |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FEATURE_001 | Validate usage_id uniqueness | All usage_id values unique |
| TC_FEATURE_002 | Test meeting_id foreign key relationship | Valid meeting references exist |
| TC_FEATURE_003 | Verify feature_name standardization | Feature names properly standardized |
| TC_FEATURE_004 | Test usage_count validation | Usage count >= 0 |
| TC_FEATURE_005 | Validate usage_date format | Usage dates in correct format |
| TC_FEATURE_006 | Test null filtering for required fields | Records with null keys excluded |
| TC_FEATURE_007 | Verify feature usage aggregation | Usage counts aggregated correctly |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TICKETS_001 | Validate ticket_id uniqueness | All ticket_id values unique |
| TC_TICKETS_002 | Test user_id foreign key relationship | Valid user references exist |
| TC_TICKETS_003 | Verify ticket_type accepted values | Only valid ticket types allowed |
| TC_TICKETS_004 | Test resolution_status workflow | Status transitions follow business rules |
| TC_TICKETS_005 | Validate open_date format | Open dates in correct format |
| TC_TICKETS_006 | Test null filtering for required fields | Records with null keys excluded |
| TC_TICKETS_007 | Verify ticket lifecycle tracking | Ticket status changes tracked properly |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BILLING_001 | Validate event_id uniqueness | All event_id values unique |
| TC_BILLING_002 | Test user_id foreign key relationship | Valid user references exist |
| TC_BILLING_003 | Verify amount data type conversion | TRY_CAST handles invalid amounts |
| TC_BILLING_004 | Test event_type accepted values | Only valid event types allowed |
| TC_BILLING_005 | Validate amount precision | Amounts stored with correct precision (10,2) |
| TC_BILLING_006 | Test null filtering for required fields | Records with null keys excluded |
| TC_BILLING_007 | Verify billing event chronology | Event dates in logical sequence |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LICENSES_001 | Validate license_id uniqueness | All license_id values unique |
| TC_LICENSES_002 | Test license_type accepted values | Only valid license types allowed |
| TC_LICENSES_003 | Verify date range validation | End date >= start date when both present |
| TC_LICENSES_004 | Test TRY_CAST for end_date | Invalid dates converted to null gracefully |
| TC_LICENSES_005 | Validate user assignment logic | License assignments tracked correctly |
| TC_LICENSES_006 | Test null filtering for required fields | Records with null license_id excluded |
| TC_LICENSES_007 | Verify license lifecycle management | License status changes tracked properly |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id > 0"
          config:
            severity: error
    columns:
      - name: record_id
        tests:
          - not_null
          - unique
      - name: source_table
        tests:
          - not_null
      - name: status
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING', 'STARTED', 'INITIALIZED']
      - name: processing_time
        tests:
          - dbt_utils.expression_is_true:
              expression: "processing_time >= 0"

  # BZ_USERS Tests
  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "email LIKE '%@%'"
          config:
            severity: warn
    columns:
      - name: user_id
        tests:
          - not_null
          - unique
      - name: email
        tests:
          - not_null
      - name: plan_type
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'FREE']
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_time >= start_time OR end_time IS NULL"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
    columns:
      - name: meeting_id
        tests:
          - not_null
          - unique
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_time
        tests:
          - not_null
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes <= 1440 OR duration_minutes IS NULL"

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    tests:
      - dbt_utils.expression_is_true:
          expression: "leave_time >= join_time OR leave_time IS NULL"
    columns:
      - name: participant_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        tests:
          - not_null
          - accepted_values:
              values: ['SCREEN_SHARE', 'CHAT', 'RECORDING', 'BREAKOUT_ROOMS', 'WHITEBOARD', 'POLLS', 'REACTIONS']
      - name: usage_count
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    columns:
      - name: ticket_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        tests:
          - not_null
          - accepted_values:
              values: ['TECHNICAL', 'BILLING', 'ACCOUNT', 'FEATURE_REQUEST', 'BUG_REPORT']
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'ESCALATED']

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    columns:
      - name: event_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_type
        tests:
          - not_null
          - accepted_values:
              values: ['CHARGE', 'REFUND', 'CREDIT', 'SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE']
      - name: amount
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "amount >= 0"

  # BZ_LICENSES Tests
  - name: bz_licenses
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_date >= start_date OR end_date IS NULL"
    columns:
      - name: license_id
        tests:
          - not_null
          - unique
      - name: license_type
        tests:
          - not_null
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'TRIAL']
      - name: start_date
        tests:
          - not_null
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
```

### Custom SQL-based dbt Tests

#### 1. Data Freshness Test
```sql
-- tests/test_data_freshness.sql
-- Test to ensure data is loaded within acceptable time window

SELECT 
    source_table,
    MAX(load_timestamp) as latest_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
FROM {{ ref('bz_data_audit') }}
WHERE status = 'SUCCESS'
GROUP BY source_table
HAVING hours_since_load > 24  -- Fail if data is older than 24 hours
```

#### 2. Referential Integrity Test
```sql
-- tests/test_referential_integrity.sql
-- Test to ensure all foreign key relationships are valid

WITH orphaned_meetings AS (
    SELECT meeting_id, host_id
    FROM {{ ref('bz_meetings') }} m
    LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
    WHERE u.user_id IS NULL
),

orphaned_participants AS (
    SELECT participant_id, meeting_id, user_id
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
    LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
    WHERE m.meeting_id IS NULL OR u.user_id IS NULL
)

SELECT 'orphaned_meetings' as issue_type, COUNT(*) as count FROM orphaned_meetings
UNION ALL
SELECT 'orphaned_participants' as issue_type, COUNT(*) as count FROM orphaned_participants
HAVING count > 0
```

#### 3. Data Quality Completeness Test
```sql
-- tests/test_data_completeness.sql
-- Test to ensure critical fields have acceptable completeness rates

WITH completeness_check AS (
    SELECT 
        'bz_users' as table_name,
        'email' as column_name,
        COUNT(*) as total_records,
        COUNT(email) as non_null_records,
        (COUNT(email) * 100.0 / COUNT(*)) as completeness_rate
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        'duration_minutes' as column_name,
        COUNT(*) as total_records,
        COUNT(duration_minutes) as non_null_records,
        (COUNT(duration_minutes) * 100.0 / COUNT(*)) as completeness_rate
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        'amount' as column_name,
        COUNT(*) as total_records,
        COUNT(amount) as non_null_records,
        (COUNT(amount) * 100.0 / COUNT(*)) as completeness_rate
    FROM {{ ref('bz_billing_events') }}
)

SELECT *
FROM completeness_check
WHERE completeness_rate < 95  -- Fail if completeness is below 95%
```

#### 4. Business Logic Validation Test
```sql
-- tests/test_business_logic.sql
-- Test to validate business rules and logic

WITH business_rule_violations AS (
    -- Test 1: Meeting duration should not exceed 24 hours
    SELECT 
        'meeting_duration_exceeded' as rule_violation,
        meeting_id,
        duration_minutes
    FROM {{ ref('bz_meetings') }}
    WHERE duration_minutes > 1440
    
    UNION ALL
    
    -- Test 2: Participant join time should be within meeting timeframe
    SELECT 
        'participant_join_outside_meeting' as rule_violation,
        p.participant_id,
        p.join_time
    FROM {{ ref('bz_participants') }} p
    JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE p.join_time < m.start_time 
       OR (m.end_time IS NOT NULL AND p.join_time > m.end_time)
    
    UNION ALL
    
    -- Test 3: Billing amounts should be reasonable
    SELECT 
        'unreasonable_billing_amount' as rule_violation,
        event_id,
        amount
    FROM {{ ref('bz_billing_events') }}
    WHERE amount > 10000 OR amount < 0
    
    UNION ALL
    
    -- Test 4: License end date should be after start date
    SELECT 
        'invalid_license_dates' as rule_violation,
        license_id,
        start_date
    FROM {{ ref('bz_licenses') }}
    WHERE end_date IS NOT NULL AND end_date < start_date
)

SELECT *
FROM business_rule_violations
```

#### 5. Duplicate Detection Test
```sql
-- tests/test_duplicate_detection.sql
-- Test to detect potential duplicates that shouldn't exist

WITH duplicate_users AS (
    SELECT email, COUNT(*) as count
    FROM {{ ref('bz_users') }}
    WHERE email IS NOT NULL
    GROUP BY email
    HAVING COUNT(*) > 1
),

duplicate_meetings AS (
    SELECT host_id, start_time, COUNT(*) as count
    FROM {{ ref('bz_meetings') }}
    GROUP BY host_id, start_time
    HAVING COUNT(*) > 1
)

SELECT 'duplicate_users' as issue_type, email as identifier, count
FROM duplicate_users
UNION ALL
SELECT 'duplicate_meetings' as issue_type, 
       CONCAT(host_id, '_', start_time) as identifier, 
       count
FROM duplicate_meetings
```

#### 6. Performance Monitoring Test
```sql
-- tests/test_performance_monitoring.sql
-- Test to monitor model performance and processing times

SELECT 
    source_table,
    AVG(processing_time) as avg_processing_time,
    MAX(processing_time) as max_processing_time,
    COUNT(*) as execution_count
FROM {{ ref('bz_data_audit') }}
WHERE status = 'SUCCESS'
  AND load_timestamp >= CURRENT_DATE - 7  -- Last 7 days
GROUP BY source_table
HAVING max_processing_time > 300  -- Fail if any execution takes more than 5 minutes
```

### Parameterized Tests

#### Generic Test for Accepted Values with Custom Logic
```sql
-- macros/test_accepted_values_with_null.sql
{% macro test_accepted_values_with_null(model, column_name, values, allow_null=true) %}

SELECT {{ column_name }}
FROM {{ model }}
WHERE 
    {% if allow_null %}
        {{ column_name }} IS NOT NULL AND
    {% endif %}
    {{ column_name }} NOT IN (
        {% for value in values %}
            '{{ value }}'
            {%- if not loop.last -%},{%- endif -%}
        {% endfor %}
    )

{% endmacro %}
```

#### Generic Test for Date Range Validation
```sql
-- macros/test_date_range_validation.sql
{% macro test_date_range_validation(model, start_date_column, end_date_column, allow_null_end=true) %}

SELECT *
FROM {{ model }}
WHERE 
    {{ start_date_column }} IS NOT NULL
    {% if allow_null_end %}
        AND {{ end_date_column }} IS NOT NULL
    {% endif %}
    AND {{ end_date_column }} < {{ start_date_column }}

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all tests before deployment
dbt test --models bronze

# Run specific test categories
dbt test --models bronze --select test_type:schema
dbt test --models bronze --select test_type:data
```

### 2. Continuous Integration Testing
```bash
# Run tests on specific models
dbt test --models bz_users bz_meetings

# Run tests with specific severity
dbt test --models bronze --warn-error
```

### 3. Production Monitoring
```bash
# Daily data quality checks
dbt test --models bronze --select tag:daily_check

# Performance monitoring
dbt test --models bronze --select tag:performance
```

## Test Results Tracking

All test results are automatically tracked in:
- **dbt's run_results.json**: Contains detailed test execution results
- **Snowflake audit schema**: Custom audit tables for tracking test history
- **BZ_DATA_AUDIT table**: Bronze layer specific audit trail

## Maintenance and Updates

1. **Weekly Review**: Review test results and update thresholds as needed
2. **Monthly Analysis**: Analyze test performance and add new test cases
3. **Quarterly Assessment**: Comprehensive review of test coverage and effectiveness
4. **Version Control**: All test changes tracked through Git with proper documentation

---

## Conclusion

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze layer dbt models in Snowflake. The combination of schema tests, custom SQL tests, and business logic validation provides robust coverage for all critical data pipeline components.

Regular execution of these tests will help maintain high data quality standards and catch potential issues early in the development cycle, ensuring consistent and reliable data delivery to downstream consumers.