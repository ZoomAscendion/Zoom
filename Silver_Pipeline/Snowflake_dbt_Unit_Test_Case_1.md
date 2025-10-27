_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive Snowflake dbt Unit Test Cases for Zoom Silver Layer Pipeline
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Silver Layer Pipeline

## Description

This document contains comprehensive unit test cases and dbt test scripts for the Zoom Silver Layer Pipeline that runs in Snowflake. The tests cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Case Overview

The test suite covers the following Silver Layer models:
- `si_users` - User profile data with email validation and segmentation
- `si_meetings` - Meeting data with duration validation and categorization
- `si_participants` - Participant attendance data with engagement metrics
- `si_billing_events` - Billing and payment event data with amount validation
- `si_licenses` - License management data with lifecycle tracking
- `si_feature_usage` - Feature utilization data with usage patterns
- `si_support_tickets` - Support ticket data with resolution metrics
- `si_webinars` - Webinar data with attendance analytics
- `audit_log` - Pipeline execution audit trail

## Test Case List

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| TC_SU_001 | Email Format Validation | si_users | All emails follow RFC 5322 format |
| TC_SU_002 | User Name Not Null Validation | si_users | No null or empty user names |
| TC_SU_003 | Plan Type Validation | si_users | Plan types are within allowed values |
| TC_SU_004 | Email Uniqueness Validation | si_users | No duplicate email addresses |
| TC_SU_005 | Data Quality Score Calculation | si_users | Scores between 0.00-1.00 |
| TC_SM_001 | Meeting Duration Validation | si_meetings | Duration ≤ 1440 minutes (24 hours) |
| TC_SM_002 | Start/End Time Logic Validation | si_meetings | End time ≥ start time |
| TC_SM_003 | Host ID Referential Integrity | si_meetings | All hosts exist in users table |
| TC_SM_004 | Meeting Topic Length Validation | si_meetings | Topic length ≤ 255 characters |
| TC_SM_005 | Business Hours Flag Accuracy | si_meetings | Correct business hours classification |
| TC_SP_001 | Join/Leave Time Logic Validation | si_participants | Leave time ≥ join time |
| TC_SP_002 | Attendance Duration Calculation | si_participants | Duration matches time difference |
| TC_SP_003 | Attendance Percentage Range | si_participants | Percentage between 0-100% |
| TC_SP_004 | Engagement Score Validation | si_participants | Score between 0.00-1.00 |
| TC_SP_005 | Meeting-Participant Relationship | si_participants | All participants linked to valid meetings |
| TC_SB_001 | Billing Amount Validation | si_billing_events | Amounts > 0 and ≤ 10,000 |
| TC_SB_002 | Event Type Standardization | si_billing_events | Event types are standardized |
| TC_SB_003 | Currency Code Validation | si_billing_events | Valid ISO currency codes |
| TC_SB_004 | Event Date Logic Validation | si_billing_events | Event dates not in future |
| TC_SB_005 | User-Billing Relationship | si_billing_events | All billing events linked to valid users |
| TC_SL_001 | License Period Validation | si_licenses | End date ≥ start date |
| TC_SL_002 | License Type Validation | si_licenses | Valid license types only |
| TC_SL_003 | License Status Validation | si_licenses | Valid status values only |
| TC_SL_004 | Duration Calculation Accuracy | si_licenses | Correct duration calculation |
| TC_SF_001 | Usage Count Validation | si_feature_usage | Non-negative usage counts |
| TC_SF_002 | Feature Name Standardization | si_feature_usage | Consistent feature naming |
| TC_SF_003 | Feature Category Validation | si_feature_usage | Valid category assignments |
| TC_ST_001 | Ticket Type Validation | si_support_tickets | Valid ticket types only |
| TC_ST_002 | Resolution Status Validation | si_support_tickets | Valid status values only |
| TC_ST_003 | Date Logic Validation | si_support_tickets | Close date ≥ open date |
| TC_ST_004 | SLA Compliance Calculation | si_support_tickets | Accurate SLA breach flags |
| TC_SW_001 | Webinar Duration Validation | si_webinars | Duration ≤ 1440 minutes |
| TC_SW_002 | Registrant Count Validation | si_webinars | Non-negative registrant counts |
| TC_SW_003 | Attendance Rate Calculation | si_webinars | Accurate attendance rate |
| TC_AL_001 | Audit Log Completeness | audit_log | All pipeline executions logged |
| TC_AL_002 | Execution Status Validation | audit_log | Valid status values only |

## dbt Test Scripts

### 1. Schema Tests (schema.yml)

```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer users table with cleansed and standardized user data"
    columns:
      - name: user_id
        description: "Unique identifier for user"
        tests:
          - unique
          - not_null
      - name: user_name
        description: "User display name"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_not_be_null
      - name: email
        description: "User email address (validated and standardized)"
        tests:
          - not_null
          - unique
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "User subscription plan type"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: data_quality_score
        description: "Data quality score (0.00-1.00)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 1.00

  - name: si_meetings
    description: "Silver layer meetings table with cleansed meeting data"
    columns:
      - name: meeting_id
        description: "Unique identifier for meeting"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: meeting_topic
        description: "Meeting topic/title"
        tests:
          - not_null
          - dbt_expectations.expect_column_value_lengths_to_be_between:
              min_value: 1
              max_value: 255
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: data_quality_score
        description: "Data quality score (0.00-1.00)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 1.00

  - name: si_participants
    description: "Silver layer participants table with attendance analytics"
    columns:
      - name: participant_id
        description: "Unique identifier for participant"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Associated meeting ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Participant user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_percentage
        description: "Attendance percentage (0-100%)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 100.00
      - name: engagement_score
        description: "Engagement score (0.00-1.00)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 1.00

  - name: si_billing_events
    description: "Silver layer billing events with standardized payment data"
    columns:
      - name: billing_event_id
        description: "Unique identifier for billing event"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Associated user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: amount
        description: "Transaction amount"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.01
              max_value: 10000.00
      - name: event_type
        description: "Standardized event type"
        tests:
          - accepted_values:
              values: ['Payment', 'Refund', 'Subscription', 'Upgrade', 'Downgrade']
      - name: currency_code
        description: "ISO currency code"
        tests:
          - not_null
          - dbt_expectations.expect_column_value_lengths_to_equal:
              value: 3

  - name: audit_log
    description: "Silver layer audit log for tracking pipeline executions"
    columns:
      - name: audit_id
        description: "Unique identifier for audit record"
        tests:
          - unique
          - not_null
      - name: pipeline_name
        description: "Name of the pipeline being executed"
        tests:
          - not_null
      - name: execution_status
        description: "Status of pipeline execution"
        tests:
          - accepted_values:
              values: ['INITIALIZED', 'STARTED', 'RUNNING', 'COMPLETED', 'FAILED']
```

### 2. Custom SQL-Based Tests

#### Test: Email Format Validation (tests/test_email_format_validation.sql)
```sql
-- Test to ensure all email addresses follow RFC 5322 format
SELECT 
    user_id,
    email,
    'Invalid email format' as error_message
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test: Meeting Duration Validation (tests/test_meeting_duration_validation.sql)
```sql
-- Test to ensure meeting durations don't exceed 24 hours (1440 minutes)
SELECT 
    meeting_id,
    duration_minutes,
    start_time,
    end_time,
    'Meeting duration exceeds 24 hours' as error_message
FROM {{ ref('si_meetings') }}
WHERE duration_minutes > 1440 
   OR duration_minutes < 0
```

#### Test: Start/End Time Logic Validation (tests/test_meeting_time_logic.sql)
```sql
-- Test to ensure meeting end times are after start times
SELECT 
    meeting_id,
    start_time,
    end_time,
    'End time is before or equal to start time' as error_message
FROM {{ ref('si_meetings') }}
WHERE end_time IS NOT NULL 
  AND start_time IS NOT NULL 
  AND end_time <= start_time
```

#### Test: Join/Leave Time Logic Validation (tests/test_participant_time_logic.sql)
```sql
-- Test to ensure participants leave after they join
SELECT 
    participant_id,
    join_time,
    leave_time,
    'Leave time is before or equal to join time' as error_message
FROM {{ ref('si_participants') }}
WHERE leave_time IS NOT NULL 
  AND join_time IS NOT NULL 
  AND leave_time <= join_time
```

#### Test: Attendance Duration Consistency (tests/test_attendance_duration_consistency.sql)
```sql
-- Test to validate attendance duration calculation accuracy
SELECT 
    participant_id,
    attendance_duration_minutes,
    DATEDIFF(minute, join_time, leave_time) as calculated_duration,
    'Attendance duration inconsistent with join/leave times' as error_message
FROM {{ ref('si_participants') }}
WHERE leave_time IS NOT NULL 
  AND join_time IS NOT NULL
  AND ABS(attendance_duration_minutes - DATEDIFF(minute, join_time, leave_time)) > 1
```

#### Test: Billing Amount Validation (tests/test_billing_amount_validation.sql)
```sql
-- Test to ensure billing amounts are positive and within reasonable ranges
SELECT 
    billing_event_id,
    amount,
    event_type,
    'Invalid billing amount' as error_message
FROM {{ ref('si_billing_events') }}
WHERE amount <= 0 
   OR amount > 10000
```

#### Test: License Period Validation (tests/test_license_period_validation.sql)
```sql
-- Test to ensure license end dates are after start dates
SELECT 
    license_id,
    start_date,
    end_date,
    'License end date is before or equal to start date' as error_message
FROM {{ ref('si_licenses') }}
WHERE end_date IS NOT NULL 
  AND start_date IS NOT NULL 
  AND end_date <= start_date
```

#### Test: Data Quality Score Range Validation (tests/test_data_quality_score_range.sql)
```sql
-- Test to ensure data quality scores are within valid range (0.00-1.00)
WITH quality_score_validation AS (
    SELECT 'si_users' as table_name, user_id as record_id, data_quality_score
    FROM {{ ref('si_users') }}
    WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
    
    UNION ALL
    
    SELECT 'si_meetings' as table_name, meeting_id as record_id, data_quality_score
    FROM {{ ref('si_meetings') }}
    WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
    
    UNION ALL
    
    SELECT 'si_participants' as table_name, participant_id as record_id, data_quality_score
    FROM {{ ref('si_participants') }}
    WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
    
    UNION ALL
    
    SELECT 'si_billing_events' as table_name, billing_event_id as record_id, data_quality_score
    FROM {{ ref('si_billing_events') }}
    WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
)
SELECT 
    table_name,
    record_id,
    data_quality_score,
    'Data quality score out of valid range (0.00-1.00)' as error_message
FROM quality_score_validation
```

#### Test: Cross-Table Referential Integrity (tests/test_referential_integrity.sql)
```sql
-- Test to ensure referential integrity across Silver layer tables
WITH referential_integrity_violations AS (
    -- Meeting-Participant relationship
    SELECT 
        'si_participants' as source_table,
        p.participant_id as record_id,
        'meeting_id' as foreign_key_column,
        p.meeting_id as foreign_key_value,
        'Meeting ID not found in si_meetings' as error_message
    FROM {{ ref('si_participants') }} p
    LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL
    
    UNION ALL
    
    -- Feature Usage-Meeting relationship
    SELECT 
        'si_feature_usage' as source_table,
        f.feature_usage_id as record_id,
        'meeting_id' as foreign_key_column,
        f.meeting_id as foreign_key_value,
        'Meeting ID not found in si_meetings' as error_message
    FROM {{ ref('si_feature_usage') }} f
    LEFT JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL
    
    UNION ALL
    
    -- User-License relationship
    SELECT 
        'si_licenses' as source_table,
        l.license_id as record_id,
        'assigned_to_user_id' as foreign_key_column,
        l.assigned_to_user_id as foreign_key_value,
        'User ID not found in si_users' as error_message
    FROM {{ ref('si_licenses') }} l
    LEFT JOIN {{ ref('si_users') }} u ON l.assigned_to_user_id = u.user_id
    WHERE u.user_id IS NULL
)
SELECT * FROM referential_integrity_violations
```

### 3. Parameterized Tests

#### Macro: Generic Range Validation (macros/test_column_range.sql)
```sql
{% macro test_column_range(model, column_name, min_value, max_value) %}

SELECT 
    {{ column_name }},
    '{{ column_name }} value out of range ({{ min_value }} - {{ max_value }})' as error_message
FROM {{ model }}
WHERE {{ column_name }} < {{ min_value }} 
   OR {{ column_name }} > {{ max_value }}

{% endmacro %}
```

#### Macro: Generic Date Logic Validation (macros/test_date_logic.sql)
```sql
{% macro test_date_logic(model, start_date_column, end_date_column) %}

SELECT 
    {{ start_date_column }},
    {{ end_date_column }},
    '{{ end_date_column }} is before {{ start_date_column }}' as error_message
FROM {{ model }}
WHERE {{ end_date_column }} IS NOT NULL 
  AND {{ start_date_column }} IS NOT NULL 
  AND {{ end_date_column }} < {{ start_date_column }}

{% endmacro %}
```

### 4. Edge Case Tests

#### Test: Null Value Handling (tests/test_null_value_handling.sql)
```sql
-- Test to identify records with unexpected null values in critical fields
WITH null_value_checks AS (
    SELECT 
        'si_users' as table_name,
        user_id as record_id,
        'user_name' as column_name,
        'Critical field is null' as error_message
    FROM {{ ref('si_users') }}
    WHERE user_name IS NULL OR TRIM(user_name) = ''
    
    UNION ALL
    
    SELECT 
        'si_meetings' as table_name,
        meeting_id as record_id,
        'meeting_topic' as column_name,
        'Critical field is null' as error_message
    FROM {{ ref('si_meetings') }}
    WHERE meeting_topic IS NULL OR TRIM(meeting_topic) = ''
    
    UNION ALL
    
    SELECT 
        'si_billing_events' as table_name,
        billing_event_id as record_id,
        'amount' as column_name,
        'Critical field is null' as error_message
    FROM {{ ref('si_billing_events') }}
    WHERE amount IS NULL
)
SELECT * FROM null_value_checks
```

#### Test: Empty Dataset Handling (tests/test_empty_dataset_handling.sql)
```sql
-- Test to ensure models handle empty source datasets gracefully
WITH table_counts AS (
    SELECT 'si_users' as table_name, COUNT(*) as record_count FROM {{ ref('si_users') }}
    UNION ALL
    SELECT 'si_meetings' as table_name, COUNT(*) as record_count FROM {{ ref('si_meetings') }}
    UNION ALL
    SELECT 'si_participants' as table_name, COUNT(*) as record_count FROM {{ ref('si_participants') }}
    UNION ALL
    SELECT 'si_billing_events' as table_name, COUNT(*) as record_count FROM {{ ref('si_billing_events') }}
)
SELECT 
    table_name,
    record_count,
    'Table is empty - may indicate data pipeline issue' as warning_message
FROM table_counts
WHERE record_count = 0
```

### 5. Performance Tests

#### Test: Model Execution Time Monitoring (tests/test_model_performance.sql)
```sql
-- Test to monitor model execution performance
-- This would typically be implemented as part of the dbt run monitoring
SELECT 
    'Performance monitoring placeholder' as test_type,
    'Monitor execution time for each model' as description,
    'Implement using dbt artifacts and run_results.json' as implementation_note
```

## Test Execution Strategy

### 1. Test Categories

- **Unit Tests**: Individual model validation
- **Integration Tests**: Cross-model relationship validation
- **Data Quality Tests**: Business rule and constraint validation
- **Performance Tests**: Execution time and resource usage monitoring
- **Edge Case Tests**: Null handling, empty datasets, boundary conditions

### 2. Test Execution Schedule

- **Pre-deployment**: All tests must pass before production deployment
- **Daily**: Automated execution of critical data quality tests
- **Weekly**: Comprehensive test suite execution
- **On-demand**: Manual test execution for troubleshooting

### 3. Test Result Tracking

- Results logged to `dbt_test_results` table
- Integration with Snowflake audit schema
- Automated alerting for test failures
- Dashboard for test result visualization

## Error Handling and Remediation

### 1. Test Failure Classification

- **Critical**: Data integrity violations, referential integrity failures
- **High**: Business rule violations, data quality score issues
- **Medium**: Format violations, range check failures
- **Low**: Warning conditions, performance degradation

### 2. Automated Remediation

- Data quality score recalculation
- Automatic retry for transient failures
- Error logging to `Si_DATA_QUALITY_ERRORS` table
- Notification to data engineering team

### 3. Manual Intervention

- Critical failures require immediate attention
- Data correction procedures for business rule violations
- Source system investigation for persistent issues
- Documentation updates for new edge cases

## Conclusion

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Silver Layer Pipeline in Snowflake. The tests validate key transformations, business rules, edge cases, and error handling scenarios to maintain high-quality data for analytics and reporting purposes.

Regular execution and monitoring of these tests will help identify issues early in the development cycle, enhance maintainability, and prevent production failures while ensuring consistent and reliable data delivery.