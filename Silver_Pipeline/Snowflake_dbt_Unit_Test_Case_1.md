_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Platform Analytics Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios for all 8 silver layer models that transform data from bronze to silver layer.

## Models Under Test

1. **SI_Audit_Log** - Audit logging table
2. **SI_Users** - User data with email validation and plan standardization
3. **SI_Meetings** - Meeting data with duration validation and timestamp handling
4. **SI_Participants** - Participant data with session time validation
5. **SI_Feature_Usage** - Feature usage data with standardization
6. **SI_Support_Tickets** - Support ticket data with status standardization
7. **SI_Billing_Events** - Billing event data with amount validation
8. **SI_Licenses** - License data with date format conversion

## Test Case List

### 1. SI_Users Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate email format using REGEXP_LIKE | Only valid email formats pass validation |
| TC_USR_002 | Test plan type standardization (FREE, BASIC, PRO, ENTERPRISE) | All plan types are standardized to uppercase |
| TC_USR_003 | Validate data quality scoring (0-100 range) | Data quality scores are within valid range |
| TC_USR_004 | Test deduplication logic using ROW_NUMBER() | No duplicate records in final output |
| TC_USR_005 | Validate null value elimination | No null values in critical fields |
| TC_USR_006 | Test invalid email format handling | Invalid emails are flagged or excluded |
| TC_USR_007 | Test empty/null plan type handling | Default plan type assigned or record flagged |
| TC_USR_008 | Validate audit log integration | Pre/post hooks execute successfully |

### 2. SI_Meetings Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Test numeric field text unit cleaning ("108 mins" issue) | Text units removed, numeric values extracted |
| TC_MTG_002 | Validate EST timezone conversion | Timestamps converted to EST timezone |
| TC_MTG_003 | Test duration validation (0-1440 minutes) | Meeting durations within valid range |
| TC_MTG_004 | Validate business logic (end_time > start_time) | End time is always after start time |
| TC_MTG_005 | Test null timestamp handling | Null timestamps handled appropriately |
| TC_MTG_006 | Test invalid duration values (negative/excessive) | Invalid durations flagged or corrected |
| TC_MTG_007 | Test meeting ID uniqueness | No duplicate meeting IDs |
| TC_MTG_008 | Validate timestamp format standardization | All timestamps in consistent format |

### 3. SI_Participants Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Test multiple timestamp format handling (DD/MM/YYYY, MM/DD/YYYY, EST) | All formats parsed correctly |
| TC_PRT_002 | Validate session time logic (leave_time > join_time) | Leave time is after join time |
| TC_PRT_003 | Test meeting boundary validation | Participant times within meeting duration |
| TC_PRT_004 | Test null join/leave time handling | Null times handled with default values |
| TC_PRT_005 | Validate participant ID uniqueness per meeting | No duplicate participants per meeting |
| TC_PRT_006 | Test invalid timestamp format handling | Invalid formats flagged or excluded |
| TC_PRT_007 | Test session duration calculation | Session duration calculated correctly |
| TC_PRT_008 | Validate meeting-participant relationship | All participants linked to valid meetings |

### 4. SI_Feature_Usage Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Test feature name standardization (UPPER/TRIM) | Feature names standardized consistently |
| TC_FTR_002 | Validate usage count validation (>= 0) | Usage counts are non-negative |
| TC_FTR_003 | Test date alignment validation | Usage dates align with valid date ranges |
| TC_FTR_004 | Test null feature name handling | Null feature names handled appropriately |
| TC_FTR_005 | Validate negative usage count handling | Negative counts flagged or corrected |
| TC_FTR_006 | Test feature usage aggregation | Usage counts aggregated correctly |
| TC_FTR_007 | Validate user-feature relationship | All usage linked to valid users |
| TC_FTR_008 | Test duplicate usage record handling | Duplicate records handled appropriately |

### 5. SI_Support_Tickets Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Test status standardization (OPEN, IN PROGRESS, RESOLVED, CLOSED) | All statuses standardized |
| TC_TKT_002 | Validate date validation (not future dates) | No future dates in ticket creation |
| TC_TKT_003 | Test ticket type standardization | Ticket types standardized consistently |
| TC_TKT_004 | Test null status handling | Default status assigned to null values |
| TC_TKT_005 | Validate ticket ID uniqueness | No duplicate ticket IDs |
| TC_TKT_006 | Test invalid date format handling | Invalid dates flagged or corrected |
| TC_TKT_007 | Validate ticket lifecycle logic | Status transitions follow business rules |
| TC_TKT_008 | Test user-ticket relationship | All tickets linked to valid users |

### 6. SI_Billing_Events Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Test amount validation (positive numbers, 2 decimal precision) | Amounts are positive with 2 decimals |
| TC_BIL_002 | Validate event type standardization | Event types standardized consistently |
| TC_BIL_003 | Test date validation (not future dates) | No future billing dates |
| TC_BIL_004 | Test null amount handling | Null amounts handled appropriately |
| TC_BIL_005 | Validate negative amount handling | Negative amounts flagged or excluded |
| TC_BIL_006 | Test billing event ID uniqueness | No duplicate billing event IDs |
| TC_BIL_007 | Validate currency format consistency | All amounts in consistent currency format |
| TC_BIL_008 | Test user-billing relationship | All billing events linked to valid users |

### 7. SI_Licenses Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Test DD/MM/YYYY date format conversion ("27/08/2024" issue) | DD/MM/YYYY dates converted correctly |
| TC_LIC_002 | Test multi-format date parsing (YYYY-MM-DD, DD/MM/YYYY, MM/DD/YYYY) | All date formats parsed correctly |
| TC_LIC_003 | Validate date logic (start_date <= end_date) | Start date is before or equal to end date |
| TC_LIC_004 | Test null date handling | Null dates handled with appropriate defaults |
| TC_LIC_005 | Validate license ID uniqueness | No duplicate license IDs |
| TC_LIC_006 | Test invalid date format handling | Invalid dates flagged or excluded |
| TC_LIC_007 | Test license status validation | License status values are valid |
| TC_LIC_008 | Validate user-license relationship | All licenses linked to valid users |

### 8. SI_Audit_Log Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Test audit log table structure | Table created with proper column definitions |
| TC_AUD_002 | Validate VARCHAR(255) max lengths | All string columns respect max length |
| TC_AUD_003 | Test audit log insertion | Audit records inserted successfully |
| TC_AUD_004 | Validate timestamp accuracy | Audit timestamps are accurate |
| TC_AUD_005 | Test audit log completeness | All required audit fields populated |
| TC_AUD_006 | Validate audit trail integrity | Audit trail maintains data integrity |
| TC_AUD_007 | Test audit log performance | Audit operations don't impact performance |
| TC_AUD_008 | Validate audit log retention | Audit logs retained per policy |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer users table with data quality validations"
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
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "User plan type"
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: si_meetings
    description: "Silver layer meetings table with duration and timestamp validations"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - unique
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - not_null

  - name: si_participants
    description: "Silver layer participants table with session time validations"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Associated meeting identifier"
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
        tests:
          - not_null

  - name: si_feature_usage
    description: "Silver layer feature usage table with usage validations"
    columns:
      - name: usage_id
        description: "Unique usage identifier"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Feature name (standardized)"
        tests:
          - not_null
      - name: usage_count
        description: "Usage count (non-negative)"
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_support_tickets
    description: "Silver layer support tickets with status validations"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: status
        description: "Ticket status (standardized)"
        tests:
          - accepted_values:
              values: ['OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED']
      - name: created_date
        description: "Ticket creation date"
        tests:
          - not_null

  - name: si_billing_events
    description: "Silver layer billing events with amount validations"
    columns:
      - name: billing_event_id
        description: "Unique billing event identifier"
        tests:
          - unique
          - not_null
      - name: amount
        description: "Billing amount (positive, 2 decimals)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: event_type
        description: "Billing event type (standardized)"
        tests:
          - not_null

  - name: si_licenses
    description: "Silver layer licenses with date format validations"
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
    description: "Silver layer audit log table"
    columns:
      - name: audit_id
        description: "Unique audit identifier"
        tests:
          - unique
          - not_null
      - name: table_name
        description: "Table name being audited"
        tests:
          - not_null
      - name: operation_type
        description: "Type of operation (INSERT, UPDATE, DELETE)"
        tests:
          - accepted_values:
              values: ['INSERT', 'UPDATE', 'DELETE']
```

### Custom SQL-based dbt Tests

#### 1. Email Format Validation Test
```sql
-- tests/test_email_format_validation.sql
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### 2. Meeting Duration Logic Test
```sql
-- tests/test_meeting_duration_logic.sql
SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes
FROM {{ ref('si_meetings') }}
WHERE end_time <= start_time
   OR duration_minutes < 0
   OR duration_minutes > 1440
```

#### 3. Participant Session Time Validation Test
```sql
-- tests/test_participant_session_validation.sql
SELECT 
    participant_id,
    meeting_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE leave_time <= join_time
```

#### 4. Feature Usage Count Validation Test
```sql
-- tests/test_feature_usage_validation.sql
SELECT 
    usage_id,
    feature_name,
    usage_count
FROM {{ ref('si_feature_usage') }}
WHERE usage_count < 0
   OR feature_name IS NULL
   OR TRIM(feature_name) = ''
```

#### 5. Billing Amount Precision Test
```sql
-- tests/test_billing_amount_precision.sql
SELECT 
    billing_event_id,
    amount
FROM {{ ref('si_billing_events') }}
WHERE amount <= 0
   OR ROUND(amount, 2) != amount
```

#### 6. License Date Logic Test
```sql
-- tests/test_license_date_logic.sql
SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('si_licenses') }}
WHERE start_date > end_date
   OR start_date IS NULL
   OR end_date IS NULL
```

#### 7. Data Quality Score Range Test
```sql
-- tests/test_data_quality_score_range.sql
SELECT 
    user_id,
    data_quality_score
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0
   OR data_quality_score > 100
```

#### 8. Duplicate Record Detection Test
```sql
-- tests/test_duplicate_records.sql
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

#### 9. Referential Integrity Test
```sql
-- tests/test_referential_integrity.sql
-- Check if all participants have valid meeting references
SELECT 
    p.participant_id,
    p.meeting_id
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
```

#### 10. Audit Log Completeness Test
```sql
-- tests/test_audit_log_completeness.sql
SELECT 
    audit_id,
    table_name,
    operation_type,
    audit_timestamp
FROM {{ ref('si_audit_log') }}
WHERE table_name IS NULL
   OR operation_type IS NULL
   OR audit_timestamp IS NULL
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before deployment
- Execute custom SQL tests to validate business rules
- Verify data quality scores and validation flags
- Check referential integrity across all models

### 2. Post-deployment Validation
- Validate record counts match expected ranges
- Check data freshness and completeness
- Verify audit log entries are created
- Monitor performance metrics

### 3. Continuous Monitoring
- Schedule regular test runs
- Set up alerts for test failures
- Monitor data quality trends
- Track test execution performance

## Critical P1 Fixes Validation

### 1. Numeric Field Text Unit Cleaning (SI_Meetings)
```sql
-- Validate "108 mins" issue is resolved
SELECT 
    meeting_id,
    duration_minutes,
    original_duration_field
FROM {{ ref('si_meetings') }}
WHERE duration_minutes IS NULL
   OR NOT REGEXP_LIKE(CAST(duration_minutes AS STRING), '^[0-9]+$')
```

### 2. DD/MM/YYYY Date Format Conversion (SI_Licenses)
```sql
-- Validate "27/08/2024" date format issue is resolved
SELECT 
    license_id,
    start_date,
    end_date,
    original_start_date,
    original_end_date
FROM {{ ref('si_licenses') }}
WHERE start_date IS NULL
   OR end_date IS NULL
   OR NOT REGEXP_LIKE(CAST(start_date AS STRING), '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
```

## Performance and Scalability Tests

### 1. Model Execution Time Test
```sql
-- Monitor model execution times
SELECT 
    model_name,
    execution_time_seconds,
    record_count
FROM dbt_run_results
WHERE execution_time_seconds > 300 -- Flag models taking > 5 minutes
```

### 2. Data Volume Validation Test
```sql
-- Validate expected data volumes
SELECT 
    'si_users' as table_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) BETWEEN 1000 AND 100000 THEN 'PASS' ELSE 'FAIL' END as volume_check
FROM {{ ref('si_users') }}

UNION ALL

SELECT 
    'si_meetings' as table_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) BETWEEN 5000 AND 500000 THEN 'PASS' ELSE 'FAIL' END as volume_check
FROM {{ ref('si_meetings') }}
```

## Error Handling and Recovery Tests

### 1. Null Value Handling Test
```sql
-- Test null value handling across all models
SELECT 
    'si_users' as table_name,
    'user_id' as column_name,
    COUNT(*) as null_count
FROM {{ ref('si_users') }}
WHERE user_id IS NULL

UNION ALL

SELECT 
    'si_meetings' as table_name,
    'meeting_id' as column_name,
    COUNT(*) as null_count
FROM {{ ref('si_meetings') }}
WHERE meeting_id IS NULL
```

### 2. Data Type Validation Test
```sql
-- Validate data types are correct
SELECT 
    table_name,
    column_name,
    data_type,
    CASE 
        WHEN table_name = 'SI_USERS' AND column_name = 'DATA_QUALITY_SCORE' AND data_type != 'NUMBER' THEN 'FAIL'
        WHEN table_name = 'SI_MEETINGS' AND column_name = 'DURATION_MINUTES' AND data_type != 'NUMBER' THEN 'FAIL'
        ELSE 'PASS'
    END as type_check
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'SILVER'
  AND table_name IN ('SI_USERS', 'SI_MEETINGS', 'SI_PARTICIPANTS', 'SI_FEATURE_USAGE', 'SI_SUPPORT_TICKETS', 'SI_BILLING_EVENTS', 'SI_LICENSES', 'SI_AUDIT_LOG')
```

## Test Results Tracking

All test results are tracked in:
1. **dbt's run_results.json** - Standard dbt test execution results
2. **Snowflake audit schema** - Custom audit logging for detailed tracking
3. **SI_Audit_Log table** - Application-specific audit trail

## Conclusion

This comprehensive unit test suite ensures the reliability, performance, and data quality of all Zoom Platform Analytics Silver Layer dbt models in Snowflake. The tests cover:

- ✅ **Data Quality Validation** - Email formats, plan types, amounts, dates
- ✅ **Business Rule Enforcement** - Duration limits, date logic, status values
- ✅ **Edge Case Handling** - Null values, invalid formats, boundary conditions
- ✅ **Critical P1 Fixes** - Numeric text cleaning, date format conversion
- ✅ **Performance Monitoring** - Execution times, data volumes
- ✅ **Referential Integrity** - Cross-model relationships
- ✅ **Audit Trail Completeness** - Comprehensive logging

Regular execution of these tests ensures the silver layer maintains high data quality standards and serves as a reliable "single source of truth" for downstream analytics and business intelligence applications.