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

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver Layer dbt models. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models in Snowflake.

## Test Case Overview

The test suite validates the following dbt models:
- `audit_log` - Audit tracking for silver layer transformations
- `si_users` - Silver layer users data with data quality checks
- `si_meetings` - Silver layer meetings data with calculated metrics
- `si_participants` - Silver layer participants data with deduplication

## Test Case List

### 1. Audit Log Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| AL_001 | Validate audit log table creation | Table exists with correct schema |
| AL_002 | Test audit log initialization | No rows inserted during initial creation |
| AL_003 | Validate audit log data types | All columns have correct Snowflake data types |
| AL_004 | Test audit log constraints | Status values conform to expected enumeration |

### 2. Silver Users Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SU_001 | Validate user data deduplication | Only latest records per user_id retained |
| SU_002 | Test email format validation | Invalid emails filtered out |
| SU_003 | Test email standardization | Emails converted to lowercase and trimmed |
| SU_004 | Test status domain validation | Only valid status values (active, inactive, pending) |
| SU_005 | Test null user_id handling | Records with null user_id excluded |
| SU_006 | Test data quality transformations | Names and departments properly trimmed |
| SU_007 | Test audit column population | created_at and updated_at populated correctly |
| SU_008 | Test bronze source dependency | Model references bronze_users correctly |
| SU_009 | Test edge case - empty strings | Empty strings handled appropriately |
| SU_010 | Test edge case - duplicate emails | Duplicate handling with latest record priority |

### 3. Silver Meetings Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SM_001 | Validate meeting data deduplication | Only latest records per meeting_id retained |
| SM_002 | Test duration validation | Duration between 0 and 1440 minutes |
| SM_003 | Test end time calculation | End time calculated correctly using DATEADD |
| SM_004 | Test participant count validation | Participant count >= 0 |
| SM_005 | Test meeting type validation | Only valid meeting types allowed |
| SM_006 | Test null meeting_id handling | Records with null meeting_id excluded |
| SM_007 | Test null host_id handling | Records with null host_id excluded |
| SM_008 | Test start time validation | Start time is not null |
| SM_009 | Test topic standardization | Meeting topics properly trimmed |
| SM_010 | Test timezone handling | Timezone values properly trimmed |
| SM_011 | Test edge case - zero duration | Zero duration meetings handled |
| SM_012 | Test edge case - maximum duration | 24-hour maximum duration enforced |

### 4. Silver Participants Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SP_001 | Validate participant deduplication | Only latest records per participant_id, meeting_id |
| SP_002 | Test duration calculation | Duration calculated correctly from join/leave times |
| SP_003 | Test join time validation | Join time is not null |
| SP_004 | Test duration range validation | Duration >= 0 seconds |
| SP_005 | Test email format validation | Email format validated when present |
| SP_006 | Test participant name standardization | Names properly trimmed |
| SP_007 | Test email standardization | Emails converted to lowercase |
| SP_008 | Test null participant_id handling | Records with null participant_id excluded |
| SP_009 | Test null meeting_id handling | Records with null meeting_id excluded |
| SP_010 | Test edge case - missing leave time | Calculated duration uses duration_seconds when leave_time null |
| SP_011 | Test edge case - same join/leave time | Zero duration handled correctly |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

sources:
  - name: bronze
    description: "Bronze layer raw data from Zoom API"
    tables:
      - name: bronze_users
        description: "Raw user data from Zoom"
        columns:
          - name: user_id
            description: "Unique identifier for user"
            tests:
              - not_null
              - unique
          - name: email
            description: "User email address"
            tests:
              - not_null
          - name: _loaded_at
            description: "Timestamp when data was loaded"
            tests:
              - not_null

      - name: bronze_meetings
        description: "Raw meeting data from Zoom"
        columns:
          - name: meeting_id
            description: "Unique identifier for meeting"
            tests:
              - not_null
              - unique
          - name: host_id
            description: "User ID of meeting host"
            tests:
              - not_null

      - name: bronze_participants
        description: "Raw participant data from Zoom"
        columns:
          - name: participant_id
            description: "Unique identifier for participant"
            tests:
              - not_null
          - name: meeting_id
            description: "Meeting identifier"
            tests:
              - not_null

models:
  - name: audit_log
    description: "Audit log for tracking all silver layer transformations"
    columns:
      - name: source_table
        description: "Name of the source table being processed"
        tests:
          - not_null
      - name: status
        description: "Status of the process"
        tests:
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'INITIALIZED']
      - name: created_at
        description: "Record creation timestamp"
        tests:
          - not_null

  - name: si_users
    description: "Silver layer clean user data"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - not_null
          - unique
      - name: email
        description: "Clean user email address"
        tests:
          - not_null
          - unique
      - name: status
        description: "User status"
        tests:
          - accepted_values:
              values: ['ACTIVE', 'INACTIVE', 'PENDING']
      - name: process_status
        description: "Processing status"
        tests:
          - not_null
          - accepted_values:
              values: ['ACTIVE', 'INACTIVE', 'ERROR']
      - name: created_at
        description: "Record creation timestamp"
        tests:
          - not_null
      - name: updated_at
        description: "Record update timestamp"
        tests:
          - not_null

  - name: si_meetings
    description: "Silver layer clean meeting data"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: start_time
        description: "Meeting start time"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
      - name: participants_count
        description: "Number of participants"
        tests:
          - not_null
      - name: created_at
        description: "Record creation timestamp"
        tests:
          - not_null
      - name: updated_at
        description: "Record update timestamp"
        tests:
          - not_null

  - name: si_participants
    description: "Silver layer clean participant data"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
        tests:
          - not_null
      - name: meeting_id
        description: "Associated meeting ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: join_time
        description: "When participant joined"
        tests:
          - not_null
      - name: duration_seconds
        description: "Participant session duration"
        tests:
          - not_null
      - name: created_at
        description: "Record creation timestamp"
        tests:
          - not_null
      - name: updated_at
        description: "Record update timestamp"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### Test 1: Email Format Validation

**File:** `tests/test_email_format_validation.sql`

```sql
-- Test that all emails in si_users follow valid format
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test 2: Meeting Duration Range Validation

**File:** `tests/test_meeting_duration_range.sql`

```sql
-- Test that meeting durations are within acceptable range (1 minute to 24 hours)
SELECT 
    meeting_id,
    duration_minutes
FROM {{ ref('si_meetings') }}
WHERE duration_minutes IS NOT NULL 
  AND (duration_minutes <= 0 OR duration_minutes > 1440)
```

#### Test 3: Participant Duration Logic Validation

**File:** `tests/test_participant_duration_logic.sql`

```sql
-- Test that participant duration is logical (non-negative)
SELECT 
    participant_id,
    meeting_id,
    duration_seconds
FROM {{ ref('si_participants') }}
WHERE duration_seconds IS NOT NULL 
  AND duration_seconds < 0
```

#### Test 4: Data Freshness Validation

**File:** `tests/test_data_freshness.sql`

```sql
-- Test that data is not older than expected threshold
SELECT 
    'si_users' as table_name,
    MAX(updated_at) as latest_update,
    DATEDIFF('hour', MAX(updated_at), CURRENT_TIMESTAMP()) as hours_since_update
FROM {{ ref('si_users') }}
WHERE DATEDIFF('hour', MAX(updated_at), CURRENT_TIMESTAMP()) > 25

UNION ALL

SELECT 
    'si_meetings' as table_name,
    MAX(updated_at) as latest_update,
    DATEDIFF('hour', MAX(updated_at), CURRENT_TIMESTAMP()) as hours_since_update
FROM {{ ref('si_meetings') }}
WHERE DATEDIFF('hour', MAX(updated_at), CURRENT_TIMESTAMP()) > 25

UNION ALL

SELECT 
    'si_participants' as table_name,
    MAX(updated_at) as latest_update,
    DATEDIFF('hour', MAX(updated_at), CURRENT_TIMESTAMP()) as hours_since_update
FROM {{ ref('si_participants') }}
WHERE DATEDIFF('hour', MAX(updated_at), CURRENT_TIMESTAMP()) > 25
```

#### Test 5: Referential Integrity Validation

**File:** `tests/test_referential_integrity.sql`

```sql
-- Test that all host_ids in meetings exist in users
SELECT 
    m.meeting_id,
    m.host_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL
  AND m.host_id IS NOT NULL
```

#### Test 6: Deduplication Effectiveness

**File:** `tests/test_deduplication_effectiveness.sql`

```sql
-- Test that deduplication worked correctly - no duplicate user_ids
SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1

UNION ALL

-- Test that deduplication worked correctly - no duplicate meeting_ids
SELECT 
    meeting_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_meetings') }}
GROUP BY meeting_id
HAVING COUNT(*) > 1
```

#### Test 7: Data Quality Score Validation

**File:** `tests/test_data_quality_metrics.sql`

```sql
-- Test data completeness metrics
WITH completeness_metrics AS (
    SELECT 
        'si_users' as table_name,
        COUNT(*) as total_records,
        COUNT(user_id) as user_id_count,
        COUNT(email) as email_count,
        COUNT(first_name) as first_name_count,
        COUNT(last_name) as last_name_count
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'si_meetings' as table_name,
        COUNT(*) as total_records,
        COUNT(meeting_id) as meeting_id_count,
        COUNT(host_id) as host_id_count,
        COUNT(start_time) as start_time_count,
        COUNT(duration_minutes) as duration_count
    FROM {{ ref('si_meetings') }}
)
SELECT 
    table_name,
    total_records,
    CASE 
        WHEN table_name = 'si_users' THEN 
            CASE WHEN total_records > 0 AND 
                     (user_id_count::FLOAT / total_records < 0.95 OR
                      email_count::FLOAT / total_records < 0.95)
                 THEN 'QUALITY_ISSUE'
                 ELSE 'ACCEPTABLE'
            END
        WHEN table_name = 'si_meetings' THEN 
            CASE WHEN total_records > 0 AND 
                     (meeting_id_count::FLOAT / total_records < 0.95 OR
                      host_id_count::FLOAT / total_records < 0.95 OR
                      start_time_count::FLOAT / total_records < 0.95)
                 THEN 'QUALITY_ISSUE'
                 ELSE 'ACCEPTABLE'
            END
    END as quality_status
FROM completeness_metrics
WHERE CASE 
        WHEN table_name = 'si_users' THEN 
            CASE WHEN total_records > 0 AND 
                     (user_id_count::FLOAT / total_records < 0.95 OR
                      email_count::FLOAT / total_records < 0.95)
                 THEN 'QUALITY_ISSUE'
                 ELSE 'ACCEPTABLE'
            END
        WHEN table_name = 'si_meetings' THEN 
            CASE WHEN total_records > 0 AND 
                     (meeting_id_count::FLOAT / total_records < 0.95 OR
                      host_id_count::FLOAT / total_records < 0.95 OR
                      start_time_count::FLOAT / total_records < 0.95)
                 THEN 'QUALITY_ISSUE'
                 ELSE 'ACCEPTABLE'
            END
    END = 'QUALITY_ISSUE'
```

#### Test 8: Temporal Logic Validation

**File:** `tests/test_temporal_logic.sql`

```sql
-- Test temporal logic consistency
SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes
FROM {{ ref('si_meetings') }}
WHERE end_time IS NOT NULL 
  AND start_time IS NOT NULL
  AND end_time <= start_time

UNION ALL

-- Test participant temporal logic
SELECT 
    participant_id as meeting_id,
    join_time as start_time,
    leave_time as end_time,
    duration_seconds as duration_minutes
FROM {{ ref('si_participants') }}
WHERE leave_time IS NOT NULL 
  AND join_time IS NOT NULL
  AND leave_time <= join_time
```

#### Test 9: Business Rule Validation

**File:** `tests/test_business_rules.sql`

```sql
-- Test business rules compliance
WITH business_rule_violations AS (
    -- Rule 1: Users must have valid email format
    SELECT 
        'INVALID_EMAIL_FORMAT' as rule_violation,
        user_id as record_id,
        email as violation_value
    FROM {{ ref('si_users') }}
    WHERE email IS NOT NULL 
      AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
    
    UNION ALL
    
    -- Rule 2: Meeting duration must be reasonable (> 0 and <= 1440 minutes)
    SELECT 
        'INVALID_MEETING_DURATION' as rule_violation,
        meeting_id as record_id,
        duration_minutes::VARCHAR as violation_value
    FROM {{ ref('si_meetings') }}
    WHERE duration_minutes IS NOT NULL 
      AND (duration_minutes <= 0 OR duration_minutes > 1440)
    
    UNION ALL
    
    -- Rule 3: Participant count must be non-negative
    SELECT 
        'NEGATIVE_PARTICIPANT_COUNT' as rule_violation,
        meeting_id as record_id,
        participants_count::VARCHAR as violation_value
    FROM {{ ref('si_meetings') }}
    WHERE participants_count IS NOT NULL 
      AND participants_count < 0
)
SELECT * FROM business_rule_violations
```

#### Test 10: Performance and Volume Validation

**File:** `tests/test_performance_metrics.sql`

```sql
-- Test for performance and volume metrics
WITH volume_metrics AS (
    SELECT 
        'si_users' as table_name,
        COUNT(*) as record_count,
        COUNT(DISTINCT user_id) as unique_keys,
        MIN(created_at) as earliest_record,
        MAX(updated_at) as latest_record
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'si_meetings' as table_name,
        COUNT(*) as record_count,
        COUNT(DISTINCT meeting_id) as unique_keys,
        MIN(created_at) as earliest_record,
        MAX(updated_at) as latest_record
    FROM {{ ref('si_meetings') }}
    
    UNION ALL
    
    SELECT 
        'si_participants' as table_name,
        COUNT(*) as record_count,
        COUNT(DISTINCT participant_id) as unique_keys,
        MIN(created_at) as earliest_record,
        MAX(updated_at) as latest_record
    FROM {{ ref('si_participants') }}
)
SELECT 
    table_name,
    record_count,
    unique_keys,
    CASE 
        WHEN record_count = 0 THEN 'EMPTY_TABLE'
        WHEN unique_keys::FLOAT / record_count < 0.95 THEN 'HIGH_DUPLICATE_RATIO'
        WHEN DATEDIFF('day', latest_record, CURRENT_TIMESTAMP()) > 7 THEN 'STALE_DATA'
        ELSE 'ACCEPTABLE'
    END as volume_status
FROM volume_metrics
WHERE CASE 
        WHEN record_count = 0 THEN 'EMPTY_TABLE'
        WHEN unique_keys::FLOAT / record_count < 0.95 THEN 'HIGH_DUPLICATE_RATIO'
        WHEN DATEDIFF('day', latest_record, CURRENT_TIMESTAMP()) > 7 THEN 'STALE_DATA'
        ELSE 'ACCEPTABLE'
    END != 'ACCEPTABLE'
```

### Parameterized Tests

#### Macro for Email Validation

**File:** `macros/test_email_validation.sql`

```sql
{% macro test_email_validation(model, column_name) %}
    SELECT 
        {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL 
      AND NOT REGEXP_LIKE({{ column_name }}, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
{% endmacro %}
```

#### Macro for Range Validation

**File:** `macros/test_range_validation.sql`

```sql
{% macro test_range_validation(model, column_name, min_value, max_value) %}
    SELECT 
        {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL 
      AND ({{ column_name }} < {{ min_value }} OR {{ column_name }} > {{ max_value }})
{% endmacro %}
```

#### Macro for Temporal Logic Validation

**File:** `macros/test_temporal_logic.sql`

```sql
{% macro test_temporal_logic(model, start_column, end_column) %}
    SELECT 
        {{ start_column }},
        {{ end_column }}
    FROM {{ model }}
    WHERE {{ start_column }} IS NOT NULL 
      AND {{ end_column }} IS NOT NULL
      AND {{ end_column }} <= {{ start_column }}
{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-hook Tests
- Validate source data availability
- Check bronze layer data quality
- Verify dependencies are met

### 2. Transformation Tests
- Validate data type conversions
- Test business logic implementation
- Verify calculated fields

### 3. Post-hook Tests
- Validate final data quality
- Check referential integrity
- Verify audit trail completeness

### 4. Performance Tests
- Monitor execution time
- Validate resource utilization
- Check for optimization opportunities

## Test Data Setup

### Sample Test Data for Bronze Layer

```sql
-- Sample bronze_users data for testing
INSERT INTO bronze_users VALUES
('USR001', 'john.doe@example.com', 'John', 'Doe', 'Engineering', 'Manager', 'ACC001', '2024-01-01 10:00:00', '2024-01-15 14:30:00', 'active', '2024-01-01 10:00:00'),
('USR002', 'jane.smith@test.com', 'Jane', 'Smith', 'Marketing', 'Director', 'ACC001', '2024-01-02 09:00:00', '2024-01-16 11:00:00', 'active', '2024-01-02 09:00:00'),
('USR003', 'invalid-email', 'Bob', 'Johnson', 'Sales', 'Rep', 'ACC001', '2024-01-03 08:00:00', '2024-01-17 16:00:00', 'inactive', '2024-01-03 08:00:00'),
('USR001', 'john.doe@example.com', 'John', 'Doe', 'Engineering', 'Senior Manager', 'ACC001', '2024-01-01 10:00:00', '2024-01-18 15:00:00', 'active', '2024-01-18 15:00:00'); -- Duplicate for deduplication test

-- Sample bronze_meetings data for testing
INSERT INTO bronze_meetings VALUES
('MTG001', 'USR001', 'Team Standup', 'scheduled', '2024-01-15 09:00:00', 30, 'UTC', 5, 0, 'ACC001', '2024-01-15 09:00:00'),
('MTG002', 'USR002', 'Product Review', 'scheduled', '2024-01-16 14:00:00', 60, 'UTC', 10, 1, 'ACC001', '2024-01-16 14:00:00'),
('MTG003', 'USR999', 'Invalid Host Meeting', 'instant', '2024-01-17 10:00:00', 45, 'UTC', 3, 0, 'ACC001', '2024-01-17 10:00:00'), -- Invalid host_id
('MTG004', 'USR001', 'Long Meeting', 'scheduled', '2024-01-18 08:00:00', 1500, 'UTC', 2, 0, 'ACC001', '2024-01-18 08:00:00'); -- Duration > 1440 minutes

-- Sample bronze_participants data for testing
INSERT INTO bronze_participants VALUES
('PRT001', 'MTG001', 'USR001', '2024-01-15 09:00:00', '2024-01-15 09:30:00', 1800, 'USR001', 'John Doe', 'john.doe@example.com', '2024-01-15 09:00:00'),
('PRT002', 'MTG001', 'USR002', '2024-01-15 09:05:00', '2024-01-15 09:30:00', 1500, 'USR002', 'Jane Smith', 'jane.smith@test.com', '2024-01-15 09:05:00'),
('PRT003', 'MTG002', 'USR001', '2024-01-16 14:00:00', NULL, 3600, 'USR001', 'John Doe', 'john.doe@example.com', '2024-01-16 14:00:00'), -- Missing leave_time
('PRT004', 'MTG999', 'USR002', '2024-01-17 10:00:00', '2024-01-17 10:45:00', 2700, 'USR002', 'Jane Smith', 'jane.smith@test.com', '2024-01-17 10:00:00'); -- Invalid meeting_id
```

## Expected Test Results

### Successful Test Scenarios
1. Valid user records should pass all validation tests
2. Proper email formats should be accepted
3. Meeting durations within range should pass validation
4. Deduplication should retain latest records
5. Audit logs should track all transformations

### Expected Test Failures
1. Invalid email formats should be caught
2. Meetings with duration > 1440 minutes should fail
3. Orphaned participants (invalid meeting_id) should be identified
4. Missing required fields should be flagged
5. Temporal logic violations should be detected

## Monitoring and Alerting

### dbt Test Results Tracking

```sql
-- Query to monitor test results
SELECT 
    test_name,
    status,
    execution_time,
    failures,
    run_started_at
FROM dbt_test_results
WHERE run_started_at >= CURRENT_DATE()
ORDER BY run_started_at DESC;
```

### Data Quality Dashboard Metrics

1. **Test Pass Rate**: Percentage of tests passing
2. **Data Completeness**: Percentage of non-null values in critical fields
3. **Data Freshness**: Time since last successful data load
4. **Error Rate**: Number of records failing validation
5. **Performance Metrics**: Model execution times and resource usage

## Continuous Integration

### dbt Test Execution in CI/CD

```bash
# Run all tests
dbt test

# Run tests for specific models
dbt test --models si_users si_meetings si_participants

# Run tests with specific tags
dbt test --models tag:data_quality

# Generate test documentation
dbt docs generate
dbt docs serve
```

### Test Result Integration

1. **Slack Notifications**: Automated alerts for test failures
2. **Email Reports**: Daily data quality summary reports
3. **Dashboard Updates**: Real-time test result visualization
4. **Jira Integration**: Automatic ticket creation for critical failures

## Conclusion

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics System Silver Layer dbt models. The combination of schema tests, custom SQL tests, and parameterized macros provides thorough coverage of:

- **Data Quality**: Email validation, range checks, format validation
- **Business Logic**: Deduplication, calculated fields, status derivation
- **Referential Integrity**: Foreign key relationships, orphaned record detection
- **Performance**: Execution time monitoring, resource utilization
- **Edge Cases**: Null handling, boundary conditions, error scenarios

Regular execution of these tests in the CI/CD pipeline ensures early detection of data quality issues and maintains the integrity of the analytics platform.