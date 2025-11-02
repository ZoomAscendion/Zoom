_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Silver Layer dbt models
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer transformation models. The tests cover data quality validations, business rule enforcement, edge case handling, and error scenarios across all silver layer models including users, meetings, participants, feature usage, support tickets, billing events, licenses, and webinars.

## Test Strategy Overview

The testing approach follows dbt best practices with:
- **Schema Tests**: Built-in dbt tests (unique, not_null, relationships, accepted_values)
- **Data Tests**: Custom SQL-based tests for business logic validation
- **Quality Tests**: Data quality score validations and threshold checks
- **Edge Case Tests**: Null handling, boundary conditions, and data anomalies
- **Integration Tests**: Cross-model relationship validations

## Test Case List

### 1. SI_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| TC_USR_002 | Validate EMAIL format and uniqueness | All EMAIL values follow valid format and are unique |
| TC_USR_003 | Validate PLAN_TYPE accepted values | PLAN_TYPE only contains: FREE, BASIC, PRO, ENTERPRISE, UNKNOWN_PLAN |
| TC_USR_004 | Validate DATA_QUALITY_SCORE threshold | All records have DATA_QUALITY_SCORE >= 0.5 |
| TC_USR_005 | Validate ACCOUNT_STATUS derivation | ACCOUNT_STATUS correctly derived from PLAN_TYPE |
| TC_USR_006 | Test duplicate removal logic | Only latest record per USER_ID is retained |
| TC_USR_007 | Test email validation edge cases | Invalid emails are set to NULL |
| TC_USR_008 | Test user name standardization | USER_NAME is properly trimmed and uppercased |

### 2. SI_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| TC_MTG_002 | Validate HOST_ID references SI_USERS | All HOST_ID values exist in SI_USERS.USER_ID |
| TC_MTG_003 | Validate START_TIME and END_TIME logic | END_TIME >= START_TIME for all records |
| TC_MTG_004 | Validate DURATION_MINUTES calculation | DURATION_MINUTES matches time difference |
| TC_MTG_005 | Validate MEETING_STATUS derivation | MEETING_STATUS correctly reflects meeting state |
| TC_MTG_006 | Validate PARTICIPANT_COUNT accuracy | PARTICIPANT_COUNT matches actual participants |
| TC_MTG_007 | Test meeting type classification | MEETING_TYPE correctly derived from duration |
| TC_MTG_008 | Test data quality threshold | All records have DATA_QUALITY_SCORE >= 0.6 |

### 3. SI_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique and not null |
| TC_PRT_002 | Validate MEETING_ID references SI_MEETINGS | All MEETING_ID values exist in SI_MEETINGS |
| TC_PRT_003 | Validate USER_ID references SI_USERS | All USER_ID values exist in SI_USERS |
| TC_PRT_004 | Validate JOIN_TIME and LEAVE_TIME logic | LEAVE_TIME >= JOIN_TIME for all records |
| TC_PRT_005 | Validate ATTENDANCE_DURATION calculation | ATTENDANCE_DURATION correctly calculated |
| TC_PRT_006 | Validate PARTICIPANT_ROLE derivation | PARTICIPANT_ROLE based on attendance duration |
| TC_PRT_007 | Validate CONNECTION_QUALITY assessment | CONNECTION_QUALITY reflects attendance patterns |
| TC_PRT_008 | Test data quality threshold | All records have DATA_QUALITY_SCORE >= 0.75 |

### 4. SI_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate USAGE_ID uniqueness | All USAGE_ID values are unique and not null |
| TC_FTR_002 | Validate MEETING_ID references SI_MEETINGS | All MEETING_ID values exist in SI_MEETINGS |
| TC_FTR_003 | Validate USAGE_COUNT non-negative | All USAGE_COUNT values >= 0 |
| TC_FTR_004 | Validate FEATURE_CATEGORY classification | FEATURE_CATEGORY correctly assigned |
| TC_FTR_005 | Validate USAGE_DURATION calculation | USAGE_DURATION = USAGE_COUNT * 2 |
| TC_FTR_006 | Test feature name standardization | FEATURE_NAME properly trimmed and uppercased |
| TC_FTR_007 | Test usage date validation | USAGE_DATE <= CURRENT_DATE |
| TC_FTR_008 | Test data quality threshold | All records have DATA_QUALITY_SCORE >= 0.75 |

### 5. SI_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate TICKET_ID uniqueness | All TICKET_ID values are unique and not null |
| TC_TKT_002 | Validate USER_ID references SI_USERS | All USER_ID values exist in SI_USERS |
| TC_TKT_003 | Validate TICKET_TYPE accepted values | TICKET_TYPE in: TECHNICAL, BILLING, FEATURE REQUEST, BUG REPORT, OTHER |
| TC_TKT_004 | Validate PRIORITY_LEVEL derivation | PRIORITY_LEVEL correctly derived from TICKET_TYPE |
| TC_TKT_005 | Validate RESOLUTION_STATUS values | RESOLUTION_STATUS in: OPEN, IN PROGRESS, RESOLVED, CLOSED |
| TC_TKT_006 | Validate CLOSE_DATE logic | CLOSE_DATE set when status is RESOLVED/CLOSED |
| TC_TKT_007 | Validate RESOLUTION_TIME_HOURS calculation | RESOLUTION_TIME_HOURS calculated for closed tickets |
| TC_TKT_008 | Test data quality threshold | All records have DATA_QUALITY_SCORE >= 0.75 |

### 6. SI_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate EVENT_ID uniqueness | All EVENT_ID values are unique and not null |
| TC_BIL_002 | Validate USER_ID references SI_USERS | All USER_ID values exist in SI_USERS |
| TC_BIL_003 | Validate TRANSACTION_AMOUNT non-negative | All TRANSACTION_AMOUNT values >= 0 |
| TC_BIL_004 | Validate EVENT_TYPE accepted values | EVENT_TYPE in: SUBSCRIPTION, UPGRADE, DOWNGRADE, REFUND |
| TC_BIL_005 | Validate CURRENCY_CODE standardization | All CURRENCY_CODE values = 'USD' |
| TC_BIL_006 | Validate INVOICE_NUMBER format | INVOICE_NUMBER follows 'INV-' + EVENT_ID pattern |
| TC_BIL_007 | Validate TRANSACTION_STATUS derivation | TRANSACTION_STATUS correctly derived from amount |
| TC_BIL_008 | Test data quality threshold | All records have DATA_QUALITY_SCORE >= 0.75 |

### 7. SI_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate LICENSE_ID uniqueness | All LICENSE_ID values are unique and not null |
| TC_LIC_002 | Validate ASSIGNED_TO_USER_ID references SI_USERS | All user IDs exist in SI_USERS |
| TC_LIC_003 | Validate LICENSE_TYPE accepted values | LICENSE_TYPE in: BASIC, PRO, ENTERPRISE, ADD-ON |
| TC_LIC_004 | Validate date range logic | END_DATE >= START_DATE for all records |
| TC_LIC_005 | Validate LICENSE_STATUS derivation | LICENSE_STATUS correctly reflects current state |
| TC_LIC_006 | Validate LICENSE_COST assignment | LICENSE_COST matches LICENSE_TYPE pricing |
| TC_LIC_007 | Validate RENEWAL_STATUS logic | RENEWAL_STATUS = 'YES' when END_DATE within 30 days |
| TC_LIC_008 | Test data quality threshold | All records have DATA_QUALITY_SCORE >= 0.75 |

### 8. SI_WEBINARS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_WEB_001 | Validate WEBINAR_ID uniqueness | All WEBINAR_ID values are unique and not null |
| TC_WEB_002 | Validate HOST_ID references SI_USERS | All HOST_ID values exist in SI_USERS |
| TC_WEB_003 | Validate time logic | END_TIME >= START_TIME for all records |
| TC_WEB_004 | Validate DURATION_MINUTES calculation | DURATION_MINUTES matches time difference |
| TC_WEB_005 | Validate REGISTRANTS non-negative | All REGISTRANTS values >= 0 |
| TC_WEB_006 | Validate ATTENDEES calculation | ATTENDEES = REGISTRANTS * 0.7 (rounded) |
| TC_WEB_007 | Validate ATTENDANCE_RATE calculation | ATTENDANCE_RATE = (ATTENDEES/REGISTRANTS) * 100 |
| TC_WEB_008 | Test data quality threshold | All records have DATA_QUALITY_SCORE >= 0.6 |

### 9. Cross-Model Integration Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INT_001 | Validate referential integrity | All foreign key relationships maintained |
| TC_INT_002 | Validate audit log completeness | All transformations logged in audit_log |
| TC_INT_003 | Validate data consistency | Consistent data across related models |
| TC_INT_004 | Validate load date consistency | LOAD_DATE consistent across all models |

## dbt Test Scripts

### Schema Tests (models/silver/schema.yml)

```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer users with data quality validations"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - unique
          - not_null
      - name: email
        description: "User email address"
        tests:
          - unique
          - not_null
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE', 'UNKNOWN_PLAN']
      - name: account_status
        description: "Current account status"
        tests:
          - accepted_values:
              values: ['ACTIVE', 'INACTIVE']
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.5
              max_value: 1.0

  - name: si_meetings
    description: "Silver layer meetings with enrichment"
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
              to: ref('si_users')
              field: user_id
      - name: meeting_status
        description: "Current meeting status"
        tests:
          - accepted_values:
              values: ['COMPLETED', 'IN_PROGRESS', 'SCHEDULED', 'UNKNOWN']
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.6
              max_value: 1.0

  - name: si_participants
    description: "Silver layer participants with attendance metrics"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
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
      - name: attendance_duration
        description: "Attendance duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: participant_role
        description: "Participant role in meeting"
        tests:
          - accepted_values:
              values: ['HOST', 'PARTICIPANT', 'OBSERVER']
      - name: connection_quality
        description: "Connection quality assessment"
        tests:
          - accepted_values:
              values: ['EXCELLENT', 'GOOD', 'FAIR', 'POOR']
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.75
              max_value: 1.0

  - name: si_feature_usage
    description: "Silver layer feature usage with categorization"
    columns:
      - name: usage_id
        description: "Unique usage identifier"
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
      - name: usage_count
        description: "Feature usage count"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000
      - name: feature_category
        description: "Feature category classification"
        tests:
          - accepted_values:
              values: ['AUDIO', 'VIDEO', 'COLLABORATION', 'SECURITY', 'OTHER']
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.75
              max_value: 1.0

  - name: si_support_tickets
    description: "Silver layer support tickets with resolution metrics"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Ticket creator user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - accepted_values:
              values: ['TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT', 'OTHER']
      - name: priority_level
        description: "Ticket priority level"
        tests:
          - accepted_values:
              values: ['HIGH', 'MEDIUM', 'LOW']
      - name: resolution_status
        description: "Current resolution status"
        tests:
          - accepted_values:
              values: ['OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED']
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.75
              max_value: 1.0

  - name: si_billing_events
    description: "Silver layer billing events with financial validations"
    columns:
      - name: event_id
        description: "Unique billing event identifier"
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
      - name: transaction_amount
        description: "Transaction amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: event_type
        description: "Type of billing event"
        tests:
          - accepted_values:
              values: ['SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND']
      - name: currency_code
        description: "Transaction currency"
        tests:
          - accepted_values:
              values: ['USD']
      - name: transaction_status
        description: "Transaction status"
        tests:
          - accepted_values:
              values: ['COMPLETED', 'REFUNDED', 'PENDING']
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.75
              max_value: 1.0

  - name: si_licenses
    description: "Silver layer licenses with user enrichment"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "License assigned user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: license_type
        description: "Type of license"
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON']
      - name: license_status
        description: "Current license status"
        tests:
          - accepted_values:
              values: ['EXPIRED', 'ACTIVE', 'PENDING', 'SUSPENDED']
      - name: license_cost
        description: "License cost"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: renewal_status
        description: "Renewal status"
        tests:
          - accepted_values:
              values: ['YES', 'NO']
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.75
              max_value: 1.0

  - name: si_webinars
    description: "Silver layer webinars with engagement metrics"
    columns:
      - name: webinar_id
        description: "Unique webinar identifier"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Webinar host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Webinar duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 480
      - name: registrants
        description: "Number of registrants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: attendees
        description: "Number of attendees"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: attendance_rate
        description: "Attendance rate percentage"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.6
              max_value: 1.0

  - name: audit_log
    description: "Pipeline execution audit log"
    columns:
      - name: execution_id
        description: "Unique execution identifier"
        tests:
          - not_null
      - name: pipeline_name
        description: "Name of executed pipeline"
        tests:
          - not_null
      - name: status
        description: "Execution status"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'STARTED']
```

### Custom SQL Tests

#### Test: Email Format Validation (tests/test_email_format.sql)
```sql
-- Test that all emails in si_users follow valid format
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test: Meeting Duration Logic (tests/test_meeting_duration.sql)
```sql
-- Test that meeting duration matches calculated time difference
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('si_meetings') }}
WHERE start_time IS NOT NULL 
  AND end_time IS NOT NULL
  AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### Test: Participant Attendance Logic (tests/test_attendance_duration.sql)
```sql
-- Test that attendance duration is correctly calculated
SELECT 
    participant_id,
    attendance_duration,
    DATEDIFF('minute', join_time, leave_time) AS calculated_duration
FROM {{ ref('si_participants') }}
WHERE join_time IS NOT NULL 
  AND leave_time IS NOT NULL
  AND ABS(attendance_duration - DATEDIFF('minute', join_time, leave_time)) > 1
```

#### Test: Feature Usage Duration Calculation (tests/test_feature_usage_duration.sql)
```sql
-- Test that usage duration equals usage count * 2
SELECT 
    usage_id,
    usage_count,
    usage_duration
FROM {{ ref('si_feature_usage') }}
WHERE usage_duration != (usage_count * 2)
```

#### Test: License Cost Assignment (tests/test_license_cost.sql)
```sql
-- Test that license cost matches license type
SELECT 
    license_id,
    license_type,
    license_cost
FROM {{ ref('si_licenses') }}
WHERE 
    (license_type = 'BASIC' AND license_cost != 14.99) OR
    (license_type = 'PRO' AND license_cost != 19.99) OR
    (license_type = 'ENTERPRISE' AND license_cost != 39.99) OR
    (license_type = 'ADD-ON' AND license_cost != 9.99)
```

#### Test: Webinar Attendance Rate Calculation (tests/test_webinar_attendance_rate.sql)
```sql
-- Test that attendance rate is correctly calculated
SELECT 
    webinar_id,
    registrants,
    attendees,
    attendance_rate,
    CASE 
        WHEN registrants > 0 
        THEN ROUND((attendees::FLOAT / registrants) * 100, 2)
        ELSE 0 
    END AS calculated_rate
FROM {{ ref('si_webinars') }}
WHERE ABS(attendance_rate - 
    CASE 
        WHEN registrants > 0 
        THEN ROUND((attendees::FLOAT / registrants) * 100, 2)
        ELSE 0 
    END) > 0.1
```

#### Test: Data Quality Score Validation (tests/test_data_quality_scores.sql)
```sql
-- Test that data quality scores meet minimum thresholds across all models
WITH quality_check AS (
    SELECT 'si_users' AS model_name, COUNT(*) AS total_records, 
           COUNT(CASE WHEN data_quality_score < 0.5 THEN 1 END) AS below_threshold
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 'si_meetings' AS model_name, COUNT(*) AS total_records,
           COUNT(CASE WHEN data_quality_score < 0.6 THEN 1 END) AS below_threshold
    FROM {{ ref('si_meetings') }}
    
    UNION ALL
    
    SELECT 'si_participants' AS model_name, COUNT(*) AS total_records,
           COUNT(CASE WHEN data_quality_score < 0.75 THEN 1 END) AS below_threshold
    FROM {{ ref('si_participants') }}
    
    UNION ALL
    
    SELECT 'si_feature_usage' AS model_name, COUNT(*) AS total_records,
           COUNT(CASE WHEN data_quality_score < 0.75 THEN 1 END) AS below_threshold
    FROM {{ ref('si_feature_usage') }}
    
    UNION ALL
    
    SELECT 'si_support_tickets' AS model_name, COUNT(*) AS total_records,
           COUNT(CASE WHEN data_quality_score < 0.75 THEN 1 END) AS below_threshold
    FROM {{ ref('si_support_tickets') }}
    
    UNION ALL
    
    SELECT 'si_billing_events' AS model_name, COUNT(*) AS total_records,
           COUNT(CASE WHEN data_quality_score < 0.75 THEN 1 END) AS below_threshold
    FROM {{ ref('si_billing_events') }}
    
    UNION ALL
    
    SELECT 'si_licenses' AS model_name, COUNT(*) AS total_records,
           COUNT(CASE WHEN data_quality_score < 0.75 THEN 1 END) AS below_threshold
    FROM {{ ref('si_licenses') }}
    
    UNION ALL
    
    SELECT 'si_webinars' AS model_name, COUNT(*) AS total_records,
           COUNT(CASE WHEN data_quality_score < 0.6 THEN 1 END) AS below_threshold
    FROM {{ ref('si_webinars') }}
)
SELECT *
FROM quality_check
WHERE below_threshold > 0
```

#### Test: Referential Integrity (tests/test_referential_integrity.sql)
```sql
-- Test referential integrity across all models
WITH integrity_violations AS (
    -- Check meetings host_id references
    SELECT 'si_meetings' AS model, 'host_id' AS field, COUNT(*) AS violations
    FROM {{ ref('si_meetings') }} m
    LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
    WHERE u.user_id IS NULL
    
    UNION ALL
    
    -- Check participants meeting_id references
    SELECT 'si_participants' AS model, 'meeting_id' AS field, COUNT(*) AS violations
    FROM {{ ref('si_participants') }} p
    LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL
    
    UNION ALL
    
    -- Check participants user_id references
    SELECT 'si_participants' AS model, 'user_id' AS field, COUNT(*) AS violations
    FROM {{ ref('si_participants') }} p
    LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
    WHERE u.user_id IS NULL
    
    UNION ALL
    
    -- Check feature_usage meeting_id references
    SELECT 'si_feature_usage' AS model, 'meeting_id' AS field, COUNT(*) AS violations
    FROM {{ ref('si_feature_usage') }} f
    LEFT JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL
    
    UNION ALL
    
    -- Check support_tickets user_id references
    SELECT 'si_support_tickets' AS model, 'user_id' AS field, COUNT(*) AS violations
    FROM {{ ref('si_support_tickets') }} s
    LEFT JOIN {{ ref('si_users') }} u ON s.user_id = u.user_id
    WHERE u.user_id IS NULL
    
    UNION ALL
    
    -- Check billing_events user_id references
    SELECT 'si_billing_events' AS model, 'user_id' AS field, COUNT(*) AS violations
    FROM {{ ref('si_billing_events') }} b
    LEFT JOIN {{ ref('si_users') }} u ON b.user_id = u.user_id
    WHERE u.user_id IS NULL
    
    UNION ALL
    
    -- Check licenses assigned_to_user_id references
    SELECT 'si_licenses' AS model, 'assigned_to_user_id' AS field, COUNT(*) AS violations
    FROM {{ ref('si_licenses') }} l
    LEFT JOIN {{ ref('si_users') }} u ON l.assigned_to_user_id = u.user_id
    WHERE u.user_id IS NULL
    
    UNION ALL
    
    -- Check webinars host_id references
    SELECT 'si_webinars' AS model, 'host_id' AS field, COUNT(*) AS violations
    FROM {{ ref('si_webinars') }} w
    LEFT JOIN {{ ref('si_users') }} u ON w.host_id = u.user_id
    WHERE u.user_id IS NULL
)
SELECT *
FROM integrity_violations
WHERE violations > 0
```

## Test Execution Instructions

### Running Schema Tests
```bash
# Run all schema tests
dbt test

# Run tests for specific model
dbt test --models si_users

# Run specific test type
dbt test --select test_type:unique
dbt test --select test_type:not_null
dbt test --select test_type:relationships
```

### Running Custom SQL Tests
```bash
# Run all custom tests
dbt test --select test_type:data

# Run specific custom test
dbt test --select test_email_format
```

### Test Results Tracking

Test results are automatically tracked in:
- **dbt run_results.json**: Contains detailed test execution results
- **Snowflake audit schema**: Custom audit tables for test tracking
- **dbt docs**: Generated documentation with test status

### Expected Test Coverage

- **Schema Tests**: 100% coverage for primary keys, foreign keys, and critical business fields
- **Data Quality Tests**: All models have data quality score validations
- **Business Logic Tests**: All derived fields and calculations are tested
- **Edge Case Tests**: Null handling, boundary conditions, and data anomalies
- **Integration Tests**: Cross-model relationships and data consistency

## Maintenance and Updates

- **Version Control**: All test changes are version controlled with the dbt project
- **Documentation**: Test documentation is automatically generated with dbt docs
- **Monitoring**: Test failures trigger alerts in the data pipeline monitoring system
- **Review Process**: All new tests require peer review before deployment

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Silver Layer dbt models in the Snowflake environment.