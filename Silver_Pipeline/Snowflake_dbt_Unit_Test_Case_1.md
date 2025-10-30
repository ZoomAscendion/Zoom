_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics - Silver Layer Models

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Silver Layer dbt models in the Zoom Platform Analytics System. The tests cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and high-quality data processing in Snowflake.

## Test Coverage Overview

The test suite covers the following dbt models:
- **sv_users.sql** - User data transformation from Bronze to Silver
- **sv_meetings.sql** - Meeting data transformation with calculated metrics
- **sv_participants.sql** - Participant attendance data with duration calculations
- **sv_feature_usage.sql** - Feature usage analytics with categorization
- **audit_log.sql** - Audit logging for pipeline execution tracking

## Test Case List

### 1. SV_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SV_USERS_001 | Validate user_surrogate_key uniqueness and not null | All records have unique, non-null surrogate keys |
| SV_USERS_002 | Test email format validation and standardization | Invalid emails are filtered out, valid emails are lowercased |
| SV_USERS_003 | Verify plan_type enumeration validation | Only valid plan types (Free, Basic, Pro, Enterprise) are accepted |
| SV_USERS_004 | Test deduplication logic with ROW_NUMBER | Only latest record per user_id is retained |
| SV_USERS_005 | Validate data quality flag assignment | Correct flags assigned based on data completeness |
| SV_USERS_006 | Test email provider derivation logic | Email providers correctly categorized (Gmail, Yahoo, Microsoft, Other) |
| SV_USERS_007 | Verify plan tier calculation | Plan tiers correctly assigned (0-3) based on plan type |
| SV_USERS_008 | Test null handling and default values | Null values replaced with appropriate defaults |
| SV_USERS_009 | Validate incremental processing logic | Only new/updated records processed in incremental runs |
| SV_USERS_010 | Test edge case with empty/whitespace values | Empty strings and whitespace handled correctly |

### 2. SV_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SV_MEETINGS_001 | Validate meeting_surrogate_key uniqueness | All records have unique surrogate keys |
| SV_MEETINGS_002 | Test duration calculation and validation | Duration correctly calculated and validated (0-1440 minutes) |
| SV_MEETINGS_003 | Verify start/end time logic validation | End time must be >= start time |
| SV_MEETINGS_004 | Test meeting status derivation | Status correctly derived from timestamps and current time |
| SV_MEETINGS_005 | Validate time of day categorization | Meetings correctly categorized by time (Morning, Afternoon, Evening, Night) |
| SV_MEETINGS_006 | Test meeting length categorization | Meetings categorized as Short (<15min), Medium (<60min), Long (>=60min) |
| SV_MEETINGS_007 | Verify deduplication with latest record | Only most recent record per meeting_id retained |
| SV_MEETINGS_008 | Test data quality flag assignment | Flags assigned based on missing topic or end time |
| SV_MEETINGS_009 | Validate incremental processing | Only updated meetings processed in incremental runs |
| SV_MEETINGS_010 | Test edge case with null end times | Meetings without end times handled appropriately |

### 3. SV_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SV_PARTICIPANTS_001 | Validate participant_surrogate_key uniqueness | All records have unique surrogate keys |
| SV_PARTICIPANTS_002 | Test foreign key relationships | Meeting and user surrogate keys correctly generated |
| SV_PARTICIPANTS_003 | Verify participation duration calculation | Duration correctly calculated from join/leave times |
| SV_PARTICIPANTS_004 | Test participation category assignment | Categories assigned based on duration (Brief, Short, Medium, Long) |
| SV_PARTICIPANTS_005 | Validate participation status logic | Status correctly derived (Currently Active, Completed, Scheduled) |
| SV_PARTICIPANTS_006 | Test join/leave time validation | Leave time must be >= join time when present |
| SV_PARTICIPANTS_007 | Verify deduplication logic | Only latest record per participant_id retained |
| SV_PARTICIPANTS_008 | Test data quality flag for missing leave time | Flag assigned when leave time is missing |
| SV_PARTICIPANTS_009 | Validate incremental processing | Only updated participant records processed |
| SV_PARTICIPANTS_010 | Test edge case with active participants | Participants still in meeting handled correctly |

### 4. SV_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SV_FEATURE_USAGE_001 | Validate usage_surrogate_key uniqueness | All records have unique surrogate keys |
| SV_FEATURE_USAGE_002 | Test feature name standardization | Feature names standardized to uppercase |
| SV_FEATURE_USAGE_003 | Verify feature category mapping | Features correctly categorized (Screen Sharing, Chat, Recording, etc.) |
| SV_FEATURE_USAGE_004 | Test usage intensity classification | Usage classified as Not Used, Light, Moderate, Heavy |
| SV_FEATURE_USAGE_005 | Validate usage count validation | Usage count must be >= 0 |
| SV_FEATURE_USAGE_006 | Test date extraction logic | Year, month, day of week correctly extracted |
| SV_FEATURE_USAGE_007 | Verify deduplication logic | Only latest record per usage_id retained |
| SV_FEATURE_USAGE_008 | Test data quality flag for zero usage | Flag assigned for zero usage records |
| SV_FEATURE_USAGE_009 | Validate incremental processing | Only updated usage records processed |
| SV_FEATURE_USAGE_010 | Test edge case with unknown features | Unknown features categorized as 'Other' |

### 5. AUDIT_LOG Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| AUDIT_LOG_001 | Validate audit_id uniqueness | All audit records have unique IDs |
| AUDIT_LOG_002 | Test incremental processing logic | Only new audit records added in incremental runs |
| AUDIT_LOG_003 | Verify status enumeration | Status values limited to valid options |
| AUDIT_LOG_004 | Test timestamp consistency | Process times are logical and consistent |
| AUDIT_LOG_005 | Validate record count accuracy | Record counts match actual processing results |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  - name: sv_users
    description: "Silver layer cleaned and transformed user data"
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
    columns:
      - name: user_surrogate_key
        description: "Surrogate key for user dimension"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Business key - unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: email
        description: "Cleaned and standardized email address"
        tests:
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
              row_condition: "email IS NOT NULL"
      - name: plan_type
        description: "Type of subscription plan"
        tests:
          - not_null
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: email_provider
        description: "Derived email provider category"
        tests:
          - accepted_values:
              values: ['Gmail', 'Yahoo', 'Microsoft', 'Other']
      - name: plan_tier
        description: "Numeric plan tier"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 3
      - name: data_quality_flag
        description: "Flag indicating data quality issues"
        tests:
          - not_null
          - accepted_values:
              values: ['CLEAN', 'EMAIL_MISSING', 'COMPANY_MISSING']

  - name: sv_meetings
    description: "Silver layer cleaned and transformed meeting data"
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 10000000
    columns:
      - name: meeting_surrogate_key
        description: "Surrogate key for meeting dimension"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Business key - unique identifier for each meeting"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "Reference to meeting host user"
        tests:
          - not_null
          - relationships:
              to: source('bronze', 'bz_users')
              field: user_id
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max
      - name: meeting_status
        description: "Current status of the meeting"
        tests:
          - not_null
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Incomplete']
      - name: time_of_day
        description: "Time categorization"
        tests:
          - accepted_values:
              values: ['Morning', 'Afternoon', 'Evening', 'Night']
      - name: meeting_length_category
        description: "Meeting length categorization"
        tests:
          - accepted_values:
              values: ['Short', 'Medium', 'Long']

  - name: sv_participants
    description: "Silver layer cleaned and transformed participant data"
    columns:
      - name: participant_surrogate_key
        description: "Surrogate key for participant fact"
        tests:
          - not_null
          - unique
      - name: meeting_surrogate_key
        description: "Foreign key to meeting dimension"
        tests:
          - not_null
          - relationships:
              to: ref('sv_meetings')
              field: meeting_surrogate_key
      - name: user_surrogate_key
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('sv_users')
              field: user_surrogate_key
      - name: participation_duration_minutes
        description: "Duration of participation in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max
              row_condition: "participation_duration_minutes IS NOT NULL"
      - name: participation_category
        description: "Participation duration category"
        tests:
          - accepted_values:
              values: ['Active', 'Brief', 'Short', 'Medium', 'Long']
      - name: participation_status
        description: "Current participation status"
        tests:
          - accepted_values:
              values: ['Currently Active', 'Completed', 'Scheduled', 'Unknown']

  - name: sv_feature_usage
    description: "Silver layer cleaned and transformed feature usage data"
    columns:
      - name: usage_surrogate_key
        description: "Surrogate key for feature usage fact"
        tests:
          - not_null
          - unique
      - name: meeting_surrogate_key
        description: "Foreign key to meeting dimension"
        tests:
          - not_null
          - relationships:
              to: ref('sv_meetings')
              field: meeting_surrogate_key
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: feature_category
        description: "Feature category classification"
        tests:
          - accepted_values:
              values: ['Screen Sharing', 'Chat', 'Recording', 'Breakout Rooms', 'Whiteboard', 'Other']
      - name: usage_intensity
        description: "Usage intensity classification"
        tests:
          - accepted_values:
              values: ['Not Used', 'Light Usage', 'Moderate Usage', 'Heavy Usage']

  - name: audit_log
    description: "Audit log table for tracking silver layer transformations"
    columns:
      - name: audit_id
        description: "Unique identifier for each audit record"
        tests:
          - not_null
          - unique
      - name: source_table
        description: "Name of the source table being processed"
        tests:
          - not_null
      - name: status
        description: "Status of the processing operation"
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'INITIALIZED']
```

### Custom SQL-based Tests

#### Test 1: User Email Validation
```sql
-- tests/assert_valid_user_emails.sql
-- Test that all user emails follow valid format when not null

SELECT 
    user_id,
    email
FROM {{ ref('sv_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
```

#### Test 2: Meeting Duration Consistency
```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test that calculated duration matches stored duration

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('sv_meetings') }}
WHERE end_time IS NOT NULL 
  AND start_time IS NOT NULL
  AND ABS(DATEDIFF('minute', start_time, end_time) - duration_minutes) > 1
```

#### Test 3: Participant Time Logic
```sql
-- tests/assert_participant_time_logic.sql
-- Test that leave time is after join time

SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('sv_participants') }}
WHERE leave_time IS NOT NULL 
  AND leave_time < join_time
```

#### Test 4: Feature Usage Count Validation
```sql
-- tests/assert_feature_usage_counts.sql
-- Test that usage counts are non-negative

SELECT 
    usage_id,
    feature_name,
    usage_count
FROM {{ ref('sv_feature_usage') }}
WHERE usage_count < 0
```

#### Test 5: Data Quality Score Range
```sql
-- tests/assert_data_quality_score_range.sql
-- Test that data quality flags are within valid range

WITH quality_check AS (
    SELECT 'sv_users' as table_name, user_id as record_id, data_quality_flag
    FROM {{ ref('sv_users') }}
    WHERE data_quality_flag NOT IN ('CLEAN', 'EMAIL_MISSING', 'COMPANY_MISSING')
    
    UNION ALL
    
    SELECT 'sv_meetings', meeting_id, data_quality_flag
    FROM {{ ref('sv_meetings') }}
    WHERE data_quality_flag NOT IN ('CLEAN', 'TOPIC_MISSING', 'END_TIME_MISSING')
    
    UNION ALL
    
    SELECT 'sv_participants', participant_id, data_quality_flag
    FROM {{ ref('sv_participants') }}
    WHERE data_quality_flag NOT IN ('CLEAN', 'LEAVE_TIME_MISSING')
    
    UNION ALL
    
    SELECT 'sv_feature_usage', usage_id, data_quality_flag
    FROM {{ ref('sv_feature_usage') }}
    WHERE data_quality_flag NOT IN ('CLEAN', 'ZERO_USAGE')
)
SELECT * FROM quality_check
```

#### Test 6: Surrogate Key Consistency
```sql
-- tests/assert_surrogate_key_consistency.sql
-- Test that surrogate keys are generated consistently

WITH key_check AS (
    SELECT 
        user_id,
        user_surrogate_key,
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} AS expected_key
    FROM {{ ref('sv_users') }}
    WHERE user_surrogate_key != {{ dbt_utils.generate_surrogate_key(['user_id']) }}
)
SELECT * FROM key_check
```

#### Test 7: Incremental Processing Validation
```sql
-- tests/assert_incremental_processing.sql
-- Test that incremental processing works correctly

{% if is_incremental() %}
SELECT 
    meeting_id,
    bronze_update_timestamp
FROM {{ ref('sv_meetings') }}
WHERE bronze_update_timestamp <= (
    SELECT COALESCE(MAX(bronze_update_timestamp), '1900-01-01') 
    FROM {{ this }}
)
{% else %}
-- Full refresh - no test needed
SELECT 1 WHERE FALSE
{% endif %}
```

#### Test 8: Business Rule Validation - Plan Tier Mapping
```sql
-- tests/assert_plan_tier_mapping.sql
-- Test that plan tier mapping is correct

SELECT 
    user_id,
    plan_type,
    plan_tier
FROM {{ ref('sv_users') }}
WHERE (
    (plan_type = 'Free' AND plan_tier != 0) OR
    (plan_type = 'Basic' AND plan_tier != 1) OR
    (plan_type = 'Pro' AND plan_tier != 2) OR
    (plan_type = 'Enterprise' AND plan_tier != 3)
)
```

#### Test 9: Cross-Model Referential Integrity
```sql
-- tests/assert_cross_model_integrity.sql
-- Test referential integrity across models

WITH integrity_check AS (
    -- Check meetings reference valid users
    SELECT 'meetings_to_users' as check_type, m.meeting_id as record_id
    FROM {{ ref('sv_meetings') }} m
    LEFT JOIN {{ ref('sv_users') }} u ON m.host_id = u.user_id
    WHERE u.user_id IS NULL
    
    UNION ALL
    
    -- Check participants reference valid meetings and users
    SELECT 'participants_to_meetings', p.participant_id
    FROM {{ ref('sv_participants') }} p
    LEFT JOIN {{ ref('sv_meetings') }} m ON p.meeting_surrogate_key = m.meeting_surrogate_key
    WHERE m.meeting_surrogate_key IS NULL
    
    UNION ALL
    
    SELECT 'participants_to_users', p.participant_id
    FROM {{ ref('sv_participants') }} p
    LEFT JOIN {{ ref('sv_users') }} u ON p.user_surrogate_key = u.user_surrogate_key
    WHERE u.user_surrogate_key IS NULL
)
SELECT * FROM integrity_check
```

#### Test 10: Data Freshness and Completeness
```sql
-- tests/assert_data_freshness.sql
-- Test that data is fresh and complete

WITH freshness_check AS (
    SELECT 
        'sv_users' as table_name,
        COUNT(*) as record_count,
        MAX(silver_updated_at) as latest_update,
        DATEDIFF('hour', MAX(silver_updated_at), CURRENT_TIMESTAMP()) as hours_since_update
    FROM {{ ref('sv_users') }}
    
    UNION ALL
    
    SELECT 
        'sv_meetings',
        COUNT(*),
        MAX(silver_updated_at),
        DATEDIFF('hour', MAX(silver_updated_at), CURRENT_TIMESTAMP())
    FROM {{ ref('sv_meetings') }}
    
    UNION ALL
    
    SELECT 
        'sv_participants',
        COUNT(*),
        MAX(silver_updated_at),
        DATEDIFF('hour', MAX(silver_updated_at), CURRENT_TIMESTAMP())
    FROM {{ ref('sv_participants') }}
    
    UNION ALL
    
    SELECT 
        'sv_feature_usage',
        COUNT(*),
        MAX(silver_updated_at),
        DATEDIFF('hour', MAX(silver_updated_at), CURRENT_TIMESTAMP())
    FROM {{ ref('sv_feature_usage') }}
)
SELECT * 
FROM freshness_check 
WHERE hours_since_update > 24  -- Alert if data is more than 24 hours old
   OR record_count = 0         -- Alert if no records
```

### Parameterized Tests

#### Generic Test for Surrogate Key Validation
```sql
-- macros/test_surrogate_key_format.sql
{% macro test_surrogate_key_format(model, column_name) %}

SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} IS NULL 
   OR LENGTH({{ column_name }}) != 32  -- MD5 hash length
   OR NOT REGEXP_LIKE({{ column_name }}, '^[a-f0-9]{32}$')

{% endmacro %}
```

#### Generic Test for Timestamp Validation
```sql
-- macros/test_timestamp_logic.sql
{% macro test_timestamp_logic(model, start_col, end_col) %}

SELECT *
FROM {{ model }}
WHERE {{ end_col }} IS NOT NULL 
  AND {{ start_col }} IS NOT NULL
  AND {{ end_col }} < {{ start_col }}

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before deploying models
- Execute custom SQL tests to validate business logic
- Perform data quality checks on sample datasets

### 2. Post-deployment Validation
- Monitor test results in dbt's run_results.json
- Set up alerts for test failures
- Track test execution times and performance

### 3. Continuous Monitoring
- Schedule regular test execution
- Monitor data quality trends over time
- Implement automated remediation for common issues

### 4. Test Maintenance
- Review and update tests as business rules change
- Add new tests for edge cases discovered in production
- Optimize test performance for large datasets

## Expected Test Results

### Success Criteria
- All schema tests pass with 100% success rate
- Custom SQL tests return zero rows (indicating no issues)
- Data quality scores meet defined thresholds (>= 0.8)
- Referential integrity maintained across all models
- Incremental processing works correctly

### Failure Scenarios and Remediation
- **Test failures**: Investigate root cause, fix data or logic
- **Performance issues**: Optimize queries and add appropriate indexes
- **Data quality degradation**: Implement additional validation rules
- **Schema changes**: Update tests to reflect new requirements

## Integration with Snowflake Audit Schema

All test results are automatically tracked in:
- dbt's native `run_results.json` for test execution details
- Snowflake's `INFORMATION_SCHEMA` for query performance metrics
- Custom audit tables for business-specific monitoring
- Integration with monitoring tools for alerting and dashboards

This comprehensive test suite ensures the reliability, accuracy, and performance of the Silver Layer dbt models while providing robust monitoring and alerting capabilities for production environments.