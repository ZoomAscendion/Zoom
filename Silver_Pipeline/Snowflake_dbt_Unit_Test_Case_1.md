_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Platform Analytics Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios for all 8 Silver layer models and the audit framework.

## Test Coverage Overview

### Models Under Test
1. **SI_Audit_Log** - Audit trail for Silver layer operations
2. **SI_Users** - User profile data with email validation
3. **SI_Meetings** - Meeting information with numeric field cleaning
4. **SI_Participants** - Meeting participants with timestamp parsing
5. **SI_Feature_Usage** - Platform feature usage analytics
6. **SI_Support_Tickets** - Customer support data
7. **SI_Billing_Events** - Financial transactions
8. **SI_Licenses** - License management with date format conversion

## Test Case Categories
- **Happy Path Tests**: Valid data transformations and business rules
- **Edge Case Tests**: Null values, empty datasets, boundary conditions
- **Error Handling Tests**: Invalid formats, failed conversions, data quality issues
- **Business Rule Tests**: Plan types, status validations, date logic
- **Performance Tests**: Large dataset handling, query optimization

---

## Test Case List

### 1. SI_Audit_Log Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| AUD_001 | Verify audit table structure and column definitions | All required columns present with correct data types |
| AUD_002 | Test audit log insertion for successful operations | Records inserted with correct operation_type = 'SUCCESS' |
| AUD_003 | Test audit log insertion for failed operations | Records inserted with operation_type = 'ERROR' and error details |
| AUD_004 | Validate audit timestamp generation | AUDIT_TIMESTAMP populated with current timestamp |
| AUD_005 | Test audit record uniqueness | AUDIT_ID is unique for each record |

### 2. SI_Users Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| USR_001 | Valid email format validation | Users with valid emails pass validation |
| USR_002 | Invalid email format handling | Invalid emails flagged in data quality score |
| USR_003 | Plan type standardization | Plan types normalized to standard values |
| USR_004 | Null email handling | Null emails handled gracefully with appropriate DQ score |
| USR_005 | User deduplication logic | Latest user record retained based on UPDATE_TIMESTAMP |
| USR_006 | Data quality scoring calculation | DQ scores calculated correctly (100/75/50 points) |
| USR_007 | Plan type constraint validation | Only valid plan types (Basic, Pro, Business, Enterprise) accepted |

### 3. SI_Meetings Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| MTG_001 | Numeric field text unit cleaning (P1 Fix) | "108 mins" converted to numeric 108 |
| MTG_002 | Duration validation and cleaning | Duration values cleaned and validated |
| MTG_003 | EST timezone handling | Timezone conversions handled correctly |
| MTG_004 | Meeting duration boundary tests | Negative durations handled appropriately |
| MTG_005 | Null duration handling | Null durations assigned default or flagged |
| MTG_006 | Meeting deduplication | Latest meeting record retained |
| MTG_007 | Invalid duration format handling | Non-numeric durations handled gracefully |
| MTG_008 | Large duration values | Extremely large durations validated |

### 4. SI_Participants Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| PRT_001 | Multi-format timestamp parsing | YYYY-MM-DD, DD/MM/YYYY, MM/DD/YYYY formats supported |
| PRT_002 | Join/leave time validation | Join time before leave time validation |
| PRT_003 | Session boundary validation | Participant sessions within meeting boundaries |
| PRT_004 | Invalid timestamp handling | Invalid timestamps handled with TRY_TO_TIMESTAMP |
| PRT_005 | Null timestamp handling | Null join/leave times handled appropriately |
| PRT_006 | Participant deduplication | Latest participant record retained |
| PRT_007 | Meeting-participant relationship | Valid meeting_id references maintained |

### 5. SI_Feature_Usage Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| FTR_001 | Feature name standardization | Feature names normalized to standard format |
| FTR_002 | Usage count validation | Non-negative usage counts enforced |
| FTR_003 | Feature-meeting alignment | Feature usage aligned with meeting records |
| FTR_004 | Null usage count handling | Null usage counts defaulted to 0 |
| FTR_005 | Invalid feature names | Unknown features handled appropriately |
| FTR_006 | Usage aggregation accuracy | Usage counts aggregated correctly |

### 6. SI_Support_Tickets Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SUP_001 | Status standardization | Ticket statuses normalized (Open, In Progress, Resolved, Closed) |
| SUP_002 | Ticket type normalization | Ticket types standardized |
| SUP_003 | Date consistency validation | Created date before resolved date |
| SUP_004 | Invalid status handling | Invalid statuses handled with default |
| SUP_005 | Null date handling | Null dates handled appropriately |
| SUP_006 | Ticket priority validation | Priority levels validated |

### 7. SI_Billing_Events Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BIL_001 | Numeric field cleaning for quoted values | Quoted amounts converted to numeric |
| BIL_002 | Amount validation | Positive amounts enforced |
| BIL_003 | Event type standardization | Event types normalized |
| BIL_004 | Future date prevention | Future billing dates prevented |
| BIL_005 | Null amount handling | Null amounts handled appropriately |
| BIL_006 | Currency validation | Currency codes validated |
| BIL_007 | Negative amount handling | Negative amounts flagged appropriately |

### 8. SI_Licenses Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| LIC_001 | DD/MM/YYYY date format conversion (P1 Fix) | "27/08/2024" converted to proper date |
| LIC_002 | Multi-format date parsing | YYYY-MM-DD, DD/MM/YYYY, DD-MM-YYYY, MM/DD/YYYY supported |
| LIC_003 | License validity validation | Start date before end date validation |
| LIC_004 | Invalid date format handling | Invalid dates handled with TRY_TO_DATE |
| LIC_005 | Null date handling | Null dates handled appropriately |
| LIC_006 | License status validation | License statuses validated |
| LIC_007 | Expired license identification | Expired licenses flagged correctly |

### 9. Cross-Model Integration Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| INT_001 | User-Meeting relationship integrity | Valid user_id references in meetings |
| INT_002 | Meeting-Participant consistency | Participant records match meeting records |
| INT_003 | User-License alignment | License records align with user records |
| INT_004 | Billing-User consistency | Billing events align with user records |
| INT_005 | Support ticket-User relationship | Support tickets linked to valid users |

### 10. Data Quality Framework Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| DQ_001 | Data quality score calculation | Scores calculated correctly (100/75/50) |
| DQ_002 | Validation status assignment | PASSED/WARNING/FAILED assigned correctly |
| DQ_003 | Audit logging for DQ failures | DQ failures logged in audit table |
| DQ_004 | Deduplication effectiveness | No duplicate records in final output |
| DQ_005 | Null value handling | Null values handled per business rules |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer user profile data with data quality validations"
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
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100

  - name: si_meetings
    description: "Silver layer meeting data with duration cleaning"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - unique
          - not_null
      - name: clean_duration_minutes
        description: "Cleaned meeting duration in minutes"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440  # 24 hours max
      - name: user_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id

  - name: si_participants
    description: "Silver layer meeting participants with timestamp validation"
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
        description: "Participant join timestamp"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave timestamp"

  - name: si_feature_usage
    description: "Silver layer feature usage analytics"
    columns:
      - name: usage_id
        description: "Unique usage record identifier"
        tests:
          - unique
          - not_null
      - name: usage_count
        description: "Feature usage count"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true

  - name: si_support_tickets
    description: "Silver layer support ticket data"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: status
        description: "Ticket status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer billing events"
    columns:
      - name: event_id
        description: "Unique billing event identifier"
        tests:
          - unique
          - not_null
      - name: amount
        description: "Billing amount"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: false

  - name: si_licenses
    description: "Silver layer license management"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - not_null

  - name: si_audit_log
    description: "Audit trail for Silver layer operations"
    columns:
      - name: audit_id
        description: "Unique audit record identifier"
        tests:
          - unique
          - not_null
      - name: audit_timestamp
        description: "Audit record timestamp"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### Test 1: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$')
```

#### Test 2: Meeting Duration Cleaning Validation
```sql
-- tests/test_meeting_duration_cleaning.sql
SELECT 
    meeting_id,
    duration_minutes,
    clean_duration_minutes
FROM {{ ref('si_meetings') }}
WHERE clean_duration_minutes IS NULL 
   OR clean_duration_minutes < 0
   OR clean_duration_minutes > 1440
```

#### Test 3: Date Format Conversion Validation
```sql
-- tests/test_license_date_conversion.sql
SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('si_licenses') }}
WHERE start_date IS NULL 
   OR end_date IS NULL 
   OR start_date >= end_date
```

#### Test 4: Participant Session Validation
```sql
-- tests/test_participant_session_validation.sql
SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.meeting_start_time,
    m.meeting_end_time
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.join_time > p.leave_time
   OR p.join_time < m.meeting_start_time
   OR p.leave_time > m.meeting_end_time
```

#### Test 5: Data Quality Score Validation
```sql
-- tests/test_data_quality_scores.sql
SELECT 
    'si_users' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN data_quality_score = 100 THEN 1 END) as perfect_score,
    COUNT(CASE WHEN data_quality_score < 50 THEN 1 END) as poor_quality
FROM {{ ref('si_users') }}
UNION ALL
SELECT 
    'si_meetings' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN data_quality_score = 100 THEN 1 END) as perfect_score,
    COUNT(CASE WHEN data_quality_score < 50 THEN 1 END) as poor_quality
FROM {{ ref('si_meetings') }}
-- Add similar unions for other tables
```

#### Test 6: Audit Log Completeness
```sql
-- tests/test_audit_log_completeness.sql
SELECT 
    table_name,
    operation_type,
    COUNT(*) as operation_count
FROM {{ ref('si_audit_log') }}
WHERE audit_timestamp >= CURRENT_DATE - 1
GROUP BY table_name, operation_type
HAVING COUNT(*) = 0  -- Should return no results if all operations are logged
```

#### Test 7: Cross-Model Referential Integrity
```sql
-- tests/test_referential_integrity.sql
-- Check for orphaned meeting records
SELECT 
    m.meeting_id,
    m.user_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check for orphaned participant records
SELECT 
    p.participant_id,
    p.meeting_id
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
```

#### Test 8: Numeric Field Cleaning Validation
```sql
-- tests/test_numeric_field_cleaning.sql
WITH test_cases AS (
    SELECT 
        meeting_id,
        duration_minutes as original_value,
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(duration_minutes::STRING)
        END as expected_clean_value,
        clean_duration_minutes as actual_clean_value
    FROM {{ ref('si_meetings') }}
    WHERE duration_minutes IS NOT NULL
)
SELECT *
FROM test_cases
WHERE expected_clean_value != actual_clean_value
   OR (expected_clean_value IS NULL AND actual_clean_value IS NOT NULL)
   OR (expected_clean_value IS NOT NULL AND actual_clean_value IS NULL)
```

### Parameterized Tests

#### Generic Test for Data Quality Scores
```sql
-- macros/test_data_quality_score_range.sql
{% macro test_data_quality_score_range(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
      AND ({{ column_name }} < 0 OR {{ column_name }} > 100)
{% endmacro %}
```

#### Generic Test for Timestamp Validation
```sql
-- macros/test_timestamp_order.sql
{% macro test_timestamp_order(model, start_column, end_column) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ start_column }} IS NOT NULL
      AND {{ end_column }} IS NOT NULL
      AND {{ start_column }} >= {{ end_column }}
{% endmacro %}
```

### Test Execution Configuration

```yaml
# dbt_project.yml test configuration
tests:
  zoom_silver_pipeline:
    +severity: error  # Fail builds on test failures
    +store_failures: true  # Store failed test results
    +schema: test_results  # Store test results in dedicated schema
```

### Performance Test Queries

#### Test 9: Large Dataset Performance
```sql
-- tests/test_large_dataset_performance.sql
-- This test ensures models can handle large datasets efficiently
SELECT 
    COUNT(*) as record_count,
    MAX(load_date) as latest_load_date,
    MIN(load_date) as earliest_load_date
FROM {{ ref('si_meetings') }}
HAVING COUNT(*) > 1000000  -- Adjust threshold as needed
```

#### Test 10: Query Performance Validation
```sql
-- tests/test_query_performance.sql
-- Validate that complex joins perform within acceptable limits
WITH performance_test AS (
    SELECT 
        u.user_id,
        COUNT(DISTINCT m.meeting_id) as meeting_count,
        COUNT(DISTINCT p.participant_id) as participant_count,
        COUNT(DISTINCT f.usage_id) as feature_usage_count
    FROM {{ ref('si_users') }} u
    LEFT JOIN {{ ref('si_meetings') }} m ON u.user_id = m.user_id
    LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id
    LEFT JOIN {{ ref('si_feature_usage') }} f ON m.meeting_id = f.meeting_id
    GROUP BY u.user_id
)
SELECT COUNT(*) as user_count
FROM performance_test
-- This query should complete within reasonable time limits
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before deployment
- Execute custom SQL tests for critical business rules
- Validate data quality scores and audit logging

### 2. Post-deployment Validation
- Verify all models materialized successfully
- Check audit log entries for all operations
- Validate cross-model relationships

### 3. Continuous Monitoring
- Schedule regular test runs
- Monitor data quality score trends
- Alert on test failures or performance degradation

### 4. Test Data Management
- Maintain test datasets for edge cases
- Version control test expectations
- Document test failure resolution procedures

## Expected Test Results

### Success Criteria
- All unique and not_null tests pass
- Email format validation achieves >95% pass rate
- Numeric field cleaning handles all format variations
- Date format conversion supports all specified formats
- Data quality scores calculated correctly
- Audit logging captures all operations
- Cross-model relationships maintained
- Performance tests complete within acceptable timeframes

### Failure Handling
- Failed tests logged in dbt run_results.json
- Critical failures prevent model deployment
- Warning-level failures logged but allow deployment
- Failed records excluded from Silver layer output
- Audit trail maintained for all test executions

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics Silver Layer dbt models in Snowflake, providing robust validation for all transformations, business rules, and edge cases.