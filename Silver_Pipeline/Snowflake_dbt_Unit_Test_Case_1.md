_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive Snowflake dbt Unit Test Cases for Zoom Platform Analytics Silver Layer Pipeline
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics Silver Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer Pipeline. The tests validate data transformations, business rules, edge cases, and error handling across all Silver layer models including si_users, si_meetings, si_participants, si_feature_usage, si_support_tickets, si_billing_events, si_licenses, si_webinars, and si_audit_log.

## Test Strategy

The testing approach covers:
- **Happy Path Testing**: Valid data transformations and business logic
- **Edge Case Testing**: Boundary conditions, null values, and data quality scenarios
- **Error Handling**: Invalid data, constraint violations, and referential integrity
- **Performance Testing**: Large datasets and complex transformations
- **Data Quality Validation**: Completeness, accuracy, consistency, and validity

---

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate user email format standardization | All emails converted to lowercase and validated against regex pattern |
| TC_USR_002 | Test user name standardization (TRIM and UPPER) | User names properly formatted with consistent casing |
| TC_USR_003 | Validate plan type enumeration | Only valid plan types (Free, Basic, Pro, Enterprise) allowed |
| TC_USR_004 | Test data quality score calculation | Scores calculated correctly based on completeness and validity |
| TC_USR_005 | Validate deduplication logic | Only latest record per USER_ID retained |
| TC_USR_006 | Test null email handling | Records with null emails rejected from Silver layer |
| TC_USR_007 | Validate account status derivation | Account status correctly derived from plan type and activity |
| TC_USR_008 | Test invalid email format handling | Invalid email formats rejected or corrected |
| TC_USR_009 | Validate registration date extraction | Registration date correctly extracted from load_timestamp |
| TC_USR_010 | Test future timestamp validation | Future timestamps corrected to current timestamp |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate meeting duration calculation | Duration correctly calculated from start and end times |
| TC_MTG_002 | Test meeting type classification | Meeting types correctly classified based on duration |
| TC_MTG_003 | Validate host name enrichment | Host names correctly joined from users table |
| TC_MTG_004 | Test meeting status derivation | Status correctly derived from timestamps and current time |
| TC_MTG_005 | Validate participant count calculation | Participant counts correctly aggregated from participants table |
| TC_MTG_006 | Test negative duration handling | Negative durations corrected to absolute values |
| TC_MTG_007 | Validate end time before start time | Invalid time sequences corrected using duration |
| TC_MTG_008 | Test null host ID handling | Records with null host IDs rejected |
| TC_MTG_009 | Validate recording status derivation | Recording status correctly derived from meeting attributes |
| TC_MTG_010 | Test data quality validations | All data quality checks applied correctly |

### 3. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PAR_001 | Validate attendance duration calculation | Duration correctly calculated from join and leave times |
| TC_PAR_002 | Test participant role derivation | Roles correctly derived from user and meeting relationship |
| TC_PAR_003 | Validate connection quality assessment | Quality correctly derived from attendance patterns |
| TC_PAR_004 | Test leave time before join time handling | Invalid time sequences corrected |
| TC_PAR_005 | Validate missing leave time handling | Missing leave times inferred or handled gracefully |
| TC_PAR_006 | Test referential integrity with meetings | All participants reference valid meetings |
| TC_PAR_007 | Validate referential integrity with users | All participants reference valid users |
| TC_PAR_008 | Test future timestamp handling | Future timestamps corrected appropriately |
| TC_PAR_009 | Validate deduplication logic | Duplicate participant records handled correctly |
| TC_PAR_010 | Test data quality score calculation | Quality scores calculated based on completeness |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FEA_001 | Validate feature name standardization | Feature names consistently formatted |
| TC_FEA_002 | Test feature category mapping | Features correctly categorized (Audio, Video, Collaboration, Security) |
| TC_FEA_003 | Validate usage count validation | Negative usage counts handled appropriately |
| TC_FEA_004 | Test usage duration calculation | Duration correctly derived from usage patterns |
| TC_FEA_005 | Validate referential integrity with meetings | All usage records reference valid meetings |
| TC_FEA_006 | Test outlier detection for usage counts | Statistical outliers identified and handled |
| TC_FEA_007 | Validate date consistency | Usage dates consistent with meeting dates |
| TC_FEA_008 | Test null feature name handling | Null feature names handled gracefully |
| TC_FEA_009 | Validate data quality checks | All validation rules applied correctly |
| TC_FEA_010 | Test aggregation accuracy | Usage metrics aggregated correctly |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SUP_001 | Validate ticket type standardization | Ticket types standardized to enumerated values |
| TC_SUP_002 | Test priority level derivation | Priority correctly derived from ticket type |
| TC_SUP_003 | Validate resolution time calculation | Resolution time calculated in business hours |
| TC_SUP_004 | Test resolution status standardization | Status values standardized correctly |
| TC_SUP_005 | Validate close date logic | Close dates consistent with resolution status |
| TC_SUP_006 | Test referential integrity with users | All tickets reference valid users |
| TC_SUP_007 | Validate future open date handling | Future open dates corrected |
| TC_SUP_008 | Test null user ID handling | Tickets without user association handled |
| TC_SUP_009 | Validate issue description standardization | Descriptions properly formatted |
| TC_SUP_010 | Test resolution notes generation | Notes generated based on status |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate transaction amount validation | Positive amounts validated correctly |
| TC_BIL_002 | Test event type standardization | Event types standardized to valid values |
| TC_BIL_003 | Validate payment method derivation | Payment methods correctly derived |
| TC_BIL_004 | Test currency code standardization | Currency codes validated to ISO standards |
| TC_BIL_005 | Validate invoice number generation | Invoice numbers generated uniquely |
| TC_BIL_006 | Test transaction status derivation | Status derived from amount and event type |
| TC_BIL_007 | Validate negative amount handling | Negative amounts handled for refunds |
| TC_BIL_008 | Test referential integrity with users | All events reference valid users |
| TC_BIL_009 | Validate large amount detection | Unusually large amounts flagged |
| TC_BIL_010 | Test date consistency validation | Transaction dates validated |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate license type standardization | License types standardized correctly |
| TC_LIC_002 | Test license status derivation | Status derived from current date vs end date |
| TC_LIC_003 | Validate date range logic | End date must be after start date |
| TC_LIC_004 | Test user name enrichment | User names correctly joined |
| TC_LIC_005 | Validate cost derivation | Costs correctly derived from license type |
| TC_LIC_006 | Test renewal status calculation | Renewal status based on end date proximity |
| TC_LIC_007 | Validate utilization percentage | Utilization calculated from usage patterns |
| TC_LIC_008 | Test referential integrity with users | All licenses reference valid users |
| TC_LIC_009 | Validate future start date handling | Future start dates handled appropriately |
| TC_LIC_010 | Test date range correction | Invalid date ranges corrected |

### 8. SI_WEBINARS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_WEB_001 | Validate webinar duration calculation | Duration calculated from start and end times |
| TC_WEB_002 | Test attendance rate calculation | Rate calculated as (attendees/registrants) * 100 |
| TC_WEB_003 | Validate attendee count derivation | Attendees derived from registrants with rate |
| TC_WEB_004 | Test negative registrant handling | Negative registrant counts corrected |
| TC_WEB_005 | Validate time sequence logic | End time must be after start time |
| TC_WEB_006 | Test missing end time handling | Missing end times inferred |
| TC_WEB_007 | Validate webinar topic standardization | Topics properly formatted |
| TC_WEB_008 | Test referential integrity with users | All webinars reference valid hosts |
| TC_WEB_009 | Validate duplicate webinar ID handling | Duplicates resolved by latest timestamp |
| TC_WEB_010 | Test data quality validations | All validation rules applied |

### 9. SI_AUDIT_LOG Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Validate audit log initialization | Audit log properly initialized |
| TC_AUD_002 | Test execution ID generation | Unique execution IDs generated |
| TC_AUD_003 | Validate pipeline tracking | All pipeline executions tracked |
| TC_AUD_004 | Test error message logging | Error messages properly logged |
| TC_AUD_005 | Validate duration calculation | Execution duration calculated correctly |
| TC_AUD_006 | Test record count tracking | Record counts accurately tracked |
| TC_AUD_007 | Validate status tracking | Execution status properly recorded |
| TC_AUD_008 | Test lineage information | Data lineage information captured |
| TC_AUD_009 | Validate timestamp consistency | All timestamps consistent |
| TC_AUD_010 | Test audit completeness | All required audit fields populated |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer cleaned and standardized user data"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - unique
          - not_null
      - name: email
        description: "Validated and standardized email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "Standardized subscription tier"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: account_status
        description: "Current status of user account"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        description: "Overall data quality score for the record"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  - name: si_meetings
    description: "Silver layer cleaned and enriched meeting data"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Calculated meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: meeting_status
        description: "Current state of the meeting"
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled', 'Unknown']
      - name: participant_count
        description: "Total number of participants"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  - name: si_participants
    description: "Silver layer participant attendance data"
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
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        description: "Time participant spent in meeting"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440

  - name: si_feature_usage
    description: "Silver layer feature usage data"
    columns:
      - name: usage_id
        description: "Unique identifier for each usage record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: feature_category
        description: "Classification of feature type"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']
      - name: usage_count
        description: "Number of times feature was utilized"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000

  - name: si_support_tickets
    description: "Silver layer support ticket data"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        description: "Standardized category"
        tests:
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: resolution_status
        description: "Current status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer billing transaction data"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: event_type
        description: "Standardized billing transaction type"
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
      - name: transaction_amount
        description: "Monetary value of the billing event"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: -10000.00
              max_value: 100000.00

  - name: si_licenses
    description: "Silver layer license management data"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: license_type
        description: "Standardized category"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-on']
      - name: license_status
        description: "Current state"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']

  - name: si_webinars
    description: "Silver layer webinar data"
    columns:
      - name: webinar_id
        description: "Unique identifier for each webinar"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "User ID of the webinar host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_rate
        description: "Percentage of registrants who attended"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 100.0

  - name: si_audit_log
    description: "Silver layer audit log"
    columns:
      - name: execution_id
        description: "Unique identifier for each pipeline execution"
        tests:
          - unique
          - not_null
      - name: pipeline_name
        description: "Name of the data pipeline"
        tests:
          - not_null
      - name: status
        description: "Status of execution"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'STARTED', 'COMPLETED']
```

### Custom SQL Tests

#### Test 1: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
-- Test that all emails in si_users follow proper format
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test 2: Meeting Duration Consistency
```sql
-- tests/test_meeting_duration_consistency.sql
-- Test that calculated duration matches the difference between start and end times
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('si_meetings') }}
WHERE start_time IS NOT NULL 
  AND end_time IS NOT NULL
  AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### Test 3: Participant Attendance Logic
```sql
-- tests/test_participant_attendance_logic.sql
-- Test that participant attendance duration is logical
SELECT 
    participant_id,
    join_time,
    leave_time,
    attendance_duration
FROM {{ ref('si_participants') }}
WHERE leave_time IS NOT NULL 
  AND join_time IS NOT NULL
  AND (leave_time < join_time OR attendance_duration < 0)
```

#### Test 4: Data Quality Score Validation
```sql
-- tests/test_data_quality_score_validation.sql
-- Test that data quality scores are within valid range
SELECT 
    'si_users' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.0 OR data_quality_score > 1.0
UNION ALL
SELECT 
    'si_meetings' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0.0 OR data_quality_score > 1.0
HAVING invalid_scores > 0
```

#### Test 5: Referential Integrity Check
```sql
-- tests/test_referential_integrity.sql
-- Test that all foreign key relationships are maintained
SELECT 
    'meetings_to_users' as relationship,
    COUNT(*) as orphaned_records
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL
UNION ALL
SELECT 
    'participants_to_meetings' as relationship,
    COUNT(*) as orphaned_records
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
HAVING orphaned_records > 0
```

#### Test 6: Temporal Consistency Validation
```sql
-- tests/test_temporal_consistency.sql
-- Test that timestamps are logically consistent
SELECT 
    'future_timestamps' as issue_type,
    COUNT(*) as issue_count
FROM {{ ref('si_users') }}
WHERE load_timestamp > CURRENT_TIMESTAMP() + INTERVAL '1' DAY
UNION ALL
SELECT 
    'invalid_meeting_times' as issue_type,
    COUNT(*) as issue_count
FROM {{ ref('si_meetings') }}
WHERE end_time < start_time
HAVING issue_count > 0
```

#### Test 7: Business Rule Validation
```sql
-- tests/test_business_rules.sql
-- Test that business rules are properly applied
SELECT 
    'invalid_plan_types' as rule_type,
    COUNT(*) as violations
FROM {{ ref('si_users') }}
WHERE plan_type NOT IN ('Free', 'Basic', 'Pro', 'Enterprise', 'Unknown')
UNION ALL
SELECT 
    'negative_billing_amounts' as rule_type,
    COUNT(*) as violations
FROM {{ ref('si_billing_events') }}
WHERE transaction_amount < 0 AND event_type != 'Refund'
HAVING violations > 0
```

#### Test 8: Deduplication Effectiveness
```sql
-- tests/test_deduplication_effectiveness.sql
-- Test that deduplication logic works correctly
SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
UNION ALL
SELECT 
    meeting_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_meetings') }}
GROUP BY meeting_id
HAVING COUNT(*) > 1
```

#### Test 9: Audit Trail Completeness
```sql
-- tests/test_audit_trail_completeness.sql
-- Test that audit logging is complete
SELECT 
    execution_id,
    pipeline_name,
    status
FROM {{ ref('si_audit_log') }}
WHERE execution_id IS NULL 
   OR pipeline_name IS NULL 
   OR status IS NULL
   OR start_time IS NULL
```

#### Test 10: Data Completeness Check
```sql
-- tests/test_data_completeness.sql
-- Test overall data completeness across critical fields
WITH completeness_check AS (
    SELECT 
        'si_users' as table_name,
        'email' as column_name,
        COUNT(*) as total_records,
        COUNT(email) as non_null_records,
        (COUNT(email)::FLOAT / COUNT(*)) * 100 as completeness_percentage
    FROM {{ ref('si_users') }}
    UNION ALL
    SELECT 
        'si_meetings' as table_name,
        'host_id' as column_name,
        COUNT(*) as total_records,
        COUNT(host_id) as non_null_records,
        (COUNT(host_id)::FLOAT / COUNT(*)) * 100 as completeness_percentage
    FROM {{ ref('si_meetings') }}
)
SELECT *
FROM completeness_check
WHERE completeness_percentage < 95.0
```

### Parameterized Tests

#### Generic Test for Range Validation
```sql
-- macros/test_column_range.sql
{% macro test_column_range(model, column_name, min_value, max_value) %}
    SELECT 
        {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL 
      AND ({{ column_name }} < {{ min_value }} OR {{ column_name }} > {{ max_value }})
{% endmacro %}
```

#### Generic Test for Pattern Matching
```sql
-- macros/test_pattern_match.sql
{% macro test_pattern_match(model, column_name, pattern) %}
    SELECT 
        {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL 
      AND NOT REGEXP_LIKE({{ column_name }}, '{{ pattern }}')
{% endmacro %}
```

### Performance Tests

#### Test 1: Model Execution Time
```sql
-- tests/performance/test_model_execution_time.sql
-- Monitor execution time for each model
SELECT 
    pipeline_name,
    execution_duration_seconds,
    records_processed,
    (records_processed / NULLIF(execution_duration_seconds, 0)) as records_per_second
FROM {{ ref('si_audit_log') }}
WHERE execution_duration_seconds > 300 -- Flag executions taking more than 5 minutes
```

#### Test 2: Data Volume Validation
```sql
-- tests/performance/test_data_volume.sql
-- Validate expected data volumes
WITH volume_check AS (
    SELECT 
        'si_users' as table_name,
        COUNT(*) as record_count,
        CURRENT_DATE() as check_date
    FROM {{ ref('si_users') }}
    UNION ALL
    SELECT 
        'si_meetings' as table_name,
        COUNT(*) as record_count,
        CURRENT_DATE() as check_date
    FROM {{ ref('si_meetings') }}
)
SELECT *
FROM volume_check
WHERE record_count = 0 -- Flag empty tables
```

## Test Execution Strategy

### 1. Continuous Integration Tests
- Run schema tests on every dbt run
- Execute custom SQL tests during CI/CD pipeline
- Validate data quality scores meet minimum thresholds

### 2. Regression Testing
- Compare current run results with baseline
- Monitor data quality trends over time
- Alert on significant deviations

### 3. Performance Monitoring
- Track model execution times
- Monitor resource utilization
- Optimize based on performance metrics

### 4. Data Quality Dashboard
- Real-time data quality metrics
- Test execution results
- Trend analysis and alerting

## Expected Outcomes

### Data Quality Metrics
- **Completeness**: > 95% for critical fields
- **Accuracy**: > 99% for business calculations
- **Consistency**: 100% for referential integrity
- **Validity**: > 98% for format validations

### Performance Benchmarks
- **Model Execution**: < 5 minutes per model
- **Test Execution**: < 2 minutes for full test suite
- **Data Processing**: > 1000 records/second

### Error Handling
- **Critical Errors**: 0 tolerance (block processing)
- **Warning Errors**: < 5% of total records
- **Data Quality Score**: > 0.85 average across all models

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics Silver Layer Pipeline in Snowflake with dbt.