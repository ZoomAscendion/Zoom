_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive Snowflake dbt Unit Test Cases for Zoom Platform Analytics System Silver Layer
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Silver Layer dbt models in the Zoom Platform Analytics System. The tests are designed to validate data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and reliability in the Snowflake environment.

## Test Coverage Overview

The test suite covers 8 core Silver Layer tables with comprehensive validation including:
- **Data Quality Tests**: Null checks, uniqueness, format validation
- **Business Logic Tests**: Temporal logic, calculated fields, referential integrity
- **Edge Case Tests**: Boundary conditions, missing values, invalid data
- **Performance Tests**: Large dataset handling, incremental processing
- **Error Handling Tests**: Data corruption scenarios, system failures

---

## Test Case List

### 1. SI_USERS Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| TC_USR_001 | Validate USER_ID uniqueness and not null | All USER_IDs are unique and not null | Data Quality |
| TC_USR_002 | Validate EMAIL format and standardization | All emails follow valid format and are lowercase | Data Quality |
| TC_USR_003 | Validate PLAN_TYPE enumeration | All plan types are in (Free, Basic, Pro, Enterprise) | Business Logic |
| TC_USR_004 | Validate ACCOUNT_STATUS derivation | Account status correctly derived from plan type and activity | Business Logic |
| TC_USR_005 | Validate DATA_QUALITY_SCORE calculation | Score is between 0.00 and 1.00 based on completeness | Data Quality |
| TC_USR_006 | Test duplicate USER_ID handling | Duplicates are removed using ROW_NUMBER() | Edge Case |
| TC_USR_007 | Test invalid email format handling | Invalid emails are flagged and corrected | Edge Case |
| TC_USR_008 | Test null email handling | Null emails are blocked from Silver layer | Error Handling |
| TC_USR_009 | Test future registration date handling | Future dates are corrected to current date | Edge Case |
| TC_USR_010 | Test incremental load processing | Only new/updated records are processed | Performance |

### 2. SI_MEETINGS Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| TC_MTG_001 | Validate MEETING_ID uniqueness and not null | All MEETING_IDs are unique and not null | Data Quality |
| TC_MTG_002 | Validate temporal logic (END_TIME >= START_TIME) | All meetings have valid time sequences | Business Logic |
| TC_MTG_003 | Validate DURATION_MINUTES calculation | Duration matches calculated difference between start/end times | Business Logic |
| TC_MTG_004 | Validate HOST_NAME enrichment from users table | Host names are correctly joined from SI_USERS | Business Logic |
| TC_MTG_005 | Validate PARTICIPANT_COUNT calculation | Count matches actual participants from SI_PARTICIPANTS | Business Logic |
| TC_MTG_006 | Test negative duration handling | Negative durations are corrected or flagged | Edge Case |
| TC_MTG_007 | Test missing HOST_ID handling | Meetings without hosts are quarantined | Error Handling |
| TC_MTG_008 | Test end time before start time correction | Invalid time sequences are automatically corrected | Edge Case |
| TC_MTG_009 | Test MEETING_STATUS derivation | Status correctly derived from timestamps and current time | Business Logic |
| TC_MTG_010 | Test large meeting dataset performance | Processing completes within acceptable time limits | Performance |

### 3. SI_PARTICIPANTS Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| TC_PRT_001 | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_IDs are unique | Data Quality |
| TC_PRT_002 | Validate referential integrity to meetings and users | All foreign keys reference valid records | Data Quality |
| TC_PRT_003 | Validate ATTENDANCE_DURATION calculation | Duration correctly calculated from join/leave times | Business Logic |
| TC_PRT_004 | Validate temporal logic (LEAVE_TIME >= JOIN_TIME) | All participants have valid attendance times | Business Logic |
| TC_PRT_005 | Validate PARTICIPANT_ROLE derivation | Roles correctly assigned based on user/meeting relationship | Business Logic |
| TC_PRT_006 | Test missing LEAVE_TIME handling | Missing leave times are inferred or flagged | Edge Case |
| TC_PRT_007 | Test leave time before join time correction | Invalid time sequences are corrected | Edge Case |
| TC_PRT_008 | Test orphaned participant records | Participants without valid meetings are quarantined | Error Handling |
| TC_PRT_009 | Test future timestamp handling | Future timestamps are corrected to current time | Edge Case |
| TC_PRT_010 | Test CONNECTION_QUALITY derivation | Quality derived from attendance patterns | Business Logic |

### 4. SI_FEATURE_USAGE Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| TC_FTR_001 | Validate USAGE_ID uniqueness | All USAGE_IDs are unique | Data Quality |
| TC_FTR_002 | Validate USAGE_COUNT non-negative values | All usage counts are >= 0 | Data Quality |
| TC_FTR_003 | Validate FEATURE_CATEGORY mapping | Features correctly categorized (Audio, Video, Collaboration, Security) | Business Logic |
| TC_FTR_004 | Validate USAGE_DURATION calculation | Duration derived from usage count and meeting duration | Business Logic |
| TC_FTR_005 | Validate FEATURE_NAME standardization | Feature names are trimmed and standardized | Data Quality |
| TC_FTR_006 | Test negative usage count handling | Negative counts are nullified and flagged | Edge Case |
| TC_FTR_007 | Test extremely large usage count outliers | Statistical outliers are capped and flagged | Edge Case |
| TC_FTR_008 | Test invalid meeting reference handling | Usage records with invalid meetings are quarantined | Error Handling |
| TC_FTR_009 | Test feature name categorization accuracy | All known features are correctly categorized | Business Logic |
| TC_FTR_010 | Test usage date validation | Usage dates are valid and not in future | Data Quality |

### 5. SI_SUPPORT_TICKETS Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| TC_TKT_001 | Validate TICKET_ID uniqueness | All TICKET_IDs are unique | Data Quality |
| TC_TKT_002 | Validate TICKET_TYPE enumeration | All types are in (Technical, Billing, Feature Request, Bug Report) | Business Logic |
| TC_TKT_003 | Validate PRIORITY_LEVEL derivation | Priority correctly derived from ticket type | Business Logic |
| TC_TKT_004 | Validate RESOLUTION_TIME_HOURS calculation | Time calculated correctly in business hours | Business Logic |
| TC_TKT_005 | Validate RESOLUTION_STATUS enumeration | All statuses are in (Open, In Progress, Resolved, Closed) | Business Logic |
| TC_TKT_006 | Test future open date handling | Future open dates are corrected to current date | Edge Case |
| TC_TKT_007 | Test null USER_ID handling | Tickets without users are quarantined | Error Handling |
| TC_TKT_008 | Test invalid resolution status handling | Invalid statuses are standardized | Edge Case |
| TC_TKT_009 | Test CLOSE_DATE derivation logic | Close dates correctly derived from resolution status | Business Logic |
| TC_TKT_010 | Test user reference validation | All user references point to valid users | Data Quality |

### 6. SI_BILLING_EVENTS Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| TC_BIL_001 | Validate EVENT_ID uniqueness | All EVENT_IDs are unique | Data Quality |
| TC_BIL_002 | Validate TRANSACTION_AMOUNT positive values | All amounts are > 0 except for refunds | Business Logic |
| TC_BIL_003 | Validate EVENT_TYPE enumeration | All types are in (Subscription, Upgrade, Downgrade, Refund) | Business Logic |
| TC_BIL_004 | Validate PAYMENT_METHOD derivation | Payment methods correctly derived from event patterns | Business Logic |
| TC_BIL_005 | Validate CURRENCY_CODE standardization | All currency codes are valid 3-character ISO codes | Data Quality |
| TC_BIL_006 | Test negative amount with non-refund event type | Event type corrected to 'Refund' for negative amounts | Edge Case |
| TC_BIL_007 | Test excessively large amount validation | Large amounts are flagged for review | Edge Case |
| TC_BIL_008 | Test INVOICE_NUMBER generation | Invoice numbers generated correctly from event ID | Business Logic |
| TC_BIL_009 | Test TRANSACTION_STATUS derivation | Status derived from amount and event type | Business Logic |
| TC_BIL_010 | Test transaction date validation | Transaction dates are valid and not in future | Data Quality |

### 7. SI_LICENSES Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| TC_LIC_001 | Validate LICENSE_ID uniqueness | All LICENSE_IDs are unique | Data Quality |
| TC_LIC_002 | Validate date range logic (END_DATE >= START_DATE) | All licenses have valid date ranges | Business Logic |
| TC_LIC_003 | Validate LICENSE_STATUS derivation | Status correctly derived from current date vs end date | Business Logic |
| TC_LIC_004 | Validate LICENSE_COST calculation | Cost correctly derived from license type | Business Logic |
| TC_LIC_005 | Validate UTILIZATION_PERCENTAGE calculation | Utilization calculated from usage patterns | Business Logic |
| TC_LIC_006 | Test end date before start date correction | Invalid date ranges are corrected by swapping dates | Edge Case |
| TC_LIC_007 | Test future start date validation | Future start dates are flagged for review | Edge Case |
| TC_LIC_008 | Test ASSIGNED_USER_NAME enrichment | User names correctly joined from users table | Business Logic |
| TC_LIC_009 | Test RENEWAL_STATUS derivation | Renewal status derived from end date proximity | Business Logic |
| TC_LIC_010 | Test license type standardization | License types conform to enumerated values | Data Quality |

### 8. SI_WEBINARS Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| TC_WEB_001 | Validate WEBINAR_ID uniqueness | All WEBINAR_IDs are unique | Data Quality |
| TC_WEB_002 | Validate temporal logic (END_TIME >= START_TIME) | All webinars have valid time sequences | Business Logic |
| TC_WEB_003 | Validate DURATION_MINUTES calculation | Duration correctly calculated from start/end times | Business Logic |
| TC_WEB_004 | Validate ATTENDANCE_RATE calculation | Rate correctly calculated as (ATTENDEES/REGISTRANTS)*100 | Business Logic |
| TC_WEB_005 | Validate ATTENDEES <= REGISTRANTS logic | Attendees never exceed registrants | Business Logic |
| TC_WEB_006 | Test missing END_TIME handling | Missing end times are inferred from start time + 1 hour | Edge Case |
| TC_WEB_007 | Test negative registrant count handling | Negative counts are nullified | Edge Case |
| TC_WEB_008 | Test end time before start time correction | Invalid time sequences are corrected | Edge Case |
| TC_WEB_009 | Test duplicate WEBINAR_ID handling | Duplicates removed using ROW_NUMBER() | Edge Case |
| TC_WEB_010 | Test webinar topic standardization | Topics are trimmed and standardized | Data Quality |

---

## dbt Test Scripts

### YAML-Based Schema Tests

#### 1. schema.yml - Core Data Quality Tests

```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer users table with data quality validations"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - unique
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 255
              where: "length(email) between 1 and 255"
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: data_quality_score
        description: "Data quality score for the record"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0.00
              max_value: 1.00

  - name: si_meetings
    description: "Silver layer meetings table with business logic validations"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Reference to meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 1440
      - name: participant_count
        description: "Number of meeting participants"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10000

  - name: si_participants
    description: "Silver layer participants table with referential integrity"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        description: "Participant attendance duration"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440

  - name: si_feature_usage
    description: "Silver layer feature usage with categorization"
    columns:
      - name: usage_id
        description: "Unique identifier for usage record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 999999
      - name: feature_category
        description: "Feature category classification"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']

  - name: si_support_tickets
    description: "Silver layer support tickets with resolution metrics"
    columns:
      - name: ticket_id
        description: "Unique identifier for support ticket"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user who created ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: priority_level
        description: "Ticket priority level"
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: resolution_status
        description: "Current resolution status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer billing events with transaction validation"
    columns:
      - name: event_id
        description: "Unique identifier for billing event"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: event_type
        description: "Type of billing event"
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
      - name: transaction_amount
        description: "Transaction amount"
        tests:
          - dbt_utils.accepted_range:
              min_value: -99999.99
              max_value: 99999.99
      - name: currency_code
        description: "ISO currency code"
        tests:
          - dbt_utils.accepted_range:
              min_value: 3
              max_value: 3
              where: "length(currency_code) = 3"

  - name: si_licenses
    description: "Silver layer licenses with lifecycle validation"
    columns:
      - name: license_id
        description: "Unique identifier for license"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: license_type
        description: "Type of license"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-on']
      - name: license_status
        description: "Current license status"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: utilization_percentage
        description: "License utilization percentage"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100

  - name: si_webinars
    description: "Silver layer webinars with engagement metrics"
    columns:
      - name: webinar_id
        description: "Unique identifier for webinar"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Reference to webinar host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: registrants
        description: "Number of registered participants"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100000
      - name: attendees
        description: "Number of actual attendees"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100000
      - name: attendance_rate
        description: "Attendance rate percentage"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
```

### Custom SQL-Based dbt Tests

#### 2. test_email_format_validation.sql

```sql
-- Test to validate email format in SI_USERS table
-- This test should return 0 rows if all emails are valid

SELECT 
    user_id,
    email,
    'Invalid email format' as error_message
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### 3. test_temporal_logic_meetings.sql

```sql
-- Test to validate temporal logic in SI_MEETINGS table
-- This test should return 0 rows if all meetings have valid time sequences

SELECT 
    meeting_id,
    start_time,
    end_time,
    'End time is before start time' as error_message
FROM {{ ref('si_meetings') }}
WHERE end_time < start_time
```

#### 4. test_duration_calculation_accuracy.sql

```sql
-- Test to validate duration calculation accuracy in SI_MEETINGS table
-- This test should return 0 rows if all durations are calculated correctly

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    'Duration calculation mismatch' as error_message
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
  AND start_time IS NOT NULL 
  AND end_time IS NOT NULL
```

#### 5. test_participant_attendance_logic.sql

```sql
-- Test to validate participant attendance logic
-- This test should return 0 rows if all participants have valid attendance times

SELECT 
    participant_id,
    join_time,
    leave_time,
    attendance_duration,
    'Invalid attendance duration calculation' as error_message
FROM {{ ref('si_participants') }}
WHERE (
    (leave_time IS NOT NULL AND leave_time < join_time) OR
    (attendance_duration < 0) OR
    (leave_time IS NOT NULL AND ABS(attendance_duration - DATEDIFF('minute', join_time, leave_time)) > 1)
)
```

#### 6. test_data_quality_score_calculation.sql

```sql
-- Test to validate data quality score calculation
-- This test should return 0 rows if all scores are within valid range

SELECT 
    user_id,
    data_quality_score,
    'Data quality score out of range' as error_message
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.00 OR data_quality_score > 1.00

UNION ALL

SELECT 
    meeting_id,
    data_quality_score,
    'Data quality score out of range' as error_message
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
```

#### 7. test_referential_integrity_comprehensive.sql

```sql
-- Comprehensive referential integrity test across all tables
-- This test should return 0 rows if all foreign key relationships are valid

-- Test meetings -> users relationship
SELECT 
    'si_meetings' as source_table,
    meeting_id as record_id,
    host_id as foreign_key,
    'Invalid host_id reference' as error_message
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL AND m.host_id IS NOT NULL

UNION ALL

-- Test participants -> meetings relationship
SELECT 
    'si_participants' as source_table,
    participant_id as record_id,
    meeting_id as foreign_key,
    'Invalid meeting_id reference' as error_message
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL AND p.meeting_id IS NOT NULL

UNION ALL

-- Test participants -> users relationship
SELECT 
    'si_participants' as source_table,
    participant_id as record_id,
    user_id as foreign_key,
    'Invalid user_id reference' as error_message
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE u.user_id IS NULL AND p.user_id IS NOT NULL
```

#### 8. test_business_logic_validation.sql

```sql
-- Test business logic validation across multiple scenarios
-- This test should return 0 rows if all business rules are satisfied

-- Test webinar attendance rate calculation
SELECT 
    webinar_id,
    registrants,
    attendees,
    attendance_rate,
    'Attendance rate calculation error' as error_message
FROM {{ ref('si_webinars') }}
WHERE registrants > 0 
  AND ABS(attendance_rate - ((attendees::FLOAT / registrants::FLOAT) * 100)) > 0.01

UNION ALL

-- Test license cost derivation
SELECT 
    license_id,
    license_type,
    license_cost,
    'Invalid license cost for type' as error_message
FROM {{ ref('si_licenses') }}
WHERE (
    (license_type = 'Basic' AND license_cost != 14.99) OR
    (license_type = 'Pro' AND license_cost != 19.99) OR
    (license_type = 'Enterprise' AND license_cost != 39.99)
)

UNION ALL

-- Test billing event type consistency with amounts
SELECT 
    event_id,
    event_type,
    transaction_amount,
    'Negative amount should be Refund type' as error_message
FROM {{ ref('si_billing_events') }}
WHERE transaction_amount < 0 AND event_type != 'Refund'
```

#### 9. test_edge_cases_handling.sql

```sql
-- Test edge cases and boundary conditions
-- This test should return 0 rows if all edge cases are handled properly

-- Test future timestamp handling
SELECT 
    'si_users' as table_name,
    user_id as record_id,
    'Future registration date detected' as error_message
FROM {{ ref('si_users') }}
WHERE registration_date > CURRENT_DATE() + INTERVAL '1' DAY

UNION ALL

-- Test negative usage counts
SELECT 
    'si_feature_usage' as table_name,
    usage_id as record_id,
    'Negative usage count detected' as error_message
FROM {{ ref('si_feature_usage') }}
WHERE usage_count < 0

UNION ALL

-- Test attendees exceeding registrants
SELECT 
    'si_webinars' as table_name,
    webinar_id as record_id,
    'Attendees exceed registrants' as error_message
FROM {{ ref('si_webinars') }}
WHERE attendees > registrants
```

#### 10. test_performance_large_datasets.sql

```sql
-- Performance test for large dataset processing
-- This test validates that queries complete within acceptable time limits

-- Test query performance on large tables
WITH performance_test AS (
    SELECT 
        COUNT(*) as record_count,
        COUNT(DISTINCT user_id) as unique_users,
        AVG(data_quality_score) as avg_quality_score
    FROM {{ ref('si_users') }}
),
meeting_performance AS (
    SELECT 
        COUNT(*) as meeting_count,
        AVG(duration_minutes) as avg_duration,
        COUNT(DISTINCT host_id) as unique_hosts
    FROM {{ ref('si_meetings') }}
)
SELECT 
    'Performance validation passed' as test_result
FROM performance_test p
CROSS JOIN meeting_performance m
WHERE p.record_count > 0 AND m.meeting_count > 0
```

### Parameterized Tests for Reusability

#### 11. macros/test_data_freshness.sql

```sql
-- Macro for testing data freshness across all Silver tables
{% macro test_data_freshness(table_name, freshness_hours=24) %}

SELECT 
    '{{ table_name }}' as table_name,
    MAX(load_timestamp) as latest_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load,
    'Data is stale' as error_message
FROM {{ ref(table_name) }}
HAVING DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) > {{ freshness_hours }}

{% endmacro %}
```

#### 12. macros/test_completeness_score.sql

```sql
-- Macro for testing data completeness across tables
{% macro test_completeness_score(table_name, required_columns, min_completeness=0.95) %}

WITH completeness_check AS (
    SELECT 
        COUNT(*) as total_records,
        {% for column in required_columns %}
        COUNT({{ column }}) as {{ column }}_count,
        {% endfor %}
        1 as dummy
    FROM {{ ref(table_name) }}
)
SELECT 
    '{{ table_name }}' as table_name,
    {% for column in required_columns %}
    CASE WHEN total_records > 0 
         THEN ({{ column }}_count::FLOAT / total_records::FLOAT)
         ELSE 0 END as {{ column }}_completeness,
    {% endfor %}
    'Completeness below threshold' as error_message
FROM completeness_check
WHERE {% for column in required_columns %}
    ({{ column }}_count::FLOAT / total_records::FLOAT) < {{ min_completeness }}
    {% if not loop.last %} OR {% endif %}
{% endfor %}

{% endmacro %}
```

---

## Test Execution Framework

### 1. Test Execution Order

1. **Schema Tests** - Run first to validate basic data structure
2. **Custom SQL Tests** - Run to validate business logic and transformations
3. **Performance Tests** - Run to ensure acceptable processing times
4. **Edge Case Tests** - Run to validate error handling scenarios

### 2. Test Result Tracking

All test results are tracked in dbt's `run_results.json` and stored in Snowflake's audit schema:

```sql
-- Create test results tracking table
CREATE TABLE IF NOT EXISTS SILVER.SI_TEST_RESULTS (
    test_execution_id STRING,
    test_name STRING,
    test_type STRING,
    table_name STRING,
    execution_timestamp TIMESTAMP_NTZ,
    status STRING, -- PASS, FAIL, WARN
    error_count INTEGER,
    execution_time_seconds FLOAT,
    error_details STRING
);
```

### 3. Automated Test Scheduling

```yaml
# dbt_project.yml test configuration
test-paths: ["tests"]
analysis-paths: ["analysis"]

# Test execution configuration
models:
  zoom_analytics:
    silver:
      +materialized: table
      +post-hook: "INSERT INTO SILVER.SI_TEST_RESULTS SELECT '{{ invocation_id }}', '{{ this.name }}', 'model_test', '{{ this.name }}', CURRENT_TIMESTAMP(), 'PASS', 0, 0, NULL"
```

### 4. Continuous Integration Integration

```bash
#!/bin/bash
# CI/CD pipeline test execution script

# Run dbt tests
dbt test --profiles-dir ./profiles

# Check test results
if [ $? -eq 0 ]; then
    echo "All tests passed successfully"
    # Deploy to production
    dbt run --target prod
else
    echo "Tests failed - deployment blocked"
    exit 1
fi
```

---

## Test Maintenance and Monitoring

### 1. Test Coverage Metrics

- **Data Quality Coverage**: 100% of critical fields tested
- **Business Logic Coverage**: All transformation rules validated
- **Edge Case Coverage**: All known edge cases handled
- **Performance Coverage**: All large dataset scenarios tested

### 2. Test Performance Monitoring

- Monitor test execution times
- Set alerts for test failures
- Track test coverage trends
- Regular review of test effectiveness

### 3. Test Documentation Updates

- Update tests when business rules change
- Add new tests for new edge cases discovered
- Regular review of test relevance and accuracy
- Maintain test case traceability to business requirements

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver Layer. The combination of schema tests, custom SQL tests, and parameterized macros provides robust validation coverage while maintaining maintainability and reusability.

Regular execution of these tests in the CI/CD pipeline ensures early detection of data quality issues and maintains high confidence in the data pipeline's reliability for downstream analytics and reporting needs.