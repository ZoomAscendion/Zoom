_____________________________________________
## *Author*: AAVA
## *Created on*: 2024
## *Description*: Comprehensive Snowflake dbt Unit Test Cases for Silver Layer Models in Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024
_____________________________________________

# Snowflake dbt Unit Test Cases - Silver Layer
## Zoom Platform Analytics System

## 1. Overview

This document provides comprehensive unit test cases for the Silver layer models in the Zoom Platform Analytics System following the Medallion architecture. The test cases cover data quality validations, business rule enforcement, edge case handling, and referential integrity checks using dbt-compatible testing frameworks.

### Test Coverage Areas:
- **Happy Path Scenarios**: Valid data transformations and business logic
- **Edge Cases**: Null values, boundary conditions, and format variations
- **Exception Cases**: Data quality violations, referential integrity failures
- **Performance Tests**: Large dataset handling and optimization validation

### Testing Framework:
- **YAML-based Schema Tests**: Built-in dbt tests (unique, not_null, relationships, accepted_values)
- **Custom SQL Tests**: Complex business logic and data quality validations
- **Expression Tests**: Field-level validations and calculations

## 2. SI_USERS Table Test Cases

### 2.1 YAML Schema Tests

```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer cleaned and standardized user data"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
              
      - name: email
        description: "Validated and standardized email address"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: warn
              
      - name: plan_type
        description: "Standardized subscription tier"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
              severity: error
              
      - name: account_status
        description: "Current status of user account"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
              severity: error
              
      - name: data_quality_score
        description: "Overall data quality score for the record"
        tests:
          - not_null:
              severity: warn
```

### 2.2 Custom SQL Tests

#### Test Case 2.2.1: Email Format Validation
```sql
-- tests/silver/test_si_users_email_format.sql
-- Test: Validate email format using REGEXP_LIKE
-- Expected: All emails should match valid email pattern

SELECT 
    user_id,
    email,
    'Invalid email format' as test_failure_reason
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test Case 2.2.2: Data Quality Score Range Validation
```sql
-- tests/silver/test_si_users_data_quality_score_range.sql
-- Test: Validate data quality score is between 0.00 and 1.00
-- Expected: All scores should be within valid range

SELECT 
    user_id,
    data_quality_score,
    'Data quality score out of range' as test_failure_reason
FROM {{ ref('si_users') }}
WHERE data_quality_score IS NOT NULL 
  AND (data_quality_score < 0.00 OR data_quality_score > 1.00)
```

#### Test Case 2.2.3: Registration Date Logic Validation
```sql
-- tests/silver/test_si_users_registration_date_logic.sql
-- Test: Registration date should not be in the future
-- Expected: All registration dates should be <= current date

SELECT 
    user_id,
    registration_date,
    'Future registration date' as test_failure_reason
FROM {{ ref('si_users') }}
WHERE registration_date > CURRENT_DATE()
```

#### Test Case 2.2.4: Last Login Date Logic Validation
```sql
-- tests/silver/test_si_users_last_login_logic.sql
-- Test: Last login date should be >= registration date
-- Expected: Last login cannot be before registration

SELECT 
    user_id,
    registration_date,
    last_login_date,
    'Last login before registration' as test_failure_reason
FROM {{ ref('si_users') }}
WHERE last_login_date IS NOT NULL 
  AND registration_date IS NOT NULL
  AND last_login_date < registration_date
```

## 3. SI_MEETINGS Table Test Cases

### 3.1 YAML Schema Tests

```yaml
# models/silver/schema.yml (continued)
  - name: si_meetings
    description: "Silver layer cleaned and enriched meeting data"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
              
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
              
      - name: meeting_status
        description: "Current state of the meeting"
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
              severity: error
              
      - name: recording_status
        description: "Whether the meeting was recorded"
        tests:
          - accepted_values:
              values: ['Yes', 'No']
              severity: warn
```

### 3.2 Custom SQL Tests

#### Test Case 3.2.1: Temporal Logic Validation
```sql
-- tests/silver/test_si_meetings_temporal_logic.sql
-- Test: End time should be >= start time
-- Expected: No meetings with end time before start time

SELECT 
    meeting_id,
    start_time,
    end_time,
    'End time before start time' as test_failure_reason
FROM {{ ref('si_meetings') }}
WHERE end_time IS NOT NULL 
  AND start_time IS NOT NULL
  AND end_time < start_time
```

#### Test Case 3.2.2: Duration Calculation Validation
```sql
-- tests/silver/test_si_meetings_duration_calculation.sql
-- Test: Duration should match calculated difference between start and end time
-- Expected: Duration should be consistent with timestamps

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    'Duration mismatch' as test_failure_reason
FROM {{ ref('si_meetings') }}
WHERE start_time IS NOT NULL 
  AND end_time IS NOT NULL
  AND duration_minutes IS NOT NULL
  AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### Test Case 3.2.3: Participant Count Validation
```sql
-- tests/silver/test_si_meetings_participant_count.sql
-- Test: Participant count should be >= 0
-- Expected: No negative participant counts

SELECT 
    meeting_id,
    participant_count,
    'Negative participant count' as test_failure_reason
FROM {{ ref('si_meetings') }}
WHERE participant_count < 0
```

#### Test Case 3.2.4: Meeting Duration Range Validation
```sql
-- tests/silver/test_si_meetings_duration_range.sql
-- Test: Meeting duration should be between 1 and 1440 minutes (24 hours)
-- Expected: Reasonable duration limits

SELECT 
    meeting_id,
    duration_minutes,
    'Duration out of reasonable range' as test_failure_reason
FROM {{ ref('si_meetings') }}
WHERE duration_minutes IS NOT NULL 
  AND (duration_minutes < 1 OR duration_minutes > 1440)
```

## 4. SI_PARTICIPANTS Table Test Cases

### 4.1 YAML Schema Tests

```yaml
# models/silver/schema.yml (continued)
  - name: si_participants
    description: "Silver layer cleaned participant attendance data"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant record"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
              
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
              severity: error
              
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: warn
              
      - name: participant_role
        description: "Role of attendee"
        tests:
          - accepted_values:
              values: ['Host', 'Co-host', 'Participant', 'Observer']
              severity: warn
```

### 4.2 Custom SQL Tests

#### Test Case 4.2.1: Attendance Duration Logic
```sql
-- tests/silver/test_si_participants_attendance_logic.sql
-- Test: Leave time should be >= join time
-- Expected: No participants leaving before joining

SELECT 
    participant_id,
    join_time,
    leave_time,
    'Leave time before join time' as test_failure_reason
FROM {{ ref('si_participants') }}
WHERE leave_time IS NOT NULL 
  AND join_time IS NOT NULL
  AND leave_time < join_time
```

#### Test Case 4.2.2: Attendance Duration Calculation
```sql
-- tests/silver/test_si_participants_duration_calculation.sql
-- Test: Attendance duration should match calculated difference
-- Expected: Duration should be consistent with timestamps

SELECT 
    participant_id,
    join_time,
    leave_time,
    attendance_duration,
    DATEDIFF('minute', join_time, leave_time) as calculated_duration,
    'Attendance duration mismatch' as test_failure_reason
FROM {{ ref('si_participants') }}
WHERE join_time IS NOT NULL 
  AND leave_time IS NOT NULL
  AND attendance_duration IS NOT NULL
  AND ABS(attendance_duration - DATEDIFF('minute', join_time, leave_time)) > 1
```

#### Test Case 4.2.3: Attendance vs Meeting Duration
```sql
-- tests/silver/test_si_participants_vs_meeting_duration.sql
-- Test: Participant attendance should not exceed meeting duration
-- Expected: Attendance duration <= meeting duration

WITH participant_meeting AS (
    SELECT 
        p.participant_id,
        p.attendance_duration,
        m.duration_minutes as meeting_duration
    FROM {{ ref('si_participants') }} p
    JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE p.attendance_duration IS NOT NULL 
      AND m.duration_minutes IS NOT NULL
)
SELECT 
    participant_id,
    attendance_duration,
    meeting_duration,
    'Attendance exceeds meeting duration' as test_failure_reason
FROM participant_meeting
WHERE attendance_duration > meeting_duration + 5  -- Allow 5 minute buffer
```

## 5. SI_FEATURE_USAGE Table Test Cases

### 5.1 YAML Schema Tests

```yaml
# models/silver/schema.yml (continued)
  - name: si_feature_usage
    description: "Silver layer standardized feature usage data"
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
              
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
              severity: error
              
      - name: feature_category
        description: "Classification of feature type"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']
              severity: warn
```

### 5.2 Custom SQL Tests

#### Test Case 5.2.1: Usage Count Validation
```sql
-- tests/silver/test_si_feature_usage_count_validation.sql
-- Test: Usage count should be >= 0
-- Expected: No negative usage counts

SELECT 
    usage_id,
    feature_name,
    usage_count,
    'Negative usage count' as test_failure_reason
FROM {{ ref('si_feature_usage') }}
WHERE usage_count < 0
```

#### Test Case 5.2.2: Usage Duration Validation
```sql
-- tests/silver/test_si_feature_usage_duration_validation.sql
-- Test: Usage duration should be >= 0 and reasonable
-- Expected: Non-negative duration within meeting bounds

SELECT 
    usage_id,
    feature_name,
    usage_duration,
    'Invalid usage duration' as test_failure_reason
FROM {{ ref('si_feature_usage') }}
WHERE usage_duration IS NOT NULL 
  AND (usage_duration < 0 OR usage_duration > 1440)  -- Max 24 hours
```

## 6. SI_SUPPORT_TICKETS Table Test Cases

### 6.1 YAML Schema Tests

```yaml
# models/silver/schema.yml (continued)
  - name: si_support_tickets
    description: "Silver layer standardized support ticket data"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
              
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
              
      - name: ticket_type
        description: "Standardized category"
        tests:
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
              severity: error
              
      - name: priority_level
        description: "Urgency level of ticket"
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
              severity: error
              
      - name: resolution_status
        description: "Current status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
              severity: error
```

### 6.2 Custom SQL Tests

#### Test Case 6.2.1: Date Logic Validation
```sql
-- tests/silver/test_si_support_tickets_date_logic.sql
-- Test: Close date should be >= open date
-- Expected: Tickets cannot be closed before they are opened

SELECT 
    ticket_id,
    open_date,
    close_date,
    'Close date before open date' as test_failure_reason
FROM {{ ref('si_support_tickets') }}
WHERE close_date IS NOT NULL 
  AND open_date IS NOT NULL
  AND close_date < open_date
```

#### Test Case 6.2.2: Resolution Time Validation
```sql
-- tests/silver/test_si_support_tickets_resolution_time.sql
-- Test: Resolution time should be >= 0
-- Expected: Non-negative resolution times

SELECT 
    ticket_id,
    resolution_time_hours,
    'Negative resolution time' as test_failure_reason
FROM {{ ref('si_support_tickets') }}
WHERE resolution_time_hours < 0
```

#### Test Case 6.2.3: Status Consistency Validation
```sql
-- tests/silver/test_si_support_tickets_status_consistency.sql
-- Test: Closed/Resolved tickets should have close date
-- Expected: Status and dates should be consistent

SELECT 
    ticket_id,
    resolution_status,
    close_date,
    'Status inconsistent with close date' as test_failure_reason
FROM {{ ref('si_support_tickets') }}
WHERE resolution_status IN ('Resolved', 'Closed')
  AND close_date IS NULL
```

## 7. SI_BILLING_EVENTS Table Test Cases

### 7.1 YAML Schema Tests

```yaml
# models/silver/schema.yml (continued)
  - name: si_billing_events
    description: "Silver layer validated billing transaction data"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
              
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
              
      - name: event_type
        description: "Standardized billing transaction type"
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
              severity: error
              
      - name: payment_method
        description: "Method used for payment"
        tests:
          - accepted_values:
              values: ['Credit Card', 'Bank Transfer', 'PayPal']
              severity: warn
              
      - name: transaction_status
        description: "Status of transaction"
        tests:
          - accepted_values:
              values: ['Completed', 'Pending', 'Failed', 'Refunded']
              severity: error
```

### 7.2 Custom SQL Tests

#### Test Case 7.2.1: Transaction Amount Validation
```sql
-- tests/silver/test_si_billing_events_amount_validation.sql
-- Test: Transaction amounts should be reasonable (not zero for non-refunds)
-- Expected: Positive amounts for most transaction types

SELECT 
    event_id,
    event_type,
    transaction_amount,
    'Invalid transaction amount' as test_failure_reason
FROM {{ ref('si_billing_events') }}
WHERE (
    (event_type != 'Refund' AND transaction_amount <= 0)
    OR (event_type = 'Refund' AND transaction_amount >= 0)
    OR transaction_amount IS NULL
)
```

#### Test Case 7.2.2: Currency Code Validation
```sql
-- tests/silver/test_si_billing_events_currency_validation.sql
-- Test: Currency code should be valid 3-character ISO code
-- Expected: Valid currency codes

SELECT 
    event_id,
    currency_code,
    'Invalid currency code' as test_failure_reason
FROM {{ ref('si_billing_events') }}
WHERE currency_code IS NULL 
   OR LENGTH(currency_code) != 3
   OR NOT REGEXP_LIKE(currency_code, '^[A-Z]{3}$')
```

#### Test Case 7.2.3: Invoice Number Uniqueness
```sql
-- tests/silver/test_si_billing_events_invoice_uniqueness.sql
-- Test: Invoice numbers should be unique
-- Expected: No duplicate invoice numbers

SELECT 
    invoice_number,
    COUNT(*) as duplicate_count,
    'Duplicate invoice number' as test_failure_reason
FROM {{ ref('si_billing_events') }}
WHERE invoice_number IS NOT NULL
GROUP BY invoice_number
HAVING COUNT(*) > 1
```

## 8. SI_LICENSES Table Test Cases

### 8.1 YAML Schema Tests

```yaml
# models/silver/schema.yml (continued)
  - name: si_licenses
    description: "Silver layer validated license assignment data"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
              
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
              
      - name: license_type
        description: "Standardized category"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-on']
              severity: error
              
      - name: license_status
        description: "Current state"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
              severity: error
              
      - name: renewal_status
        description: "Whether license is set for automatic renewal"
        tests:
          - accepted_values:
              values: ['Yes', 'No']
              severity: warn
```

### 8.2 Custom SQL Tests

#### Test Case 8.2.1: Date Range Validation
```sql
-- tests/silver/test_si_licenses_date_range_validation.sql
-- Test: End date should be >= start date
-- Expected: Valid date ranges for all licenses

SELECT 
    license_id,
    start_date,
    end_date,
    'End date before start date' as test_failure_reason
FROM {{ ref('si_licenses') }}
WHERE end_date IS NOT NULL 
  AND start_date IS NOT NULL
  AND end_date < start_date
```

#### Test Case 8.2.2: License Cost Validation
```sql
-- tests/silver/test_si_licenses_cost_validation.sql
-- Test: License cost should be >= 0
-- Expected: Non-negative license costs

SELECT 
    license_id,
    license_type,
    license_cost,
    'Negative license cost' as test_failure_reason
FROM {{ ref('si_licenses') }}
WHERE license_cost < 0
```

#### Test Case 8.2.3: Utilization Percentage Range
```sql
-- tests/silver/test_si_licenses_utilization_range.sql
-- Test: Utilization percentage should be between 0 and 100
-- Expected: Valid percentage range

SELECT 
    license_id,
    utilization_percentage,
    'Utilization percentage out of range' as test_failure_reason
FROM {{ ref('si_licenses') }}
WHERE utilization_percentage IS NOT NULL 
  AND (utilization_percentage < 0 OR utilization_percentage > 100)
```

## 9. SI_WEBINARS Table Test Cases

### 9.1 YAML Schema Tests

```yaml
# models/silver/schema.yml (continued)
  - name: si_webinars
    description: "Silver layer cleaned webinar data with engagement metrics"
    columns:
      - name: webinar_id
        description: "Unique identifier for each webinar"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
              
      - name: host_id
        description: "User ID of the webinar host"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
```

### 9.2 Custom SQL Tests

#### Test Case 9.2.1: Webinar Temporal Logic
```sql
-- tests/silver/test_si_webinars_temporal_logic.sql
-- Test: End time should be >= start time
-- Expected: Valid time sequences for webinars

SELECT 
    webinar_id,
    start_time,
    end_time,
    'End time before start time' as test_failure_reason
FROM {{ ref('si_webinars') }}
WHERE end_time IS NOT NULL 
  AND start_time IS NOT NULL
  AND end_time < start_time
```

#### Test Case 9.2.2: Attendance Rate Calculation
```sql
-- tests/silver/test_si_webinars_attendance_rate.sql
-- Test: Attendance rate should be calculated correctly
-- Expected: Rate = (attendees/registrants) * 100

SELECT 
    webinar_id,
    registrants,
    attendees,
    attendance_rate,
    CASE WHEN registrants > 0 
         THEN ROUND((attendees::FLOAT / registrants) * 100, 2)
         ELSE 0 END as calculated_rate,
    'Attendance rate calculation error' as test_failure_reason
FROM {{ ref('si_webinars') }}
WHERE registrants IS NOT NULL 
  AND attendees IS NOT NULL
  AND attendance_rate IS NOT NULL
  AND ABS(attendance_rate - 
          CASE WHEN registrants > 0 
               THEN ROUND((attendees::FLOAT / registrants) * 100, 2)
               ELSE 0 END) > 0.1
```

#### Test Case 9.2.3: Attendee Count Logic
```sql
-- tests/silver/test_si_webinars_attendee_logic.sql
-- Test: Attendees should not exceed registrants
-- Expected: Attendees <= registrants

SELECT 
    webinar_id,
    registrants,
    attendees,
    'Attendees exceed registrants' as test_failure_reason
FROM {{ ref('si_webinars') }}
WHERE attendees IS NOT NULL 
  AND registrants IS NOT NULL
  AND attendees > registrants
```

## 10. Cross-Table Referential Integrity Tests

### 10.1 Orphaned Records Detection

#### Test Case 10.1.1: Orphaned Meeting Participants
```sql
-- tests/silver/test_cross_table_orphaned_participants.sql
-- Test: All participants should reference valid meetings
-- Expected: No orphaned participant records

SELECT 
    p.participant_id,
    p.meeting_id,
    'Orphaned participant - meeting not found' as test_failure_reason
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
```

#### Test Case 10.1.2: Invalid Host References
```sql
-- tests/silver/test_cross_table_invalid_hosts.sql
-- Test: All meeting hosts should exist in users table
-- Expected: No invalid host references

SELECT 
    m.meeting_id,
    m.host_id,
    'Invalid host reference' as test_failure_reason
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL
```

### 10.2 Data Consistency Across Tables

#### Test Case 10.2.1: Meeting Participant Count Consistency
```sql
-- tests/silver/test_cross_table_participant_count_consistency.sql
-- Test: Meeting participant count should match actual participants
-- Expected: Consistent participant counts

WITH actual_counts AS (
    SELECT 
        meeting_id,
        COUNT(*) as actual_participant_count
    FROM {{ ref('si_participants') }}
    GROUP BY meeting_id
)
SELECT 
    m.meeting_id,
    m.participant_count as reported_count,
    COALESCE(a.actual_participant_count, 0) as actual_count,
    'Participant count mismatch' as test_failure_reason
FROM {{ ref('si_meetings') }} m
LEFT JOIN actual_counts a ON m.meeting_id = a.meeting_id
WHERE ABS(COALESCE(m.participant_count, 0) - COALESCE(a.actual_participant_count, 0)) > 0
```

## 11. Data Quality Score Validation Tests

### 11.1 Data Quality Score Calculation Test

#### Test Case 11.1.1: Data Quality Score Consistency
```sql
-- tests/silver/test_data_quality_score_calculation.sql
-- Test: Data quality scores should be calculated consistently
-- Expected: Scores reflect actual data quality metrics

WITH quality_metrics AS (
    SELECT 
        user_id,
        data_quality_score,
        -- Calculate completeness score (40%)
        CASE WHEN user_name IS NOT NULL THEN 0.1 ELSE 0 END +
        CASE WHEN email IS NOT NULL THEN 0.1 ELSE 0 END +
        CASE WHEN company IS NOT NULL THEN 0.1 ELSE 0 END +
        CASE WHEN plan_type IS NOT NULL THEN 0.1 ELSE 0 END as completeness_score,
        -- Calculate validity score (30%)
        CASE WHEN email IS NULL OR REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
             THEN 0.15 ELSE 0 END +
        CASE WHEN plan_type IS NULL OR plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') 
             THEN 0.15 ELSE 0 END as validity_score,
        -- Calculate consistency score (20%)
        CASE WHEN last_login_date IS NULL OR registration_date IS NULL OR last_login_date >= registration_date 
             THEN 0.2 ELSE 0 END as consistency_score,
        -- Calculate accuracy score (10%)
        0.1 as accuracy_score  -- Assume full accuracy for this test
    FROM {{ ref('si_users') }}
)
SELECT 
    user_id,
    data_quality_score,
    (completeness_score + validity_score + consistency_score + accuracy_score) as calculated_score,
    'Data quality score calculation inconsistent' as test_failure_reason
FROM quality_metrics
WHERE ABS(data_quality_score - (completeness_score + validity_score + consistency_score + accuracy_score)) > 0.05
```

## 12. Performance and Volume Tests

### 12.1 Large Dataset Handling

#### Test Case 12.1.1: Duplicate Detection Performance
```sql
-- tests/silver/test_performance_duplicate_detection.sql
-- Test: Duplicate detection should handle large volumes efficiently
-- Expected: No performance degradation with large datasets

WITH duplicate_check AS (
    SELECT 
        user_id,
        COUNT(*) as duplicate_count,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY load_timestamp DESC) as rn
    FROM {{ ref('si_users') }}
    GROUP BY user_id, email, user_name, load_timestamp
    HAVING COUNT(*) > 1
)
SELECT 
    user_id,
    duplicate_count,
    'Performance issue with duplicate detection' as test_failure_reason
FROM duplicate_check
WHERE duplicate_count > 10  -- Flag if more than 10 duplicates
```

## 13. Error Handling and Data Quality Monitoring

### 13.1 Error Tracking Validation

#### Test Case 13.1.1: Data Quality Error Logging
```sql
-- tests/silver/test_data_quality_error_logging.sql
-- Test: Data quality errors should be properly logged
-- Expected: All critical errors are captured in error table

WITH critical_errors AS (
    SELECT 'SI_USERS' as table_name, user_id as record_id, 'INVALID_EMAIL' as error_type
    FROM {{ ref('si_users') }}
    WHERE email IS NOT NULL 
      AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
    
    UNION ALL
    
    SELECT 'SI_MEETINGS', meeting_id, 'TEMPORAL_LOGIC_ERROR'
    FROM {{ ref('si_meetings') }}
    WHERE end_time IS NOT NULL 
      AND start_time IS NOT NULL
      AND end_time < start_time
)
SELECT 
    ce.table_name,
    ce.record_id,
    ce.error_type,
    'Critical error not logged in error table' as test_failure_reason
FROM critical_errors ce
LEFT JOIN {{ ref('si_data_quality_errors') }} dqe 
    ON ce.table_name = dqe.source_table 
    AND ce.record_id = dqe.source_record_id
    AND ce.error_type = dqe.error_type
WHERE dqe.error_id IS NULL
```

## 14. Test Execution Framework

### 14.1 dbt Test Configuration

```yaml
# dbt_project.yml
name: 'zoom_analytics'
version: '1.0.0'
config-version: 2

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["data"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  zoom_analytics:
    silver:
      +materialized: table
      +tags: ["silver"]
      
tests:
  zoom_analytics:
    +severity: warn  # Default severity
    +tags: ["data_quality"]
```

### 14.2 Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific models
dbt test --models si_users
dbt test --models tag:silver

# Run tests with specific severity
dbt test --severity error

# Run specific test types
dbt test --models si_users --test-type unique
dbt test --models si_users --test-type not_null

# Generate test documentation
dbt docs generate
dbt docs serve
```

## 15. Test Results Monitoring and Alerting

### 15.1 Test Results Analysis

```sql
-- Query to analyze test results
SELECT 
    test_name,
    model_name,
    severity,
    status,
    execution_time,
    failures,
    message
FROM {{ ref('test_results') }}
WHERE status = 'fail'
ORDER BY severity DESC, execution_time DESC;
```

### 15.2 Data Quality Dashboard Metrics

```sql
-- Data quality metrics for dashboard
WITH quality_summary AS (
    SELECT 
        'SI_USERS' as table_name,
        COUNT(*) as total_records,
        SUM(CASE WHEN data_quality_score >= 0.9 THEN 1 ELSE 0 END) as high_quality_records,
        AVG(data_quality_score) as avg_quality_score
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'SI_MEETINGS',
        COUNT(*),
        SUM(CASE WHEN data_quality_score >= 0.9 THEN 1 ELSE 0 END),
        AVG(data_quality_score)
    FROM {{ ref('si_meetings') }}
)
SELECT 
    table_name,
    total_records,
    high_quality_records,
    ROUND((high_quality_records::FLOAT / total_records) * 100, 2) as quality_percentage,
    ROUND(avg_quality_score, 3) as avg_quality_score
FROM quality_summary;
```

## 16. Conclusion

This comprehensive test suite provides robust validation for the Silver layer models in the Zoom Platform Analytics System. The tests cover:

1. **Data Integrity**: Unique constraints, not null validations, and referential integrity
2. **Business Logic**: Temporal validations, calculation accuracy, and business rule enforcement
3. **Data Quality**: Format validations, range checks, and consistency validations
4. **Performance**: Large dataset handling and optimization validation
5. **Error Handling**: Comprehensive error logging and monitoring

### Implementation Recommendations:

1. **Automated Execution**: Integrate tests into CI/CD pipeline for continuous validation
2. **Monitoring**: Set up alerts for test failures and data quality degradation
3. **Documentation**: Maintain test documentation and update as business rules evolve
4. **Performance**: Monitor test execution times and optimize as needed
5. **Coverage**: Regularly review and expand test coverage based on new requirements

The test cases are designed to be maintainable, scalable, and provide comprehensive coverage of the Silver layer data quality requirements while following dbt best practices for Snowflake environments.