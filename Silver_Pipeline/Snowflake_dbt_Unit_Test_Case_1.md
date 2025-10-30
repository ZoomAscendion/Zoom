_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Silver Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Silver Layer transformation pipeline. The tests cover data quality validations, business rule implementations, edge cases, and error handling scenarios for all silver layer models including audit_log, si_users, si_meetings, si_participants, si_feature_usage, si_support_tickets, si_billing_events, si_licenses, and si_webinars.

## Test Case Overview

### Models Under Test
1. **audit_log** - Pipeline execution tracking
2. **si_users** - User account data transformation
3. **si_meetings** - Meeting session data processing
4. **si_participants** - Participant attendance tracking
5. **si_feature_usage** - Feature utilization analytics
6. **si_support_tickets** - Customer support data
7. **si_billing_events** - Financial transaction processing
8. **si_licenses** - License management data
9. **si_webinars** - Webinar engagement metrics

---

## Test Case List

### 1. Audit Log Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| AL_001 | Validate execution_id uniqueness | All execution_id values are unique |
| AL_002 | Verify pipeline_name not null | No null values in pipeline_name column |
| AL_003 | Check status accepted values | Status only contains: SUCCESS, FAILED, STARTED, COMPLETED |
| AL_004 | Validate timestamp consistency | start_time <= end_time for all records |
| AL_005 | Test incremental loading | Only new records added based on start_time |

### 2. SI_Users Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SU_001 | Validate user_id uniqueness | All user_id values are unique and not null |
| SU_002 | Email format validation | All email addresses follow valid format pattern |
| SU_003 | Plan type standardization | Plan_type only contains: FREE, BASIC, PRO, ENTERPRISE |
| SU_004 | Account status validation | Account_status only contains: Active, Inactive, Suspended |
| SU_005 | Data quality score range | Data_quality_score between 0 and 1 |
| SU_006 | Deduplication logic | Latest record per user_id based on update_timestamp |
| SU_007 | Email case standardization | All emails converted to lowercase |
| SU_008 | Name capitalization | User names properly capitalized |
| SU_009 | Registration date validation | Registration_date <= current_date |
| SU_010 | Incremental processing | Only updated records processed |

### 3. SI_Meetings Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SM_001 | Validate meeting_id uniqueness | All meeting_id values are unique and not null |
| SM_002 | Host relationship validation | All host_id values exist in si_users |
| SM_003 | Duration calculation accuracy | Duration_minutes = DATEDIFF(start_time, end_time) |
| SM_004 | Meeting type classification | Meeting_type correctly derived from duration and topic |
| SM_005 | Meeting status logic | Status correctly calculated based on timestamps |
| SM_006 | Duration range validation | Duration_minutes between 0 and 1440 |
| SM_007 | Participant count accuracy | Participant_count matches actual participants |
| SM_008 | Data quality score calculation | Score reflects completeness and validity |
| SM_009 | Time validation | End_time >= start_time for all meetings |
| SM_010 | Incremental loading | Only new/updated meetings processed |

### 4. SI_Participants Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SP_001 | Validate participant_id uniqueness | All participant_id values are unique |
| SP_002 | Meeting relationship validation | All meeting_id values exist in si_meetings |
| SP_003 | User relationship validation | All user_id values exist in si_users |
| SP_004 | Attendance duration calculation | Duration = DATEDIFF(join_time, leave_time) |
| SP_005 | Participant role validation | Role contains: Host, Co-host, Participant, Observer |
| SP_006 | Connection quality validation | Quality contains: Excellent, Good, Fair, Poor |
| SP_007 | Time sequence validation | Leave_time >= join_time |
| SP_008 | Duration range validation | Attendance_duration between 0 and 1440 |
| SP_009 | Host role consistency | Host role matches meeting host_id |
| SP_010 | Data completeness | All required fields populated |

### 5. SI_Feature_Usage Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SF_001 | Validate usage_id uniqueness | All usage_id values are unique |
| SF_002 | Meeting relationship validation | All meeting_id values exist in si_meetings |
| SF_003 | Feature categorization | Categories: Audio, Video, Collaboration, Security |
| SF_004 | Usage count validation | Usage_count >= 0 and <= 1000 |
| SF_005 | Feature name standardization | Feature names converted to uppercase |
| SF_006 | Usage date validation | Usage_date <= current_date |
| SF_007 | Duration estimation | Usage_duration calculated from usage_count |
| SF_008 | Category mapping accuracy | Features correctly categorized |
| SF_009 | Data quality scoring | Score reflects data completeness |
| SF_010 | Incremental processing | Only new usage records processed |

### 6. SI_Support_Tickets Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| ST_001 | Validate ticket_id uniqueness | All ticket_id values are unique |
| ST_002 | User relationship validation | All user_id values exist in si_users |
| ST_003 | Ticket type validation | Types: Technical, Billing, Feature Request, Bug Report |
| ST_004 | Priority level validation | Levels: Low, Medium, High, Critical |
| ST_005 | Resolution status validation | Status: Open, In Progress, Resolved, Closed |
| ST_006 | Priority derivation logic | Priority correctly derived from ticket_type |
| ST_007 | Resolution time calculation | Time calculated for resolved tickets |
| ST_008 | Date validation | Open_date <= current_date |
| ST_009 | Close date logic | Close_date populated for resolved tickets |
| ST_010 | Data quality assessment | Quality score reflects completeness |

### 7. SI_Billing_Events Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SB_001 | Validate event_id uniqueness | All event_id values are unique |
| SB_002 | User relationship validation | All user_id values exist in si_users |
| SB_003 | Event type validation | Types: Subscription, Upgrade, Downgrade, Refund |
| SB_004 | Amount validation | Transaction_amount between 0 and 10000 |
| SB_005 | Currency code validation | Currency: USD, EUR, GBP, CAD |
| SB_006 | Invoice number generation | Invoice numbers follow pattern INV-{event_id}-{year} |
| SB_007 | Transaction status logic | Status derived from amount value |
| SB_008 | Amount sign validation | Positive amounts for non-refund transactions |
| SB_009 | Date validation | Transaction_date <= current_date |
| SB_010 | Financial data integrity | All monetary values properly validated |

### 8. SI_Licenses Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SL_001 | Validate license_id uniqueness | All license_id values are unique |
| SL_002 | License type validation | Types: BASIC, PRO, ENTERPRISE, ADD-ON |
| SL_003 | License status validation | Status: Active, Expired, Suspended |
| SL_004 | Cost validation | License_cost between 0 and 1000 |
| SL_005 | Utilization percentage validation | Utilization between 0 and 100 |
| SL_006 | Date range validation | Start_date <= end_date |
| SL_007 | Status derivation logic | Status correctly calculated from dates |
| SL_008 | Cost mapping accuracy | Costs correctly mapped to license types |
| SL_009 | User assignment validation | Assigned users exist in si_users |
| SL_010 | Data quality scoring | Quality reflects data completeness |

### 9. SI_Webinars Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SW_001 | Validate webinar_id uniqueness | All webinar_id values are unique |
| SW_002 | Host relationship validation | All host_id values exist in si_users |
| SW_003 | Duration calculation | Duration_minutes = DATEDIFF(start_time, end_time) |
| SW_004 | Registrant validation | Registrants between 0 and 10000 |
| SW_005 | Attendee validation | Attendees between 0 and 10000 |
| SW_006 | Attendance rate calculation | Rate = (attendees/registrants) * 100 |
| SW_007 | Attendee logic validation | Attendees <= registrants |
| SW_008 | Duration range validation | Duration between 0 and 1440 minutes |
| SW_009 | Time sequence validation | End_time > start_time |
| SW_010 | Data quality assessment | Quality score reflects completeness |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  # Audit Log Tests
  - name: audit_log
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - execution_id
            - pipeline_name
    columns:
      - name: execution_id
        tests:
          - not_null
          - unique
      - name: pipeline_name
        tests:
          - not_null
      - name: status
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'STARTED', 'COMPLETED']
      - name: start_time
        tests:
          - not_null
      - name: end_time
        tests:
          - not_null

  # SI_Users Tests
  - name: si_users
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
    columns:
      - name: user_id
        tests:
          - not_null
          - unique
      - name: email
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
      - name: plan_type
        tests:
          - not_null
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: account_status
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1
      - name: registration_date
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date

  # SI_Meetings Tests
  - name: si_meetings
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
    columns:
      - name: meeting_id
        tests:
          - not_null
          - unique
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: meeting_type
        tests:
          - not_null
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
      - name: meeting_status
        tests:
          - not_null
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
      - name: participant_count
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  # SI_Participants Tests
  - name: si_participants
    columns:
      - name: participant_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: participant_role
        tests:
          - not_null
          - accepted_values:
              values: ['Host', 'Co-host', 'Participant', 'Observer']
      - name: connection_quality
        tests:
          - not_null
          - accepted_values:
              values: ['Excellent', 'Good', 'Fair', 'Poor']

  # SI_Feature_Usage Tests
  - name: si_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000
      - name: feature_category
        tests:
          - not_null
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']

  # SI_Support_Tickets Tests
  - name: si_support_tickets
    columns:
      - name: ticket_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        tests:
          - not_null
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: priority_level
        tests:
          - not_null
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  # SI_Billing_Events Tests
  - name: si_billing_events
    columns:
      - name: event_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: event_type
        tests:
          - not_null
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
      - name: transaction_amount
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: currency_code
        tests:
          - not_null
          - accepted_values:
              values: ['USD', 'EUR', 'GBP', 'CAD']

  # SI_Licenses Tests
  - name: si_licenses
    columns:
      - name: license_id
        tests:
          - not_null
          - unique
      - name: license_type
        tests:
          - not_null
          - accepted_values:
              values: ['BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON']
      - name: license_status
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: license_cost
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000
      - name: utilization_percentage
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  # SI_Webinars Tests
  - name: si_webinars
    columns:
      - name: webinar_id
        tests:
          - not_null
          - unique
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: registrants
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: attendees
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: attendance_rate
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
```

### Custom SQL-based dbt Tests

#### 1. Time Consistency Tests

```sql
-- tests/time_consistency_audit_log.sql
-- Test that start_time <= end_time in audit_log
SELECT 
    execution_id,
    start_time,
    end_time
FROM {{ ref('audit_log') }}
WHERE start_time > end_time
```

```sql
-- tests/time_consistency_meetings.sql
-- Test that start_time < end_time in meetings
SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE start_time >= end_time
```

```sql
-- tests/time_consistency_participants.sql
-- Test that join_time <= leave_time in participants
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE join_time > leave_time
```

#### 2. Business Logic Tests

```sql
-- tests/meeting_duration_calculation.sql
-- Verify meeting duration calculation accuracy
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('si_meetings') }}
WHERE duration_minutes != DATEDIFF('minute', start_time, end_time)
```

```sql
-- tests/participant_attendance_calculation.sql
-- Verify participant attendance duration calculation
SELECT 
    participant_id,
    attendance_duration,
    DATEDIFF('minute', join_time, leave_time) AS calculated_duration
FROM {{ ref('si_participants') }}
WHERE attendance_duration != GREATEST(DATEDIFF('minute', join_time, leave_time), 0)
```

```sql
-- tests/webinar_attendance_rate_calculation.sql
-- Verify webinar attendance rate calculation
SELECT 
    webinar_id,
    attendance_rate,
    CASE 
        WHEN registrants > 0 
        THEN ROUND((attendees::FLOAT / registrants * 100), 2)
        ELSE 0.00
    END AS calculated_rate
FROM {{ ref('si_webinars') }}
WHERE attendance_rate != CASE 
    WHEN registrants > 0 
    THEN ROUND((attendees::FLOAT / registrants * 100), 2)
    ELSE 0.00
END
```

#### 3. Data Quality Tests

```sql
-- tests/email_format_validation.sql
-- Validate email format in si_users
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

```sql
-- tests/data_quality_score_validation.sql
-- Validate data quality scores are within expected range
SELECT 
    'si_users' AS model_name,
    user_id AS record_id,
    data_quality_score
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 
    'si_meetings' AS model_name,
    meeting_id AS record_id,
    data_quality_score
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 
    'si_participants' AS model_name,
    participant_id AS record_id,
    data_quality_score
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0 OR data_quality_score > 1
```

#### 4. Referential Integrity Tests

```sql
-- tests/orphaned_meetings.sql
-- Check for meetings with invalid host references
SELECT 
    m.meeting_id,
    m.host_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL
```

```sql
-- tests/orphaned_participants.sql
-- Check for participants with invalid meeting or user references
SELECT 
    p.participant_id,
    p.meeting_id,
    p.user_id
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE m.meeting_id IS NULL OR u.user_id IS NULL
```

#### 5. Incremental Loading Tests

```sql
-- tests/incremental_loading_validation.sql
-- Validate incremental loading logic
WITH max_timestamps AS (
    SELECT 
        'si_users' AS model_name,
        MAX(update_timestamp) AS max_update_timestamp
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'si_meetings' AS model_name,
        MAX(update_timestamp) AS max_update_timestamp
    FROM {{ ref('si_meetings') }}
    
    UNION ALL
    
    SELECT 
        'si_participants' AS model_name,
        MAX(update_timestamp) AS max_update_timestamp
    FROM {{ ref('si_participants') }}
)

SELECT 
    model_name,
    max_update_timestamp
FROM max_timestamps
WHERE max_update_timestamp IS NULL
```

#### 6. Edge Case Tests

```sql
-- tests/zero_duration_meetings.sql
-- Check for meetings with zero or negative duration
SELECT 
    meeting_id,
    duration_minutes,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE duration_minutes <= 0
```

```sql
-- tests/future_dates_validation.sql
-- Check for invalid future dates
SELECT 
    'si_users' AS model_name,
    user_id AS record_id,
    registration_date AS date_field
FROM {{ ref('si_users') }}
WHERE registration_date > CURRENT_DATE()

UNION ALL

SELECT 
    'si_support_tickets' AS model_name,
    ticket_id AS record_id,
    open_date AS date_field
FROM {{ ref('si_support_tickets') }}
WHERE open_date > CURRENT_DATE()
```

#### 7. Deduplication Tests

```sql
-- tests/duplicate_users.sql
-- Check for duplicate users after deduplication
SELECT 
    user_id,
    COUNT(*) AS duplicate_count
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

```sql
-- tests/duplicate_meetings.sql
-- Check for duplicate meetings after deduplication
SELECT 
    meeting_id,
    COUNT(*) AS duplicate_count
FROM {{ ref('si_meetings') }}
GROUP BY meeting_id
HAVING COUNT(*) > 1
```

### Parameterized Tests

```sql
-- macros/test_data_quality_score_range.sql
{% macro test_data_quality_score_range(model, column_name) %}
    SELECT 
        *
    FROM {{ model }}
    WHERE {{ column_name }} < 0 OR {{ column_name }} > 1
{% endmacro %}
```

```sql
-- macros/test_timestamp_consistency.sql
{% macro test_timestamp_consistency(model, start_col, end_col) %}
    SELECT 
        *
    FROM {{ model }}
    WHERE {{ start_col }} > {{ end_col }}
{% endmacro %}
```

### Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users

# Run specific test type
dbt test --select test_type:schema
dbt test --select test_type:data

# Run tests with specific tags
dbt test --select tag:data_quality
dbt test --select tag:referential_integrity

# Run tests in fail-fast mode
dbt test --fail-fast

# Generate test documentation
dbt docs generate
dbt docs serve
```

### Test Results Tracking

The test results are automatically tracked in:
- **dbt's run_results.json**: Contains detailed test execution results
- **Snowflake audit schema**: Custom audit tables for test result history
- **dbt Cloud/dbt Core logs**: Comprehensive logging of test execution

### Monitoring and Alerting

1. **Test Failure Alerts**: Configure alerts for test failures in production
2. **Data Quality Dashboards**: Monitor data quality scores and trends
3. **Test Coverage Reports**: Track test coverage across all models
4. **Performance Monitoring**: Monitor test execution times and resource usage

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Silver Layer dbt models in Snowflake. The tests cover:

- **Data Quality**: Validation of data formats, ranges, and completeness
- **Business Logic**: Verification of calculations and transformations
- **Referential Integrity**: Ensuring proper relationships between models
- **Edge Cases**: Handling of null values, empty datasets, and boundary conditions
- **Performance**: Incremental loading and processing efficiency
- **Compliance**: Data governance and audit requirements

Regular execution of these tests will help maintain high data quality standards and catch issues early in the development cycle, ensuring reliable data delivery to downstream consumers.