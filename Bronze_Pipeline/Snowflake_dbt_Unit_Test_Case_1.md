_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Description

This document contains comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer Pipeline dbt models that run in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Coverage Overview

The test suite covers the following bronze layer models:
- `bz_audit_log` - Audit and process tracking
- `bz_billing_events` - Billing and payment events
- `bz_feature_usage` - Feature usage tracking
- `bz_licenses` - License management
- `bz_meetings` - Meeting information
- `bz_participants` - Meeting participants
- `bz_support_tickets` - Support tickets
- `bz_users` - User accounts
- `bz_webinars` - Webinar data

## Test Case List

### 1. bz_audit_log Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_AUDIT_001 | Verify audit log table structure creation | Table created with correct schema |
| BZ_AUDIT_002 | Test audit log insertion via pre/post hooks | Audit records inserted for each model run |
| BZ_AUDIT_003 | Validate processing time calculation | Processing time calculated correctly |
| BZ_AUDIT_004 | Test status tracking (STARTED/COMPLETED/FAILED) | Status updates properly |

### 2. bz_billing_events Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_BILL_001 | Valid billing event transformation | All valid records processed |
| BZ_BILL_002 | Missing USER_ID handling | Records with null USER_ID filtered out |
| BZ_BILL_003 | Missing EVENT_TYPE handling | Records with null EVENT_TYPE filtered out |
| BZ_BILL_004 | Missing AMOUNT handling | Records with null AMOUNT filtered out |
| BZ_BILL_005 | Missing EVENT_DATE handling | Records with null EVENT_DATE filtered out |
| BZ_BILL_006 | Data type casting validation | Proper data types applied |
| BZ_BILL_007 | Amount precision validation | AMOUNT field has correct precision (10,2) |

### 3. bz_feature_usage Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_FEAT_001 | Valid feature usage transformation | All valid records processed |
| BZ_FEAT_002 | Missing MEETING_ID handling | Records with null MEETING_ID filtered out |
| BZ_FEAT_003 | Missing FEATURE_NAME handling | Records with null FEATURE_NAME filtered out |
| BZ_FEAT_004 | Missing USAGE_COUNT handling | Records with null USAGE_COUNT filtered out |
| BZ_FEAT_005 | Missing USAGE_DATE handling | Records with null USAGE_DATE filtered out |
| BZ_FEAT_006 | Usage count validation | USAGE_COUNT is non-negative integer |

### 4. bz_licenses Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_LIC_001 | Valid license transformation | All valid records processed |
| BZ_LIC_002 | Missing LICENSE_TYPE handling | Records with null LICENSE_TYPE filtered out |
| BZ_LIC_003 | Missing START_DATE handling | Records with null START_DATE filtered out |
| BZ_LIC_004 | Missing END_DATE handling | Records with null END_DATE filtered out |
| BZ_LIC_005 | Invalid date range handling | Records where START_DATE > END_DATE filtered out |
| BZ_LIC_006 | License assignment validation | ASSIGNED_TO_USER_ID properly mapped |

### 5. bz_meetings Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_MEET_001 | Valid meeting transformation | All valid records processed |
| BZ_MEET_002 | Missing HOST_ID handling | Records with null HOST_ID filtered out |
| BZ_MEET_003 | Missing MEETING_TOPIC handling | Records with null MEETING_TOPIC filtered out |
| BZ_MEET_004 | Missing START_TIME handling | Records with null START_TIME filtered out |
| BZ_MEET_005 | Missing END_TIME handling | Records with null END_TIME filtered out |
| BZ_MEET_006 | Invalid time range handling | Records where START_TIME > END_TIME filtered out |
| BZ_MEET_007 | Invalid duration handling | Records with negative DURATION_MINUTES filtered out |

### 6. bz_participants Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_PART_001 | Valid participant transformation | All valid records processed |
| BZ_PART_002 | Missing MEETING_ID handling | Records with null MEETING_ID filtered out |
| BZ_PART_003 | Missing USER_ID handling | Records with null USER_ID filtered out |
| BZ_PART_004 | Missing JOIN_TIME handling | Records with null JOIN_TIME filtered out |
| BZ_PART_005 | Missing LEAVE_TIME handling | Records with null LEAVE_TIME filtered out |
| BZ_PART_006 | Invalid time range handling | Records where JOIN_TIME > LEAVE_TIME filtered out |

### 7. bz_support_tickets Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_SUPP_001 | Valid support ticket transformation | All valid records processed |
| BZ_SUPP_002 | Missing USER_ID handling | Records with null USER_ID filtered out |
| BZ_SUPP_003 | Missing TICKET_TYPE handling | Records with null TICKET_TYPE filtered out |
| BZ_SUPP_004 | Missing RESOLUTION_STATUS handling | Records with null RESOLUTION_STATUS filtered out |
| BZ_SUPP_005 | Missing OPEN_DATE handling | Records with null OPEN_DATE filtered out |

### 8. bz_users Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_USER_001 | Valid user transformation | All valid records processed |
| BZ_USER_002 | Missing USER_NAME handling | Records with null USER_NAME filtered out |
| BZ_USER_003 | Missing EMAIL handling | Records with null EMAIL filtered out |
| BZ_USER_004 | Missing PLAN_TYPE handling | Records with null PLAN_TYPE filtered out |
| BZ_USER_005 | Invalid email format handling | Records with invalid email format filtered out |
| BZ_USER_006 | Email format validation | EMAIL contains '@' symbol |

### 9. bz_webinars Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_WEB_001 | Valid webinar transformation | All valid records processed |
| BZ_WEB_002 | Missing HOST_ID handling | Records with null HOST_ID filtered out |
| BZ_WEB_003 | Missing WEBINAR_TOPIC handling | Records with null WEBINAR_TOPIC filtered out |
| BZ_WEB_004 | Missing START_TIME handling | Records with null START_TIME filtered out |
| BZ_WEB_005 | Missing END_TIME handling | Records with null END_TIME filtered out |
| BZ_WEB_006 | Invalid time range handling | Records where START_TIME > END_TIME filtered out |
| BZ_WEB_007 | Invalid registrants count handling | Records with negative REGISTRANTS filtered out |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  - name: bz_audit_log
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id IS NOT NULL"
      - dbt_utils.expression_is_true:
          expression: "source_table IS NOT NULL"
      - dbt_utils.expression_is_true:
          expression: "load_timestamp IS NOT NULL"
      - dbt_utils.expression_is_true:
          expression: "status IN ('STARTED', 'COMPLETED', 'FAILED', 'INITIALIZED')"
    columns:
      - name: record_id
        tests:
          - unique
          - not_null
      - name: source_table
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: status
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'INITIALIZED']

  - name: bz_billing_events
    tests:
      - dbt_utils.expression_is_true:
          expression: "amount >= 0"
      - dbt_utils.expression_is_true:
          expression: "event_date <= CURRENT_DATE()"
    columns:
      - name: user_id
        tests:
          - not_null
      - name: event_type
        tests:
          - not_null
      - name: amount
        tests:
          - not_null
      - name: event_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_feature_usage
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_count >= 0"
      - dbt_utils.expression_is_true:
          expression: "usage_date <= CURRENT_DATE()"
    columns:
      - name: meeting_id
        tests:
          - not_null
      - name: feature_name
        tests:
          - not_null
      - name: usage_count
        tests:
          - not_null
      - name: usage_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_licenses
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= end_date"
      - dbt_utils.expression_is_true:
          expression: "start_date <= CURRENT_DATE()"
    columns:
      - name: license_type
        tests:
          - not_null
      - name: start_date
        tests:
          - not_null
      - name: end_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time <= end_time"
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0"
    columns:
      - name: host_id
        tests:
          - not_null
      - name: meeting_topic
        tests:
          - not_null
      - name: start_time
        tests:
          - not_null
      - name: end_time
        tests:
          - not_null
      - name: duration_minutes
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_participants
    tests:
      - dbt_utils.expression_is_true:
          expression: "join_time <= leave_time"
    columns:
      - name: meeting_id
        tests:
          - not_null
      - name: user_id
        tests:
          - not_null
      - name: join_time
        tests:
          - not_null
      - name: leave_time
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_support_tickets
    tests:
      - dbt_utils.expression_is_true:
          expression: "open_date <= CURRENT_DATE()"
    columns:
      - name: user_id
        tests:
          - not_null
      - name: ticket_type
        tests:
          - not_null
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']
      - name: open_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "email LIKE '%@%'"
    columns:
      - name: user_name
        tests:
          - not_null
      - name: email
        tests:
          - not_null
      - name: plan_type
        tests:
          - not_null
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE']
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_webinars
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time <= end_time"
      - dbt_utils.expression_is_true:
          expression: "registrants >= 0"
    columns:
      - name: host_id
        tests:
          - not_null
      - name: webinar_topic
        tests:
          - not_null
      - name: start_time
        tests:
          - not_null
      - name: end_time
        tests:
          - not_null
      - name: registrants
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### 1. Data Quality Test for Billing Events

```sql
-- tests/test_billing_events_data_quality.sql
-- Test to ensure billing events have valid amounts and dates

SELECT 
    user_id,
    event_type,
    amount,
    event_date
FROM {{ ref('bz_billing_events') }}
WHERE 
    amount < 0 
    OR event_date > CURRENT_DATE()
    OR user_id IS NULL
    OR event_type IS NULL
```

#### 2. Meeting Duration Consistency Test

```sql
-- tests/test_meeting_duration_consistency.sql
-- Test to ensure meeting duration matches calculated time difference

SELECT 
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE 
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
    OR start_time > end_time
```

#### 3. License Validity Test

```sql
-- tests/test_license_validity.sql
-- Test to ensure license dates are logical and valid

SELECT 
    license_type,
    assigned_to_user_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE 
    start_date > end_date
    OR start_date > CURRENT_DATE() + INTERVAL '1 year'
    OR end_date < start_date
```

#### 4. Participant Session Validation Test

```sql
-- tests/test_participant_session_validation.sql
-- Test to ensure participant join/leave times are logical

SELECT 
    meeting_id,
    user_id,
    join_time,
    leave_time,
    DATEDIFF('minute', join_time, leave_time) AS session_duration
FROM {{ ref('bz_participants') }}
WHERE 
    join_time > leave_time
    OR DATEDIFF('hour', join_time, leave_time) > 24  -- Sessions longer than 24 hours
    OR join_time IS NULL
    OR leave_time IS NULL
```

#### 5. Email Format Validation Test

```sql
-- tests/test_email_format_validation.sql
-- Test to ensure all email addresses have valid format

SELECT 
    user_name,
    email,
    company,
    plan_type
FROM {{ ref('bz_users') }}
WHERE 
    email NOT LIKE '%@%'
    OR email NOT LIKE '%.%'
    OR LENGTH(email) < 5
    OR email LIKE '%..%'
    OR email LIKE '.%'
    OR email LIKE '%.'  
```

#### 6. Feature Usage Anomaly Detection Test

```sql
-- tests/test_feature_usage_anomalies.sql
-- Test to detect unusual feature usage patterns

SELECT 
    meeting_id,
    feature_name,
    usage_count,
    usage_date
FROM {{ ref('bz_feature_usage') }}
WHERE 
    usage_count > 1000  -- Unusually high usage count
    OR usage_count < 0
    OR usage_date > CURRENT_DATE()
    OR usage_date < '2020-01-01'  -- Dates before Zoom became popular
```

#### 7. Webinar Registration Validation Test

```sql
-- tests/test_webinar_registration_validation.sql
-- Test to ensure webinar registrant counts are reasonable

SELECT 
    host_id,
    webinar_topic,
    start_time,
    end_time,
    registrants
FROM {{ ref('bz_webinars') }}
WHERE 
    registrants < 0
    OR registrants > 100000  -- Unusually high registration count
    OR start_time > end_time
    OR DATEDIFF('hour', start_time, end_time) > 8  -- Webinars longer than 8 hours
```

#### 8. Cross-Model Referential Integrity Test

```sql
-- tests/test_referential_integrity.sql
-- Test to ensure referential integrity between models

WITH missing_users AS (
    SELECT DISTINCT user_id
    FROM {{ ref('bz_billing_events') }}
    WHERE user_id NOT IN (
        SELECT DISTINCT user_id 
        FROM {{ source('raw', 'users') }}
        WHERE user_id IS NOT NULL
    )
),
missing_meetings AS (
    SELECT DISTINCT meeting_id
    FROM {{ ref('bz_participants') }}
    WHERE meeting_id NOT IN (
        SELECT DISTINCT meeting_id 
        FROM {{ source('raw', 'meetings') }}
        WHERE meeting_id IS NOT NULL
    )
)
SELECT 'Missing Users' as issue_type, user_id as missing_id FROM missing_users
UNION ALL
SELECT 'Missing Meetings' as issue_type, meeting_id as missing_id FROM missing_meetings
```

#### 9. Audit Log Completeness Test

```sql
-- tests/test_audit_log_completeness.sql
-- Test to ensure audit log captures all model runs

SELECT 
    source_table,
    COUNT(*) as run_count,
    MAX(load_timestamp) as last_run,
    MIN(load_timestamp) as first_run
FROM {{ ref('bz_audit_log') }}
WHERE status = 'COMPLETED'
GROUP BY source_table
HAVING COUNT(*) = 0  -- Tables that have never completed successfully
```

#### 10. Data Freshness Validation Test

```sql
-- tests/test_data_freshness.sql
-- Test to ensure data is not stale

WITH freshness_check AS (
    SELECT 
        'bz_billing_events' as table_name,
        MAX(load_timestamp) as last_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        MAX(load_timestamp) as last_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_users' as table_name,
        MAX(load_timestamp) as last_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_users') }}
)
SELECT *
FROM freshness_check
WHERE hours_since_load > 24  -- Data older than 24 hours
```

## Test Execution Instructions

### Running Schema Tests
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select bz_billing_events

# Run tests with specific tag
dbt test --select tag:data_quality

# Run only custom SQL tests
dbt test --select test_type:generic
```

### Running Custom SQL Tests
```bash
# Run specific custom test
dbt test --select test_billing_events_data_quality

# Run all custom tests
dbt test --select tests/
```

### Test Results Monitoring

Test results are automatically tracked in:
- `target/run_results.json` - dbt run results
- Snowflake audit schema - Custom audit tables
- `bz_audit_log` table - Model execution tracking

## Error Handling and Alerting

### Failed Test Handling
1. **Immediate Notification**: Configure dbt to send alerts on test failures
2. **Data Quality Quarantine**: Failed records are logged but not processed
3. **Retry Logic**: Implement retry mechanisms for transient failures
4. **Escalation**: Critical test failures trigger immediate escalation

### Monitoring Dashboard
Create monitoring dashboards to track:
- Test pass/fail rates
- Data quality trends
- Processing times
- Error patterns

## Maintenance and Updates

### Regular Review Schedule
- **Weekly**: Review test results and failure patterns
- **Monthly**: Update test thresholds based on data patterns
- **Quarterly**: Add new test cases for emerging data quality issues

### Test Case Evolution
- Add new tests as business rules evolve
- Update acceptance criteria based on data analysis
- Remove obsolete tests that no longer provide value

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Bronze Layer Pipeline in Snowflake, providing confidence in data quality for downstream analytics and reporting.