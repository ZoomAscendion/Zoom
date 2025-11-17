_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics System Silver layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models.

## Test Coverage Overview

### **Models Under Test:**
- SI_USERS - User profile and subscription data
- SI_MEETINGS - Meeting information and session details
- SI_PARTICIPANTS - Meeting participants and session tracking
- SI_FEATURE_USAGE - Platform feature usage metrics
- SI_SUPPORT_TICKETS - Customer support requests
- SI_BILLING_EVENTS - Financial transactions and billing
- SI_LICENSES - License assignments and entitlements
- SI_AUDIT_LOG - Pipeline execution audit trail

### **Test Categories:**
- **Happy Path Tests**: Valid transformations, joins, and aggregations
- **Edge Case Tests**: Null values, empty datasets, boundary conditions
- **Exception Tests**: Invalid data, failed relationships, conversion errors
- **Business Rule Tests**: Data quality validations, format conversions
- **Performance Tests**: Query optimization and execution time validation

---

## **Test Case List**

### **1. SI_USERS Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_USERS_001 | Validate user ID uniqueness | No duplicate USER_ID values |
| TC_SI_USERS_002 | Email format validation | All emails follow valid format pattern |
| TC_SI_USERS_003 | Plan type standardization | Only valid plan types (Free, Basic, Pro, Enterprise) |
| TC_SI_USERS_004 | Null value validation | Critical fields (USER_ID, EMAIL) are not null |
| TC_SI_USERS_005 | Data quality score range | All scores between 0-100 |
| TC_SI_USERS_006 | Load timestamp validation | All records have valid load timestamps |
| TC_SI_USERS_007 | Source system validation | All records have valid source system |
| TC_SI_USERS_008 | Validation status check | Status is PASSED, FAILED, or WARNING |

### **2. SI_MEETINGS Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_MEETINGS_001 | Meeting duration consistency | Duration matches time difference |
| TC_SI_MEETINGS_002 | Meeting time logic validation | End time is after start time |
| TC_SI_MEETINGS_003 | Host ID referential integrity | All hosts exist in SI_USERS |
| TC_SI_MEETINGS_004 | Duration range validation | Duration between 0-1440 minutes |
| TC_SI_MEETINGS_005 | EST timezone format handling | EST timestamps converted properly |
| TC_SI_MEETINGS_006 | Duration text unit cleaning | "108 mins" format cleaned to numeric |
| TC_SI_MEETINGS_007 | Meeting ID uniqueness | No duplicate MEETING_ID values |
| TC_SI_MEETINGS_008 | Null value validation | Critical fields are not null |

### **3. SI_PARTICIPANTS Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_PARTICIPANTS_001 | Session time validation | Leave time is after join time |
| TC_SI_PARTICIPANTS_002 | Meeting boundary validation | Join/leave within meeting duration |
| TC_SI_PARTICIPANTS_003 | Meeting referential integrity | All meetings exist in SI_MEETINGS |
| TC_SI_PARTICIPANTS_004 | User referential integrity | All users exist in SI_USERS |
| TC_SI_PARTICIPANTS_005 | MM/DD/YYYY format handling | Date format converted properly |
| TC_SI_PARTICIPANTS_006 | Unique participant per meeting | No duplicate participant-meeting pairs |
| TC_SI_PARTICIPANTS_007 | Timestamp format consistency | Mixed formats handled correctly |
| TC_SI_PARTICIPANTS_008 | Null value validation | Critical fields are not null |

### **4. SI_FEATURE_USAGE Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_FEATURE_USAGE_001 | Feature name standardization | Feature names follow conventions |
| TC_SI_FEATURE_USAGE_002 | Usage count validation | Usage counts are non-negative |
| TC_SI_FEATURE_USAGE_003 | Meeting referential integrity | All meetings exist in SI_MEETINGS |
| TC_SI_FEATURE_USAGE_004 | Usage date consistency | Usage dates align with meeting dates |
| TC_SI_FEATURE_USAGE_005 | Feature adoption calculation | Adoption rates calculated correctly |
| TC_SI_FEATURE_USAGE_006 | Usage ID uniqueness | No duplicate USAGE_ID values |
| TC_SI_FEATURE_USAGE_007 | Null value validation | Critical fields are not null |
| TC_SI_FEATURE_USAGE_008 | Data quality validation | Quality scores within range |

### **5. SI_SUPPORT_TICKETS Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_SUPPORT_TICKETS_001 | Ticket status validation | Valid status values only |
| TC_SI_SUPPORT_TICKETS_002 | User referential integrity | All users exist in SI_USERS |
| TC_SI_SUPPORT_TICKETS_003 | Ticket ID uniqueness | No duplicate TICKET_ID values |
| TC_SI_SUPPORT_TICKETS_004 | Open date validation | Open dates not in future |
| TC_SI_SUPPORT_TICKETS_005 | Ticket volume calculation | Volume per 1000 users calculated |
| TC_SI_SUPPORT_TICKETS_006 | Null value validation | Critical fields are not null |
| TC_SI_SUPPORT_TICKETS_007 | Status standardization | Status values standardized |
| TC_SI_SUPPORT_TICKETS_008 | Data quality validation | Quality scores within range |

### **6. SI_BILLING_EVENTS Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_BILLING_EVENTS_001 | Amount validation | Amounts are positive numbers |
| TC_SI_BILLING_EVENTS_002 | Event date validation | Event dates not in future |
| TC_SI_BILLING_EVENTS_003 | User referential integrity | All users exist in SI_USERS |
| TC_SI_BILLING_EVENTS_004 | Event type standardization | Event types follow categories |
| TC_SI_BILLING_EVENTS_005 | MRR calculation | Monthly recurring revenue calculated |
| TC_SI_BILLING_EVENTS_006 | Amount field cleaning | Quoted amounts cleaned properly |
| TC_SI_BILLING_EVENTS_007 | Event ID uniqueness | No duplicate EVENT_ID values |
| TC_SI_BILLING_EVENTS_008 | Null value validation | Critical fields are not null |

### **7. SI_LICENSES Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_LICENSES_001 | License date logic validation | Start date before end date |
| TC_SI_LICENSES_002 | User referential integrity | All users exist in SI_USERS |
| TC_SI_LICENSES_003 | Active license validation | Active licenses have future end dates |
| TC_SI_LICENSES_004 | License type standardization | License types follow categories |
| TC_SI_LICENSES_005 | DD/MM/YYYY format conversion | "27/08/2024" format converted properly |
| TC_SI_LICENSES_006 | License utilization calculation | Utilization rates calculated correctly |
| TC_SI_LICENSES_007 | License ID uniqueness | No duplicate LICENSE_ID values |
| TC_SI_LICENSES_008 | Null value validation | Critical fields are not null |

### **8. Cross-Table Integration Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INTEGRATION_001 | User activity consistency | Meeting hosts have participant records |
| TC_INTEGRATION_002 | Feature usage alignment | Feature usage aligns with participants |
| TC_INTEGRATION_003 | Billing-license consistency | Billing users have license records |
| TC_INTEGRATION_004 | Data freshness validation | Data loaded within acceptable windows |
| TC_INTEGRATION_005 | Record count validation | Record counts within expected ranges |
| TC_INTEGRATION_006 | Business rule validation | DAU calculation accuracy |
| TC_INTEGRATION_007 | Churn rate calculation | Monthly churn rates calculated correctly |
| TC_INTEGRATION_008 | End-to-end data flow | Complete Bronze to Silver transformation |

---

## **dbt Test Scripts**

### **YAML-based Schema Tests**

```yaml
# schema.yml - Comprehensive dbt tests for Silver layer models

version: 2

sources:
  - name: bronze
    description: "Bronze layer source tables"
    schema: bronze
    tables:
      - name: bz_users
        description: "Raw user data from source systems"
      - name: bz_meetings
        description: "Raw meeting data from source systems"
      - name: bz_participants
        description: "Raw participant data from source systems"
      - name: bz_feature_usage
        description: "Raw feature usage data from source systems"
      - name: bz_support_tickets
        description: "Raw support ticket data from source systems"
      - name: bz_billing_events
        description: "Raw billing event data from source systems"
      - name: bz_licenses
        description: "Raw license data from source systems"

models:
  - name: si_users
    description: "Silver layer user data with cleansing and validation"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: email
        description: "User email address"
        tests:
          - not_null:
              severity: error
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
              severity: warn
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
              severity: error
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
              severity: warn
      - name: validation_status
        description: "Data validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']
              severity: error
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null:
              severity: error
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null:
              severity: error

  - name: si_meetings
    description: "Silver layer meeting data with cleansing and validation"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
              severity: warn
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null:
              severity: error
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - not_null:
              severity: error
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
              severity: warn

  - name: si_participants
    description: "Silver layer participant data with cleansing and validation"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
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
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: warn
      - name: join_time
        description: "Participant join timestamp"
        tests:
          - not_null:
              severity: error
      - name: leave_time
        description: "Participant leave timestamp"
        tests:
          - not_null:
              severity: error

  - name: si_feature_usage
    description: "Silver layer feature usage data with validation"
    columns:
      - name: usage_id
        description: "Unique usage identifier"
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
      - name: usage_count
        description: "Feature usage count"
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
              severity: error
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 999999
              severity: warn

  - name: si_support_tickets
    description: "Silver layer support ticket data with validation"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
      - name: resolution_status
        description: "Ticket resolution status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
              severity: error
      - name: open_date
        description: "Ticket open date"
        tests:
          - not_null:
              severity: error

  - name: si_billing_events
    description: "Silver layer billing event data with validation"
    columns:
      - name: event_id
        description: "Unique event identifier"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
      - name: amount
        description: "Billing amount"
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
              severity: error
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 999999.99
              severity: warn
      - name: event_date
        description: "Event date"
        tests:
          - not_null:
              severity: error

  - name: si_licenses
    description: "Silver layer license data with validation"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: assigned_to_user_id
        description: "Reference to assigned user"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
      - name: start_date
        description: "License start date"
        tests:
          - not_null:
              severity: error
      - name: end_date
        description: "License end date"
        tests:
          - not_null:
              severity: error
```

### **Custom SQL-based dbt Tests**

#### **1. Meeting Duration Consistency Test**

```sql
-- tests/meeting_duration_consistency.sql
-- Test that calculated duration matches the difference between start and end times

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as duration_diff
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
  AND start_time IS NOT NULL 
  AND end_time IS NOT NULL
  AND duration_minutes IS NOT NULL
```

#### **2. Meeting Time Logic Validation Test**

```sql
-- tests/meeting_time_logic.sql
-- Test that end time is after start time

SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE end_time <= start_time
  AND start_time IS NOT NULL 
  AND end_time IS NOT NULL
```

#### **3. Participant Session Time Validation Test**

```sql
-- tests/participant_session_time.sql
-- Test that leave time is after join time

SELECT 
    participant_id,
    meeting_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE leave_time <= join_time
  AND join_time IS NOT NULL 
  AND leave_time IS NOT NULL
```

#### **4. Meeting Boundary Validation Test**

```sql
-- tests/meeting_boundary_validation.sql
-- Test that participant join/leave times are within meeting duration

SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time,
    m.end_time
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE (p.join_time < m.start_time OR p.leave_time > m.end_time)
  AND p.join_time IS NOT NULL 
  AND p.leave_time IS NOT NULL
  AND m.start_time IS NOT NULL 
  AND m.end_time IS NOT NULL
```

#### **5. EST Timezone Format Validation Test**

```sql
-- tests/est_timezone_format.sql
-- Test EST timezone format handling in meetings

SELECT 
    meeting_id,
    start_time,
    end_time,
    'EST_FORMAT_ISSUE' as error_type
FROM {{ ref('si_meetings') }}
WHERE (start_time::STRING LIKE '%EST%' 
       AND NOT REGEXP_LIKE(start_time::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$'))
   OR (end_time::STRING LIKE '%EST%' 
       AND NOT REGEXP_LIKE(end_time::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$'))
```

#### **6. Duration Text Unit Cleaning Test**

```sql
-- tests/duration_text_cleaning.sql
-- Test duration text unit cleaning (e.g., "108 mins")

SELECT 
    meeting_id,
    duration_minutes,
    'DURATION_TEXT_UNITS' as error_type
FROM {{ source('bronze', 'bz_meetings') }}
WHERE duration_minutes::STRING REGEXP '[a-zA-Z]'
  AND TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', '')) IS NULL
```

#### **7. MM/DD/YYYY Format Validation Test**

```sql
-- tests/mmddyyyy_format_validation.sql
-- Test MM/DD/YYYY HH:MM format handling in participants

SELECT 
    participant_id,
    join_time,
    leave_time,
    'MMDDYYYY_FORMAT_ISSUE' as error_type
FROM {{ ref('si_participants') }}
WHERE (join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
       AND TRY_TO_TIMESTAMP(join_time::STRING, 'MM/DD/YYYY HH24:MI') IS NULL)
   OR (leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
       AND TRY_TO_TIMESTAMP(leave_time::STRING, 'MM/DD/YYYY HH24:MI') IS NULL)
```

#### **8. DD/MM/YYYY Date Format Conversion Test**

```sql
-- tests/ddmmyyyy_date_conversion.sql
-- Test DD/MM/YYYY format conversion in licenses (e.g., "27/08/2024")

SELECT 
    license_id,
    start_date,
    end_date,
    'DDMMYYYY_CONVERSION_FAILURE' as error_type
FROM {{ source('bronze', 'bz_licenses') }}
WHERE (start_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
       AND TRY_TO_DATE(start_date::STRING, 'DD/MM/YYYY') IS NULL)
   OR (end_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
       AND TRY_TO_DATE(end_date::STRING, 'DD/MM/YYYY') IS NULL)
```

#### **9. User Activity Consistency Test**

```sql
-- tests/user_activity_consistency.sql
-- Test that users with meetings also have corresponding participant records

SELECT 
    m.meeting_id,
    m.host_id,
    'MISSING_HOST_PARTICIPATION' as error_type
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p 
  ON m.meeting_id = p.meeting_id 
  AND m.host_id = p.user_id
WHERE p.user_id IS NULL
  AND m.host_id IS NOT NULL
```

#### **10. Feature Usage Alignment Test**

```sql
-- tests/feature_usage_alignment.sql
-- Test that feature usage records align with actual meeting participants

SELECT 
    f.usage_id,
    f.meeting_id,
    'FEATURE_USAGE_WITHOUT_PARTICIPANTS' as error_type
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_participants') }} p ON f.meeting_id = p.meeting_id
WHERE p.meeting_id IS NULL
  AND f.meeting_id IS NOT NULL
```

#### **11. Billing Amount Validation Test**

```sql
-- tests/billing_amount_validation.sql
-- Test that billing amounts are positive and properly formatted

SELECT 
    event_id,
    amount,
    'INVALID_BILLING_AMOUNT' as error_type
FROM {{ ref('si_billing_events') }}
WHERE amount <= 0 
   OR amount IS NULL
   OR amount > 999999.99
```

#### **12. License Date Logic Test**

```sql
-- tests/license_date_logic.sql
-- Test that license start date is before end date

SELECT 
    license_id,
    start_date,
    end_date,
    'INVALID_LICENSE_DATE_LOGIC' as error_type
FROM {{ ref('si_licenses') }}
WHERE start_date >= end_date
  AND start_date IS NOT NULL 
  AND end_date IS NOT NULL
```

#### **13. Data Quality Score Distribution Test**

```sql
-- tests/data_quality_score_distribution.sql
-- Test data quality score distribution across all Silver tables

WITH quality_scores AS (
  SELECT 'SI_USERS' as table_name, data_quality_score FROM {{ ref('si_users') }}
  UNION ALL
  SELECT 'SI_MEETINGS', data_quality_score FROM {{ ref('si_meetings') }}
  UNION ALL
  SELECT 'SI_PARTICIPANTS', data_quality_score FROM {{ ref('si_participants') }}
  UNION ALL
  SELECT 'SI_FEATURE_USAGE', data_quality_score FROM {{ ref('si_feature_usage') }}
  UNION ALL
  SELECT 'SI_SUPPORT_TICKETS', data_quality_score FROM {{ ref('si_support_tickets') }}
  UNION ALL
  SELECT 'SI_BILLING_EVENTS', data_quality_score FROM {{ ref('si_billing_events') }}
  UNION ALL
  SELECT 'SI_LICENSES', data_quality_score FROM {{ ref('si_licenses') }}
)
SELECT 
    table_name,
    data_quality_score,
    'LOW_QUALITY_SCORE' as error_type
FROM quality_scores
WHERE data_quality_score < 70
   OR data_quality_score IS NULL
```

#### **14. Data Freshness Validation Test**

```sql
-- tests/data_freshness_validation.sql
-- Test that data is being loaded within acceptable time windows

WITH freshness_check AS (
  SELECT 'SI_USERS' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('si_users') }}
  UNION ALL
  SELECT 'SI_MEETINGS', MAX(load_timestamp) FROM {{ ref('si_meetings') }}
  UNION ALL
  SELECT 'SI_PARTICIPANTS', MAX(load_timestamp) FROM {{ ref('si_participants') }}
  UNION ALL
  SELECT 'SI_FEATURE_USAGE', MAX(load_timestamp) FROM {{ ref('si_feature_usage') }}
  UNION ALL
  SELECT 'SI_SUPPORT_TICKETS', MAX(load_timestamp) FROM {{ ref('si_support_tickets') }}
  UNION ALL
  SELECT 'SI_BILLING_EVENTS', MAX(load_timestamp) FROM {{ ref('si_billing_events') }}
  UNION ALL
  SELECT 'SI_LICENSES', MAX(load_timestamp) FROM {{ ref('si_licenses') }}
)
SELECT 
    table_name,
    latest_load,
    DATEDIFF('hour', latest_load, CURRENT_TIMESTAMP()) as hours_since_load,
    'STALE_DATA' as error_type
FROM freshness_check
WHERE DATEDIFF('hour', latest_load, CURRENT_TIMESTAMP()) > 24
   OR latest_load IS NULL
```

### **Parameterized Tests for Reusability**

#### **Generic Test: Column Value Range**

```sql
-- macros/test_column_value_range.sql
-- Generic test for validating column values within a specified range

{% test column_value_range(model, column_name, min_value, max_value) %}

SELECT 
    {{ column_name }},
    'VALUE_OUT_OF_RANGE' as error_type
FROM {{ model }}
WHERE {{ column_name }} < {{ min_value }} 
   OR {{ column_name }} > {{ max_value }}
   OR {{ column_name }} IS NULL

{% endtest %}
```

#### **Generic Test: Timestamp Format Validation**

```sql
-- macros/test_timestamp_format.sql
-- Generic test for validating timestamp formats

{% test timestamp_format_validation(model, column_name, format_pattern) %}

SELECT 
    {{ column_name }},
    'INVALID_TIMESTAMP_FORMAT' as error_type
FROM {{ model }}
WHERE {{ column_name }}::STRING REGEXP '{{ format_pattern }}'
  AND TRY_TO_TIMESTAMP({{ column_name }}::STRING) IS NULL

{% endtest %}
```

#### **Generic Test: Referential Integrity**

```sql
-- macros/test_referential_integrity.sql
-- Generic test for validating referential integrity between tables

{% test referential_integrity(model, column_name, parent_model, parent_column) %}

SELECT 
    child.{{ column_name }},
    'ORPHANED_RECORD' as error_type
FROM {{ model }} child
LEFT JOIN {{ parent_model }} parent 
  ON child.{{ column_name }} = parent.{{ parent_column }}
WHERE parent.{{ parent_column }} IS NULL
  AND child.{{ column_name }} IS NOT NULL

{% endtest %}
```

---

## **Test Execution Strategy**

### **1. Test Execution Order**

1. **Schema Tests** (YAML-based) - Run first for basic validation
2. **Custom SQL Tests** - Run for complex business logic validation
3. **Integration Tests** - Run for cross-table validation
4. **Performance Tests** - Run for optimization validation

### **2. Test Severity Levels**

- **Error**: Critical tests that must pass (data integrity, business rules)
- **Warn**: Important tests that should pass (data quality, format validation)
- **Info**: Monitoring tests for awareness (performance, freshness)

### **3. Test Automation**

```yaml
# dbt_project.yml - Test configuration

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
      +pre-hook: "INSERT INTO {{ ref('si_audit_log') }} VALUES ('{{ this }}', 'PRE_HOOK', CURRENT_TIMESTAMP())"
      +post-hook: "INSERT INTO {{ ref('si_audit_log') }} VALUES ('{{ this }}', 'POST_HOOK', CURRENT_TIMESTAMP())"

tests:
  +severity: warn
  +store_failures: true
  +schema: silver_test_results

vars:
  # Test configuration variables
  data_quality_threshold: 70
  freshness_threshold_hours: 24
  max_duration_minutes: 1440
  valid_plan_types: ['Free', 'Basic', 'Pro', 'Enterprise']
  valid_ticket_statuses: ['Open', 'In Progress', 'Resolved', 'Closed']
```

### **4. Test Results Tracking**

```sql
-- models/silver/si_test_results.sql
-- Model to track test execution results

SELECT 
    test_name,
    model_name,
    column_name,
    severity,
    status,
    error_count,
    execution_time,
    run_started_at,
    run_completed_at
FROM {{ ref('dbt_test_results') }}
WHERE run_started_at >= CURRENT_DATE() - INTERVAL '7 days'
ORDER BY run_started_at DESC
```

---

## **Performance Optimization Tests**

### **1. Query Performance Test**

```sql
-- tests/query_performance.sql
-- Test that Silver layer queries execute within acceptable time limits

WITH performance_test AS (
  SELECT 
    'SI_USERS' as table_name,
    COUNT(*) as record_count,
    CURRENT_TIMESTAMP() as start_time
  FROM {{ ref('si_users') }}
  
  UNION ALL
  
  SELECT 
    'SI_MEETINGS',
    COUNT(*),
    CURRENT_TIMESTAMP()
  FROM {{ ref('si_meetings') }}
  
  UNION ALL
  
  SELECT 
    'SI_PARTICIPANTS',
    COUNT(*),
    CURRENT_TIMESTAMP()
  FROM {{ ref('si_participants') }}
)
SELECT 
    table_name,
    record_count,
    'PERFORMANCE_ISSUE' as error_type
FROM performance_test
WHERE record_count = 0  -- This test will fail if any table is empty
```

### **2. Memory Usage Test**

```sql
-- tests/memory_usage.sql
-- Test memory usage for large transformations

SELECT 
    'MEMORY_USAGE_HIGH' as error_type,
    COUNT(*) as large_table_count
FROM (
  SELECT COUNT(*) as row_count FROM {{ ref('si_meetings') }}
  UNION ALL
  SELECT COUNT(*) FROM {{ ref('si_participants') }}
  UNION ALL
  SELECT COUNT(*) FROM {{ ref('si_feature_usage') }}
) large_tables
WHERE row_count > 10000000  -- Flag tables with more than 10M rows
HAVING COUNT(*) > 0
```

---

## **Error Handling and Recovery**

### **1. Test Failure Handling**

```sql
-- macros/handle_test_failure.sql
-- Macro for handling test failures gracefully

{% macro handle_test_failure(test_name, error_message) %}
  
  INSERT INTO {{ ref('si_audit_log') }} (
    table_name,
    column_name,
    error_type,
    error_description,
    audit_timestamp
  )
  VALUES (
    '{{ test_name }}',
    'TEST_EXECUTION',
    'TEST_FAILURE',
    '{{ error_message }}',
    CURRENT_TIMESTAMP()
  );
  
{% endmacro %}
```

### **2. Data Quality Remediation**

```sql
-- models/silver/si_data_quality_remediation.sql
-- Model for tracking and remediating data quality issues

WITH quality_issues AS (
  SELECT 
    'SI_MEETINGS' as table_name,
    'DURATION_TEXT_CLEANING' as issue_type,
    meeting_id as record_id,
    duration_minutes as original_value,
    TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', '')) as remediated_value
  FROM {{ source('bronze', 'bz_meetings') }}
  WHERE duration_minutes::STRING REGEXP '[a-zA-Z]'
  
  UNION ALL
  
  SELECT 
    'SI_LICENSES',
    'DD_MM_YYYY_CONVERSION',
    license_id,
    start_date::STRING,
    TRY_TO_DATE(start_date::STRING, 'DD/MM/YYYY')::STRING
  FROM {{ source('bronze', 'bz_licenses') }}
  WHERE start_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
)
SELECT 
    table_name,
    issue_type,
    record_id,
    original_value,
    remediated_value,
    CASE 
      WHEN remediated_value IS NOT NULL THEN 'REMEDIATED'
      ELSE 'FAILED'
    END as remediation_status,
    CURRENT_TIMESTAMP() as remediation_timestamp
FROM quality_issues
```

---

## **Monitoring and Alerting**

### **1. Test Results Dashboard Query**

```sql
-- analysis/test_results_dashboard.sql
-- Query for creating test results dashboard

WITH test_summary AS (
  SELECT 
    DATE(run_started_at) as test_date,
    model_name,
    severity,
    COUNT(*) as total_tests,
    COUNT(CASE WHEN status = 'pass' THEN 1 END) as passed_tests,
    COUNT(CASE WHEN status = 'fail' THEN 1 END) as failed_tests,
    COUNT(CASE WHEN status = 'error' THEN 1 END) as error_tests,
    AVG(execution_time) as avg_execution_time
  FROM {{ ref('si_test_results') }}
  WHERE run_started_at >= CURRENT_DATE() - INTERVAL '30 days'
  GROUP BY DATE(run_started_at), model_name, severity
)
SELECT 
    test_date,
    model_name,
    severity,
    total_tests,
    passed_tests,
    failed_tests,
    error_tests,
    ROUND((passed_tests * 100.0 / total_tests), 2) as pass_rate_percent,
    ROUND(avg_execution_time, 2) as avg_execution_time_seconds
FROM test_summary
ORDER BY test_date DESC, model_name, severity
```

### **2. Alert Configuration**

```yaml
# alerts.yml - Test failure alert configuration

alerts:
  - name: critical_test_failures
    description: "Alert when critical tests fail"
    condition: "severity = 'error' AND status = 'fail'"
    notification:
      - email: "data-team@company.com"
      - slack: "#data-alerts"
    
  - name: data_quality_degradation
    description: "Alert when data quality scores drop below threshold"
    condition: "avg_data_quality_score < 70"
    notification:
      - email: "data-team@company.com"
      
  - name: test_execution_time
    description: "Alert when test execution time exceeds threshold"
    condition: "avg_execution_time > 300"
    notification:
      - slack: "#data-performance"
```

---

## **Conclusion**

This comprehensive unit test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics System Silver layer dbt models in Snowflake. The test cases cover:

- **Data Integrity**: Uniqueness, null validation, referential integrity
- **Business Rules**: Plan type validation, status standardization, date logic
- **Format Handling**: EST timezone, MM/DD/YYYY, DD/MM/YYYY, text unit cleaning
- **Performance**: Query execution time, memory usage, data freshness
- **Cross-table Validation**: Integration tests, consistency checks
- **Error Handling**: Graceful failure handling, remediation tracking

The test framework supports automated execution, result tracking, and alerting to maintain high data quality standards and ensure reliable analytics capabilities for the Zoom platform.

**Key Benefits:**
- Early detection of data quality issues
- Automated validation of business rules
- Performance monitoring and optimization
- Comprehensive audit trail and error tracking
- Scalable test framework for future enhancements

**Recommended Execution Schedule:**
- **Critical Tests (Error severity)**: Every dbt run
- **Quality Tests (Warn severity)**: Daily
- **Performance Tests**: Weekly
- **Integration Tests**: After any schema changes

This testing framework ensures that the Silver layer maintains production-ready quality standards while supporting the analytical needs of the Zoom Platform Analytics System.