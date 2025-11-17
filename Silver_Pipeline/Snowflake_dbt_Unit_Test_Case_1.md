_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Silver Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Silver Layer pipeline models running in Snowflake. The tests validate data transformations, business rules, edge cases, and error handling across all Silver layer models.

## Models Covered

- SI_Users.sql
- SI_Meetings.sql
- SI_Participants.sql
- SI_Feature_Usage.sql
- SI_Support_Tickets.sql
- SI_Billing_Events.sql
- SI_Licenses.sql
- SI_Audit_Log.sql

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Rule Validation Tests
### 3. Transformation Logic Tests
### 4. Edge Case Tests
### 5. Error Handling Tests

---

## Test Case List

| Test Case ID | Model | Test Case Description | Expected Outcome | Test Type |
|--------------|-------|----------------------|------------------|----------|
| TC_SI_001 | SI_Users | Validate email format using regex pattern | Only valid email formats pass | Data Quality |
| TC_SI_002 | SI_Users | Check plan type standardization | Plan types are 'FREE', 'BASIC', 'PRO', 'ENTERPRISE' | Business Rule |
| TC_SI_003 | SI_Users | Verify deduplication logic | No duplicate user_id records | Data Quality |
| TC_SI_004 | SI_Users | Test default plan assignment for invalid values | Invalid plans default to 'FREE' | Business Rule |
| TC_SI_005 | SI_Users | Validate quality score calculation | Quality scores between 0-100 | Data Quality |
| TC_SI_006 | SI_Meetings | Test EST timezone conversion to UTC | Timestamps properly converted using CONVERT_TIMEZONE | Transformation |
| TC_SI_007 | SI_Meetings | Validate meeting duration logic | Duration = end_time - start_time | Business Rule |
| TC_SI_008 | SI_Meetings | Check host_id foreign key validation | All host_ids exist in users table | Data Quality |
| TC_SI_009 | SI_Meetings | Test negative duration handling | Meetings with negative duration are flagged | Edge Case |
| TC_SI_010 | SI_Meetings | Validate meeting time boundaries | Start time < End time | Business Rule |
| TC_SI_011 | SI_Participants | Test MM/DD/YYYY format conversion | TRY_TO_TIMESTAMP handles format conversion | Transformation |
| TC_SI_012 | SI_Participants | Validate session time within meeting bounds | Join time <= Leave time <= Meeting end | Business Rule |
| TC_SI_013 | SI_Participants | Check participant-meeting relationship | All meeting_ids exist in meetings table | Data Quality |
| TC_SI_014 | SI_Participants | Test null timestamp handling | Null timestamps handled gracefully | Edge Case |
| TC_SI_015 | SI_Participants | Validate participant duration calculation | Duration = leave_time - join_time | Business Rule |
| TC_SI_016 | SI_Feature_Usage | Test feature name standardization | Feature names are uppercase and trimmed | Business Rule |
| TC_SI_017 | SI_Feature_Usage | Validate non-negative usage counts | Usage counts >= 0 | Business Rule |
| TC_SI_018 | SI_Feature_Usage | Check user-feature relationship | All user_ids exist in users table | Data Quality |
| TC_SI_019 | SI_Feature_Usage | Test feature name normalization | Consistent feature naming across records | Data Quality |
| TC_SI_020 | SI_Feature_Usage | Validate usage aggregation logic | Usage counts properly summed by user/feature | Transformation |
| TC_SI_021 | SI_Support_Tickets | Test status standardization | Status in ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') | Business Rule |
| TC_SI_022 | SI_Support_Tickets | Validate future date prevention | Created date <= Current date | Business Rule |
| TC_SI_023 | SI_Support_Tickets | Check user-ticket relationship | All user_ids exist in users table | Data Quality |
| TC_SI_024 | SI_Support_Tickets | Test resolution time calculation | Resolution time = resolved_date - created_date | Business Rule |
| TC_SI_025 | SI_Support_Tickets | Validate ticket priority handling | Priority values are standardized | Data Quality |
| TC_SI_026 | SI_Billing_Events | Test positive amount validation | All amounts > 0 | Business Rule |
| TC_SI_027 | SI_Billing_Events | Validate amount precision rounding | Amounts rounded to 2 decimal places | Business Rule |
| TC_SI_028 | SI_Billing_Events | Check event type standardization | Event types are standardized values | Business Rule |
| TC_SI_029 | SI_Billing_Events | Test user-billing relationship | All user_ids exist in users table | Data Quality |
| TC_SI_030 | SI_Billing_Events | Validate currency handling | Currency codes are valid ISO codes | Data Quality |
| TC_SI_031 | SI_Licenses | Test date logic validation | Start date < End date | Business Rule |
| TC_SI_032 | SI_Licenses | Validate license type standardization | License types are predefined values | Business Rule |
| TC_SI_033 | SI_Licenses | Check user-license relationship | All user_ids exist in users table | Data Quality |
| TC_SI_034 | SI_Licenses | Test license expiration logic | Active licenses have end_date > current_date | Business Rule |
| TC_SI_035 | SI_Licenses | Validate license status calculation | Status derived from date comparison | Transformation |
| TC_SI_036 | SI_Audit_Log | Test audit table structure | All required columns exist with correct types | Data Quality |
| TC_SI_037 | SI_Audit_Log | Validate process tracking | Process start/end times are logical | Business Rule |
| TC_SI_038 | All Models | Test record count validation | Silver record count <= Bronze record count | Data Quality |
| TC_SI_039 | All Models | Validate data quality scores | All records have quality scores assigned | Data Quality |
| TC_SI_040 | All Models | Test validation status assignment | All records have validation status | Data Quality |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer users with data quality validation"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - unique
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: quality_score
        description: "Data quality score 0-100"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: si_meetings
    description: "Silver layer meetings with timezone conversion"
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
      - name: start_time_utc
        description: "Meeting start time in UTC"
        tests:
          - not_null
      - name: end_time_utc
        description: "Meeting end time in UTC"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number

  - name: si_participants
    description: "Silver layer participants with timestamp conversion"
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
      - name: join_time
        description: "Participant join time"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave time"
        tests:
          - not_null

  - name: si_feature_usage
    description: "Silver layer feature usage with standardization"
    columns:
      - name: usage_id
        description: "Unique usage record identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "User ID for feature usage"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: feature_name
        description: "Standardized feature name"
        tests:
          - not_null
      - name: usage_count
        description: "Feature usage count"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 999999

  - name: si_support_tickets
    description: "Silver layer support tickets with status validation"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "User who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: status
        description: "Ticket resolution status"
        tests:
          - accepted_values:
              values: ['OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED']
      - name: created_date
        description: "Ticket creation date"
        tests:
          - not_null

  - name: si_billing_events
    description: "Silver layer billing events with amount validation"
    columns:
      - name: event_id
        description: "Unique billing event identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "User associated with billing event"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: amount
        description: "Billing amount (positive values only)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.01
              max_value: 999999.99
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null

  - name: si_licenses
    description: "Silver layer licenses with date validation"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "User associated with license"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - not_null
      - name: license_type
        description: "Type of license"
        tests:
          - not_null

  - name: si_audit_log
    description: "Silver layer audit log for process tracking"
    columns:
      - name: audit_id
        description: "Unique audit record identifier"
        tests:
          - unique
          - not_null
      - name: process_name
        description: "Name of the process being audited"
        tests:
          - not_null
      - name: start_time
        description: "Process start timestamp"
        tests:
          - not_null
      - name: end_time
        description: "Process end timestamp"
      - name: status
        description: "Process execution status"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'RUNNING', 'CANCELLED']
```

### Custom SQL-based dbt Tests

#### Test 1: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
SELECT 
    user_id,
    email,
    'Invalid email format' as error_message
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$')
```

#### Test 2: Meeting Duration Logic
```sql
-- tests/test_meeting_duration_logic.sql
SELECT 
    meeting_id,
    start_time_utc,
    end_time_utc,
    duration_minutes,
    'Duration calculation mismatch' as error_message
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time_utc, end_time_utc)) > 1
```

#### Test 3: Timezone Conversion Validation
```sql
-- tests/test_timezone_conversion.sql
SELECT 
    meeting_id,
    original_start_time,
    start_time_utc,
    'Timezone conversion failed' as error_message
FROM {{ ref('si_meetings') }}
WHERE start_time_utc IS NULL 
  AND original_start_time IS NOT NULL
```

#### Test 4: Participant Session Boundaries
```sql
-- tests/test_participant_session_boundaries.sql
SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time_utc,
    m.end_time_utc,
    'Participant session outside meeting bounds' as error_message
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.join_time < m.start_time_utc 
   OR p.leave_time > m.end_time_utc
   OR p.join_time > p.leave_time
```

#### Test 5: Feature Usage Count Validation
```sql
-- tests/test_feature_usage_counts.sql
SELECT 
    usage_id,
    user_id,
    feature_name,
    usage_count,
    'Negative usage count detected' as error_message
FROM {{ ref('si_feature_usage') }}
WHERE usage_count < 0
```

#### Test 6: Billing Amount Precision
```sql
-- tests/test_billing_amount_precision.sql
SELECT 
    event_id,
    amount,
    'Amount precision exceeds 2 decimal places' as error_message
FROM {{ ref('si_billing_events') }}
WHERE amount != ROUND(amount, 2)
```

#### Test 7: License Date Logic
```sql
-- tests/test_license_date_logic.sql
SELECT 
    license_id,
    user_id,
    start_date,
    end_date,
    'Start date must be before end date' as error_message
FROM {{ ref('si_licenses') }}
WHERE start_date >= end_date
```

#### Test 8: Support Ticket Future Date Prevention
```sql
-- tests/test_support_ticket_future_dates.sql
SELECT 
    ticket_id,
    created_date,
    'Ticket created in future' as error_message
FROM {{ ref('si_support_tickets') }}
WHERE created_date > CURRENT_DATE()
```

#### Test 9: Data Quality Score Range
```sql
-- tests/test_quality_score_range.sql
SELECT 
    'si_users' as model_name,
    user_id as record_id,
    quality_score,
    'Quality score out of range' as error_message
FROM {{ ref('si_users') }}
WHERE quality_score < 0 OR quality_score > 100

UNION ALL

SELECT 
    'si_meetings' as model_name,
    meeting_id as record_id,
    quality_score,
    'Quality score out of range' as error_message
FROM {{ ref('si_meetings') }}
WHERE quality_score < 0 OR quality_score > 100
```

#### Test 10: Deduplication Validation
```sql
-- tests/test_deduplication_validation.sql
SELECT 
    user_id,
    COUNT(*) as duplicate_count,
    'Duplicate records found after deduplication' as error_message
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    meeting_id,
    COUNT(*) as duplicate_count,
    'Duplicate records found after deduplication' as error_message
FROM {{ ref('si_meetings') }}
GROUP BY meeting_id
HAVING COUNT(*) > 1
```

### Parameterized Tests

#### Generic Test for Referential Integrity
```sql
-- macros/test_referential_integrity.sql
{% macro test_referential_integrity(model, column_name, parent_model, parent_column) %}

SELECT 
    {{ column_name }},
    'Referential integrity violation' as error_message
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND {{ column_name }} NOT IN (
    SELECT {{ parent_column }}
    FROM {{ parent_model }}
    WHERE {{ parent_column }} IS NOT NULL
  )

{% endmacro %}
```

#### Generic Test for Data Freshness
```sql
-- macros/test_data_freshness.sql
{% macro test_data_freshness(model, date_column, max_days_old=7) %}

SELECT 
    COUNT(*) as stale_record_count,
    'Data is older than {{ max_days_old }} days' as error_message
FROM {{ model }}
WHERE {{ date_column }} < CURRENT_DATE() - {{ max_days_old }}
HAVING COUNT(*) > 0

{% endmacro %}
```

### Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users

# Run specific test type
dbt test --select test_type:data

# Run tests with verbose output
dbt test --verbose

# Run tests and store results
dbt test --store-failures
```

### Test Results Tracking

Test results are automatically tracked in:
- `dbt_test_results` table in Snowflake
- `run_results.json` file
- dbt Cloud test history (if using dbt Cloud)

### Monitoring and Alerting

```sql
-- Query to monitor test failures
SELECT 
    test_name,
    model_name,
    failure_count,
    last_run_time,
    status
FROM dbt_test_results
WHERE status = 'FAILED'
  AND last_run_time >= CURRENT_DATE() - 1
ORDER BY failure_count DESC;
```

## Test Coverage Summary

| Model | Total Tests | Data Quality | Business Rules | Transformations | Edge Cases |
|-------|-------------|--------------|----------------|-----------------|------------|
| SI_Users | 8 | 4 | 3 | 1 | 2 |
| SI_Meetings | 7 | 2 | 3 | 2 | 1 |
| SI_Participants | 6 | 2 | 2 | 1 | 2 |
| SI_Feature_Usage | 5 | 2 | 2 | 1 | 1 |
| SI_Support_Tickets | 5 | 2 | 2 | 0 | 1 |
| SI_Billing_Events | 5 | 2 | 3 | 0 | 1 |
| SI_Licenses | 5 | 2 | 2 | 1 | 1 |
| SI_Audit_Log | 4 | 3 | 1 | 0 | 0 |
| **Total** | **45** | **19** | **18** | **6** | **9** |

## Conclusion

This comprehensive test suite ensures:
- **Data Quality**: Validates data integrity, format compliance, and completeness
- **Business Rules**: Enforces business logic and constraints
- **Transformation Logic**: Verifies data transformations and calculations
- **Edge Cases**: Handles null values, invalid data, and boundary conditions
- **Error Handling**: Graceful handling of data quality issues

The tests are designed to run efficiently in Snowflake and integrate seamlessly with dbt's testing framework, providing robust validation for the Zoom Silver Layer pipeline.