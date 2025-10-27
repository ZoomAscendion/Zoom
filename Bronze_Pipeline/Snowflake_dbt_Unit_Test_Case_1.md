_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer Pipeline that transforms data from RAW schema to BRONZE schema in Snowflake. The pipeline includes 9 models: bz_audit_log, bz_billing_events, bz_feature_usage, bz_licenses, bz_meetings, bz_participants, bz_support_tickets, bz_users, and bz_webinars.

## Test Strategy

The testing approach covers:
- **Data Quality**: Validation of data types, null constraints, and business rules
- **Transformation Logic**: Verification of data transformations and mappings
- **Edge Cases**: Handling of null values, empty datasets, and invalid data
- **Performance**: Ensuring models execute efficiently in Snowflake
- **Audit Trail**: Validation of audit logging functionality

---

## Test Case List

### 1. Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_DQ_001 | Validate user_id is not null in bz_billing_events | All records have valid user_id |
| TC_DQ_002 | Validate event_type is not null in bz_billing_events | All records have valid event_type |
| TC_DQ_003 | Validate amount is positive in bz_billing_events | All amounts are greater than 0 |
| TC_DQ_004 | Validate meeting_id is not null in bz_feature_usage | All records have valid meeting_id |
| TC_DQ_005 | Validate feature_name is not null in bz_feature_usage | All records have valid feature_name |
| TC_DQ_006 | Validate usage_count is non-negative in bz_feature_usage | All usage counts are >= 0 |
| TC_DQ_007 | Validate license_type is not null in bz_licenses | All records have valid license_type |
| TC_DQ_008 | Validate start_date <= end_date in bz_licenses | All license periods are valid |
| TC_DQ_009 | Validate host_id is not null in bz_meetings | All records have valid host_id |
| TC_DQ_010 | Validate meeting_topic is not null in bz_meetings | All records have valid meeting_topic |
| TC_DQ_011 | Validate start_time <= end_time in bz_meetings | All meeting times are logical |
| TC_DQ_012 | Validate duration_minutes is positive in bz_meetings | All durations are greater than 0 |
| TC_DQ_013 | Validate meeting_id is not null in bz_participants | All records have valid meeting_id |
| TC_DQ_014 | Validate user_id is not null in bz_participants | All records have valid user_id |
| TC_DQ_015 | Validate join_time <= leave_time in bz_participants | All participation times are logical |
| TC_DQ_016 | Validate user_id is not null in bz_support_tickets | All records have valid user_id |
| TC_DQ_017 | Validate ticket_type is not null in bz_support_tickets | All records have valid ticket_type |
| TC_DQ_018 | Validate resolution_status in accepted values | Status is in ['Open', 'In Progress', 'Resolved', 'Closed'] |
| TC_DQ_019 | Validate user_name is not null in bz_users | All records have valid user_name |
| TC_DQ_020 | Validate email format in bz_users | All emails follow valid format |
| TC_DQ_021 | Validate plan_type in accepted values | Plan type is in ['Basic', 'Pro', 'Business', 'Enterprise'] |
| TC_DQ_022 | Validate host_id is not null in bz_webinars | All records have valid host_id |
| TC_DQ_023 | Validate webinar_topic is not null in bz_webinars | All records have valid webinar_topic |
| TC_DQ_024 | Validate registrants is non-negative in bz_webinars | All registrant counts are >= 0 |

### 2. Transformation Logic Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TL_001 | Verify data type casting for amount in bz_billing_events | Amount is NUMBER(10,2) |
| TC_TL_002 | Verify data type casting for event_date in bz_billing_events | Event_date is DATE |
| TC_TL_003 | Verify data type casting for usage_count in bz_feature_usage | Usage_count is NUMBER(38,0) |
| TC_TL_004 | Verify data type casting for usage_date in bz_feature_usage | Usage_date is DATE |
| TC_TL_005 | Verify data type casting for start_date in bz_licenses | Start_date is DATE |
| TC_TL_006 | Verify data type casting for end_date in bz_licenses | End_date is DATE |
| TC_TL_007 | Verify data type casting for start_time in bz_meetings | Start_time is TIMESTAMP_NTZ |
| TC_TL_008 | Verify data type casting for end_time in bz_meetings | End_time is TIMESTAMP_NTZ |
| TC_TL_009 | Verify data type casting for duration_minutes in bz_meetings | Duration_minutes is NUMBER(38,0) |
| TC_TL_010 | Verify data type casting for join_time in bz_participants | Join_time is TIMESTAMP_NTZ |
| TC_TL_011 | Verify data type casting for leave_time in bz_participants | Leave_time is TIMESTAMP_NTZ |
| TC_TL_012 | Verify data type casting for open_date in bz_support_tickets | Open_date is DATE |
| TC_TL_013 | Verify data type casting for registrants in bz_webinars | Registrants is NUMBER(38,0) |
| TC_TL_014 | Verify string field casting to STRING type | All string fields are properly cast |
| TC_TL_015 | Verify timestamp field casting to TIMESTAMP_NTZ | All timestamp fields are properly cast |

### 3. Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_EC_001 | Handle null values in non-critical fields | Records processed with null handling |
| TC_EC_002 | Handle empty string values | Empty strings converted to null or default |
| TC_EC_003 | Handle future dates in event_date | Future dates accepted if valid |
| TC_EC_004 | Handle zero amounts in billing_events | Zero amounts handled per business rules |
| TC_EC_005 | Handle negative usage_count | Negative values filtered out |
| TC_EC_006 | Handle expired licenses | Expired licenses included with proper dates |
| TC_EC_007 | Handle meetings with null end_time | Ongoing meetings handled appropriately |
| TC_EC_008 | Handle participants with null leave_time | Active participants handled appropriately |
| TC_EC_009 | Handle invalid email formats | Invalid emails flagged or corrected |
| TC_EC_010 | Handle duplicate records | Duplicates handled per business rules |

### 4. Audit Trail Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AT_001 | Verify audit log creation for bz_billing_events | Audit records created for processing |
| TC_AT_002 | Verify audit log creation for bz_feature_usage | Audit records created for processing |
| TC_AT_003 | Verify audit log creation for bz_licenses | Audit records created for processing |
| TC_AT_004 | Verify audit log creation for bz_meetings | Audit records created for processing |
| TC_AT_005 | Verify audit log creation for bz_participants | Audit records created for processing |
| TC_AT_006 | Verify audit log creation for bz_support_tickets | Audit records created for processing |
| TC_AT_007 | Verify audit log creation for bz_users | Audit records created for processing |
| TC_AT_008 | Verify audit log creation for bz_webinars | Audit records created for processing |
| TC_AT_009 | Verify processing time calculation | Processing times calculated correctly |
| TC_AT_010 | Verify status tracking | Status updates tracked properly |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  - name: bz_billing_events
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: user_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: event_type
        tests:
          - not_null
          - accepted_values:
              values: ['payment', 'refund', 'subscription', 'upgrade', 'downgrade']
      - name: amount
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: event_date
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "<= CURRENT_DATE()"

  - name: bz_feature_usage
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: meeting_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: feature_name
        tests:
          - not_null
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard', 'polls']
      - name: usage_count
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: usage_date
        tests:
          - not_null

  - name: bz_licenses
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: license_type
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: assigned_to_user_id
        tests:
          - not_null
      - name: start_date
        tests:
          - not_null
      - name: end_date
        tests:
          - not_null
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= end_date"

  - name: bz_meetings
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: host_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: meeting_topic
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: start_time
        tests:
          - not_null
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "> 0"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time <= end_time OR end_time IS NULL"

  - name: bz_participants
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
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
    tests:
      - dbt_utils.expression_is_true:
          expression: "join_time <= leave_time OR leave_time IS NULL"

  - name: bz_support_tickets
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: user_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: ticket_type
        tests:
          - not_null
          - accepted_values:
              values: ['technical', 'billing', 'feature_request', 'bug_report', 'general']
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
      - name: open_date
        tests:
          - not_null

  - name: bz_users
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: user_name
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: email
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: plan_type
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']

  - name: bz_webinars
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: host_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: webinar_topic
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: start_time
        tests:
          - not_null
      - name: registrants
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time <= end_time OR end_time IS NULL"

  - name: bz_audit_log
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: record_id
        tests:
          - not_null
          - unique
      - name: source_table
        tests:
          - not_null
          - accepted_values:
              values: ['bz_billing_events', 'bz_feature_usage', 'bz_licenses', 'bz_meetings', 'bz_participants', 'bz_support_tickets', 'bz_users', 'bz_webinars']
      - name: load_timestamp
        tests:
          - not_null
      - name: status
        tests:
          - not_null
          - accepted_values:
              values: ['PROCESSING_STARTED', 'PROCESSING_COMPLETED', 'ERROR']
```

### Custom SQL-based dbt Tests

#### 1. Email Format Validation Test

```sql
-- tests/test_email_format_validation.sql
-- Test to validate email format in bz_users table

SELECT 
    email,
    COUNT(*) as invalid_email_count
FROM {{ ref('bz_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
GROUP BY email
HAVING COUNT(*) > 0
```

#### 2. Data Freshness Test

```sql
-- tests/test_data_freshness.sql
-- Test to ensure data is not older than 7 days

SELECT 
    source_table,
    MAX(load_timestamp) as latest_load,
    DATEDIFF('day', MAX(load_timestamp), CURRENT_TIMESTAMP()) as days_old
FROM {{ ref('bz_audit_log') }}
GROUP BY source_table
HAVING DATEDIFF('day', MAX(load_timestamp), CURRENT_TIMESTAMP()) > 7
```

#### 3. Cross-Table Referential Integrity Test

```sql
-- tests/test_referential_integrity_meetings_participants.sql
-- Test to ensure all participants have valid meeting references

SELECT 
    p.meeting_id,
    COUNT(*) as orphaned_participants
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.host_id  -- Note: This assumes meeting_id maps to host_id
WHERE m.host_id IS NULL
GROUP BY p.meeting_id
HAVING COUNT(*) > 0
```

#### 4. Business Logic Validation Test

```sql
-- tests/test_meeting_duration_consistency.sql
-- Test to ensure calculated duration matches actual duration

SELECT 
    host_id,
    meeting_topic,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as duration_difference
FROM {{ ref('bz_meetings') }}
WHERE end_time IS NOT NULL
  AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 5  -- Allow 5 minute tolerance
```

#### 5. Data Quality Completeness Test

```sql
-- tests/test_data_completeness.sql
-- Test to check data completeness across all bronze tables

WITH completeness_check AS (
    SELECT 
        'bz_billing_events' as table_name,
        COUNT(*) as total_records,
        COUNT(user_id) as non_null_user_id,
        COUNT(event_type) as non_null_event_type,
        COUNT(amount) as non_null_amount
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'bz_users' as table_name,
        COUNT(*) as total_records,
        COUNT(user_name) as non_null_user_name,
        COUNT(email) as non_null_email,
        COUNT(plan_type) as non_null_plan_type
    FROM {{ ref('bz_users') }}
)

SELECT 
    table_name,
    total_records,
    CASE 
        WHEN table_name = 'bz_billing_events' THEN 
            CASE WHEN non_null_user_id < total_records OR 
                      non_null_event_type < total_records OR 
                      non_null_amount < total_records 
                 THEN 'INCOMPLETE' 
                 ELSE 'COMPLETE' 
            END
        WHEN table_name = 'bz_users' THEN 
            CASE WHEN non_null_user_name < total_records OR 
                      non_null_email < total_records OR 
                      non_null_plan_type < total_records 
                 THEN 'INCOMPLETE' 
                 ELSE 'COMPLETE' 
            END
    END as completeness_status
FROM completeness_check
WHERE CASE 
        WHEN table_name = 'bz_billing_events' THEN 
            CASE WHEN non_null_user_id < total_records OR 
                      non_null_event_type < total_records OR 
                      non_null_amount < total_records 
                 THEN 'INCOMPLETE' 
                 ELSE 'COMPLETE' 
            END
        WHEN table_name = 'bz_users' THEN 
            CASE WHEN non_null_user_name < total_records OR 
                      non_null_email < total_records OR 
                      non_null_plan_type < total_records 
                 THEN 'INCOMPLETE' 
                 ELSE 'COMPLETE' 
            END
    END = 'INCOMPLETE'
```

#### 6. Audit Trail Validation Test

```sql
-- tests/test_audit_trail_validation.sql
-- Test to ensure audit trail is properly maintained

SELECT 
    source_table,
    COUNT(*) as audit_records,
    COUNT(CASE WHEN status = 'PROCESSING_STARTED' THEN 1 END) as started_records,
    COUNT(CASE WHEN status = 'PROCESSING_COMPLETED' THEN 1 END) as completed_records,
    COUNT(CASE WHEN status = 'ERROR' THEN 1 END) as error_records
FROM {{ ref('bz_audit_log') }}
GROUP BY source_table
HAVING COUNT(CASE WHEN status = 'PROCESSING_STARTED' THEN 1 END) != 
       COUNT(CASE WHEN status = 'PROCESSING_COMPLETED' THEN 1 END)
```

### Parameterized Tests

#### Generic Test for Positive Values

```sql
-- macros/test_positive_values.sql
{% macro test_positive_values(model, column_name) %}

SELECT 
    {{ column_name }},
    COUNT(*) as negative_value_count
FROM {{ model }}
WHERE {{ column_name }} < 0
GROUP BY {{ column_name }}
HAVING COUNT(*) > 0

{% endmacro %}
```

#### Generic Test for Date Range Validation

```sql
-- macros/test_date_range.sql
{% macro test_date_range(model, start_date_column, end_date_column) %}

SELECT 
    {{ start_date_column }},
    {{ end_date_column }},
    COUNT(*) as invalid_date_range_count
FROM {{ model }}
WHERE {{ start_date_column }} > {{ end_date_column }}
GROUP BY {{ start_date_column }}, {{ end_date_column }}
HAVING COUNT(*) > 0

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Execute custom SQL tests to validate business logic
- Verify audit trail functionality
- Check data quality and completeness

### 2. Post-deployment Validation
- Monitor audit logs for processing status
- Validate data freshness and completeness
- Check referential integrity across tables
- Verify performance metrics

### 3. Continuous Monitoring
- Schedule regular test execution
- Set up alerts for test failures
- Monitor data quality trends
- Track processing performance

## Expected Test Results

### Success Criteria
- All schema tests pass with 100% success rate
- Custom SQL tests return zero failing records
- Audit trail shows complete processing for all tables
- Data quality metrics meet defined thresholds
- Processing times remain within acceptable limits

### Failure Handling
- Failed tests trigger immediate alerts
- Error records logged in audit trail
- Data quality issues flagged for investigation
- Processing stopped for critical failures
- Rollback procedures activated when necessary

## Performance Considerations

### Snowflake Optimization
- Use appropriate warehouse sizes for test execution
- Leverage Snowflake's automatic clustering for large tables
- Implement result caching for repeated test runs
- Monitor credit consumption during test execution

### Test Efficiency
- Group related tests for batch execution
- Use sampling for large dataset validation
- Implement incremental testing for changed data only
- Optimize test queries for performance

---

## Conclusion

This comprehensive unit testing framework ensures the reliability, performance, and data quality of the Zoom Bronze Layer dbt models in Snowflake. The combination of schema tests, custom SQL tests, and audit trail validation provides robust coverage for all transformation logic, business rules, and edge cases. Regular execution of these tests will maintain high data quality standards and prevent production issues.

The testing framework is designed to be maintainable, scalable, and aligned with dbt best practices, ensuring long-term success of the Zoom Bronze Pipeline in the Snowflake environment.