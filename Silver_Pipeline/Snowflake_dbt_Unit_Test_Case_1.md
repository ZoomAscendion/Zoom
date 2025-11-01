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

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and high-quality data pipelines.

## Test Coverage Overview

### Models Under Test:
- `si_users` - User data with quality validations
- `si_meetings` - Meeting data with business logic
- `si_participants` - Participant attendance data
- `si_feature_usage` - Feature usage analytics
- `si_support_tickets` - Support ticket management
- `si_billing_events` - Financial transaction data
- `si_licenses` - License management data
- `si_webinars` - Webinar analytics data
- `si_pipeline_audit` - Pipeline execution audit

---

## Test Case List

### 1. SI_USERS Model Test Cases

#### Test Case ID: TC_SI_USERS_001
**Test Case Description**: Validate USER_ID uniqueness and not null constraint
**Expected Outcome**: All USER_ID values should be unique and not null

#### Test Case ID: TC_SI_USERS_002
**Test Case Description**: Validate email format using regex pattern
**Expected Outcome**: All email addresses should follow valid email format

#### Test Case ID: TC_SI_USERS_003
**Test Case Description**: Validate PLAN_TYPE enumeration values
**Expected Outcome**: PLAN_TYPE should only contain 'FREE', 'BASIC', 'PRO', 'ENTERPRISE'

#### Test Case ID: TC_SI_USERS_004
**Test Case Description**: Validate data quality score range (0.00-1.00)
**Expected Outcome**: All DATA_QUALITY_SCORE values should be between 0.00 and 1.00

#### Test Case ID: TC_SI_USERS_005
**Test Case Description**: Validate account status derivation logic
**Expected Outcome**: ACCOUNT_STATUS should be correctly derived based on last login date

#### Test Case ID: TC_SI_USERS_006
**Test Case Description**: Validate deduplication logic
**Expected Outcome**: No duplicate USER_ID records should exist after deduplication

#### Test Case ID: TC_SI_USERS_007
**Test Case Description**: Validate data quality score calculation
**Expected Outcome**: DATA_QUALITY_SCORE should be calculated correctly based on field completeness

#### Test Case ID: TC_SI_USERS_008
**Test Case Description**: Validate registration date logic
**Expected Outcome**: REGISTRATION_DATE should not be in the future

### 2. SI_MEETINGS Model Test Cases

#### Test Case ID: TC_SI_MEETINGS_001
**Test Case Description**: Validate MEETING_ID uniqueness and not null constraint
**Expected Outcome**: All MEETING_ID values should be unique and not null

#### Test Case ID: TC_SI_MEETINGS_002
**Test Case Description**: Validate HOST_ID referential integrity
**Expected Outcome**: All HOST_ID values should exist in SI_USERS table

#### Test Case ID: TC_SI_MEETINGS_003
**Test Case Description**: Validate meeting duration calculation
**Expected Outcome**: DURATION_MINUTES should match calculated difference between START_TIME and END_TIME

#### Test Case ID: TC_SI_MEETINGS_004
**Test Case Description**: Validate meeting time logic
**Expected Outcome**: END_TIME should be greater than or equal to START_TIME

#### Test Case ID: TC_SI_MEETINGS_005
**Test Case Description**: Validate participant count accuracy
**Expected Outcome**: PARTICIPANT_COUNT should match actual count from SI_PARTICIPANTS table

#### Test Case ID: TC_SI_MEETINGS_006
**Test Case Description**: Validate meeting status derivation
**Expected Outcome**: MEETING_STATUS should be correctly derived based on timestamps

#### Test Case ID: TC_SI_MEETINGS_007
**Test Case Description**: Validate duration range constraints
**Expected Outcome**: DURATION_MINUTES should be between 1 and 1440 minutes

### 3. SI_PARTICIPANTS Model Test Cases

#### Test Case ID: TC_SI_PARTICIPANTS_001
**Test Case Description**: Validate PARTICIPANT_ID uniqueness
**Expected Outcome**: All PARTICIPANT_ID values should be unique

#### Test Case ID: TC_SI_PARTICIPANTS_002
**Test Case Description**: Validate MEETING_ID referential integrity
**Expected Outcome**: All MEETING_ID values should exist in SI_MEETINGS table

#### Test Case ID: TC_SI_PARTICIPANTS_003
**Test Case Description**: Validate USER_ID referential integrity
**Expected Outcome**: All USER_ID values should exist in SI_USERS table

#### Test Case ID: TC_SI_PARTICIPANTS_004
**Test Case Description**: Validate attendance duration calculation
**Expected Outcome**: ATTENDANCE_DURATION should match calculated difference between JOIN_TIME and LEAVE_TIME

#### Test Case ID: TC_SI_PARTICIPANTS_005
**Test Case Description**: Validate join/leave time logic
**Expected Outcome**: LEAVE_TIME should be greater than or equal to JOIN_TIME

#### Test Case ID: TC_SI_PARTICIPANTS_006
**Test Case Description**: Validate attendance duration vs meeting duration
**Expected Outcome**: ATTENDANCE_DURATION should not exceed meeting DURATION_MINUTES

### 4. SI_FEATURE_USAGE Model Test Cases

#### Test Case ID: TC_SI_FEATURE_USAGE_001
**Test Case Description**: Validate USAGE_ID uniqueness
**Expected Outcome**: All USAGE_ID values should be unique

#### Test Case ID: TC_SI_FEATURE_USAGE_002
**Test Case Description**: Validate MEETING_ID referential integrity
**Expected Outcome**: All MEETING_ID values should exist in SI_MEETINGS table

#### Test Case ID: TC_SI_FEATURE_USAGE_003
**Test Case Description**: Validate USAGE_COUNT non-negative constraint
**Expected Outcome**: All USAGE_COUNT values should be >= 0

#### Test Case ID: TC_SI_FEATURE_USAGE_004
**Test Case Description**: Validate FEATURE_CATEGORY enumeration
**Expected Outcome**: FEATURE_CATEGORY should only contain 'Audio', 'Video', 'Collaboration', 'Security'

#### Test Case ID: TC_SI_FEATURE_USAGE_005
**Test Case Description**: Validate usage duration vs meeting duration
**Expected Outcome**: USAGE_DURATION should not exceed meeting DURATION_MINUTES

### 5. SI_SUPPORT_TICKETS Model Test Cases

#### Test Case ID: TC_SI_SUPPORT_TICKETS_001
**Test Case Description**: Validate TICKET_ID uniqueness
**Expected Outcome**: All TICKET_ID values should be unique

#### Test Case ID: TC_SI_SUPPORT_TICKETS_002
**Test Case Description**: Validate USER_ID referential integrity
**Expected Outcome**: All USER_ID values should exist in SI_USERS table

#### Test Case ID: TC_SI_SUPPORT_TICKETS_003
**Test Case Description**: Validate TICKET_TYPE enumeration
**Expected Outcome**: TICKET_TYPE should only contain 'Technical', 'Billing', 'Feature Request', 'Bug Report'

#### Test Case ID: TC_SI_SUPPORT_TICKETS_004
**Test Case Description**: Validate PRIORITY_LEVEL enumeration
**Expected Outcome**: PRIORITY_LEVEL should only contain 'Low', 'Medium', 'High', 'Critical'

#### Test Case ID: TC_SI_SUPPORT_TICKETS_005
**Test Case Description**: Validate ticket date logic
**Expected Outcome**: CLOSE_DATE should be greater than or equal to OPEN_DATE when populated

#### Test Case ID: TC_SI_SUPPORT_TICKETS_006
**Test Case Description**: Validate resolution time calculation
**Expected Outcome**: RESOLUTION_TIME_HOURS should be calculated correctly in business hours

### 6. SI_BILLING_EVENTS Model Test Cases

#### Test Case ID: TC_SI_BILLING_EVENTS_001
**Test Case Description**: Validate EVENT_ID uniqueness
**Expected Outcome**: All EVENT_ID values should be unique

#### Test Case ID: TC_SI_BILLING_EVENTS_002
**Test Case Description**: Validate USER_ID referential integrity
**Expected Outcome**: All USER_ID values should exist in SI_USERS table

#### Test Case ID: TC_SI_BILLING_EVENTS_003
**Test Case Description**: Validate TRANSACTION_AMOUNT positive constraint
**Expected Outcome**: All TRANSACTION_AMOUNT values should be > 0

#### Test Case ID: TC_SI_BILLING_EVENTS_004
**Test Case Description**: Validate EVENT_TYPE enumeration
**Expected Outcome**: EVENT_TYPE should only contain 'Subscription', 'Upgrade', 'Downgrade', 'Refund'

#### Test Case ID: TC_SI_BILLING_EVENTS_005
**Test Case Description**: Validate CURRENCY_CODE format
**Expected Outcome**: CURRENCY_CODE should be valid 3-character ISO codes

#### Test Case ID: TC_SI_BILLING_EVENTS_006
**Test Case Description**: Validate INVOICE_NUMBER uniqueness
**Expected Outcome**: INVOICE_NUMBER should be unique when not null

### 7. SI_LICENSES Model Test Cases

#### Test Case ID: TC_SI_LICENSES_001
**Test Case Description**: Validate LICENSE_ID uniqueness
**Expected Outcome**: All LICENSE_ID values should be unique

#### Test Case ID: TC_SI_LICENSES_002
**Test Case Description**: Validate ASSIGNED_TO_USER_ID referential integrity
**Expected Outcome**: All ASSIGNED_TO_USER_ID values should exist in SI_USERS table

#### Test Case ID: TC_SI_LICENSES_003
**Test Case Description**: Validate LICENSE_TYPE enumeration
**Expected Outcome**: LICENSE_TYPE should only contain 'Basic', 'Pro', 'Enterprise', 'Add-on'

#### Test Case ID: TC_SI_LICENSES_004
**Test Case Description**: Validate license date logic
**Expected Outcome**: END_DATE should be greater than or equal to START_DATE

#### Test Case ID: TC_SI_LICENSES_005
**Test Case Description**: Validate LICENSE_STATUS derivation
**Expected Outcome**: LICENSE_STATUS should be correctly derived based on current date vs END_DATE

#### Test Case ID: TC_SI_LICENSES_006
**Test Case Description**: Validate UTILIZATION_PERCENTAGE range
**Expected Outcome**: UTILIZATION_PERCENTAGE should be between 0 and 100

### 8. SI_WEBINARS Model Test Cases

#### Test Case ID: TC_SI_WEBINARS_001
**Test Case Description**: Validate WEBINAR_ID uniqueness
**Expected Outcome**: All WEBINAR_ID values should be unique

#### Test Case ID: TC_SI_WEBINARS_002
**Test Case Description**: Validate HOST_ID referential integrity
**Expected Outcome**: All HOST_ID values should exist in SI_USERS table

#### Test Case ID: TC_SI_WEBINARS_003
**Test Case Description**: Validate webinar duration calculation
**Expected Outcome**: DURATION_MINUTES should match calculated difference between START_TIME and END_TIME

#### Test Case ID: TC_SI_WEBINARS_004
**Test Case Description**: Validate attendance rate calculation
**Expected Outcome**: ATTENDANCE_RATE should equal (ATTENDEES/REGISTRANTS) * 100

#### Test Case ID: TC_SI_WEBINARS_005
**Test Case Description**: Validate attendee vs registrant logic
**Expected Outcome**: ATTENDEES should not exceed REGISTRANTS

#### Test Case ID: TC_SI_WEBINARS_006
**Test Case Description**: Validate attendance rate range
**Expected Outcome**: ATTENDANCE_RATE should be between 0 and 100

---

## dbt Test Scripts

### YAML-based Schema Tests

#### models/silver/schema.yml

```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer table containing cleaned and standardized user data"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - USER_ID
      - dbt_utils.not_null_proportion:
          at_least: 0.95
    columns:
      - name: USER_ID
        description: "Unique identifier for each user account"
        tests:
          - unique
          - not_null
      - name: EMAIL
        description: "Validated and standardized email address"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1
              where: "EMAIL IS NOT NULL"
      - name: PLAN_TYPE
        description: "Standardized subscription tier"
        tests:
          - not_null
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: DATA_QUALITY_SCORE
        description: "Overall data quality score for the record (0.00 to 1.00)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0.00
              max_value: 1.00
      - name: ACCOUNT_STATUS
        description: "Current status of user account"
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: REGISTRATION_DATE
        description: "Date when the user first registered"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "<= current_date()"

  - name: si_meetings
    description: "Silver layer table containing cleaned and enriched meeting data"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - MEETING_ID
    columns:
      - name: MEETING_ID
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: HOST_ID
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: USER_ID
      - name: DURATION_MINUTES
        description: "Calculated meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 1440
      - name: START_TIME
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: END_TIME
        description: "Meeting end timestamp"
        tests:
          - not_null
      - name: DATA_QUALITY_SCORE
        description: "Overall data quality score for the record"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0.00
              max_value: 1.00

  - name: si_participants
    description: "Silver layer table containing cleaned participant attendance data"
    columns:
      - name: PARTICIPANT_ID
        description: "Unique identifier for each participant record"
        tests:
          - unique
          - not_null
      - name: MEETING_ID
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: MEETING_ID
      - name: USER_ID
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: USER_ID
      - name: JOIN_TIME
        description: "Timestamp when participant joined"
        tests:
          - not_null
      - name: ATTENDANCE_DURATION
        description: "Time participant spent in meeting (minutes)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440

  - name: si_feature_usage
    description: "Silver layer table containing standardized feature usage data"
    columns:
      - name: USAGE_ID
        description: "Unique identifier for each feature usage record"
        tests:
          - unique
          - not_null
      - name: MEETING_ID
        description: "Reference to meeting where feature was used"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: MEETING_ID
      - name: USAGE_COUNT
        description: "Number of times feature was utilized"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
      - name: FEATURE_CATEGORY
        description: "Classification of feature type"
        tests:
          - not_null
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']

  - name: si_support_tickets
    description: "Silver layer table containing standardized support ticket data"
    columns:
      - name: TICKET_ID
        description: "Unique identifier for each support ticket"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Reference to user who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: USER_ID
      - name: TICKET_TYPE
        description: "Standardized category"
        tests:
          - not_null
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: PRIORITY_LEVEL
        description: "Urgency level of ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: RESOLUTION_STATUS
        description: "Current status"
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer table containing validated billing transaction data"
    columns:
      - name: EVENT_ID
        description: "Unique identifier for each billing event"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Reference to user associated with billing event"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: USER_ID
      - name: TRANSACTION_AMOUNT
        description: "Validated monetary value"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0.01
      - name: EVENT_TYPE
        description: "Type of billing event"
        tests:
          - not_null
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
      - name: CURRENCY_CODE
        description: "ISO currency code"
        tests:
          - not_null

  - name: si_licenses
    description: "Silver layer table containing validated license data"
    columns:
      - name: LICENSE_ID
        description: "Unique identifier for each license"
        tests:
          - unique
          - not_null
      - name: ASSIGNED_TO_USER_ID
        description: "User ID to whom license is assigned"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: USER_ID
      - name: LICENSE_TYPE
        description: "Standardized category"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-on']
      - name: LICENSE_STATUS
        description: "Current state"
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: UTILIZATION_PERCENTAGE
        description: "Percentage of license features being utilized"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100

  - name: si_webinars
    description: "Silver layer table containing cleaned webinar data"
    columns:
      - name: WEBINAR_ID
        description: "Unique identifier for each webinar"
        tests:
          - unique
          - not_null
      - name: HOST_ID
        description: "User ID of the webinar host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: USER_ID
      - name: ATTENDANCE_RATE
        description: "Percentage of registrants who attended"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
      - name: REGISTRANTS
        description: "Number of registered participants"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
      - name: ATTENDEES
        description: "Number of actual attendees"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
```

### Custom SQL-based dbt Tests

#### tests/test_email_format_validation.sql

```sql
-- Test to validate email format using regex
SELECT USER_ID, EMAIL
FROM {{ ref('si_users') }}
WHERE EMAIL IS NOT NULL
  AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### tests/test_meeting_time_logic.sql

```sql
-- Test to validate meeting time logic (end_time >= start_time)
SELECT MEETING_ID, START_TIME, END_TIME
FROM {{ ref('si_meetings') }}
WHERE END_TIME < START_TIME
   OR START_TIME IS NULL
   OR END_TIME IS NULL
```

#### tests/test_duration_calculation_accuracy.sql

```sql
-- Test to validate duration calculation accuracy
SELECT 
    MEETING_ID,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    DATEDIFF('minute', START_TIME, END_TIME) AS calculated_duration
FROM {{ ref('si_meetings') }}
WHERE DURATION_MINUTES != DATEDIFF('minute', START_TIME, END_TIME)
   OR DURATION_MINUTES IS NULL
```

#### tests/test_participant_attendance_logic.sql

```sql
-- Test to validate participant attendance duration vs meeting duration
SELECT 
    p.PARTICIPANT_ID,
    p.MEETING_ID,
    p.ATTENDANCE_DURATION,
    m.DURATION_MINUTES AS meeting_duration
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.MEETING_ID = m.MEETING_ID
WHERE p.ATTENDANCE_DURATION > m.DURATION_MINUTES
   OR p.ATTENDANCE_DURATION < 0
```

#### tests/test_join_leave_time_logic.sql

```sql
-- Test to validate join/leave time logic
SELECT 
    PARTICIPANT_ID,
    JOIN_TIME,
    LEAVE_TIME
FROM {{ ref('si_participants') }}
WHERE LEAVE_TIME < JOIN_TIME
   OR JOIN_TIME IS NULL
```

#### tests/test_data_quality_score_calculation.sql

```sql
-- Test to validate data quality score calculation for users
WITH expected_scores AS (
    SELECT 
        USER_ID,
        DATA_QUALITY_SCORE,
        (
            CASE WHEN USER_NAME IS NOT NULL AND TRIM(USER_NAME) != '' THEN 0.20 ELSE 0 END +
            CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0.25 ELSE 0 END +
            CASE WHEN COMPANY IS NOT NULL AND TRIM(COMPANY) != '' THEN 0.15 ELSE 0 END +
            CASE WHEN PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 0.20 ELSE 0 END +
            CASE WHEN REGISTRATION_DATE IS NOT NULL AND REGISTRATION_DATE <= CURRENT_DATE() THEN 0.20 ELSE 0 END
        ) AS calculated_score
    FROM {{ ref('si_users') }}
)
SELECT USER_ID, DATA_QUALITY_SCORE, calculated_score
FROM expected_scores
WHERE ABS(DATA_QUALITY_SCORE - calculated_score) > 0.01
```

#### tests/test_billing_amount_validation.sql

```sql
-- Test to validate billing amounts are positive
SELECT EVENT_ID, TRANSACTION_AMOUNT
FROM {{ ref('si_billing_events') }}
WHERE TRANSACTION_AMOUNT <= 0
   OR TRANSACTION_AMOUNT IS NULL
```

#### tests/test_currency_code_format.sql

```sql
-- Test to validate currency code format (3-character ISO codes)
SELECT EVENT_ID, CURRENCY_CODE
FROM {{ ref('si_billing_events') }}
WHERE LENGTH(CURRENCY_CODE) != 3
   OR CURRENCY_CODE IS NULL
   OR NOT REGEXP_LIKE(CURRENCY_CODE, '^[A-Z]{3}$')
```

#### tests/test_license_date_logic.sql

```sql
-- Test to validate license date logic (end_date >= start_date)
SELECT LICENSE_ID, START_DATE, END_DATE
FROM {{ ref('si_licenses') }}
WHERE END_DATE < START_DATE
   OR START_DATE IS NULL
   OR END_DATE IS NULL
```

#### tests/test_webinar_attendance_rate_calculation.sql

```sql
-- Test to validate webinar attendance rate calculation
SELECT 
    WEBINAR_ID,
    REGISTRANTS,
    ATTENDEES,
    ATTENDANCE_RATE,
    CASE 
        WHEN REGISTRANTS > 0 THEN (ATTENDEES::FLOAT / REGISTRANTS * 100)
        ELSE 0
    END AS calculated_rate
FROM {{ ref('si_webinars') }}
WHERE REGISTRANTS > 0
  AND ABS(ATTENDANCE_RATE - (ATTENDEES::FLOAT / REGISTRANTS * 100)) > 0.01
```

#### tests/test_attendees_vs_registrants.sql

```sql
-- Test to validate attendees do not exceed registrants
SELECT WEBINAR_ID, REGISTRANTS, ATTENDEES
FROM {{ ref('si_webinars') }}
WHERE ATTENDEES > REGISTRANTS
   OR REGISTRANTS < 0
   OR ATTENDEES < 0
```

#### tests/test_support_ticket_date_logic.sql

```sql
-- Test to validate support ticket date logic
SELECT TICKET_ID, OPEN_DATE, CLOSE_DATE
FROM {{ ref('si_support_tickets') }}
WHERE CLOSE_DATE < OPEN_DATE
   OR OPEN_DATE > CURRENT_DATE()
```

#### tests/test_cross_table_referential_integrity.sql

```sql
-- Test to validate cross-table referential integrity
WITH orphaned_records AS (
    SELECT 'si_meetings' AS table_name, COUNT(*) AS orphaned_count
    FROM {{ ref('si_meetings') }} m
    LEFT JOIN {{ ref('si_users') }} u ON m.HOST_ID = u.USER_ID
    WHERE u.USER_ID IS NULL AND m.HOST_ID IS NOT NULL
    
    UNION ALL
    
    SELECT 'si_participants', COUNT(*)
    FROM {{ ref('si_participants') }} p
    LEFT JOIN {{ ref('si_meetings') }} m ON p.MEETING_ID = m.MEETING_ID
    WHERE m.MEETING_ID IS NULL
    
    UNION ALL
    
    SELECT 'si_feature_usage', COUNT(*)
    FROM {{ ref('si_feature_usage') }} f
    LEFT JOIN {{ ref('si_meetings') }} m ON f.MEETING_ID = m.MEETING_ID
    WHERE m.MEETING_ID IS NULL
)
SELECT table_name, orphaned_count
FROM orphaned_records
WHERE orphaned_count > 0
```

### Parameterized Tests

#### macros/test_data_quality_threshold.sql

```sql
{% macro test_data_quality_threshold(model, column_name, threshold=0.8) %}

    SELECT COUNT(*) AS failing_records
    FROM {{ model }}
    WHERE {{ column_name }} < {{ threshold }}

{% endmacro %}
```

#### Usage in schema.yml:

```yaml
models:
  - name: si_users
    tests:
      - test_data_quality_threshold:
          column_name: DATA_QUALITY_SCORE
          threshold: 0.6
```

#### macros/test_enum_values.sql

```sql
{% macro test_enum_values(model, column_name, values) %}

    SELECT {{ column_name }}, COUNT(*) AS invalid_count
    FROM {{ model }}
    WHERE {{ column_name }} NOT IN ({{ values | join(', ') }})
       OR {{ column_name }} IS NULL
    GROUP BY {{ column_name }}

{% endmacro %}
```

### Edge Case Tests

#### tests/test_edge_cases_null_handling.sql

```sql
-- Test edge cases for null handling in transformations
WITH null_tests AS (
    SELECT 'si_users' AS table_name, 'USER_NAME' AS column_name, COUNT(*) AS null_count
    FROM {{ ref('si_users') }}
    WHERE USER_NAME IS NULL OR TRIM(USER_NAME) = ''
    
    UNION ALL
    
    SELECT 'si_meetings', 'MEETING_TOPIC', COUNT(*)
    FROM {{ ref('si_meetings') }}
    WHERE MEETING_TOPIC IS NULL OR TRIM(MEETING_TOPIC) = ''
)
SELECT table_name, column_name, null_count
FROM null_tests
WHERE null_count > 0
```

#### tests/test_edge_cases_extreme_values.sql

```sql
-- Test edge cases for extreme values
SELECT 
    'meeting_duration' AS test_case,
    COUNT(*) AS extreme_value_count
FROM {{ ref('si_meetings') }}
WHERE DURATION_MINUTES > 480  -- More than 8 hours
   OR DURATION_MINUTES < 1     -- Less than 1 minute

UNION ALL

SELECT 
    'billing_amount',
    COUNT(*)
FROM {{ ref('si_billing_events') }}
WHERE TRANSACTION_AMOUNT > 10000  -- More than $10,000
   OR TRANSACTION_AMOUNT < 0.01   -- Less than 1 cent
```

### Performance Tests

#### tests/test_model_performance.sql

```sql
-- Test to monitor model performance and record counts
WITH model_stats AS (
    SELECT 
        'si_users' AS model_name,
        COUNT(*) AS record_count,
        COUNT(DISTINCT USER_ID) AS unique_keys,
        AVG(DATA_QUALITY_SCORE) AS avg_quality_score
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'si_meetings',
        COUNT(*),
        COUNT(DISTINCT MEETING_ID),
        AVG(DATA_QUALITY_SCORE)
    FROM {{ ref('si_meetings') }}
)
SELECT 
    model_name,
    record_count,
    unique_keys,
    avg_quality_score,
    CASE 
        WHEN record_count = 0 THEN 'FAIL: No records'
        WHEN record_count != unique_keys THEN 'FAIL: Duplicate keys'
        WHEN avg_quality_score < 0.8 THEN 'WARN: Low quality score'
        ELSE 'PASS'
    END AS test_result
FROM model_stats
```

## Test Execution Guidelines

### 1. **Automated Test Execution**

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users

# Run tests with specific tag
dbt test --select tag:data_quality

# Run tests excluding specific models
dbt test --exclude si_pipeline_audit
```

### 2. **Test Results Monitoring**

- All test results are tracked in dbt's `run_results.json`
- Failed tests should trigger alerts in monitoring systems
- Test results should be logged in Snowflake audit schema
- Performance metrics should be tracked over time

### 3. **Error Handling and Remediation**

- Critical test failures should halt pipeline execution
- Warning-level failures should be logged but allow pipeline continuation
- All test failures should be logged in `SI_DATA_QUALITY_ERRORS` table
- Remediation procedures should be documented for each test type

### 4. **Test Maintenance**

- Tests should be reviewed and updated with each model change
- New business rules should trigger new test creation
- Test performance should be monitored and optimized
- Test coverage should be measured and maintained above 90%

## Conclusion

These comprehensive unit test cases ensure the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver Layer dbt models in Snowflake. The tests cover:

- **Data Quality**: Validation of data types, formats, and business rules
- **Referential Integrity**: Cross-table relationship validation
- **Business Logic**: Calculation accuracy and constraint validation
- **Edge Cases**: Null handling, extreme values, and boundary conditions
- **Performance**: Model execution monitoring and optimization

Regular execution of these tests will maintain high data quality standards and prevent production issues in the analytics pipeline.